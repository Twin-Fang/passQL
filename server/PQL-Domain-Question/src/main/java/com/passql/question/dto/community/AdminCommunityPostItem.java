package com.passql.question.dto.community;

import com.passql.question.constant.CommunityPostStatus;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/** 관리자 화면 신고 글 1건: 내용, 작성자 닉네임, 신고 수, 신고 목록 */
public record AdminCommunityPostItem(
        UUID postUuid,
        UUID questionUuid,
        String authorNickname,
        String content,
        CommunityPostStatus status,
        Integer reportCount,
        Integer likeCount,
        LocalDateTime createdAt,
        List<AdminCommunityReportItem> reports
) {
}
