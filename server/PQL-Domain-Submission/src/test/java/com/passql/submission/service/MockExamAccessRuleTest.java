package com.passql.submission.service;

import com.passql.submission.constant.MockExamRoundStatus;
import com.passql.submission.constant.MockExamRoundType;
import com.passql.submission.dto.mockexam.MockExamStartBlockReason;
import com.passql.submission.entity.MockExamRound;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 모의고사 시작 판정 (#866): 무료는 체험 회차 1회, 프로는 전체, 풀이 중 응시는 동시에 1개
 * 기출 회차 (#1079): 가장 최근 기출 1개는 무료, 체험 횟수와 별개
 */
class MockExamAccessRuleTest {

    private static final UUID ROUND_UUID = UUID.fromString("00000000-0000-0000-0000-000000000001");
    private static final UUID OTHER_ROUND_UUID = UUID.fromString("00000000-0000-0000-0000-000000000002");

    @Test
    void 무료_첫_응시는_체험_회차만_시작() {
        assertThat(MockExamAccessRule.findStartBlockReason(false, true, false, false, ROUND_UUID, null)).isNull();
        assertThat(MockExamAccessRule.findStartBlockReason(false, false, false, false, ROUND_UUID, null))
            .isEqualTo(MockExamStartBlockReason.PRO_REQUIRED);
    }

    @Test
    void 무료는_응시_기록이_있으면_체험_소진() {
        assertThat(MockExamAccessRule.findStartBlockReason(false, true, false, true, ROUND_UUID, null))
            .isEqualTo(MockExamStartBlockReason.FREE_TRIAL_USED);
    }

    @Test
    void 무료_기출_회차는_체험을_썼어도_시작() {
        assertThat(MockExamAccessRule.findStartBlockReason(false, false, true, true, ROUND_UUID, null)).isNull();
    }

    @Test
    void 프로는_재응시_가능() {
        assertThat(MockExamAccessRule.findStartBlockReason(true, false, false, true, ROUND_UUID, null)).isNull();
    }

    @Test
    void 풀이_중이면_같은_회차는_이어_풀고_다른_회차는_막음() {
        assertThat(MockExamAccessRule.findStartBlockReason(false, true, false, true, ROUND_UUID, ROUND_UUID)).isNull();
        assertThat(MockExamAccessRule.findStartBlockReason(true, false, true, true, ROUND_UUID, OTHER_ROUND_UUID))
            .isEqualTo(MockExamStartBlockReason.OTHER_ATTEMPT_IN_PROGRESS);
    }

    @Test
    void 무료_회차는_모의고사_가장_작은_번호와_기출_가장_최근_회차() {
        MockExamRound mockRoundTwo = round(MockExamRoundType.MOCK, 2);
        MockExamRound mockRoundThree = round(MockExamRoundType.MOCK, 3);
        MockExamRound pastRound61 = round(MockExamRoundType.PAST_EXAM, 61);
        MockExamRound pastRound62 = round(MockExamRoundType.PAST_EXAM, 62);

        MockExamFreeRounds freeRounds = MockExamFreeRounds.from(List.of(mockRoundThree, pastRound62, mockRoundTwo, pastRound61));

        assertThat(freeRounds.freeTrialRoundUuid()).isEqualTo(mockRoundTwo.getMockExamRoundUuid());
        assertThat(freeRounds.freePastExamRoundUuid()).isEqualTo(pastRound62.getMockExamRoundUuid());
        assertThat(freeRounds.isFreePastExamRound(pastRound61.getMockExamRoundUuid())).isFalse();
        assertThat(MockExamFreeRounds.from(List.of(mockRoundTwo)).freePastExamRoundUuid()).isNull();
    }

    private static MockExamRound round(MockExamRoundType roundType, int roundNumber) {
        return MockExamRound.builder()
            .mockExamRoundUuid(UUID.randomUUID())
            .roundType(roundType)
            .roundNumber(roundNumber)
            .title(roundNumber + "회")
            .status(MockExamRoundStatus.PUBLISHED)
            .build();
    }
}
