package com.passql.question.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 관리자 문제 목록 정렬 (값 없으면 NEWEST)
 */
public enum AdminQuestionSortType {
    NEWEST("최신 등록순"),
    ACCURACY_ASCENDING("정답률 낮은 순 (풀이 있는 문제만)"),
    SOLVE_COUNT_DESCENDING("풀이 많은 순"),
    REPORT_COUNT_DESCENDING("신고 많은 순");

    // 화면 표시 이름
    private final String label;

    AdminQuestionSortType(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    /** 풀이·신고 집계로 정렬하는지 (NEWEST 는 createdAt 정렬) */
    public boolean isQualitySort() {
        return this != NEWEST;
    }

    /** 요청값 > 정렬 (null·공백 > NEWEST, 없는 값 > INVALID_INPUT_VALUE) */
    public static AdminQuestionSortType fromRequestValueOrNewest(String requestValue) {
        if (requestValue == null || requestValue.isBlank()) {
            return NEWEST;
        }
        return RequestEnumParser.parse(AdminQuestionSortType.class, requestValue);
    }
}
