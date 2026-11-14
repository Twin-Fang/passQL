package com.passql.submission.dto.examanswer;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

/**
 * 관리자 가답안 회차 생성 (문항 50행 자동 생성)
 */
public record AdminExamAnswerRoundCreateRequest(
    @NotBlank String certType,
    @NotNull @Min(1) @Max(999) Integer roundNumber,
    @NotNull LocalDate examDate,
    @NotBlank @Size(max = 100) String title,
    String notice) {
}
