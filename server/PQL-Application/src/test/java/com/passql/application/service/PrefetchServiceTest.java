package com.passql.application.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuizSession;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.question.repository.QuizSessionRepository;
import com.passql.question.service.ChoiceSetGenerationService;
import com.passql.question.service.QuestionService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Optional;
import java.util.UUID;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

/**
 * 프리페치 (#511): 다음 문제가 CURATED_ONLY 면 AI 보기 생성 건너뜀, 그 외 정책은 기존대로 생성
 */
class PrefetchServiceTest {

    private final QuizSessionRepository quizSessionRepository = mock(QuizSessionRepository.class);
    private final QuestionChoiceSetRepository choiceSetRepository = mock(QuestionChoiceSetRepository.class);
    private final ChoiceSetGenerationService choiceSetGenerationService = mock(ChoiceSetGenerationService.class);
    private final QuestionService questionService = mock(QuestionService.class);
    private PrefetchService prefetchService;

    private final UUID sessionUuid = UUID.randomUUID();
    private final UUID memberUuid = UUID.randomUUID();
    private final UUID nextQuestionUuid = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        prefetchService = new PrefetchService(quizSessionRepository, choiceSetRepository,
                choiceSetGenerationService, new ObjectMapper(), questionService);
        when(quizSessionRepository.findById(sessionUuid)).thenReturn(Optional.of(QuizSession.builder()
                .sessionUuid(sessionUuid).memberUuid(memberUuid).totalQuestions(2)
                .questionOrderJson("[\"" + UUID.randomUUID() + "\",\"" + nextQuestionUuid + "\"]").build()));
    }

    private void givenNextQuestionPolicy(ChoiceSetPolicy policy) {
        when(questionService.getQuestionEntityOrNull(nextQuestionUuid))
                .thenReturn(Question.builder().questionUuid(nextQuestionUuid).choiceSetPolicy(policy).build());
    }

    @Test
    void curatedNextQuestion_skipsAiGeneration() {
        givenNextQuestionPolicy(ChoiceSetPolicy.CURATED_ONLY);

        prefetchService.prefetchNext(sessionUuid, 0);

        verifyNoInteractions(choiceSetGenerationService);
    }

    @Test
    void aiOnlyNextQuestion_prefetchesAsBefore() {
        givenNextQuestionPolicy(ChoiceSetPolicy.AI_ONLY);

        prefetchService.prefetchNext(sessionUuid, 0);

        verify(choiceSetGenerationService).generate(nextQuestionUuid, memberUuid, ChoiceSetSource.AI_PREFETCH);
    }
}
