package com.passql.common.util;

import java.util.Locale;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 회원 번호 표기: PQL- + 회원 UUID 앞 8자리 대문자 (예: PQL-9B22FE8A, 문의 때 회원 확인용)
 * 만들기(UUID > 회원 번호)와 읽기(회원 번호 > UUID 앞 8자리 소문자) 한 곳 (#929)
 */
public final class MemberCode {

    private static final String PREFIX = "PQL-";
    // 회원 번호 입력 형식: PQL- + 16진수 8자리 (대소문자 무관)
    private static final Pattern MEMBER_CODE_PATTERN =
            Pattern.compile("^PQL-([0-9a-f]{" + UuidUtils.SHORT_FORM_LENGTH + "})$", Pattern.CASE_INSENSITIVE);

    private MemberCode() {
    }

    /** 회원 UUID > 회원 번호 (PQL- + 앞 8자리 대문자) */
    public static String fromMemberUuid(UUID memberUuid) {
        return PREFIX + UuidUtils.toShortForm(memberUuid).toUpperCase(Locale.ROOT);
    }

    /** 입력 글 > UUID 앞 8자리 소문자 (회원 번호 형식 아님 > empty) */
    public static Optional<String> parseUuidPrefix(String text) {
        if (text == null) {
            return Optional.empty();
        }
        Matcher matcher = MEMBER_CODE_PATTERN.matcher(text.trim());
        return matcher.matches()
                ? Optional.of(matcher.group(1).toLowerCase(Locale.ROOT))
                : Optional.empty();
    }
}
