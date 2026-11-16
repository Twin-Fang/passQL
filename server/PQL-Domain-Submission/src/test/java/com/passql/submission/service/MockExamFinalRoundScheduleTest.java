package com.passql.submission.service;

import com.passql.submission.constant.MockExamRoundType;
import com.passql.submission.entity.MockExamRound;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * FINAL 공개 시점 (#1084): 시험일 3일 전부터 열림, 지난 FINAL 계속 열림, 다른 종류는 늘 열림
 */
class MockExamFinalRoundScheduleTest {

    private static final LocalDate EXAM_DATE = LocalDate.of(2027, 3, 13);

    @Test
    void FINAL은_시험일_3일_전부터_열리고_지나도_계속_열림() {
        MockExamRound finalRound = round(MockExamRoundType.FINAL, EXAM_DATE);

        assertThat(MockExamFinalRoundSchedule.isOpen(finalRound, EXAM_DATE.minusDays(4))).isFalse();
        assertThat(MockExamFinalRoundSchedule.isOpen(finalRound, EXAM_DATE.minusDays(3))).isTrue();
        assertThat(MockExamFinalRoundSchedule.isOpen(finalRound, EXAM_DATE.plusMonths(6))).isTrue();
        assertThat(MockExamFinalRoundSchedule.toOpenNotificationAt(EXAM_DATE))
            .isEqualTo(EXAM_DATE.minusDays(3).atTime(9, 0));
    }

    @Test
    void 시험일_없는_FINAL은_숨기고_다른_종류는_늘_열림() {
        LocalDate today = EXAM_DATE.minusDays(30);

        assertThat(MockExamFinalRoundSchedule.isOpen(round(MockExamRoundType.FINAL, null), today)).isFalse();
        assertThat(MockExamFinalRoundSchedule.isOpen(round(MockExamRoundType.MOCK, null), today)).isTrue();
        assertThat(MockExamFinalRoundSchedule.isOpen(round(MockExamRoundType.PAST_EXAM, EXAM_DATE), today)).isTrue();
    }

    private static MockExamRound round(MockExamRoundType roundType, LocalDate examDate) {
        return MockExamRound.builder().roundNumber(1).roundType(roundType).examDate(examDate).title("회차").build();
    }
}
