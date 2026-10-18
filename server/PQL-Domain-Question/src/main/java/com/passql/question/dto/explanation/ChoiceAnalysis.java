package com.passql.question.dto.explanation;

import io.swagger.v3.oas.annotations.media.Schema;

/** 보기 1개 판정: 보기 키, 정답 여부(DB 정답과 일치 검증됨), 맞고 틀린 이유 한 줄 (#521) */
public record ChoiceAnalysis(
    @Schema(description = "보기 키 (A~D)") String choiceKey,
    @Schema(description = "정답 보기 여부") Boolean isCorrect,
    @Schema(description = "맞거나 틀린 이유 한 줄") String reason
) {}
