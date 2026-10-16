package com.passql.member.dto;

import com.passql.member.constant.NotificationCategory;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 알림함 항목 1건 (알림·공지 탭 공용, 앱·웹과의 와이어 계약)
 * 알림: id = 알림 UUID, type = MemberNotificationType 이름 / 공지: id = 공지 UUID, type = NOTICE, 이동 정보 없음
 */
public record NotificationItemResponse(
        UUID id,
        NotificationCategory category,
        String type,
        String title,
        String body,
        String linkTarget,
        UUID linkQuestionUuid,
        Boolean isRead,
        LocalDateTime createdAt,
        Boolean isImportant
) {
}
