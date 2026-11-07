package com.passql.application.questionformat.dto;

import java.util.List;

/**
 * 형식 일괄 점검 결과 (#905): 점검 수(문제·세트·개념), 위반 문제 수, 사유별 건수, 위반 줄(사유 필터·표시 상한 적용)
 * shownRowCount < totalRowCount 면 화면에 일부만 보임
 */
public record QuestionFormatAuditReport(
        int scannedQuestionCount,
        int scannedChoiceSetCount,
        int scannedConceptCount,
        int violatingQuestionCount,
        List<QuestionFormatReasonCount> reasonCounts,
        int totalRowCount,
        List<QuestionFormatAuditRow> rows
) {

    public int getShownRowCount() {
        return rows.size();
    }
}
