package com.passql.question.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 관리자 신고 목록 정렬 기준 (값 없으면 REPORT_COUNT_DESC)
 */
public enum ReportSummarySort {
    REPORT_COUNT_DESC,   // 신고 많은 순
    PENDING_COUNT_DESC,  // 미처리 많은 순
    LATEST_DESC;         // 최근 신고 순

    /** 요청값 > 정렬 (null·공백 > REPORT_COUNT_DESC, 없는 값 > INVALID_INPUT_VALUE) */
    public static ReportSummarySort fromRequestValueOrDefault(String requestValue) {
        if (requestValue == null || requestValue.isBlank()) {
            return REPORT_COUNT_DESC;
        }
        return RequestEnumParser.parse(ReportSummarySort.class, requestValue);
    }
}
