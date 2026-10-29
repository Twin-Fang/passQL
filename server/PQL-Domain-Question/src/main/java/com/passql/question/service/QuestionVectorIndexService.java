package com.passql.question.service;

import com.passql.ai.client.AiGatewayClient;
import com.passql.ai.dto.IndexQuestionRequest;
import com.passql.ai.dto.IndexQuestionResult;
import com.passql.ai.dto.IndexQuestionsBulkResult;
import com.passql.ai.dto.IndexStatusRequest;
import com.passql.ai.dto.IndexStatusResult;
import com.passql.ai.dto.PruneIndexResult;
import com.passql.common.util.TextPreview;
import com.passql.question.dto.IndexQuestionPreview;
import com.passql.meta.entity.Subtopic;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.SubtopicRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.entity.Question;
import com.passql.question.event.QuestionSavedEvent;
import com.passql.question.event.QuestionsDeactivatedEvent;
import com.passql.question.repository.QuestionConceptTagRepository;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 문제 벡터 색인(Qdrant): 등록 직후 비동기 적재, 전체·선택 재색인, 삭제·비활성 문제 벡터 정리
 * 색인 요청 1건 = 토픽·서브토픽 이름 + 개념 태그 키 + 지문
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class QuestionVectorIndexService {

    // 지문을 찾을 수 없는 문제의 미리보기 문구
    private static final String DELETED_QUESTION_PREVIEW = "(삭제된 문제)";

    private final AiGatewayClient aiGatewayClient;
    private final QuestionRepository questionRepository;
    private final QuestionConceptTagRepository questionConceptTagRepository;
    private final TopicRepository topicRepository;
    private final SubtopicRepository subtopicRepository;

    /**
     * 활성 문제 전체를 Qdrant에 재색인한다 (관리자 "전체 색인" 버튼용).
     * 타임아웃 문제를 방지하기 위해 1개씩 순차 전송한다.
     */
    @Transactional(readOnly = true)
    public IndexQuestionsBulkResult reindexAll() {
        return reindexAll(IndexProgressListener.NONE);
    }

    /** 활성 문제 전체 재색인 + 문제 1건마다 진행률 통지 (비동기 실행 이력용) */
    @Transactional(readOnly = true)
    public IndexQuestionsBulkResult reindexAll(IndexProgressListener progressListener) {
        List<Question> questions = questionRepository.findByIsActiveTrue();
        log.info("[reindex-all] 전체 재색인 시작: 활성 문제 수={}", questions.size());

        List<IndexQuestionRequest> requests = questions.stream()
                .map(q -> buildIndexRequest(q))
                .toList();

        return indexOneByOne(requests, "reindex-all", progressListener);
    }

    /** 색인 진행률 통지: 처리한 건수 / 전체 건수 / 성공 / 실패 (문제 1건 처리할 때마다) */
    @FunctionalInterface
    public interface IndexProgressListener {
        IndexProgressListener NONE = (processedCount, totalCount, succeededCount, failedCount) -> { };

        void onProgress(int processedCount, int totalCount, int succeededCount, int failedCount);
    }

    /**
     * 문제 UUID 목록 > 화면용 한 줄 요약 (지문 미리보기, 토픽 이름, 난이도)
     * 문제·토픽은 일괄 조회 (N+1 방지), 삭제된 문제는 "(삭제된 문제)"
     */
    @Transactional(readOnly = true)
    public List<IndexQuestionPreview> describeQuestions(List<String> questionUuids) {
        List<UUID> questionUuidList = questionUuids.stream().map(UUID::fromString).toList();
        Map<UUID, Question> questionByUuid = questionRepository.findAllById(questionUuidList).stream()
                .collect(Collectors.toMap(Question::getQuestionUuid, question -> question));
        List<UUID> topicUuids = questionByUuid.values().stream()
                .map(Question::getTopicUuid).filter(Objects::nonNull).distinct().toList();
        Map<UUID, String> topicNameByUuid = topicRepository.findAllById(topicUuids).stream()
                .collect(Collectors.toMap(Topic::getTopicUuid, Topic::getDisplayName));

        return questionUuidList.stream().map(questionUuid -> {
            Question question = questionByUuid.get(questionUuid);
            if (question == null) {
                return new IndexQuestionPreview(questionUuid.toString(), DELETED_QUESTION_PREVIEW, "", null);
            }
            return new IndexQuestionPreview(questionUuid.toString(),
                    TextPreview.truncateWithEllipsis(question.getStem(), TextPreview.QUESTION_SUMMARY_STEM_LENGTH),
                    topicNameByUuid.getOrDefault(question.getTopicUuid(), ""), question.getDifficulty());
        }).toList();
    }

    /** 활성 문제 전체 색인 상태 조회 (AI 서버 장애 > null, 화면은 오류 배너) */
    @Transactional(readOnly = true)
    public IndexStatusResult findIndexStatusOfActiveQuestions() {
        List<String> activeUuids = questionRepository.findAllActiveQuestionUuids();
        log.info("[index-status] DB 활성 문제 수={}", activeUuids.size());
        try {
            return aiGatewayClient.getIndexStatus(new IndexStatusRequest(activeUuids));
        } catch (Exception e) {
            log.warn("[index-status] AI 서버 색인 상태 조회 실패: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 활성 문제에 없는 Qdrant 벡터(삭제·비활성 문제)를 정리한다 (#412).
     * 문제 삭제 직후와 전체 재색인 뒤에 호출한다. 활성 문제가 0개면 컬렉션을 비우게 되므로 건너뛴다.
     *
     * @return 정리 결과, 건너뛰었거나 AI 서버 실패면 null
     */
    @Transactional(readOnly = true)
    public PruneIndexResult pruneIndex() {
        List<String> activeUuids = questionRepository.findAllActiveQuestionUuids();
        if (activeUuids.isEmpty()) {
            log.warn("[prune-index] 활성 문제 0개 — 정리 건너뜀");
            return null;
        }
        return aiGatewayClient.pruneIndex(new IndexStatusRequest(activeUuids));
    }

    /**
     * 선택한 문제 UUID 목록을 Qdrant에 재색인한다 (관리자 "선택 색인" 버튼용).
     * 타임아웃 문제를 방지하기 위해 1개씩 순차 전송한다.
     * 존재하지 않는 UUID는 조용히 스킵한다.
     */
    @Transactional(readOnly = true)
    public IndexQuestionsBulkResult reindexSelected(List<String> questionUuids) {
        return reindexSelected(questionUuids, IndexProgressListener.NONE);
    }

    /** 선택 문제 재색인 + 문제 1건마다 진행률 통지 (선택·실패 재시도 공통) */
    @Transactional(readOnly = true)
    public IndexQuestionsBulkResult reindexSelected(List<String> questionUuids, IndexProgressListener progressListener) {
        log.info("[reindex-selected] 선택 재색인 시작: 요청 수={}", questionUuids.size());

        List<IndexQuestionRequest> requests = questionUuids.stream()
                .map(uuidStr -> questionRepository.findById(UUID.fromString(uuidStr)).orElse(null))
                .filter(q -> q != null)
                .map(q -> buildIndexRequest(q))
                .toList();

        log.info("[reindex-selected] 실제 처리할 문제 수={}", requests.size());
        return indexOneByOne(requests, "reindex-selected", progressListener);
    }

    /**
     * IndexQuestionRequest 목록을 1개씩 순차 전송하여 결과를 집계한다.
     * bulk 전송 시 타임아웃이 발생하는 경우를 방지한다.
     */
    private IndexQuestionsBulkResult indexOneByOne(List<IndexQuestionRequest> requests, String logPrefix,
                                                   IndexProgressListener progressListener) {
        int succeeded = 0;
        int failed = 0;
        List<String> failedUuids = new java.util.ArrayList<>();

        int total = requests.size();
        for (int i = 0; i < total; i++) {
            IndexQuestionRequest request = requests.get(i);
            try {
                var result = aiGatewayClient.indexQuestion(request);
                if (result != null) {
                    succeeded++;
                } else {
                    failed++;
                    failedUuids.add(request.questionUuid());
                    log.warn("[{}] 색인 결과 null: uuid={}", logPrefix, request.questionUuid());
                }
            } catch (Exception e) {
                failed++;
                failedUuids.add(request.questionUuid());
                log.warn("[{}] 색인 실패: uuid={}, error={}", logPrefix, request.questionUuid(), e.getMessage());
            }
            // 매 문제마다 진행 상황 로그
            log.info("[{}] 진행: {}/{} (성공={}, 실패={})", logPrefix, i + 1, total, succeeded, failed);
            progressListener.onProgress(i + 1, total, succeeded, failed);
        }

        log.info("[{}] 완료: total={}, succeeded={}, failed={}", logPrefix, requests.size(), succeeded, failed);
        return new IndexQuestionsBulkResult(requests.size(), succeeded, failed, failedUuids);
    }

    /**
     * Question 엔티티 → IndexQuestionRequest 변환.
     * 토픽/서브토픽 이름과 태그 키 조회를 포함한다.
     */
    private IndexQuestionRequest buildIndexRequest(Question question) {
        String topicName = topicRepository.findById(question.getTopicUuid())
                .map(Topic::getDisplayName)
                .orElse("");
        String subtopicName = question.getSubtopicUuid() != null
                ? subtopicRepository.findById(question.getSubtopicUuid())
                        .map(Subtopic::getDisplayName)
                        .orElse(null)
                : null;
        List<String> tagKeys = questionConceptTagRepository
                .findTagKeysByQuestionUuid(question.getQuestionUuid().toString());

        return new IndexQuestionRequest(
                question.getQuestionUuid().toString(),
                topicName,
                subtopicName,
                question.getDifficulty(),
                tagKeys,
                question.getStem() != null ? question.getStem() : ""
        );
    }

    /** 문제 저장 커밋 후 > 벡터 색인 비동기 적재 (트랜잭션 없이 발행돼도 바로 실행) */
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    public void onQuestionSaved(QuestionSavedEvent event) {
        indexQuestionAsync(event.questionUuid());
    }

    /** 문제 비활성화 커밋 후 > 비활성 문제 벡터 정리 1회 (남기면 추천 결과에 삭제된 문제가 섞임, #412) */
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    @Transactional(propagation = Propagation.REQUIRES_NEW, readOnly = true)
    public void onQuestionsDeactivated(QuestionsDeactivatedEvent event) {
        pruneIndex();
    }

    /**
     * 문제 1건 Qdrant 적재: 가상 스레드에서 조회 > 요청 조립 > 적재
     * 실패는 기록만 (문제 등록 응답·흐름에 영향 없음)
     */
    public void indexQuestionAsync(UUID questionUuid) {
        Thread.startVirtualThread(() -> {
            try {
                Question question = questionRepository.findById(questionUuid).orElse(null);
                if (question == null) {
                    log.warn("[question-index] 적재 대상 없음 (skip): questionUuid={}", questionUuid);
                    return;
                }
                IndexQuestionRequest request = buildIndexRequest(question);
                IndexQuestionResult result = aiGatewayClient.indexQuestion(request);
                if (result != null) {
                    log.info("[question-index] Qdrant 적재 완료: questionUuid={}, created={}",
                            questionUuid, result.created());
                }
            } catch (Exception e) {
                // 인덱싱 실패는 문제 등록 완료에 영향을 주지 않음
                log.warn("[question-index] Qdrant 적재 실패 (non-critical): questionUuid={}, error={}",
                        questionUuid, e.getMessage());
            }
        });
    }
}
