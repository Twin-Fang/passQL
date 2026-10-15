package com.passql.ai.dto;

/**
 * AI 서버 호출 통계 (ai_call_log DB 집계, 배포해도 유지, #474)
 * 실패 = HTTP 오류·연결 실패·응답 해석 실패 (Gemini 대체 경로로 복구된 호출도 AI 서버 기준 실패)
 */
public record AiStats(
        long totalCallCount,
        long successCount,
        long failureCount,
        double averageLatencyMilliseconds,
        long maxLatencyMilliseconds
) {
    public static AiStats empty() {
        return new AiStats(0, 0, 0, 0, 0);
    }

    /** 실패 비율 (%) — 호출 없으면 0 */
    public double failureRatePercent() {
        return totalCallCount == 0 ? 0 : failureCount * 100.0 / totalCallCount;
    }
}
