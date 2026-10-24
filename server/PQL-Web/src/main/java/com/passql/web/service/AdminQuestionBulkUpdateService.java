package com.passql.web.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.Subtopic;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.SubtopicRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.dto.QuestionBulkClassifyRequest;
import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import com.passql.question.service.QuestionAuditSummary;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 관리자 문제 일괄 변경: 일괄 활성화, 일괄 토픽·난이도 변경
 * 한 트랜잭션에서 상태 변경만 (벡터 색인 갱신은 호출 쪽), 없는 문제·변화 없는 문제는 건너뜀 목록으로 반환
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminQuestionBulkUpdateService {

    // 난이도 허용 범위 (1 개념 암기 ~ 5 윈도우·계층·PIVOT)
    private static final int MINIMUM_DIFFICULTY = 1;
    private static final int MAXIMUM_DIFFICULTY = 5;
    // 건너뜀 사유
    private static final String SKIP_REASON_NOT_FOUND = "문제 없음";
    private static final String SKIP_REASON_ALREADY_ACTIVE = "이미 활성";
    private static final String SKIP_REASON_NO_CHANGE = "변경할 내용 없음";

    private final QuestionRepository questionRepository;
    private final TopicRepository topicRepository;
    private final SubtopicRepository subtopicRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** 선택 문제 일괄 활성화 (이미 활성인 문제는 건너뜀) */
    @Transactional
    public BulkUpdateResult activateQuestions(List<UUID> questionUuids) {
        Map<UUID, Question> questionByUuid = findQuestionByUuid(questionUuids);
        List<UUID> activatedQuestionUuids = new ArrayList<>();
        List<String> skippedReasons = new ArrayList<>();
        for (UUID questionUuid : questionUuids) {
            Question question = questionByUuid.get(questionUuid);
            if (question == null) {
                skippedReasons.add(questionUuid + ": " + SKIP_REASON_NOT_FOUND);
            } else if (Boolean.TRUE.equals(question.getIsActive())) {
                skippedReasons.add(questionUuid + ": " + SKIP_REASON_ALREADY_ACTIVE);
            } else {
                question.restore();
                eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.QUESTION, questionUuid,
                        AdminAuditAction.ACTIVATE, AdminAuditEvent.summary("isActive", false), AdminAuditEvent.summary("isActive", true)));
                activatedQuestionUuids.add(questionUuid);
            }
        }
        log.info("[question activate] bulk done : total={}, activated={}, skipped={}",
                questionUuids.size(), activatedQuestionUuids.size(), skippedReasons.size());
        return BulkUpdateResult.of(activatedQuestionUuids, skippedReasons);
    }

    /** 선택 문제 일괄 토픽·난이도 변경: 요청 검증 > 토픽·서브토픽 확인 > 문제별 변경 */
    @Transactional
    public BulkUpdateResult classifyQuestions(QuestionBulkClassifyRequest request) {
        validateClassifyRequest(request);
        Topic topic = findTopicOrNull(request.topicCode());
        Subtopic subtopic = findSubtopicOrNull(request.subtopicCode(), topic);

        Map<UUID, Question> questionByUuid = findQuestionByUuid(request.questionUuids());
        List<UUID> changedQuestionUuids = new ArrayList<>();
        List<String> skippedReasons = new ArrayList<>();
        for (UUID questionUuid : request.questionUuids()) {
            Question question = questionByUuid.get(questionUuid);
            if (question == null) {
                skippedReasons.add(questionUuid + ": " + SKIP_REASON_NOT_FOUND);
                continue;
            }
            Map<String, Object> before = QuestionAuditSummary.of(question);
            if (!applyClassification(question, topic, subtopic, request.difficulty())) {
                skippedReasons.add(questionUuid + ": " + SKIP_REASON_NO_CHANGE);
                continue;
            }
            eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.QUESTION, questionUuid,
                    AdminAuditAction.UPDATE, before, QuestionAuditSummary.of(question)));
            changedQuestionUuids.add(questionUuid);
        }
        log.info("[question classify] bulk done : total={}, changed={}, skipped={}",
                request.questionUuids().size(), changedQuestionUuids.size(), skippedReasons.size());
        return BulkUpdateResult.of(changedQuestionUuids, skippedReasons);
    }

    /** 문제 1건에 토픽·서브토픽·난이도 반영 > 바뀐 값이 있으면 true (토픽만 바뀌면 서브토픽 비움) */
    private boolean applyClassification(Question question, Topic topic, Subtopic subtopic, Integer difficulty) {
        boolean isChanged = false;
        if (topic != null) {
            boolean isSameTopic = topic.getTopicUuid().equals(question.getTopicUuid());
            UUID nextSubtopicUuid = subtopic != null ? subtopic.getSubtopicUuid()
                    : (isSameTopic ? question.getSubtopicUuid() : null);
            if (!isSameTopic || !Objects.equals(nextSubtopicUuid, question.getSubtopicUuid())) {
                question.setTopicUuid(topic.getTopicUuid());
                question.setSubtopicUuid(nextSubtopicUuid);
                isChanged = true;
            }
        }
        if (difficulty != null && !difficulty.equals(question.getDifficulty())) {
            question.setDifficulty(difficulty);
            isChanged = true;
        }
        return isChanged;
    }

    private void validateClassifyRequest(QuestionBulkClassifyRequest request) {
        if (request.questionUuids() == null || request.questionUuids().isEmpty()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "변경할 문제를 선택하세요.");
        }
        boolean hasTopic = request.topicCode() != null && !request.topicCode().isBlank();
        boolean hasSubtopic = request.subtopicCode() != null && !request.subtopicCode().isBlank();
        if (!hasTopic && request.difficulty() == null) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "변경할 토픽 또는 난이도를 선택하세요.");
        }
        if (hasSubtopic && !hasTopic) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "서브토픽은 토픽과 함께 선택하세요.");
        }
        if (request.difficulty() != null
                && (request.difficulty() < MINIMUM_DIFFICULTY || request.difficulty() > MAXIMUM_DIFFICULTY)) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "난이도는 1~5 범위여야 합니다.");
        }
    }

    private Topic findTopicOrNull(String topicCode) {
        if (topicCode == null || topicCode.isBlank()) {
            return null;
        }
        return topicRepository.findByCode(topicCode).orElseThrow(() -> new CustomException(ErrorCode.TOPIC_NOT_FOUND));
    }

    /** 서브토픽 코드 > 서브토픽 (선택한 토픽 소속이어야 함) */
    private Subtopic findSubtopicOrNull(String subtopicCode, Topic topic) {
        if (subtopicCode == null || subtopicCode.isBlank()) {
            return null;
        }
        Subtopic subtopic = subtopicRepository.findByCode(subtopicCode)
                .orElseThrow(() -> new CustomException(ErrorCode.TOPIC_NOT_FOUND));
        if (!subtopic.getTopicUuid().equals(topic.getTopicUuid())) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "선택한 토픽의 서브토픽이 아닙니다.");
        }
        return subtopic;
    }

    private Map<UUID, Question> findQuestionByUuid(List<UUID> questionUuids) {
        return questionRepository.findAllById(questionUuids).stream()
                .collect(Collectors.toMap(Question::getQuestionUuid, Function.identity()));
    }

    /** 일괄 변경 결과 (updated: 실제 바뀐 건수, skipped: 건너뜀 건수, errors: 건너뜀 사유, updatedQuestionUuids: 색인 갱신 대상) */
    public record BulkUpdateResult(int updated, int skipped, List<String> errors, List<UUID> updatedQuestionUuids) {
        static BulkUpdateResult of(List<UUID> updatedQuestionUuids, List<String> skippedReasons) {
            return new BulkUpdateResult(updatedQuestionUuids.size(), skippedReasons.size(), skippedReasons, updatedQuestionUuids);
        }
    }
}
