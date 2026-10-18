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
    LocalDateTime createdAt,
    @Schema(description = "최신 출제 경향 반영 문제 여부 ('최신 경향' 배지, #523)")
    Boolean isLatestTrend
) {}
