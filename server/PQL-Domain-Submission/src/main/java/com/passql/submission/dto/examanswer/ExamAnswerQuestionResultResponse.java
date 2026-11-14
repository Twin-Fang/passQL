package com.passql.submission.dto.examanswer;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 문항 1개 채점 결과
 */
public record ExamAnswerQuestionResultResponse(
    @Schema(description = "문항 번호") int questionNo,
    @Schema(description = "내 답 (0 모름, 1~4)") int myAnswer,
    @Schema(description = "표시용 정답 (없으면 null)") Integer answer,
    @Schema(description = "정답 여부 (복수 정답 인정 포함, 표시용 정답 없으면 null)") Boolean isCorrect) {
}
