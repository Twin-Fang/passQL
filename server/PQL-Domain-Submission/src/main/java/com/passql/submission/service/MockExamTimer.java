package com.passql.submission.service;

import java.time.Duration;
import java.time.LocalDateTime;

/**
 * 응시 시간 판정 (순수): 남은 초, 시간 끝, 답 받기 마감(마감 + 유예)
 */
public final class MockExamTimer {

    private MockExamTimer() {
    }

    /** 마감까지 남은 시간 (초, 0 이상) */
    public static long remainingSeconds(LocalDateTime deadlineAt, LocalDateTime now) {
        return Math.max(0, Duration.between(now, deadlineAt).getSeconds());
    }

    /** 시간 끝 (마감 시각 도달) */
    public static boolean isTimeUp(LocalDateTime deadlineAt, LocalDateTime now) {
        return !now.isBefore(deadlineAt);
    }

    /** 답 받기 마감 지남 (마감 + 유예 초과, 그 뒤 도착한 답은 반영하지 않음) */
    public static boolean isAnswerWindowClosed(LocalDateTime deadlineAt, LocalDateTime now) {
        return now.isAfter(deadlineAt.plus(MockExamRule.SUBMIT_GRACE));
    }

    /** 푼 시간 (초): 시작 ~ 제출, 시험 시간 상한 */
    public static long elapsedSeconds(LocalDateTime startedAt, LocalDateTime submittedAt) {
        long elapsed = Math.max(0, Duration.between(startedAt, submittedAt).getSeconds());
        return Math.min(elapsed, MockExamRule.DURATION.getSeconds());
    }
}
