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
import com.passql.question.repository.QuestionRepository;
import com.passql.question.repository.SubtopicQuestionCountProjection;
import com.passql.question.repository.TopicQuestionCountProjection;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 관리자 토픽·서브토픽 삭제와 소속 문제 수 집계
 * 삭제: 소속 문제(비활성 포함)가 1개라도 있으면 거부 > 없으면 삭제 (토픽은 빈 서브토픽도 함께)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminTopicManagementService {

    private final TopicRepository topicRepository;
    private final SubtopicRepository subtopicRepository;
    private final QuestionRepository questionRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** 토픽 uuid > 소속 문제 수 (문제 없는 토픽은 키 없음) */
    public Map<UUID, Long> countQuestionsByTopicUuid() {
        return questionRepository.countAllByTopic().stream()
                .collect(Collectors.toMap(TopicQuestionCountProjection::getTopicUuid, TopicQuestionCountProjection::getQuestionCount));
    }

    /** 서브토픽 uuid > 소속 문제 수 (문제 없는 서브토픽은 키 없음) */
    public Map<UUID, Long> countQuestionsBySubtopicUuid() {
        return questionRepository.countAllBySubtopic().stream()
                .collect(Collectors.toMap(SubtopicQuestionCountProjection::getSubtopicUuid, SubtopicQuestionCountProjection::getQuestionCount));
    }

    /** 토픽 삭제: 소속 문제 확인 > 하위 서브토픽 삭제 > 토픽 삭제 */
    @Transactional
    public void deleteTopic(String topicCode) {
        Topic topic = topicRepository.findByCode(topicCode)
                .orElseThrow(() -> new CustomException(ErrorCode.TOPIC_NOT_FOUND));
        long questionCount = questionRepository.countByTopicUuid(topic.getTopicUuid());
        if (questionCount > 0) {
            throw hasQuestionsException("토픽", questionCount);
        }
        List<Subtopic> subtopics = subtopicRepository.findByTopicUuidOrderBySortOrderAsc(topic.getTopicUuid());
        for (Subtopic subtopic : subtopics) {
            // 서브토픽 소속 문제는 토픽 소속 문제와 별개로 한 번 더 확인
            long subtopicQuestionCount = questionRepository.countBySubtopicUuid(subtopic.getSubtopicUuid());
            if (subtopicQuestionCount > 0) {
                throw hasQuestionsException("서브토픽 " + subtopic.getCode(), subtopicQuestionCount);
            }
        }
        subtopicRepository.deleteAll(subtopics);
        topicRepository.delete(topic);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.TOPIC, topicCode, AdminAuditAction.DELETE,
                AdminAuditEvent.summary("displayName", topic.getDisplayName(), "sortOrder", topic.getSortOrder(),
                        "isActive", topic.getIsActive(), "deletedSubtopicCount", subtopics.size()), null));
        log.info("[topic delete] done : topicCode={}, deletedSubtopics={}", topicCode, subtopics.size());
    }

    /** 서브토픽 삭제: 상위 토픽 소속 확인 > 소속 문제 확인 > 삭제 */
    @Transactional
    public void deleteSubtopic(String topicCode, String subtopicCode) {
        Topic topic = topicRepository.findByCode(topicCode)
                .orElseThrow(() -> new CustomException(ErrorCode.TOPIC_NOT_FOUND));
        Subtopic subtopic = subtopicRepository.findByCode(subtopicCode)
                .filter(found -> found.getTopicUuid().equals(topic.getTopicUuid()))
                .orElseThrow(() -> new CustomException(ErrorCode.TOPIC_NOT_FOUND));
        long questionCount = questionRepository.countBySubtopicUuid(subtopic.getSubtopicUuid());
        if (questionCount > 0) {
            throw hasQuestionsException("서브토픽", questionCount);
        }
        subtopicRepository.delete(subtopic);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.TOPIC, topicCode + "/" + subtopicCode,
                AdminAuditAction.DELETE, AdminAuditEvent.summary("displayName", subtopic.getDisplayName(),
                        "sortOrder", subtopic.getSortOrder(), "isActive", subtopic.getIsActive()), null));
        log.info("[subtopic delete] done : topicCode={}, subtopicCode={}", topicCode, subtopicCode);
    }

    /** 삭제 거부 안내: 몇 개가 소속돼 있고 어떻게 풀지 (문제 목록 일괄 변경으로 이동) */
    private CustomException hasQuestionsException(String targetName, long questionCount) {
        return new CustomException(ErrorCode.TOPIC_HAS_QUESTIONS, targetName + "에 문제 " + questionCount
                + "개가 소속되어 있어 삭제할 수 없습니다. 문제 목록의 '일괄 변경 > 토픽·난이도 변경'으로 다른 토픽에 옮긴 뒤 삭제하세요.");
    }
}
