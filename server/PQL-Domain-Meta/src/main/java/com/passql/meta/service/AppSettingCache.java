package com.passql.meta.service;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.Cursor;
import org.springframework.data.redis.core.ScanOptions;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

/**
 * app_setting Redis 캐시: 조회, 커밋 뒤 쓰기·삭제 (TTL 포함), 기동 시 전체 비우기
 * DB 가 원본, 캐시는 passql:settings:{settingKey} 에 저장값(비밀은 암호문) 그대로
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AppSettingCache {

    static final String REDIS_PREFIX = "passql:settings:";
    // 캐시 유효 시간: 마이그레이션·DB 직접 수정도 이 시간 안에 반영 (#879)
    static final Duration SETTING_CACHE_TTL = Duration.ofMinutes(10);
    // 전체 비우기 SCAN 한 번에 훑는 키 수
    private static final long SCAN_BATCH_SIZE = 200;

    private final StringRedisTemplate redisTemplate;

    /** 캐시 값 (없으면 null) */
    public String findOrNull(String settingKey) {
        return redisTemplate.opsForValue().get(REDIS_PREFIX + settingKey);
    }

    /** 캐시 쓰기, 트랜잭션 안이면 커밋 뒤 (롤백된 값이 캐시에만 남지 않게) */
    public void putAfterCommit(String settingKey, String storedValue) {
        runAfterCommit(() -> redisTemplate.opsForValue().set(REDIS_PREFIX + settingKey, storedValue, SETTING_CACHE_TTL));
    }

    /** 캐시 삭제, 트랜잭션 안이면 커밋 뒤 */
    public void evictAfterCommit(String settingKey) {
        runAfterCommit(() -> redisTemplate.delete(REDIS_PREFIX + settingKey));
    }

    /**
     * 기동 시 설정 캐시 전체 비우기: 이번 배포 마이그레이션이 바꾼 값을 TTL 전에도 바로 반영
     * 설정을 읽는 빈(SandboxPool 등)보다 먼저 실행 (이 빈에 의존), Redis 실패는 기동을 막지 않음 (TTL 로 반영)
     */
    @PostConstruct
    void evictAllOnStartup() {
        try {
            evictAll();
        } catch (RuntimeException e) {
            log.warn("[app-setting cache] startup eviction skipped : cause={}", e.getClass().getSimpleName(), e);
        }
    }

    /** 설정 캐시 전체 삭제 (SCAN 으로 설정 키만, 다른 키 영역은 건드리지 않음) */
    public void evictAll() {
        ScanOptions scanOptions = ScanOptions.scanOptions().match(REDIS_PREFIX + "*").count(SCAN_BATCH_SIZE).build();
        List<String> cachedKeys = new ArrayList<>();
        try (Cursor<String> cursor = redisTemplate.scan(scanOptions)) {
            cursor.forEachRemaining(cachedKeys::add);
        }
        if (!cachedKeys.isEmpty()) {
            redisTemplate.delete(cachedKeys);
        }
        log.info("[app-setting cache] evicted all : count={}", cachedKeys.size());
    }

    /** 트랜잭션 동기화 중이면 커밋 뒤 실행, 아니면 바로 실행 */
    private static void runAfterCommit(Runnable action) {
        if (!TransactionSynchronizationManager.isSynchronizationActive()) {
            action.run();
            return;
        }
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                action.run();
            }
        });
    }
}
