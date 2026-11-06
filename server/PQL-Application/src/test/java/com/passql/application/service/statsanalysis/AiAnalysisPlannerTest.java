package com.passql.application.service.statsanalysis;

import com.passql.ai.constant.AiAnalysisActionType;
import com.passql.ai.dto.AiStatsAnalysis;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 통계 AI 분석 서버 판정 (#861, #862): 집중 토픽 순서, 시험 임박 제외, 강점 기준, 한 줄 요약, 데이터 부족·모두 안정권 다음 할 일
 */
class AiAnalysisPlannerTest {

    // 최근 7일 풀이 있음 / 없음
    private static final TwoWeekSubmissionCounts ACTIVE_WEEKS = new TwoWeekSubmissionCounts(20, 13, 10, 5);
    private static final TwoWeekSubmissionCounts NO_RECENT_WEEK = new TwoWeekSubmissionCounts(0, 0, 10, 5);

    private static TopicLearningStat topic(String displayName, int solvedCount, double correctRate) {
        return new TopicLearningStat(UUID.nameUUIDFromBytes(displayName.getBytes()), displayName, false, solvedCount, correctRate);
    }

    private static TopicLearningStat subjectOne(int solvedCount, double correctRate) {
        return new TopicLearningStat(UUID.nameUUIDFromBytes("subject-one".getBytes()), "데이터 모델링의 이해", true,
                solvedCount, correctRate);
    }

    private static AiStatsAnalysis plan(List<TopicLearningStat> topics, TwoWeekSubmissionCounts weeks,
                                        Integer daysUntilExam, long latestWrongCount) {
        return AiAnalysisPlanner.plan(input(topics, 100, weeks, daysUntilExam, latestWrongCount)).analysis();
    }

    private static StatsAnalysisInput input(List<TopicLearningStat> topics, long totalSolvedCount,
                                            TwoWeekSubmissionCounts weeks, Integer daysUntilExam, long latestWrongCount) {
        return new StatsAnalysisInput(topics, totalSolvedCount, weeks, daysUntilExam, latestWrongCount,
                RepeatedWrongStat.EMPTY, Set.of());
    }

    @Test
    void 일과목이_안정권_아니면_0문제여도_가장_먼저_고른다() {
        List<TopicLearningStat> focus = AiAnalysisPlanner.selectFocusTopics(
                List.of(topic("조인 (JOIN)", 20, 0.45), subjectOne(0, 0)), null);

        assertThat(focus).extracting(TopicLearningStat::displayName)
                .containsExactly("데이터 모델링의 이해", "조인 (JOIN)");
    }

    @Test
    void 약점은_틀린_문제_수_많은_순이고_불안정보다_먼저다() {
        List<TopicLearningStat> focus = AiAnalysisPlanner.selectFocusTopics(List.of(
                subjectOne(20, 0.9),
                topic("서브쿼리", 10, 0.7),
                topic("윈도우 함수", 8, 0.38),
                topic("조인 (JOIN)", 20, 0.45)), null);

        // 틀린 수: 조인 11 > 윈도우 4.96, 서브쿼리는 불안정이라 밀림
        assertThat(focus).extracting(TopicLearningStat::displayName)
                .containsExactly("조인 (JOIN)", "윈도우 함수");
    }

    @Test
    void 시험_14일_이내이고_약점_있으면_판단_이른_토픽은_빼고_아니면_넣는다() {
        List<TopicLearningStat> topics = List.of(subjectOne(20, 0.9), topic("서브쿼리", 10, 0.7), topic("조인 (JOIN)", 3, 0.33));

        assertThat(AiAnalysisPlanner.selectFocusTopics(topics, 7)).extracting(TopicLearningStat::displayName)
                .containsExactly("서브쿼리");
        assertThat(AiAnalysisPlanner.selectFocusTopics(topics, 20)).extracting(TopicLearningStat::displayName)
                .containsExactly("서브쿼리", "조인 (JOIN)");
    }

    @Test
    void 강점은_10문제_85퍼센트_이상_중_정답률_높은_토픽() {
        AiStatsAnalysis analysis = plan(List.of(
                subjectOne(20, 0.9),
                topic("SELECT 기본", 30, 0.93),
                topic("집합 연산자", 9, 1.0),
                topic("조인 (JOIN)", 20, 0.84)), ACTIVE_WEEKS, null, 0);

        assertThat(analysis.strength().topicName()).isEqualTo("SELECT 기본");
        assertThat(analysis.strength().correctRatePercent()).isEqualTo(93);
        assertThat(plan(List.of(topic("조인 (JOIN)", 20, 0.84)), ACTIVE_WEEKS, null, 0).strength()).isNull();
    }

    @Test
    void 한_줄_요약은_첫_해당_경우를_고르고_시험_30일_이내면_D_접두() {
        // 판단 가능한 토픽(5문제 이상)이 하나는 있어야 진단 (없으면 데이터 부족 안내)
        TopicLearningStat stableSelect = topic("SELECT 기본", 20, 0.9);
        assertThat(plan(List.of(subjectOne(6, 0.5)), ACTIVE_WEEKS, 7, 0).headline())
                .isEqualTo("D-7 · 1과목 정답률 50%, 과락 위험이 커요");
        assertThat(plan(List.of(subjectOne(0, 0), stableSelect), NO_RECENT_WEEK, null, 0).headline())
                .isEqualTo("최근 7일 풀이가 없어요");
        assertThat(plan(List.of(subjectOne(0, 0), stableSelect), ACTIVE_WEEKS, 40, 0).headline())
                .isEqualTo("1과목 아직 0문제, 과락 위험이 커요");
        assertThat(plan(List.of(subjectOne(3, 0.33), stableSelect), ACTIVE_WEEKS, null, 0).headline())
                .isEqualTo("1과목 아직 3문제, 과락 위험이 커요");
        assertThat(plan(List.of(subjectOne(20, 0.9), topic("조인 (JOIN)", 20, 0.45)), ACTIVE_WEEKS, null, 0).headline())
                .isEqualTo("조인 정답률 45%가 가장 급해요");
        assertThat(plan(List.of(subjectOne(20, 0.9), topic("서브쿼리", 10, 0.7)), ACTIVE_WEEKS, null, 0).headline())
                .isEqualTo("서브쿼리 70%, 조금만 더 올려요");
        assertThat(plan(List.of(subjectOne(20, 0.9), topic("조인 (JOIN)", 3, 0.33)), ACTIVE_WEEKS, null, 0).headline())
                .isEqualTo("조인 아직 3문제, 판단하기 일러요");
        assertThat(plan(List.of(subjectOne(20, 0.9)), ACTIVE_WEEKS, null, 0).headline())
                .isEqualTo("모든 토픽이 안정권이에요");
    }

    @Test
    void 풀이_기록이_없으면_요약과_진행_안내만_내고_집중_토픽이_없다() {
        StatsAnalysisPlan emptyPlan = AiAnalysisPlanner.plan(input(
                List.of(subjectOne(0, 0)), 0, TwoWeekSubmissionCounts.EMPTY, null, 0));

        assertThat(emptyPlan.analysis().headline()).isEqualTo("아직 풀이 기록이 없어요");
        assertThat(emptyPlan.analysis().findings()).isEmpty();
        assertThat(emptyPlan.analysis().readiness().solvedCount()).isZero();
        assertThat(emptyPlan.hasFocusTopics()).isFalse();
    }

    @Test
    void 판단_가능한_토픽이_없으면_가장_많이_푼_토픽_진행과_랜덤_버튼() {
        StatsAnalysisPlan thinPlan = AiAnalysisPlanner.plan(input(
                List.of(subjectOne(2, 0.5), topic("조인 (JOIN)", 4, 0.5), topic("서브쿼리", 4, 1.0)),
                10, ACTIVE_WEEKS, null, 5));

        AiStatsAnalysis analysis = thinPlan.analysis();
        assertThat(thinPlan.hasFocusTopics()).isFalse();
        assertThat(analysis.headline()).isEqualTo("아직 진단할 풀이가 부족해요");
        assertThat(analysis.forecast()).isNull();
        // 동률이면 정렬 순서 앞 토픽
        assertThat(analysis.readiness().topicName()).isEqualTo("조인");
        assertThat(analysis.readiness().solvedCount()).isEqualTo(4);
        assertThat(analysis.readiness().targetCount()).isEqualTo(5);
        assertThat(analysis.actions()).extracting(action -> action.type())
                .containsExactly(AiAnalysisActionType.RANDOM_PRACTICE, AiAnalysisActionType.PRACTICE_TOPIC);
        assertThat(analysis.actions().get(1).label()).isEqualTo("조인 이어서 풀기");
    }

    @Test
    void 모두_안정권이면_안_푼_토픽_시작_없으면_최신_경향() {
        AiStatsAnalysis withUntouched = plan(List.of(subjectOne(20, 0.9), topic("윈도우 함수", 0, 0)), ACTIVE_WEEKS, null, 0);
        assertThat(withUntouched.nextGoal()).isEqualTo("아직 안 푼 윈도우 함수까지 풀면 출제 범위를 모두 덮어요");
        assertThat(withUntouched.actions().get(0).label()).isEqualTo("윈도우 함수 시작하기");

        AiStatsAnalysis allTouched = plan(List.of(subjectOne(20, 0.9)), ACTIVE_WEEKS, null, 0);
        assertThat(allTouched.actions()).extracting(action -> action.type())
                .containsExactly(AiAnalysisActionType.PRACTICE_LATEST_TREND);
    }

    @Test
    void 반복_오답은_2문제_이상일_때만_문구와_오답_버튼() {
        StatsAnalysisInput repeatedInput = new StatsAnalysisInput(List.of(subjectOne(20, 0.9), topic("조인 (JOIN)", 20, 0.45)),
                100, ACTIVE_WEEKS, null, 1, new RepeatedWrongStat(4, 3, "조인 (JOIN)"), Set.of());
        AiStatsAnalysis analysis = AiAnalysisPlanner.plan(repeatedInput).analysis();

        assertThat(analysis.repeatedWrong().text()).isEqualTo("4문제를 2번 이상 틀렸고, 3문제는 아직 못 맞혔어요. 대부분 조인 문제예요");
        assertThat(analysis.actions()).extracting(action -> action.label())
                .containsExactly("조인 문제 풀기", "반복 오답 다시 풀기");
        assertThat(AiAnalysisNextStepPlanner.toRepeatedWrong(new RepeatedWrongStat(1, 1, null))).isNull();
    }

    @Test
    void 근거_추세_버튼_문구() {
        AiStatsAnalysis analysis = plan(List.of(subjectOne(20, 0.9), topic("조인 (JOIN)", 20, 0.45)), ACTIVE_WEEKS, null, 14);

        assertThat(analysis.findings().get(0).evidence()).isEqualTo("20문제 중 9문제 정답 (45%)");
        // 이번 주 13/20 = 65%, 지난주 5/10 = 50%
        assertThat(analysis.trend()).isEqualTo("이번 주 정답률 65%, 지난주보다 15%p 올랐어요");
        assertThat(analysis.actions()).extracting(action -> action.type())
                .containsExactly(AiAnalysisActionType.PRACTICE_TOPIC, AiAnalysisActionType.REVIEW_WRONG);
        assertThat(analysis.actions()).extracting(action -> action.label())
                .containsExactly("조인 문제 풀기", "오답 노트에서 다시 풀기");
    }
}
