package com.passql.submission.service;

import com.passql.submission.dto.QuestionFirstAttemptStat;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 오답률 순위 (#1080): 첫 제출 회원 20명 미만 제외, 오답률 내림차순, 같으면 응시 많은 순
 */
class HardestQuestionRankerTest {

    private static final int MINIMUM_ATTEMPT_COUNT = 20;

    @Test
    void 첫_제출_회원_20명_미만_문제는_오답률이_높아도_뺀다() {
        QuestionFirstAttemptStat tooFewAttempts = stat(19, 19);
        QuestionFirstAttemptStat enoughAttempts = stat(20, 5);

        assertThat(HardestQuestionRanker.rank(List.of(tooFewAttempts, enoughAttempts), MINIMUM_ATTEMPT_COUNT, 30))
            .containsExactly(enoughAttempts);
    }

    @Test
    void 오답률_내림차순이고_같으면_응시_많은_순_상위_N개() {
        QuestionFirstAttemptStat halfOfForty = stat(40, 20);
        QuestionFirstAttemptStat halfOfTwenty = stat(20, 10);
        QuestionFirstAttemptStat threeQuarters = stat(20, 15);
        QuestionFirstAttemptStat quarter = stat(40, 10);

        List<QuestionFirstAttemptStat> ranked = HardestQuestionRanker.rank(
            List.of(quarter, halfOfTwenty, threeQuarters, halfOfForty), MINIMUM_ATTEMPT_COUNT, 3);

        assertThat(ranked).containsExactly(threeQuarters, halfOfForty, halfOfTwenty);
        assertThat(HardestQuestionRanker.toWrongRatePercent(stat(30, 10))).isEqualTo(33.3);
    }

    private static QuestionFirstAttemptStat stat(int attemptCount, int wrongCount) {
        return new QuestionFirstAttemptStat(UUID.randomUUID(), "토픽", "sql_basic", attemptCount, wrongCount);
    }
}
