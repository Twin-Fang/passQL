package com.passql.application.concept.admin.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 관리자 개념 본문 수정 요청: 제목·요약·핵심·자세히 (자세히 형식·앵커는 ConceptAdminService 가 검사)
 */
public record ConceptContentUpdateRequest(
    @NotBlank String title,
    @NotNull String summary,
    @NotNull String coreMd,
    @NotNull String detailMd
) {}
