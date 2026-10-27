package com.passql.application.concept.admin.dto;

/**
 * 묶음 저장 결과: 새로 만든 개념 수, 갱신한 개념 수
 */
public record ConceptBundleImportResult(int createdCount, int updatedCount) {
}
