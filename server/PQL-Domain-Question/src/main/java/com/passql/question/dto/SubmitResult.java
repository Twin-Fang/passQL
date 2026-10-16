package com.passql.question.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.UUID;

// EXECUTABLE 문제: selectedResult/correctResult/selectedSql/correctSql 포함
// CONCEPT_ONLY 문제: 위 4개 필드 null
// submissionUuid: 저장된 제출 UUID — 프론트 신고 기능에서 사용
public record SubmitResult(
    boolean isCorrect,
    @Schema(nullable = true) String correctKey,
    @Schema(nullable = true) String rationale,
    @Schema(nullable = true) ExecuteResult selectedResult,
    @Schema(nullable = true) ExecuteResult correctResult,
    @Schema(nullable = true) String correctSql,
    @Schema(nullable = true) String selectedSql,
    @Schema(nullable = true) UUID submissionUuid
) {}
