package com.passql.application.statistics;

import com.passql.application.statistics.AdminStatisticsQueryRepository.SubmissionBucketRow;
import com.passql.application.statistics.dto.AiUsageTotal;
import com.passql.application.statistics.dto.PeriodComparisonResponse;
import com.passql.application.statistics.dto.PeriodComparisonResponse.MetricComparison;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** 기간 비교: 조회 기간·직전 기간 값 나란히, 증감률 계산(직전 0 이면 null) */
class AdminPeriodComparisonServiceTest {

    private final AdminStatisticsQueryRepository statisticsQueryRepository = mock(AdminStatisticsQueryRepository.class);
    private final AdminAiStatisticsService adminAiStatisticsService = mock(AdminAiStatisticsService.class);
    private final AdminPeriodComparisonService service =
            new AdminPeriodComparisonService(statisticsQueryRepository, adminAiStatisticsService);

    @Test
    void 조회_기간과_직전_기간_가입을_비교한다() {
        StatisticsPeriod period = new StatisticsPeriod(LocalDate.of(2026, 10, 12), LocalDate.of(2026, 10, 18));
        StatisticsPeriod previousPeriod = period.getPreviousPeriod();
        when(statisticsQueryRepository.countSignups(period.getStartInclusive(), period.getEndExclusive())).thenReturn(15L);
        when(statisticsQueryRepository.countSignups(previousPeriod.getStartInclusive(), previousPeriod.getEndExclusive())).thenReturn(10L);
        when(statisticsQueryRepository.countSubmissionsByDay(any(), any())).thenReturn(List.of(
                new SubmissionBucketRow(LocalDate.of(2026, 10, 12), 10, 7)));
        when(adminAiStatisticsService.summarizeUsage(any(), any())).thenReturn(new AiUsageTotal(0, 0, 0));

        PeriodComparisonResponse comparison = service.compare(period);

        MetricComparison signups = findMetric(comparison, "SIGNUPS");
        assertThat(signups.currentValue()).isEqualTo(15);
        assertThat(signups.previousValue()).isEqualTo(10);
        assertThat(signups.changePercent()).isEqualTo(50.0);
        assertThat(comparison.previousFromDate()).isEqualTo(LocalDate.of(2026, 10, 5));
        assertThat(findMetric(comparison, "CORRECT_RATE").currentValue()).isEqualTo(70.0);
    }

    @Test
    void 직전_값이_0이면_증감률은_null이다() {
        assertThat(AdminPeriodComparisonService.toComparison("X", "x", "건", 5, 0).changePercent()).isNull();
        assertThat(AdminPeriodComparisonService.toComparison("X", "x", "건", 5, 10).changePercent()).isEqualTo(-50.0);
    }

    private static MetricComparison findMetric(PeriodComparisonResponse comparison, String metricCode) {
        return comparison.metrics().stream().filter(metric -> metric.metricCode().equals(metricCode)).findFirst().orElseThrow();
    }
}
