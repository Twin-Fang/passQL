package com.passql.question.dto.community;

import io.swagger.v3.oas.annotations.media.Schema;

/** 글 작성 요청: 본문 1~500자, includeSolveSnapshot 가 true 면 서버가 본인 제출 기록으로 풀이 요약을 붙임 */
public record CommunityPostCreateRequest(
        String content,
        @Schema(nullable = true) Boolean includeSolveSnapshot
) {
}
