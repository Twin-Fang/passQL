package com.passql.submission.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 가답안 회차 상태 3개: COLLECTING 수집 중, OFFICIAL 공식 정답 반영, CLOSED 마감(조회만, 답안 제출 거부)
 */
public enum ExamAnswerRoundStatus {
    COLLECTING,
    OFFICIAL,
    CLOSED;

    /** 요청값 > 상태 (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static ExamAnswerRoundStatus fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(ExamAnswerRoundStatus.class, requestValue);
    }
}
