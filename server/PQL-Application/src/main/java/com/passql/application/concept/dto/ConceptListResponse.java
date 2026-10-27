package com.passql.application.concept.dto;

import java.util.List;
import java.util.UUID;

/**
 * 단원의 개념 목록 (잠긴 단원도 제목·진행은 내려줌, 앱은 블러로 표시)
 */
public record ConceptListResponse(
    UUID topicUuid,
    String displayName,
    boolean isLocked,
    List<ConceptSummary> concepts
) {
}
