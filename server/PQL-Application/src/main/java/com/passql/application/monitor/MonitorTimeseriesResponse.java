package com.passql.application.monitor;

import java.util.List;

/**
 * 모니터링 시간대별 시계열 (labels 와 같은 순서, 빈 시간 0)
 * AI·SQL: 호출 수, 실패율(%), 평균 지연(ms), 서버 오류: 건수
 */
public record MonitorTimeseriesResponse(
        List<String> labels,
        List<Long> aiCallCounts,
        List<Double> aiFailureRatePercents,
        List<Long> aiAverageLatencyMilliseconds,
        List<Long> serverErrorCounts,
        List<Long> sqlExecutionCounts,
        List<Double> sqlFailureRatePercents,
        List<Long> sqlAverageElapsedMilliseconds
) {}
