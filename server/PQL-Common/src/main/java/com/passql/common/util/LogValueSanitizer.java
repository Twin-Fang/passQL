package com.passql.common.util;

/**
 * 외부에서 들어온 식별자 > 로그에 넣을 안전한 값 (길이 제한 + 허용 문자 외 치환)
 * 허용 문자: 영문·숫자·하이픈·밑줄·슬래시 (UUID, 광고 단위 ID 형식), null > "null"
 */
public final class LogValueSanitizer {

    // 허용 문자 밖 (UUID·광고 단위 ID·거래 ID에 쓰이는 문자만 남김)
    private static final String NON_IDENTIFIER_CHARACTER_PATTERN = "[^0-9A-Za-z/_-]";
    private static final String REPLACEMENT = "?";
    private static final String NULL_TEXT = "null";

    private LogValueSanitizer() {
    }

    /** 식별자 정리: 앞에서 maxLength 자 > 허용 문자 외 ? (줄바꿈 로그 위조 차단) */
    public static String toLogSafeIdentifier(String value, int maxLength) {
        if (value == null) {
            return NULL_TEXT;
        }
        return TextPreview.truncate(value, maxLength).replaceAll(NON_IDENTIFIER_CHARACTER_PATTERN, REPLACEMENT);
    }
}
