package com.passql.question.dto;

import java.util.List;

/**
 * 문제 상세 품질 요약: 풀이·정답·신고 수 + 보기 키별 선택 분포
 * accuracyPercent 는 풀이 0건이면 null
 */
public record AdminQuestionQualityDetail(
        long solveCount,
        long correctCount,
        Double accuracyPercent,
        long reportCount,
        long pendingReportCount,
        List<ChoiceSelection> choiceSelections
) {
    /** 보기 키 1개: 선택 수, 그중 정답 처리 수, 전체 풀이 대비 선택 비율(%) */
    public record ChoiceSelection(String choiceKey, long selectedCount, long correctCount, double selectedPercent) {}
}
