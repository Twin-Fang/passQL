package com.passql.question.dto.community;

import com.passql.question.constant.CommunityReportStatus;

import java.time.LocalDateTime;

/** 관리자 화면 신고 1건 (신고자 식별 정보 없음) */
public record AdminCommunityReportItem(
        String category,
        String categoryLabel,
        String detail,
        CommunityReportStatus status,
        LocalDateTime createdAt
) {
}
