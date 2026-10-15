package com.passql.member.constant;

import com.passql.common.util.RequestEnumParser;

/** 푸시 발송 대상 2종: 수신 동의 기기 전체, 특정 회원 1명 */
public enum PushAudience {
    ALL("전체"),
    MEMBER("특정 회원");

    private final String label;

    PushAudience(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    /** 요청값 > PushAudience (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static PushAudience fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(PushAudience.class, requestValue);
    }
}
