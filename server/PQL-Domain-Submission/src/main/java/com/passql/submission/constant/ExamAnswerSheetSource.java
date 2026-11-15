package com.passql.submission.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 답안 제출 경로 2개: WEB 소개 사이트, APP 모바일 앱
 */
public enum ExamAnswerSheetSource {
    WEB,
    APP;

    /** 요청값 > 경로 (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static ExamAnswerSheetSource fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(ExamAnswerSheetSource.class, requestValue);
    }
}
