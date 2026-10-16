package com.passql.application.service;

import com.passql.ai.dto.AiResult;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.question.repository.QuestionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.mockito.ArgumentMatchers.any;

/**
 * 고정 세트 해설 (#511): 검증 근거 해설을 AI 해설로 덮어쓰지 않음 (조회·미리 생성 공통)
 */
class ChoiceExplanationCuratedTest {

    private final QuestionRepository questionRepository = mock(QuestionRepository.class);
    private final QuestionChoiceSetRepository choiceSetRepository = mock(QuestionChoiceSetRepository.class);
    private final QuestionChoiceSetItemRepository choiceSetItemRepository = mock(QuestionChoiceSetItemRepository.class);
    private final AiExplanationGenerator explanationGenerator = mock(AiExplanationGenerator.class);
    private ChoiceExplanationService choiceExplanationService;

    private final UUID questionUuid = UUID.randomUUID();
    private final UUID curatedSetUuid = UUID.randomUUID();
    private final QuestionChoiceSetItem curatedItem = QuestionChoiceSetItem.builder()
            .choiceSetUuid(curatedSetUuid).choiceKey("A").body("2").isCorrect(true)
            .rationale("D>B>A 전개 후 B 제외").explanation("D>B>A 전개 후 B 제외").build();

    private Question curatedQuestion() {
        return Question.builder().questionUuid(questionUuid).choiceSetPolicy(ChoiceSetPolicy.CURATED_ONLY).build();
    }

    @BeforeEach
    void setUp() {
        choiceExplanationService = new ChoiceExplanationService(
                questionRepository, choiceSetRepository, choiceSetItemRepository, explanationGenerator);
        when(choiceSetRepository.findById(curatedSetUuid)).thenReturn(Optional.of(QuestionChoiceSet.builder()
                .choiceSetUuid(curatedSetUuid).questionUuid(questionUuid).source(ChoiceSetSource.ADMIN_CURATED).build()));
        when(questionRepository.findById(questionUuid)).thenReturn(Optional.of(curatedQuestion()));
        when(choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(curatedSetUuid)).thenReturn(List.of(curatedItem));
        when(explanationGenerator.activeChoicePromptVersion()).thenReturn(3);
    }

    @Test
    void getOrCreate_curatedSet_returnsStoredRationaleWithoutAi() {
        AiResult result = choiceExplanationService.getOrCreateExplanation(
                curatedQuestion(), curatedSetUuid, "A");

        assertThat(result.text()).isEqualTo("D>B>A 전개 후 B 제외");
        verify(explanationGenerator, never()).generateChoiceExplanation(any(), any(), any());
        verify(choiceSetItemRepository, never()).save(any());
    }

    @Test
    void pregenerate_curatedSet_createsNothing() {
        int createdCount = choiceExplanationService.pregenerateExplanations(curatedSetUuid);

        assertThat(createdCount).isZero();
        verify(explanationGenerator, never()).generateChoiceExplanation(any(), any(), any());
    }
}
