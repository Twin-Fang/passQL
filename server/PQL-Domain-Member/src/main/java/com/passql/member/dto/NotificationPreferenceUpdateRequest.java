package com.passql.member.dto;

/** 자동 알림 수신 설정 변경: null 인 항목은 그대로 둠 */
public record NotificationPreferenceUpdateRequest(
    Boolean isStudyReminderEnabled,
    Boolean isComebackEnabled,
    Boolean isExamCountdownEnabled
) {
}
