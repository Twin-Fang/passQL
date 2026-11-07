package com.passql.submission.util;

import com.passql.submission.dto.HeatmapEntry;
import com.passql.submission.dto.RecentAttemptProjection;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * 학습 패턴 집계 (#909): 날짜별 풀이·정답 수, 요일별·시간대별 풀이 수
 * 입력 시각은 KST 로컬 저장값 그대로 (submitted_at, #560)
 */
public final class StudyPatternCalculator {

    // 날짜별 기록 기간 (일, 4주)
    public static final int DAILY_WINDOW_DAYS = 28;
    // 요일·시간대 분포 기간 (일, 12주)
    public static final int PATTERN_WINDOW_DAYS = 84;
    // 요일·시간대 가장 많은 칸을 판정할 최소 풀이 수 (그보다 적으면 우연에 가까움)
    public static final int MINIMUM_PATTERN_ATTEMPT_COUNT = 10;
    // 앞 2주 <-> 뒤 2주 정답률 비교에 필요한 각 구간 최소 풀이 수
    private static final int MINIMUM_HALF_ATTEMPT_COUNT_FOR_TREND = 5;
    private static final int PERCENT = 100;
    private static final int WEEKDAY_COUNT = 7;
    private static final int HOUR_COUNT = 24;

    private StudyPatternCalculator() {
    }

    /** 날짜별 풀이·정답 수: 오늘 포함 최근 28일, 오래된 날 먼저, 기록 없는 날은 0 */
    public static List<HeatmapEntry> toDailyRecords(List<RecentAttemptProjection> attempts, LocalDate today) {
        LocalDate firstDate = today.minusDays(DAILY_WINDOW_DAYS - 1L);
        int[] attemptCounts = new int[DAILY_WINDOW_DAYS];
        int[] correctCounts = new int[DAILY_WINDOW_DAYS];
        for (RecentAttemptProjection attempt : attempts) {
            LocalDate date = attempt.submittedAt().toLocalDate();
            if (date.isBefore(firstDate) || date.isAfter(today)) {
                continue;
            }
            int index = (int) (date.toEpochDay() - firstDate.toEpochDay());
            attemptCounts[index]++;
            if (Boolean.TRUE.equals(attempt.isCorrect())) {
                correctCounts[index]++;
            }
        }
        List<HeatmapEntry> records = new ArrayList<>(DAILY_WINDOW_DAYS);
        for (int index = 0; index < DAILY_WINDOW_DAYS; index++) {
            records.add(new HeatmapEntry(firstDate.plusDays(index), attemptCounts[index], correctCounts[index]));
        }
        return records;
    }

    /** 요일별 풀이 수 (월 0 ~ 일 6) */
    public static List<Integer> toWeekdayAttemptCounts(List<RecentAttemptProjection> attempts) {
        int[] counts = new int[WEEKDAY_COUNT];
        for (RecentAttemptProjection attempt : attempts) {
            counts[attempt.submittedAt().getDayOfWeek().getValue() - 1]++;
        }
        return toList(counts);
    }

    /** 시간대별 풀이 수 (0시 ~ 23시) */
    public static List<Integer> toHourAttemptCounts(List<RecentAttemptProjection> attempts) {
        int[] counts = new int[HOUR_COUNT];
        for (RecentAttemptProjection attempt : attempts) {
            counts[attempt.submittedAt().getHour()]++;
        }
        return toList(counts);
    }

    /** 날짜별 기록 요약: 풀이·정답 수, 공부한 날, 앞 절반 대비 뒤 절반 정답률 변화(%p, 각 절반 5문제 미만이면 null) */
    public static RecentStudySummary summarize(List<HeatmapEntry> dailyRecords) {
        int half = dailyRecords.size() / 2;
        int earlierAttempts = 0;
        int earlierCorrect = 0;
        int laterAttempts = 0;
        int laterCorrect = 0;
        int studyDayCount = 0;
        for (int index = 0; index < dailyRecords.size(); index++) {
            HeatmapEntry record = dailyRecords.get(index);
            if (record.solvedCount() > 0) {
                studyDayCount++;
            }
            if (index < half) {
                earlierAttempts += record.solvedCount();
                earlierCorrect += record.correctCount();
            } else {
                laterAttempts += record.solvedCount();
                laterCorrect += record.correctCount();
            }
        }
        boolean canCompare = earlierAttempts >= MINIMUM_HALF_ATTEMPT_COUNT_FOR_TREND
            && laterAttempts >= MINIMUM_HALF_ATTEMPT_COUNT_FOR_TREND;
        Integer accuracyChangePoints = canCompare
            ? toPercent(laterCorrect, laterAttempts) - toPercent(earlierCorrect, earlierAttempts)
            : null;
        return new RecentStudySummary(earlierAttempts + laterAttempts, earlierCorrect + laterCorrect,
            studyDayCount, accuracyChangePoints);
    }

    /** 가장 많이 푼 칸 (같으면 앞 칸), 전체 풀이가 최소 미만이면 null */
    public static Integer busiestIndexOf(List<Integer> counts) {
        int total = counts.stream().mapToInt(Integer::intValue).sum();
        if (total < MINIMUM_PATTERN_ATTEMPT_COUNT) {
            return null;
        }
        int busiestIndex = 0;
        for (int index = 1; index < counts.size(); index++) {
            if (counts.get(index) > counts.get(busiestIndex)) {
                busiestIndex = index;
            }
        }
        return busiestIndex;
    }

    /** 최근 기록 요약 값 */
    public record RecentStudySummary(int attemptCount, int correctCount, int studyDayCount,
                                     Integer accuracyChangePoints) {}

    private static int toPercent(int part, int whole) {
        return (int) Math.round((double) part * PERCENT / whole);
    }

    private static List<Integer> toList(int[] counts) {
        List<Integer> values = new ArrayList<>(counts.length);
        for (int count : counts) {
            values.add(count);
        }
        return Collections.unmodifiableList(values);
    }
}
