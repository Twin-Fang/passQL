package com.passql.web.ai;

import com.google.genai.types.Schema;
import com.passql.ai.client.GeminiClient;
import com.passql.ai.dto.AiResult;
import com.passql.ai.entity.AiErrorExplanation;
import com.passql.ai.repository.AiErrorExplanationRepository;
import com.passql.application.service.AiExplainService;
import com.passql.application.service.AiExplanationGenerator;
import com.passql.application.service.ChoiceExplanationService;
import com.passql.application.service.explanation.ChoiceSetExplanationGenerator;
import com.passql.application.service.explanation.ChoiceSetExplanationPrompt;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.question.constant.ChoiceExplanationStatus;
import com.passql.question.dto.explanation.ChoiceAnalysis;
import com.passql.question.dto.explanation.ChoiceExplanationResponse;
import com.passql.question.dto.explanation.ChoiceSetExplanation;
import com.passql.question.dto.explanation.KeyConcept;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.question.service.ChoiceExplanationComposer;
import com.passql.submission.entity.Submission;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * AI 해설: 항상 "일시적으로 사용 불가"로 나가던 문제(#354) 회귀 + 해설 영구 저장(#496)
 * + 세트 구조화 해설 즉시 응답·백그라운드 생성·사실 검증 재시도·출시 앱 호환(#521)
 */
class AiExplainServiceTest {

    private static final int CURRENT_PROMPT_VERSION = ChoiceSetExplanationPrompt.PROMPT_VERSION;

    private final GeminiClient gemini = mock(GeminiClient.class);
    private final PromptService prompts = mock(PromptService.class);
    private final QuestionRepository questions = mock(QuestionRepository.class);
    private final QuestionChoiceSetRepository choiceSets = mock(QuestionChoiceSetRepository.class);
    private final QuestionChoiceSetItemRepository items = mock(QuestionChoiceSetItemRepository.class);
    private final SubmissionRepository submissions = mock(SubmissionRepository.class);
    private final AiErrorExplanationRepository errorExplanations = mock(AiErrorExplanationRepository.class);
    // 백그라운드 작업을 바로 돌리지 않고 모아 두는 실행기 (GENERATING 즉시 응답 확인용)
    private final List<Runnable> queuedBackgroundTasks = new ArrayList<>();

    private final AiExplanationGenerator errorGenerator = new AiExplanationGenerator(gemini, prompts);
    private final ChoiceSetExplanationGenerator choiceSetGenerator = new ChoiceSetExplanationGenerator(gemini, prompts);
    private final ChoiceExplanationService choiceExplanationService =
            new ChoiceExplanationService(questions, choiceSets, items, choiceSetGenerator, queuedBackgroundTasks::add);
    private final AiExplainService service =
            new AiExplainService(questions, submissions, errorExplanations, choiceExplanationService, errorGenerator);

    private final UUID member = UUID.randomUUID();
    private final UUID qid = UUID.randomUUID();
    private final UUID setId = UUID.randomUUID();
    private QuestionChoiceSet choiceSet;
    private QuestionChoiceSetItem wrongItem;

    @BeforeEach
    void setUp() {
        PromptTemplate p = PromptTemplate.builder().keyName("diff_explain").version(2).model("m")
                .systemPrompt("튜터\\n입니다").userTemplate("").temperature(0.5f).maxTokens(512).build();
        when(prompts.getActivePrompt(anyString())).thenReturn(p);
        when(questions.findById(qid)).thenReturn(Optional.of(Question.builder()
                .questionUuid(qid).stem("RANK 결과는?").schemaDdl("CREATE TABLE EMP(...)").build()));
        when(submissions.findFirstByMemberUuidAndQuestionUuidOrderBySubmittedAtDesc(member, qid))
                .thenReturn(Optional.of(Submission.builder().choiceSetUuid(setId).selectedChoiceKey("C").build()));
        choiceSet = QuestionChoiceSet.builder().choiceSetUuid(setId).questionUuid(qid).build();
        when(choiceSets.findById(setId)).thenAnswer(invocation -> Optional.of(choiceSet));
        wrongItem = item("C", "오답 결과표", false);
        when(items.findByChoiceSetUuidOrderBySortOrderAsc(setId)).thenReturn(List.of(item("A", "정답 결과표", true), wrongItem));
        // 저장 쿼리 > 메모리 세트에 반영 (다음 조회가 저장본을 읽게)
        when(choiceSets.saveReadyExplanation(eq(setId), anyString(), anyInt(), any())).thenAnswer(invocation -> {
            choiceSet.setExplanationJson(invocation.getArgument(1));
            choiceSet.setExplanationPromptVersion(invocation.getArgument(2));
            choiceSet.setExplanationStatus(ChoiceExplanationStatus.READY);
            return 1;
        });
        when(choiceSets.markExplanationFailed(eq(setId), any())).thenAnswer(invocation -> {
            choiceSet.setExplanationStatus(ChoiceExplanationStatus.FAILED);
            return 1;
        });
    }

    private QuestionChoiceSetItem item(String key, String body, boolean correct) {
        return QuestionChoiceSetItem.builder().choiceSetUuid(setId).choiceKey(key).body(body).isCorrect(correct).build();
    }

    private static ChoiceSetExplanation explanation(String correctChoiceKey) {
        return new ChoiceSetExplanation(correctChoiceKey,
                "`RANK` 는 동점에 같은 순위 부여 후 다음 순위 건너뜀. 샘플 데이터에서 A 결과표와 일치.",
                List.of(new KeyConcept("RANK", "동점 같은 순위, 다음 순위 건너뜀")),
                List.of("`DENSE_RANK` 는 건너뛰지 않음"),
                List.of(new ChoiceAnalysis("A", "A".equals(correctChoiceKey), "동점 뒤 순위 건너뜀 반영"),
                        new ChoiceAnalysis("C", "C".equals(correctChoiceKey), "동점 뒤 순위를 이어 붙인 결과")),
                "동점 뒤 순위 번호부터 확인");
    }

    private void givenStoredExplanation(int promptVersion) {
        choiceSet.setExplanationJson(ChoiceExplanationComposer.toJson(explanation("A")));
        choiceSet.setExplanationPromptVersion(promptVersion);
        choiceSet.setExplanationStatus(ChoiceExplanationStatus.READY);
    }

    private void givenAiResponses(String... responses) {
        var stubbing = when(gemini.chatStructured(anyString(), anyString(), anyString(), anyFloat(), anyInt(), any(Schema.class)));
        for (String response : responses) stubbing = stubbing.thenReturn(response);
    }

    @Test
    void 저장된_구조화_해설은_AI_호출_없이_READY_로_즉시_돌려준다() {
        givenStoredExplanation(CURRENT_PROMPT_VERSION);

        ChoiceExplanationResponse response = service.getChoiceExplanation(member, qid, null, "C");

        assertEquals(ChoiceExplanationStatus.READY, response.status());
        assertEquals("오답 · C 선택, 정답은 A · 동점 뒤 순위를 이어 붙인 결과", response.explanation().verdict(),
                "판정은 DB 정답 키로 서버가 조립");
        assertFalse(response.explanation().isSelectedCorrect());
        assertTrue(response.text().contains("**핵심 개념**"));
        assertNull(response.retryAfterMilliseconds());
        verifyNoInteractions(gemini);
        verify(choiceSets, never()).claimExplanationGeneration(any(), anyInt(), anyInt(), any(), any());
    }

    @Test
    void 해설이_없으면_생성을_맡아_GENERATING_으로_즉시_응답하고_백그라운드에서_저장한다() {
        when(choiceSets.claimExplanationGeneration(eq(setId), eq(CURRENT_PROMPT_VERSION), anyInt(), any(), any())).thenReturn(1);
        givenAiResponses(ChoiceExplanationComposer.toJson(explanation("A")));

        ChoiceExplanationResponse response = service.getChoiceExplanation(member, qid, null, "C");

        assertEquals(ChoiceExplanationStatus.GENERATING, response.status());
        assertEquals(1500, response.retryAfterMilliseconds());
        assertEquals(1, queuedBackgroundTasks.size(), "AI 호출은 요청 스레드가 아니라 백그라운드");
        verifyNoInteractions(gemini);

        queuedBackgroundTasks.get(0).run();
        ArgumentCaptor<String> userPrompt = ArgumentCaptor.forClass(String.class);
        verify(gemini).chatStructured(anyString(), anyString(), userPrompt.capture(), anyFloat(), anyInt(), any(Schema.class));
        assertTrue(userPrompt.getValue().contains("A. [정답] 정답 결과표"), "보기 전체를 정답 표시와 함께 넘긴다");
        assertTrue(userPrompt.getValue().contains("C. [오답] 오답 결과표"));
        assertEquals(ChoiceExplanationStatus.READY, service.getChoiceExplanation(member, qid, null, "C").status());
    }

    @Test
    void 다른_요청이_생성_중이면_다시_맡지_않고_GENERATING_을_준다() {
        choiceSet.setExplanationStatus(ChoiceExplanationStatus.GENERATING);
        when(choiceSets.claimExplanationGeneration(any(), anyInt(), anyInt(), any(), any())).thenReturn(0);

        ChoiceExplanationResponse response = service.getChoiceExplanation(member, qid, null, "C");

        assertEquals(ChoiceExplanationStatus.GENERATING, response.status());
        assertTrue(queuedBackgroundTasks.isEmpty());
    }

    @Test
    void 재시도_상한까지_실패한_세트는_FAILED_와_옛_해설_글을_준다() {
        choiceSet.setExplanationStatus(ChoiceExplanationStatus.FAILED);
        wrongItem.setExplanation("옛 보기별 해설");
        when(choiceSets.claimExplanationGeneration(any(), anyInt(), anyInt(), any(), any())).thenReturn(0);

        ChoiceExplanationResponse response = service.getChoiceExplanation(member, qid, null, "C");

        assertEquals(ChoiceExplanationStatus.FAILED, response.status());
        assertEquals("옛 보기별 해설", response.text());
        assertNull(response.explanation());
    }

    @Test
    void 낡은_프롬프트_버전_저장본은_즉시_주고_백그라운드_재생성을_요청한다() {
        givenStoredExplanation(CURRENT_PROMPT_VERSION - 1);
        when(choiceSets.claimExplanationGeneration(eq(setId), eq(CURRENT_PROMPT_VERSION), anyInt(), any(), any())).thenReturn(1);

        ChoiceExplanationResponse response = service.getChoiceExplanation(member, qid, null, "C");

        assertEquals(ChoiceExplanationStatus.READY, response.status());
        assertEquals(CURRENT_PROMPT_VERSION - 1, response.promptVersion());
        assertEquals(1, queuedBackgroundTasks.size(), "재생성은 백그라운드");
    }

    @Test
    void 정답과_모순된_AI_응답은_위반_목록을_붙여_재시도하고_그래도_틀리면_저장하지_않는다() {
        when(choiceSets.claimExplanationGeneration(any(), anyInt(), anyInt(), any(), any())).thenReturn(1);
        givenAiResponses(ChoiceExplanationComposer.toJson(explanation("C")), ChoiceExplanationComposer.toJson(explanation("C")));

        assertEquals(0, choiceExplanationService.pregenerateExplanation(setId));

        ArgumentCaptor<String> userPrompt = ArgumentCaptor.forClass(String.class);
        verify(gemini, times(2)).chatStructured(anyString(), anyString(), userPrompt.capture(), anyFloat(), anyInt(), any(Schema.class));
        assertTrue(userPrompt.getAllValues().get(1).contains("직전 응답의 문제"));
        assertTrue(userPrompt.getAllValues().get(1).contains("correctChoiceKey 불일치"));
        verify(choiceSets, never()).saveReadyExplanation(any(), anyString(), anyInt(), any());
        verify(choiceSets).markExplanationFailed(eq(setId), any());
    }

    @Test
    void 첫_응답이_모순이어도_재시도가_통과하면_저장한다() {
        when(choiceSets.claimExplanationGeneration(any(), anyInt(), anyInt(), any(), any())).thenReturn(1);
        givenAiResponses("{깨진 JSON", ChoiceExplanationComposer.toJson(explanation("A")));

        assertEquals(1, choiceExplanationService.pregenerateExplanation(setId));
        verify(choiceSets).saveReadyExplanation(eq(setId), contains("\"correctChoiceKey\":\"A\""), eq(CURRENT_PROMPT_VERSION), any());
    }

    @Test
    void 이미_다른_요청이_맡은_세트는_미리_생성하지_않는다() {
        when(choiceSets.claimExplanationGeneration(any(), anyInt(), anyInt(), any(), any())).thenReturn(0);

        assertEquals(0, choiceExplanationService.pregenerateExplanation(setId));
        verifyNoInteractions(gemini);
    }

    @Test
    void 출시_앱_diffExplain_은_구조화_해설_마크다운을_돌려준다() {
        givenStoredExplanation(CURRENT_PROMPT_VERSION);

        AiResult result = service.diffExplain(member, qid, "C");

        assertTrue(result.text().startsWith("**오답 · C 선택, 정답은 A"));
        assertFalse(result.text().contains("#"), "출시 앱 MarkdownLiteText 가 못 그리는 제목 기호 없음");
        assertEquals(CURRENT_PROMPT_VERSION, result.promptVersion());
    }

    @Test
    void 출시_앱_diffExplain_은_옛_해설_글이_있으면_기다리지_않고_주고_백그라운드_생성을_요청한다() {
        wrongItem.setExplanation("옛 보기별 해설");
        when(choiceSets.claimExplanationGeneration(any(), anyInt(), anyInt(), any(), any())).thenReturn(1);

        AiResult result = service.diffExplain(member, qid, "C");

        assertEquals("옛 보기별 해설", result.text());
        assertEquals(1, queuedBackgroundTasks.size());
    }

    @Test
    void 출시_앱_diffExplain_은_생성_실패가_확정되면_AI_UNAVAILABLE() {
        when(choiceSets.claimExplanationGeneration(any(), anyInt(), anyInt(), any(), any())).thenReturn(1);
        givenAiResponses(ChoiceExplanationComposer.toJson(explanation("C")), ChoiceExplanationComposer.toJson(explanation("C")));
        // 백그라운드 작업을 바로 실행하는 서비스로 (생성 실패 > FAILED 확정 > 대기 종료)
        ChoiceExplanationService immediateService =
                new ChoiceExplanationService(questions, choiceSets, items, choiceSetGenerator, Runnable::run);
        AiExplainService immediateExplainService =
                new AiExplainService(questions, submissions, errorExplanations, immediateService, errorGenerator);

        CustomException e = assertThrows(CustomException.class, () -> immediateExplainService.diffExplain(member, qid, "C"));
        assertEquals(ErrorCode.AI_UNAVAILABLE, e.getErrorCode());
    }

    @Test
    void 세트를_지정한_조회는_그_세트로_제출한_기록이_없으면_거절한다() {
        UUID otherSetId = UUID.randomUUID();
        when(submissions.findFirstByMemberUuidAndQuestionUuidAndChoiceSetUuidOrderBySubmittedAtDesc(member, qid, otherSetId))
                .thenReturn(Optional.empty());

        CustomException e = assertThrows(CustomException.class,
                () -> service.getChoiceExplanation(member, qid, otherSetId, "C"));
        assertEquals(ErrorCode.INVALID_INPUT_VALUE, e.getErrorCode());
    }

    @Test
    void 세트를_지정하면_고른_키를_안_보내도_그_제출의_키로_해설한다() {
        givenStoredExplanation(CURRENT_PROMPT_VERSION);
        when(submissions.findFirstByMemberUuidAndQuestionUuidAndChoiceSetUuidOrderBySubmittedAtDesc(member, qid, setId))
                .thenReturn(Optional.of(Submission.builder().choiceSetUuid(setId).selectedChoiceKey("A").build()));

        ChoiceExplanationResponse response = service.getChoiceExplanation(member, qid, setId, null);

        assertEquals("A", response.selectedChoiceKey());
        assertTrue(response.explanation().isSelectedCorrect());
        assertTrue(response.explanation().verdict().startsWith("정답 · "));
    }

    @Test
    void 세트에_없는_선택지_키는_잘못된_입력이다() {
        CustomException e = assertThrows(CustomException.class, () -> service.diffExplain(member, qid, "Z"));
        assertEquals(ErrorCode.INVALID_INPUT_VALUE, e.getErrorCode());
    }

    @Test
    void 실행_오류_해설은_SQL과_오류_메시지를_넘기고_저장한다() {
        when(gemini.chat(anyString(), anyString(), anyString(), anyFloat(), anyInt())).thenReturn("컬럼명이 틀렸습니다.");

        AiResult r = service.explainError(member, qid, "SELECT ENAM FROM EMP", "column \"enam\" does not exist");

        assertEquals("컬럼명이 틀렸습니다.", r.text());
        ArgumentCaptor<String> sys = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<String> user = ArgumentCaptor.forClass(String.class);
        verify(gemini).chat(anyString(), sys.capture(), user.capture(), anyFloat(), anyInt());
        assertEquals("튜터\n입니다", sys.getValue(), "DB 프롬프트의 '\\n' 글자를 줄바꿈으로 바꾼다");
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
