package com.passql.application.service.statsanalysis;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 결과 화면 세션 코멘트 서버 판정 (#862): 세션 점수 > 가장 많이 놓친 토픽 > 그 토픽 최근 90일 판정 문장
 * 순수 규칙 (DB·LLM 없음). LLM 은 놓친 문제로 "무엇을 헷갈렸는지" 한 문장만 따로 붙임
 */
public final class SessionCommentPlanner {

    static final String NO_SESSION_RESULT = "이번 풀이 기록을 찾지 못했어요";

    private SessionCommentPlanner() {
    }

    /** 세션 제출 1건 (topicName 은 전체 표시 이름) */
    public record SessionResult(String topicName, boolean isCorrect) {}

    /** 판정 결과: 서버 문장들 + LLM 에 넘길 집중 토픽 (오답 없으면 LLM 호출 없음) */
    public record SessionCommentPlan(List<String> sentences, String focusTopicName, int wrongCount) {

        public boolean hasWrongAnswers() {
            return wrongCount > 0;
        }
    }

    /** 세션 결과 + 최근 90일 토픽 수치 > 서버 문장 (점수 > 놓친 토픽 > 토픽 판정) */
    public static SessionCommentPlan plan(List<SessionResult> sessionResults, List<TopicLearningStat> topicStats) {
        if (sessionResults.isEmpty()) {
            return new SessionCommentPlan(List.of(NO_SESSION_RESULT), null, 0);
        }
        int totalCount = sessionResults.size();
        int wrongCount = (int) sessionResults.stream().filter(result -> !result.isCorrect()).count();
        Map<String, Integer> wrongCountByTopic = countWrongByTopic(sessionResults);
        // 집중 토픽: 가장 많이 놓친 토픽 (동률은 먼저 푼 순), 다 맞혔으면 첫 토픽
        String focusTopicName = wrongCountByTopic.entrySet().stream()
                .filter(entry -> entry.getValue() > 0)
                .reduce((first, second) -> second.getValue() > first.getValue() ? second : first)
                .map(Map.Entry::getKey)
                .orElse(sessionResults.get(0).topicName());

        List<String> sentences = new ArrayList<>();
        sentences.add(wrongCount == 0
                ? totalCount + "문제 모두 맞혔어요"
                : totalCount + "문제 중 " + (totalCount - wrongCount) + "문제 맞혔어요");
        // 여러 토픽을 섞어 푼 세션만 놓친 토픽을 따로 짚음 (한 토픽 세션은 판정 문장이 대신함)
        if (wrongCount > 0 && wrongCountByTopic.size() > 1) {
            sentences.add(AiAnalysisPlanner.toShortTopicName(focusTopicName) + "에서 "
                    + wrongCountByTopic.get(focusTopicName) + "문제를 놓쳤어요");
        }
        findTopicStat(topicStats, focusTopicName)
                .map(stat -> toTopicContextSentence(stat, wrongCount > 0))
                .ifPresent(sentences::add);
        return new SessionCommentPlan(sentences, focusTopicName, wrongCount);
    }

    /** 토픽 최근 90일 판정 문장 (이번 세션 포함 수치) */
    static String toTopicContextSentence(TopicLearningStat stat, boolean hasWrongAnswers) {
        String shortName = AiAnalysisPlanner.toShortTopicName(stat.displayName());
        String rateText = shortName + " 최근 90일 정답률 " + stat.correctRatePercent() + "%";
        return switch (AiAnalysisPlanner.judge(stat)) {
            case UNTRIED -> shortName + " 풀이가 아직 " + stat.solvedCount() + "문제라 조금 더 풀면 약점을 짚어 드려요";
            case WEAK -> rateText + ", 지금 가장 먼저 다질 곳이에요";
            case SHAKY -> rateText + ", 조금만 더 올리면 안정권이에요";
            case STABLE -> hasWrongAnswers
                    ? rateText + "라 이번 오답은 실수에 가까워요"
                    : rateText + ", 안정권을 잘 지키고 있어요";
        };
    }

    /** 토픽별 오답 수 (세션에 나온 순서 유지, 다 맞힌 토픽은 0) */
    private static Map<String, Integer> countWrongByTopic(List<SessionResult> sessionResults) {
        Map<String, Integer> wrongCountByTopic = new LinkedHashMap<>();
        for (SessionResult result : sessionResults) {
            wrongCountByTopic.merge(result.topicName(), result.isCorrect() ? 0 : 1, Integer::sum);
        }
        return wrongCountByTopic;
    }

    private static Optional<TopicLearningStat> findTopicStat(List<TopicLearningStat> topicStats, String topicName) {
        return topicStats.stream().filter(stat -> stat.displayName().equals(topicName)).findFirst();
    }
}
