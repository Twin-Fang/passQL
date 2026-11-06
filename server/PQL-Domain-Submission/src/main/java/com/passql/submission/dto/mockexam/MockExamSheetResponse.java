package com.passql.submission.dto.mockexam;

import com.passql.question.dto.QuestionSchemaTable;
import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.constant.MockExamSubject;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;
import java.util.UUID;

/**
 * 응시 시험지: 남은 시간(서버 기준 초), 50문항(정답 없음)·내 답·표시
 * status 가 SUBMITTED 면 questions 는 비고 결과 화면으로 이동
 */
public record MockExamSheetResponse(
    UUID attemptUuid,
    UUID roundUuid,
    int roundNumber,
    String title,
    MockExamAttemptStatus status,
    @Schema(description = "응답 시점 남은 시간 (초, 0 이상). 앱은 받은 순간부터 단조 시계로 줄임") long remainingSeconds,
    List<SheetQuestion> questions
) {

    public record SheetQuestion(
        int questionNumber,
        MockExamSubject subject,
        @Schema(nullable = true) String topicName,
        String stem,
        @Schema(nullable = true) String schemaDisplay,
        List<QuestionSchemaTable> schemaTables,
        List<MockExamChoice> choices,
        @Schema(nullable = true) String selectedChoiceKey,
        boolean isFlagged
    ) {
    }
}
