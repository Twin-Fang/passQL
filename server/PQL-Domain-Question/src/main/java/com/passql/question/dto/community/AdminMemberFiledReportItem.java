package com.passql.question.dto.community;

import com.passql.question.constant.CommunityReportStatus;

import java.time.LocalDateTime;
import java.util.UUID;

/** 회원이 한 신고 1건 (대상 글 UUID, 사유, 처리 상태) */
public record AdminMemberFiledReportItem(
        UUID reportUuid,
        UUID targetUuid,
        String categoryLabel,
        String detail,
        CommunityReportStatus status,
        LocalDateTime createdAt
) {
}
