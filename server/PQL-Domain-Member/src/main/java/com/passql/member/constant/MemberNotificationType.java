package com.passql.member.constant;

/** 일반 알림이 생긴 이유 3종 (이름이 앱·웹과의 와이어 계약, 변경 금지) */
public enum MemberNotificationType {
    ADMIN_MESSAGE("관리자 발송"),
    REPORT_RESOLVED("신고 처리 결과"),
    DAILY_SET_REMINDER("오늘의 세트 리마인드");

    private final String label;

    MemberNotificationType(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
