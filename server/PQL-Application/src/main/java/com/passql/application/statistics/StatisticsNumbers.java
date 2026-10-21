package com.passql.application.statistics;

import java.util.ArrayList;
import java.util.List;

/**
 * 통계 숫자 정리: 비율(%), 나눗셈 반올림, 소수 자리 반올림, 누적 합
 * 분모 0 이면 0
 */
final class StatisticsNumbers {

    // 비용 표시 소수 자리 (USD, 하루 몇 센트 미만도 보이게 6자리)
    private static final double COST_USD_SCALE = 1_000_000d;
    // 비율·평균 표시 소수 자리 (1자리)
    private static final double ONE_DECIMAL_SCALE = 10d;

    private StatisticsNumbers() {
    }

    /** part / total × 100 (소수 1자리) */
    static double toPercent(long part, long total) {
        return total == 0 ? 0 : roundToOneDecimal(part * 100.0 / total);
    }

    /** part / total × 100 (소수 1자리, 실수 입력) */
    static double toPercent(double part, double total) {
        return total <= 0 ? 0 : roundToOneDecimal(part * 100.0 / total);
    }

    /** dividend / divisor 반올림 정수 */
    static long divideRounded(long dividend, long divisor) {
        return divisor == 0 ? 0 : Math.round(dividend / (double) divisor);
    }

    static double roundToOneDecimal(double value) {
        return Math.round(value * ONE_DECIMAL_SCALE) / ONE_DECIMAL_SCALE;
    }

    /** 비용 USD 소수 6자리 */
    static double roundCostUsd(double costUsd) {
        return Math.round(costUsd * COST_USD_SCALE) / COST_USD_SCALE;
    }

    /** 시작값 + 앞에서부터 누적 합 */
    static List<Long> toRunningTotals(long initialTotal, List<Long> increments) {
        List<Long> runningTotals = new ArrayList<>(increments.size());
        long runningTotal = initialTotal;
        for (Long increment : increments) {
            runningTotal += increment;
            runningTotals.add(runningTotal);
        }
        return runningTotals;
    }
}
