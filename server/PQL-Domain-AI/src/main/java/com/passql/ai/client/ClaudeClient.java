package com.passql.ai.client;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.passql.ai.constant.AiCallSource;
import com.passql.ai.constant.AiProvider;
import com.passql.ai.dto.AiConnectionTarget;
import com.passql.ai.service.AiCallLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Claude Messages API: 일반·JSON 강제 응답(도구 강제 호출), 호출 기록(연결·모델·지연·토큰) (#688, #695)
 */
@Component
@RequiredArgsConstructor
public class ClaudeClient implements AiProviderClient {

    private static final String MESSAGES_URL = "https://api.anthropic.com/v1/messages";
    private static final String MODELS_URL = "https://api.anthropic.com/v1/models/";
    private static final String API_VERSION = "2023-06-01";
    // 호출 기록 endpointPath (직접 호출 기능 구분)
    static final String CHAT_ENDPOINT_PATH = "claude:chat";
    static final String CHAT_STRUCTURED_ENDPOINT_PATH = "claude:chatStructured";
    // JSON 강제 응답용 도구 이름 (tool_choice 로 이 도구만 쓰게 함)
    private static final String STRUCTURED_RESPONSE_TOOL_NAME = "submit_response";

    private final AiProviderHttpClient aiProviderHttpClient;
    private final AiCallLogService aiCallLogService;

    @Override
    public AiProvider provider() {
        return AiProvider.CLAUDE;
    }

    /** 일반 텍스트 응답 (text 블록 이어 붙임, temperature 는 Claude 최신 모델이 거부해 미전송) */
    @Override
    public String chat(AiConnectionTarget connection, String model, String systemPrompt, String userPrompt,
                       float temperature, int maxTokens) {
        ObjectNode requestBody = buildRequestBody(model, systemPrompt, userPrompt, maxTokens);
        JsonNode responseBody = sendMessages(connection, CHAT_ENDPOINT_PATH, model, requestBody);
        StringBuilder text = new StringBuilder();
        for (JsonNode block : responseBody.path("content")) {
            if ("text".equals(block.path("type").asText())) {
                text.append(block.path("text").asText());
            }
        }
        if (text.toString().isBlank()) {
            throw new IllegalStateException("Claude returned empty response for model: " + model);
        }
        return text.toString();
    }

    /** JSON 강제 응답: 응답 스키마 > 도구 input_schema > 강제 호출 > 도구 입력 JSON 문자열 */
    @Override
    public String chatStructured(AiConnectionTarget connection, String model, String systemPrompt, String userPrompt,
                                 float temperature, int maxTokens, String responseSchemaJson) {
        ObjectNode requestBody = buildRequestBody(model, systemPrompt, userPrompt, maxTokens);
        ObjectNode tool = requestBody.putArray("tools").addObject();
        tool.put("name", STRUCTURED_RESPONSE_TOOL_NAME);
        tool.put("description", "응답을 정해진 JSON 형식으로 제출");
        tool.set("input_schema", AiResponseSchemaConverter.toJsonSchema(responseSchemaJson));
        requestBody.putObject("tool_choice").put("type", "tool").put("name", STRUCTURED_RESPONSE_TOOL_NAME);

        JsonNode responseBody = sendMessages(connection, CHAT_STRUCTURED_ENDPOINT_PATH, model, requestBody);
        for (JsonNode block : responseBody.path("content")) {
            if ("tool_use".equals(block.path("type").asText()) && block.path("input").isObject()) {
                return block.path("input").toString();
            }
        }
        throw new IllegalStateException("Claude structured response has no tool_use block for model: " + model);
    }

    /** 모델 조회 (GET /v1/models/{model}, 과금 없음) */
    @Override
    public void verifyConnection(String apiKey, String model) {
        aiProviderHttpClient.get(provider(), MODELS_URL + model, toHeaders(apiKey));
    }

    private ObjectNode buildRequestBody(String model, String systemPrompt, String userPrompt, int maxTokens) {
        ObjectNode requestBody = aiProviderHttpClient.objectMapper().createObjectNode();
        requestBody.put("model", model);
        requestBody.put("max_tokens", maxTokens);
        // thinking 끔: 켜져 있으면 thinking 토큰이 max_tokens 를 먼저 써서 본문이 비거나 잘림
        requestBody.putObject("thinking").put("type", "disabled");
        requestBody.put("system", systemPrompt == null ? "" : systemPrompt);
        requestBody.putArray("messages").addObject().put("role", "user").put("content", userPrompt);
        return requestBody;
    }

    /** Messages API 1건 + 호출 기록 (성공·실패 공통) */
    private JsonNode sendMessages(AiConnectionTarget connection, String endpointPath, String model, ObjectNode requestBody) {
        long startedAtMilliseconds = System.currentTimeMillis();
        try {
            JsonNode responseBody = aiProviderHttpClient.post(provider(), MESSAGES_URL, toHeaders(connection.apiKey()), requestBody);
            JsonNode usage = responseBody.path("usage");
            aiCallLogService.recordConnectionCall(AiCallSource.CLAUDE_DIRECT, connection.connectionName(), endpointPath, model,
                    true, System.currentTimeMillis() - startedAtMilliseconds, null,
                    usage.has("input_tokens") ? usage.path("input_tokens").asInt() : null,
                    usage.has("output_tokens") ? usage.path("output_tokens").asInt() : null);
            return responseBody;
        } catch (AiProviderException e) {
            aiCallLogService.recordConnectionCall(AiCallSource.CLAUDE_DIRECT, connection.connectionName(), endpointPath, model,
                    false, System.currentTimeMillis() - startedAtMilliseconds, e.toErrorType(), null, null);
            throw e;
        }
    }

    private static Map<String, String> toHeaders(String apiKey) {
        return Map.of("x-api-key", apiKey, "anthropic-version", API_VERSION);
    }
}
