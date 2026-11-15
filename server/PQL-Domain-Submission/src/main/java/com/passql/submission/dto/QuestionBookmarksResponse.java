package com.passql.submission.dto;

import java.util.List;

/** 즐겨찾기 목록 한 페이지 (#1082): 최근 추가 순, totalCount 는 활성 문제 기준 전체 수 */
public record QuestionBookmarksResponse(
    List<QuestionBookmarkItem> items,
    long totalCount,
    int page,
    Boolean hasNext
) {}
