package com.passql.meta.dto;

import jakarta.validation.constraints.NotNull;

/**
 * 관리자 개념 문서 본문 수정 요청 (마크다운, 빈 본문 허용)
 */
public record ConceptDocBodyUpdateRequest(
    @NotNull String bodyMd
) {}
