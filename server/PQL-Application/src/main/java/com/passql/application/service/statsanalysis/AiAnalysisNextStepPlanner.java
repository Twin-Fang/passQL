package com.passql.application.service.statsanalysis;

import com.passql.ai.constant.AiAnalysisActionType;
import com.passql.ai.dto.AiAnalysisAction;
import com.passql.ai.dto.AiAnalysisReadiness;
import com.passql.ai.dto.AiRepeatedWrong;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * 통계 AI 분석 "다음 할 일" (#861, #862): 데이터 부족 안내, 모두 안정권일 때 다음 목표, 반복 오답 문구, 바로 풀기 버튼(최대 2개)
 * 순수 규칙 (DB·LLM 없음). 버튼 문구에 문제 수를 넣지 않음 (앱·웹 이동 화면이 개수를 받지 않음)
 */
public final class AiAnalysisNextStepPlanner {

    // 응답 count 값: 토픽 풀기 권장 문제 수 (앱·웹 이동·문구에는 안 씀)
    static final int PRACTICE_COUNT = 5;
    // 오답 노트 버튼: 마지막 시도 오답 3문제 이상 또는 반복 오답 중 못 맞힌 문제 1개 이상, 응답 count 최대 5
    static final int REVIEW_WRONG_MIN_COUNT = 3;
    static final int REVIEW_WRONG_MAX_COUNT = 5;
    // 반복 오답 표시: 2번 이상 틀린 문제가 2개 이상일 때
    static final int REPEATED_WRONG_MIN_QUESTION_COUNT = 2;
    // 랜덤 풀기 응답 count (앱 랜덤 풀기 화면 기본 문제 수)
    static final int RANDOM_PRACTICE_COUNT = 10;

    static final String READINESS_MESSAGE = "토픽별 " + AiAnalysisPlanner.MIN_SOLVED_FOR_JUDGE
            + "문제씩 풀면 약점과 헷갈리는 개념을 짚어 드려요";
    static final String LATEST_TREND_GOAL = "최신 경향 문제로 실전 감각을 이어 가요";

    private AiAnalysisNextStepPlanner() {
    }

    /** 데이터 부족 진행 대상: 가장 많이 푼 토픽 (동률은 정렬 순서, 모두 0문제면 첫 토픽) */
    static Optional<TopicLearningStat> selectReadinessTopic(List<TopicLearningStat> topicStats) {
        TopicLearningStat mostSolvedTopic = null;
        for (TopicLearningStat stat : topicStats) {
            if (mostSolvedTopic == null || stat.solvedCount() > mostSolvedTopic.solvedCount()) {
                mostSolvedTopic = stat;
            }
        }
        return Optional.ofNullable(mostSolvedTopic);
    }

    /** 데이터 부족 안내: "지금 N/5" (N = 진행 대상 토픽 풀이 수) */
    static AiAnalysisReadiness toReadiness(Optional<TopicLearningStat> readinessTopic) {
        return new AiAnalysisReadiness(READINESS_MESSAGE,
                readinessTopic.map(stat -> AiAnalysisPlanner.toShortTopicName(stat.displayName())).orElse(null),
                readinessTopic.map(TopicLearningStat::solvedCount).orElse(0),
                AiAnalysisPlanner.MIN_SOLVED_FOR_JUDGE);
    }

    /** 데이터 부족 버튼: 랜덤 풀기 > 진행 대상 토픽 이어서 풀기 (0문제면 "부터 풀기") */
    static List<AiAnalysisAction> buildReadinessActions(Optional<TopicLearningStat> readinessTopic) {
        List<AiAnalysisAction> actions = new ArrayList<>();
        actions.add(new AiAnalysisAction(AiAnalysisActionType.RANDOM_PRACTICE, null, null,
                RANDOM_PRACTICE_COUNT, "랜덤으로 골고루 풀기"));
        readinessTopic.ifPresent(stat -> {
            String shortName = AiAnalysisPlanner.toShortTopicName(stat.displayName());
            String label = stat.solvedCount() > 0 ? shortName + " 이어서 풀기" : shortName + "부터 풀기";
            actions.add(new AiAnalysisAction(AiAnalysisActionType.PRACTICE_TOPIC, stat.topicUuid(), shortName,
                    PRACTICE_COUNT, label));
        });
        return actions;
    }

    /** 모두 안정권 다음 목표 대상: 아직 0문제인 첫 토픽 (없으면 최신 경향) */
    static Optional<TopicLearningStat> selectUntouchedTopic(List<TopicLearningStat> topicStats) {
        return topicStats.stream().filter(stat -> stat.solvedCount() == 0).findFirst();
    }

    /** 모두 안정권 다음 목표 문구 */
    static String toNextGoal(Optional<TopicLearningStat> untouchedTopic) {
        return untouchedTopic
                .map(stat -> "아직 안 푼 " + AiAnalysisPlanner.toShortTopicName(stat.displayName())
                        + "까지 풀면 출제 범위를 모두 덮어요")
                .orElse(LATEST_TREND_GOAL);
    }

    /**
     * 분석 버튼 최대 2개: 첫 처방(집중 토픽 풀기, 없으면 안 푼 토픽 시작·최신 경향) > 오답 노트
     * 오답 노트 조건: 마지막 시도 오답 3문제 이상 또는 반복 오답 중 못 맞힌 문제 있음
     */
    static List<AiAnalysisAction> buildActions(List<TopicLearningStat> focusTopics, Optional<TopicLearningStat> untouchedTopic,
                                               long latestWrongQuestionCount, RepeatedWrongStat repeatedWrongStat) {
        List<AiAnalysisAction> actions = new ArrayList<>();
        if (!focusTopics.isEmpty()) {
            actions.add(toPracticeTopicAction(focusTopics.get(0), " 문제 풀기"));
        } else if (untouchedTopic.isPresent()) {
            actions.add(toPracticeTopicAction(untouchedTopic.get(), " 시작하기"));
        } else {
            actions.add(new AiAnalysisAction(AiAnalysisActionType.PRACTICE_LATEST_TREND, null, null,
                    PRACTICE_COUNT, "최신 경향 문제 풀기"));
        }
        boolean hasUnresolvedRepeatedWrong = isRepeatedWrongShown(repeatedWrongStat) && repeatedWrongStat.unresolvedCount() > 0;
        if (latestWrongQuestionCount >= REVIEW_WRONG_MIN_COUNT || hasUnresolvedRepeatedWrong) {
            int reviewCount = (int) Math.min(Math.max(latestWrongQuestionCount, 1), REVIEW_WRONG_MAX_COUNT);
            String label = hasUnresolvedRepeatedWrong ? "반복 오답 다시 풀기" : "오답 노트에서 다시 풀기";
            actions.add(new AiAnalysisAction(AiAnalysisActionType.REVIEW_WRONG, null, null, reviewCount, label));
        }
        return actions;
    }

    /** 반복 오답 문구 (2문제 미만이면 null): "4문제를 2번 이상 틀렸고, 3문제는 아직 못 맞혔어요. 대부분 조인 문제예요" */
    static AiRepeatedWrong toRepeatedWrong(RepeatedWrongStat stat) {
        if (!isRepeatedWrongShown(stat)) {
            return null;
        }
        String countText = stat.questionCount() + "문제를 2번 이상 틀렸";
        String text = stat.unresolvedCount() > 0
                ? countText + "고, " + stat.unresolvedCount() + "문제는 아직 못 맞혔어요"
                : countText + "지만 지금은 모두 맞혔어요";
        if (stat.dominantTopicName() != null) {
            text += ". 대부분 " + AiAnalysisPlanner.toShortTopicName(stat.dominantTopicName()) + " 문제예요";
        }
        return new AiRepeatedWrong(stat.questionCount(), stat.unresolvedCount(), text);
    }

    private static boolean isRepeatedWrongShown(RepeatedWrongStat stat) {
        return stat.questionCount() >= REPEATED_WRONG_MIN_QUESTION_COUNT;
    }

    private static AiAnalysisAction toPracticeTopicAction(TopicLearningStat stat, String labelSuffix) {
        String shortName = AiAnalysisPlanner.toShortTopicName(stat.displayName());
        return new AiAnalysisAction(AiAnalysisActionType.PRACTICE_TOPIC, stat.topicUuid(), shortName,
                PRACTICE_COUNT, shortName + labelSuffix);
    }
}
