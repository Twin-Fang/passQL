package com.passql.submission.service;

import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.ExpectedPassSubjectAverage;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;

/**
 * 예상 합격률 (#1086): 최근 5회 중 합격 비율, 과목 평균이 과락 기준 + 4점 이하면 위험, 0회면 null
 */
class ExpectedPassCalculatorTest {

    @Test
    void 최근_5회만_보고_합격_비율과_과락_위험_과목을_낸다() {
        // 최신 순 6회: 6번째(가장 오래된 합격)는 계산에서 빠짐
        List<ExpectedPassCalculator.GradedAttempt> recentAttempts = List.of(
            attempt(70, 12, 58, true),
            attempt(64, 10, 54, true),
            attempt(56, 14, 42, false),
            attempt(50, 6, 44, false),
            attempt(62, 12, 50, true),
            attempt(90, 20, 70, true));

        ExpectedPassCalculator.Estimate estimate = ExpectedPassCalculator.estimate(recentAttempts);

        assertThat(estimate.basisAttemptCount()).isEqualTo(5);
        assertThat(estimate.passedAttemptCount()).isEqualTo(3);
        assertThat(estimate.expectedPassPercent()).isEqualTo(60);
        assertThat(estimate.averageScore()).isEqualTo(60.4);
        // 1과목 평균 10.8 <= 과락 기준 8 + 4 > 위험, 2과목 평균 49.6 > 32 + 4 > 안전
        assertThat(estimate.subjectAverages())
            .extracting(ExpectedPassSubjectAverage::subject, ExpectedPassSubjectAverage::averageScore,
                ExpectedPassSubjectAverage::isFailRisk)
            .containsExactly(
                tuple(MockExamSubject.SUBJECT_ONE, 10.8, true),
                tuple(MockExamSubject.SUBJECT_TWO, 49.6, false));
    }

    @Test
    void 응시가_없으면_비율과_평균은_null() {
        ExpectedPassCalculator.Estimate estimate = ExpectedPassCalculator.estimate(List.of());

        assertThat(estimate.expectedPassPercent()).isNull();
        assertThat(estimate.averageScore()).isNull();
        assertThat(estimate.basisAttemptCount()).isZero();
        assertThat(estimate.subjectAverages()).isEmpty();
    }

    private static ExpectedPassCalculator.GradedAttempt attempt(int totalScore, int subjectOneScore,
                                                                int subjectTwoScore, boolean isPassed) {
        return new ExpectedPassCalculator.GradedAttempt(totalScore, subjectOneScore, subjectTwoScore, isPassed);
    }
}
