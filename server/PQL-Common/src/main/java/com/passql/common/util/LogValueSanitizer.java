package com.passql.common.util;

/**
 * 외부에서 들어온 값 > 로그에 넣을 안전한 값 (치환 + 길이 제한, null > 빈 문자열)
 * 규칙 2개: 식별자(UUID 문자 외 > ?), 문장(제어문자 > ?)
 */
public final class LogValueSanitizer {

    // 식별자 허용 문자: 영문·숫자·하이픈 (UUID 형식)
    private static final String NON_IDENTIFIER_CHARACTER_PATTERN = "[^0-9A-Za-z-]";
    private static final String CONTROL_CHARACTER_PATTERN = "\\p{Cntrl}";
    private static final String REPLACEMENT = "?";

    private LogValueSanitizer() {
    }

    /** 식별자 정리: 앞에서 maxLength 자 > 영문·숫자·하이픈 외 ? */
    public static String toLogSafeIdentifier(String value, int maxLength) {
        return TextPreview.truncate(value, maxLength).replaceAll(NON_IDENTIFIER_CHARACTER_PATTERN, REPLACEMENT);
    }

    /** 문장 정리: 앞에서 maxLength 자 > 제어문자 ? (줄바꿈 로그 위조 차단) */
    public static String toLogSafeText(String value, int maxLength) {
        return TextPreview.truncate(value, maxLength).replaceAll(CONTROL_CHARACTER_PATTERN, REPLACEMENT);
    }
}
