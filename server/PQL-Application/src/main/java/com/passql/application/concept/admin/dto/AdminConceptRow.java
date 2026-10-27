package com.passql.application.concept.admin.dto;

import com.passql.meta.constant.ConceptPublishStatus;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 관리자 개념 목록 1행: 상태, 확인 문제 수(5개여야 공개 가능), 마지막 수정
 */
public record AdminConceptRow(
    UUID conceptUuid,
    String tagKey,
    String title,
    ConceptPublishStatus publishStatus,
    int checkQuestionCount,
    LocalDateTime updatedAt
) {
}
