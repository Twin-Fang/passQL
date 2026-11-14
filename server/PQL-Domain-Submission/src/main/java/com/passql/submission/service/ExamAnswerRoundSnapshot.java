package com.passql.submission.service;

import com.passql.submission.constant.ExamAnswerRoundStatus;
import com.passql.submission.dto.examanswer.ExamAnswerRoundResponse;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

/**
 * 회차 집계 1회분 (불변): 공개 응답·채점 기준 50개·참여자 총점 분포(오름차순)
 * ExamAnswerSnapshotCache 가 60초 보관
 */
public record ExamAnswerRoundSnapshot(UUID roundUuid, ExamAnswerRoundStatus status, ExamAnswerRoundResponse response,
                                      List<ExamAnswerKey> keys, int[] ascendingTotalScores) {

    /**
     * 내 총점 > 상위 % (1~100, 올림): 나보다 높은 참여자 수 + 1 / 참여자 수
     * 참여자 10명 미만이면 null (MockExamRankingCalculator 와 같은 기준), 분포에 아직 없는 새 답안은 1명 더해 계산
     */
    public Integer calculateTopPercent(int myTotalScore) {
        int higherScoreCount = countHigherScores(myTotalScore);
        int participantCount = Math.max(ascendingTotalScores.length, higherScoreCount + 1);
        if (participantCount < MockExamRankingCalculator.MINIMUM_RANKING_TAKER_COUNT) {
            return null;
        }
        int topPercent = (int) Math.ceil((higherScoreCount + 1) * 100.0 / participantCount);
        return Math.max(1, Math.min(100, topPercent));
    }

    /** 오름차순 분포에서 내 점수 초과 개수 (이진 탐색) */
    private int countHigherScores(int myTotalScore) {
        int insertionIndex = Arrays.binarySearch(ascendingTotalScores, myTotalScore + 1);
        int firstHigherIndex = insertionIndex >= 0 ? insertionIndex : -insertionIndex - 1;
        // 같은 점수가 여러 개면 binarySearch 가 아무 위치나 줄 수 있어 첫 위치로 당김
        while (firstHigherIndex > 0 && ascendingTotalScores[firstHigherIndex - 1] > myTotalScore) {
            firstHigherIndex--;
        }
        return ascendingTotalScores.length - firstHigherIndex;
    }
}
