package com.passql.application.concept.admin.dto;

import java.util.List;

/**
 * 묶음 안 확인 문제: 순서(1~5), 지문, 지문 SQL(선택), 풀이, 다시 읽기 앵커, 보기 4개
 */
public record ConceptBundleCheckQuestion(
    Integer sortOrder,
    String stem,
    String stemSql,
    String explanation,
    String rereadAnchor,
    List<ConceptBundleChoice> choices
) {
}
