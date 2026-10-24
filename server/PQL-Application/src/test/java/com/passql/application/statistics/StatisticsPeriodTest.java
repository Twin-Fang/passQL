package com.passql.application.statistics;

import com.passql.common.exception.CustomException;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/** 통계 공통 기간: 기본값 보정, 직전 기간(전주·전월) 규칙 */
class StatisticsPeriodTest {

    @Test
    void 요청이_없으면_오늘까지_기본_일수로_잡는다() {
        StatisticsPeriod period = StatisticsPeriod.resolve(null, null, 30);

        assertThat(period.toDate()).isEqualTo(LocalDate.now());
        assertThat(period.getDayCount()).isEqualTo(30);
    }

    @Test
    void 미래_종료일은_오늘로_줄이고_시작이_종료보다_늦으면_거절한다() {
        assertThat(StatisticsPeriod.resolve(null, LocalDate.now().plusDays(5), 7).toDate()).isEqualTo(LocalDate.now());
        assertThatThrownBy(() -> StatisticsPeriod.resolve(LocalDate.now(), LocalDate.now().minusDays(1), 7))
                .isInstanceOf(CustomException.class);
        assertThatThrownBy(() -> StatisticsPeriod.resolve(LocalDate.now().minusDays(StatisticsPeriod.MAX_DAY_COUNT), LocalDate.now(), 7))
                .isInstanceOf(CustomException.class);
    }

    @Test
    void 일곱_일_구간의_직전_기간은_바로_앞_일곱_일이다() {
        StatisticsPeriod previous = new StatisticsPeriod(LocalDate.of(2026, 10, 12), LocalDate.of(2026, 10, 18)).getPreviousPeriod();

        assertThat(previous).isEqualTo(new StatisticsPeriod(LocalDate.of(2026, 10, 5), LocalDate.of(2026, 10, 11)));
    }

    @Test
    void 달_전체의_직전_기간은_전월이다() {
        StatisticsPeriod previous = new StatisticsPeriod(LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 31)).getPreviousPeriod();

        assertThat(previous).isEqualTo(new StatisticsPeriod(LocalDate.of(2026, 9, 1), LocalDate.of(2026, 9, 30)));
    }

    @Test
    void 이번_달_중간까지의_직전_기간은_전월_같은_일수이고_전월_말일을_넘지_않는다() {
        assertThat(new StatisticsPeriod(LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 24)).getPreviousPeriod())
                .isEqualTo(new StatisticsPeriod(LocalDate.of(2026, 9, 1), LocalDate.of(2026, 9, 24)));
        assertThat(new StatisticsPeriod(LocalDate.of(2026, 3, 1), LocalDate.of(2026, 3, 31)).getPreviousPeriod())
                .isEqualTo(new StatisticsPeriod(LocalDate.of(2026, 2, 1), LocalDate.of(2026, 2, 28)));
    }
}
