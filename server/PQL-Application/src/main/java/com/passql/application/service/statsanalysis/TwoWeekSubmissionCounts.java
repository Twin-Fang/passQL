package com.passql.application.service.statsanalysis;

/** 2주 제출 집계: 이번 주 = 최근 7일, 지난주 = 8~14일 전 (제출 건수 기준) */
public record TwoWeekSubmissionCounts(long thisWeekCount, long thisWeekCorrectCount,
                                      long lastWeekCount, long lastWeekCorrectCount) {

    public static final TwoWeekSubmissionCounts EMPTY = new TwoWeekSubmissionCounts(0, 0, 0, 0);

    public boolean hasBothWeeks() {
        return thisWeekCount > 0 && lastWeekCount > 0;
    }

    public int thisWeekCorrectRatePercent() {
        return toPercent(thisWeekCorrectCount, thisWeekCount);
    }

    public int lastWeekCorrectRatePercent() {
        return toPercent(lastWeekCorrectCount, lastWeekCount);
    }

    private static int toPercent(long correctCount, long totalCount) {
        return totalCount == 0 ? 0 : (int) Math.round(correctCount * 100.0 / totalCount);
    }
}
