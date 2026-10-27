package com.passql.application.concept.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.UUID;

/**
 * 단원 안 개념 1행: 제목, 한 줄 요약, 상태, 확인 문제 정답 수 / 문제 수
 */
public record ConceptSummary(
    UUID conceptUuid,
    String title,
    @Schema(nullable = true) String summary,
    ConceptStatus status,
    int checkCorrectCount,
    int checkQuestionCount
) {
}
