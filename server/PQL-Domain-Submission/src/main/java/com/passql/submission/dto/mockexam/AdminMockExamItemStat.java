package com.passql.submission.dto.mockexam;

import com.passql.submission.constant.MockExamSubject;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 문항 통계 (채점된 응시 기준): 정답률, 보기별 선택률, 안 고른 비율, 점검 신호, 미처리 신고 수
 * 점검 신호 2개: 정답률 30% 미만, 정답보다 많이 고른 오답 보기
 */
public record AdminMockExamItemStat(
    UUID itemUuid,
    int questionNumber,
    MockExamSubject subject,
    String topicName,
    UUID questionUuid,
    String stemPreview,
    String correctChoiceKey,
    long gradedCount,
    Integer correctRatePercent,
    Integer unansweredPercent,
    List<ChoicePick> choicePicks,
    boolean isLowAccuracy,
    boolean hasStrongerDistractor,
    long pendingReportCount
) {

    public record ChoicePick(String choiceKey, long pickCount, Integer pickPercent, boolean isCorrect) {
    }
}
