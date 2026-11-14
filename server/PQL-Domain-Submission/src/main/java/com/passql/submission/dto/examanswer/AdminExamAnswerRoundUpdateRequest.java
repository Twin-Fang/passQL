package com.passql.submission.dto.examanswer;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

/**
 * 관리자 가답안 회차 정보 수정 (제목·시험일·상태·안내)
 */
public record AdminExamAnswerRoundUpdateRequest(
    @NotBlank @Size(max = 100) String title,
    @NotNull LocalDate examDate,
    @NotBlank String status,
    String notice) {
}
