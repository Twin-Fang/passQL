package com.passql.application.statistics.dto;

import java.util.List;

/** AI 호출량 추이 (일 30 / 월 12): 성공·실패·평균 지연(ms)·추정 비용(USD, 단가 미등록 모델은 0) */
public record DashboardAiUsageResponse(
        List<String> labels,
        List<Long> successCounts,
        List<Long> failureCounts,
        List<Long> averageLatencyMilliseconds,
        List<Double> estimatedCostUsd
) {}
