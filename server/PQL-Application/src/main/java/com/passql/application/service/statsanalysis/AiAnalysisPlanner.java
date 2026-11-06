package com.passql.application.service.statsanalysis;

import com.passql.ai.constant.AiFindingKind;
import com.passql.ai.dto.AiAnalysisFinding;
import com.passql.ai.dto.AiAnalysisStrength;
import com.passql.ai.dto.AiStatsAnalysis;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

/**
 * 통계 AI 분석 서버 판정 (#861, #862): 데이터 부족(5문제 이상 토픽 없음) > 토픽 판정 > 집중 토픽 2개 > 예상 점수 > 강점·반복 오답 > 요약·추세 > 다음 할 일
 * 순수 규칙 (DB·LLM 없음). LLM 은 집중 토픽별 한 문장만 따로 붙임
 */
public final class AiAnalysisPlanner {

    // 판정 기준: 5문제 미만 판단 이름, 정답률 60% 미만 약점, 75% 미만 불안정
    static final int MIN_SOLVED_FOR_JUDGE = 5;
    static final double WEAK_RATE_THRESHOLD = 0.60;
    static final double SHAKY_RATE_THRESHOLD = 0.75;
    static final int MAX_FOCUS_TOPIC_COUNT = 2;
    // 시험이 이 일수 이내이고 약점이 이미 있으면 판단 이른 토픽은 넣지 않음
    static final int UNTRIED_SKIP_EXAM_DAYS = 14;
    // 강점: 10문제 이상, 정답률 85% 이상
    static final int STRENGTH_MIN_SOLVED = 10;
    static final double STRENGTH_RATE_THRESHOLD = 0.85;
    // 한 줄 요약 앞 D-N 표기 기간 (일)
    static final int EXAM_PREFIX_DAYS = 30;
    // 판정 기간 표기 (StatsAnalysisDataLoader 의 90일 누적과 같은 값)
    static final String PERIOD_LABEL = "최근 " + StatsAnalysisDataLoader.ANALYSIS_STATS_RECENT_DAYS + "일 기준";

    static final String HEADLINE_NO_HISTORY = "아직 풀이 기록이 없어요";
    static final String HEADLINE_NOT_ENOUGH_DATA = "아직 진단할 풀이가 부족해요";

    /** 토픽 판정 4종 (STABLE 안정권은 분석 대상 아님) */
    enum TopicJudgement { WEAK, SHAKY, UNTRIED, STABLE }

    private AiAnalysisPlanner() {
    }

    /** 판정 입력 > 화면용 분석(insight 없음) + 집중 토픽 */
    public static StatsAnalysisPlan plan(StatsAnalysisInput input) {
        String examPrefix = toExamPrefix(input.daysUntilExam());
        List<TopicLearningStat> topicStats = input.topicStats();
        if (!hasJudgeableTopic(topicStats)) {
            return new StatsAnalysisPlan(planNotEnoughData(input, examPrefix), List.of());
        }
        List<TopicLearningStat> focusTopics = selectFocusTopics(topicStats, input.daysUntilExam());
        // 모두 안정권일 때만 다음 목표 (안 푼 토픽 시작 > 최신 경향)
        Optional<TopicLearningStat> untouchedTopic = focusTopics.isEmpty()
                ? AiAnalysisNextStepPlanner.selectUntouchedTopic(topicStats)
                : Optional.empty();
        AiStatsAnalysis analysis = new AiStatsAnalysis(
                examPrefix + toHeadlineBody(focusTopics, input.recentSolvedCount()),
                focusTopics.stream().map(stat -> toFinding(stat, input.conceptTopicUuids())).toList(),
                toTrendText(input.twoWeekCounts()),
                selectStrength(topicStats).orElse(null),
                AiAnalysisNextStepPlanner.buildActions(focusTopics, untouchedTopic,
                        input.latestWrongQuestionCount(), input.repeatedWrongStat()),
                PERIOD_LABEL,
                ExamForecastCalculator.forecast(topicStats).orElse(null),
                ExamForecastCalculator.toMissingDataHint(topicStats),
                AiAnalysisNextStepPlanner.toRepeatedWrong(input.repeatedWrongStat()),
                null,
                focusTopics.isEmpty() ? AiAnalysisNextStepPlanner.toNextGoal(untouchedTopic) : null
        );
        return new StatsAnalysisPlan(analysis, focusTopics);
    }

    /** 데이터 부족: 요약(기록 없음·부족) + 진행 안내 + 랜덤·토픽 버튼 (진단·예상 점수·LLM 없음) */
    private static AiStatsAnalysis planNotEnoughData(StatsAnalysisInput input, String examPrefix) {
        Optional<TopicLearningStat> readinessTopic = AiAnalysisNextStepPlanner.selectReadinessTopic(input.topicStats());
        String headlineBody = input.totalSolvedCount() == 0 ? HEADLINE_NO_HISTORY : HEADLINE_NOT_ENOUGH_DATA;
        return new AiStatsAnalysis(examPrefix + headlineBody, List.of(), toTrendText(input.twoWeekCounts()), null,
                AiAnalysisNextStepPlanner.buildReadinessActions(readinessTopic), PERIOD_LABEL, null, null, null,
                AiAnalysisNextStepPlanner.toReadiness(readinessTopic), null);
    }

    /** 5문제 이상 푼 토픽이 하나라도 있는지 (없으면 데이터 부족) */
    static boolean hasJudgeableTopic(List<TopicLearningStat> topicStats) {
        return topicStats.stream().anyMatch(stat -> judge(stat) != TopicJudgement.UNTRIED);
    }

    static TopicJudgement judge(TopicLearningStat stat) {
        if (stat.solvedCount() < MIN_SOLVED_FOR_JUDGE) {
            return TopicJudgement.UNTRIED;
        }
        if (stat.correctRate() < WEAK_RATE_THRESHOLD) {
            return TopicJudgement.WEAK;
        }
        if (stat.correctRate() < SHAKY_RATE_THRESHOLD) {
            return TopicJudgement.SHAKY;
        }
        return TopicJudgement.STABLE;
    }

    /** 집중 토픽 판정 > 응답 판정 (집중 토픽은 STABLE 이 나오지 않음) */
    public static AiFindingKind toFindingKind(TopicLearningStat stat) {
        return switch (judge(stat)) {
            case WEAK -> AiFindingKind.WEAK;
            case SHAKY -> AiFindingKind.SHAKY;
            case UNTRIED, STABLE -> AiFindingKind.UNTRIED;
        };
    }

    /**
     * 집중 토픽 최대 2개: 1과목(안정권 아니면, 0문제 포함) > 그 외 약점 > 불안정 > 판단 이른 토픽 1개
     * 같은 판정 안에서는 틀린 문제 수 많은 순 (동률은 토픽 정렬 순서)
     */
    static List<TopicLearningStat> selectFocusTopics(List<TopicLearningStat> topicStats, Integer daysUntilExam) {
        List<TopicLearningStat> candidates = new ArrayList<>();
        // 1과목: 과락 위험
        topicStats.stream()
                .filter(stat -> stat.isSubjectOne() && judge(stat) != TopicJudgement.STABLE)
                .forEach(candidates::add);
        // 그 외 약점 > 불안정
        candidates.addAll(sortedOtherTopics(topicStats, TopicJudgement.WEAK));
        candidates.addAll(sortedOtherTopics(topicStats, TopicJudgement.SHAKY));
        // 판단 이른 토픽 (1문제 이상): 시험 임박 + 약점 있음이면 제외
        boolean hasWeakOrShaky = candidates.stream()
                .anyMatch(stat -> judge(stat) == TopicJudgement.WEAK || judge(stat) == TopicJudgement.SHAKY);
        boolean isExamClose = daysUntilExam != null && daysUntilExam <= UNTRIED_SKIP_EXAM_DAYS;
        if (!(isExamClose && hasWeakOrShaky)) {
            sortedOtherTopics(topicStats, TopicJudgement.UNTRIED).stream()
                    .filter(stat -> stat.solvedCount() > 0)
                    .findFirst()
                    .ifPresent(candidates::add);
        }
        // 중복 제거 후 앞에서 2개
        Map<UUID, TopicLearningStat> distinctByTopic = new LinkedHashMap<>();
        candidates.forEach(stat -> distinctByTopic.putIfAbsent(stat.topicUuid(), stat));
        return distinctByTopic.values().stream().limit(MAX_FOCUS_TOPIC_COUNT).toList();
    }

    /** 1과목 외 토픽 중 판정이 같은 것, 틀린 문제 수 많은 순 (안정 정렬) */
    private static List<TopicLearningStat> sortedOtherTopics(List<TopicLearningStat> topicStats, TopicJudgement judgement) {
        return topicStats.stream()
                .filter(stat -> !stat.isSubjectOne() && judge(stat) == judgement)
                .sorted(Comparator.comparingDouble(TopicLearningStat::wrongCount).reversed())
                .toList();
    }

    /** 강점: 10문제 이상·85% 이상 중 정답률 높은 순 (동률은 많이 푼 순) */
    static Optional<AiAnalysisStrength> selectStrength(List<TopicLearningStat> topicStats) {
        return topicStats.stream()
                .filter(stat -> stat.solvedCount() >= STRENGTH_MIN_SOLVED && stat.correctRate() >= STRENGTH_RATE_THRESHOLD)
                .sorted(Comparator.comparingDouble(TopicLearningStat::correctRate).reversed()
                        .thenComparing(Comparator.comparingInt(TopicLearningStat::solvedCount).reversed()))
                .findFirst()
                .map(stat -> new AiAnalysisStrength(stat.topicUuid(), toShortTopicName(stat.displayName()),
                        stat.correctRatePercent()));
    }

    /** 시험 30일 이내면 "D-7 · " (당일 "D-DAY · "), 아니면 빈 문자열 */
    static String toExamPrefix(Integer daysUntilExam) {
        if (daysUntilExam == null || daysUntilExam < 0 || daysUntilExam > EXAM_PREFIX_DAYS) {
            return "";
        }
        return (daysUntilExam == 0 ? "D-DAY" : "D-" + daysUntilExam) + " · ";
    }

    /** 한 줄 요약 본문: 7일 쉼 > 1과목 > 약점 > 불안정 > 판단 이름 > 모두 안정 순으로 첫 해당 */
    static String toHeadlineBody(List<TopicLearningStat> focusTopics, long recentSolvedCount) {
        if (recentSolvedCount == 0) {
            return "최근 7일 풀이가 없어요";
        }
        if (focusTopics.isEmpty()) {
            return "모든 토픽이 안정권이에요";
        }
        TopicLearningStat firstFocus = focusTopics.get(0);
        // 1과목: 5문제 미만은 정답률을 믿지 않아 풀이 수로만 말함
        if (firstFocus.isSubjectOne()) {
            if (judge(firstFocus) == TopicJudgement.UNTRIED) {
                return "1과목 아직 " + firstFocus.solvedCount() + "문제, 과락 위험이 커요";
            }
            return "1과목 정답률 " + firstFocus.correctRatePercent() + "%, 과락 위험이 커요";
        }
        String shortName = toShortTopicName(firstFocus.displayName());
        return switch (judge(firstFocus)) {
            case WEAK -> shortName + " 정답률 " + firstFocus.correctRatePercent() + "%가 가장 급해요";
            case SHAKY -> shortName + " " + firstFocus.correctRatePercent() + "%, 조금만 더 올려요";
            case UNTRIED, STABLE -> shortName + " 아직 " + firstFocus.solvedCount() + "문제, 판단하기 일러요";
        };
    }

    /** 근거 문구: "20문제 중 9문제 정답 (45%)" / "아직 풀이 0문제" */
    static String toEvidence(TopicLearningStat stat) {
        if (stat.solvedCount() == 0) {
            return "아직 풀이 0문제";
        }
        return stat.solvedCount() + "문제 중 " + stat.correctCount() + "문제 정답 (" + stat.correctRatePercent() + "%)";
    }

    /** 주간 추세: 두 주 모두 풀이 있을 때만 */
    static String toTrendText(TwoWeekSubmissionCounts counts) {
        if (!counts.hasBothWeeks()) {
            return null;
        }
        int thisWeekPercent = counts.thisWeekCorrectRatePercent();
        int differencePoints = thisWeekPercent - counts.lastWeekCorrectRatePercent();
        String comparison = differencePoints > 0 ? "지난주보다 " + differencePoints + "%p 올랐어요"
                : differencePoints < 0 ? "지난주보다 " + (-differencePoints) + "%p 내려갔어요"
                : "지난주와 같아요";
        return "이번 주 정답률 " + thisWeekPercent + "%, " + comparison;
    }

    /** 집중 토픽 > 응답 항목 (insight 는 LLM 결과로 나중에 채움, 열 수 있는 개념 단원 있으면 바로 가기) */
    private static AiAnalysisFinding toFinding(TopicLearningStat stat, Set<UUID> conceptTopicUuids) {
        UUID conceptTopicUuid = conceptTopicUuids.contains(stat.topicUuid()) ? stat.topicUuid() : null;
        return new AiAnalysisFinding(stat.topicUuid(), toShortTopicName(stat.displayName()), toFindingKind(stat),
                stat.solvedCount(), stat.correctRatePercent(), toEvidence(stat), null, conceptTopicUuid);
    }

    /** 표시용 짧은 이름: 끝 괄호 설명 제거 ("조인 (JOIN)" > "조인") */
    public static String toShortTopicName(String displayName) {
        if (displayName == null) {
            return "";
        }
        String shortName = displayName.replaceFirst("\\s*\\([^()]*\\)\\s*$", "").trim();
        return shortName.isEmpty() ? displayName.trim() : shortName;
    }
}
