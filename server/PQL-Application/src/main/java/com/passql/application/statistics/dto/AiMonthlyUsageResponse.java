package com.passql.application.statistics.dto;

import com.passql.ai.dto.AiModelPrice;

import java.util.List;

/** AI 월 사용량 (month: yyyy-MM): 합계, 모델별, 출처·경로별, 단가표 */
public record AiMonthlyUsageResponse(
        String month,
        long totalCallCount,
        long totalFailureCount,
        long totalPromptTokenCount,
        long totalCompletionTokenCount,
        double totalEstimatedCostUsd,
        double monthlyBudgetUsd,
        List<AiModelUsageSummary> byModel,
        List<EndpointUsage> byEndpoint,
        List<AiModelPrice> priceTable
) {

    /** 출처·경로 1개 사용량 (callSource: AI_SERVER | GEMINI_DIRECT) */
    public record EndpointUsage(
            String callSource,
            String endpointPath,
            long callCount,
            long failureCount,
            long averageLatencyMilliseconds,
            long promptTokenCount,
            long completionTokenCount,
            double estimatedCostUsd
    ) {}
}
