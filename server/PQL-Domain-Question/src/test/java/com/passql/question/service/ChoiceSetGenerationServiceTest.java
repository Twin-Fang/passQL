package com.passql.question.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.client.AiGatewayClient;
import com.passql.ai.dto.GenerateChoiceSetRequest;
import com.passql.ai.dto.GenerateChoiceSetResult;
import com.passql.ai.dto.GeneratedChoiceDto;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.dto.ValidationReport;
import com.passql.question.dto.ValidationReport.ChoiceValidation;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 선택지 생성 흐름 고정: AI 요청 조립(피드백·힌트·실행 결과 치환) > 검증 > 저장 위임
 */
class ChoiceSetGenerationServiceTest {

    // 선택지 4개 응답 스키마 (AI 서버 계약)
    private static final Map<String, Object> EXPECTED_CHOICE_SET_RESPONSE_SCHEMA = Map.of(
            "type", "object",
            "properties", Map.of(
                    "choices", Map.of(
                            "type", "array",
                            "minItems", 4, "maxItems", 4,
                            "items", Map.of(
                                    "type", "object",
                                    "properties", Map.of(
                                            "key", Map.of("type", "string"),
                                            "body", Map.of("type", "string"),
                                            "is_correct", Map.of("type", "boolean"),
                                            "rationale", Map.of("type", "string")
                                    ),
                                    "required", List.of("key", "body", "is_correct", "rationale")
                            )
                    )
            ),
            "required", List.of("choices")
    );

    private final UUID questionUuid = UUID.randomUUID();
    private final UUID memberUuid = UUID.randomUUID();

    private QuestionService questionService;
    private PromptService promptService;
    private AiGatewayClient aiGatewayClient;
    private SandboxValidator sandboxValidator;
    private ChoiceSetSaveService choiceSetSaveService;
    private SandboxPool sandboxPool;
    private SandboxExecutor sandboxExecutor;
    private ChoiceSetGenerationService choiceSetGenerationService;

    @BeforeEach
    void setUp() {
        questionService = mock(QuestionService.class);
        promptService = mock(PromptService.class);
        aiGatewayClient = mock(AiGatewayClient.class);
        sandboxValidator = mock(SandboxValidator.class);
        choiceSetSaveService = mock(ChoiceSetSaveService.class);
        sandboxPool = mock(SandboxPool.class);
        sandboxExecutor = mock(SandboxExecutor.class);
        choiceSetGenerationService = new ChoiceSetGenerationService(
                questionService, promptService, aiGatewayClient, sandboxValidator,
                new ResultMatchChoiceValidator(new ObjectMapper()),
                choiceSetSaveService, sandboxPool, sandboxExecutor);
    }

    @Test
    void 정답이_여러개면_동치_SQL을_다음_요청_피드백에_붙인다() {
        Question question = executableQuestion();
        PromptTemplate prompt = prompt("USER");
        when(questionService.getQuestionEntity(questionUuid)).thenReturn(question);
        when(promptService.getActivePrompt("generate_choice_set")).thenReturn(prompt);
        GenerateChoiceSetResult aiResult = new GenerateChoiceSetResult(List.of(
                new GeneratedChoiceDto("A", "SELECT a", true, "r"),
                new GeneratedChoiceDto("B", "SELECT b", false, "r"),
                new GeneratedChoiceDto("C", "SELECT c", false, "r"),
                new GeneratedChoiceDto("D", "SELECT d", false, "r")), null);
        when(aiGatewayClient.generateChoiceSet(any())).thenReturn(aiResult);
        ValidationReport multipleCorrectReport = new ValidationReport(2, List.of(
                matched("A", true), matched("B", true), matched("C", false), matched("D", false)));
        ValidationReport singleCorrectReport = new ValidationReport(1, List.of(
                matched("A", true), matched("B", false), matched("C", false), matched("D", false)));
        when(sandboxValidator.validate(any(), any(), any(), any(), any()))
                .thenReturn(multipleCorrectReport, singleCorrectReport);
        QuestionChoiceSet savedChoiceSet = mock(QuestionChoiceSet.class);
        when(choiceSetSaveService.saveSuccess(eq(question), eq(ChoiceSetSource.AI_PREFETCH), eq(memberUuid),
                eq(prompt), eq(aiResult), eq(singleCorrectReport), eq(2))).thenReturn(savedChoiceSet);

        QuestionChoiceSet result = choiceSetGenerationService.generate(questionUuid, memberUuid, ChoiceSetSource.AI_PREFETCH);

        assertThat(result).isSameAs(savedChoiceSet);
        ArgumentCaptor<GenerateChoiceSetRequest> requestCaptor = ArgumentCaptor.forClass(GenerateChoiceSetRequest.class);
        verify(aiGatewayClient, times(2)).generateChoiceSet(requestCaptor.capture());
        GenerateChoiceSetRequest firstRequest = requestCaptor.getAllValues().get(0);
        GenerateChoiceSetRequest secondRequest = requestCaptor.getAllValues().get(1);
        assertThat(firstRequest.llmConfig().userTemplate()).isEqualTo("USER");
        assertThat(firstRequest.llmConfig().responseSchema()).isEqualTo(EXPECTED_CHOICE_SET_RESPONSE_SCHEMA);
        assertThat(firstRequest.context().answerSql()).isEqualTo("SELECT answer");
        assertThat(secondRequest.llmConfig().userTemplate()).isEqualTo("USER"
                + "\n\n[재시도 피드백]\n"
                + "아래 SQL들은 기준 SQL과 동일한 실행 결과를 내는 것으로 확인되었다.\n"
                + "오답 선택지로 절대 사용하지 말 것:\n"
                + "1. SELECT a\n"
                + "2. SELECT b\n"
                + "위 SQL과 다른 표현/문법으로 명확히 다른 결과를 내는 오답 SQL을 생성해야 한다.");
    }

    @Test
    void 개념_문제는_힌트를_지문에_붙이고_SQL_항목을_비운다() {
        Question question = executableQuestion();
        question.setHint("힌트 내용");
        PromptTemplate prompt = prompt("CONCEPT USER");
        when(questionService.getQuestionEntity(questionUuid)).thenReturn(question);
        when(promptService.getActivePrompt("generate_choice_set_concept")).thenReturn(prompt);
        GenerateChoiceSetResult aiResult = new GenerateChoiceSetResult(List.of(
                new GeneratedChoiceDto("A", "a", true, "r"),
                new GeneratedChoiceDto("B", "b", false, "r")), null);
        when(aiGatewayClient.generateChoiceSet(any())).thenReturn(aiResult);
        QuestionChoiceSet savedChoiceSet = mock(QuestionChoiceSet.class);
        when(choiceSetSaveService.saveConceptSuccess(question, ChoiceSetSource.AI_PREFETCH, memberUuid, prompt, aiResult, 1))
                .thenReturn(savedChoiceSet);

        QuestionChoiceSet result = choiceSetGenerationService.generateConcept(questionUuid, memberUuid, ChoiceSetSource.AI_PREFETCH);

        assertThat(result).isSameAs(savedChoiceSet);
        ArgumentCaptor<GenerateChoiceSetRequest> requestCaptor = ArgumentCaptor.forClass(GenerateChoiceSetRequest.class);
        verify(aiGatewayClient).generateChoiceSet(requestCaptor.capture());
        GenerateChoiceSetRequest request = requestCaptor.getValue();
        assertThat(request.context().stem()).isEqualTo("지문\n\n[힌트] 힌트 내용");
        assertThat(request.context().answerSql()).isNull();
        assertThat(request.context().schemaDdl()).isNull();
        assertThat(request.llmConfig().userTemplate()).isEqualTo("CONCEPT USER");
        assertThat(request.llmConfig().responseSchema()).isEqualTo(EXPECTED_CHOICE_SET_RESPONSE_SCHEMA);
    }

    @Test
    void 결과_일치_문제는_정답_실행결과를_프롬프트에_치환하고_샌드박스를_반납한다() {
        Question question = executableQuestion();
        question.setChoiceSetPolicy(ChoiceSetPolicy.RESULT_MATCH);
        PromptTemplate prompt = prompt("결과={answer_result}");
        when(questionService.getQuestionEntity(questionUuid)).thenReturn(question);
        when(promptService.getActivePrompt("generate_choice_set_result_match")).thenReturn(prompt);
        when(sandboxPool.acquire()).thenReturn("sandbox_1");
        ExecuteResult answerResult = new ExecuteResult("OK", List.of("ID", "NAME"),
                List.of(List.of(1, "{x}")), 1, 3L, null, null);
        when(sandboxExecutor.execute("sandbox_1", "SELECT answer")).thenReturn(answerResult);
        GenerateChoiceSetResult aiResult = new GenerateChoiceSetResult(List.of(
                new GeneratedChoiceDto("A", "[{\"id\": 1.0, \"name\": \"{x}\"}]", true, "r"),
                new GeneratedChoiceDto("B", "[{\"id\": 2, \"name\": \"{x}\"}]", false, "r"),
                new GeneratedChoiceDto("C", "not json", false, "r"),
                new GeneratedChoiceDto("D", "[]", false, "r")), null);
        when(aiGatewayClient.generateChoiceSet(any())).thenReturn(aiResult);
        QuestionChoiceSet savedChoiceSet = mock(QuestionChoiceSet.class);
        when(choiceSetSaveService.saveResultMatch(eq(question), eq(ChoiceSetSource.AI_PREFETCH), eq(memberUuid),
                eq(prompt), eq(aiResult), any(), eq(1))).thenReturn(savedChoiceSet);

        QuestionChoiceSet result = choiceSetGenerationService.generateResultMatch(questionUuid, memberUuid, ChoiceSetSource.AI_PREFETCH);

        assertThat(result).isSameAs(savedChoiceSet);
        verify(sandboxExecutor).applyDdl("sandbox_1", "CREATE TABLE t (id int);\nINSERT INTO t VALUES (1)");
        verify(sandboxPool).release("sandbox_1");
        ArgumentCaptor<GenerateChoiceSetRequest> requestCaptor = ArgumentCaptor.forClass(GenerateChoiceSetRequest.class);
        verify(aiGatewayClient).generateChoiceSet(requestCaptor.capture());
        assertThat(requestCaptor.getValue().llmConfig().userTemplate()).isEqualTo("결과=ID, NAME\n1, [x]");
        assertThat(requestCaptor.getValue().llmConfig().responseSchema()).isEqualTo(EXPECTED_CHOICE_SET_RESPONSE_SCHEMA);
        ArgumentCaptor<ValidationReport> reportCaptor = ArgumentCaptor.forClass(ValidationReport.class);
        verify(choiceSetSaveService).saveResultMatch(any(), any(), any(), any(), any(), reportCaptor.capture(), anyInt());
        assertThat(reportCaptor.getValue().correctCount()).isEqualTo(1);
    }

    private Question executableQuestion() {
        return Question.builder()
                .questionUuid(questionUuid)
                .stem("지문")
                .answerSql("SELECT answer")
                .schemaDdl("CREATE TABLE t (id int)")
                .schemaSampleData("INSERT INTO t VALUES (1)")
                .schemaIntent("의도")
                .difficulty(2)
                .choiceSetPolicy(ChoiceSetPolicy.AI_ONLY)
                .build();
    }

    private PromptTemplate prompt(String userTemplate) {
        return PromptTemplate.builder()
                .model("model")
                .systemPrompt("SYSTEM")
                .userTemplate(userTemplate)
                .temperature(0.5f)
                .maxTokens(100)
                .build();
    }

    private ChoiceValidation matched(String key, boolean isMatched) {
        return new ChoiceValidation(key, "OK", List.of(), 0, isMatched, null);
    }
}
