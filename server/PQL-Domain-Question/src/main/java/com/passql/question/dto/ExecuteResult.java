package com.passql.question.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record ExecuteResult(
    @Schema(nullable = true) String status,
    List<String> columns,
    List<List<Object>> rows,
    int rowCount,
    long elapsedMs,
    @Schema(nullable = true) String errorCode,
    @Schema(nullable = true) String errorMessage
) {}
