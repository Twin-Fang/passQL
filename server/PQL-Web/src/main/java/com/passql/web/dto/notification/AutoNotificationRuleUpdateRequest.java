package com.passql.web.dto.notification;

/** 자동 알림 규칙 수정 요청 (값 범위는 AutoNotificationService 가 검증) */
public record AutoNotificationRuleUpdateRequest(
        Boolean isEnabled,
        Integer sendHour,
        Integer thresholdDays,
        String title,
        String body,
        String linkTarget
) {
}
