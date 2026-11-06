package com.passql.submission.service;

import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 모의고사 시간 판정 (#866): 마감 도달 = 시간 끝, 답은 마감 + 15초까지 받음, 푼 시간 상한 90분
 */
class MockExamTimerTest {

    private static final LocalDateTime STARTED_AT = LocalDateTime.of(2026, 11, 7, 10, 0);
    private static final LocalDateTime DEADLINE_AT = STARTED_AT.plus(MockExamRule.DURATION);

    @Test
    void 마감_전에는_남은_초를_주고_시간_끝이_아님() {
        LocalDateTime now = DEADLINE_AT.minusMinutes(10);

        assertThat(MockExamTimer.remainingSeconds(DEADLINE_AT, now)).isEqualTo(600);
        assertThat(MockExamTimer.isTimeUp(DEADLINE_AT, now)).isFalse();
    }

    @Test
    void 마감_시각이면_시간_끝이고_남은_초는_0() {
        assertThat(MockExamTimer.isTimeUp(DEADLINE_AT, DEADLINE_AT)).isTrue();
        assertThat(MockExamTimer.remainingSeconds(DEADLINE_AT, DEADLINE_AT.plusMinutes(5))).isZero();
    }

    @Test
    void 유예_15초_안의_답은_받고_넘으면_막음() {
        assertThat(MockExamTimer.isAnswerWindowClosed(DEADLINE_AT, DEADLINE_AT.plusSeconds(15))).isFalse();
        assertThat(MockExamTimer.isAnswerWindowClosed(DEADLINE_AT, DEADLINE_AT.plusSeconds(16))).isTrue();
    }

    @Test
    void 늦게_채점돼도_푼_시간은_90분을_넘지_않음() {
        assertThat(MockExamTimer.elapsedSeconds(STARTED_AT, DEADLINE_AT.plusHours(3)))
            .isEqualTo(MockExamRule.DURATION.getSeconds());
    }
}
