package com.passql.application.statistics.dto;

import java.time.LocalDate;
import java.util.List;

/**
 * 기간 비교(조회 기간 vs 직전 기간): 지표별 현재·직전 값과 증감률
 * changePercent: (현재 - 직전) / 직전 x 100, 직전 0 이면 null
 */
public record PeriodComparisonResponse(
        LocalDate fromDate,
        LocalDate toDate,
        LocalDate previousFromDate,
        LocalDate previousToDate,
        List<MetricComparison> metrics
) {

    /** 지표 1개 (metricLabel 화면·CSV 표시 이름, unit 값 단위 표시) */
    public record MetricComparison(
            String metricCode,
            String metricLabel,
            String unit,
            double currentValue,
            double previousValue,
            Double changePercent
    ) {}
}
