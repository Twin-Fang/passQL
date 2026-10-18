package com.passql.question.dto.community;

import io.swagger.v3.oas.annotations.media.Schema;

/** 신고 요청: category = ABUSE / SPAM / ANSWER_SPOILER / ETC, detail 은 선택 (최대 200자) */
public record CommunityReportRequest(String category, @Schema(nullable = true) String detail) {
}
