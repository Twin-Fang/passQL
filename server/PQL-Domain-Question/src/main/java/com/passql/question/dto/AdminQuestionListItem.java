package com.passql.question.dto;

import com.passql.question.constant.ExecutionMode;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 관리자 문제 목록 행 (공개 QuestionSummary + 활성 여부 + 품질 지표 + 내부 태그 묶음)
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
        Long reportCount,
        // 내부 관리 태그 네임스페이스 묶음 (#1117, 태그 없으면 빈 목록)
        List<QuestionInternalTagGroup> internalTagGroups
) {
    public static AdminQuestionListItem of(QuestionSummary summary, Boolean isActive,
                                           List<QuestionInternalTagGroup> internalTagGroups) {
        return new AdminQuestionListItem(summary.questionUuid(), summary.topicCode(), summary.topicName(),
                summary.difficulty(), summary.executionMode(), summary.stemPreview(), summary.createdAt(), isActive,
                null, null, null, internalTagGroups);
    }

    /** 품질 지표 붙인 새 행 */
    public AdminQuestionListItem attachQualityStat(Long solveCount, Double accuracyPercent, Long reportCount) {
        return new AdminQuestionListItem(questionUuid, topicCode, topicName, difficulty, executionMode, stemPreview,
                createdAt, isActive, solveCount, accuracyPercent, reportCount, internalTagGroups);
    }
}
