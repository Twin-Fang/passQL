package com.passql.application.concept.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 확인 문제 답 제출: 고른 보기 키 (A~D)
 */
public record ConceptCheckAnswerRequest(@NotBlank String choiceKey) {
}
