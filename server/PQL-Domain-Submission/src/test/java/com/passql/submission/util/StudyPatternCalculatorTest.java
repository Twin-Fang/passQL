package com.passql.submission.util;

import com.passql.submission.dto.HeatmapEntry;
import com.passql.submission.dto.RecentAttemptProjection;
import org.junit.jupiter.api.Test;

import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 학습 패턴 집계 (#909): 28일 날짜별 0 채움, 요일(월 0)·시간대 분포, 최장 연속
 */
class StudyPatternCalculatorTest {

    // 2026-11-07 토요일
    private static final LocalDate TODAY = LocalDate.of(2026, 11, 7);

    private static RecentAttemptProjection attempt(LocalDateTime submittedAt, boolean isCorrect) {
        return new RecentAttemptProjection(isCorrect, submittedAt);
    }

    @Test
    void 날짜별_기록은_오늘_포함_28일을_오래된_날부터_0으로_채우고_기간_밖은_뺀다() {
        List<RecentAttemptProjection> attempts = List.of(
            attempt(TODAY.atTime(9, 0), true),
            attempt(TODAY.atTime(21, 30), false),
            attempt(TODAY.minusDays(27).atTime(8, 0), true),
            attempt(TODAY.minusDays(28).atTime(8, 0), true));

        List<HeatmapEntry> records = StudyPatternCalculator.toDailyRecords(attempts, TODAY);

        assertThat(records).hasSize(28);
        assertThat(records.get(0)).isEqualTo(new HeatmapEntry(TODAY.minusDays(27), 1, 1));
        assertThat(records.get(27)).isEqualTo(new HeatmapEntry(TODAY, 2, 1));
        assertThat(records.get(1).solvedCount()).isZero();
    }

    @Test
    void 요일은_월요일부터_시간대는_0시부터_센다() {
        List<RecentAttemptProjection> attempts = List.of(
            attempt(LocalDateTime.of(2026, 11, 2, 0, 10), true),   // 월 0시
            attempt(LocalDateTime.of(2026, 11, 8, 23, 50), false), // 일 23시
            attempt(LocalDateTime.of(2026, 11, 8, 23, 5), true));  // 일 23시

        List<Integer> weekdayCounts = StudyPatternCalculator.toWeekdayAttemptCounts(attempts);
        List<Integer> hourCounts = StudyPatternCalculator.toHourAttemptCounts(attempts);

        assertThat(weekdayCounts).containsExactly(1, 0, 0, 0, 0, 0, 2);
        assertThat(hourCounts).hasSize(24);
        assertThat(hourCounts.get(0)).isEqualTo(1);
        assertThat(hourCounts.get(23)).isEqualTo(2);
    }

    @Test
    void 최장_연속은_끊긴_구간_중_가장_긴_것() {
        List<Date> dates = List.of(
            Date.valueOf(TODAY),
            Date.valueOf(TODAY.minusDays(5)),
            Date.valueOf(TODAY.minusDays(6)),
            Date.valueOf(TODAY.minusDays(7)),
            Date.valueOf(TODAY.minusDays(10)));

        assertThat(StreakCalculator.calculateLongest(dates)).isEqualTo(3);
        assertThat(StreakCalculator.calculateLongest(List.of())).isZero();
    }

    @Test
    void 요약은_앞뒤_절반_모두_5문제_이상일_때만_정답률_변화를_낸다() {
        List<HeatmapEntry> records = List.of(
            new HeatmapEntry(TODAY.minusDays(3), 5, 2),
            new HeatmapEntry(TODAY.minusDays(2), 0, 0),
            new HeatmapEntry(TODAY.minusDays(1), 10, 8),
            new HeatmapEntry(TODAY, 0, 0));

        StudyPatternCalculator.RecentStudySummary summary = StudyPatternCalculator.summarize(records);

        assertThat(summary.attemptCount()).isEqualTo(15);
        assertThat(summary.studyDayCount()).isEqualTo(2);
        assertThat(summary.accuracyChangePoints()).isEqualTo(80 - 40);
        assertThat(StudyPatternCalculator.summarize(List.of(
            new HeatmapEntry(TODAY.minusDays(1), 4, 4),
            new HeatmapEntry(TODAY, 10, 5))).accuracyChangePoints()).isNull();
    }

    @Test
    void 가장_많은_칸은_같으면_앞_칸이고_10문제_미만이면_판정하지_않는다() {
        assertThat(StudyPatternCalculator.busiestIndexOf(List.of(2, 5, 5, 0))).isEqualTo(1);
        assertThat(StudyPatternCalculator.busiestIndexOf(List.of(4, 5, 0))).isNull();
    }
}
