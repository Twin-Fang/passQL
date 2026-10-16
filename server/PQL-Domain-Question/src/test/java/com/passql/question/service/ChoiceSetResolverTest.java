package com.passql.question.service;

import com.passql.member.constant.ChoiceGenerationMode;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.repository.QuestionChoiceSetRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

/**
 * 보기 결정 정책: CURATED_ONLY 고정 세트 우선(모드 무관, AI 미호출), 고정 세트 없으면 AI 대체 (#511)
 */
class ChoiceSetResolverTest {

    private final QuestionService questionService = mock(QuestionService.class);
    private final QuestionChoiceSetRepository choiceSetRepository = mock(QuestionChoiceSetRepository.class);
    private final ChoiceSetGenerationService choiceSetGenerationService = mock(ChoiceSetGenerationService.class);
    private ChoiceSetResolver choiceSetResolver;

    private final UUID questionUuid = UUID.randomUUID();
    private final UUID memberUuid = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        choiceSetResolver = new ChoiceSetResolver(questionService, choiceSetRepository, choiceSetGenerationService);
    }

    private void givenQuestion(ChoiceSetPolicy policy, ExecutionMode executionMode) {
        Question question = Question.builder()
                .questionUuid(questionUuid)
                .choiceSetPolicy(policy)
                .executionMode(executionMode)
                .build();
        when(questionService.getQuestionEntity(questionUuid)).thenReturn(question);
    }

    private void givenCuratedSet(QuestionChoiceSet curatedSet) {
        when(choiceSetRepository.findFirstByQuestionUuidAndStatusAndSourceInOrderByCreatedAtDesc(
                questionUuid, ChoiceSetStatus.OK, ChoiceSetSource.CURATED_SOURCES))
                .thenReturn(Optional.ofNullable(curatedSet));
    }

    @ParameterizedTest
    @EnumSource(ChoiceGenerationMode.class)
    void curatedOnly_returnsCuratedSetInEveryModeWithoutAiCall(ChoiceGenerationMode mode) {
        givenQuestion(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.CONCEPT_ONLY);
        QuestionChoiceSet curatedSet = QuestionChoiceSet.builder()
                .choiceSetUuid(UUID.randomUUID()).questionUuid(questionUuid)
                .source(ChoiceSetSource.ADMIN_CURATED).status(ChoiceSetStatus.OK).build();
        givenCuratedSet(curatedSet);

        QuestionChoiceSet resolved = choiceSetResolver.resolveForUser(questionUuid, memberUuid, mode);

        assertThat(resolved).isSameAs(curatedSet);
        verifyNoInteractions(choiceSetGenerationService);
        verify(choiceSetRepository, never()).markConsumed(any(), any());
    }

    @Test
    void curatedOnly_conceptQuestionWithoutCuratedSet_fallsBackToConceptGeneration() {
        givenQuestion(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.CONCEPT_ONLY);
        givenCuratedSet(null);
        QuestionChoiceSet generatedSet = QuestionChoiceSet.builder().choiceSetUuid(UUID.randomUUID()).build();
        when(choiceSetGenerationService.generateConcept(questionUuid, memberUuid, ChoiceSetSource.AI_RUNTIME))
                .thenReturn(generatedSet);

        QuestionChoiceSet resolved = choiceSetResolver.resolveForUser(questionUuid, memberUuid, ChoiceGenerationMode.REAL);

        assertThat(resolved).isSameAs(generatedSet);
    }

    @Test
    void curatedOnly_executableQuestionWithoutCuratedSet_fallsBackToAiGeneration() {
        givenQuestion(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.EXECUTABLE);
        givenCuratedSet(null);
        QuestionChoiceSet generatedSet = QuestionChoiceSet.builder().choiceSetUuid(UUID.randomUUID()).build();
        when(choiceSetGenerationService.generate(questionUuid, memberUuid, ChoiceSetSource.AI_RUNTIME))
                .thenReturn(generatedSet);

        QuestionChoiceSet resolved = choiceSetResolver.resolveForUser(questionUuid, memberUuid, ChoiceGenerationMode.REAL);

        assertThat(resolved).isSameAs(generatedSet);
    }

    @Test
    void aiOnly_realMode_keepsRuntimeGeneration() {
        givenQuestion(ChoiceSetPolicy.AI_ONLY, ExecutionMode.EXECUTABLE);
        QuestionChoiceSet generatedSet = QuestionChoiceSet.builder().choiceSetUuid(UUID.randomUUID()).build();
        when(choiceSetGenerationService.generate(eq(questionUuid), eq(memberUuid), eq(ChoiceSetSource.AI_RUNTIME)))
                .thenReturn(generatedSet);

        QuestionChoiceSet resolved = choiceSetResolver.resolveForUser(questionUuid, memberUuid, ChoiceGenerationMode.REAL);

        assertThat(resolved).isSameAs(generatedSet);
        verify(choiceSetRepository, never()).findFirstByQuestionUuidAndStatusAndSourceInOrderByCreatedAtDesc(any(), any(), any());
    }
}
