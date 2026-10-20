package com.passql.application.statistics.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/** 토론 활동 14일: 일별 새 글 수(삭제 제외) + 최근 글 5건 */
public record DashboardCommunityResponse(
        List<String> labels,
        List<Long> postCounts,
        List<RecentCommunityPost> recentPosts
) {

    /** 최근 글 1건 (contentPreview: 본문 앞부분 + 말줄임, authorNickname: member 행 없으면 탈퇴회원) */
    public record RecentCommunityPost(
            UUID postUuid,
            String boardType,
            String contentPreview,
            String authorNickname,
            long likeCount,
            long commentCount,
            String status,
            long reportCount,
            LocalDateTime createdAt
    ) {}
}
