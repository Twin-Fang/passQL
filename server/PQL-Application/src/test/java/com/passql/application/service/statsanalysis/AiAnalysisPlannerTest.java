package com.passql.application.service.statsanalysis;

import com.passql.ai.constant.AiAnalysisActionType;
import com.passql.ai.dto.AiStatsAnalysis;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 통계 AI 분석 서버 판정 (#861): 집중 토픽 순서, 시험 임박 제외, 강점 기준, 한 줄 요약
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
        return AiAnalysisPlanner.plan(new StatsAnalysisInput(topics, 100, weeks, daysUntilExam, latestWrongCount)).analysis();
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
        assertThat(plan(List.of(subjectOne(6, 0.5)), ACTIVE_WEEKS, 7, 0).headline())
                .isEqualTo("D-7 · 1과목 정답률 50%, 과락 위험이 커요");
        assertThat(plan(List.of(subjectOne(0, 0)), NO_RECENT_WEEK, null, 0).headline())
                .isEqualTo("최근 7일 풀이가 없어요");
        assertThat(plan(List.of(subjectOne(0, 0)), ACTIVE_WEEKS, 40, 0).headline())
                .isEqualTo("1과목 아직 0문제, 과락 위험이 커요");
        assertThat(plan(List.of(subjectOne(3, 0.33)), ACTIVE_WEEKS, null, 0).headline())
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
    void 풀이_기록이_없으면_요약만_내고_집중_토픽이_없다() {
        StatsAnalysisPlan emptyPlan = AiAnalysisPlanner.plan(new StatsAnalysisInput(
                List.of(subjectOne(0, 0)), 0, TwoWeekSubmissionCounts.EMPTY, null, 0));

        assertThat(emptyPlan.analysis().headline()).isEqualTo("아직 풀이 기록이 없어요");
        assertThat(emptyPlan.analysis().findings()).isEmpty();
        assertThat(emptyPlan.hasFocusTopics()).isFalse();
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
                .containsExactly("조인 5문제 풀기", "최근 오답 5문제 다시 풀기");
    }
}
