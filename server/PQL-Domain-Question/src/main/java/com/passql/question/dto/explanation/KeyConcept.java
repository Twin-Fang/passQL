package com.passql.question.dto.explanation;

import io.swagger.v3.oas.annotations.media.Schema;

/** 핵심 개념 1개: 개념명 + 한두 줄 설명 (#521) */
public record KeyConcept(
    @Schema(description = "개념명 (예: DENSE_RANK)") String name,
    @Schema(description = "개념 설명 한두 줄") String description
) {}
