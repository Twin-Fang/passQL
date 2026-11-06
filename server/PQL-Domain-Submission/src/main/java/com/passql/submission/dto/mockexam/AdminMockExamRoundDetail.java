package com.passql.submission.dto.mockexam;

import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ExecutionMode;
import com.passql.submission.constant.MockExamRoundStatus;
import com.passql.submission.constant.MockExamSubject;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 관리자 회차 상세: 회차 정보, 50문항 표, 공개 검사, 응시 수 (되돌리기 가능 판정)
 */
public record AdminMockExamRoundDetail(
    UUID roundUuid,
    int roundNumber,
    String title,
    MockExamRoundStatus status,
    LocalDateTime publishedAt,
    long attemptCount,
    List<ItemRow> items,
    AdminMockExamPublishCheck publishCheck
) {

    public record ItemRow(
        UUID itemUuid,
        int questionNumber,
        MockExamSubject subject,
        UUID topicUuid,
        String topicName,
        UUID questionUuid,
        Integer difficulty,
        ExecutionMode executionMode,
        String stemPreview,
        UUID choiceSetUuid,
        ChoiceSetSource choiceSetSource,
        boolean isChoiceSetEligible
    ) {
    }
}
