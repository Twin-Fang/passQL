package com.passql.common.util;

import java.util.Optional;
import java.util.UUID;

/**
 * UUID 표기 변환: 짧은 표기(앞 8자리), 문자열 > UUID 파싱
 */
public final class UuidUtils {

    // 짧은 표기 길이 (UUID 첫 구간 16진수 8자리, 하이픈 없음)
    public static final int SHORT_FORM_LENGTH = 8;

    private UuidUtils() {
    }

    /** UUID > 앞 8자리 (예: 3f2a9c1e-... > 3f2a9c1e), 로그·임시 이름·표시용 */
    public static String toShortForm(UUID uuid) {
        return uuid.toString().substring(0, SHORT_FORM_LENGTH);
    }

    /** 문자열 > UUID (null·형식 오류 > empty, 앞뒤 공백 정리는 호출부 책임) */
    public static Optional<UUID> parseOrEmpty(String text) {
        if (text == null) {
            return Optional.empty();
        }
        try {
            return Optional.of(UUID.fromString(text));
        } catch (IllegalArgumentException invalidUuidFormat) {
            return Optional.empty();
        }
    }
}
