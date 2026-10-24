package com.passql.member.constant;

import com.passql.common.util.RequestEnumParser;

/** 제재 사유 분류 4종 (이름이 화면·이력과의 계약, 변경 금지) */
public enum SuspendReasonCategory {
    ABUSE("욕설·비방"),
    SPAM("광고·스팸"),
    CHEATING("부정 이용"),
    ETC("기타");

    // 관리자 화면 표시 이름
    private final String label;

    SuspendReasonCategory(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    /** 요청값 > SuspendReasonCategory (비면 null, 없는 값은 INVALID_INPUT_VALUE) */
    public static SuspendReasonCategory fromRequestValueOrNull(String requestValue) {
        if (requestValue == null || requestValue.isBlank()) {
            return null;
        }
        return RequestEnumParser.parse(SuspendReasonCategory.class, requestValue);
    }
}
