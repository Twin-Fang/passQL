package com.passql.question.constant;

import com.passql.common.util.RequestEnumParser;

/** 관리자 글 처리 동작 4종 (URL 경로 값 = 소문자 이름) */
public enum CommunityModerationAction {
    HIDE,
    RESTORE,
    DELETE,
    DISMISS;

    /** 경로 값(hide, restore, delete, dismiss) > 동작 (없는 값 > INVALID_INPUT_VALUE) */
    public static CommunityModerationAction fromPathValue(String pathValue) {
        return RequestEnumParser.parse(CommunityModerationAction.class, pathValue == null ? null : pathValue.toUpperCase());
    }
}
