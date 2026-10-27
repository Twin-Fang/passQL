package com.passql.application.concept.dto;

import java.util.UUID;

/**
 * 개념 단원 목록 1행: 순서(0부터, 무료 판정 기준), 개념 수, 완료 수, 잠금 여부
 */
public record ConceptTopicSummary(
    UUID topicUuid,
    String displayName,
    int orderIndex,
    int conceptCount,
    int completedCount,
    boolean isLocked
) {
}
