package com.passql.member.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 푸시 발송 대상 7종: 전체, 특정 회원 1명, 세그먼트 5개(프로, 무료, N일 미접속, Android 기기, iOS 기기)
 * 세그먼트는 발송 시점에 회원을 조회해 정함 (예약 발송도 발송 시각 기준)
 */
public enum PushAudience {
    ALL("전체", false),
    MEMBER("특정 회원", false),
    PRO_MEMBERS("프로 회원", true),
    FREE_MEMBERS("무료 회원", true),
    INACTIVE_MEMBERS("N일 이상 미접속 회원", true),
    ANDROID_DEVICES("Android 기기", true),
    IOS_DEVICES("iOS 기기", true);

    private final String label;
    private final boolean isSegment;

    PushAudience(String label, boolean isSegment) {
        this.label = label;
        this.isSegment = isSegment;
    }

    public String getLabel() {
        return label;
    }

    /** 발송 시점에 회원 목록을 조회해 정하는 대상이면 true */
    public boolean isSegment() {
        return isSegment;
    }

    /** 요청값 > PushAudience (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static PushAudience fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(PushAudience.class, requestValue);
    }
}
