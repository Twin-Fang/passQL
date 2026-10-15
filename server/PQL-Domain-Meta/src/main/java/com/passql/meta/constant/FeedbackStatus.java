package com.passql.meta.constant;

import com.passql.common.util.RequestEnumParser;

public enum FeedbackStatus {
    PENDING,    // 접수됨, 미확인 (노란 pill)
    REVIEWED,   // 팀에서 확인함 (인디고 pill)
    APPLIED;    // 반영됨 (초록 pill)

    /** 요청값 > FeedbackStatus (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static FeedbackStatus fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(FeedbackStatus.class, requestValue);
    }
}
