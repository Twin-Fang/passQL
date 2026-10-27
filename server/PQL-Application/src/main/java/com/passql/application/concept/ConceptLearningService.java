package com.passql.application.concept;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.application.concept.dto.ConceptCheckChoiceResponse;
import com.passql.application.concept.dto.ConceptCheckQuestionResponse;
import com.passql.application.concept.dto.ConceptDetailResponse;
import com.passql.application.concept.dto.ConceptListResponse;
import com.passql.application.concept.dto.ConceptStatus;
import com.passql.application.concept.dto.ConceptSummary;
import com.passql.application.concept.dto.ConceptTopicListResponse;
import com.passql.application.concept.dto.ConceptTopicSummary;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.ConceptPublishStatus;
import com.passql.meta.constant.ConceptReadingDepth;
import com.passql.meta.constant.ConceptStudyMode;
import com.passql.meta.entity.ConceptCheckChoice;
import com.passql.meta.entity.ConceptCheckQuestion;
import com.passql.meta.entity.ConceptDoc;
import com.passql.meta.entity.ConceptTag;
import com.passql.meta.entity.MemberConceptProgress;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.ConceptCheckChoiceRepository;
import com.passql.meta.repository.ConceptCheckQuestionRepository;
import com.passql.meta.repository.ConceptDocRepository;
import com.passql.meta.repository.ConceptTagRepository;
import com.passql.meta.repository.MemberConceptProgressRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.meta.service.concept.ConceptDetailSectionParser;
import com.passql.question.entity.QuestionConceptTag;
import com.passql.question.repository.QuestionConceptTagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 개념 학습: 단원·개념 목록, 개념 상세, 확인 문제 조회
 * 노출 판정 순서: 이용 가능(공개·미리보기) > 초안 숨김(미리보기 회원 제외) > 단원 잠금(FeatureAccessPolicy)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ConceptLearningService {

    private final TopicRepository topicRepository;
    private final ConceptTagRepository conceptTagRepository;
    private final ConceptDocRepository conceptDocRepository;
    private final ConceptCheckQuestionRepository checkQuestionRepository;
    private final ConceptCheckChoiceRepository checkChoiceRepository;
    private final MemberConceptProgressRepository progressRepository;
    private final QuestionConceptTagRepository questionConceptTagRepository;
    private final FeatureAccessPolicy featureAccessPolicy;
    private final ConceptAvailabilityPolicy availabilityPolicy;
    private final ConceptDetailSectionParser detailSectionParser;
    private final ObjectMapper objectMapper;

    /** 단원 목록: 이용 불가 > 빈 목록, 개념 없는 단원 제외, 앞 N단원 외 무료 회원 잠금 */
    public ConceptTopicListResponse getTopics(UUID memberUuid) {
        int freeTopicCount = featureAccessPolicy.getConceptFreeTopicCount();
        if (!availabilityPolicy.isAvailableFor(memberUuid)) {
            return new ConceptTopicListResponse(false, freeTopicCount, List.of());
        }

        ConceptCatalog catalog = loadCatalog(memberUuid);
        Map<UUID, Integer> questionCountByConcept = countCheckQuestions(catalog.visibleConceptUuids());
        Map<UUID, MemberConceptProgress> progressByConcept = loadProgress(memberUuid, catalog.visibleConceptUuids());

        List<ConceptTopicSummary> topics = new ArrayList<>();
        for (int orderIndex = 0; orderIndex < catalog.topics().size(); orderIndex++) {
            Topic topic = catalog.topics().get(orderIndex);
            List<ConceptTag> concepts = catalog.conceptsOf(topic.getTopicUuid());
            if (concepts.isEmpty()) {
                continue;
            }
            int completedCount = (int) concepts.stream()
                .filter(concept -> toStatus(progressByConcept.get(concept.getConceptTagUuid()),
                    questionCountByConcept.getOrDefault(concept.getConceptTagUuid(), 0)) == ConceptStatus.SOLVED)
                .count();
            boolean isLocked = !featureAccessPolicy.canOpenConceptTopic(memberUuid, orderIndex);
            topics.add(new ConceptTopicSummary(topic.getTopicUuid(), topic.getDisplayName(), orderIndex,
                concepts.size(), completedCount, isLocked));
        }
        return new ConceptTopicListResponse(true, freeTopicCount, topics);
    }

    /** 단원의 개념 목록 (잠긴 단원도 제목·진행은 보여 줌) */
    public ConceptListResponse getConcepts(UUID memberUuid, UUID topicUuid) {
        requireAvailable(memberUuid);
        ConceptCatalog catalog = loadCatalog(memberUuid);
        int orderIndex = catalog.orderIndexOf(topicUuid);
        if (orderIndex < 0) {
            throw new CustomException(ErrorCode.TOPIC_NOT_FOUND);
        }
        Topic topic = catalog.topics().get(orderIndex);
        List<ConceptTag> concepts = catalog.conceptsOf(topicUuid);
        List<UUID> conceptUuids = concepts.stream().map(ConceptTag::getConceptTagUuid).toList();
        Map<UUID, Integer> questionCountByConcept = countCheckQuestions(conceptUuids);
        Map<UUID, MemberConceptProgress> progressByConcept = loadProgress(memberUuid, conceptUuids);

        List<ConceptSummary> summaries = concepts.stream()
            .map(concept -> toSummary(concept, progressByConcept.get(concept.getConceptTagUuid()),
                questionCountByConcept.getOrDefault(concept.getConceptTagUuid(), 0)))
            .toList();
        boolean isLocked = !featureAccessPolicy.canOpenConceptTopic(memberUuid, orderIndex);
        return new ConceptListResponse(topicUuid, topic.getDisplayName(), isLocked, summaries);
    }

    /** 개념 상세: 접근 확인 > 본문·문단 > 같은 단원 이전·다음 > 내 진행 > 관련 문제 */
    public ConceptDetailResponse getConceptDetail(UUID memberUuid, UUID conceptUuid) {
        AccessibleConcept accessible = requireAccessibleConcept(memberUuid, conceptUuid);
        ConceptTag concept = accessible.concept();
        ConceptDoc doc = conceptDocRepository.findFirstByConceptTagUuidAndIsActiveTrue(conceptUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.CONCEPT_NOT_FOUND));

        // 같은 단원 안 이웃 개념 (노출 대상 기준)
        List<ConceptTag> siblings = accessible.siblings();
        int position = siblings.indexOf(concept);
        UUID previousConceptUuid = position > 0 ? siblings.get(position - 1).getConceptTagUuid() : null;
        UUID nextConceptUuid = position >= 0 && position < siblings.size() - 1
            ? siblings.get(position + 1).getConceptTagUuid() : null;

        MemberConceptProgress progress = progressRepository.findByMemberUuidAndConceptTagUuid(memberUuid, conceptUuid)
            .orElse(null);
        List<UUID> relatedQuestionUuids = questionConceptTagRepository.findByConceptTagUuid(conceptUuid).stream()
            .map(QuestionConceptTag::getQuestionUuid)
            .toList();

        return new ConceptDetailResponse(
            conceptUuid,
            concept.getTopicUuid(),
            concept.getLabelKo(),
            concept.getSummary(),
            doc.getCoreMd(),
            detailSectionParser.parse(doc.getDetailMd()),
            previousConceptUuid,
            nextConceptUuid,
            progress != null ? progress.getLastMode() : ConceptStudyMode.READ,
            progress != null ? progress.getLastDepth() : ConceptReadingDepth.CORE,
            progress != null && Boolean.TRUE.equals(progress.getIsRead()),
            progress != null ? progress.getCheckCorrectCount() : 0,
            relatedQuestionUuids);
    }

    /** 확인 문제 목록 (정답·풀이 미포함, 보기는 순서대로) */
    public List<ConceptCheckQuestionResponse> getCheckQuestions(UUID memberUuid, UUID conceptUuid) {
        requireAccessibleConcept(memberUuid, conceptUuid);
        List<ConceptCheckQuestion> questions = checkQuestionRepository.findByConceptTagUuidOrderBySortOrderAsc(conceptUuid);
        List<UUID> questionUuids = questions.stream().map(ConceptCheckQuestion::getConceptCheckQuestionUuid).toList();
        Map<UUID, List<ConceptCheckChoice>> choicesByQuestion = questionUuids.isEmpty()
            ? Map.of()
            : checkChoiceRepository.findByConceptCheckQuestionUuidInOrderBySortOrderAsc(questionUuids).stream()
                .collect(Collectors.groupingBy(ConceptCheckChoice::getConceptCheckQuestionUuid));

        return questions.stream()
            .map(question -> new ConceptCheckQuestionResponse(
                question.getConceptCheckQuestionUuid(),
                question.getSortOrder(),
                question.getStem(),
                question.getStemSql(),
                choicesByQuestion.getOrDefault(question.getConceptCheckQuestionUuid(), List.of()).stream()
                    .map(choice -> new ConceptCheckChoiceResponse(choice.getChoiceKey(), choice.getBody()))
                    .toList()))
            .toList();
    }

    // ===== 접근 판정 =====

    /** 개념 접근: 이용 가능 > 존재·노출(초안은 미리보기 회원만, 아니면 404) > 단원 잠금(403) */
    AccessibleConcept requireAccessibleConcept(UUID memberUuid, UUID conceptUuid) {
        requireAvailable(memberUuid);
        ConceptCatalog catalog = loadCatalog(memberUuid);
        ConceptTag concept = conceptTagRepository.findById(conceptUuid)
            .filter(found -> catalog.isVisible(found.getConceptTagUuid()))
            .orElseThrow(() -> new CustomException(ErrorCode.CONCEPT_NOT_FOUND));
        int orderIndex = catalog.orderIndexOf(concept.getTopicUuid());
        if (orderIndex < 0) {
            throw new CustomException(ErrorCode.CONCEPT_NOT_FOUND);
        }
        if (!featureAccessPolicy.canOpenConceptTopic(memberUuid, orderIndex)) {
            throw new CustomException(ErrorCode.PRO_REQUIRED);
        }
        return new AccessibleConcept(concept, catalog.conceptsOf(concept.getTopicUuid()));
    }

    private void requireAvailable(UUID memberUuid) {
        if (!availabilityPolicy.isAvailableFor(memberUuid)) {
            throw new CustomException(ErrorCode.CONCEPT_NOT_FOUND);
        }
    }

    // ===== 조회 묶음 =====

    /** 활성 단원(정렬) + 회원에게 보이는 개념 (초안은 미리보기 회원만) */
    private ConceptCatalog loadCatalog(UUID memberUuid) {
        List<Topic> topics = topicRepository.findByIsActiveTrueOrderBySortOrderAsc();
        List<UUID> topicUuids = topics.stream().map(Topic::getTopicUuid).toList();
        boolean canSeeDrafts = availabilityPolicy.canSeeDrafts(memberUuid);
        List<ConceptTag> visibleConcepts = topicUuids.isEmpty()
            ? List.of()
            : conceptTagRepository.findByTopicUuidInAndIsActiveTrueOrderBySortOrderAsc(topicUuids).stream()
                .filter(concept -> canSeeDrafts || concept.getPublishStatus() == ConceptPublishStatus.PUBLISHED)
                .toList();
        return new ConceptCatalog(topics, visibleConcepts);
    }

    private Map<UUID, Integer> countCheckQuestions(Collection<UUID> conceptUuids) {
        if (conceptUuids.isEmpty()) {
            return Map.of();
        }
        return checkQuestionRepository.findByConceptTagUuidIn(conceptUuids).stream()
            .collect(Collectors.groupingBy(ConceptCheckQuestion::getConceptTagUuid, Collectors.summingInt(question -> 1)));
    }

    private Map<UUID, MemberConceptProgress> loadProgress(UUID memberUuid, Collection<UUID> conceptUuids) {
        if (conceptUuids.isEmpty()) {
            return Map.of();
        }
        return progressRepository.findByMemberUuidAndConceptTagUuidIn(memberUuid, conceptUuids).stream()
            .collect(Collectors.toMap(MemberConceptProgress::getConceptTagUuid, Function.identity(), (first, second) -> first));
    }

    private ConceptSummary toSummary(ConceptTag concept, MemberConceptProgress progress, int checkQuestionCount) {
        return new ConceptSummary(
            concept.getConceptTagUuid(),
            concept.getLabelKo(),
            concept.getSummary(),
            toStatus(progress, checkQuestionCount),
            progress != null ? progress.getCheckCorrectCount() : 0,
            checkQuestionCount);
    }

    /** 진행 > 상태: 확인 문제 전부 풂 SOLVED, 읽음 READ, 그 외 NOT_STARTED */
    static ConceptStatus toStatus(MemberConceptProgress progress, int checkQuestionCount) {
        if (progress == null) {
            return ConceptStatus.NOT_STARTED;
        }
        if (checkQuestionCount > 0 && progress.getCheckSolvedCount() >= checkQuestionCount) {
            return ConceptStatus.SOLVED;
        }
        return Boolean.TRUE.equals(progress.getIsRead()) ? ConceptStatus.READ : ConceptStatus.NOT_STARTED;
    }

    /** 접근 확인을 통과한 개념과 같은 단원 개념들 (노출 대상, 정렬) */
    record AccessibleConcept(ConceptTag concept, List<ConceptTag> siblings) {
    }

    /** 활성 단원 순서 + 노출 개념 묶음 */
    private record ConceptCatalog(List<Topic> topics, List<ConceptTag> visibleConcepts) {

        List<ConceptTag> conceptsOf(UUID topicUuid) {
            return visibleConcepts.stream()
                .filter(concept -> Objects.equals(concept.getTopicUuid(), topicUuid))
                .toList();
        }

        List<UUID> visibleConceptUuids() {
            return visibleConcepts.stream().map(ConceptTag::getConceptTagUuid).toList();
        }

        boolean isVisible(UUID conceptUuid) {
            return visibleConcepts.stream().anyMatch(concept -> concept.getConceptTagUuid().equals(conceptUuid));
        }

        int orderIndexOf(UUID topicUuid) {
            for (int index = 0; index < topics.size(); index++) {
                if (topics.get(index).getTopicUuid().equals(topicUuid)) {
                    return index;
                }
            }
            return -1;
        }
    }
}
