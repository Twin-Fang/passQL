package com.passql.ai.client;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.dto.*;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Python AI 서버 장애 시 AiChatClient 를 직접 호출하는 fallback 래퍼 (모델 이름으로 Gemini·Claude 선택).
 * <p>
 * ⚠️ AiGatewayClient 내부에서만 호출. 다른 서비스에서 직접 주입 금지.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class GeminiFallbackClient {

    // 템플릿 변수 자리 {이름} (이름 = 영문·숫자·밑줄, JSON 예시 중괄호는 해당 없음)
    private static final Pattern TEMPLATE_VARIABLE_PATTERN = Pattern.compile("\\{([A-Za-z_][A-Za-z0-9_]*)\\}");

    private final AiChatClient aiChatClient;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public GenerateQuestionFullResult generateQuestionFull(GenerateQuestionFullRequest request) {
        LlmConfigDto config = request.llmConfig();
        String userPrompt = renderTemplate(config.userTemplate(), buildQuestionFullVars(request.context()));
        try {
            long started = System.currentTimeMillis();
            String json;
            if (config.responseSchema() != null) {
                json = aiChatClient.chatStructured(
                        config.model(), config.systemPrompt(), userPrompt,
                        config.temperature(), config.maxTokens(),
                        toSchemaJson(config.responseSchema()));
            } else {
                json = aiChatClient.chat(
                        config.model(), config.systemPrompt(), userPrompt,
                        config.temperature(), config.maxTokens());
            }
            int elapsed = (int) (System.currentTimeMillis() - started);
            return parseQuestionFullResponse(json, config.model(), elapsed);
        } catch (CustomException e) {
            throw e;
        } catch (Exception e) {
            log.error("[GeminiFallback] generateQuestionFull 실패: {}", e.getMessage());
            throw new CustomException(ErrorCode.AI_FALLBACK_FAILED,
                    "Gemini 직접 호출 실패", e);
        }
    }

    public GenerateChoiceSetResult generateChoiceSet(GenerateChoiceSetRequest request) {
        LlmConfigDto config = request.llmConfig();
        String userPrompt = renderTemplate(config.userTemplate(), buildChoiceSetVars(request.context()));
        try {
            long started = System.currentTimeMillis();
            String json;
            if (config.responseSchema() != null) {
                json = aiChatClient.chatStructured(
                        config.model(), config.systemPrompt(), userPrompt,
                        config.temperature(), config.maxTokens(),
                        toSchemaJson(config.responseSchema()));
            } else {
                json = aiChatClient.chat(
                        config.model(), config.systemPrompt(), userPrompt,
                        config.temperature(), config.maxTokens());
            }
            int elapsed = (int) (System.currentTimeMillis() - started);
            return parseChoiceSetResponse(json, config.model(), elapsed);
        } catch (CustomException e) {
            throw e;
        } catch (Exception e) {
            log.error("[GeminiFallback] generateChoiceSet 실패: {}", e.getMessage());
            throw new CustomException(ErrorCode.AI_FALLBACK_FAILED,
                    "Gemini 직접 호출 실패", e);
        }
    }

    public TestPromptResult testPrompt(TestPromptRequest request) {
        LlmConfigDto config = request.llmConfig();
        String userPrompt = renderTemplate(config.userTemplate(), request.variables());
        try {
            long started = System.currentTimeMillis();
            String result;
            if (config.responseSchema() != null) {
                result = aiChatClient.chatStructured(
                        config.model(), config.systemPrompt(), userPrompt,
                        config.temperature(), config.maxTokens(),
                        toSchemaJson(config.responseSchema()));
            } else {
                result = aiChatClient.chat(
                        config.model(), config.systemPrompt(), userPrompt,
                        config.temperature(), config.maxTokens());
            }
            int elapsed = (int) (System.currentTimeMillis() - started);
            return new TestPromptResult(result, elapsed);
        } catch (CustomException e) {
            throw e;
        } catch (Exception e) {
            log.error("[GeminiFallback] testPrompt 실패: {}", e.getMessage());
            throw new CustomException(ErrorCode.AI_FALLBACK_FAILED,
                    "Gemini 직접 호출 실패", e);
        }
    }

    // ========================
    //  내부 유틸
    // ========================

    /**
     * {변수} 한 번에 치환 (값 null > 빈 문자열, 모르는 이름은 그대로, AI 서버 render_template 과 같은 규칙)
     * 한 번만 훑어 치환한 값 안의 {다른 변수} 가 다시 치환되지 않음 (#877)
     */
    static String renderTemplate(String template, Map<String, String> variables) {
        if (template == null) return "";
        return TEMPLATE_VARIABLE_PATTERN.matcher(template).replaceAll(match -> {
            String variableName = match.group(1);
            if (!variables.containsKey(variableName)) {
                return Matcher.quoteReplacement(match.group());
            }
            String variableValue = variables.get(variableName);
            return Matcher.quoteReplacement(variableValue != null ? variableValue : "");
        });
    }

    private Map<String, String> buildQuestionFullVars(QuestionFullContextDto ctx) {
        return Map.of(
                "schema_ddl", ctx.schemaDdl() != null ? ctx.schemaDdl() : "",
                "schema_sample_data", ctx.schemaSampleData() != null ? ctx.schemaSampleData() : "",
                "schema_intent", ctx.schemaIntent() != null ? ctx.schemaIntent() : "",
                "topic", ctx.topic() != null ? ctx.topic() : "",
                "subtopic", ctx.subtopic() != null ? ctx.subtopic() : "",
                "difficulty", String.valueOf(ctx.difficulty()),
                "hint", ctx.hint() != null ? ctx.hint() : ""
        );
    }

    private Map<String, String> buildChoiceSetVars(ChoiceSetContextDto ctx) {
        return Map.of(
                "question_uuid", ctx.questionUuid() != null ? ctx.questionUuid().toString() : "",
                "stem", ctx.stem() != null ? ctx.stem() : "",
                "answer_sql", ctx.answerSql() != null ? ctx.answerSql() : "",
                "schema_ddl", ctx.schemaDdl() != null ? ctx.schemaDdl() : "",
                "schema_sample_data", ctx.schemaSampleData() != null ? ctx.schemaSampleData() : "",
                "schema_intent", ctx.schemaIntent() != null ? ctx.schemaIntent() : "",
                "difficulty", String.valueOf(ctx.difficulty())
        );
    }

    /** 응답 스키마 Map > JSON 문자열 (Gemini·Claude 공통 입력) */
    private String toSchemaJson(Map<String, Object> schemaMap) throws Exception {
        return objectMapper.writeValueAsString(schemaMap);
    }

    @SuppressWarnings("unchecked")
    private GenerateQuestionFullResult parseQuestionFullResponse(String json, String model, int elapsed) {
        try {
            Map<String, Object> payload = objectMapper.readValue(json, new TypeReference<>() {});
            String stem = (String) payload.get("stem");
            String answerSql = (String) payload.get("answer_sql");
            List<Map<String, Object>> rawChoices = (List<Map<String, Object>>) payload.get("seed_choices");

            List<GeneratedChoiceDto> choices = rawChoices.stream()
                    .map(c -> new GeneratedChoiceDto(
                            (String) c.get("key"),
                            (String) c.get("body"),
                            Boolean.TRUE.equals(c.get("is_correct")),
                            (String) c.get("rationale")))
                    .toList();

            return new GenerateQuestionFullResult(stem, answerSql, choices,
                    new GenerationMetadataDto(model, null, elapsed, null, null, payload, 1, null));
        } catch (Exception e) {
            // 원인 메시지는 로그에만 (응답 detail 은 고정 문구)
            log.error("[GeminiFallback] 응답 파싱 실패: model={}, error={}", model, e.getMessage());
            throw new CustomException(ErrorCode.AI_RESPONSE_PARSE_FAILED,
                    "Gemini fallback 응답 파싱 실패", e);
        }
    }

    @SuppressWarnings("unchecked")
    private GenerateChoiceSetResult parseChoiceSetResponse(String json, String model, int elapsed) {
        try {
            Map<String, Object> payload = objectMapper.readValue(json, new TypeReference<>() {});
            List<Map<String, Object>> rawChoices = (List<Map<String, Object>>) payload.get("choices");

            List<GeneratedChoiceDto> choices = rawChoices.stream()
                    .map(c -> new GeneratedChoiceDto(
                            (String) c.get("key"),
                            (String) c.get("body"),
                            Boolean.TRUE.equals(c.get("is_correct")),
                            (String) c.get("rationale")))
                    .toList();

            return new GenerateChoiceSetResult(choices,
                    new GenerationMetadataDto(model, null, elapsed, null, null, payload, 1, null));
        } catch (Exception e) {
            // 원인 메시지는 로그에만 (응답 detail 은 고정 문구)
            log.error("[GeminiFallback] 응답 파싱 실패: model={}, error={}", model, e.getMessage());
            throw new CustomException(ErrorCode.AI_RESPONSE_PARSE_FAILED,
                    "Gemini fallback 응답 파싱 실패", e);
        }
    }
}
