package com.passql.ai.dto;

import java.time.LocalDateTime;

/**
 * Gemini API 키 유효성 확인 결과 (models.get 무료 호출, 5분 캐시, #557)
 * detail: 정상이면 확인한 모델, 실패면 원인 (한도 초과 429 / 권한·결제 401·403 / 그 외)
 */
public record GeminiApiKeyHealth(
        boolean isValid,
        long latencyMilliseconds,
        String detail,
        LocalDateTime checkedAt
) {
    // 모니터링 카드 구성 요소 이름
    public static final String COMPONENT_NAME = "Gemini API";

    /** 모니터링 카드 형태 > ComponentHealth */
    public ComponentHealth toComponentHealth() {
        return isValid
                ? ComponentHealth.up(COMPONENT_NAME, latencyMilliseconds, detail)
                : ComponentHealth.down(COMPONENT_NAME, latencyMilliseconds, detail);
    }
}
