package com.passql.application.monitor;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/** 모니터링 필터 보정: 허용 밖 기간·상태는 기본값, URI 는 공백 제거·길이 제한 */
class MonitorFilterTest {

    @Test
    void 허용된_값은_그대로_쓴다() {
        MonitorFilter filter = MonitorFilter.of(6, "ERROR", " /api/questions ");

        assertThat(filter.hours()).isEqualTo(6);
        assertThat(filter.executionStatus()).isEqualTo("ERROR");
        assertThat(filter.uriKeyword()).isEqualTo("/api/questions");
    }

    @Test
    void 허용_밖_값은_기본값으로_보정한다() {
        MonitorFilter filter = MonitorFilter.of(5, "DROP TABLE", null);

        assertThat(filter.hours()).isEqualTo(MonitorFilter.DEFAULT_HOURS);
        assertThat(filter.executionStatus()).isEmpty();
        assertThat(filter.uriKeyword()).isEmpty();
        assertThat(MonitorFilter.of(null, null, null).hours()).isEqualTo(MonitorFilter.DEFAULT_HOURS);
    }

    @Test
    void URI_키워드는_100자까지만_쓴다() {
        assertThat(MonitorFilter.of(24, "", "a".repeat(150)).uriKeyword()).hasSize(100);
    }
}
