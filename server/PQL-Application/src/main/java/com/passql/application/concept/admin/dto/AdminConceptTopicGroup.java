package com.passql.application.concept.admin.dto;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 개념 목록 단원 묶음 (단원 순서대로, 개념이 없는 단원도 포함)
 */
public record AdminConceptTopicGroup(
    UUID topicUuid,
    String topicCode,
    String displayName,
    List<AdminConceptRow> concepts
) {
}
