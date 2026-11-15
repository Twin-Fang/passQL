package com.passql.submission.service;

import com.passql.submission.constant.MockExamRoundType;
import com.passql.submission.entity.MockExamRound;

import java.util.Comparator;
import java.util.List;
import java.util.UUID;

/**
 * 무료 회원이 시작할 수 있는 회차 2개 판정 (순수): 공개 회차 목록 > 무료 체험 회차, 무료 기출 회차
 * 무료 체험 = MOCK 중 번호가 가장 작은 회차(응시 기록 있으면 소진), 무료 기출 = PAST_EXAM 중 가장 최근 회차(횟수 제한 없음, #1079)
 */
public record MockExamFreeRounds(UUID freeTrialRoundUuid, UUID freePastExamRoundUuid) {

    /** 공개 회차 목록 > 무료 회차 2개 (해당 종류 회차가 없으면 null) */
    public static MockExamFreeRounds from(List<MockExamRound> publishedRounds) {
        UUID freeTrialRoundUuid = publishedRounds.stream()
            .filter(round -> round.getRoundType() == MockExamRoundType.MOCK)
            .min(Comparator.comparing(MockExamRound::getRoundNumber))
            .map(MockExamRound::getMockExamRoundUuid)
            .orElse(null);
        UUID freePastExamRoundUuid = publishedRounds.stream()
            .filter(MockExamRound::isPastExam)
            .max(Comparator.comparing(MockExamRound::getRoundNumber))
            .map(MockExamRound::getMockExamRoundUuid)
            .orElse(null);
        return new MockExamFreeRounds(freeTrialRoundUuid, freePastExamRoundUuid);
    }

    public boolean isFreeTrialRound(UUID roundUuid) {
        return roundUuid != null && roundUuid.equals(freeTrialRoundUuid);
    }

    public boolean isFreePastExamRound(UUID roundUuid) {
        return roundUuid != null && roundUuid.equals(freePastExamRoundUuid);
    }
}
