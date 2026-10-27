package com.passql.application.concept.dto;

import java.util.List;

/**
 * 개념 단원 목록: 이용 가능 여부(공개 또는 미리보기 회원), 무료 단원 수, 단원들
 */
public record ConceptTopicListResponse(
    boolean isAvailable,
    int freeTopicCount,
    List<ConceptTopicSummary> topics
) {
}
