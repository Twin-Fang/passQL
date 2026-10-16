package com.passql.application.notification;

import com.passql.member.dto.UnreadNotificationCountResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Component;

import java.util.UUID;
import java.util.function.Supplier;

/**
 * 안 읽은 개수 캐시: 회원별 30초 (만료 설정은 CaffeineConfig)
 * 알림 생성·읽음·회수 때 해당 회원 삭제, 전체 발송·회수는 전체 삭제
 */
@Component
@RequiredArgsConstructor
public class UnreadNotificationCountCache {

    // CaffeineConfig 에 등록하는 캐시 이름
    public static final String CACHE_NAME = "notificationUnreadCount";

    private final CacheManager cacheManager;

    public UnreadNotificationCountResponse getOrLoad(UUID memberUuid, Supplier<UnreadNotificationCountResponse> loader) {
        return cache().get(memberUuid, loader::get);
    }

    public void evict(UUID memberUuid) {
        cache().evict(memberUuid);
    }

    public void evictAll() {
        cache().clear();
    }

    private Cache cache() {
        return cacheManager.getCache(CACHE_NAME);
    }
}
