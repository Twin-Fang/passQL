package com.passql.meta.constant;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 지금 단계 경계 고정 (#991, 2026 제60회: 접수 2.2~2.6, 수험표 2.20, 시험 3.7, 발표 3.27)
 */
class ExamSchedulePhaseTest {

    private static final LocalDate APPLICATION_START = LocalDate.of(2026, 2, 2);
    private static final LocalDate APPLICATION_END = LocalDate.of(2026, 2, 6);
    private static final LocalDate ADMISSION_TICKET = LocalDate.of(2026, 2, 20);
    private static final LocalDate EXAM = LocalDate.of(2026, 3, 7);
    private static final LocalDate RESULT = LocalDate.of(2026, 3, 27);

    @Test
    void 날짜별_단계가_순서대로_바뀐다() {
        assertThat(phaseOn(2026, 2, 1)).isEqualTo(ExamSchedulePhase.BEFORE_APPLICATION);
        assertThat(phaseOn(2026, 2, 2)).isEqualTo(ExamSchedulePhase.APPLICATION_OPEN);
        assertThat(phaseOn(2026, 2, 6)).isEqualTo(ExamSchedulePhase.APPLICATION_OPEN);
        assertThat(phaseOn(2026, 2, 7)).isEqualTo(ExamSchedulePhase.WAITING_ADMISSION_TICKET);
        assertThat(phaseOn(2026, 2, 20)).isEqualTo(ExamSchedulePhase.WAITING_EXAM);
        assertThat(phaseOn(2026, 3, 7)).isEqualTo(ExamSchedulePhase.WAITING_EXAM);
        assertThat(phaseOn(2026, 3, 8)).isEqualTo(ExamSchedulePhase.WAITING_RESULT);
        assertThat(phaseOn(2026, 3, 27)).isEqualTo(ExamSchedulePhase.FINISHED);
    }

    @Test
    void 시험일만_있는_수동_일정은_시험_대기와_끝으로만_나뉜다() {
        assertThat(ExamSchedulePhase.resolve(null, null, null, EXAM, null, LocalDate.of(2026, 1, 1)))
                .isEqualTo(ExamSchedulePhase.WAITING_EXAM);
        assertThat(ExamSchedulePhase.resolve(null, null, null, EXAM, null, LocalDate.of(2026, 3, 8)))
                .isEqualTo(ExamSchedulePhase.FINISHED);
    }

    private static ExamSchedulePhase phaseOn(int year, int month, int day) {
        return ExamSchedulePhase.resolve(APPLICATION_START, APPLICATION_END, ADMISSION_TICKET, EXAM, RESULT,
                LocalDate.of(year, month, day));
    }
}
