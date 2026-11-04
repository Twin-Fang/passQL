package com.passql.common.util;

/**
 * 이메일 가림 표기: 아이디 앞 2자 + *** + @도메인 (예: sqld.pass@kakao.com > sq***@kakao.com)
 * 형식이 아니면(빈 값, @ 없음, 아이디·도메인 비어 있음) null
 */
public final class EmailMasking {

    // 아이디에서 보여 주는 앞 글자 수
    private static final int VISIBLE_LOCAL_PART_LENGTH = 2;
    private static final String MASK = "***";
    private static final char DOMAIN_SEPARATOR = '@';

    private EmailMasking() {
    }

    /** 이메일 > 가린 표기 (형식 아님 > null) */
    public static String mask(String email) {
        if (email == null || email.isBlank()) {
            return null;
        }
        String trimmedEmail = email.trim();
        int separatorIndex = trimmedEmail.lastIndexOf(DOMAIN_SEPARATOR);
        if (separatorIndex <= 0 || separatorIndex == trimmedEmail.length() - 1) {
            return null;
        }
        String localPart = trimmedEmail.substring(0, separatorIndex);
        String domain = trimmedEmail.substring(separatorIndex + 1);
        String visiblePart = localPart.substring(0, Math.min(VISIBLE_LOCAL_PART_LENGTH, localPart.length()));
        return visiblePart + MASK + DOMAIN_SEPARATOR + domain;
    }
}
