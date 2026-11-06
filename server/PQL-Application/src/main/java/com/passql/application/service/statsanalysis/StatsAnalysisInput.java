package com.passql.application.service.statsanalysis;

import java.util.List;

/**
 * 통계 AI 분석 판정 입력: 토픽 수치(정렬 순서 유지), 전체 제출 수, 2주 집계, 시험까지 남은 일수, 마지막 시도 오답 문제 수
 * daysUntilExam 은 다가오는 시험 없으면 null
 */
public record StatsAnalysisInput(
        List<TopicLearningStat> topicStats,
        long totalSolvedCount,
        TwoWeekSubmissionCounts twoWeekCounts,
        Integer daysUntilExam,
        long latestWrongQuestionCount
) {
    /** 최근 7일 제출 수 */
    public long recentSolvedCount() {
        return twoWeekCounts.thisWeekCount();
    }
}
