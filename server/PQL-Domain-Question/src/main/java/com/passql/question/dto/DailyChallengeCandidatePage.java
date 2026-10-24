package com.passql.question.dto;

import java.util.List;

/**
 * 일일 챌린지 배정 후보 한 페이지 (활성 문제만, 최신 등록순)
 */
public record DailyChallengeCandidatePage(
        List<AdminQuestionListItem> content,
        int page,
        int totalPages,
        long totalElements
) {}
