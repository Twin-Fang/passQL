package com.passql.application.concept.admin.dto;

import java.util.List;

/**
 * 개념 묶음 가져오기 요청 (관리자 JSON 업로드, 콘텐츠 제작 결과물)
 */
public record ConceptBundle(List<ConceptBundleItem> concepts) {
}
