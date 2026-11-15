package com.passql.submission.dto.examanswer;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 과목 1개 채점 규칙 (번호 범위·만점·과락 기준)
 */
public record ExamAnswerSubjectRuleResponse(
    @Schema(description = "과목 번호 (1, 2)") int subjectNo,
    @Schema(description = "과목 이름") String subjectName,
    @Schema(description = "첫 문항 번호") int firstQuestionNo,
    @Schema(description = "마지막 문항 번호") int lastQuestionNo,
    @Schema(description = "과목 만점 (점)") int maxScore,
    @Schema(description = "과락 기준 점수 (미만이면 과락)") int failBelowScore) {
}
