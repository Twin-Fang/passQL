package com.passql.web.support;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;

import java.time.Clock;
import java.time.Duration;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 고정 창 요청 수 제한 (인메모리, 서버 1대 기준): 키·창 번호별 카운터 > 한도 초과면 거부
 * 카운터는 최대 창 길이 2배 뒤 자동 만료
 */
public class FixedWindowRateLimiter {

    // 동시에 추적할 최대 키 수 (초과 시 오래된 키부터 제거)
    private static final long MAXIMUM_TRACKED_KEYS = 100_000;

    private final Cache<String, AtomicInteger> requestCountByWindowKey;
    private final Clock clock;

    public FixedWindowRateLimiter(Duration longestWindow, Clock clock) {
        this.clock = clock;
        this.requestCountByWindowKey = Caffeine.newBuilder()
                .maximumSize(MAXIMUM_TRACKED_KEYS)
                .expireAfterWrite(longestWindow.multipliedBy(2))
                .build();
    }

    /** 요청 1건 기록 > 한도 안이면 true */
    public boolean tryAcquire(String key, int maxRequestsPerWindow, int windowSeconds) {
        long windowIndex = clock.millis() / (windowSeconds * 1000L);
        AtomicInteger requestCount = requestCountByWindowKey.get(key + ":" + windowIndex, ignored -> new AtomicInteger());
        return requestCount.incrementAndGet() <= maxRequestsPerWindow;
    }
}
