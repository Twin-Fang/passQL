package com.passql.question.dto.community;

import java.util.List;

/** 관리자 신고 글 목록 한 페이지 (pendingPostCount: 검토 대기 신고가 있는 글 전체 수) */
public record AdminCommunityPostPage(
        List<AdminCommunityPostItem> content,
        int page,
        int size,
        long totalElements,
        int totalPages,
        long pendingPostCount
) {
}
