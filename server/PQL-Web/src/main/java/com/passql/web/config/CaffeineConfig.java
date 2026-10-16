package com.passql.web.config;

import com.github.benmanes.caffeine.cache.Caffeine;
import com.passql.application.notification.UnreadNotificationCountCache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.TimeUnit;

/** 기본 캐시 5초 + 안 읽은 알림 개수 캐시 회원별 30초 (알림함, #491) */
@Configuration
@EnableCaching
public class CaffeineConfig {

    // 안 읽은 알림 개수 캐시: 최대 회원 수, 유지 시간(초)
    private static final int UNREAD_COUNT_CACHE_MAX_SIZE = 50_000;
    private static final int UNREAD_COUNT_CACHE_SECONDS = 30;

    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager cacheManager = new CaffeineCacheManager();
        cacheManager.setCaffeine(
            Caffeine.newBuilder()
                .maximumSize(500)
                .expireAfterWrite(5, TimeUnit.SECONDS)
        );
        cacheManager.registerCustomCache(UnreadNotificationCountCache.CACHE_NAME, Caffeine.newBuilder()
                .maximumSize(UNREAD_COUNT_CACHE_MAX_SIZE)
                .expireAfterWrite(UNREAD_COUNT_CACHE_SECONDS, TimeUnit.SECONDS)
                .build());
        return cacheManager;
    }
}
