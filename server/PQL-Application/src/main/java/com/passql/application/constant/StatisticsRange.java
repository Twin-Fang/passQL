package com.passql.application.constant;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;

/**
 * 관리자 통계 그래프 범위: DAY 최근 30일(일별), MONTH 최근 12개월(월별)
 * 묶음 시작일 = 그 날 / 그 달 1일
 */
@Getter
@RequiredArgsConstructor
public enum StatisticsRange {

    DAY(30, "day", "MM/dd"),
    MONTH(12, "month", "yyyy.MM");

    // 기본 묶음 개수 (일 30개, 월 12개)
    private final int defaultBucketCount;
    // PostgreSQL date_trunc 단위
    private final String truncateUnit;
    // 그래프 라벨 형식
    private final String labelPattern;

    /** 날짜 > 속한 묶음 시작일 */
    public LocalDate toBucketStartDate(LocalDate date) {
        return this == DAY ? date : date.withDayOfMonth(1);
    }

    /** 묶음 시작일 > 다음 묶음 시작일 */
    public LocalDate toNextBucketStartDate(LocalDate bucketStartDate) {
        return this == DAY ? bucketStartDate.plusDays(1) : bucketStartDate.plusMonths(1);
    }

    /** 묶음 시작일 > count 묶음 이전 시작일 */
    public LocalDate minusBuckets(LocalDate bucketStartDate, int count) {
        return this == DAY ? bucketStartDate.minusDays(count) : bucketStartDate.minusMonths(count);
    }
}
