package com.passql.member.constant;

import com.passql.common.util.RequestEnumParser;

/** 푸시 토큰 발급 기기 플랫폼 2종 */
public enum PushPlatform {
    IOS,
    ANDROID;

    /** 요청값 > PushPlatform (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static PushPlatform fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(PushPlatform.class, requestValue);
    }
}
