package com.passql.ai.dto;

import com.passql.ai.constant.AiProvider;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * 연결 추가: 제공자 + 이름 + API 키 + 기본 모델 (우선순위는 맨 뒤)
 */
public record AiConnectionCreateRequest(
        @NotNull AiProvider provider,
        @NotBlank @Size(max = 100) String connectionName,
        @NotBlank String apiKey,
        @NotBlank @Size(max = 100) String defaultModel
) {
}
