package com.passql.submission.dto.mockexam;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * 관리자 기출 복원 회차 생성 (#1079): 실제 시험 회차 번호·시험일·제목 + 문제 50개 (순서 = 시험 번호)
 */
public record AdminMockExamPastRoundCreateRequest(
    @NotNull @Min(1) @Max(999) Integer examRoundNumber,
    @NotNull LocalDate examDate,
    @NotBlank @Size(max = 100) String title,
    @NotNull List<UUID> questionUuids) {
}
