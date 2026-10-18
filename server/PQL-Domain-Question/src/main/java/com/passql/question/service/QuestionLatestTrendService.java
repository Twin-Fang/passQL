package com.passql.question.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.TextPreview;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.dto.AdminLatestTrendCandidate;
import com.passql.question.dto.AdminLatestTrendUpdateRequest;
import com.passql.question.dto.AdminLatestTrendUpdateResult;
import com.passql.question.dto.LatestTrendTopicCount;
import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import com.passql.question.repository.TopicQuestionCountProjection;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 최신 출제 경향 문제: 토픽별 문제 수, 관리자 지정 후보 조회, 일괄 지정·해제 (#523)
 * 지정 근거는 관리자 판단 (CURATED_ONLY 후보 + 경향 양산 원본 대조), 자동 판별 없음
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionLatestTrendService {

    // 일괄 지정 1회 최대 문제 수 (요청 크기 제한)
    static final int MAXIMUM_UPDATE_QUESTION_COUNT = 200;
    // 감사 로그 before·after 키
    private static final String AUDIT_FIELD_IS_LATEST_TREND = "isLatestTrend";

    private final QuestionRepository questionRepository;
    private final TopicRepository topicRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** 토픽별 활성 최신 경향 문제 수 (활성 토픽만, 토픽 정렬 순서) */
    public List<LatestTrendTopicCount> getLatestTrendTopicCounts() {
        List<TopicQuestionCountProjection> topicCounts = questionRepository.countActiveLatestTrendByTopic();
        Map<UUID, Topic> topicByUuid = topicRepository
                .findAllById(topicCounts.stream().map(TopicQuestionCountProjection::getTopicUuid).toList())
                .stream()
                .collect(Collectors.toMap(Topic::getTopicUuid, Function.identity()));
        return topicCounts.stream()
                .filter(topicCount -> isActiveTopic(topicByUuid.get(topicCount.getTopicUuid())))
                .sorted(Comparator.comparing(
                        (TopicQuestionCountProjection topicCount) -> topicSortOrder(topicByUuid.get(topicCount.getTopicUuid()))))
                .map(topicCount -> {
                    Topic topic = topicByUuid.get(topicCount.getTopicUuid());
                    return new LatestTrendTopicCount(topic.getCode(), topic.getDisplayName(),
                            topicCount.getQuestionCount().intValue());
                })
                .toList();
    }

    /** 지정 후보: 활성 + CURATED_ONLY + 고정 OK 세트 보유 (등록 오래된 순) */
    public List<AdminLatestTrendCandidate> getLatestTrendCandidates() {
        List<Question> candidates = questionRepository.findLatestTrendCandidates();
        Map<UUID, String> topicCodeByUuid = topicRepository
                .findAllById(candidates.stream().map(Question::getTopicUuid).distinct().toList())
                .stream()
                .collect(Collectors.toMap(Topic::getTopicUuid, Topic::getCode));
        return candidates.stream()
                .map(question -> new AdminLatestTrendCandidate(
                        question.getQuestionUuid(),
                        topicCodeByUuid.get(question.getTopicUuid()),
                        question.getDifficulty(),
                        question.getSchemaIntent(),
                        TextPreview.truncate(question.getStem(), TextPreview.QUESTION_SUMMARY_STEM_LENGTH),
                        question.getCreatedAt(),
                        Boolean.TRUE.equals(question.getIsLatestTrend())))
                .toList();
    }

    /** 일괄 지정·해제: 요청 검증 > 문제 조회 > 값 다른 문제만 변경·감사 기록 > 결과 */
    @Transactional
    public AdminLatestTrendUpdateResult updateLatestTrend(AdminLatestTrendUpdateRequest request) {
        Set<UUID> questionUuids = validateUpdateRequest(request);
        boolean isLatestTrend = request.isLatestTrend();

        Map<UUID, Question> questionByUuid = questionRepository.findAllById(questionUuids).stream()
                .collect(Collectors.toMap(Question::getQuestionUuid, Function.identity()));
        List<UUID> notFoundQuestionUuids = questionUuids.stream()
                .filter(questionUuid -> !questionByUuid.containsKey(questionUuid))
                .toList();

        int changedCount = 0;
        for (Question question : questionByUuid.values()) {
            boolean wasLatestTrend = Boolean.TRUE.equals(question.getIsLatestTrend());
            if (wasLatestTrend == isLatestTrend) {
                continue;
            }
            question.setIsLatestTrend(isLatestTrend);
            changedCount++;
            eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.QUESTION, question.getQuestionUuid(),
                    AdminAuditAction.UPDATE,
                    Map.of(AUDIT_FIELD_IS_LATEST_TREND, wasLatestTrend),
                    Map.of(AUDIT_FIELD_IS_LATEST_TREND, isLatestTrend)));
        }
        log.info("[question latest trend] updated : requested={}, changed={}, notFound={}, isLatestTrend={}",
                questionUuids.size(), changedCount, notFoundQuestionUuids.size(), isLatestTrend);
        return new AdminLatestTrendUpdateResult(questionUuids.size(), changedCount, notFoundQuestionUuids);
    }

    /** 요청 검증 (UUID 1개 이상·최대 개수·null UUID 없음, 지정 값 필수) > 중복 제거한 UUID */
    private Set<UUID> validateUpdateRequest(AdminLatestTrendUpdateRequest request) {
        if (request == null || request.isLatestTrend() == null || request.questionUuids() == null
                || request.questionUuids().isEmpty()
                || request.questionUuids().size() > MAXIMUM_UPDATE_QUESTION_COUNT
                || request.questionUuids().stream().anyMatch(Objects::isNull)) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }
        return new LinkedHashSet<>(request.questionUuids());
    }

    private static boolean isActiveTopic(Topic topic) {
        return topic != null && Boolean.TRUE.equals(topic.getIsActive());
    }

    // 정렬 순서 없는 토픽은 맨 뒤
    private static int topicSortOrder(Topic topic) {
        return topic.getSortOrder() != null ? topic.getSortOrder() : Integer.MAX_VALUE;
    }
}
