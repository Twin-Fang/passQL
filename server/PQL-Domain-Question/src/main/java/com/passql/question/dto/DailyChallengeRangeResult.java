package com.passql.question.dto;

/**
 * 기간 일괄 작업 결과: 배정(복사)한 날짜 수, 이미 배정돼 건너뛴 날짜 수
 */
public record DailyChallengeRangeResult(
        int processedDateCount,
        int skippedDateCount
) {}
