package com.passql.common.util;

import java.util.UUID;

/**
 * UUID 표기 변환: 짧은 표기(앞 8자리)
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
}
