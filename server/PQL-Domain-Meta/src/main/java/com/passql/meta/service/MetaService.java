package com.passql.meta.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.dto.TopicCreateRequest;
import com.passql.meta.dto.TopicTree;
import com.passql.meta.dto.TopicUpdateRequest;
import com.passql.meta.entity.ConceptDoc;
import com.passql.meta.entity.ConceptTag;
import com.passql.meta.entity.Subtopic;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.ConceptDocRepository;
import com.passql.meta.repository.ConceptTagRepository;
import com.passql.meta.repository.SubtopicRepository;
import com.passql.meta.repository.TopicRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MetaService {

    private static final String EMBEDDING_VERSION = "v1";
    private final TopicRepository topicRepository;
    private final SubtopicRepository subtopicRepository;
    private final ConceptTagRepository conceptTagRepository;
    private final ConceptDocRepository conceptDocRepository;
    private final ApplicationEventPublisher eventPublisher;

    public List<TopicTree> getTopicTree() {
        // 관리자 화면에서는 비활성 토픽도 포함해 전체 목록을 표시 (비활성화 후 되돌릴 수 없는 문제 방지)
        List<Topic> topics = topicRepository.findAllByOrderBySortOrderAsc();
        return topics.stream()
                .map(topic -> {
                    List<TopicTree.SubtopicItem> subs = subtopicRepository
                            .findByTopicUuidOrderBySortOrderAsc(topic.getTopicUuid())
                            .stream()
                            .map(s -> new TopicTree.SubtopicItem(s.getCode(), s.getDisplayName(), s.getSortOrder(), s.getIsActive()))
                            .toList();
                    return new TopicTree(topic.getTopicUuid(), topic.getCode(), topic.getDisplayName(), topic.getSortOrder(), topic.getIsActive(), subs);
                })
                .toList();
    }

    public List<ConceptTag> getActiveTags() {
        return conceptTagRepository.findByIsActiveTrueOrderBySortOrderAsc();
    }

    public List<Subtopic> getSubtopics(String topicCode) {
        return topicRepository.findByCode(topicCode)
                .map(topic -> subtopicRepository.findByTopicUuidOrderBySortOrderAsc(topic.getTopicUuid()))
                .orElse(List.of());
    }

    public List<ConceptDoc> getDocsByTagKey(String tagKey) {
        return conceptTagRepository.findByTagKey(tagKey)
                .map(tag -> conceptDocRepository.findByConceptTagUuid(tag.getConceptTagUuid()))
                .orElse(List.of());
    }

    @Transactional
    public ConceptDoc createDoc(String tagKey, String title, String bodyMd) {
        ConceptTag tag = conceptTagRepository.findByTagKey(tagKey)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 tagKey: " + tagKey));
        ConceptDoc doc = ConceptDoc.builder()
                .conceptTagUuid(tag.getConceptTagUuid())
                .title(title)
                .bodyMd(bodyMd)
                .embeddingVersion(EMBEDDING_VERSION)
                .isActive(true)
                .build();
        ConceptDoc saved = conceptDocRepository.save(doc);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.CONCEPT_DOC, saved.getConceptDocUuid(),
                AdminAuditAction.CREATE, null, AdminAuditEvent.summary("tagKey", tagKey, "title", title)));
        return saved;
    }

    /** 토픽 추가 (#479): 코드 중복 검사 > 활성 토픽 생성 */
    @Transactional
    public Topic createTopic(TopicCreateRequest request) {
        if (topicRepository.existsByCode(request.code())) {
            throw new CustomException(ErrorCode.TOPIC_DUPLICATE);
        }
        Topic topic = topicRepository.save(Topic.builder()
                .code(request.code())
                .displayName(request.displayName())
                .sortOrder(request.sortOrder())
                .isActive(true)
                .build());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.TOPIC, topic.getCode(), AdminAuditAction.CREATE,
                null, toTopicAuditSummary(topic)));
        return topic;
    }

    /** 서브토픽 추가 (#479): 상위 토픽 확인 > 코드 중복 검사(전체 서브토픽 기준 유니크) > 활성 서브토픽 생성 */
    @Transactional
    public Subtopic createSubtopic(String topicCode, TopicCreateRequest request) {
        Topic topic = topicRepository.findByCode(topicCode)
                .orElseThrow(() -> new CustomException(ErrorCode.TOPIC_NOT_FOUND));
        if (subtopicRepository.findByCode(request.code()).isPresent()) {
            throw new CustomException(ErrorCode.TOPIC_DUPLICATE);
        }
        Subtopic subtopic = subtopicRepository.save(Subtopic.builder()
                .topicUuid(topic.getTopicUuid())
                .code(request.code())
                .displayName(request.displayName())
                .sortOrder(request.sortOrder())
                .isActive(true)
                .build());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.TOPIC, topicCode + "/" + subtopic.getCode(),
                AdminAuditAction.CREATE, null, AdminAuditEvent.summary("displayName", subtopic.getDisplayName(),
                        "sortOrder", subtopic.getSortOrder())));
        return subtopic;
    }

    /** 개념 문서 삭제 (#479, 행 삭제, 감사 로그에 제목·본문 앞부분 보관) */
    @Transactional
    public void deleteDoc(UUID conceptDocUuid) {
        ConceptDoc doc = conceptDocRepository.findById(conceptDocUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));
        conceptDocRepository.delete(doc);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.CONCEPT_DOC, conceptDocUuid, AdminAuditAction.DELETE,
                AdminAuditEvent.summary("title", doc.getTitle(), "bodyMd", doc.getBodyMd()), null));
    }

    /** 토픽 편집 — displayName, sortOrder, isActive 수정 */
    @Transactional
    public void updateTopic(String code, TopicUpdateRequest request) {
        Topic topic = topicRepository.findByCode(code)
                .orElseThrow(() -> new CustomException(ErrorCode.TOPIC_NOT_FOUND));
        Map<String, Object> before = toTopicAuditSummary(topic);
        topic.setDisplayName(request.displayName());
        topic.setSortOrder(request.sortOrder());
        topic.setIsActive(request.isActive());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.TOPIC, code, AdminAuditAction.UPDATE,
                before, toTopicAuditSummary(topic)));
    }

    private Map<String, Object> toTopicAuditSummary(Topic topic) {
        return AdminAuditEvent.summary("displayName", topic.getDisplayName(), "sortOrder", topic.getSortOrder(),
                "isActive", topic.getIsActive());
    }

    @Transactional
    public void updateDocBody(UUID conceptDocUuid, String bodyMd) {
        ConceptDoc doc = conceptDocRepository.findById(conceptDocUuid)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 ConceptDoc: " + conceptDocUuid));
        Map<String, Object> before = AdminAuditEvent.summary("bodyMd", doc.getBodyMd());
        doc.setBodyMd(bodyMd);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.CONCEPT_DOC, conceptDocUuid,
                AdminAuditAction.UPDATE, before, AdminAuditEvent.summary("bodyMd", bodyMd)));
    }
}
