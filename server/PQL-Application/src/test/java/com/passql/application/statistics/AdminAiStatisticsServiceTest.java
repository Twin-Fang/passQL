package com.passql.application.statistics;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.client.GeminiClient;
import com.passql.ai.service.AiCostCalculator;
import com.passql.application.service.SystemHealthService;
import com.passql.application.statistics.AdminAiStatisticsQueryRepository.AiUsageGroupRow;
import com.passql.application.statistics.AdminAiStatisticsQueryRepository.ErrorTypeCountRow;
import com.passql.application.statistics.dto.AiModelUsageSummary;
import com.passql.application.statistics.dto.AiMonthlyUsageResponse;
import com.passql.application.statistics.dto.DashboardAiStatusResponse.AiFailureBreakdown;
import org.junit.jupiter.api.Test;

import java.time.YearMonth;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** AI 월 사용량 비용 합산: 모델별 단가 × 토큰, 단가 미등록·모델 미기록은 0 */
class AdminAiStatisticsServiceTest {

    private final AdminAiStatisticsQueryRepository aiStatisticsQueryRepository = mock(AdminAiStatisticsQueryRepository.class);
    private final AiCostCalculator aiCostCalculator = mock(AiCostCalculator.class);
    private final AdminAiStatisticsService adminAiStatisticsService = new AdminAiStatisticsService(
            aiStatisticsQueryRepository, aiCostCalculator, mock(SystemHealthService.class), mock(GeminiClient.class));

    @Test
    void 월_사용량은_모델별_비용을_합산하고_단가_미등록은_0이다() throws Exception {
        when(aiStatisticsQueryRepository.sumUsageBySourceEndpointAndModel(any(), any())).thenReturn(List.of(
                new AiUsageGroupRow("GEMINI_DIRECT", "gemini:chat", "gemini-2.5-flash-lite", 10, 1, 5_000, 1_000_000, 500_000),
                new AiUsageGroupRow("AI_SERVER", "/api/ai/generate-choice-set", "gemini-2.5-flash-lite", 5, 0, 2_000, 1_000_000, 0),
                new AiUsageGroupRow("AI_SERVER", "/api/ai/generate-choice-set", "unknown-model", 2, 2, 400, 300, 300),
                new AiUsageGroupRow("AI_SERVER", "/api/ai/embed", null, 1, 0, 100, 0, 0)));
        when(aiCostCalculator.estimateCostUsd("gemini-2.5-flash-lite", 1_000_000, 500_000)).thenReturn(0.30);
        when(aiCostCalculator.estimateCostUsd("gemini-2.5-flash-lite", 1_000_000, 0)).thenReturn(0.10);
        when(aiCostCalculator.estimateCostUsd("gemini-2.5-flash-lite", 2_000_000, 500_000)).thenReturn(0.40);
        when(aiCostCalculator.isPriceRegistered("gemini-2.5-flash-lite")).thenReturn(true);
        when(aiCostCalculator.getMonthlyBudgetUsd()).thenReturn(10.0);

        AiMonthlyUsageResponse usage = adminAiStatisticsService.getAiMonthlyUsage(YearMonth.of(2026, 10));

        assertThat(usage.month()).isEqualTo("2026-10");
        assertThat(usage.totalCallCount()).isEqualTo(18);
        assertThat(usage.totalFailureCount()).isEqualTo(3);
        assertThat(usage.totalEstimatedCostUsd()).isEqualTo(0.40);
        assertThat(usage.byModel()).extracting(AiModelUsageSummary::modelName)
                .containsExactly("gemini-2.5-flash-lite", "unknown-model", AdminAiStatisticsService.UNRECORDED_MODEL_NAME);
        assertThat(usage.byModel()).extracting(AiModelUsageSummary::isPriceRegistered).containsExactly(true, false, false);
        assertThat(usage.byEndpoint()).hasSize(3);
        assertThat(usage.byEndpoint().getFirst().estimatedCostUsd()).isEqualTo(0.30);
        // 화면 JS 가 읽는 이름 그대로 직렬화 (Boolean 래퍼라 is 접두사 유지)
        assertThat(new ObjectMapper().writeValueAsString(usage.byModel().getFirst())).contains("\"isPriceRegistered\":true");
    }

    @Test
    void 실패_원인은_error_type_별_건수를_4종으로_묶는다() {
        AiFailureBreakdown breakdown = AdminAiStatisticsService.classifyFailures(List.of(
                new ErrorTypeCountRow("GEMINI_QUOTA_EXCEEDED", 3),
                new ErrorTypeCountRow("GEMINI_PERMISSION_DENIED", 1),
                new ErrorTypeCountRow("ResourceAccessException", 2),
                new ErrorTypeCountRow(null, 4)));

        assertThat(breakdown).isEqualTo(new AiFailureBreakdown(3, 1, 2, 4));
    }
}
