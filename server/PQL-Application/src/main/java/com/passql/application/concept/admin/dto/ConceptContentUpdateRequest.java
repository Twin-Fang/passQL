package com.passql.application.concept.admin.dto;

/** 개념 본문 수정 요청: 제목, 요약, 핵심(마크다운), 자세히(마크다운, 앵커 형식 검사는 서비스) */
public record ConceptContentUpdateRequest(String title, String summary, String coreMd, String detailMd) {
}
