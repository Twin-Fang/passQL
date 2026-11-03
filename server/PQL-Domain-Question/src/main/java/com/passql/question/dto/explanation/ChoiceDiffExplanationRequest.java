package com.passql.question.dto.explanation;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

/**
 * 선택지 해설 요청 (동기, 출시 앱 호환): 문제 + 고른 보기 (생략·빈 값이면 마지막 제출의 보기)
 */
@Schema(description = "선택지 해설 요청 (동기, 출시 앱 호환)")
public record ChoiceDiffExplanationRequest(
    @Schema(description = "문제 UUID", example = "550e8400-e29b-41d4-a716-446655440000")
    @NotNull UUID questionUuid,

    @Schema(nullable = true, description = "고른 보기 키 (생략 시 마지막 제출의 보기)", example = "A")
    String selectedChoiceKey
) {}
