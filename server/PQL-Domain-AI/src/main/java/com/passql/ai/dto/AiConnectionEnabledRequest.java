package com.passql.ai.dto;

import jakarta.validation.constraints.NotNull;

/** 연결 사용 켜기·끄기 요청 */
public record AiConnectionEnabledRequest(@NotNull Boolean isEnabled) {
}
