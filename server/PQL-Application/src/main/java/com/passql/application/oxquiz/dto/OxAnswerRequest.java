package com.passql.application.oxquiz.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/** OX 답 기록 (#1083): 카드 키 + 맞혔는지 (채점은 앱) */
public record OxAnswerRequest(@NotBlank String cardKey, @NotNull Boolean isCorrect) {
}
