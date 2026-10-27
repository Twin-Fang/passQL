package com.passql.application.concept.dto;

/**
 * 확인 문제 보기 (정답 여부는 채점 응답에서만)
 */
public record ConceptCheckChoiceResponse(String choiceKey, String body) {
}
