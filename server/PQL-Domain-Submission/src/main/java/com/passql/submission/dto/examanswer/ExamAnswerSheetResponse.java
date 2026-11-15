package com.passql.submission.dto.examanswer;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

/**
 * 내 답안 + 가채점 결과
 */
public record ExamAnswerSheetResponse(
    @Schema(description = "자격증 (SQLD)") String certType,
    @Schema(description = "회차 번호") int roundNumber,
    @Schema(description = "내 답 50자 (0 모름, 1~4)") String answers,
    @Schema(description = "제출 경로 WEB | APP") String source,
    @Schema(description = "마지막 제출 시각") LocalDateTime submittedAt,
    @Schema(description = "가채점 결과") ExamAnswerGradingResponse result) {
}
