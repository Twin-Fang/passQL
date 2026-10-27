package com.passql.application.concept;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.application.concept.dto.ConceptCheckAnswerRequest;
import com.passql.application.concept.dto.ConceptCheckAnswerResponse;
import com.passql.application.concept.dto.ConceptCheckChoiceResponse;
import com.passql.application.concept.dto.ConceptCheckQuestionResponse;
import com.passql.application.concept.dto.ConceptDetailResponse;
import com.passql.application.concept.dto.ConceptListResponse;
import com.passql.application.concept.dto.ConceptProgressRequest;
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
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 개념 학습: 단원·개념 목록, 개념 상세, 확인 문제 조회
 * 노출 판정 순서: 이용 가능(공개·미리보기) > 초안 숨김(미리보기 회원 제외) > 단원 잠금(FeatureAccessPolicy)
 * 확인 문제 채점은 이 서비스 안에서 끝냄 (제출·통계·오답 노트·하루 한도와 무관)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ConceptLearningService {

    // answered_choice_keys_json 형식: 확인 문제 UUID 문자열 > 마지막 선택 키
    private static final TypeReference<LinkedHashMap<String, String>> ANSWERED_KEYS_TYPE = new TypeReference<>() {
    };

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

    /** 진행 저장: 접근 확인 > 진행 행(없으면 생성) > null 아닌 칸만 반영 (읽음은 되돌리지 않음) */
    @Transactional
    public void saveProgress(UUID memberUuid, UUID conceptUuid, ConceptProgressRequest request) {
        requireAccessibleConcept(memberUuid, conceptUuid);
        MemberConceptProgress progress = findOrCreateProgress(memberUuid, conceptUuid);
        if (Boolean.TRUE.equals(request.isRead())) {
            progress.setIsRead(true);
        }
        if (request.lastMode() != null) {
            progress.setLastMode(request.lastMode());
        }
        if (request.lastDepth() != null) {
            progress.setLastDepth(request.lastDepth());
        }
        progressRepository.save(progress);
    }

    /** 확인 문제 채점: 접근 확인 > 문제 소속 확인 > 보기 확인 > 마지막 답 갱신 > 누적 재계산 */
    @Transactional
    public ConceptCheckAnswerResponse answerCheckQuestion(UUID memberUuid, UUID conceptUuid, UUID questionUuid,
                                                         ConceptCheckAnswerRequest request) {
        requireAccessibleConcept(memberUuid, conceptUuid);
        ConceptCheckQuestion question = checkQuestionRepository.findById(questionUuid)
            .filter(found -> found.getConceptTagUuid().equals(conceptUuid))
            .orElseThrow(() -> new CustomException(ErrorCode.CONCEPT_CHECK_QUESTION_NOT_FOUND));
        List<ConceptCheckChoice> choices = checkChoiceRepository.findByConceptCheckQuestionUuidInOrderBySortOrderAsc(List.of(questionUuid));
        String selectedKey = request.choiceKey() == null ? "" : request.choiceKey().trim();
        boolean isKnownChoice = choices.stream().anyMatch(choice -> choice.getChoiceKey().equals(selectedKey));
        if (!isKnownChoice) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "unknown choiceKey");
        }
        String correctKey = choices.stream().filter(choice -> Boolean.TRUE.equals(choice.getIsCorrect()))
            .map(ConceptCheckChoice::getChoiceKey).findFirst()
            .orElseThrow(() -> new CustomException(ErrorCode.CONCEPT_CHECK_QUESTION_NOT_FOUND, "no correct choice"));

        // 문제별 마지막 답 갱신 > 정답 수·푼 수 재계산
        MemberConceptProgress progress = findOrCreateProgress(memberUuid, conceptUuid);
        Map<String, String> answeredKeys = readAnsweredKeys(progress);
        answeredKeys.put(questionUuid.toString(), selectedKey);
        int checkCorrectCount = countCorrectAnswers(answeredKeys, conceptUuid);
        progress.setAnsweredChoiceKeysJson(writeAnsweredKeys(answeredKeys));
        progress.setCheckSolvedCount(answeredKeys.size());
        progress.setCheckCorrectCount(checkCorrectCount);
        progress.setLastMode(ConceptStudyMode.SOLVE);
        progressRepository.save(progress);

        Map<String, String> rationaleByChoiceKey = new LinkedHashMap<>();
        choices.forEach(choice -> rationaleByChoiceKey.put(choice.getChoiceKey(),
            choice.getRationale() == null ? "" : choice.getRationale()));
        return new ConceptCheckAnswerResponse(
            selectedKey.equals(correctKey),
            correctKey,
            question.getExplanation(),
            question.getRereadAnchor(),
            rationaleByChoiceKey,
            checkCorrectCount,
            answeredKeys.size());
    }

    private MemberConceptProgress findOrCreateProgress(UUID memberUuid, UUID conceptUuid) {
        return progressRepository.findByMemberUuidAndConceptTagUuid(memberUuid, conceptUuid)
            .orElseGet(() -> MemberConceptProgress.builder()
                .memberUuid(memberUuid)
                .conceptTagUuid(conceptUuid)
                .build());
    }

    /** 마지막 답 목록 중 정답 수 (현재 개념의 문제·정답 기준, 지워진 문제는 제외) */
    private int countCorrectAnswers(Map<String, String> answeredKeys, UUID conceptUuid) {
        List<ConceptCheckQuestion> questions = checkQuestionRepository.findByConceptTagUuidOrderBySortOrderAsc(conceptUuid);
        List<UUID> questionUuids = questions.stream().map(ConceptCheckQuestion::getConceptCheckQuestionUuid).toList();
        if (questionUuids.isEmpty()) {
            questionUuids = answeredKeys.keySet().stream().map(UUID::fromString).toList();
        }
        Map<String, String> correctKeyByQuestion = checkChoiceRepository
            .findByConceptCheckQuestionUuidInOrderBySortOrderAsc(questionUuids).stream()
            .filter(choice -> Boolean.TRUE.equals(choice.getIsCorrect()))
            .collect(Collectors.toMap(choice -> choice.getConceptCheckQuestionUuid().toString(),
                ConceptCheckChoice::getChoiceKey, (first, second) -> first));
        return (int) answeredKeys.entrySet().stream()
            .filter(entry -> entry.getValue().equals(correctKeyByQuestion.get(entry.getKey())))
            .count();
    }

    private Map<String, String> readAnsweredKeys(MemberConceptProgress progress) {
        String json = progress.getAnsweredChoiceKeysJson();
        if (json == null || json.isBlank()) {
            return new LinkedHashMap<>();
        }
        try {
            return objectMapper.readValue(json, ANSWERED_KEYS_TYPE);
        } catch (JsonProcessingException e) {
            log.warn("[concept learning] answered keys unreadable, resetting : progress={}", progress.getMemberConceptProgressUuid());
            return new LinkedHashMap<>();
        }
    }

    private String writeAnsweredKeys(Map<String, String> answeredKeys) {
        try {
            return objectMapper.writeValueAsString(answeredKeys);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("answered keys serialization failed", e);
        }
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
