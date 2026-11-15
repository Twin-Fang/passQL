package com.passql.submission.service;

import com.passql.submission.dto.QuestionFirstAttemptStat;

import java.util.Comparator;
import java.util.List;

/**
 * 오답률 순위 (#1080): 첫 제출 회원 수 기준 미달 제외 > 오답률 내림차순 > 상위 N개
 * 오답률 = 첫 제출 오답 회원 수 / 첫 제출 회원 수, 같으면 응시 많은 순
 */
public final class HardestQuestionRanker {

    // 오답률 같을 때: 첫 제출 회원 많은 순 > 문제 uuid (순서 고정)
    private static final Comparator<QuestionFirstAttemptStat> HARDEST_ORDER =
        Comparator.comparingDouble(HardestQuestionRanker::wrongRateOf).reversed()
            .thenComparing(Comparator.comparingInt(QuestionFirstAttemptStat::attemptCount).reversed())
            .thenComparing(QuestionFirstAttemptStat::questionUuid);

    private HardestQuestionRanker() {
    }

    /** 집계 > 순위 목록 (첫 제출 회원 minimumAttemptCount 명 미만 제외, 최대 limit 개) */
    public static List<QuestionFirstAttemptStat> rank(
        List<QuestionFirstAttemptStat> stats, int minimumAttemptCount, int limit
    ) {
        return stats.stream()
            .filter(stat -> stat.attemptCount() >= minimumAttemptCount)
            .sorted(HARDEST_ORDER)
            .limit(limit)
            .toList();
    }

    /** 오답률 (%, 소수 1자리 반올림) */
    public static double toWrongRatePercent(QuestionFirstAttemptStat stat) {
        return Math.round(wrongRateOf(stat) * 1000.0) / 10.0;
    }

    // 0.0 ~ 1.0 (응시 0명 > 0)
    private static double wrongRateOf(QuestionFirstAttemptStat stat) {
        return stat.attemptCount() == 0 ? 0.0 : (double) stat.wrongCount() / stat.attemptCount();
    }
}
