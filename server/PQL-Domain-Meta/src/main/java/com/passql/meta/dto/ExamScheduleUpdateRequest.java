package com.passql.meta.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

/**
 * 시험 일정 수정 요청 (회차·시험일 필수, 나머지 일정은 비우면 null, 자격증 종류는 바꾸지 않음)
 * isManualLocked: true 면 자동 수집이 이 회차를 덮어쓰지 않음 (#991, null 이면 기존 값 유지)
 */
public record ExamScheduleUpdateRequest(
        @NotNull @Min(1) Integer round,
        @NotNull LocalDate examDate,
        LocalDate applicationStartDate,
        LocalDate applicationEndDate,
        LocalDate admissionTicketDate,
        LocalDate preliminaryScoreStartDate,
        LocalDate preliminaryScoreEndDate,
        LocalDate resultAnnouncementDate,
        Boolean isManualLocked
) {}
