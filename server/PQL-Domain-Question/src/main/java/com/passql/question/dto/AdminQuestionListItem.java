package com.passql.question.dto;

import com.passql.question.constant.ExecutionMode;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 관리자 문제 목록 행 (공개 QuestionSummary + 활성 여부 + 품질 지표)
 * 품질 지표(solveCount 등)는 attachQualityStat 전에는 null, accuracyPercent 는 풀이 0건이면 null
 */
public record AdminQuestionListItem(
        UUID questionUuid,
        String topicCode,
        String topicName,
        Integer difficulty,
        ExecutionMode executionMode,
        String stemPreview,
        LocalDateTime createdAt,
        Boolean isActive,
        Long solveCount,
        Double accuracyPercent,
        Long reportCount
) {
    public static AdminQuestionListItem of(QuestionSummary summary, Boolean isActive) {
        return new AdminQuestionListItem(summary.questionUuid(), summary.topicCode(), summary.topicName(),
                summary.difficulty(), summary.executionMode(), summary.stemPreview(), summary.createdAt(), isActive,
                null, null, null);
    }

    /** 품질 지표 붙인 새 행 */
    public AdminQuestionListItem attachQualityStat(Long solveCount, Double accuracyPercent, Long reportCount) {
        return new AdminQuestionListItem(questionUuid, topicCode, topicName, difficulty, executionMode, stemPreview,
                createdAt, isActive, solveCount, accuracyPercent, reportCount);
    }
}
