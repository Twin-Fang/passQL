package com.passql.question.dto;

import com.passql.question.constant.EmbeddingIndexRunStatus;
import com.passql.question.constant.EmbeddingIndexRunType;
import com.passql.question.entity.EmbeddingIndexRun;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 임베딩 색인 실행 이력 1건 (화면 표시용, 실패 UUID 목록은 제외)
 * durationSeconds: 끝나지 않은 실행이면 null
 */
public record EmbeddingIndexRunItem(
        UUID embeddingIndexRunUuid,
        EmbeddingIndexRunType runType,
        EmbeddingIndexRunStatus status,
        LocalDateTime startedAt,
        LocalDateTime finishedAt,
        Long durationSeconds,
        Integer totalCount,
        Integer succeededCount,
        Integer failedCount,
        String errorMessage,
        String triggeredByAdminUsername
) {
    public static EmbeddingIndexRunItem from(EmbeddingIndexRun run) {
        Long durationSeconds = run.getFinishedAt() == null
                ? null : Duration.between(run.getStartedAt(), run.getFinishedAt()).toSeconds();
        return new EmbeddingIndexRunItem(run.getEmbeddingIndexRunUuid(), run.getRunType(), run.getStatus(),
                run.getStartedAt(), run.getFinishedAt(), durationSeconds, run.getTotalCount(),
                run.getSucceededCount(), run.getFailedCount(), run.getErrorMessage(),
                run.getTriggeredByAdminUsername());
    }
}
