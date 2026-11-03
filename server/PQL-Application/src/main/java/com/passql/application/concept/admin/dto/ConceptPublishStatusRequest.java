package com.passql.application.concept.admin.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 관리자 개념 공개 상태 변경 요청: status "PUBLISHED" | "DRAFT" (없는 값 > ConceptPublishStatus.fromRequestValue 가 400)
 */
public record ConceptPublishStatusRequest(
    @NotBlank String status
) {}
