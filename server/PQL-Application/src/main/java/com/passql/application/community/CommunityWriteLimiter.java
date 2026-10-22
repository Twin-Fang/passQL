package com.passql.application.community;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.Sha256Hex;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.UUID;

/**
 * 글 작성 제한 (Redis): 회원당 분당 5건, 하루 100건, 같은 내용 5분 안 반복 차단, 이미지 업로드 분당 5장·하루 20장
 * 키: community:rate:min:{member}, community:rate:day:{member}:{yyyy-MM-dd}, community:dup:{member},
 *     community:img:min:{member}, community:img:day:{member}:{yyyy-MM-dd}
 * Redis 장애 시 작성은 막지 않음 (경고 로그)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class CommunityWriteLimiter {

    // 분당 작성 한도 / 하루 작성 한도
    static final int MAX_POSTS_PER_MINUTE = 5;
    static final int MAX_POSTS_PER_DAY = 100;
    // 이미지 업로드 분당 한도 / 하루 한도
    static final int MAX_IMAGE_UPLOADS_PER_MINUTE = 5;
    static final int MAX_IMAGE_UPLOADS_PER_DAY = 20;
    private static final Duration MINUTE_WINDOW = Duration.ofMinutes(1);
    private static final Duration DAY_WINDOW = Duration.ofDays(1);
    // 같은 내용 반복 차단 시간
    private static final Duration DUPLICATE_WINDOW = Duration.ofMinutes(5);
    private static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Seoul");

    private final StringRedisTemplate stringRedisTemplate;

    /** 작성 시도 1회 기록 > 한도 초과면 429 (분당 COMMUNITY_POST_RATE_LIMITED, 하루 COMMUNITY_POST_DAILY_LIMIT_EXCEEDED) */
    public void acquireWritePermit(UUID memberUuid) {
        try {
            long minuteCount = increase("community:rate:min:" + memberUuid, MINUTE_WINDOW);
            if (minuteCount > MAX_POSTS_PER_MINUTE) {
                log.warn("[community] rejected 429 : per-minute limit, member={}", memberUuid);
                throw new CustomException(ErrorCode.COMMUNITY_POST_RATE_LIMITED);
            }
            long dayCount = increase("community:rate:day:" + memberUuid + ":" + LocalDate.now(SERVICE_ZONE), DAY_WINDOW);
            if (dayCount > MAX_POSTS_PER_DAY) {
                log.warn("[community] rejected 429 : daily limit, member={}", memberUuid);
                throw new CustomException(ErrorCode.COMMUNITY_POST_DAILY_LIMIT_EXCEEDED);
            }
        } catch (DataAccessException e) {
            log.warn("[community] write limiter skipped : redis unavailable, cause={}", e.getClass().getSimpleName());
        }
    }

    /** 업로드 시도 1회 기록 > 한도 초과면 429 (분당 COMMUNITY_IMAGE_UPLOAD_RATE_LIMITED, 하루 COMMUNITY_IMAGE_DAILY_LIMIT_EXCEEDED) */
    public void acquireImageUploadPermit(UUID memberUuid) {
        try {
            long minuteCount = increase("community:img:min:" + memberUuid, MINUTE_WINDOW);
            if (minuteCount > MAX_IMAGE_UPLOADS_PER_MINUTE) {
                log.warn("[community image] rejected 429 : per-minute limit, member={}", memberUuid);
                throw new CustomException(ErrorCode.COMMUNITY_IMAGE_UPLOAD_RATE_LIMITED);
            }
            long dayCount = increase("community:img:day:" + memberUuid + ":" + LocalDate.now(SERVICE_ZONE), DAY_WINDOW);
            if (dayCount > MAX_IMAGE_UPLOADS_PER_DAY) {
                log.warn("[community image] rejected 429 : daily limit, member={}", memberUuid);
                throw new CustomException(ErrorCode.COMMUNITY_IMAGE_DAILY_LIMIT_EXCEEDED);
            }
        } catch (DataAccessException e) {
            log.warn("[community image] upload limiter skipped : redis unavailable, cause={}", e.getClass().getSimpleName());
        }
    }

    /** 직전 5분 안에 같은 내용을 썼으면 COMMUNITY_POST_DUPLICATE */
    public void assertNotRecentDuplicate(UUID memberUuid, String content) {
        try {
            String recentHash = stringRedisTemplate.opsForValue().get(duplicateKeyOf(memberUuid));
            if (Sha256Hex.of(content).equals(recentHash)) {
                log.warn("[community] rejected 409 : duplicate content, member={}", memberUuid);
                throw new CustomException(ErrorCode.COMMUNITY_POST_DUPLICATE);
            }
        } catch (DataAccessException e) {
            log.warn("[community] duplicate check skipped : redis unavailable, cause={}", e.getClass().getSimpleName());
        }
    }

    /** 작성 성공 후 내용 해시 기록 (5분) */
    public void recordWrittenContent(UUID memberUuid, String content) {
        try {
            stringRedisTemplate.opsForValue().set(duplicateKeyOf(memberUuid), Sha256Hex.of(content), DUPLICATE_WINDOW);
        } catch (DataAccessException e) {
            log.warn("[community] duplicate record skipped : redis unavailable, cause={}", e.getClass().getSimpleName());
        }
    }

    /** 카운터 1 증가, 처음이면 만료 설정 */
    private long increase(String key, Duration window) {
        Long count = stringRedisTemplate.opsForValue().increment(key);
        if (count != null && count == 1L) {
            stringRedisTemplate.expire(key, window);
        }
        return count == null ? 0L : count;
    }

    private static String duplicateKeyOf(UUID memberUuid) {
        return "community:dup:" + memberUuid;
    }
}
