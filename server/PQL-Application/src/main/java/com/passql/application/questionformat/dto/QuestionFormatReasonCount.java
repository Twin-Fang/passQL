package com.passql.application.questionformat.dto;

import com.passql.question.constant.QuestionFormatViolationReason;

/**
 * 사유별 위반 수 (#905): 사유, 전체 건수, 자동 정리 가능 건수
 */
public record QuestionFormatReasonCount(QuestionFormatViolationReason reason, long count, long autoFixableCount) {

    public String getDisplayName() {
        return reason.getDisplayName();
    }

    public int getRuleNumber() {
        return reason.getRuleNumber();
    }
}
