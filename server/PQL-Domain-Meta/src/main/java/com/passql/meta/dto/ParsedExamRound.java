package com.passql.meta.dto;

import java.time.LocalDate;

/**
 * 공식 일정 표에서 읽은 SQLD 회차 1건 (#991, 시험일만 필수)
 */
public record ParsedExamRound(
        int round,
        LocalDate applicationStartDate,
        LocalDate applicationEndDate,
        LocalDate admissionTicketDate,
        LocalDate examDate,
        LocalDate preliminaryScoreStartDate,
        LocalDate preliminaryScoreEndDate,
        LocalDate resultAnnouncementDate
) {
}
