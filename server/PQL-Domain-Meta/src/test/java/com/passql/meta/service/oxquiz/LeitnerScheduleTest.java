package com.passql.meta.service.oxquiz;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Leitner 5칸 (#1083): 맞히면 칸 +1(최대 5), 틀리면 1칸, 간격 1·2·4·7·14일
 */
class LeitnerScheduleTest {

    private static final LocalDate ANSWERED_DATE = LocalDate.of(2026, 11, 16);

    @Test
    void 맞히면_한_칸_올라가고_5칸에서_멈춘다() {
        assertThat(LeitnerSchedule.next(null, true, ANSWERED_DATE))
            .isEqualTo(new LeitnerSchedule.NextReview(2, ANSWERED_DATE.plusDays(2)));
        assertThat(LeitnerSchedule.next(3, true, ANSWERED_DATE))
            .isEqualTo(new LeitnerSchedule.NextReview(4, ANSWERED_DATE.plusDays(7)));
        assertThat(LeitnerSchedule.next(5, true, ANSWERED_DATE))
            .isEqualTo(new LeitnerSchedule.NextReview(5, ANSWERED_DATE.plusDays(14)));
    }

    @Test
    void 틀리면_어느_칸이든_1칸으로_돌아가_다음날_나온다() {
        assertThat(LeitnerSchedule.next(4, false, ANSWERED_DATE))
            .isEqualTo(new LeitnerSchedule.NextReview(1, ANSWERED_DATE.plusDays(1)));
        assertThat(LeitnerSchedule.next(null, false, ANSWERED_DATE))
            .isEqualTo(new LeitnerSchedule.NextReview(1, ANSWERED_DATE.plusDays(1)));
    }
}
