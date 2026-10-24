package com.passql.application.statistics;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

/**
 * 관리자 통계 공통 조회 기간: 시작일·종료일(둘 다 포함), 직전 비교 기간 계산
 * 직전 기간: 달 전체(1일 ~ 말일·오늘)면 전월 같은 일수, 그 외는 바로 앞 같은 일수 (7일 > 전주)
 */
public record StatisticsPeriod(LocalDate fromDate, LocalDate toDate) {

    // 조회 가능한 최대 일수 (ai_call_log 보관 400일과 맞춤)
    public static final int MAX_DAY_COUNT = 400;

    /** 요청 기간 해석: 종료일 없으면 오늘, 시작일 없으면 종료일 기준 defaultDayCount 일, 미래 종료일은 오늘로 */
    public static StatisticsPeriod resolve(LocalDate requestedFromDate, LocalDate requestedToDate, int defaultDayCount) {
        LocalDate today = LocalDate.now();
        LocalDate toDate = requestedToDate == null || requestedToDate.isAfter(today) ? today : requestedToDate;
        LocalDate fromDate = requestedFromDate != null ? requestedFromDate : toDate.minusDays(defaultDayCount - 1L);
        if (fromDate.isAfter(toDate) || ChronoUnit.DAYS.between(fromDate, toDate) + 1 > MAX_DAY_COUNT) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "period must be 1 to " + MAX_DAY_COUNT + " days");
        }
        return new StatisticsPeriod(fromDate, toDate);
    }

    /** 조회 일수 (시작일·종료일 포함) */
    public long getDayCount() {
        return ChronoUnit.DAYS.between(fromDate, toDate) + 1;
    }

    /** 조회 시작 시각 (시작일 00:00, 포함) */
    public LocalDateTime getStartInclusive() {
        return fromDate.atStartOfDay();
    }

    /** 조회 끝 시각 (종료일 다음 날 00:00, 제외) */
    public LocalDateTime getEndExclusive() {
        return toDate.plusDays(1).atStartOfDay();
    }

    /** 비교용 직전 기간 */
    public StatisticsPeriod getPreviousPeriod() {
        if (isMonthFromFirstDay()) {
            LocalDate previousFromDate = fromDate.minusMonths(1);
            LocalDate previousMonthLastDate = previousFromDate.withDayOfMonth(previousFromDate.lengthOfMonth());
            LocalDate previousToDate = previousFromDate.plusDays(getDayCount() - 1);
            return new StatisticsPeriod(previousFromDate,
                    previousToDate.isAfter(previousMonthLastDate) ? previousMonthLastDate : previousToDate);
        }
        long dayCount = getDayCount();
        return new StatisticsPeriod(fromDate.minusDays(dayCount), fromDate.minusDays(1));
    }

    // 같은 달 안에서 1일부터 시작하는 기간 (이번 달 오늘까지, 지난달 전체)
    private boolean isMonthFromFirstDay() {
        return fromDate.getDayOfMonth() == 1
                && fromDate.getYear() == toDate.getYear()
                && fromDate.getMonth() == toDate.getMonth();
    }
}
