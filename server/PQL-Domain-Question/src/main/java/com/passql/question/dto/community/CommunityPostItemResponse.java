package com.passql.question.dto.community;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

/** 글 1건: 작성자는 닉네임만 (회원 UUID 비노출) */
public record CommunityPostItemResponse(
        UUID postUuid,
        String authorNickname,
        String content,
        Boolean isMine,
        Integer likeCount,
        Boolean isLikedByMe,
        @Schema(nullable = true) SolveSnapshot solveSnapshot,
        LocalDateTime createdAt
) {
}
