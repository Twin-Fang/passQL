package com.passql.application.statistics.dto;

import java.time.LocalDateTime;
import java.util.List;

/**
 * AI API 상태: AI 서버·서킷·1순위 AI 연결, 24시간 실패 원인 4종, 이번 달 토큰·비용·예산
 * circuitState: CLOSED 정상, OPEN 차단, HALF_OPEN 시험 호출 중, UNKNOWN 서킷 미등록
 */
public record DashboardAiStatusResponse(
        AiServerStatus aiServer,
        String circuitState,
        AiConnectionStatus aiConnection,
        AiFailureBreakdown failureBreakdown24h,
        long monthPromptTokenCount,
        long monthCompletionTokenCount,
        double monthEstimatedCostUsd,
        double monthlyBudgetUsd,
        double budgetUsedPercent,
        List<AiModelUsageSummary> costByModel
) {

    /** AI 서버 /health 결과 */
    public record AiServerStatus(Boolean isUp, long latencyMilliseconds, String detail) {}

    /** 1순위 AI 연결 확인 결과 (checkedAt: 상태 조회 시각) */
    public record AiConnectionStatus(Boolean isValid, LocalDateTime checkedAt, String detail) {}

    /** 최근 24시간 실패 원인별 건수 */
    public record AiFailureBreakdown(long quotaExceededCount, long permissionDeniedCount,
                                     long timeoutOrServerErrorCount, long otherCount) {}
}
