package com.passql.web.readiness;

import com.passql.submission.readiness.ReadinessCalculator;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 합격 준비도 최신성(recency) 계산 (#373).
 * PQL-Domain-Submission 테스트 소스는 기존 테스트가 깨져 컴파일되지 않아, 실행되는 PQL-Web 쪽에 둔다.
 */
class ReadinessRecencyTest {

    private static final LocalDate TODAY = LocalDate.of(2026, 10, 7);

    @Test
    void 학습기록이_없으면_최신성은_0이다() {
        ReadinessCalculator.ReadinessResult result = ReadinessCalculator.calculate(
                Collections.emptyList(), null, 0, 9, Collections.emptyMap(), 0L, 0L, TODAY);
        assertThat(result.recency()).isEqualTo(0.0);
        assertThat(result.score()).isEqualTo(0.0);
    }

    @Test
    void 오래_쉬었으면_바닥값_0_70을_유지한다() {
        ReadinessCalculator.ReadinessResult result = ReadinessCalculator.calculate(
                List.of(true), TODAY.minusDays(30), 1, 9, Map.of("t1", 1L), 0L, 0L, TODAY);
        assertThat(result.recency()).isEqualTo(0.70);
    }

    @Test
    void 오늘_공부했으면_최신성은_1이다() {
        ReadinessCalculator.ReadinessResult result = ReadinessCalculator.calculate(
                List.of(true), TODAY, 1, 9, Map.of("t1", 1L), 0L, 0L, TODAY);
        assertThat(result.recency()).isEqualTo(1.0);
    }
}
