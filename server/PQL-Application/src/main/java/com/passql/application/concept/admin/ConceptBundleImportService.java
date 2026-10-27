package com.passql.application.concept.admin;

import com.passql.application.concept.admin.dto.ConceptBundle;
import com.passql.application.concept.admin.dto.ConceptBundleCheckQuestion;
import com.passql.application.concept.admin.dto.ConceptBundleChoice;
import com.passql.application.concept.admin.dto.ConceptBundleImportResult;
import com.passql.application.concept.admin.dto.ConceptBundleItem;
import com.passql.application.concept.admin.dto.ConceptBundleItemIssue;
import com.passql.application.concept.admin.dto.ConceptBundleValidationResult;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.ConceptPublishStatus;
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
import com.passql.question.entity.QuestionConceptTag;
import com.passql.question.repository.QuestionConceptTagRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 개념 묶음 저장: 검증 > tagKey 기준 생성·갱신 > 본문 > 확인 문제 교체 > 관련 문제 연결 교체 (한 트랜잭션)
 * 새 개념은 초안, 기존 공개 개념은 공개 유지. 회원 진행 기록은 건드리지 않음
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ConceptBundleImportService {

    // 검증 실패 메시지에 담는 문제 최대 건수
    private static final int ISSUE_MESSAGE_LIMIT = 20;

    private final ConceptBundleValidator validator;
    private final TopicRepository topicRepository;
    private final ConceptTagRepository conceptTagRepository;
    private final ConceptDocRepository conceptDocRepository;
    private final ConceptCheckQuestionRepository checkQuestionRepository;
    private final ConceptCheckChoiceRepository checkChoiceRepository;
    private final QuestionConceptTagRepository questionConceptTagRepository;

    /** 검증만 (저장 없음) */
    public ConceptBundleValidationResult validate(ConceptBundle bundle) {
        return validator.validate(bundle);
    }

    /** 묶음 저장: 검증 실패면 아무것도 저장하지 않고 INVALID_INPUT_VALUE */
    @Transactional
    public ConceptBundleImportResult importBundle(ConceptBundle bundle) {
        ConceptBundleValidationResult validation = validator.validate(bundle);
        if (!validation.isValid()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, toIssueMessage(validation.issues()));
        }
        Map<String, Topic> topicByCode = topicRepository.findByIsActiveTrueOrderBySortOrderAsc().stream()
            .collect(Collectors.toMap(Topic::getCode, Function.identity(), (first, second) -> first));

        int createdCount = 0;
        int updatedCount = 0;
        for (ConceptBundleItem item : bundle.concepts()) {
            boolean isNew = conceptTagRepository.findByTagKey(item.tagKey()).isEmpty();
            ConceptTag concept = saveConcept(item, topicByCode.get(item.topicCode()));
            saveDoc(concept, item);
            replaceCheckQuestions(concept.getConceptTagUuid(), item.checkQuestions());
            replaceRelatedQuestions(concept.getConceptTagUuid(), item.relatedQuestionUuids());
            if (isNew) {
                createdCount++;
            } else {
                updatedCount++;
            }
        }
        log.info("[concept learning] bundle imported : created={}, updated={}", createdCount, updatedCount);
        return new ConceptBundleImportResult(createdCount, updatedCount);
    }

    /** 개념 행 생성·갱신 (새 개념 DRAFT, 기존 공개 상태 유지) */
    private ConceptTag saveConcept(ConceptBundleItem item, Topic topic) {
        ConceptTag concept = conceptTagRepository.findByTagKey(item.tagKey())
            .orElseGet(() -> ConceptTag.builder()
                .tagKey(item.tagKey())
                .publishStatus(ConceptPublishStatus.DRAFT)
                .isActive(true)
                .build());
        concept.setTopicUuid(topic.getTopicUuid());
        concept.setLabelKo(item.title());
        concept.setSummary(item.summary());
        concept.setSortOrder(item.sortOrder());
        concept.setIsActive(true);
        if (concept.getPublishStatus() == null) {
            concept.setPublishStatus(ConceptPublishStatus.DRAFT);
        }
        return conceptTagRepository.save(concept);
    }

    /** 활성 본문 1건 생성·갱신 (핵심만·자세히) */
    private void saveDoc(ConceptTag concept, ConceptBundleItem item) {
        ConceptDoc doc = conceptDocRepository.findFirstByConceptTagUuidAndIsActiveTrue(concept.getConceptTagUuid())
            .orElseGet(() -> ConceptDoc.builder()
                .conceptTagUuid(concept.getConceptTagUuid())
                .isActive(true)
                .build());
        doc.setTitle(item.title());
        doc.setCoreMd(item.coreMd());
        doc.setDetailMd(item.detailMd());
        doc.setIsActive(true);
        conceptDocRepository.save(doc);
    }

    /** 확인 문제 교체: 기존 삭제(보기는 FK CASCADE) > 문제·보기 새로 저장 */
    private void replaceCheckQuestions(UUID conceptUuid, List<ConceptBundleCheckQuestion> questions) {
        checkQuestionRepository.deleteByConceptTagUuid(conceptUuid);
        checkQuestionRepository.flush();
        for (ConceptBundleCheckQuestion bundleQuestion : questions) {
            ConceptCheckQuestion question = checkQuestionRepository.save(ConceptCheckQuestion.builder()
                .conceptTagUuid(conceptUuid)
                .sortOrder(bundleQuestion.sortOrder())
                .stem(bundleQuestion.stem())
                .stemSql(bundleQuestion.stemSql())
                .explanation(bundleQuestion.explanation())
                .rereadAnchor(bundleQuestion.rereadAnchor())
                .build());
            List<ConceptBundleChoice> choices = bundleQuestion.choices();
            for (int index = 0; index < choices.size(); index++) {
                ConceptBundleChoice choice = choices.get(index);
                checkChoiceRepository.save(ConceptCheckChoice.builder()
                    .conceptCheckQuestionUuid(question.getConceptCheckQuestionUuid())
                    .choiceKey(choice.choiceKey())
                    .body(choice.body())
                    .isCorrect(Boolean.TRUE.equals(choice.isCorrect()))
                    .rationale(choice.rationale())
                    .sortOrder(index + 1)
                    .build());
            }
        }
    }

    /** 관련 문제 연결 교체 (question_concept_tag) */
    private void replaceRelatedQuestions(UUID conceptUuid, List<UUID> relatedQuestionUuids) {
        questionConceptTagRepository.deleteByConceptTagUuid(conceptUuid);
        if (relatedQuestionUuids == null) {
            return;
        }
        relatedQuestionUuids.stream().distinct().forEach(questionUuid -> questionConceptTagRepository.save(
            QuestionConceptTag.builder().questionUuid(questionUuid).conceptTagUuid(conceptUuid).build()));
    }

    private static String toIssueMessage(List<ConceptBundleItemIssue> issues) {
        return issues.stream()
            .limit(ISSUE_MESSAGE_LIMIT)
            .map(issue -> issue.tagKey() + "." + issue.field() + ": " + issue.reason())
            .collect(Collectors.joining("; "));
    }
}
