package com.passql.application.concept.admin.dto;

import java.util.List;
import java.util.UUID;

/**
 * 묶음 안 개념 1개: tagKey(갱신 기준), 단원 코드, 단원 안 순서, 제목·요약, 핵심만·자세히, 확인 문제 5개, 관련 문제
 */
public record ConceptBundleItem(
    String tagKey,
    String topicCode,
    Integer sortOrder,
    String title,
    String summary,
    String coreMd,
    String detailMd,
    List<ConceptBundleCheckQuestion> checkQuestions,
    List<UUID> relatedQuestionUuids
) {
}
