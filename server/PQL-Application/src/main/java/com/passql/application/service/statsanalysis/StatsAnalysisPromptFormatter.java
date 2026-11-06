package com.passql.application.service.statsanalysis;

import com.passql.ai.constant.AiFindingKind;
import com.passql.common.util.TextPreview;

import java.util.List;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * PromptKey.AI_ANALYSIS_STATS 프롬프트 변수 3개 조립 (#861): {focusTopics}, {subtopicStats}, {recentWrongs}
 * 한 줄에 한 항목 ("- ..."), 비면 "(없음)"
 */
public final class StatsAnalysisPromptFormatter {

    static final String EMPTY_VALUE = "(없음)";

    private StatsAnalysisPromptFormatter() {
    }

    /** 세부 주제 1행 (토픽명은 전체 표시 이름) */
    public record SubtopicStat(String topicName, String subtopicName, int solvedCount, double correctRate) {}

    /** 최근 오답 1행 (subtopicName null 가능) */
    public record WrongQuestionSummary(String topicName, String subtopicName, String stem) {}

    /** "- topicUuid=<uuid> | 조인 (JOIN) | 판정 WEAK(약점) | 풀이 20문제, 정답률 45%" (0문제면 정답률 생략) */
    public static String formatFocusTopics(List<TopicLearningStat> focusTopics) {
        return joinLines(focusTopics, stat -> {
            AiFindingKind kind = AiAnalysisPlanner.toFindingKind(stat);
            String rateText = stat.solvedCount() > 0 ? ", 정답률 " + stat.correctRatePercent() + "%" : "";
            return "- topicUuid=" + stat.topicUuid() + " | " + stat.displayName()
                    + " | 판정 " + kind.name() + "(" + toKindLabel(kind) + ")"
                    + " | 풀이 " + stat.solvedCount() + "문제" + rateText;
        });
    }

    /** "- 조인 (JOIN) > OUTER JOIN: 9문제, 정답률 22%" */
    public static String formatSubtopicStats(List<SubtopicStat> subtopicStats) {
        return joinLines(subtopicStats, stat -> "- " + stat.topicName() + " > " + stat.subtopicName() + ": "
                + stat.solvedCount() + "문제, 정답률 " + Math.round(stat.correctRate() * 100) + "%");
    }

    /** "- [조인 (JOIN) > OUTER JOIN] <지문 한 줄, 80자>" (세부 주제 없으면 토픽만) */
    public static String formatRecentWrongs(List<WrongQuestionSummary> wrongQuestions) {
        return joinLines(wrongQuestions, wrong -> {
            String location = wrong.subtopicName() == null
                    ? wrong.topicName()
                    : wrong.topicName() + " > " + wrong.subtopicName();
            return "- [" + location + "] " + toSingleLineStem(wrong.stem());
        });
    }

    /** 지문 > 한 줄 (코드 펜스 표시 제거, 공백 정리, 80자) */
    static String toSingleLineStem(String stem) {
        String withoutFence = stem == null ? "" : stem.replaceAll("```[a-zA-Z]*", " ");
        return TextPreview.truncate(withoutFence.replaceAll("\\s+", " ").trim(), TextPreview.AI_ANALYSIS_WRONG_STEM_LENGTH);
    }

    private static String toKindLabel(AiFindingKind kind) {
        return switch (kind) {
            case WEAK -> "약점";
            case SHAKY -> "불안정";
            case UNTRIED -> "아직 판단하기 이름";
        };
    }

    private static <T> String joinLines(List<T> rows, Function<T, String> toLine) {
        if (rows.isEmpty()) {
            return EMPTY_VALUE;
        }
        return rows.stream().map(toLine).collect(Collectors.joining("\n"));
    }
}
