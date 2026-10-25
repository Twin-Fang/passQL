package com.passql.member.constant;

/**
 * 회원이 끄고 켜는 자동 알림 종류 3그룹 (이름이 앱·API 와이어 계약, 변경 금지)
 * 관리자 직접 발송은 그룹이 없고 항상 수신
 */
public enum AutoNotificationGroup {
    STUDY_REMINDER("학습 리마인더"),
    COMEBACK("복귀 알림"),
    EXAM_COUNTDOWN("시험 D-day");

    private final String label;

    AutoNotificationGroup(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
