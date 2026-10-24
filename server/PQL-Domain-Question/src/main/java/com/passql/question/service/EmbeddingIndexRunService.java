package com.passql.question.service;

import com.passql.ai.dto.IndexQuestionsBulkResult;
import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.constant.EmbeddingIndexRunStatus;
import com.passql.question.constant.EmbeddingIndexRunType;
import com.passql.question.dto.EmbeddingIndexProgress;
import com.passql.question.dto.EmbeddingIndexRunItem;
import com.passql.question.dto.IndexQuestionPreview;
import com.passql.question.entity.EmbeddingIndexRun;
import com.passql.question.repository.EmbeddingIndexRunRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

/**
 * 임베딩 색인 실행 관리: 비동기 전체·실패 재시도 실행, 진행률(메모리), 실행 이력(DB), 실패 목록
 * 진행률 = 서버 메모리 한 건 (동시 실행 1건만 허용), 이력 = 시작 시 RUNNING 저장 > 끝나면 결과 갱신
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EmbeddingIndexRunService {

    // 화면에 보여 줄 최근 실행 이력 건수
    private static final int RECENT_RUN_COUNT = 10;
    // 서버 재시작 등으로 끝나지 못한 실행의 기록 사유
    private static final String INTERRUPTED_MESSAGE = "서버 재시작 등으로 중단됨";

    private final QuestionVectorIndexService questionVectorIndexService;
    private final EmbeddingIndexRunRepository embeddingIndexRunRepository;
    private final ApplicationEventPublisher eventPublisher;

    // 동시 실행 방지 (true 인 동안 새 비동기 실행 거부)
    private final AtomicBoolean isAsyncRunActive = new AtomicBoolean(false);
    // 현재 진행률 (실행 중이 아니면 idle)
    private final AtomicReference<EmbeddingIndexProgress> currentProgress =
            new AtomicReference<>(EmbeddingIndexProgress.idle());

    /** 전체 재색인 비동기 시작 (이미 실행 중이면 409) */
    public void startReindexAll(String adminUsername) {
        startAsyncRun(EmbeddingIndexRunType.ALL, null, adminUsername);
    }

    /** 직전 실행의 실패 문제만 비동기 재시도 (실패 목록 없으면 400, 이미 실행 중이면 409) */
    public void startRetryFailed(String adminUsername) {
        List<String> failedQuestionUuids = findLatestFailedQuestionUuids();
        if (failedQuestionUuids.isEmpty()) {
            throw new CustomException(ErrorCode.EMBEDDING_INDEX_TARGET_EMPTY);
        }
        startAsyncRun(EmbeddingIndexRunType.RETRY_FAILED, failedQuestionUuids, adminUsername);
    }

    /** 선택 문제 재색인 (요청 스레드에서 끝까지 실행, 이력만 남김) */
    public IndexQuestionsBulkResult runSelectedSynchronously(List<String> questionUuids, String adminUsername) {
        EmbeddingIndexRun run = embeddingIndexRunRepository.save(
                EmbeddingIndexRun.start(EmbeddingIndexRunType.SELECTED, adminUsername));
        publishAuditEvent(run, questionUuids.size());
        try {
            IndexQuestionsBulkResult result = questionVectorIndexService.reindexSelected(questionUuids);
            run.complete(result.total(), result.succeeded(), result.failed(), result.failedUuids());
            return result;
        } catch (RuntimeException e) {
            run.fail(e.getClass().getSimpleName());
            throw e;
        } finally {
            // 성공·실패 공통
            embeddingIndexRunRepository.save(run);
        }
    }

    /** 현재 진행률 (실행 중 아니면 idle) */
    public EmbeddingIndexProgress getCurrentProgress() {
        return currentProgress.get();
    }

    /** 최근 실행 이력 (최신순) */
    public List<EmbeddingIndexRunItem> listRecentRuns() {
        return embeddingIndexRunRepository.findAllByOrderByStartedAtDesc(PageRequest.of(0, RECENT_RUN_COUNT))
                .stream().map(EmbeddingIndexRunItem::from).toList();
    }

    /** 끝난 실행 중 가장 최근 1건 (마지막 실행 시각 표시용) */
    public Optional<EmbeddingIndexRunItem> findLastFinishedRun() {
        return embeddingIndexRunRepository.findFirstByStatusNotOrderByStartedAtDesc(EmbeddingIndexRunStatus.RUNNING)
                .map(EmbeddingIndexRunItem::from);
    }

    /** 가장 최근에 끝난 실행의 실패 문제 + 지문·토픽 미리보기 (재시도 대상) */
    public List<IndexQuestionPreview> listLatestFailedQuestions() {
        List<String> failedQuestionUuids = findLatestFailedQuestionUuids();
        return failedQuestionUuids.isEmpty() ? List.of() : questionVectorIndexService.describeQuestions(failedQuestionUuids);
    }

    /** 가장 최근에 끝난 실행의 실패 문제 UUID (그 실행이 전부 성공이면 빈 목록) */
    private List<String> findLatestFailedQuestionUuids() {
        return embeddingIndexRunRepository.findFirstByStatusNotOrderByStartedAtDesc(EmbeddingIndexRunStatus.RUNNING)
                .map(EmbeddingIndexRun::getFailedQuestionUuidList)
                .orElse(List.of());
    }

    /** 비동기 실행: 중복 실행 거부 > 중단된 이전 기록 정리 > 이력 저장 > 가상 스레드 시작 */
    private void startAsyncRun(EmbeddingIndexRunType runType, List<String> questionUuids, String adminUsername) {
        if (!isAsyncRunActive.compareAndSet(false, true)) {
            throw new CustomException(ErrorCode.EMBEDDING_INDEX_ALREADY_RUNNING);
        }
        EmbeddingIndexRun run;
        try {
            markInterruptedRuns();
            run = embeddingIndexRunRepository.save(EmbeddingIndexRun.start(runType, adminUsername));
            publishAuditEvent(run, questionUuids == null ? 0 : questionUuids.size());
        } catch (RuntimeException e) {
            // 스레드 시작 전 실패 시 실행 플래그 반환
            isAsyncRunActive.set(false);
            throw e;
        }
        currentProgress.set(new EmbeddingIndexProgress(true, runType, 0, 0, 0, 0));
        UUID runUuid = run.getEmbeddingIndexRunUuid();
        Thread.startVirtualThread(() -> executeRun(runUuid, runType, questionUuids));
    }

    /** 가상 스레드 본문: 색인(+전체면 남은 벡터 정리) > 결과 기록, 예외 시에도 플래그·진행률 정리 */
    private void executeRun(UUID runUuid, EmbeddingIndexRunType runType, List<String> questionUuids) {
        EmbeddingIndexRun run = embeddingIndexRunRepository.findById(runUuid).orElseThrow();
        try {
            QuestionVectorIndexService.IndexProgressListener progressListener =
                    (processedCount, totalCount, succeededCount, failedCount) -> currentProgress.set(
                            new EmbeddingIndexProgress(true, runType, processedCount, totalCount, succeededCount, failedCount));
            IndexQuestionsBulkResult result = runType == EmbeddingIndexRunType.ALL
                    ? questionVectorIndexService.reindexAll(progressListener)
                    : questionVectorIndexService.reindexSelected(questionUuids, progressListener);
            // 재색인은 추가만 하므로 삭제·비활성 문제의 벡터는 따로 정리 (#412)
            if (runType == EmbeddingIndexRunType.ALL) {
                questionVectorIndexService.pruneIndex();
            }
            run.complete(result.total(), result.succeeded(), result.failed(), result.failedUuids());
            log.info("[embedding run] completed : type={}, total={}, succeeded={}, failed={}",
                    runType, result.total(), result.succeeded(), result.failed());
        } catch (RuntimeException e) {
            // 원인 상세는 로그에만, 이력에는 예외 종류만
            log.error("[embedding run] failed : type={}", runType, e);
            run.fail(e.getClass().getSimpleName());
        } finally {
            // 성공·실패 공통
            embeddingIndexRunRepository.save(run);
            currentProgress.set(EmbeddingIndexProgress.idle());
            isAsyncRunActive.set(false);
        }
    }

    /** 실행 플래그를 잡은 시점의 RUNNING 기록 = 서버 재시작 등으로 끝나지 못한 실행 > FAILED */
    private void markInterruptedRuns() {
        List<EmbeddingIndexRun> interruptedRuns =
                embeddingIndexRunRepository.findByStatus(EmbeddingIndexRunStatus.RUNNING);
        interruptedRuns.forEach(interruptedRun -> interruptedRun.fail(INTERRUPTED_MESSAGE));
        embeddingIndexRunRepository.saveAll(interruptedRuns);
    }

    /** 감사 로그: 요청 스레드에서 발행 (관리자·IP 를 요청에서 읽음) */
    private void publishAuditEvent(EmbeddingIndexRun run, int requestedCount) {
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EMBEDDING_INDEX,
                run.getEmbeddingIndexRunUuid(), AdminAuditAction.REINDEX, null,
                AdminAuditEvent.summary("runType", run.getRunType(), "requestedCount", requestedCount)));
    }
}
