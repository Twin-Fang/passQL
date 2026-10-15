package com.passql.question.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 관리자 문제 목록 활성 여부 필터 (값 없으면 ACTIVE: 기존 목록과 같은 기본값)
 */
public enum QuestionActiveFilter {
    ACTIVE,    // 활성 문제만
    INACTIVE,  // 비활성(삭제 처리)된 문제만, 복구 대상
    ALL;       // 전체

    /** 요청값 > 필터 (null·공백 > ACTIVE, 없는 값 > INVALID_INPUT_VALUE) */
    public static QuestionActiveFilter fromRequestValueOrActive(String requestValue) {
        if (requestValue == null || requestValue.isBlank()) {
            return ACTIVE;
        }
        return RequestEnumParser.parse(QuestionActiveFilter.class, requestValue);
    }
}
