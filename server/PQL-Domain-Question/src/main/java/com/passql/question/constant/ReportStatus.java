package com.passql.question.constant;

import com.passql.common.util.RequestEnumParser;

public enum ReportStatus {
    PENDING,   // 미처리
    RESOLVED,  // 처리완료 (보정·비활성화 반영)
    DISMISSED; // 기각 (문제 없음, 보정 안 함, #479)

    /** 요청값 > ReportStatus (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static ReportStatus fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(ReportStatus.class, requestValue);
    }
}
