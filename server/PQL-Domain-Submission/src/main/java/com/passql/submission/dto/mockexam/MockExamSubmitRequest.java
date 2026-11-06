package com.passql.submission.dto.mockexam;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * 제출: 기기에 남은 답 묶음 (저장 실패분 보강용, 마감 + 유예 안에 도착했을 때만 반영). 비어도 됨
 */
public record MockExamSubmitRequest(
    @Schema(nullable = true) List<AnswerEntry> answers
) {

    public record AnswerEntry(int questionNumber, @Schema(nullable = true) String selectedChoiceKey,
                              @Schema(nullable = true) Boolean isFlagged) {
    }
}
