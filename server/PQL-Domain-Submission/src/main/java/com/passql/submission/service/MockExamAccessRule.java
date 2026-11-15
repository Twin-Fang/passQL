package com.passql.submission.service;

import com.passql.submission.dto.mockexam.MockExamStartBlockReason;

import java.util.UUID;

/**
 * 회차 시작 판정 (순수): 풀이 중 응시 > 등급 > 무료 기출 회차 > 무료 체험 1회
 * 무료 체험 = 모의고사 회차 중 번호가 가장 작은 회차, 모의고사 응시 기록이 하나라도 있으면 소진 (제출 여부·회차 무관)
 * 무료 기출 = 가장 최근 기출 회차, 체험 횟수와 별개로 늘 시작 가능 (#1079)
 */
public final class MockExamAccessRule {

    private MockExamAccessRule() {
    }

    /**
     * 시작 불가 이유 (시작 가능하면 null)
     * @param hasAnyMockRoundAttempt 모의고사(MOCK) 회차 응시 기록 여부 (기출 회차 응시는 넣지 않음)
     * @param inProgressRoundUuidOrNull 풀이 중 응시의 회차 (없으면 null)
     */
    public static MockExamStartBlockReason findStartBlockReason(boolean isPro, boolean isFreeTrialRound,
                                                                boolean isFreePastExamRound, boolean hasAnyMockRoundAttempt,
                                                                UUID roundUuid, UUID inProgressRoundUuidOrNull) {
        // 풀이 중 응시: 같은 회차는 이어 풀기, 다른 회차는 막음 (동시에 1개)
        if (inProgressRoundUuidOrNull != null) {
            return inProgressRoundUuidOrNull.equals(roundUuid) ? null : MockExamStartBlockReason.OTHER_ATTEMPT_IN_PROGRESS;
        }
        if (isPro || isFreePastExamRound) {
            return null;
        }
        if (!isFreeTrialRound) {
            return MockExamStartBlockReason.PRO_REQUIRED;
        }
        return hasAnyMockRoundAttempt ? MockExamStartBlockReason.FREE_TRIAL_USED : null;
    }
}
