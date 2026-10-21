package com.passql.question.dto.community;

import java.util.List;

/** 관리자 토론 게시글 목록 한 페이지 (최신 작성순) */
public record AdminCommunityPostListPage(
        List<AdminCommunityPostListItem> content,
        int page,
        int size,
        long totalElements,
        int totalPages
) {
}
