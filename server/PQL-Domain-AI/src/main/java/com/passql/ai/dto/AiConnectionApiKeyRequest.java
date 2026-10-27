package com.passql.ai.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 연결 API 키 교체
 */
public record AiConnectionApiKeyRequest(@NotBlank String apiKey) {
}
