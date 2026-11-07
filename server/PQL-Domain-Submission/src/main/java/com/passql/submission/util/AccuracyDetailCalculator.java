package com.passql.submission.util;

import com.passql.submission.dto.AccuracyDetailResponse;
import com.passql.submission.dto.AccuracyDetailResponse.DifficultyStat;
import com.passql.submission.dto.AccuracyDetailResponse.WeeklyWrongCount;
import com.passql.submission.dto.QuestionAttemptRow;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * 정답률 상세 집계 (#909): 난이도별 정답률(문제별 마지막 시도), 오답 정리 현황, 주별 남은 오답
 * 남은 오답 = 틀린 적 있는 활성 문제 중 그 시점 마지막 시도가 오답 / 다시 맞힘 = 마지막 시도가 정답
 */
public final class AccuracyDetailCalculator {

    // 남은 오답 추이 주 수 (이번 주 포함)
    public static final int WRONG_TREND_WEEK_COUNT = 8;
    private static final int MINIMUM_DIFFICULTY = 1;
    private static final int MAXIMUM_DIFFICULTY = 5;
    // 정답률 반올림 자릿수 (둘째 자리, DEC-0024)
    private static final double RATE_ROUNDING_SCALE = 100.0;

    private AccuracyDetailCalculator() {
    }

    /** 전체 집계: rows 는 제출 시각 오름차순 (같은 시각은 제출 순) */
    public static AccuracyDetailResponse calculate(List<QuestionAttemptRow> rows, LocalDate today) {
        Map<UUID, Boolean> latestCorrectByActiveQuestion = new HashMap<>();
        Set<UUID> everWrongActiveQuestions = new HashSet<>();
        for (QuestionAttemptRow row : rows) {
            if (!Boolean.TRUE.equals(row.isQuestionActive())) {
                continue;
            }
            latestCorrectByActiveQuestion.put(row.questionUuid(), Boolean.TRUE.equals(row.isCorrect()));
            if (!Boolean.TRUE.equals(row.isCorrect())) {
                everWrongActiveQuestions.add(row.questionUuid());
            }
        }
        int clearedCount = (int) everWrongActiveQuestions.stream()
            .filter(latestCorrectByActiveQuestion::get)
            .count();
        return new AccuracyDetailResponse(
            toDifficultyStats(rows),
            everWrongActiveQuestions.size(),
            clearedCount,
            toRemainingWrongTrend(rows, today));
    }

    /** 난이도별 정답률: 문제별 마지막 시도, 푼 문제가 있는 단계만 (난이도 범위 밖은 가까운 끝값) */
    static List<DifficultyStat> toDifficultyStats(List<QuestionAttemptRow> rows) {
        Map<UUID, QuestionAttemptRow> latestByQuestion = new LinkedHashMap<>();
        for (QuestionAttemptRow row : rows) {
            latestByQuestion.put(row.questionUuid(), row);
        }
        int levelCount = MAXIMUM_DIFFICULTY - MINIMUM_DIFFICULTY + 1;
        int[] solvedCounts = new int[levelCount];
        int[] correctCounts = new int[levelCount];
        for (QuestionAttemptRow latest : latestByQuestion.values()) {
            int index = toClampedDifficulty(latest.difficulty()) - MINIMUM_DIFFICULTY;
            solvedCounts[index]++;
            if (Boolean.TRUE.equals(latest.isCorrect())) {
                correctCounts[index]++;
            }
        }
        List<DifficultyStat> stats = new ArrayList<>();
        for (int index = 0; index < levelCount; index++) {
            if (solvedCounts[index] == 0) {
                continue;
            }
            double rate = (double) correctCounts[index] / solvedCounts[index];
            stats.add(new DifficultyStat(index + MINIMUM_DIFFICULTY, solvedCounts[index],
                Math.round(rate * RATE_ROUNDING_SCALE) / RATE_ROUNDING_SCALE));
        }
        return stats;
    }

    /**
     * 주별 남은 오답: 최근 8주(월요일 시작, 오래된 주 먼저), 각 주 끝(다음 월요일 0시) 직전까지 다시 계산
     * 이번 주는 지금까지 / 활성 문제만
     */
    static List<WeeklyWrongCount> toRemainingWrongTrend(List<QuestionAttemptRow> rows, LocalDate today) {
        LocalDate thisWeekStart = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate firstWeekStart = thisWeekStart.minusWeeks(WRONG_TREND_WEEK_COUNT - 1L);
        Map<UUID, Boolean> latestCorrectByQuestion = new HashMap<>();
        List<WeeklyWrongCount> trend = new ArrayList<>(WRONG_TREND_WEEK_COUNT);
        int rowIndex = 0;
        for (int week = 0; week < WRONG_TREND_WEEK_COUNT; week++) {
            LocalDate weekStart = firstWeekStart.plusWeeks(week);
            LocalDateTime weekEndExclusive = weekStart.plusWeeks(1).atStartOfDay();
            // 이 주 끝 전까지의 제출을 반영 (rows 시간순이라 앞에서부터 한 번씩만)
            while (rowIndex < rows.size() && rows.get(rowIndex).submittedAt().isBefore(weekEndExclusive)) {
                QuestionAttemptRow row = rows.get(rowIndex++);
                if (Boolean.TRUE.equals(row.isQuestionActive())) {
                    latestCorrectByQuestion.put(row.questionUuid(), Boolean.TRUE.equals(row.isCorrect()));
                }
            }
            int remainingWrongCount = (int) latestCorrectByQuestion.values().stream()
                .filter(isCorrect -> !isCorrect)
                .count();
            trend.add(new WeeklyWrongCount(weekStart, remainingWrongCount));
        }
        return trend;
    }

    private static int toClampedDifficulty(int difficulty) {
        return Math.max(MINIMUM_DIFFICULTY, Math.min(MAXIMUM_DIFFICULTY, difficulty));
    }
}
