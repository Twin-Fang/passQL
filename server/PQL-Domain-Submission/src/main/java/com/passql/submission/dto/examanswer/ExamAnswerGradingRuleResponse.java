package com.passql.submission.dto.examanswer;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * 가채점 규칙 (SQLD: 50문항 2점, 60점 합격, 과목 40% 미만 과락), 클라이언트는 숫자를 복사하지 않고 이 값을 표시
 */
public record ExamAnswerGradingRuleResponse(
    @Schema(description = "전체 문항 수") int totalQuestionCount,
    @Schema(description = "문항당 배점 (점)") int pointsPerQuestion,
    @Schema(description = "만점 (점)") int maxScore,
    @Schema(description = "합격 총점 (점, 이상)") int passScore,
    @Schema(description = "과락 기준 (과목 만점 대비 %, 미만이면 과락)") int subjectFailBelowPercent,
    @Schema(description = "과목별 규칙") List<ExamAnswerSubjectRuleResponse> subjects) {
}
