package com.passql.application.concept.admin.dto;

/**
 * 묶음 검증 문제 1건: 어느 개념(tagKey)의 어느 칸이 왜 틀렸는지
 */
public record ConceptBundleItemIssue(String tagKey, String field, String reason) {
}
