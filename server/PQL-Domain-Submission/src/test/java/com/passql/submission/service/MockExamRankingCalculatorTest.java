package com.passql.submission.service;

import com.passql.submission.dto.mockexam.MockExamRanking;
import com.passql.submission.dto.mockexam.MockExamRoundScoreProjection;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 모의고사 회차 순위 (#1041): 응시자 10명 미만 null, 동점 같은 순위, 재응시는 첫 응시만 분포에
 */
class MockExamRankingCalculatorTest {

    private static final UUID MY_MEMBER_UUID = UUID.randomUUID();

    @Test
    void 응시자가_10명_미만이면_순위_없음() {
        // 다른 회원 8명 + 나 = 9명
        List<MockExamRoundScoreProjection> submittedScores = otherMemberScores(8, 50);

        assertThat(MockExamRankingCalculator.rank(submittedScores, MY_MEMBER_UUID, 70)).isNull();
    }

    @Test
    void 동점은_같은_순위이고_상위_퍼센트는_올림() {
        // 다른 회원: 90점 2명, 70점 3명, 50점 6명 + 나 70점 = 12명
        List<MockExamRoundScoreProjection> submittedScores = new ArrayList<>();
        submittedScores.addAll(otherMemberScores(2, 90));
        submittedScores.addAll(otherMemberScores(3, 70));
        submittedScores.addAll(otherMemberScores(6, 50));

        MockExamRanking ranking = MockExamRankingCalculator.rank(submittedScores, MY_MEMBER_UUID, 70);

        // 나보다 높은 2명 > 3위, 3 * 100 / 12 = 25
        assertThat(ranking).isEqualTo(new MockExamRanking(3, 12, 25));
    }

    @Test
    void 재응시_점수는_분포에_넣지_않고_회원별_첫_응시만_셈() {
        // 다른 회원 9명 첫 응시 40점, 그중 1명이 재응시 100점
        List<MockExamRoundScoreProjection> submittedScores = new ArrayList<>(otherMemberScores(9, 40));
        submittedScores.add(new MockExamRoundScoreProjection(submittedScores.get(0).memberUuid(), 100));
        // 내 첫 응시 30점은 분포에서 빼고 지금 점수 60점으로 위치 계산
        submittedScores.add(0, new MockExamRoundScoreProjection(MY_MEMBER_UUID, 30));

        MockExamRanking ranking = MockExamRankingCalculator.rank(submittedScores, MY_MEMBER_UUID, 60);

        assertThat(ranking).isEqualTo(new MockExamRanking(1, 10, 10));
    }

    private static List<MockExamRoundScoreProjection> otherMemberScores(int memberCount, int totalScore) {
        List<MockExamRoundScoreProjection> submittedScores = new ArrayList<>();
        for (int memberIndex = 0; memberIndex < memberCount; memberIndex++) {
            submittedScores.add(new MockExamRoundScoreProjection(UUID.randomUUID(), totalScore));
        }
        return submittedScores;
    }
}
