package com.passql.ai.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 연결 수정: 이름·기본 모델 (키 교체는 별도)
 */
public record AiConnectionUpdateRequest(
        @NotBlank @Size(max = 100) String connectionName,
        @NotBlank @Size(max = 100) String defaultModel
) {
}
