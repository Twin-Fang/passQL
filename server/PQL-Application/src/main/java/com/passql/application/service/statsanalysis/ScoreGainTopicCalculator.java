package com.passql.application.service.statsanalysis;

import com.passql.ai.dto.AiScoreGainTopic;
import com.passql.submission.service.MockExamRule;

import java.util.Comparator;
import java.util.List;

/**
 * 점수 올리기 좋은 영역 (#1111): 토픽별 기대 상승 점수 > 큰 순 상위 3개
 * 기대 상승 점수 = 시험 출제 문항 수 × (안정권 정답률 − 내 정답률) × 문항당 점수. 순수 규칙 (DB 없음)
 */
public final class ScoreGainTopicCalculator {

    // 목표 정답률: 통계 AI 분석 안정권 시작 (AiAnalysisPlanner 불안정 기준과 같은 값)
    static final double TARGET_CORRECT_RATE = AiAnalysisPlanner.SHAKY_RATE_THRESHOLD;
    static final int TARGET_CORRECT_RATE_PERCENT = (int) Math.round(TARGET_CORRECT_RATE * 100);
    // 근거 최소 풀이 수: 통계 AI 분석 판정 기준과 같은 값 (미만이면 정답률을 믿지 않음)
    static final int MIN_SOLVED_COUNT = AiAnalysisPlanner.MIN_SOLVED_FOR_JUDGE;
    // 보여 줄 최대 영역 수
    static final int MAX_TOPIC_COUNT = 3;
    // 표시 최소 상승 점수 (점, 이보다 작으면 의미 없는 차이라 뺌)
    static final double MIN_GAIN_SCORE = 0.5;

    private ScoreGainTopicCalculator() {
    }

    /** 토픽 수치 > 기대 상승 점수 큰 순 최대 3개 (동률은 토픽 정렬 순서, 근거 부족이면 빈 목록) */
    public static List<AiScoreGainTopic> selectTopTopics(List<TopicLearningStat> topicStats) {
        return topicStats.stream()
                .filter(ScoreGainTopicCalculator::hasEnoughEvidence)
                .map(stat -> new AiScoreGainTopic(stat.topicUuid(), AiAnalysisPlanner.toShortTopicName(stat.displayName()),
                        stat.correctRatePercent(), TARGET_CORRECT_RATE_PERCENT, stat.examQuestionCount(),
                        roundToOneDecimal(expectedGainScoreOf(stat))))
                .filter(topic -> topic.expectedGainScore() >= MIN_GAIN_SCORE)
                .sorted(Comparator.comparingDouble(AiScoreGainTopic::expectedGainScore).reversed())
                .limit(MAX_TOPIC_COUNT)
                .toList();
    }

    /** 출제 문항 수 × (목표 − 내 정답률) × 문항당 점수 (목표 넘었으면 0) */
    static double expectedGainScoreOf(TopicLearningStat stat) {
        double rateGap = Math.max(0.0, TARGET_CORRECT_RATE - stat.correctRate());
        return stat.examQuestionCount() * rateGap * MockExamRule.POINTS_PER_QUESTION;
    }

    private static boolean hasEnoughEvidence(TopicLearningStat stat) {
        return stat.examQuestionCount() > 0 && stat.solvedCount() >= MIN_SOLVED_COUNT;
    }

    private static double roundToOneDecimal(double value) {
        return Math.round(value * 10) / 10.0;
    }
}
