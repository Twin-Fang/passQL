package com.passql.ai.dto;

import jakarta.validation.constraints.NotNull;

/**
 * 연결 사용 전환 (true 사용, false 미사용)
 */
public record AiConnectionEnabledRequest(@NotNull Boolean isEnabled) {
}
