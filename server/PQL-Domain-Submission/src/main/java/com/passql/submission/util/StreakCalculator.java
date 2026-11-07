package com.passql.submission.util;

import com.passql.common.util.ServiceTimeZone;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

public final class StreakCalculator {

    private StreakCalculator() {}

    /**
     * 제출 날짜 목록(내림차순)으로 연속 학습 일수를 계산한다.
     * 하루 그레이스 정책: 오늘 미제출이어도 어제까지 연속이면 streak 유지.
     *
     * @param dates DESC 정렬된 distinct 날짜 목록 (findSubmissionDatesByMemberUuid 쿼리가 보장)
     * @return 연속 학습 일수
     */
    public static int calculate(List<Date> dates) {
        if (dates == null || dates.isEmpty()) {
            return 0;
        }
        // KST 기준 오늘 날짜 (JVM 기본 타임존과 무관하게 명시)
        LocalDate today = LocalDate.now(ServiceTimeZone.ZONE);
        int streak = 0;
        LocalDate expected = today;
        boolean started = false;
        for (Date d : dates) {
            LocalDate ld = d.toLocalDate();
            if (!started) {
                if (ld.equals(today) || ld.equals(today.minusDays(1))) {
                    streak = 1;
                    expected = ld.minusDays(1);
                    started = true;
                } else {
                    return 0;
                }
            } else {
                if (ld.equals(expected)) {
                    streak++;
                    expected = expected.minusDays(1);
                } else if (ld.isBefore(expected)) {
                    break;
                }
            }
        }
        return streak;
    }

    /**
     * 지금까지 가장 길게 이어진 연속 학습 일수 (#909)
     *
     * @param dates distinct 날짜 목록 (정렬 무관)
     */
    public static int calculateLongest(List<Date> dates) {
        if (dates == null || dates.isEmpty()) {
            return 0;
        }
        List<LocalDate> sortedDates = dates.stream().map(Date::toLocalDate).distinct().sorted().toList();
        int longest = 1;
        int current = 1;
        for (int index = 1; index < sortedDates.size(); index++) {
            boolean isNextDay = sortedDates.get(index - 1).plusDays(1).equals(sortedDates.get(index));
            current = isNextDay ? current + 1 : 1;
            longest = Math.max(longest, current);
        }
        return longest;
    }
}
