package com.passql.question.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.question.constant.EmbeddingIndexRunStatus;
import com.passql.question.constant.EmbeddingIndexRunType;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

/**
 * 임베딩 색인 실행 이력 1건: 종류, 상태, 시작·종료 시각, 건수, 실패 문제 UUID, 실행한 관리자
 */
@Entity
@Table(name = "embedding_index_run")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class EmbeddingIndexRun extends BaseEntity {

    // 실패 문제 UUID 구분자 (줄바꿈)
    private static final String FAILED_UUID_DELIMITER = "\n";
    // 오류 메시지 최대 길이 (embedding_index_run.error_message VARCHAR(500))
    private static final int MAX_ERROR_MESSAGE_LENGTH = 500;

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID embeddingIndexRunUuid;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private EmbeddingIndexRunType runType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private EmbeddingIndexRunStatus status;

    @Column(nullable = false)
    private LocalDateTime startedAt;

    private LocalDateTime finishedAt;

    @Column(nullable = false)
    private Integer totalCount;

    @Column(nullable = false)
    private Integer succeededCount;

    @Column(nullable = false)
    private Integer failedCount;

    // 실패 문제 UUID 줄바꿈 구분 (재시도 대상)
    @Column(columnDefinition = "TEXT")
    private String failedQuestionUuids;

    @Column(length = 500)
    private String errorMessage;

    @Column(length = 100)
    private String triggeredByAdminUsername;

    /** 실행 시작 기록 (RUNNING, 건수 0) */
    public static EmbeddingIndexRun start(EmbeddingIndexRunType runType, String triggeredByAdminUsername) {
        EmbeddingIndexRun run = new EmbeddingIndexRun();
        run.runType = runType;
        run.status = EmbeddingIndexRunStatus.RUNNING;
        run.startedAt = LocalDateTime.now();
        run.totalCount = 0;
        run.succeededCount = 0;
        run.failedCount = 0;
        run.triggeredByAdminUsername = triggeredByAdminUsername;
        return run;
    }

    /** 끝까지 실행 완료 (실패 문제는 목록으로 보관) */
    public void complete(int totalCount, int succeededCount, int failedCount, List<String> failedQuestionUuidList) {
        this.status = EmbeddingIndexRunStatus.COMPLETED;
        this.finishedAt = LocalDateTime.now();
        this.totalCount = totalCount;
        this.succeededCount = succeededCount;
        this.failedCount = failedCount;
        this.failedQuestionUuids = failedQuestionUuidList.isEmpty()
                ? null : String.join(FAILED_UUID_DELIMITER, failedQuestionUuidList);
    }

    /** 실행 중단 (예외·서버 재시작) */
    public void fail(String errorMessage) {
        this.status = EmbeddingIndexRunStatus.FAILED;
        this.finishedAt = LocalDateTime.now();
        this.errorMessage = errorMessage != null && errorMessage.length() > MAX_ERROR_MESSAGE_LENGTH
                ? errorMessage.substring(0, MAX_ERROR_MESSAGE_LENGTH) : errorMessage;
    }

    /** 실패 문제 UUID 목록 (없으면 빈 목록) */
    public List<String> getFailedQuestionUuidList() {
        if (failedQuestionUuids == null || failedQuestionUuids.isBlank()) {
            return List.of();
        }
        return Arrays.asList(failedQuestionUuids.split(FAILED_UUID_DELIMITER));
    }
}
