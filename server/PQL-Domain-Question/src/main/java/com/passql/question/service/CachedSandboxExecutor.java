package com.passql.question.service;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectReader;
import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.entity.Question;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.util.Collection;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * 문제 SQL 실행 공통 지점: 결과 캐시(서버 메모리 > Redis) > 빠진 SQL만 샌드박스 실행 > 저장 (#727)
 * 같은 문제·같은 SQL 은 회원이 달라도 결과가 같아 공유 (SELECT·WITH 만, 문제 수정 시 키가 바뀌어 자동 무효)
 */
@Slf4j
@Component
public class CachedSandboxExecutor {

    // Redis 키: sandbox:result:v1:{questionUuid}:{sha256(문제 내용 + SQL)}
    private static final String REDIS_KEY_PREFIX = "sandbox:result:v1:";
    // Redis 보관 기간 (blue·green 공유, 재배포 뒤에도 유지)
    private static final Duration REDIS_TTL = Duration.ofDays(7);
    // 서버 메모리 캐시: 최대 건수, 보관 시간
    private static final int LOCAL_CACHE_MAX_SIZE = 5_000;
    private static final Duration LOCAL_CACHE_TTL = Duration.ofMinutes(30);
    // 저장하는 결과 최대 행 수 (큰 결과는 매번 실행)
    private static final int MAX_CACHED_ROW_COUNT = 1_000;
    // 다시 실행하면 달라질 수 있는 오류 문구 (시간 초과·연결·자원 부족 > 저장 안 함)
    private static final List<String> TRANSIENT_ERROR_KEYWORDS =
            List.of("timeout", "canceling statement", "connection", "terminating", "out of memory", "too many");
    // 결과가 늘 같은 SQL 오류 예외 이름 (문법·없는 열 등)
    private static final String DETERMINISTIC_SQL_ERROR_CODE = "PSQLException";
    private static final String STATUS_OK = "OK";

    private final SandboxExecutor sandboxExecutor;
    private final RedisTemplate<String, Object> redisTemplate;
    private final ObjectMapper objectMapper;
    // 소수 끝자리 보존 (3000.50 > 3000.5 방지)
    private final ObjectReader executeResultReader;
    private final Cache<String, ExecuteResult> localCache = Caffeine.newBuilder()
            .maximumSize(LOCAL_CACHE_MAX_SIZE)
            .expireAfterWrite(LOCAL_CACHE_TTL)
            .build();

    public CachedSandboxExecutor(SandboxExecutor sandboxExecutor,
                                 RedisTemplate<String, Object> redisTemplate,
                                 ObjectMapper objectMapper) {
        this.sandboxExecutor = sandboxExecutor;
        this.redisTemplate = redisTemplate;
        this.objectMapper = objectMapper;
        this.executeResultReader = objectMapper.readerFor(ExecuteResult.class)
                .with(DeserializationFeature.USE_BIG_DECIMAL_FOR_FLOATS);
    }

    /** 문제 1건 SQL 1개 실행 (캐시 우선) */
    public ExecuteResult execute(Question question, String sql) {
        return executeAll(question, List.of(sql)).get(sql);
    }

    /**
     * 문제 1건 SQL 여러 개: 캐시 조회 > 빠진 SQL만 실행(영구 DB 직접 또는 임시 DB 1회) > 저장
     * 반환: {입력 SQL: 결과}, 입력 순서 유지 (null·빈 SQL 제외)
     */
    public Map<String, ExecuteResult> executeAll(Question question, Collection<String> sqls) {
        Set<String> uniqueSqls = new LinkedHashSet<>();
        for (String sql : sqls) {
            if (sql != null && !sql.isBlank()) uniqueSqls.add(sql);
        }
        Map<String, ExecuteResult> resultBySql = new LinkedHashMap<>();
        Map<String, String> cacheKeyBySql = new LinkedHashMap<>();
        for (String sql : uniqueSqls) {
            String cacheKey = toCacheKey(question, sql);
            cacheKeyBySql.put(sql, cacheKey);
            ExecuteResult cachedResult = findCachedResult(cacheKey);
            if (cachedResult != null) resultBySql.put(sql, cachedResult);
        }

        List<String> missingSqls = uniqueSqls.stream().filter(sql -> !resultBySql.containsKey(sql)).toList();
        if (!missingSqls.isEmpty()) {
            Map<String, ExecuteResult> executedResultBySql = runInSandbox(question, missingSqls);
            executedResultBySql.forEach((sql, result) -> {
                resultBySql.put(sql, result);
                if (isCacheable(sql, result)) storeResult(cacheKeyBySql.get(sql), result);
            });
        }
        log.debug("[sandbox cache] question={} total={} hit={}",
                question.getQuestionUuid(), uniqueSqls.size(), uniqueSqls.size() - missingSqls.size());

        // 입력 순서로 다시 정렬
        Map<String, ExecuteResult> orderedResultBySql = new LinkedHashMap<>();
        for (String sql : uniqueSqls) orderedResultBySql.put(sql, resultBySql.get(sql));
        return orderedResultBySql;
    }

    /** 빠진 SQL 실행: 영구 DB 가 있으면 직접, 없으면 임시 DB 1회에 모두 (DDL 적용 1번) */
    private Map<String, ExecuteResult> runInSandbox(Question question, List<String> sqls) {
        String dbName = question.getSandboxDbName();
        if (dbName != null && !dbName.isBlank()) {
            Map<String, ExecuteResult> resultBySql = new LinkedHashMap<>();
            for (String sql : sqls) resultBySql.put(sql, sandboxExecutor.execute(dbName, sql));
            return resultBySql;
        }
        return sandboxExecutor.runInTemporarySandbox(question.getSchemaDdl(), question.getSchemaSampleData(),
                temporaryDbName -> {
                    Map<String, ExecuteResult> resultBySql = new LinkedHashMap<>();
                    for (String sql : sqls) resultBySql.put(sql, sandboxExecutor.execute(temporaryDbName, sql));
                    return resultBySql;
                });
    }

    /** 서버 메모리 > Redis 순 조회 (Redis 에서 찾으면 메모리에도 올림, Redis 오류는 없음 취급) */
    private ExecuteResult findCachedResult(String cacheKey) {
        ExecuteResult localResult = localCache.getIfPresent(cacheKey);
        if (localResult != null) return localResult;
        try {
            Object storedJson = redisTemplate.opsForValue().get(cacheKey);
            if (storedJson == null) return null;
            ExecuteResult redisResult = executeResultReader.readValue(storedJson.toString());
            localCache.put(cacheKey, redisResult);
            return redisResult;
        } catch (Exception e) {
            log.warn("[sandbox cache] read failed : key={}, cause={}", cacheKey, e.getClass().getSimpleName());
            return null;
        }
    }

    /** 서버 메모리 + Redis 저장 (Redis 오류는 메모리만) */
    private void storeResult(String cacheKey, ExecuteResult result) {
        localCache.put(cacheKey, result);
        try {
            redisTemplate.opsForValue().set(cacheKey, objectMapper.writeValueAsString(result), REDIS_TTL);
        } catch (Exception e) {
            log.warn("[sandbox cache] write failed : key={}, cause={}", cacheKey, e.getClass().getSimpleName());
        }
    }

    /**
     * 저장해도 되는 결과: 읽기 SQL(SELECT·WITH) + (성공·행 수 한도 안 | 늘 같은 SQL 오류)
     * 시간 초과·연결 오류처럼 다시 하면 달라질 결과는 저장 안 함
     */
    static boolean isCacheable(String sql, ExecuteResult result) {
        if (result == null || !isReadOnlySql(sql)) return false;
        if (STATUS_OK.equals(result.status())) return result.rowCount() <= MAX_CACHED_ROW_COUNT;
        if (!DETERMINISTIC_SQL_ERROR_CODE.equals(result.errorCode())) return false;
        String errorMessage = Objects.requireNonNullElse(result.errorMessage(), "").toLowerCase(Locale.ROOT);
        return TRANSIENT_ERROR_KEYWORDS.stream().noneMatch(errorMessage::contains);
    }

    private static boolean isReadOnlySql(String sql) {
        String upperSql = sql.strip().toUpperCase(Locale.ROOT);
        return upperSql.startsWith("SELECT") || upperSql.startsWith("WITH");
    }

    /**
     * 캐시 키: 문제 UUID + sha256(문제 실행 환경 + 정리한 SQL)
     * 실행 환경 5개: 영구 DB 이름, DDL, 샘플 데이터, 수정 시각 (문제를 고치면 키가 바뀜)
     */
    static String toCacheKey(Question question, String sql) {
        String fingerprint = String.join("\u0000",
                Objects.toString(question.getSandboxDbName(), ""),
                Objects.toString(question.getSchemaDdl(), ""),
                Objects.toString(question.getSchemaSampleData(), ""),
                Objects.toString(question.getUpdatedAt(), ""),
                toNormalizedSql(sql));
        return REDIS_KEY_PREFIX + question.getQuestionUuid() + ":" + sha256Hex(fingerprint);
    }

    /** SQL 정리: 줄바꿈 통일 + 앞뒤 공백·끝 세미콜론 제거 (문자열 안 공백은 그대로) */
    static String toNormalizedSql(String sql) {
        String normalizedSql = sql.replace("\r\n", "\n").strip();
        while (normalizedSql.endsWith(";")) {
            normalizedSql = normalizedSql.substring(0, normalizedSql.length() - 1).strip();
        }
        return normalizedSql;
    }

    private static String sha256Hex(String text) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(text.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 unavailable", e);
        }
    }
}
