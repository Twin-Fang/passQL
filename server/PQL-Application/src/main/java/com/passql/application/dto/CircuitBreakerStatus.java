package com.passql.application.dto;

/**
 * resilience4j 서킷 1개 상태 (#475)
 * state: CLOSED 정상, OPEN 차단(대체 경로), HALF_OPEN 시험 호출 중
 * failureRatePercent: 최근 창 실패율 (%, 호출이 창 최소 수보다 적으면 -1)
 */
public record CircuitBreakerStatus(
        String circuitBreakerName,
        String state,
        float failureRatePercent,
        int bufferedCallCount,
        int failedCallCount,
        long notPermittedCallCount
) {
    public boolean isOpen() {
        return "OPEN".equals(state) || "FORCED_OPEN".equals(state);
    }
}
