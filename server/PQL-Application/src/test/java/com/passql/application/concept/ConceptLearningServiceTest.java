package com.passql.application.concept;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.application.concept.dto.ConceptCheckQuestionResponse;
import com.passql.application.concept.dto.ConceptDetailResponse;
import com.passql.application.concept.dto.ConceptTopicListResponse;
import com.passql.application.concept.dto.ConceptTopicSummary;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.ConceptPublishStatus;
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
import com.passql.question.repository.QuestionConceptTagRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 개념 학습 조회: 공개·미리보기 노출, 단원 잠금, 초안 숨김, 문단·이웃 개념
 */
class ConceptLearningServiceTest {

    final TopicRepository topicRepository = mock(TopicRepository.class);
    final ConceptTagRepository conceptTagRepository = mock(ConceptTagRepository.class);
    final ConceptDocRepository conceptDocRepository = mock(ConceptDocRepository.class);
    final ConceptCheckQuestionRepository checkQuestionRepository = mock(ConceptCheckQuestionRepository.class);
    final ConceptCheckChoiceRepository checkChoiceRepository = mock(ConceptCheckChoiceRepository.class);
    final MemberConceptProgressRepository progressRepository = mock(MemberConceptProgressRepository.class);
    final QuestionConceptTagRepository questionConceptTagRepository = mock(QuestionConceptTagRepository.class);
    final FeatureAccessPolicy featureAccessPolicy = mock(FeatureAccessPolicy.class);
    final ConceptAvailabilityPolicy availabilityPolicy = mock(ConceptAvailabilityPolicy.class);

    final ConceptLearningService service = new ConceptLearningService(
        topicRepository, conceptTagRepository, conceptDocRepository, checkQuestionRepository,
        checkChoiceRepository, progressRepository, questionConceptTagRepository,
        featureAccessPolicy, availabilityPolicy, new ConceptDetailSectionParser(), new ObjectMapper());

    final UUID memberUuid = UUID.randomUUID();
    final Topic modelingTopic = topic("MODELING", 1);
    final Topic selectTopic = topic("SELECT_BASIC", 2);
    final Topic ddlTopic = topic("DDL_DML_TCL", 3);
    final List<ConceptTag> allTags = new ArrayList<>();

    @BeforeEach
    void setUp() {
        when(topicRepository.findByIsActiveTrueOrderBySortOrderAsc()).thenReturn(List.of(modelingTopic, selectTopic, ddlTopic));
        when(conceptTagRepository.findByTopicUuidInAndIsActiveTrueOrderBySortOrderAsc(anyCollection())).thenReturn(allTags);
        when(progressRepository.findByMemberUuidAndConceptTagUuidIn(eq(memberUuid), anyCollection())).thenReturn(List.of());
        when(checkQuestionRepository.findByConceptTagUuidIn(anyCollection())).thenReturn(List.of());
        when(availabilityPolicy.isAvailableFor(memberUuid)).thenReturn(true);
        when(availabilityPolicy.canSeeDrafts(memberUuid)).thenReturn(false);
        when(featureAccessPolicy.canOpenConceptTopic(eq(memberUuid), anyInt()))
            .thenAnswer(invocation -> (int) invocation.getArgument(1) < 2);
        when(questionConceptTagRepository.findByConceptTagUuid(any())).thenReturn(List.of());
    }

    @Test
    void getTopics_notPublishedAndNotPreview_returnsUnavailableEmpty() {
        when(availabilityPolicy.isAvailableFor(memberUuid)).thenReturn(false);
        allTags.add(tag(modelingTopic, "entity", 1, ConceptPublishStatus.PUBLISHED));

        ConceptTopicListResponse response = service.getTopics(memberUuid);

        assertThat(response.isAvailable()).isFalse();
        assertThat(response.topics()).isEmpty();
    }

    @Test
    void getTopics_publishedHidesDraftConceptsAndCountsCompleted() {
        ConceptTag solvedTag = tag(modelingTopic, "entity", 1, ConceptPublishStatus.PUBLISHED);
        allTags.add(solvedTag);
        allTags.add(tag(modelingTopic, "attribute", 2, ConceptPublishStatus.PUBLISHED));
        allTags.add(tag(modelingTopic, "relation", 3, ConceptPublishStatus.DRAFT));
        when(checkQuestionRepository.findByConceptTagUuidIn(anyCollection()))
            .thenReturn(checkQuestions(solvedTag, 5));
        when(progressRepository.findByMemberUuidAndConceptTagUuidIn(eq(memberUuid), anyCollection()))
            .thenReturn(List.of(progress(solvedTag, 4, 5)));

        ConceptTopicListResponse response = service.getTopics(memberUuid);

        ConceptTopicSummary modeling = response.topics().get(0);
        assertThat(response.isAvailable()).isTrue();
        assertThat(response.topics()).hasSize(1);
        assertThat(modeling.conceptCount()).isEqualTo(2);
        assertThat(modeling.completedCount()).isEqualTo(1);
        assertThat(modeling.isLocked()).isFalse();
    }

    @Test
    void getTopics_previewMemberSeesDrafts() {
        when(availabilityPolicy.canSeeDrafts(memberUuid)).thenReturn(true);
        allTags.add(tag(modelingTopic, "entity", 1, ConceptPublishStatus.PUBLISHED));
        allTags.add(tag(modelingTopic, "attribute", 2, ConceptPublishStatus.PUBLISHED));
        allTags.add(tag(modelingTopic, "relation", 3, ConceptPublishStatus.DRAFT));

        assertThat(service.getTopics(memberUuid).topics().get(0).conceptCount()).isEqualTo(3);
    }

    @Test
    void getTopics_thirdTopicLockedForFreeMember() {
        allTags.add(tag(modelingTopic, "entity", 1, ConceptPublishStatus.PUBLISHED));
        allTags.add(tag(selectTopic, "select", 1, ConceptPublishStatus.PUBLISHED));
        allTags.add(tag(ddlTopic, "create", 1, ConceptPublishStatus.PUBLISHED));

        List<ConceptTopicSummary> topics = service.getTopics(memberUuid).topics();

        assertThat(topics).extracting(ConceptTopicSummary::isLocked).containsExactly(false, false, true);
        assertThat(topics).extracting(ConceptTopicSummary::orderIndex).containsExactly(0, 1, 2);
    }

    @Test
    void getConceptDetail_lockedTopicFreeMember_throwsProRequired() {
        ConceptTag lockedTag = tag(ddlTopic, "create", 1, ConceptPublishStatus.PUBLISHED);
        allTags.add(lockedTag);
        when(conceptTagRepository.findById(lockedTag.getConceptTagUuid())).thenReturn(Optional.of(lockedTag));

        assertThatThrownBy(() -> service.getConceptDetail(memberUuid, lockedTag.getConceptTagUuid()))
            .isInstanceOf(CustomException.class)
            .extracting("errorCode").isEqualTo(ErrorCode.PRO_REQUIRED);
    }

    @Test
    void getConceptDetail_draftForNonPreview_throwsConceptNotFound() {
        ConceptTag draftTag = tag(modelingTopic, "relation", 1, ConceptPublishStatus.DRAFT);
        allTags.add(draftTag);
        when(conceptTagRepository.findById(draftTag.getConceptTagUuid())).thenReturn(Optional.of(draftTag));

        assertThatThrownBy(() -> service.getConceptDetail(memberUuid, draftTag.getConceptTagUuid()))
            .isInstanceOf(CustomException.class)
            .extracting("errorCode").isEqualTo(ErrorCode.CONCEPT_NOT_FOUND);
    }

    @Test
    void getConceptDetail_returnsSectionsAndNeighbors() {
        ConceptTag firstTag = tag(modelingTopic, "entity", 1, ConceptPublishStatus.PUBLISHED);
        ConceptTag secondTag = tag(modelingTopic, "attribute", 2, ConceptPublishStatus.PUBLISHED);
        allTags.add(firstTag);
        allTags.add(secondTag);
        when(conceptTagRepository.findById(firstTag.getConceptTagUuid())).thenReturn(Optional.of(firstTag));
        when(conceptDocRepository.findFirstByConceptTagUuidAndIsActiveTrue(firstTag.getConceptTagUuid()))
            .thenReturn(Optional.of(doc(firstTag, "핵심", "## 왜 {#why}\n가\n## 헷갈리는 점 {#confusing}\n나")));
        when(progressRepository.findByMemberUuidAndConceptTagUuid(memberUuid, firstTag.getConceptTagUuid()))
            .thenReturn(Optional.empty());

        ConceptDetailResponse detail = service.getConceptDetail(memberUuid, firstTag.getConceptTagUuid());

        assertThat(detail.coreMd()).isEqualTo("핵심");
        assertThat(detail.detailSections()).extracting("anchor").containsExactly("why", "confusing");
        assertThat(detail.previousConceptUuid()).isNull();
        assertThat(detail.nextConceptUuid()).isEqualTo(secondTag.getConceptTagUuid());
        assertThat(detail.isRead()).isFalse();
    }

    @Test
    void getCheckQuestions_returnsChoicesInSortOrder() {
        ConceptTag conceptTag = tag(modelingTopic, "entity", 1, ConceptPublishStatus.PUBLISHED);
        allTags.add(conceptTag);
        ConceptCheckQuestion question = checkQuestions(conceptTag, 1).get(0);
        when(conceptTagRepository.findById(conceptTag.getConceptTagUuid())).thenReturn(Optional.of(conceptTag));
        when(checkQuestionRepository.findByConceptTagUuidOrderBySortOrderAsc(conceptTag.getConceptTagUuid()))
            .thenReturn(List.of(question));
        when(checkChoiceRepository.findByConceptCheckQuestionUuidInOrderBySortOrderAsc(anyCollection()))
            .thenReturn(List.of(choice(question, "A", 1, false), choice(question, "B", 2, true)));

        List<ConceptCheckQuestionResponse> questions = service.getCheckQuestions(memberUuid, conceptTag.getConceptTagUuid());

        assertThat(questions).hasSize(1);
        assertThat(questions.get(0).choices()).extracting("choiceKey").containsExactly("A", "B");
    }

    // ===== 테스트 데이터 =====

    static Topic topic(String code, int sortOrder) {
        return Topic.builder().topicUuid(UUID.randomUUID()).code(code).displayName(code).sortOrder(sortOrder).isActive(true).build();
    }

    static ConceptTag tag(Topic topic, String tagKey, int sortOrder, ConceptPublishStatus status) {
        return ConceptTag.builder().conceptTagUuid(UUID.randomUUID()).tagKey(tagKey).labelKo(tagKey)
            .topicUuid(topic.getTopicUuid()).sortOrder(sortOrder).publishStatus(status).isActive(true).build();
    }

    static ConceptDoc doc(ConceptTag conceptTag, String coreMd, String detailMd) {
        return ConceptDoc.builder().conceptDocUuid(UUID.randomUUID()).conceptTagUuid(conceptTag.getConceptTagUuid())
            .title(conceptTag.getLabelKo()).coreMd(coreMd).detailMd(detailMd).isActive(true).build();
    }

    static List<ConceptCheckQuestion> checkQuestions(ConceptTag conceptTag, int count) {
        List<ConceptCheckQuestion> questions = new ArrayList<>();
        for (int order = 1; order <= count; order++) {
            questions.add(ConceptCheckQuestion.builder().conceptCheckQuestionUuid(UUID.randomUUID())
                .conceptTagUuid(conceptTag.getConceptTagUuid()).sortOrder(order).stem("문제 " + order)
                .explanation("풀이").rereadAnchor("why").build());
        }
        return questions;
    }

    static ConceptCheckChoice choice(ConceptCheckQuestion question, String key, int sortOrder, boolean isCorrect) {
        return ConceptCheckChoice.builder().conceptCheckChoiceUuid(UUID.randomUUID())
            .conceptCheckQuestionUuid(question.getConceptCheckQuestionUuid()).choiceKey(key).body("보기 " + key)
            .isCorrect(isCorrect).sortOrder(sortOrder).build();
    }

    MemberConceptProgress progress(ConceptTag conceptTag, int correctCount, int solvedCount) {
        return MemberConceptProgress.builder().memberConceptProgressUuid(UUID.randomUUID()).memberUuid(memberUuid)
            .conceptTagUuid(conceptTag.getConceptTagUuid()).checkCorrectCount(correctCount).checkSolvedCount(solvedCount).build();
    }
}
