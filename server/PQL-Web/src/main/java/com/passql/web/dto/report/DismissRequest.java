package com.passql.web.dto.report;

/**
 * 신고 1건 기각 요청 (본문 생략 가능): 사유 메모(선택, 최대 500자)
 */
public record DismissRequest(String resolutionNote) {}
