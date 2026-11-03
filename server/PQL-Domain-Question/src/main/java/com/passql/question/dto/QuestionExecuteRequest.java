package com.passql.question.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

/**
 * 선택지 SQL 실행 요청 (EXECUTABLE 문제만)
 */
@Schema(description = "선택지 SQL 실행 요청")
public record QuestionExecuteRequest(
    @Schema(description = "실행할 SQL", example = "SELECT * FROM emp")
    @NotBlank String sql
) {}
