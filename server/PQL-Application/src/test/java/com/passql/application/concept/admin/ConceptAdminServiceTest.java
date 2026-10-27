package com.passql.application.concept.admin;

import com.passql.application.concept.admin.dto.AdminConceptPreview;
import com.passql.application.concept.admin.dto.AdminConceptTopicGroup;
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
import com.passql.meta.service.concept.ConceptDetailSectionParser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationEventPublisher;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 개념 학습 관리자: 단원별 목록, 일괄 공개(확인 문제 5개만), 본문 수정 앵커 보존, 미리보기
 */
class ConceptAdminServiceTest {

    final TopicRepository topicRepository = mock(TopicRepository.class);
    final ConceptTagRepository conceptTagRepository = mock(ConceptTagRepository.class);
    final ConceptDocRepository conceptDocRepository = mock(ConceptDocRepository.class);
    final ConceptCheckQuestionRepository checkQuestionRepository = mock(ConceptCheckQuestionRepository.class);
    final ConceptCheckChoiceRepository checkChoiceRepository = mock(ConceptCheckChoiceRepository.class);
    final ConceptBundleImportService bundleImportService = mock(ConceptBundleImportService.class);
    final ApplicationEventPublisher eventPublisher = mock(ApplicationEventPublisher.class);
    final ConceptAdminService service = new ConceptAdminService(topicRepository, conceptTagRepository,
        conceptDocRepository, checkQuestionRepository, checkChoiceRepository, bundleImportService,
        new ConceptDetailSectionParser(), eventPublisher);

    final Topic modelingTopic = Topic.builder().topicUuid(UUID.randomUUID()).code("MODELING").displayName("데이터 모델링")
        .sortOrder(1).isActive(true).build();
    final List<ConceptTag> tags = new ArrayList<>();
    final List<ConceptCheckQuestion> questions = new ArrayList<>();

    @BeforeEach
    void setUp() {
        when(topicRepository.findByIsActiveTrueOrderBySortOrderAsc()).thenReturn(List.of(modelingTopic));
        when(conceptTagRepository.findByTopicUuidInAndIsActiveTrueOrderBySortOrderAsc(anyCollection())).thenReturn(tags);
        when(checkQuestionRepository.findByConceptTagUuidIn(anyCollection())).thenReturn(questions);
        when(conceptTagRepository.save(any(ConceptTag.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(conceptDocRepository.save(any(ConceptDoc.class))).thenAnswer(invocation -> invocation.getArgument(0));
    }

    private ConceptTag addTag(String tagKey, ConceptPublishStatus status, int questionCount) {
        ConceptTag tag = ConceptTag.builder().conceptTagUuid(UUID.randomUUID()).tagKey(tagKey).labelKo(tagKey)
            .topicUuid(modelingTopic.getTopicUuid()).sortOrder(tags.size() + 1).publishStatus(status).isActive(true).build();
        tags.add(tag);
        for (int order = 1; order <= questionCount; order++) {
            questions.add(ConceptCheckQuestion.builder().conceptCheckQuestionUuid(UUID.randomUUID())
                .conceptTagUuid(tag.getConceptTagUuid()).sortOrder(order).stem("문제").explanation("풀이")
                .rereadAnchor("confusing").build());
        }
        when(conceptTagRepository.findById(tag.getConceptTagUuid())).thenReturn(Optional.of(tag));
        return tag;
    }

    @Test
    void listByTopic_groupsWithStatusAndQuestionCount() {
        addTag("entity", ConceptPublishStatus.PUBLISHED, 5);
        addTag("attribute", ConceptPublishStatus.DRAFT, 3);

        List<AdminConceptTopicGroup> groups = service.listByTopic();

        assertThat(groups).hasSize(1);
        assertThat(groups.get(0).displayName()).isEqualTo("데이터 모델링");
        assertThat(groups.get(0).concepts()).extracting("tagKey").containsExactly("entity", "attribute");
        assertThat(groups.get(0).concepts()).extracting("checkQuestionCount").containsExactly(5, 3);
    }

    @Test
    void publishAll_publishesOnlyDraftsWithFiveQuestions() {
        ConceptTag ready = addTag("entity", ConceptPublishStatus.DRAFT, 5);
        ConceptTag notReady = addTag("attribute", ConceptPublishStatus.DRAFT, 3);

        int publishedCount = service.publishAll();

        assertThat(publishedCount).isEqualTo(1);
        assertThat(ready.getPublishStatus()).isEqualTo(ConceptPublishStatus.PUBLISHED);
        assertThat(notReady.getPublishStatus()).isEqualTo(ConceptPublishStatus.DRAFT);
    }

    @Test
    void updateContent_removingUsedAnchor_rejectedWithAnchorName() {
        ConceptTag tag = addTag("entity", ConceptPublishStatus.DRAFT, 5);
        when(conceptDocRepository.findFirstByConceptTagUuidAndIsActiveTrue(tag.getConceptTagUuid()))
            .thenReturn(Optional.of(ConceptDoc.builder().conceptTagUuid(tag.getConceptTagUuid()).isActive(true).build()));
        when(checkQuestionRepository.findByConceptTagUuidOrderBySortOrderAsc(tag.getConceptTagUuid()))
            .thenReturn(questions);

        assertThatThrownBy(() -> service.updateContent(tag.getConceptTagUuid(), "엔터티", "요약", "핵심",
            "## 왜 {#why}\n본문"))
            .isInstanceOf(CustomException.class)
            .hasMessageContaining("confusing")
            .extracting("errorCode").isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void updateContent_valid_savesAllFields() {
        ConceptTag tag = addTag("entity", ConceptPublishStatus.DRAFT, 5);
        ConceptDoc doc = ConceptDoc.builder().conceptTagUuid(tag.getConceptTagUuid()).isActive(true).build();
        when(conceptDocRepository.findFirstByConceptTagUuidAndIsActiveTrue(tag.getConceptTagUuid())).thenReturn(Optional.of(doc));
        when(checkQuestionRepository.findByConceptTagUuidOrderBySortOrderAsc(tag.getConceptTagUuid())).thenReturn(questions);

        service.updateContent(tag.getConceptTagUuid(), "엔터티", "요약", "핵심", "## 헷갈리는 점 {#confusing}\n본문");

        assertThat(tag.getLabelKo()).isEqualTo("엔터티");
        assertThat(tag.getSummary()).isEqualTo("요약");
        assertThat(doc.getCoreMd()).isEqualTo("핵심");
        assertThat(doc.getDetailMd()).contains("{#confusing}");
    }

    @Test
    void getPreview_includesSectionsAndCorrectAnswers() {
        ConceptTag tag = addTag("entity", ConceptPublishStatus.DRAFT, 1);
        ConceptCheckQuestion question = questions.get(0);
        when(conceptDocRepository.findFirstByConceptTagUuidAndIsActiveTrue(tag.getConceptTagUuid()))
            .thenReturn(Optional.of(ConceptDoc.builder().conceptTagUuid(tag.getConceptTagUuid()).coreMd("핵심")
                .detailMd("## 헷갈리는 점 {#confusing}\n본문").isActive(true).build()));
        when(checkQuestionRepository.findByConceptTagUuidOrderBySortOrderAsc(tag.getConceptTagUuid())).thenReturn(questions);
        when(checkChoiceRepository.findByConceptCheckQuestionUuidInOrderBySortOrderAsc(anyCollection())).thenReturn(List.of(
            ConceptCheckChoice.builder().conceptCheckQuestionUuid(question.getConceptCheckQuestionUuid())
                .choiceKey("A").body("보기").isCorrect(true).sortOrder(1).build()));

        AdminConceptPreview preview = service.getPreview(tag.getConceptTagUuid());

        assertThat(preview.sections()).extracting("anchor").containsExactly("confusing");
        assertThat(preview.checkQuestions().get(0).correctKey()).isEqualTo("A");
    }
}
