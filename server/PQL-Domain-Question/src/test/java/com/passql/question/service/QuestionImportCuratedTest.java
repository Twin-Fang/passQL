package com.passql.question.service;

import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.dto.CuratedChoiceDto;
import com.passql.question.dto.ImportRequest;
import com.passql.question.dto.ImportResult;
import com.passql.question.dto.QuestionExportDto;
import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationEventPublisher;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 가져오기 등록 단계 (#511): 전체 등록(ALL)에서도 고정 보기 규칙 위반 항목은 저장하지 않음
 */
class QuestionImportCuratedTest {

    private final QuestionRepository questionRepository = mock(QuestionRepository.class);
    private final TopicRepository topicRepository = mock(TopicRepository.class);
    private final QuestionGenerateService questionGenerateService = mock(QuestionGenerateService.class);
    private final CuratedChoiceSetWriter curatedChoiceSetWriter = mock(CuratedChoiceSetWriter.class);
    private QuestionImportExportService importExportService;

    @BeforeEach
    void setUp() {
        importExportService = new QuestionImportExportService(questionRepository, topicRepository,
                questionGenerateService, mock(QuestionService.class), mock(ApplicationEventPublisher.class),
                mock(QuestionImportItemValidator.class), new OracleSqlCompatibilityConverter(), curatedChoiceSetWriter);
        Topic topic = mock(Topic.class);
        when(topic.getTopicUuid()).thenReturn(UUID.randomUUID());
        when(topicRepository.findByCode("sql_join")).thenReturn(Optional.of(topic));
        when(questionGenerateService.createQuestionOnly(any(), any(), anyInt(), any(), any(), any(), any(), any(), any(), any(), any()))
                .thenReturn(Question.builder().questionUuid(UUID.randomUUID()).build());
    }

    private QuestionExportDto item(String policy, List<CuratedChoiceDto> choices) {
        return new QuestionExportDto(null, "sql_join", 3, "CONCEPT_ONLY", policy, "지문", null,
                null, null, null, null, choices);
    }

    private static CuratedChoiceDto choice(String key, boolean isCorrect) {
        return new CuratedChoiceDto(key, "TEXT", "보기 " + key, isCorrect, "근거 " + key);
    }

    @Test
    void importAll_skipsCuratedItemWithTwoCorrectChoices() {
        List<CuratedChoiceDto> twoCorrect = List.of(choice("A", true), choice("B", true), choice("C", false), choice("D", false));

        ImportResult result = importExportService.importBatch(new ImportRequest(List.of(item("CURATED_ONLY", twoCorrect)), "ALL", null));

        assertThat(result.created()).isZero();
        assertThat(result.skipped()).isEqualTo(1);
        verify(curatedChoiceSetWriter, never()).replaceCuratedSet(any(), any());
    }

    @Test
    void importAll_savesValidCuratedItem() {
        List<CuratedChoiceDto> valid = List.of(choice("A", true), choice("B", false), choice("C", false), choice("D", false));

        ImportResult result = importExportService.importBatch(new ImportRequest(List.of(item("CURATED_ONLY", valid)), "ALL", null));

        assertThat(result.created()).isEqualTo(1);
        verify(curatedChoiceSetWriter).replaceCuratedSet(any(), any());
    }

    @Test
    void importAll_oldFormatWithoutChoices_unchanged() {
        ImportResult result = importExportService.importBatch(new ImportRequest(List.of(item("AI_ONLY", null)), "ALL", null));

        assertThat(result.created()).isEqualTo(1);
        verify(curatedChoiceSetWriter, never()).replaceCuratedSet(any(), any());
    }
}
