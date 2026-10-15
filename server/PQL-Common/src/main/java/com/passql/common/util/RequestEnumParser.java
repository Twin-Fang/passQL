package com.passql.common.util;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;

/**
 * 요청 문자열 > enum 상수 변환 (대소문자 구분, 앞뒤 공백 미허용 — Enum.valueOf 규칙 그대로)
 * 각 enum 의 fromRequestValue 가 parse 를 위임 호출
 */
public final class RequestEnumParser {

    // 오류 메시지에 넣는 요청값 최대 길이 (문자 수)
    private static final int MAX_ECHOED_VALUE_LENGTH = 50;

    private RequestEnumParser() {
    }

    /** 요청값 > enum (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static <E extends Enum<E>> E parse(Class<E> enumType, String requestValue) {
        E constant = parseOrNull(enumType, requestValue);
        if (constant == null) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE,
                    enumType.getSimpleName() + "=" + TextPreview.truncate(requestValue, MAX_ECHOED_VALUE_LENGTH));
        }
        return constant;
    }

    /** 요청값 > enum (null·공백·없는 값 > null, 호출부가 대체 규칙을 직접 정할 때만) */
    public static <E extends Enum<E>> E parseOrNull(Class<E> enumType, String requestValue) {
        if (requestValue == null || requestValue.isBlank()) {
            return null;
        }
        try {
            return Enum.valueOf(enumType, requestValue);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
