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
 * OpenAI Chat Completions: 일반·JSON 강제 응답(json_object + 스키마 지시), 호출 기록 (#695)
 * temperature 미전송 (추론 모델이 기본값 외 거부)
 */
@Component
@RequiredArgsConstructor
public class OpenAiClient implements AiProviderClient {

    private static final String CHAT_COMPLETIONS_URL = "https://api.openai.com/v1/chat/completions";
    private static final String MODELS_URL = "https://api.openai.com/v1/models/";
    // 호출 기록 endpointPath (직접 호출 기능 구분)
    static final String CHAT_ENDPOINT_PATH = "openai:chat";
    static final String CHAT_STRUCTURED_ENDPOINT_PATH = "openai:chatStructured";
    // JSON 응답 지시 (시스템 프롬프트 끝에 붙임, AI 서버 openai_client.py 와 같은 문구)
    private static final String JSON_SCHEMA_INSTRUCTION = "\n\n응답은 다음 JSON 스키마를 따르는 JSON 객체 하나로만 작성:\n";

    private final AiProviderHttpClient aiProviderHttpClient;
    private final AiCallLogService aiCallLogService;

    @Override
    public AiProvider provider() {
        return AiProvider.OPENAI;
    }

    @Override
    public String chat(AiConnectionTarget connection, String model, String systemPrompt, String userPrompt,
                       float temperature, int maxTokens) {
        ObjectNode requestBody = buildRequestBody(model, systemPrompt == null ? "" : systemPrompt, userPrompt, maxTokens);
        return extractContent(sendChatCompletion(connection, CHAT_ENDPOINT_PATH, model, requestBody), model);
    }

    @Override
    public String chatStructured(AiConnectionTarget connection, String model, String systemPrompt, String userPrompt,
                                 float temperature, int maxTokens, String responseSchemaJson) {
        String systemPromptWithSchema = (systemPrompt == null ? "" : systemPrompt)
                + JSON_SCHEMA_INSTRUCTION + AiResponseSchemaConverter.toJsonSchema(responseSchemaJson);
        ObjectNode requestBody = buildRequestBody(model, systemPromptWithSchema, userPrompt, maxTokens);
        requestBody.putObject("response_format").put("type", "json_object");
        return extractContent(sendChatCompletion(connection, CHAT_STRUCTURED_ENDPOINT_PATH, model, requestBody), model);
    }

    /** 모델 조회 (GET /v1/models/{model}, 과금 없음) */
    @Override
    public void verifyConnection(String apiKey, String model) {
        aiProviderHttpClient.get(provider(), MODELS_URL + model, toHeaders(apiKey));
    }

    private ObjectNode buildRequestBody(String model, String systemPrompt, String userPrompt, int maxTokens) {
        ObjectNode requestBody = aiProviderHttpClient.objectMapper().createObjectNode();
        requestBody.put("model", model);
        requestBody.put("max_completion_tokens", maxTokens);
        var messages = requestBody.putArray("messages");
        messages.addObject().put("role", "system").put("content", systemPrompt);
        messages.addObject().put("role", "user").put("content", userPrompt);
        return requestBody;
    }

    /** Chat Completions 1건 + 호출 기록 (성공·실패 공통) */
    private JsonNode sendChatCompletion(AiConnectionTarget connection, String endpointPath, String model, ObjectNode requestBody) {
        long startedAtMilliseconds = System.currentTimeMillis();
        try {
            JsonNode responseBody = aiProviderHttpClient.post(provider(), CHAT_COMPLETIONS_URL, toHeaders(connection.apiKey()), requestBody);
            JsonNode usage = responseBody.path("usage");
            aiCallLogService.recordConnectionCall(AiCallSource.OPENAI_DIRECT, connection.connectionName(), endpointPath, model,
                    true, System.currentTimeMillis() - startedAtMilliseconds, null,
                    usage.has("prompt_tokens") ? usage.path("prompt_tokens").asInt() : null,
                    usage.has("completion_tokens") ? usage.path("completion_tokens").asInt() : null);
            return responseBody;
        } catch (AiProviderException e) {
            aiCallLogService.recordConnectionCall(AiCallSource.OPENAI_DIRECT, connection.connectionName(), endpointPath, model,
                    false, System.currentTimeMillis() - startedAtMilliseconds, e.toErrorType(), null, null);
            throw e;
        }
    }

    private static String extractContent(JsonNode responseBody, String model) {
        String content = responseBody.path("choices").path(0).path("message").path("content").asText("");
        if (content.isBlank()) {
            throw new IllegalStateException("OpenAI returned empty response for model: " + model);
        }
        return content;
    }

    private static Map<String, String> toHeaders(String apiKey) {
        return Map.of("Authorization", "Bearer " + apiKey);
    }
}
