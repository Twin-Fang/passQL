package com.passql.application.concept.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import com.passql.meta.constant.ConceptReadingDepth;
import com.passql.meta.constant.ConceptStudyMode;
import com.passql.meta.dto.concept.ConceptDetailSection;

import java.util.List;
import java.util.UUID;

/**
 * 개념 상세: 핵심만, 자세히 문단, 같은 단원 이전·다음 개념(없으면 null), 내 진행, 관련 문제
 */
public record ConceptDetailResponse(
    UUID conceptUuid,
    UUID topicUuid,
    String title,
    @Schema(nullable = true) String summary,
    @Schema(nullable = true) String coreMd,
    List<ConceptDetailSection> detailSections,
    @Schema(nullable = true) UUID previousConceptUuid,
    @Schema(nullable = true) UUID nextConceptUuid,
    ConceptStudyMode lastMode,
    ConceptReadingDepth lastDepth,
    boolean isRead,
    int checkCorrectCount,
    List<UUID> relatedQuestionUuids
) {
}
