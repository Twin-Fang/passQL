package com.passql.application.concept.admin.dto;

import com.passql.meta.constant.ConceptPublishStatus;
import com.passql.meta.dto.concept.ConceptDetailSection;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 미리보기: 앱과 같은 순서(핵심만 > 자세히 문단 > 확인 문제), 편집용 원문 포함
 */
public record AdminConceptPreview(
    UUID conceptUuid,
    String tagKey,
    String title,
    String summary,
    ConceptPublishStatus publishStatus,
    String coreMd,
    String detailMd,
    List<ConceptDetailSection> sections,
    List<AdminCheckQuestionPreview> checkQuestions
) {
}
