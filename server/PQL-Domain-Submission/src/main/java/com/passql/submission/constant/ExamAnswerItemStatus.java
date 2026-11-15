package com.passql.submission.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 문항 운영 가답안 상태 5개: UNKNOWN 모름, LEADING 우세, DISPUTED 갈림, CONFIRMED 확정, OFFICIAL 공식
 * LEADING·CONFIRMED·OFFICIAL 은 운영 가답안으로 표시·확정 채점, DISPUTED 는 후보 답 표시 + 점수 범위, UNKNOWN 은 득표 1위 표시 + 점수 범위
 */
public enum ExamAnswerItemStatus {
    UNKNOWN,
    LEADING,
    DISPUTED,
    CONFIRMED,
    OFFICIAL;

    /** 운영 가답안을 표시용 정답으로 쓰는 상태인지 */
    public boolean isOperatorAnswerTrusted() {
        return this == LEADING || this == CONFIRMED || this == OFFICIAL;
    }

    /** 확정은 아니지만 운영 후보 답을 표시용 정답으로 보여 주는 상태인지 (갈림, #1101) */
    public boolean isOperatorCandidateShown() {
        return this == DISPUTED;
    }

    /** 요청값 > 상태 (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static ExamAnswerItemStatus fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(ExamAnswerItemStatus.class, requestValue);
    }
}
