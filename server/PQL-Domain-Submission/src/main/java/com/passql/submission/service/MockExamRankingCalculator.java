package com.passql.submission.service;

import com.passql.submission.dto.mockexam.MockExamRanking;
import com.passql.submission.dto.mockexam.MockExamRoundScoreProjection;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 회차 순위 (순수 계산): 회원별 첫 제출 점수 분포 > 내 회원 빼고 지금 점수 넣기 > 순위·상위 %
 * 재응시 점수는 분포에 넣지 않음 (재응시로 순위 올리기 방지)
 */
public final class MockExamRankingCalculator {

    // 순위 공개 최소 응시자 수 (회원 수, 미만이면 순위 없음)
    public static final int MINIMUM_RANKING_TAKER_COUNT = 10;

    private MockExamRankingCalculator() {
    }

    /**
     * 제출 응시 목록(제출 시각 오름차순) + 내 회원·지금 점수 > 순위 (응시자 10명 미만이면 null)
     */
    public static MockExamRanking rank(List<MockExamRoundScoreProjection> submittedScoresInSubmitOrder,
                                       UUID memberUuid, int currentScore) {
        // 회원별 첫 제출 점수 (내 회원 제외)
        Map<UUID, Integer> firstScoreByMemberUuid = new LinkedHashMap<>();
        for (MockExamRoundScoreProjection submittedScore : submittedScoresInSubmitOrder) {
            if (!submittedScore.memberUuid().equals(memberUuid)) {
                firstScoreByMemberUuid.putIfAbsent(submittedScore.memberUuid(), submittedScore.totalScore());
            }
        }

        // 내 지금 점수 포함 응시자 수
        int takerCount = firstScoreByMemberUuid.size() + 1;
        if (takerCount < MINIMUM_RANKING_TAKER_COUNT) {
            return null;
        }

        // 순위 = 나보다 높은 회원 수 + 1 (동점은 같은 순위), 상위 % = 올림 후 1~100
        int higherScoreMemberCount = (int) firstScoreByMemberUuid.values().stream()
            .filter(firstScore -> firstScore > currentScore)
            .count();
        int rankPosition = higherScoreMemberCount + 1;
        int topPercent = (int) Math.ceil(rankPosition * 100.0 / takerCount);
        return new MockExamRanking(rankPosition, takerCount, Math.max(1, Math.min(100, topPercent)));
    }
}
