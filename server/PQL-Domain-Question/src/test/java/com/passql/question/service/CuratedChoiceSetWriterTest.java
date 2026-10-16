package com.passql.question.service;

import com.passql.question.constant.ChoiceKind;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.dto.CuratedChoiceDto;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 고정 세트 교체 (#511): 기존 고정 OK 세트 DISABLED > 새 ADMIN_CURATED 세트, 해설=검증 근거, 순번 1..4
 */
class CuratedChoiceSetWriterTest {

    private final QuestionChoiceSetRepository choiceSetRepository = mock(QuestionChoiceSetRepository.class);
    private final QuestionChoiceSetItemRepository choiceSetItemRepository = mock(QuestionChoiceSetItemRepository.class);
    private CuratedChoiceSetWriter curatedChoiceSetWriter;

    private final UUID questionUuid = UUID.randomUUID();
    private final UUID newSetUuid = UUID.randomUUID();
    private final QuestionChoiceSet oldCuratedSet = QuestionChoiceSet.builder().choiceSetUuid(UUID.randomUUID())
            .questionUuid(questionUuid).source(ChoiceSetSource.ADMIN_SEED).status(ChoiceSetStatus.OK).build();
    private final QuestionChoiceSet aiSet = QuestionChoiceSet.builder().choiceSetUuid(UUID.randomUUID())
            .questionUuid(questionUuid).source(ChoiceSetSource.AI_RUNTIME).status(ChoiceSetStatus.OK).build();

    @BeforeEach
    void setUp() {
        curatedChoiceSetWriter = new CuratedChoiceSetWriter(choiceSetRepository, choiceSetItemRepository);
        when(choiceSetRepository.findByQuestionUuidOrderByCreatedAtDesc(questionUuid)).thenReturn(List.of(aiSet, oldCuratedSet));
        when(choiceSetRepository.saveAndFlush(any(QuestionChoiceSet.class))).thenAnswer(invocation -> {
            QuestionChoiceSet saved = invocation.getArgument(0);
            saved.setChoiceSetUuid(newSetUuid);
            return saved;
        });
    }

    private List<CuratedChoiceDto> fourChoices() {
        return List.of(
                new CuratedChoiceDto("A", null, "2", true, "D>B>A 전개 후 B 제외"),
                new CuratedChoiceDto("B", "TEXT", "3", false, "WHERE 가 전개 후 적용됨을 놓침"),
                new CuratedChoiceDto("C", "TEXT", "1", false, "시작 행만 셈"),
                new CuratedChoiceDto("D", "SQL", "SELECT 4 FROM DUAL", false, "전체 행 수"));
    }

    @Test
    void replace_disablesOnlyOldCuratedSetAndSavesNewCuratedSet() {
        QuestionChoiceSet saved = curatedChoiceSetWriter.replaceCuratedSet(questionUuid, fourChoices());

        assertThat(oldCuratedSet.getStatus()).isEqualTo(ChoiceSetStatus.DISABLED);
        assertThat(aiSet.getStatus()).isEqualTo(ChoiceSetStatus.OK);
        assertThat(saved.getSource()).isEqualTo(ChoiceSetSource.ADMIN_CURATED);
        assertThat(saved.getStatus()).isEqualTo(ChoiceSetStatus.OK);
        assertThat(saved.getIsReusable()).isTrue();
    }

    @Test
    void replace_savesItemsWithRationaleAsExplanationAndSortOrder() {
        curatedChoiceSetWriter.replaceCuratedSet(questionUuid, fourChoices());

        ArgumentCaptor<QuestionChoiceSetItem> itemCaptor = ArgumentCaptor.forClass(QuestionChoiceSetItem.class);
        verify(choiceSetItemRepository, times(4)).save(itemCaptor.capture());
        List<QuestionChoiceSetItem> items = itemCaptor.getAllValues();
        assertThat(items).extracting(QuestionChoiceSetItem::getChoiceSetUuid).containsOnly(newSetUuid);
        assertThat(items).extracting(QuestionChoiceSetItem::getSortOrder).containsExactly(1, 2, 3, 4);
        assertThat(items).extracting(QuestionChoiceSetItem::getKind)
                .containsExactly(ChoiceKind.TEXT, ChoiceKind.TEXT, ChoiceKind.TEXT, ChoiceKind.SQL);
        assertThat(items).extracting(QuestionChoiceSetItem::getExplanation)
                .containsExactly("D>B>A 전개 후 B 제외", "WHERE 가 전개 후 적용됨을 놓침", "시작 행만 셈", "전체 행 수");
        assertThat(items).extracting(QuestionChoiceSetItem::getIsCorrect).containsExactly(true, false, false, false);
    }
}
