package com.passql.application.service;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

/** 통계 AI 코멘트 최근 활동 텍스트 (#567): 오늘 날짜와 며칠 전인지 함께 */
class AiCommentRecentActivityTest {

    private static final LocalDate TODAY = LocalDate.of(2026, 10, 21);

    @Test
    void 오늘_활동은_오늘로_표시한다() {
        assertThat(AiCommentService.toRecentActivitySummary(3, TODAY, TODAY))
                .contains("오늘: 2026-10-21")
                .contains("최근 활동일: 2026-10-21 (오늘)");
    }

    @Test
    void 지난_활동은_며칠_전인지_표시한다() {
        assertThat(AiCommentService.toRecentActivitySummary(1, TODAY.minusDays(3), TODAY))
                .contains("최근 활동일: 2026-10-18 (3일 전)");
    }

    @Test
    void 활동이_없으면_없음() {
        assertThat(AiCommentService.toRecentActivitySummary(0, null, TODAY)).contains("최근 활동일: 없음");
    }
}
