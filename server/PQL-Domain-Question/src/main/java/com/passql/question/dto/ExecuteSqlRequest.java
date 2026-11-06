package com.passql.question.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

/** 보기 SQL 실행 요청 (빈 SQL 은 400 VALIDATION_ERROR) */
@Schema(description = "보기 SQL 실행 요청")
public record ExecuteSqlRequest(
    @NotBlank
    @Schema(description = "실행할 SQL", example = "SELECT * FROM EMP")
    String sql
) {}
