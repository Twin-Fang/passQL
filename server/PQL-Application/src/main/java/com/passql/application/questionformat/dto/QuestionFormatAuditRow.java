package com.passql.application.questionformat.dto;

import com.passql.question.constant.QuestionFormatViolationReason;

import java.util.UUID;

/**
 * 형식 점검 위반 1줄 (#905): 대상 종류·식별자·미리보기·바로 가기 경로·모의고사 위치, 위반 위치·사유·설명·자동 정리 가능 여부
 */
public record QuestionFormatAuditRow(
        String targetTypeLabel,
        UUID targetUuid,
        String targetPreview,
        String linkPath,
        String mockExamLabel,
        String location,
        QuestionFormatViolationReason reason,
        String detail,
        Boolean isAutoFixable
) {

    public String getReasonDisplayName() {
        return reason.getDisplayName();
    }
}
