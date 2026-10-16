package com.passql.ai.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDateTime;

public record AiCommentResponse(String comment, @Schema(nullable = true) LocalDateTime generatedAt) {}
