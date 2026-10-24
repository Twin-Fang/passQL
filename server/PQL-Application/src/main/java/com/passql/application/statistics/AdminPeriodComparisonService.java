package com.passql.application.statistics;

import com.passql.application.statistics.AdminStatisticsQueryRepository.SubmissionBucketRow;
import com.passql.application.statistics.dto.AiUsageTotal;
import com.passql.application.statistics.dto.PeriodComparisonResponse;
import com.passql.application.statistics.dto.PeriodComparisonResponse.MetricComparison;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 관리자 기간 비교: 가입, 방문, 제출, 정답률, AI 호출·실패·비용을 조회 기간과 직전 기간으로 나란히
 * 조회 기간 해석은 StatisticsPeriod 공통 (직전 기간 = 전주·전월 규칙)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminPeriodComparisonService {

    private final AdminStatisticsQueryRepository statisticsQueryRepository;
    private final AdminAiStatisticsService adminAiStatisticsService;

    /** 조회 기간·직전 기간 집계 > 지표별 비교 (7개) */
    public PeriodComparisonResponse compare(StatisticsPeriod period) {
        StatisticsPeriod previousPeriod = period.getPreviousPeriod();
        PeriodTotals current = collectTotals(period);
        PeriodTotals previous = collectTotals(previousPeriod);
        List<MetricComparison> metrics = List.of(
                toComparison("SIGNUPS", "신규 가입", "명", current.signupCount(), previous.signupCount()),
                toComparison("VISITORS", "방문자", "명", current.visitorCount(), previous.visitorCount()),
                toComparison("SUBMISSIONS", "제출", "건", current.submissionCount(), previous.submissionCount()),
                toComparison("CORRECT_RATE", "정답률", "%",
                        StatisticsNumbers.toPercent(current.correctCount(), current.submissionCount()),
                        StatisticsNumbers.toPercent(previous.correctCount(), previous.submissionCount())),
                toComparison("AI_CALLS", "AI 호출", "건", current.aiUsage().callCount(), previous.aiUsage().callCount()),
                toComparison("AI_FAILURES", "AI 실패", "건", current.aiUsage().failureCount(), previous.aiUsage().failureCount()),
                toComparison("AI_COST", "AI 추정 비용", "USD",
                        current.aiUsage().estimatedCostUsd(), previous.aiUsage().estimatedCostUsd()));
        return new PeriodComparisonResponse(period.fromDate(), period.toDate(),
                previousPeriod.fromDate(), previousPeriod.toDate(), metrics);
    }

    private PeriodTotals collectTotals(StatisticsPeriod period) {
        List<SubmissionBucketRow> submissionRows = statisticsQueryRepository
                .countSubmissionsByDay(period.getStartInclusive(), period.getEndExclusive());
        return new PeriodTotals(
                statisticsQueryRepository.countSignups(period.getStartInclusive(), period.getEndExclusive()),
                statisticsQueryRepository.countVisitors(period.getStartInclusive(), period.getEndExclusive()),
                submissionRows.stream().mapToLong(SubmissionBucketRow::submissionCount).sum(),
                submissionRows.stream().mapToLong(SubmissionBucketRow::correctCount).sum(),
                adminAiStatisticsService.summarizeUsage(period.getStartInclusive(), period.getEndExclusive()));
    }

    /** 현재·직전 값 > 증감률 (직전 0 이면 null) */
    static MetricComparison toComparison(String metricCode, String metricLabel, String unit,
                                         double currentValue, double previousValue) {
        Double changePercent = previousValue == 0
                ? null
                : StatisticsNumbers.roundToOneDecimal((currentValue - previousValue) / previousValue * 100);
        return new MetricComparison(metricCode, metricLabel, unit, currentValue, previousValue, changePercent);
    }

    /** 구간 합계 (정답률 계산용 정답 수 포함) */
    private record PeriodTotals(long signupCount, long visitorCount, long submissionCount, long correctCount,
                                AiUsageTotal aiUsage) {}
}
