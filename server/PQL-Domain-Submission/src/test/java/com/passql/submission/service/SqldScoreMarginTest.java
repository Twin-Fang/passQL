package com.passql.submission.service;

import com.passql.submission.constant.MockExamSubject;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * SQLD 과락선·합격선 여유 (#1111): MockExamRule 기준 경계 문제 수와 문구
 */
class SqldScoreMarginTest {

    @Test
    void 과락_면하는_최소_정답은_1과목_4_2과목_16_합격은_30() {
        assertThat(SqldScoreMargin.minCorrectCountToAvoidFailOf(MockExamSubject.SUBJECT_ONE)).isEqualTo(4);
        assertThat(SqldScoreMargin.minCorrectCountToAvoidFailOf(MockExamSubject.SUBJECT_TWO)).isEqualTo(16);
        assertThat(SqldScoreMargin.minCorrectCountToPass()).isEqualTo(30);
    }

    @Test
    void 여유는_더_틀려도_되는_수_음수면_더_맞혀야_할_수() {
        assertThat(SqldScoreMargin.toFailMarginText(SqldScoreMargin.failMarginCountOf(MockExamSubject.SUBJECT_ONE, 6)))
            .isEqualTo("과락까지 여유 2문제");
        assertThat(SqldScoreMargin.toFailMarginText(SqldScoreMargin.failMarginCountOf(MockExamSubject.SUBJECT_ONE, 4)))
            .isEqualTo("한 문제만 더 틀리면 과락");
        assertThat(SqldScoreMargin.toFailMarginText(SqldScoreMargin.failMarginCountOf(MockExamSubject.SUBJECT_ONE, 3)))
            .isEqualTo("과락을 넘으려면 1문제 더");
        assertThat(SqldScoreMargin.toPassMarginText(SqldScoreMargin.passMarginCountOf(27)))
            .isEqualTo("합격선까지 3문제 더 맞히면 돼요");
        assertThat(SqldScoreMargin.toPassMarginText(SqldScoreMargin.passMarginCountOf(32)))
            .isEqualTo("합격선보다 2문제 여유가 있어요");
    }
}
