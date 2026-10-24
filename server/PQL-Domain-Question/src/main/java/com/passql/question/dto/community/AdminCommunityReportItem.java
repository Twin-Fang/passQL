package com.passql.question.dto.community;

import com.passql.question.constant.CommunityReportStatus;

import java.time.LocalDateTime;
import java.util.UUID;

/** 관리자 화면 신고 1건 (신고자 식별 정보 없음, 처리 전이면 처리 기록은 null) */
public record AdminCommunityReportItem(
        UUID reportUuid,
        String category,
        String categoryLabel,
        String detail,
        CommunityReportStatus status,
        LocalDateTime createdAt,
        String handledBy,
        String handledNote,
        LocalDateTime handledAt
) {
}
