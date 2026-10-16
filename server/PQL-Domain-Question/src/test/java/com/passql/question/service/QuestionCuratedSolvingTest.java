package com.passql.question.service;

import com.passql.meta.repository.SubtopicRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.constant.ChoiceKind;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.dto.ChoiceSetGenerateResponse;
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
 * 풀이용 고정 세트 (#511): CURATED_ONLY 상세는 고정 세트 우선, 고정 세트 응답은 순서 섞기·순번 1..4
 */
class QuestionCuratedSolvingTest {

    private final QuestionRepository questionRepository = mock(QuestionRepository.class);
    private final QuestionChoiceSetRepository choiceSetRepository = mock(QuestionChoiceSetRepository.class);
    private final QuestionChoiceSetItemRepository choiceSetItemRepository = mock(QuestionChoiceSetItemRepository.class);
    private QuestionService questionService;

    private final UUID questionUuid = UUID.randomUUID();
    private final UUID curatedSetUuid = UUID.randomUUID();
    private final UUID aiSetUuid = UUID.randomUUID();

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

        when(questionRepository.findById(questionUuid)).thenReturn(Optional.of(Question.builder()
                .questionUuid(questionUuid).stem("결과로 옳은 것은?")
                .choiceSetPolicy(ChoiceSetPolicy.CURATED_ONLY).build()));
        QuestionChoiceSet curatedSet = QuestionChoiceSet.builder().choiceSetUuid(curatedSetUuid)
                .questionUuid(questionUuid).source(ChoiceSetSource.ADMIN_CURATED).status(ChoiceSetStatus.OK).build();
        when(choiceSetRepository.findFirstByQuestionUuidAndStatusAndSourceInOrderByCreatedAtDesc(
                questionUuid, ChoiceSetStatus.OK, ChoiceSetSource.CURATED_SOURCES)).thenReturn(Optional.of(curatedSet));
        when(choiceSetRepository.findFirstByQuestionUuidAndStatusOrderByCreatedAtDesc(questionUuid, ChoiceSetStatus.OK))
                .thenReturn(Optional.of(QuestionChoiceSet.builder().choiceSetUuid(aiSetUuid)
                        .source(ChoiceSetSource.AI_RUNTIME).status(ChoiceSetStatus.OK).build()));
        when(choiceSetRepository.findById(curatedSetUuid)).thenReturn(Optional.of(curatedSet));
        when(choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(curatedSetUuid)).thenReturn(List.of(
                item("A", 0, true), item("B", 1, false), item("C", 2, false), item("D", 3, false)));
    }

    private QuestionChoiceSetItem item(String choiceKey, int sortOrder, boolean isCorrect) {
        return QuestionChoiceSetItem.builder().choiceSetUuid(curatedSetUuid).choiceKey(choiceKey)
                .sortOrder(sortOrder).kind(ChoiceKind.TEXT).body("보기 " + choiceKey).isCorrect(isCorrect).build();
    }

    @Test
    void solvingDetail_prefersCuratedSetOverNewerAiSet() {
        QuestionDetail detail = questionService.getQuestionForSolving(questionUuid);

        assertThat(detail.choiceSets()).hasSize(1);
        assertThat(detail.choiceSets().get(0).choiceSetUuid()).isEqualTo(curatedSetUuid);
        assertThat(detail.choiceSets().get(0).items()).extracting(QuestionDetail.ChoiceItem::isCorrect).containsOnlyNulls();
        assertThat(detail.choiceSets().get(0).items()).extracting(QuestionDetail.ChoiceItem::sortOrder).containsExactly(1, 2, 3, 4);
    }

    @Test
    void curatedChoiceSetForSolving_keepsKeysAndRenumbers() {
        ChoiceSetGenerateResponse response = questionService.getChoiceSetForSolving(curatedSetUuid);

        assertThat(response.choices()).extracting(ChoiceSetGenerateResponse.ChoiceItem::key)
                .containsExactlyInAnyOrder("A", "B", "C", "D");
        assertThat(response.choices()).extracting(ChoiceSetGenerateResponse.ChoiceItem::sortOrder)
                .containsExactly(1, 2, 3, 4);
    }
}
