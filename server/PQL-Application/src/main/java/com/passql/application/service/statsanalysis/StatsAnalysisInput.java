package com.passql.application.service.statsanalysis;

import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * 통계 AI 분석 판정 입력 7개: 토픽 수치(정렬 순서 유지), 전체 제출 수, 2주 집계, 시험까지 남은 일수(없으면 null), 마지막 시도 오답 문제 수, 반복 오답, 열 수 있는 개념 단원
 */
public record StatsAnalysisInput(
        List<TopicLearningStat> topicStats,
        long totalSolvedCount,
        TwoWeekSubmissionCounts twoWeekCounts,
        Integer daysUntilExam,
        long latestWrongQuestionCount,
        RepeatedWrongStat repeatedWrongStat,
        Set<UUID> conceptTopicUuids
) {
    /** 최근 7일 제출 수 */
    public long recentSolvedCount() {
        return twoWeekCounts.thisWeekCount();
    }
}
