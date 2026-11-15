package com.passql.submission.dto.examanswer;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 과목 1개 가채점 점수 (표시용 정답 기준)
 */
public record ExamAnswerSubjectScoreResponse(
    @Schema(description = "과목 점수") int score,
    @Schema(description = "과목 만점") int max,
    @Schema(description = "과락 여부 (40% 미만)") boolean isFailCut) {
}
