package com.passql.question.dto.community;

/** 좋아요 토글 결과: 토글 후 내 좋아요 여부, 글 좋아요 수 */
public record CommunityPostLikeResponse(Boolean isLiked, Integer likeCount) {
}
