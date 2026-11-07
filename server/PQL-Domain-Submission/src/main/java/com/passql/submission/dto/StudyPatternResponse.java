package com.passql.submission.dto;

import java.util.List;

/**
 * 학습 패턴 (#909, 무료): 최근 4주 날짜별 풀이·정답 수와 요약, 최근 12주 요일·시간대 분포와 가장 많은 칸, 전체 학습일·최장 연속
 * 풀이 수는 제출 횟수 기준 (같은 문제 다시 풀기도 1회씩, 히트맵과 같은 기준)
 * 판정(앞뒤 2주 비교 조건, 분포 최소 풀이 수)은 서버가 내리고 화면은 그대로 보여 줌
 */
public record StudyPatternResponse(
    int dailyWindowDays,
    List<HeatmapEntry> dailyRecords,
    int recentAttemptCount,
    int recentCorrectCount,
    int recentStudyDayCount,
    Integer accuracyChangePoints,
    int patternWindowDays,
    List<Integer> weekdayAttemptCounts,
    List<Integer> hourAttemptCounts,
    int patternAttemptCount,
    int minimumPatternAttemptCount,
    Integer busiestWeekdayIndex,
    Integer busiestHour,
    int totalStudyDayCount,
    int longestStreakDays
) {}
