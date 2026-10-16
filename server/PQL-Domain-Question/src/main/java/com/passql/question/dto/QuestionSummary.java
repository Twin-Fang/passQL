package com.passql.question.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import com.passql.question.constant.ExecutionMode;

import java.time.LocalDateTime;
import java.util.UUID;

public record QuestionSummary(
    UUID questionUuid,
    @Schema(nullable = true) String topicCode,
    @Schema(nullable = true) String topicName,
    Integer difficulty,
    @Schema(nullable = true) ExecutionMode executionMode,
    @Schema(nullable = true) String stemPreview,
    LocalDateTime createdAt
) {}
