package com.passql.question.dto;

import com.passql.question.constant.ExecutionMode;

import java.time.LocalDateTime;
import java.util.UUID;

/** 관리자 문제 목록 행 (공개 QuestionSummary + 활성 여부) */
public record AdminQuestionListItem(
        UUID questionUuid,
        String topicCode,
        String topicName,
        Integer difficulty,
        ExecutionMode executionMode,
        String stemPreview,
        LocalDateTime createdAt,
        Boolean isActive
) {
    public static AdminQuestionListItem of(QuestionSummary summary, Boolean isActive) {
        return new AdminQuestionListItem(summary.questionUuid(), summary.topicCode(), summary.topicName(),
                summary.difficulty(), summary.executionMode(), summary.stemPreview(), summary.createdAt(), isActive);
    }
}
