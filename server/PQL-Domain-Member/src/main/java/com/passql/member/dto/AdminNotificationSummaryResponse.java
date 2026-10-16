package com.passql.member.dto;

import com.passql.member.entity.MemberNotification;

import java.time.LocalDateTime;

/** 관리자 회원 상세의 알림 1건: 내용, 읽음 여부, 회수(숨김) 여부 */
public record AdminNotificationSummaryResponse(
        String type,
        String title,
        String body,
        Boolean isRead,
        Boolean isHidden,
        LocalDateTime createdAt,
        LocalDateTime readAt
) {
    public static AdminNotificationSummaryResponse from(MemberNotification notification) {
        return new AdminNotificationSummaryResponse(
                notification.getNotificationType().getLabel(), notification.getTitle(), notification.getBody(),
                notification.isRead(), notification.getIsHidden(), notification.getCreatedAt(), notification.getReadAt());
    }
}
