package com.passql.application.concept.admin.dto;

import java.util.List;

/**
 * 묶음 검증 결과: 통과 여부, 문제 목록 (통과면 빈 목록)
 */
public record ConceptBundleValidationResult(boolean isValid, List<ConceptBundleItemIssue> issues) {
}
