package com.passql.meta.dto.concept;

/**
 * 자세히 본문 문단 1개: 앵커(다시 읽기 이동 지점), 제목, 본문 마크다운
 */
public record ConceptDetailSection(String anchor, String title, String bodyMd) {
}
