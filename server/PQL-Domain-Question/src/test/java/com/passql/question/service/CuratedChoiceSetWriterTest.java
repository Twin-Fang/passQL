package com.passql.question.service;

import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.dto.CuratedChoiceDto;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.event.CuratedChoiceSetReplacedEvent;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.context.ApplicationEventPublisher;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 고정 세트 교체 > 교체 이벤트(비활성 세트 = 기존 고정 OK 세트만, 새 세트) 발행 (#1155)
 */
class CuratedChoiceSetWriterTest {

    private final QuestionChoiceSetRepository choiceSetRepository = mock(QuestionChoiceSetRepository.class);
    private final ApplicationEventPublisher eventPublisher = mock(ApplicationEventPublisher.class);
    private final CuratedChoiceSetWriter writer = new CuratedChoiceSetWriter(
        choiceSetRepository, mock(QuestionChoiceSetItemRepository.class), eventPublisher);

    @Test
    void 교체하면_비활성한_고정_세트와_새_세트로_이벤트를_발행한다() {
        UUID questionUuid = UUID.randomUUID();
        QuestionChoiceSet activeCuratedSet = choiceSetOf(questionUuid, ChoiceSetSource.ADMIN_CURATED, ChoiceSetStatus.OK);
        QuestionChoiceSet alreadyDisabledCuratedSet = choiceSetOf(questionUuid, ChoiceSetSource.ADMIN_CURATED, ChoiceSetStatus.DISABLED);
        QuestionChoiceSet aiSet = choiceSetOf(questionUuid, ChoiceSetSource.AI_RUNTIME, ChoiceSetStatus.OK);
        when(choiceSetRepository.findByQuestionUuidOrderByCreatedAtDesc(questionUuid))
            .thenReturn(List.of(activeCuratedSet, alreadyDisabledCuratedSet, aiSet));
        UUID newChoiceSetUuid = UUID.randomUUID();
        when(choiceSetRepository.saveAndFlush(any(QuestionChoiceSet.class))).thenAnswer(invocation -> {
            QuestionChoiceSet saved = invocation.getArgument(0);
            saved.setChoiceSetUuid(newChoiceSetUuid);
            return saved;
        });

        writer.replaceCuratedSet(questionUuid, List.of(new CuratedChoiceDto("A", "TEXT", "보기", true, "근거")));

        ArgumentCaptor<CuratedChoiceSetReplacedEvent> eventCaptor = ArgumentCaptor.forClass(CuratedChoiceSetReplacedEvent.class);
        verify(eventPublisher).publishEvent(eventCaptor.capture());
        CuratedChoiceSetReplacedEvent event = eventCaptor.getValue();
        assertThat(event.questionUuid()).isEqualTo(questionUuid);
        assertThat(event.disabledChoiceSetUuids()).containsExactly(activeCuratedSet.getChoiceSetUuid());
        assertThat(event.newChoiceSetUuid()).isEqualTo(newChoiceSetUuid);
        assertThat(activeCuratedSet.getStatus()).isEqualTo(ChoiceSetStatus.DISABLED);
        assertThat(aiSet.getStatus()).isEqualTo(ChoiceSetStatus.OK);
    }

    private static QuestionChoiceSet choiceSetOf(UUID questionUuid, ChoiceSetSource source, ChoiceSetStatus status) {
        return QuestionChoiceSet.builder()
            .choiceSetUuid(UUID.randomUUID())
            .questionUuid(questionUuid)
            .source(source)
            .status(status)
            .build();
    }
}
