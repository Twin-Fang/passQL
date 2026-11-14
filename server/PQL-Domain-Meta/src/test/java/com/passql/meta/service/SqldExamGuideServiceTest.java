package com.passql.meta.service;

import com.passql.meta.dto.SqldExamGuideResponse;
import com.passql.meta.dto.SqldExamGuideResponse.Insights;
import com.passql.meta.dto.SqldExamGuideResponse.YearlyStatistic;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * SQLD 알아보기 (#1077): 원본 로드·연도 정렬, 인사이트 계산 규칙 (7년 전 대비 배수, 직전 연도 대비 증감)
 */
class SqldExamGuideServiceTest {

    @Test
    void 원본_로드와_인사이트_계산() {
        SqldExamGuideResponse guide = new SqldExamGuideService().getSqldExamGuide();

        assertThat(guide.yearlyStatistics()).hasSize(15);
        assertThat(guide.yearlyStatistics().get(0).year()).isEqualTo(2011);
        assertThat(guide.yearlyStatistics().get(14).year()).isEqualTo(2025);
        assertThat(guide.insights()).isEqualTo(new Insights(2025, 2018, 11.5, -15.61));
    }

    @Test
    void 연도_1개면_인사이트_없음() {
        List<YearlyStatistic> singleYear = List.of(new YearlyStatistic(2025, 10, 8, 4, 50.0));

        assertThat(SqldExamGuideService.calculateInsights(singleYear)).isNull();
    }
}
