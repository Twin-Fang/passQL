package com.passql.meta.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 관리자 프롬프트 등록·수정 폼 요청 (prompts.html)
 * isActive: 체크박스 미체크 시 값 없음 > false
 */
public record PromptTemplateSaveRequest(
        @NotBlank String keyName,
        @NotNull @Min(1) Integer version,
        Boolean isActive,
        String model,
        String systemPrompt,
        String userTemplate,
        Float temperature,
        Integer maxTokens
) {
    public boolean isActiveChecked() {
        return Boolean.TRUE.equals(isActive);
    }
}
