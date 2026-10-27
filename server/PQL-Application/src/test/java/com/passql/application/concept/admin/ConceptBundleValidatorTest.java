package com.passql.application.concept.admin;

import com.passql.application.concept.admin.dto.ConceptBundleCheckQuestion;
import com.passql.application.concept.admin.dto.ConceptBundleValidationResult;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.meta.service.concept.ConceptDetailSectionParser;
import com.passql.question.repository.QuestionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static com.passql.application.concept.admin.ConceptBundleFixtures.bundleOf;
import static com.passql.application.concept.admin.ConceptBundleFixtures.checkQuestions;
import static com.passql.application.concept.admin.ConceptBundleFixtures.choices;
import static com.passql.application.concept.admin.ConceptBundleFixtures.itemWith;
import static com.passql.application.concept.admin.ConceptBundleFixtures.validItem;
import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 묶음 검증: 앵커 연결, 보기·정답 수, 확인 문제 5개, 단원 코드, tagKey 중복
 */
class ConceptBundleValidatorTest {

    final TopicRepository topicRepository = mock(TopicRepository.class);
    final QuestionRepository questionRepository = mock(QuestionRepository.class);
    final ConceptBundleValidator validator =
        new ConceptBundleValidator(topicRepository, questionRepository, new ConceptDetailSectionParser());

    @BeforeEach
    void setUp() {
        Topic selectTopic = Topic.builder().topicUuid(UUID.randomUUID()).code("SELECT_BASIC").isActive(true).build();
        when(topicRepository.findByIsActiveTrueOrderBySortOrderAsc()).thenReturn(List.of(selectTopic));
    }

    @Test
    void validate_validBundle_isValid() {
        ConceptBundleValidationResult result = validator.validate(bundleOf(validItem("select-where-null")));

        assertThat(result.isValid()).isTrue();
        assertThat(result.issues()).isEmpty();
    }

    @Test
    void validate_rereadAnchorMissingInDetail_reportsRereadAnchor() {
        ConceptBundleValidationResult result =
            validator.validate(bundleOf(itemWith("select-where-null", checkQuestions(5, "not-there"))));

        assertThat(result.isValid()).isFalse();
        assertThat(result.issues()).extracting("field").contains("rereadAnchor");
    }

    @Test
    void validate_zeroOrTwoCorrectChoices_reportsChoices() {
        List<ConceptBundleCheckQuestion> questions = new java.util.ArrayList<>(checkQuestions(4, "why"));
        questions.add(new ConceptBundleCheckQuestion(5, "문제 5", null, "풀이", "why", choices("A", "B")));

        ConceptBundleValidationResult result = validator.validate(bundleOf(itemWith("select-where-null", questions)));

        assertThat(result.issues()).extracting("field").contains("choices");
    }

    @Test
    void validate_notFiveCheckQuestions_reportsCheckQuestions() {
        ConceptBundleValidationResult result =
            validator.validate(bundleOf(itemWith("select-where-null", checkQuestions(4, "why"))));

        assertThat(result.issues()).extracting("field").contains("checkQuestions");
    }

    @Test
    void validate_unknownTopicAndDuplicateTagKey_reported() {
        ConceptBundleValidationResult result =
            validator.validate(bundleOf(validItem("same-key"), validItem("same-key")));

        assertThat(result.issues()).extracting("field").contains("tagKey");
    }

    @Test
    void validate_brokenDetailHeading_reportsDetailMd() {
        var item = new com.passql.application.concept.admin.dto.ConceptBundleItem("select-where-null", "SELECT_BASIC", 1,
            "제목", "요약", "핵심", "## 앵커 없음\n본문", checkQuestions(5, "why"), List.of());

        assertThat(validator.validate(bundleOf(item)).issues()).extracting("field").contains("detailMd");
    }
}
