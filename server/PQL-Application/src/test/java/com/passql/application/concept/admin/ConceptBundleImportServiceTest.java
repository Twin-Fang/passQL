package com.passql.application.concept.admin;

import com.passql.application.concept.admin.dto.ConceptBundleImportResult;
import com.passql.common.exception.CustomException;
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
import com.passql.question.repository.QuestionConceptTagRepository;
import com.passql.question.repository.QuestionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static com.passql.application.concept.admin.ConceptBundleFixtures.bundleOf;
import static com.passql.application.concept.admin.ConceptBundleFixtures.checkQuestions;
import static com.passql.application.concept.admin.ConceptBundleFixtures.itemWith;
import static com.passql.application.concept.admin.ConceptBundleFixtures.validItem;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 묶음 저장: tagKey 기준 갱신(중복 없음), 공개 상태 유지, 검증 실패면 아무것도 저장 안 함
 */
class ConceptBundleImportServiceTest {

    final TopicRepository topicRepository = mock(TopicRepository.class);
    final QuestionRepository questionRepository = mock(QuestionRepository.class);
    final ConceptTagRepository conceptTagRepository = mock(ConceptTagRepository.class);
    final ConceptDocRepository conceptDocRepository = mock(ConceptDocRepository.class);
    final ConceptCheckQuestionRepository checkQuestionRepository = mock(ConceptCheckQuestionRepository.class);
    final ConceptCheckChoiceRepository checkChoiceRepository = mock(ConceptCheckChoiceRepository.class);
    final QuestionConceptTagRepository questionConceptTagRepository = mock(QuestionConceptTagRepository.class);
    final ConceptBundleValidator validator =
        new ConceptBundleValidator(topicRepository, questionRepository, new ConceptDetailSectionParser());
    final ConceptBundleImportService service = new ConceptBundleImportService(validator, topicRepository,
        conceptTagRepository, conceptDocRepository, checkQuestionRepository, checkChoiceRepository, questionConceptTagRepository);

    final Map<String, ConceptTag> savedTagsByKey = new HashMap<>();
    final List<ConceptCheckQuestion> savedQuestions = new ArrayList<>();

    @BeforeEach
    void setUp() {
        Topic selectTopic = Topic.builder().topicUuid(UUID.randomUUID()).code("SELECT_BASIC").isActive(true).build();
        when(topicRepository.findByIsActiveTrueOrderBySortOrderAsc()).thenReturn(List.of(selectTopic));
        when(conceptTagRepository.findByTagKey(anyString()))
            .thenAnswer(invocation -> Optional.ofNullable(savedTagsByKey.get(invocation.<String>getArgument(0))));
        when(conceptTagRepository.save(any(ConceptTag.class))).thenAnswer(invocation -> {
            ConceptTag tag = invocation.getArgument(0);
            if (tag.getConceptTagUuid() == null) {
                tag.setConceptTagUuid(UUID.randomUUID());
            }
            savedTagsByKey.put(tag.getTagKey(), tag);
            return tag;
        });
        when(conceptDocRepository.findFirstByConceptTagUuidAndIsActiveTrue(any())).thenReturn(Optional.empty());
        when(conceptDocRepository.save(any(ConceptDoc.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(checkQuestionRepository.save(any(ConceptCheckQuestion.class))).thenAnswer(invocation -> {
            ConceptCheckQuestion question = invocation.getArgument(0);
            question.setConceptCheckQuestionUuid(UUID.randomUUID());
            savedQuestions.add(question);
            return question;
        });
        when(checkChoiceRepository.save(any(ConceptCheckChoice.class))).thenAnswer(invocation -> invocation.getArgument(0));
    }

    @Test
    void importBundle_sameTagKeyTwice_updatesWithoutDuplicate() {
        ConceptBundleImportResult first = service.importBundle(bundleOf(validItem("select-where-null")));
        ConceptBundleImportResult second = service.importBundle(bundleOf(validItem("select-where-null")));

        assertThat(first.createdCount()).isEqualTo(1);
        assertThat(second.createdCount()).isZero();
        assertThat(second.updatedCount()).isEqualTo(1);
        assertThat(savedTagsByKey).hasSize(1);
        // 가져올 때마다 기존 확인 문제를 지우고 5개를 새로 저장 (누적 10개 저장 = 중복 아닌 교체)
        verify(checkQuestionRepository, times(2)).deleteByConceptTagUuid(savedTagsByKey.get("select-where-null").getConceptTagUuid());
        assertThat(savedQuestions).hasSize(10);
    }

    @Test
    void importBundle_newConceptIsDraft_existingPublishedStaysPublished() {
        service.importBundle(bundleOf(validItem("select-where-null")));
        ConceptTag saved = savedTagsByKey.get("select-where-null");
        assertThat(saved.getPublishStatus()).isEqualTo(ConceptPublishStatus.DRAFT);

        saved.setPublishStatus(ConceptPublishStatus.PUBLISHED);
        service.importBundle(bundleOf(validItem("select-where-null")));

        assertThat(savedTagsByKey.get("select-where-null").getPublishStatus()).isEqualTo(ConceptPublishStatus.PUBLISHED);
    }

    @Test
    void importBundle_invalid_savesNothing() {
        assertThatThrownBy(() -> service.importBundle(bundleOf(itemWith("select-where-null", checkQuestions(3, "why")))))
            .isInstanceOf(CustomException.class);

        verify(conceptTagRepository, never()).save(any());
        verify(checkQuestionRepository, never()).save(any());
    }
}
