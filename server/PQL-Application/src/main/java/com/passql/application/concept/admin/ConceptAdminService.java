package com.passql.application.concept.admin;

import com.passql.application.concept.admin.dto.AdminCheckQuestionPreview;
import com.passql.application.concept.admin.dto.AdminConceptPreview;
import com.passql.application.concept.admin.dto.AdminConceptRow;
import com.passql.application.concept.admin.dto.AdminConceptTopicGroup;
import com.passql.application.concept.admin.dto.ConceptBundle;
import com.passql.application.concept.admin.dto.ConceptBundleChoice;
import com.passql.application.concept.admin.dto.ConceptBundleImportResult;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.ConceptPublishStatus;
import com.passql.meta.dto.concept.ConceptDetailSection;
import com.passql.meta.entity.ConceptCheckChoice;
import com.passql.meta.entity.ConceptCheckQuestion;
import com.passql.meta.entity.ConceptDoc;
import com.passql.meta.entity.ConceptTag;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.ConceptCheckChoiceRepository;
import com.passql.meta.repository.ConceptCheckQuestionRepository;
import com.passql.meta.repository.ConceptDocRepository;
import com.passql.meta.repository.ConceptTagRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.meta.service.concept.ConceptDetailSectionParser;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 개념 학습 관리자: 단원별 목록, 공개 상태 변경·일괄 공개, 본문 수정, 미리보기, 묶음 가져오기(감사 로그)
 * 공개 조건: 확인 문제 5개 (빈 개념을 공개하지 않음)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ConceptAdminService {

    private final TopicRepository topicRepository;
    private final ConceptTagRepository conceptTagRepository;
    private final ConceptDocRepository conceptDocRepository;
    private final ConceptCheckQuestionRepository checkQuestionRepository;
    private final ConceptCheckChoiceRepository checkChoiceRepository;
    private final ConceptBundleImportService bundleImportService;
    private final ConceptDetailSectionParser detailSectionParser;
    private final ApplicationEventPublisher eventPublisher;

    /** 단원별 개념 목록 (단원 순서, 단원 안 순서) */
    public List<AdminConceptTopicGroup> listByTopic() {
        List<Topic> topics = topicRepository.findByIsActiveTrueOrderBySortOrderAsc();
        List<ConceptTag> concepts = loadConcepts(topics);
        Map<UUID, Integer> questionCountByConcept = countQuestions(concepts);
        return topics.stream()
            .map(topic -> new AdminConceptTopicGroup(
                topic.getTopicUuid(),
                topic.getCode(),
                topic.getDisplayName(),
                concepts.stream()
                    .filter(concept -> Objects.equals(concept.getTopicUuid(), topic.getTopicUuid()))
                    .map(concept -> new AdminConceptRow(
                        concept.getConceptTagUuid(),
                        concept.getTagKey(),
                        concept.getLabelKo(),
                        concept.getPublishStatus(),
                        questionCountByConcept.getOrDefault(concept.getConceptTagUuid(), 0),
                        concept.getUpdatedAt()))
                    .toList()))
            .toList();
    }

    /** 공개 상태 변경 (공개로 바꿀 때 확인 문제 5개 필요) */
    @Transactional
    public void changePublishStatus(UUID conceptUuid, ConceptPublishStatus status) {
        ConceptTag concept = findConcept(conceptUuid);
        if (status == ConceptPublishStatus.PUBLISHED
            && checkQuestionRepository.countByConceptTagUuid(conceptUuid) != ConceptBundleValidator.CHECK_QUESTION_COUNT) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "check questions must be 5 before publish");
        }
        ConceptPublishStatus before = concept.getPublishStatus();
        concept.setPublishStatus(status);
        conceptTagRepository.save(concept);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.CONCEPT_DOC, conceptUuid, AdminAuditAction.UPDATE,
            AdminAuditEvent.summary("publishStatus", String.valueOf(before)),
            AdminAuditEvent.summary("publishStatus", String.valueOf(status))));
    }

    /** 일괄 공개: 확인 문제 5개를 갖춘 초안만 공개, 공개한 수 반환 */
    @Transactional
    public int publishAll() {
        List<ConceptTag> concepts = loadConcepts(topicRepository.findByIsActiveTrueOrderBySortOrderAsc());
        Map<UUID, Integer> questionCountByConcept = countQuestions(concepts);
        List<ConceptTag> publishable = concepts.stream()
            .filter(concept -> concept.getPublishStatus() == ConceptPublishStatus.DRAFT)
            .filter(concept -> questionCountByConcept.getOrDefault(concept.getConceptTagUuid(), 0)
                == ConceptBundleValidator.CHECK_QUESTION_COUNT)
            .toList();
        publishable.forEach(concept -> {
            concept.setPublishStatus(ConceptPublishStatus.PUBLISHED);
            conceptTagRepository.save(concept);
        });
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.CONCEPT_DOC, "publish-all", AdminAuditAction.UPDATE,
            null, AdminAuditEvent.summary("publishedCount", publishable.size())));
        return publishable.size();
    }

    /** 본문 수정: 자세히 형식 검사 > 확인 문제가 쓰는 앵커가 모두 남았는지 > 저장 */
    @Transactional
    public void updateContent(UUID conceptUuid, String title, String summary, String coreMd, String detailMd) {
        ConceptTag concept = findConcept(conceptUuid);
        Set<String> anchors;
        try {
            anchors = detailSectionParser.findAnchors(detailMd);
        } catch (IllegalArgumentException e) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, e.getMessage());
        }
        List<String> missingAnchors = checkQuestionRepository.findByConceptTagUuidOrderBySortOrderAsc(conceptUuid).stream()
            .map(ConceptCheckQuestion::getRereadAnchor)
            .filter(anchor -> !anchors.contains(anchor))
            .distinct()
            .toList();
        if (!missingAnchors.isEmpty()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "anchors used by check questions are missing: " + missingAnchors);
        }

        concept.setLabelKo(title);
        concept.setSummary(summary);
        conceptTagRepository.save(concept);
        ConceptDoc doc = conceptDocRepository.findFirstByConceptTagUuidAndIsActiveTrue(conceptUuid)
            .orElseGet(() -> ConceptDoc.builder().conceptTagUuid(conceptUuid).isActive(true).build());
        doc.setTitle(title);
        doc.setCoreMd(coreMd);
        doc.setDetailMd(detailMd);
        conceptDocRepository.save(doc);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.CONCEPT_DOC, conceptUuid, AdminAuditAction.UPDATE,
            null, AdminAuditEvent.summary("title", title)));
    }

    /** 미리보기: 핵심만 > 자세히 문단 > 확인 문제(정답 포함) */
    public AdminConceptPreview getPreview(UUID conceptUuid) {
        ConceptTag concept = findConcept(conceptUuid);
        ConceptDoc doc = conceptDocRepository.findFirstByConceptTagUuidAndIsActiveTrue(conceptUuid).orElse(null);
        String detailMd = doc != null ? doc.getDetailMd() : null;
        List<ConceptCheckQuestion> questions = checkQuestionRepository.findByConceptTagUuidOrderBySortOrderAsc(conceptUuid);
        List<UUID> questionUuids = questions.stream().map(ConceptCheckQuestion::getConceptCheckQuestionUuid).toList();
        Map<UUID, List<ConceptCheckChoice>> choicesByQuestion = questionUuids.isEmpty()
            ? Map.of()
            : checkChoiceRepository.findByConceptCheckQuestionUuidInOrderBySortOrderAsc(questionUuids).stream()
                .collect(Collectors.groupingBy(ConceptCheckChoice::getConceptCheckQuestionUuid));

        List<AdminCheckQuestionPreview> questionPreviews = questions.stream()
            .map(question -> {
                List<ConceptCheckChoice> choices = choicesByQuestion.getOrDefault(question.getConceptCheckQuestionUuid(), List.of());
                String correctKey = choices.stream().filter(choice -> Boolean.TRUE.equals(choice.getIsCorrect()))
                    .map(ConceptCheckChoice::getChoiceKey).findFirst().orElse(null);
                return new AdminCheckQuestionPreview(question.getSortOrder(), question.getStem(), question.getStemSql(),
                    question.getExplanation(), question.getRereadAnchor(), correctKey,
                    choices.stream().map(choice -> new ConceptBundleChoice(choice.getChoiceKey(), choice.getBody(),
                        choice.getIsCorrect(), choice.getRationale())).toList());
            })
            .toList();

        return new AdminConceptPreview(
            conceptUuid,
            concept.getTagKey(),
            concept.getLabelKo(),
            concept.getSummary(),
            concept.getPublishStatus(),
            doc != null ? doc.getCoreMd() : null,
            detailMd,
            detailMd == null || detailMd.isBlank() ? List.of() : parseSectionsOrEmpty(detailMd),
            questionPreviews);
    }

    /** 묶음 가져오기 (감사 로그 포함) */
    @Transactional
    public ConceptBundleImportResult importBundle(ConceptBundle bundle) {
        ConceptBundleImportResult result = bundleImportService.importBundle(bundle);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.CONCEPT_DOC, "bundle-import", AdminAuditAction.CREATE,
            null, AdminAuditEvent.summary("createdCount", result.createdCount(), "updatedCount", result.updatedCount())));
        return result;
    }

    private List<ConceptDetailSection> parseSectionsOrEmpty(String detailMd) {
        try {
            return detailSectionParser.parse(detailMd);
        } catch (IllegalArgumentException e) {
            return List.of();
        }
    }

    private ConceptTag findConcept(UUID conceptUuid) {
        return conceptTagRepository.findById(conceptUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.CONCEPT_NOT_FOUND));
    }

    private List<ConceptTag> loadConcepts(List<Topic> topics) {
        List<UUID> topicUuids = topics.stream().map(Topic::getTopicUuid).toList();
        return topicUuids.isEmpty() ? List.of() : conceptTagRepository.findByTopicUuidInAndIsActiveTrueOrderBySortOrderAsc(topicUuids);
    }

    private Map<UUID, Integer> countQuestions(List<ConceptTag> concepts) {
        List<UUID> conceptUuids = concepts.stream().map(ConceptTag::getConceptTagUuid).toList();
        if (conceptUuids.isEmpty()) {
            return Map.of();
        }
        return checkQuestionRepository.findByConceptTagUuidIn(conceptUuids).stream()
            .collect(Collectors.groupingBy(ConceptCheckQuestion::getConceptTagUuid, Collectors.summingInt(question -> 1)));
    }
}
