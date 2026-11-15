package com.passql.submission.service;

import com.passql.meta.dto.SqldExamGuideResponse.YearlyStatistic;
import com.passql.meta.service.SqldExamGuideService;
import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.dto.ExpectedPassResponse;
import com.passql.submission.entity.MockExamAttempt;
import com.passql.submission.repository.MockExamAttemptRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * 예상 합격률 (#1086): 최근 채점 응시 최대 5회 (회차 무관, 제출 최신 순) > 계산 > 공식 최근 연도 합격률 붙임
 * 등급 제한 없음 (무료 체험 1회도 반영)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExpectedPassService {

    private final MockExamAttemptRepository attemptRepository;
    private final SqldExamGuideService sqldExamGuideService;

    public ExpectedPassResponse getExpectedPass(UUID memberUuid) {
        // 최근 채점 응시 (총점 없는 행 제외)
        List<ExpectedPassCalculator.GradedAttempt> recentAttempts = attemptRepository
            .findByMemberUuidAndStatusOrderBySubmittedAtDesc(memberUuid, MockExamAttemptStatus.SUBMITTED,
                PageRequest.of(0, ExpectedPassCalculator.BASIS_ATTEMPT_LIMIT))
            .stream()
            .filter(attempt -> attempt.getTotalScore() != null)
            .map(ExpectedPassService::toGradedAttempt)
            .toList();
        ExpectedPassCalculator.Estimate estimate = ExpectedPassCalculator.estimate(recentAttempts);

        // 공식 최근 연도 통계 (연도 오름차순 마지막)
        List<YearlyStatistic> yearlyStatistics = sqldExamGuideService.getSqldExamGuide().yearlyStatistics();
        YearlyStatistic latestStatistic = yearlyStatistics.isEmpty() ? null : yearlyStatistics.get(yearlyStatistics.size() - 1);

        return new ExpectedPassResponse(estimate.expectedPassPercent(), estimate.averageScore(),
            estimate.basisAttemptCount(), estimate.passedAttemptCount(), MockExamRule.PASS_SCORE,
            estimate.subjectAverages(),
            latestStatistic == null ? null : latestStatistic.passRatePercent(),
            latestStatistic == null ? null : latestStatistic.year());
    }

    // 응시 행 > 계산 입력 (과목 점수 = 정답 수 × 배점)
    private static ExpectedPassCalculator.GradedAttempt toGradedAttempt(MockExamAttempt attempt) {
        return new ExpectedPassCalculator.GradedAttempt(attempt.getTotalScore(),
            scoreOf(attempt.getSubjectOneCorrectCount()), scoreOf(attempt.getSubjectTwoCorrectCount()),
            Boolean.TRUE.equals(attempt.getIsPassed()));
    }

    private static int scoreOf(Integer correctCount) {
        return correctCount == null ? 0 : correctCount * MockExamRule.POINTS_PER_QUESTION;
    }
}
