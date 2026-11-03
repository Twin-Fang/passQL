package com.passql.question.dto.explanation;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

/**
 * SQL 실행 오류 AI 해설 요청: 문제 + 실행한 SQL + 오류 메시지 (길이 상한은 AiExplainService 가 검사)
 */
@Schema(description = "SQL 실행 오류 AI 해설 요청")
public record ErrorExplanationRequest(
    @Schema(description = "문제 UUID", example = "550e8400-e29b-41d4-a716-446655440000")
    @NotNull UUID questionUuid,

    @Schema(description = "실행한 선택지 SQL", example = "SELECT ename, COUNT(*) FROM emp")
    @NotBlank String sql,

    @Schema(description = "샌드박스 실행 오류 메시지", example = "column \"ename\" must appear in the GROUP BY clause")
    @NotBlank String errorMessage
) {}
