package com.passql.member.dto;

import com.passql.member.entity.MemberNotificationPreference;

/** 자동 알림 수신 설정: 그룹별 켜짐 여부 (행이 없는 회원은 전부 true) */
public record NotificationPreferenceResponse(
    boolean isStudyReminderEnabled,
    boolean isComebackEnabled,
    boolean isExamCountdownEnabled
) {

    public static NotificationPreferenceResponse allEnabled() {
        return new NotificationPreferenceResponse(true, true, true);
    }

    public static NotificationPreferenceResponse from(MemberNotificationPreference preference) {
        return new NotificationPreferenceResponse(preference.getIsStudyReminderEnabled(),
                preference.getIsComebackEnabled(), preference.getIsExamCountdownEnabled());
    }
}
