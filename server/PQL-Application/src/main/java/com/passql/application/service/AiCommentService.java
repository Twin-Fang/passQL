package com.passql.application.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.dto.AiCommentResponse;
import com.passql.application.service.statsanalysis.StatsAnalysisService;
import com.passql.application.service.statsanalysis.StatsAnalysisService.StatsAnalysisResult;
import com.passql.application.service.statsanalysis.SessionCommentService;
import com.passql.application.service.statsanalysis.SessionCommentService.SessionCommentResult;
import com.passql.submission.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
// 클래스 단위 트랜잭션 없음: LLM 호출 동안 DB 커넥션을 잡지 않게 (#497)
public class AiCommentService {

    private static final String CACHE_KEY_PREFIX = "ai-comment:";
    /** 세션 단위 캐시 TTL — 결과 화면 확인 시간으로 충분 */
    private static final long CACHE_TTL_HOURS = 2;
    /** 통계 화면 캐시 TTL — 키에 날짜가 있어 하루 넘게 둘 필요 없음 (#699) */
    private static final long STATS_CACHE_TTL_HOURS = 24;
    /** 통계 화면 갱신 단위 (최근 풀이 수 10문제마다 새 코멘트, #699) */
    static final int STATS_REFRESH_SOLVED_COUNT = 10;
    // 캐시 키 날짜 형식 (yyyy-MM-dd)
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    /** 통계 화면 최근 활동 기간 (일) */
    private static final int RECENT_ACTIVITY_DAYS = 7;

    private final SubmissionRepository submissionRepository;
    private final StatsAnalysisService statsAnalysisService;
    private final SessionCommentService sessionCommentService;
    private final RedisTemplate<String, Object> redisTemplate;
    private final ObjectMapper objectMapper;

    /**
     * AI 코멘트 반환.
     * - sessionUuid 있음(결과 화면): 서버 판정 문장 + 놓친 문제 LLM 한 문장 (SessionCommentService, analysis 없음, #862)
     * - sessionUuid 없음(통계 화면): 서버 판정 구조화 분석 + 토픽별 한 문장 (StatsAnalysisService, #861)
     *
     * 캐시 키: ai-comment:{memberUuid}:{sessionUuid} / ai-comment:{memberUuid}:stats:{날짜}:{갱신 구간}
     * 등급 잠금은 컨트롤러 @RequiresProFeature(AI_COMMENT) 에서 (두 형태 모두 프로 전용, #860)
     */
    public AiCommentResponse getAiComment(UUID memberUuid, UUID sessionUuid) {
        // 통계 화면: 같은 날 같은 갱신 구간이면 캐시 재사용 > 풀이마다 LLM 호출하지 않게 (#567, #699)
        String cacheKey = sessionUuid != null
                ? CACHE_KEY_PREFIX + memberUuid + ":" + sessionUuid
                : CACHE_KEY_PREFIX + memberUuid + ":stats:" + toStatsRefreshBucket(LocalDate.now(), countRecentSubmissions(memberUuid));
        long cacheTtlHours = sessionUuid != null ? CACHE_TTL_HOURS : STATS_CACHE_TTL_HOURS;

        AiCommentResponse cached = readCache(cacheKey, memberUuid);
        if (cached != null) {
            return cached;
        }

        // 통계 화면: 분석 실패(LLM·해석)면 insight 없이 응답하고 캐시하지 않음 > 다음 진입에 다시 시도
        if (sessionUuid == null) {
            StatsAnalysisResult statsResult = statsAnalysisService.analyze(memberUuid);
            if (statsResult.isCacheable()) {
                writeCache(cacheKey, statsResult.response(), cacheTtlHours, memberUuid, null);
            }
            return statsResult.response();
        }

        // 결과 화면: 서버 문장은 항상 응답, LLM 실패면 캐시하지 않음 (#862)
        SessionCommentResult sessionResult = sessionCommentService.comment(memberUuid, sessionUuid);
        AiCommentResponse response = new AiCommentResponse(sessionResult.comment(), LocalDateTime.now());
        if (sessionResult.isCacheable()) {
            writeCache(cacheKey, response, cacheTtlHours, memberUuid, sessionUuid);
        }
        return response;
    }

    private AiCommentResponse readCache(String cacheKey, UUID memberUuid) {
        Object cached = redisTemplate.opsForValue().get(cacheKey);
        if (cached == null) {
            return null;
        }
        try {
            return objectMapper.readValue((String) cached, AiCommentResponse.class);
        } catch (JsonProcessingException e) {
            log.warn("AI comment cache deserialization failed for {}, regenerating", memberUuid, e);
            return null;
        }
    }

    /** 캐시 저장 (결과 화면 2시간, 통계 화면 24시간) */
    private void writeCache(String cacheKey, AiCommentResponse response, long cacheTtlHours, UUID memberUuid, UUID sessionUuid) {
        try {
            String json = objectMapper.writeValueAsString(response);
            redisTemplate.opsForValue().set(cacheKey, json, cacheTtlHours, TimeUnit.HOURS);
        } catch (JsonProcessingException e) {
            log.warn("Failed to cache AI comment for member={}, session={}", memberUuid, sessionUuid, e);
        }
    }

    /** 최근 7일 제출 수 (통계 캐시 갱신 구간 계산) */
    private long countRecentSubmissions(UUID memberUuid) {
        LocalDateTime since = LocalDateTime.now().minusDays(RECENT_ACTIVITY_DAYS);
        List<Object[]> rows = submissionRepository.findRecentActivityStats(memberUuid.toString(), since);
        // native query는 단일 집계행도 List<Object[]>로 반환되므로 첫 행을 꺼냄
        return rows.isEmpty() || rows.get(0)[0] == null ? 0L : ((Number) rows.get(0)[0]).longValue();
    }

    /**
     * 통계 코멘트 갱신 구간: 날짜 + 최근 풀이 수 10문제 단위
     * 예: 23문제 > "2026-10-27:guide-2" (예상 점수·다음 할 일 없는 #861 캐시 "analysis-" 와 겹치지 않게, #862)
     */
    static String toStatsRefreshBucket(LocalDate today, long recentCount) {
        return today.format(DATE_FORMAT) + ":guide-" + (recentCount / STATS_REFRESH_SOLVED_COUNT);
    }

    /**
     * AI 코멘트 캐시 무효화.
     * - sessionUuid 있음: 결과 화면 캐시(ai-comment:{memberUuid}:{sessionUuid}) 삭제
     * - sessionUuid 없음: 통계 화면 캐시(ai-comment:{memberUuid}:stats) 삭제
     */
    @Transactional
    public void evictCache(UUID memberUuid, UUID sessionUuid) {
        String cacheKey = sessionUuid != null
                ? CACHE_KEY_PREFIX + memberUuid + ":" + sessionUuid
                : CACHE_KEY_PREFIX + memberUuid + ":stats";
        redisTemplate.delete(cacheKey);
    }
}
