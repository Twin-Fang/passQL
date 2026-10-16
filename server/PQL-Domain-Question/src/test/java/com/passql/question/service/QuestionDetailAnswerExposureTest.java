package com.passql.question.service;

import com.passql.meta.repository.SubtopicRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.dto.QuestionDetail;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.QuestionChoiceRepository;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.question.repository.QuestionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationEventPublisher;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 문제 상세 정답 노출 차단 (#503): 풀이용은 정답 SQL·정답 여부·해설 제외, 관리자용은 포함
 */
class QuestionDetailAnswerExposureTest {

    private final QuestionRepository questionRepository = mock(QuestionRepository.class);
    private final QuestionChoiceSetRepository choiceSetRepository = mock(QuestionChoiceSetRepository.class);
    private final QuestionChoiceSetItemRepository choiceSetItemRepository = mock(QuestionChoiceSetItemRepository.class);
    private QuestionService questionService;

    private final UUID questionUuid = UUID.randomUUID();
    private final UUID latestOkChoiceSetUuid = UUID.randomUUID();
    private final UUID olderChoiceSetUuid = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        questionService = new QuestionService(
                questionRepository,
                mock(QuestionChoiceRepository.class),
                choiceSetRepository,
                choiceSetItemRepository,
                mock(DailyChallengeRepository.class),
                mock(TopicRepository.class),
                mock(SubtopicRepository.class),
                mock(ApplicationEventPublisher.class));

        Question question = Question.builder()
                .questionUuid(questionUuid)
                .stem("결과가 다른 것은?")
                .answerSql("SELECT 1")
                .build();
        QuestionChoiceSet latestOkChoiceSet = QuestionChoiceSet.builder()
                .choiceSetUuid(latestOkChoiceSetUuid).questionUuid(questionUuid).status(ChoiceSetStatus.OK).build();
        QuestionChoiceSet olderChoiceSet = QuestionChoiceSet.builder()
                .choiceSetUuid(olderChoiceSetUuid).questionUuid(questionUuid).status(ChoiceSetStatus.OK).build();

        when(questionRepository.findById(questionUuid)).thenReturn(Optional.of(question));
        when(choiceSetRepository.findFirstByQuestionUuidAndStatusOrderByCreatedAtDesc(questionUuid, ChoiceSetStatus.OK))
                .thenReturn(Optional.of(latestOkChoiceSet));
        when(choiceSetRepository.findByQuestionUuidOrderByCreatedAtDesc(questionUuid))
                .thenReturn(List.of(latestOkChoiceSet, olderChoiceSet));
        when(choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(latestOkChoiceSetUuid))
                .thenReturn(List.of(choiceItem("A", true), choiceItem("B", false)));
        when(choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(olderChoiceSetUuid))
                .thenReturn(List.of(choiceItem("A", false), choiceItem("B", true)));
    }

    @Test
    void 풀이용_상세는_정답과_해설을_내려주지_않는다() {
        QuestionDetail detail = questionService.getQuestionForSolving(questionUuid);

        assertThat(detail.answerSql()).isNull();
        assertThat(detail.choiceSets()).hasSize(1);
        assertThat(detail.choiceSets().get(0).choiceSetUuid()).isEqualTo(latestOkChoiceSetUuid);
        assertThat(detail.choiceSets().get(0).items())
                .extracting(QuestionDetail.ChoiceItem::key)
                .containsExactly("A", "B");
        assertThat(detail.choiceSets().get(0).items())
                .allSatisfy(item -> {
                    assertThat(item.isCorrect()).isNull();
                    assertThat(item.rationale()).isNull();
                    assertThat(item.body()).isNotBlank();
                });
    }

    @Test
    void 관리자_상세는_모든_세트와_정답을_포함한다() {
        QuestionDetail detail = questionService.getQuestionForAdmin(questionUuid);

        assertThat(detail.answerSql()).isEqualTo("SELECT 1");
        assertThat(detail.choiceSets()).hasSize(2);
        assertThat(detail.choiceSets().get(0).items().get(0).isCorrect()).isTrue();
        assertThat(detail.choiceSets().get(0).items().get(0).rationale()).isEqualTo("A 해설");
    }

    private QuestionChoiceSetItem choiceItem(String choiceKey, boolean isCorrect) {
        return QuestionChoiceSetItem.builder()
                .choiceKey(choiceKey)
                .body("SELECT '" + choiceKey + "'")
                .isCorrect(isCorrect)
                .rationale(choiceKey + " 해설")
                .sortOrder(choiceKey.charAt(0) - 'A')
                .build();
    }
}
