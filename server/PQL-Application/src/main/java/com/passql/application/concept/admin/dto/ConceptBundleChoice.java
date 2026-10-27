package com.passql.application.concept.admin.dto;

/**
 * 묶음 안 보기: 키(A~D), 내용, 정답 여부, 근거
 */
public record ConceptBundleChoice(String choiceKey, String body, Boolean isCorrect, String rationale) {
}
