package com.passql.submission.dto.examanswer;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 총점 범위: 확정 안 된 문항(UNKNOWN·DISPUTED)을 모두 틀림(min) / 모두 맞음(max)으로 가정
 */
public record ExamAnswerScoreRangeResponse(
    @Schema(description = "최저 총점") int min,
    @Schema(description = "최고 총점") int max) {
}
