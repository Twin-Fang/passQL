package com.passql.web.dto.notification;

/** 회원당 하루 자동 알림 상한 수정 요청 (범위는 NotificationSettingService 가 검증) */
public record AutoNotificationDailyLimitUpdateRequest(
        Integer dailyLimitPerMember
) {
}
