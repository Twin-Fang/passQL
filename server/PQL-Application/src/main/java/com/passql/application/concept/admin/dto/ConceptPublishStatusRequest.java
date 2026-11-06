package com.passql.application.concept.admin.dto;

import jakarta.validation.constraints.NotBlank;

/** 개념 공개 상태 변경 요청: status = PUBLISHED | DRAFT */
public record ConceptPublishStatusRequest(@NotBlank String status) {
}
