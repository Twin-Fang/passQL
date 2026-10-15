package com.passql.web.ai;

import com.passql.ai.dto.AiStats;
import com.passql.ai.repository.AiCallLogRepository;
import com.passql.ai.service.AiCallLogService;
import org.junit.jupiter.api.Test;

import java.util.Collections;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** AI 호출 집계 (#474): DB 집계 행 > 성공·실패·지연, 호출 없으면 0 */
class AiCallStatsTest {

    private final AiCallLogRepository repository = mock(AiCallLogRepository.class);
    private final AiCallLogService service = new AiCallLogService(repository);

    @Test
    void 집계_행을_성공_실패_지연으로_바꾼다() {
        when(repository.aggregateSince(any())).thenReturn(Collections.singletonList(new Object[]{10L, 7L, 250.5, 1200L}));

        AiStats stats = service.getStatsLast24Hours();

        assertThat(stats.failureCount()).isEqualTo(3);
        assertThat(stats.failureRatePercent()).isEqualTo(30.0);
        assertThat(stats.maxLatencyMilliseconds()).isEqualTo(1200);
    }

    @Test
    void 호출이_없으면_0() {
        when(repository.aggregateSince(any())).thenReturn(Collections.singletonList(new Object[]{0L, null, null, null}));

        AiStats stats = service.getStatsLast24Hours();

        assertThat(stats.totalCallCount()).isZero();
        assertThat(stats.failureRatePercent()).isZero();
        assertThat(List.of(stats.averageLatencyMilliseconds())).containsExactly(0.0);
    }
}
