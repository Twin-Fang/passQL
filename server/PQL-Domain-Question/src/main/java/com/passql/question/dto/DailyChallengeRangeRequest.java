package com.passql.question.dto;

import java.time.LocalDate;

/**
 * 기간 일괄 자동 배정 요청: 시작일, 종료일 (양끝 포함, 최대 62일)
 */
public record DailyChallengeRangeRequest(
        LocalDate fromDate,
        LocalDate toDate
) {}
