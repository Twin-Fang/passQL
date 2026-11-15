package com.passql.submission.service;

import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.ExpectedPassSubjectAverage;

import java.util.Arrays;
import java.util.List;
import java.util.function.ToIntFunction;

/**
 * 예상 합격률 계산 (#1086, 순수 판정): 최근 응시 목록 > 합격 비율·평균 총점·과목 평균·과락 위험
 * 합격 여부는 채점 시점 결과(isPassed) 그대로, 응시 0회면 비율·평균 null
 */
public final class ExpectedPassCalculator {

    // 계산에 쓰는 최근 응시 수 (최대)
    public static final int BASIS_ATTEMPT_LIMIT = 5;
    // 과락 위험 여유 (점): 과목 평균이 과락 기준 + 이 값 이하면 위험
    static final int FAIL_RISK_MARGIN_SCORE = 4;

    private ExpectedPassCalculator() {
    }

    /** 채점된 응시 1회: 총점·과목 점수(점)·합격 여부 */
    public record GradedAttempt(int totalScore, int subjectOneScore, int subjectTwoScore, boolean isPassed) {

        int scoreOf(MockExamSubject subject) {
            return subject == MockExamSubject.SUBJECT_ONE ? subjectOneScore : subjectTwoScore;
        }
    }

    /** 계산 결과 (응시 0회면 expectedPassPercent·averageScore null, subjectAverages 빈 목록) */
    public record Estimate(Integer expectedPassPercent, Double averageScore, int basisAttemptCount,
                           int passedAttemptCount, List<ExpectedPassSubjectAverage> subjectAverages) {
    }

    /** 최근 응시 (최신 순, 최대 5회만 사용) > 예상 합격률 */
    public static Estimate estimate(List<GradedAttempt> recentAttempts) {
        List<GradedAttempt> basisAttempts = recentAttempts.stream().limit(BASIS_ATTEMPT_LIMIT).toList();
        if (basisAttempts.isEmpty()) {
            return new Estimate(null, null, 0, 0, List.of());
        }
        int passedAttemptCount = (int) basisAttempts.stream().filter(GradedAttempt::isPassed).count();
        int expectedPassPercent = (int) Math.round(passedAttemptCount * 100.0 / basisAttempts.size());
        double averageScore = averageOf(basisAttempts, GradedAttempt::totalScore);
        List<ExpectedPassSubjectAverage> subjectAverages = Arrays.stream(MockExamSubject.values())
            .map(subject -> toSubjectAverage(subject, averageOf(basisAttempts, attempt -> attempt.scoreOf(subject))))
            .toList();
        return new Estimate(expectedPassPercent, averageScore, basisAttempts.size(), passedAttemptCount, subjectAverages);
    }

    private static ExpectedPassSubjectAverage toSubjectAverage(MockExamSubject subject, double averageScore) {
        int failBelowScore = MockExamRule.failBelowScoreOf(subject);
        boolean isFailRisk = averageScore <= failBelowScore + FAIL_RISK_MARGIN_SCORE;
        return new ExpectedPassSubjectAverage(subject, subject.getDisplayName(), averageScore,
            MockExamRule.maxScoreOf(subject), failBelowScore, isFailRisk);
    }

    // 평균 (소수 1자리 반올림)
    private static double averageOf(List<GradedAttempt> attempts, ToIntFunction<GradedAttempt> scoreOf) {
        double average = attempts.stream().mapToInt(scoreOf).average().orElse(0);
        return Math.round(average * 10.0) / 10.0;
    }
}
