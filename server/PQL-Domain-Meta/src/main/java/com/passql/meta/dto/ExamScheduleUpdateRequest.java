package com.passql.meta.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

/** 시험 일정 수정 요청 (회차·시험일, 자격증 종류는 바꾸지 않음) */
public record ExamScheduleUpdateRequest(
        @NotNull @Min(1) Integer round,
        @NotNull LocalDate examDate
) {}
