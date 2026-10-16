package com.passql.member.constant;

import com.passql.common.util.RequestEnumParser;

/** 알림함 두 탭: 일반 알림(회원별 1행), 공지(공유 1행 + 회원별 읽음) */
public enum NotificationCategory {
    GENERAL("알림"),
    NOTICE("공지");

    private final String label;

    NotificationCategory(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    /** 요청값 > NotificationCategory (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static NotificationCategory fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(NotificationCategory.class, requestValue);
    }
}
