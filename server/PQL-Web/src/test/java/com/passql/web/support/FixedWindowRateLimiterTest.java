package com.passql.web.support;

import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;

import static org.assertj.core.api.Assertions.assertThat;

/** 고정 창 요청 제한 (#478): 한도까지 허용, 초과 거부, 다음 창에서 다시 허용, 키별 독립 */
class FixedWindowRateLimiterTest {

    @Test
    void 한도를_넘으면_거부하고_다음_창에서_다시_허용한다() {
        MutableClock clock = new MutableClock(Instant.parse("2026-10-15T00:00:00Z"));
        FixedWindowRateLimiter rateLimiter = new FixedWindowRateLimiter(Duration.ofSeconds(60), clock);

        assertThat(rateLimiter.tryAcquire("LOGIN:ip:1.1.1.1", 2, 60)).isTrue();
        assertThat(rateLimiter.tryAcquire("LOGIN:ip:1.1.1.1", 2, 60)).isTrue();
        assertThat(rateLimiter.tryAcquire("LOGIN:ip:1.1.1.1", 2, 60)).isFalse();
        assertThat(rateLimiter.tryAcquire("LOGIN:ip:2.2.2.2", 2, 60)).isTrue();

        clock.advance(Duration.ofSeconds(60));
        assertThat(rateLimiter.tryAcquire("LOGIN:ip:1.1.1.1", 2, 60)).isTrue();
    }

    /** 테스트용 이동 가능한 시계 */
    private static final class MutableClock extends Clock {
        private Instant now;

        private MutableClock(Instant now) {
            this.now = now;
        }

        void advance(Duration duration) {
            now = now.plus(duration);
        }

        @Override
        public ZoneOffset getZone() {
            return ZoneOffset.UTC;
        }

        @Override
        public Clock withZone(java.time.ZoneId zone) {
            return this;
        }

        @Override
        public Instant instant() {
            return now;
        }
    }
}
