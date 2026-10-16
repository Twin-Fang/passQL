package com.passql.ai.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.UUID;

public record SimilarQuestion(UUID questionUuid, @Schema(nullable = true) String stem, @Schema(nullable = true) String topicName, double score) {}
