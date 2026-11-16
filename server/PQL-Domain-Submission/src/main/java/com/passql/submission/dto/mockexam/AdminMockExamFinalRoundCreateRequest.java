package com.passql.submission.dto.mockexam;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * 관리자 FINAL 회차 생성 (#1084): 대상 시험일·제목 + 문제 50개 (순서 = 시험 번호, 1~10 1과목)
 * 회차 번호는 FINAL 순번 자동, 공개 후 시험일 3일 전부터 회원에게 보임
 */
public record AdminMockExamFinalRoundCreateRequest(
    @NotNull LocalDate examDate,
    @NotBlank @Size(max = 100) String title,
    @NotNull List<UUID> questionUuids) {
}
