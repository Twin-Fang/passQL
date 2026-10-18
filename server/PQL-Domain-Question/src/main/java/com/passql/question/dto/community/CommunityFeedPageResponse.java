package com.passql.question.dto.community;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/** 피드 한 페이지: 문제 카드, 다음 페이지 커서 (마지막이면 null) */
public record CommunityFeedPageResponse(List<CommunityFeedCardResponse> items, @Schema(nullable = true) String nextCursor) {
}
