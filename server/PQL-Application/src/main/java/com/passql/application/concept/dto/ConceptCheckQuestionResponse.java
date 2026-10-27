package com.passql.application.concept.dto;

import java.util.List;
import java.util.UUID;

/**
 * 확인 문제 1개: 지문, 지문 SQL(없으면 null), 보기 (정답·풀이 미포함)
 */
public record ConceptCheckQuestionResponse(
    UUID questionUuid,
    int sortOrder,
    String stem,
    String stemSql,
    List<ConceptCheckChoiceResponse> choices
) {
}
