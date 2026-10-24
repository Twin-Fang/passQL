package com.passql.question.dto;

import java.time.LocalDate;

/**
 * 배정 복사 요청: 원본 날짜의 문제 목록을 대상 기간(양끝 포함, 최대 62일)에 그대로 복사
 * isOverwriteExisting: true 면 이미 배정된 날짜도 덮어쓰기, false/null 이면 건너뜀
 */
public record DailyChallengeCopyRequest(
        LocalDate sourceDate,
        LocalDate targetFromDate,
        LocalDate targetToDate,
        Boolean isOverwriteExisting
) {}
