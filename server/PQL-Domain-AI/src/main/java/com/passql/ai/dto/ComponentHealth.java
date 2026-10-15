package com.passql.ai.dto;

/**
 * 외부 구성 요소 1개 상태 (모니터링 카드, #475)
 * detail: 정상이면 요약(예: Qdrant 포인트 수), 실패면 원인
 */
public record ComponentHealth(
        String componentName,
        boolean isUp,
        long latencyMilliseconds,
        String detail
) {
    public static ComponentHealth up(String componentName, long latencyMilliseconds, String detail) {
        return new ComponentHealth(componentName, true, latencyMilliseconds, detail);
    }

    public static ComponentHealth down(String componentName, long latencyMilliseconds, String detail) {
        return new ComponentHealth(componentName, false, latencyMilliseconds, detail);
    }
}
