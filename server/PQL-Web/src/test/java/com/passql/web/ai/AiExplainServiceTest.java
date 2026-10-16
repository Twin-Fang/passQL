package com.passql.web.ai;

import com.passql.ai.client.GeminiClient;
import com.passql.ai.dto.AiResult;
import com.passql.ai.entity.AiErrorExplanation;
import com.passql.ai.repository.AiErrorExplanationRepository;
import com.passql.application.service.AiExplainService;
import com.passql.application.service.AiExplanationGenerator;
import com.passql.application.service.ChoiceExplanationService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.entity.Submission;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * AI 해설: 항상 "일시적으로 사용 불가"로 나가던 문제(#354) 회귀 + 해설 영구 저장·재사용·미리 생성(#496)
 */
class AiExplainServiceTest {

    private static final int ACTIVE_PROMPT_VERSION = 2;

    private final GeminiClient gemini = mock(GeminiClient.class);
    private final PromptService prompts = mock(PromptService.class);
    private final QuestionRepository questions = mock(QuestionRepository.class);
    private final QuestionChoiceSetRepository choiceSets = mock(QuestionChoiceSetRepository.class);
    private final QuestionChoiceSetItemRepository items = mock(QuestionChoiceSetItemRepository.class);
    private final SubmissionRepository submissions = mock(SubmissionRepository.class);
    private final AiErrorExplanationRepository errorExplanations = mock(AiErrorExplanationRepository.class);

    private final AiExplanationGenerator generator = new AiExplanationGenerator(gemini, prompts);
    private final ChoiceExplanationService choiceExplanationService =
            new ChoiceExplanationService(questions, choiceSets, items, generator);
    private final AiExplainService service =
            new AiExplainService(questions, submissions, errorExplanations, choiceExplanationService, generator);

    private final UUID member = UUID.randomUUID();
    private final UUID qid = UUID.randomUUID();
    private final UUID setId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        PromptTemplate p = PromptTemplate.builder().keyName("diff_explain").version(ACTIVE_PROMPT_VERSION).model("m")
                .systemPrompt("튜터\\n입니다").userTemplate("").temperature(0.5f).maxTokens(512).build();
        when(prompts.getActivePrompt(anyString())).thenReturn(p);
        when(questions.findById(qid)).thenReturn(Optional.of(Question.builder()
                .questionUuid(qid).stem("RANK 결과는?").schemaDdl("CREATE TABLE EMP(...)").build()));
        when(submissions.findFirstByMemberUuidAndQuestionUuidOrderBySubmittedAtDesc(member, qid))
                .thenReturn(Optional.of(Submission.builder().choiceSetUuid(setId).selectedChoiceKey("C").build()));
    }

    private QuestionChoiceSetItem item(String key, String body, boolean correct) {
        return QuestionChoiceSetItem.builder().choiceSetUuid(setId).choiceKey(key).body(body).isCorrect(correct).build();
    }

    @Test
    void 마지막_제출의_선택지_세트로_고른_답과_정답을_비교해_해설하고_저장한다() {
        QuestionChoiceSetItem wrongItem = item("C", "오답 결과표", false);
        when(items.findByChoiceSetUuidOrderBySortOrderAsc(setId)).thenReturn(List.of(
                item("A", "정답 결과표", true), wrongItem));
        when(gemini.chat(anyString(), anyString(), anyString(), anyFloat(), anyInt())).thenReturn("  C는 동점 처리가 다릅니다.  ");

        AiResult r = service.diffExplain(member, qid, "C");

        assertEquals("C는 동점 처리가 다릅니다.", r.text());
        ArgumentCaptor<String> sys = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<String> user = ArgumentCaptor.forClass(String.class);
        verify(gemini).chat(anyString(), sys.capture(), user.capture(), anyFloat(), anyInt());
        assertEquals("튜터\n입니다", sys.getValue(), "DB 프롬프트의 '\\n' 글자를 줄바꿈으로 바꾼다");
        assertTrue(user.getValue().contains("오답 결과표"));
        assertTrue(user.getValue().contains("정답 결과표"));
        assertTrue(user.getValue().contains("왜 답이 아닌지"));
        assertTrue(user.getValue().contains("선택지 전체"), "전체 선택지를 넘겨 결과를 비교하게 한다");
        assertTrue(user.getValue().contains("옳지 않은 것"), "문제 방향 규칙을 붙인다");
        // 선택지에 영구 저장 (#496)
        verify(items).save(wrongItem);
        assertEquals("C는 동점 처리가 다릅니다.", wrongItem.getExplanation());
        assertEquals(ACTIVE_PROMPT_VERSION, wrongItem.getExplanationPromptVersion());
    }

    @Test
    void 저장된_해설이_활성_프롬프트_버전이면_AI를_다시_부르지_않는다() {
        QuestionChoiceSetItem wrongItem = item("C", "오답", false);
        wrongItem.setExplanation("미리 만든 해설");
        wrongItem.setExplanationPromptVersion(ACTIVE_PROMPT_VERSION);
        when(items.findByChoiceSetUuidOrderBySortOrderAsc(setId)).thenReturn(List.of(item("A", "정답", true), wrongItem));

        assertEquals("미리 만든 해설", service.diffExplain(member, qid, "C").text());
        verify(gemini, never()).chat(anyString(), anyString(), anyString(), anyFloat(), anyInt());
    }

    @Test
    void 저장된_해설이_예전_프롬프트_버전이면_다시_만든다() {
        QuestionChoiceSetItem wrongItem = item("C", "오답", false);
        wrongItem.setExplanation("예전 해설");
        wrongItem.setExplanationPromptVersion(ACTIVE_PROMPT_VERSION - 1);
        when(items.findByChoiceSetUuidOrderBySortOrderAsc(setId)).thenReturn(List.of(item("A", "정답", true), wrongItem));
        when(gemini.chat(anyString(), anyString(), anyString(), anyFloat(), anyInt())).thenReturn("새 해설");

        assertEquals("새 해설", service.diffExplain(member, qid, "C").text());
        assertEquals("새 해설", wrongItem.getExplanation());
    }

    @Test
    void 세트에_없는_선택지_키는_잘못된_입력이다() {
        when(items.findByChoiceSetUuidOrderBySortOrderAsc(setId)).thenReturn(List.of(item("A", "정답", true)));

        CustomException e = assertThrows(CustomException.class, () -> service.diffExplain(member, qid, "Z"));
        assertEquals(ErrorCode.INVALID_INPUT_VALUE, e.getErrorCode());
    }

    @Test
    void 세트_미리_생성은_해설_없는_선택지만_만든다() {
        QuestionChoiceSetItem correctItem = item("A", "정답", true);
        QuestionChoiceSetItem readyItem = item("B", "오답1", false);
        readyItem.setExplanation("이미 있음");
        readyItem.setExplanationPromptVersion(ACTIVE_PROMPT_VERSION);
        QuestionChoiceSetItem missingItem = item("C", "오답2", false);
        when(choiceSets.findById(setId)).thenReturn(Optional.of(QuestionChoiceSet.builder()
                .choiceSetUuid(setId).questionUuid(qid).build()));
        when(items.findByChoiceSetUuidOrderBySortOrderAsc(setId)).thenReturn(List.of(correctItem, readyItem, missingItem));
        when(gemini.chat(anyString(), anyString(), anyString(), anyFloat(), anyInt())).thenReturn("해설");

        assertEquals(2, choiceExplanationService.pregenerateExplanations(setId));
        verify(gemini, times(2)).chat(anyString(), anyString(), anyString(), anyFloat(), anyInt());
        assertEquals("이미 있음", readyItem.getExplanation());
        assertEquals("해설", missingItem.getExplanation());
    }

    @Test
    void 실행_오류_해설은_SQL과_오류_메시지를_넘기고_저장한다() {
        when(gemini.chat(anyString(), anyString(), anyString(), anyFloat(), anyInt())).thenReturn("컬럼명이 틀렸습니다.");

        AiResult r = service.explainError(member, qid, "SELECT ENAM FROM EMP", "column \"enam\" does not exist");

        assertEquals("컬럼명이 틀렸습니다.", r.text());
        ArgumentCaptor<String> user = ArgumentCaptor.forClass(String.class);
        verify(gemini).chat(anyString(), anyString(), user.capture(), anyFloat(), anyInt());
        assertTrue(user.getValue().contains("SELECT ENAM FROM EMP"));
        assertTrue(user.getValue().contains("does not exist"));
        verify(errorExplanations).save(any(AiErrorExplanation.class));
    }

    @Test
    void 공백과_끝_세미콜론만_다른_SQL_오류는_저장된_해설을_재사용한다() {
        ArgumentCaptor<String> sqlHash = ArgumentCaptor.forClass(String.class);
        when(errorExplanations.findByQuestionUuidAndSqlHashAndErrorHash(eq(qid), sqlHash.capture(), anyString()))
                .thenReturn(Optional.empty())
                .thenReturn(Optional.of(AiErrorExplanation.builder().questionUuid(qid).sqlHash("h").errorHash("e")
                        .explanation("저장된 해설").promptVersion(1).createdAt(LocalDateTime.now()).build()));
        when(gemini.chat(anyString(), anyString(), anyString(), anyFloat(), anyInt())).thenReturn("처음 해설");

        service.explainError(member, qid, "SELECT  ENAM\nFROM EMP;", "oops");
        AiResult second = service.explainError(member, qid, "  SELECT ENAM FROM EMP  ", " oops ");

        assertEquals("저장된 해설", second.text());
        assertEquals(sqlHash.getAllValues().get(0), sqlHash.getAllValues().get(1), "정규화 후 같은 해시");
        verify(gemini, times(1)).chat(anyString(), anyString(), anyString(), anyFloat(), anyInt());
    }

    @Test
    void 너무_긴_SQL은_AI를_부르지_않고_거절한다() {
        CustomException e = assertThrows(CustomException.class,
                () -> service.explainError(member, qid, "S".repeat(4001), "error"));
        assertEquals(ErrorCode.INVALID_INPUT_VALUE, e.getErrorCode());
        verify(gemini, never()).chat(anyString(), anyString(), anyString(), anyFloat(), anyInt());
    }

    @Test
    void AI_호출이_실패하면_AI_UNAVAILABLE_로_알린다() {
        when(gemini.chat(anyString(), anyString(), anyString(), anyFloat(), anyInt())).thenThrow(new RuntimeException("quota"));

        CustomException e = assertThrows(CustomException.class, () -> service.explainError(member, qid, "x", "y"));
        assertEquals(ErrorCode.AI_UNAVAILABLE, e.getErrorCode());
    }
}
