package com.passql.question.dto;

import com.passql.question.constant.QuestionFormatViolationReason;

/**
 * 문항 형식 위반 1건 (#905): 사유, 위치(지문 3줄·보기 B 근거 등), 설명, 자동 정리 가능 여부
 */
public record QuestionFormatViolation(
        QuestionFormatViolationReason reason,
        String location,
        String detail,
        Boolean isAutoFixable
) {

    /** 관리자 화면·오류 메시지 한 줄: [사유] 위치: 설명 */
    public String toDisplayLine() {
        return "[" + reason.getDisplayName() + "] " + location + ": " + detail;
    }

    public String getReasonDisplayName() {
        return reason.getDisplayName();
    }
}
