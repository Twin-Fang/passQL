package com.passql.question.dto.community;

import com.passql.question.constant.CommunityBoardType;
import com.passql.question.constant.CommunityPostStatus;
import com.passql.question.constant.CommunityTargetType;

import java.time.LocalDateTime;
import java.util.UUID;

/** 관리자 토론 게시글 목록 1건 (targetUuid: 대상 없음이면 null, authorNickname: member 행 없으면 탈퇴회원) */
public record AdminCommunityPostListItem(
        UUID postUuid,
        CommunityBoardType boardType,
        CommunityTargetType targetType,
        UUID targetUuid,
        UUID authorMemberUuid,
        String authorNickname,
        String content,
        CommunityPostStatus status,
        Integer likeCount,
        Integer commentCount,
        Integer reportCount,
        LocalDateTime createdAt
) {
}
