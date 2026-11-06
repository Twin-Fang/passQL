package com.passql.submission.service;

import com.passql.submission.dto.mockexam.MockExamStartBlockReason;

import java.util.UUID;

/**
 * 회차 시작 판정 (순수): 풀이 중 응시 > 등급 > 무료 체험 1회
 * 무료 체험 = 공개 회차 중 번호가 가장 작은 회차, 응시 기록이 하나라도 있으면 소진 (제출 여부·회차 무관)
 */
public final class MockExamAccessRule {

    private MockExamAccessRule() {
    }

    /**
     * 시작 불가 이유 (시작 가능하면 null)
     * @param inProgressRoundUuidOrNull 풀이 중 응시의 회차 (없으면 null)
     */
    public static MockExamStartBlockReason findStartBlockReason(boolean isPro, boolean isFreeTrialRound,
                                                                boolean hasAnyAttempt, UUID roundUuid,
                                                                UUID inProgressRoundUuidOrNull) {
        // 풀이 중 응시: 같은 회차는 이어 풀기, 다른 회차는 막음 (동시에 1개)
        if (inProgressRoundUuidOrNull != null) {
            return inProgressRoundUuidOrNull.equals(roundUuid) ? null : MockExamStartBlockReason.OTHER_ATTEMPT_IN_PROGRESS;
        }
        if (isPro) {
            return null;
        }
        if (!isFreeTrialRound) {
            return MockExamStartBlockReason.PRO_REQUIRED;
        }
        return hasAnyAttempt ? MockExamStartBlockReason.FREE_TRIAL_USED : null;
    }
}
