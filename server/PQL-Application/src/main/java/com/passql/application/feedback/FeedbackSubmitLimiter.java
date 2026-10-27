package com.passql.application.feedback;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
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
 * 의견 전송 제한 (Redis): 회원당 하루 10건 (Asia/Seoul 날짜 기준)
 * 키: feedback:rate:day:{member}:{yyyy-MM-dd}, Redis 장애 시 전송은 막지 않음 (경고 로그)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class FeedbackSubmitLimiter {

    // 하루 전송 한도
    static final int MAX_SUBMITS_PER_DAY = 10;
    private static final Duration DAY_WINDOW = Duration.ofDays(1);
    private static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Seoul");

    private final StringRedisTemplate stringRedisTemplate;

    /** 전송 시도 1회 기록 > 하루 한도 초과면 429 FEEDBACK_DAILY_LIMIT_EXCEEDED */
    public void acquireSubmitPermit(UUID memberUuid) {
        try {
            String dayKey = "feedback:rate:day:" + memberUuid + ":" + LocalDate.now(SERVICE_ZONE);
            Long count = stringRedisTemplate.opsForValue().increment(dayKey);
            if (count != null && count == 1L) {
                stringRedisTemplate.expire(dayKey, DAY_WINDOW);
            }
            if (count != null && count > MAX_SUBMITS_PER_DAY) {
                log.warn("[feedback submit] rejected 429 : daily limit, member={}", memberUuid);
                throw new CustomException(ErrorCode.FEEDBACK_DAILY_LIMIT_EXCEEDED);
            }
        } catch (DataAccessException e) {
            log.warn("[feedback submit] limiter skipped : redis unavailable, cause={}", e.getClass().getSimpleName());
        }
    }
}
