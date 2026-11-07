package com.passql.submission.dto;

import java.time.LocalDate;
import java.util.List;

/**
 * 정답률 상세 (#909, 프로): 난이도별 정답률, 오답 정리 현황, 주별 남은 오답 추이
 * 난이도별: 전체 기록, 문제별 마지막 시도 / 오답: 활성 문제만 (AI 분석 "아직 못 맞힌 문제"와 같은 기준)
 */
public record AccuracyDetailResponse(
    List<DifficultyStat> difficultyStats,
    int everWrongQuestionCount,
    int clearedWrongQuestionCount,
    List<WeeklyWrongCount> remainingWrongTrend
) {

    /** 난이도(1~5) 한 단계: 푼 문제 수(distinct), 정답률(0.0~1.0, 둘째 자리) */
    public record DifficultyStat(int difficulty, int solvedCount, double correctRate) {}

    /** 한 주(월요일 시작)가 끝난 시점의 남은 오답 수 (이번 주는 지금 기준) */
    public record WeeklyWrongCount(LocalDate weekStartDate, int remainingWrongCount) {}
}
