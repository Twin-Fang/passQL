package com.passql.submission.dto.mockexam;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 문항 답 저장: 고른 보기(null 이면 선택 해제)와 표시 여부 (둘 다 현재 값 그대로 보냄)
 */
public record MockExamAnswerSaveRequest(
    @Schema(nullable = true) String selectedChoiceKey,
    @Schema(nullable = true, description = "null 이면 false") Boolean isFlagged
) {
}
