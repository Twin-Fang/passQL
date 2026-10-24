package com.passql.meta.dto;

import jakarta.validation.constraints.NotBlank;

/** 시험 일정 일괄 등록 요청 (text: 한 줄에 "자격증 회차 시험일", 예: SQLD 63 2026-11-14) */
public record ExamScheduleBulkRequest(@NotBlank String text) {}
