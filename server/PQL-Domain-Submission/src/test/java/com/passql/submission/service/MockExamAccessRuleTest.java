package com.passql.submission.service;

import com.passql.submission.dto.mockexam.MockExamStartBlockReason;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 모의고사 시작 판정 (#866): 무료는 체험 회차 1회, 프로는 전체, 풀이 중 응시는 동시에 1개
 */
class MockExamAccessRuleTest {

    private static final UUID ROUND_UUID = UUID.fromString("00000000-0000-0000-0000-000000000001");
    private static final UUID OTHER_ROUND_UUID = UUID.fromString("00000000-0000-0000-0000-000000000002");

    @Test
    void 무료_첫_응시는_체험_회차만_시작() {
        assertThat(MockExamAccessRule.findStartBlockReason(false, true, false, ROUND_UUID, null)).isNull();
        assertThat(MockExamAccessRule.findStartBlockReason(false, false, false, ROUND_UUID, null))
            .isEqualTo(MockExamStartBlockReason.PRO_REQUIRED);
    }

    @Test
    void 무료는_응시_기록이_있으면_체험_소진() {
        assertThat(MockExamAccessRule.findStartBlockReason(false, true, true, ROUND_UUID, null))
            .isEqualTo(MockExamStartBlockReason.FREE_TRIAL_USED);
    }

    @Test
    void 프로는_재응시_가능() {
        assertThat(MockExamAccessRule.findStartBlockReason(true, false, true, ROUND_UUID, null)).isNull();
    }

    @Test
    void 풀이_중이면_같은_회차는_이어_풀고_다른_회차는_막음() {
        assertThat(MockExamAccessRule.findStartBlockReason(false, true, true, ROUND_UUID, ROUND_UUID)).isNull();
        assertThat(MockExamAccessRule.findStartBlockReason(true, false, true, ROUND_UUID, OTHER_ROUND_UUID))
            .isEqualTo(MockExamStartBlockReason.OTHER_ATTEMPT_IN_PROGRESS);
    }
}
