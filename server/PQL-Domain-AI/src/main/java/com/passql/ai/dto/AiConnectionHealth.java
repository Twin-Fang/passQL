package com.passql.ai.dto;

import java.time.LocalDateTime;

/**
 * AI 연결 확인 결과 (모델 조회 무료 호출, #557, #695)
 * detail: 정상이면 확인한 연결·모델, 실패면 원인 (한도 초과 429 / 키·권한 401·403 / 그 외)
 */
public record AiConnectionHealth(
        boolean isValid,
        long latencyMilliseconds,
        String detail,
        LocalDateTime checkedAt
) {
    // 모니터링 카드 구성 요소 이름
    public static final String COMPONENT_NAME = "AI 연결 (1순위)";

    /** 모니터링 카드 형태 > ComponentHealth */
    public ComponentHealth toComponentHealth() {
        return isValid
                ? ComponentHealth.up(COMPONENT_NAME, latencyMilliseconds, detail)
                : ComponentHealth.down(COMPONENT_NAME, latencyMilliseconds, detail);
    }
}
