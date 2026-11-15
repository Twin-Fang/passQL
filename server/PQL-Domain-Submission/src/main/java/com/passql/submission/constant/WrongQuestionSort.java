package com.passql.submission.constant;

import com.passql.common.util.RequestEnumParser;

/** 오답 노트 정렬 2종: RECENT 최근 틀린 순, MOST_WRONG 많이 틀린 순 (#1081) */
public enum WrongQuestionSort {
    RECENT,
    MOST_WRONG;

    /** 요청값 > 정렬 (null·공백 > RECENT, 없는 값 > INVALID_INPUT_VALUE) */
    public static WrongQuestionSort fromRequestValue(String requestValue) {
        if (requestValue == null || requestValue.isBlank()) {
            return RECENT;
        }
        return RequestEnumParser.parse(WrongQuestionSort.class, requestValue);
    }
}
