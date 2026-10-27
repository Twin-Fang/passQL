package com.passql.application.concept.admin.dto;

import java.util.List;

/**
 * 관리자 미리보기 확인 문제: 정답 키·풀이·다시 읽기 앵커 포함
 */
public record AdminCheckQuestionPreview(
    int sortOrder,
    String stem,
    String stemSql,
    String explanation,
    String rereadAnchor,
    String correctKey,
    List<ConceptBundleChoice> choices
) {
}
