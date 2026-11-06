package com.passql.application.service.statsanalysis;

import com.passql.application.service.statsanalysis.SessionCommentPlanner.SessionCommentPlan;
import com.passql.application.service.statsanalysis.SessionCommentPlanner.SessionResult;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 결과 화면 세션 코멘트 서버 판정 (#862): 점수 문장, 가장 많이 놓친 토픽, 토픽 최근 90일 판정 문장
 */
class SessionCommentPlannerTest {

    private static TopicLearningStat topic(String displayName, int solvedCount, double correctRate) {
        return new TopicLearningStat(UUID.nameUUIDFromBytes(displayName.getBytes()), displayName, false, solvedCount, correctRate);
    }

    @Test
    void 여러_토픽_세션은_가장_많이_놓친_토픽과_그_토픽_판정() {
        SessionCommentPlan plan = SessionCommentPlanner.plan(List.of(
                new SessionResult("서브쿼리", false),
                new SessionResult("조인 (JOIN)", false),
                new SessionResult("조인 (JOIN)", false),
                new SessionResult("조인 (JOIN)", true)), List.of(topic("조인 (JOIN)", 20, 0.45)));

        assertThat(plan.sentences()).containsExactly(
                "4문제 중 1문제 맞혔어요", "조인에서 2문제를 놓쳤어요", "조인 최근 90일 정답률 45%, 지금 가장 먼저 다질 곳이에요");
        assertThat(plan.focusTopicName()).isEqualTo("조인 (JOIN)");
        assertThat(plan.hasWrongAnswers()).isTrue();
    }

    @Test
    void 다_맞히면_LLM_없이_점수와_토픽_판정만() {
        SessionCommentPlan plan = SessionCommentPlanner.plan(List.of(
                new SessionResult("조인 (JOIN)", true),
                new SessionResult("조인 (JOIN)", true)), List.of(topic("조인 (JOIN)", 20, 0.9)));

        assertThat(plan.sentences()).containsExactly("2문제 모두 맞혔어요", "조인 최근 90일 정답률 90%, 안정권을 잘 지키고 있어요");
        assertThat(plan.hasWrongAnswers()).isFalse();
    }
}
