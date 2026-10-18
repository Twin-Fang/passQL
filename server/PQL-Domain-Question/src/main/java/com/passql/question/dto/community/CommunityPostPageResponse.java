package com.passql.question.dto.community;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/** 글 목록 한 페이지: 항목, 다음 페이지 커서 (마지막이면 null) */
public record CommunityPostPageResponse(List<CommunityPostItemResponse> items, @Schema(nullable = true) String nextCursor) {
}
