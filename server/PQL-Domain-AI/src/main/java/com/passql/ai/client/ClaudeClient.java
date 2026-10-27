package com.passql.ai.client;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.passql.ai.constant.AiCallSource;
import com.passql.ai.service.AiCallLogService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.util.Map;

/**
 * Spring 직접 Claude 호출: Messages API, JSON 강제 응답(도구 강제 호출), 호출 기록(모델·지연·토큰) (#688)
 * 키는 호출마다 관리자 설정 ai.claude_api_key 에서 읽음 (재배포 없이 변경 반영)
 */
@Slf4j
@Component
public class ClaudeClient {

    private static final String MESSAGES_URL = "https://api.anthropic.com/v1/messages";
    private static final String API_VERSION = "2023-06-01";
    // 호출 기록 endpointPath (직접 호출 기능 구분)
    static final String CHAT_ENDPOINT_PATH = "claude:chat";
    static final String CHAT_STRUCTURED_ENDPOINT_PATH = "claude:chatStructured";
    // 호출 기록 errorType: 429 한도 초과·크레딧 부족, 401·403 키 무효·권한
    static final String QUOTA_EXCEEDED_ERROR_TYPE = "CLAUDE_QUOTA_EXCEEDED";
    static final String PERMISSION_DENIED_ERROR_TYPE = "CLAUDE_PERMISSION_DENIED";
    // 호출 1회 응답 대기 상한 (30초, Gemini 와 같은 기준)
    private static final int CALL_TIMEOUT_MILLISECONDS = 30_000;
    // JSON 강제 응답용 도구 이름 (tool_choice 로 이 도구만 쓰게 함)
    private static final String STRUCTURED_RESPONSE_TOOL_NAME = "submit_response";
    // Gemini 스키마 전용 키 (JSON Schema 에 없음 > 제거)
    private static final String GEMINI_PROPERTY_ORDERING_KEY = "propertyOrdering";
    private static final String GEMINI_NULLABLE_KEY = "nullable";
    private static final int QUOTA_EXCEEDED_STATUS_CODE = 429;
    private static final int UNAUTHORIZED_STATUS_CODE = 401;
    private static final int FORBIDDEN_STATUS_CODE = 403;
    // 스키마 변환 노드 생성 전용 (정적 변환 메서드에서 사용)
    private static final ObjectMapper SCHEMA_NODE_MAPPER = new ObjectMapper();

    private final AppSettingService appSettingService;
    private final AiCallLogService aiCallLogService;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final RestTemplate restTemplate;

    public ClaudeClient(AppSettingService appSettingService, AiCallLogService aiCallLogService) {
        this.appSettingService = appSettingService;
        this.aiCallLogService = aiCallLogService;
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(Duration.ofMillis(CALL_TIMEOUT_MILLISECONDS));
        requestFactory.setReadTimeout(Duration.ofMillis(CALL_TIMEOUT_MILLISECONDS));
        this.restTemplate = new RestTemplate(requestFactory);
    }

    /** 일반 텍스트 응답 (text 블록 이어 붙임) */
    public String chat(String model, String systemPrompt, String userPrompt, float temperature, int maxTokens) {
        ObjectNode requestBody = buildRequestBody(model, systemPrompt, userPrompt, maxTokens);
        JsonNode responseBody = sendMessages(CHAT_ENDPOINT_PATH, model, requestBody);
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

    /** JSON 강제 응답: 응답 스키마(Gemini 형식 JSON) > 도구 input_schema > 강제 호출 > 도구 입력 JSON 문자열 */
    public String chatStructured(String model, String systemPrompt, String userPrompt, float temperature,
                                 int maxTokens, String responseSchemaJson) {
        ObjectNode requestBody = buildRequestBody(model, systemPrompt, userPrompt, maxTokens);
        ObjectNode tool = requestBody.putArray("tools").addObject();
        tool.put("name", STRUCTURED_RESPONSE_TOOL_NAME);
        tool.put("description", "응답을 정해진 JSON 형식으로 제출");
        tool.set("input_schema", toJsonSchema(readJson(responseSchemaJson)));
        requestBody.putObject("tool_choice").put("type", "tool").put("name", STRUCTURED_RESPONSE_TOOL_NAME);

        JsonNode responseBody = sendMessages(CHAT_STRUCTURED_ENDPOINT_PATH, model, requestBody);
        for (JsonNode block : responseBody.path("content")) {
            if ("tool_use".equals(block.path("type").asText()) && block.path("input").isObject()) {
                return block.path("input").toString();
            }
        }
        throw new IllegalStateException("Claude structured response has no tool_use block for model: " + model);
    }

    /** Gemini 응답 스키마(type 대문자, nullable) > JSON Schema (type 소문자, null 허용 type 배열) */
    static JsonNode toJsonSchema(JsonNode geminiSchema) {
        if (geminiSchema.isArray()) {
            ArrayNode converted = SCHEMA_NODE_MAPPER.createArrayNode();
            geminiSchema.forEach(element -> converted.add(toJsonSchema(element)));
            return converted;
        }
        if (!geminiSchema.isObject()) {
            return geminiSchema;
        }
        ObjectNode converted = SCHEMA_NODE_MAPPER.createObjectNode();
        for (Map.Entry<String, JsonNode> field : geminiSchema.properties()) {
            String key = field.getKey();
            JsonNode value = field.getValue();
            if (GEMINI_PROPERTY_ORDERING_KEY.equals(key) || GEMINI_NULLABLE_KEY.equals(key)) {
                continue;
            }
            if ("type".equals(key) && value.isTextual()) {
                converted.put(key, value.asText().toLowerCase());
            } else if ("properties".equals(key) && value.isObject()) {
                ObjectNode properties = converted.putObject(key);
                value.properties().forEach(property -> properties.set(property.getKey(), toJsonSchema(property.getValue())));
            } else {
                converted.set(key, toJsonSchema(value));
            }
        }
        if (geminiSchema.path(GEMINI_NULLABLE_KEY).asBoolean(false) && converted.path("type").isTextual()) {
            String type = converted.path("type").asText();
            converted.putArray("type").add(type).add("null");
        }
        return converted;
    }

    private ObjectNode buildRequestBody(String model, String systemPrompt, String userPrompt, int maxTokens) {
        ObjectNode requestBody = objectMapper.createObjectNode();
        requestBody.put("model", model);
        requestBody.put("max_tokens", maxTokens);
        // temperature 미전송: Claude 최신 모델이 파라미터 자체를 거부 (400 deprecated)
        requestBody.put("system", systemPrompt == null ? "" : systemPrompt);
        requestBody.putArray("messages").addObject().put("role", "user").put("content", userPrompt);
        return requestBody;
    }

    /** Messages API 1건 > 응답 JSON + 호출 기록 (성공·실패 공통) */
    private JsonNode sendMessages(String endpointPath, String model, ObjectNode requestBody) {
        long startedAtMilliseconds = System.currentTimeMillis();
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("x-api-key", resolveApiKey());
            headers.set("anthropic-version", API_VERSION);
            String responseText = restTemplate.postForObject(MESSAGES_URL,
                    new HttpEntity<>(requestBody.toString(), headers), String.class);
            JsonNode responseBody = readJson(responseText);
            JsonNode usage = responseBody.path("usage");
            aiCallLogService.record(AiCallSource.CLAUDE_DIRECT, endpointPath, model, true,
                    System.currentTimeMillis() - startedAtMilliseconds, null,
                    usage.has("input_tokens") ? usage.path("input_tokens").asInt() : null,
                    usage.has("output_tokens") ? usage.path("output_tokens").asInt() : null);
            return responseBody;
        } catch (RuntimeException e) {
            aiCallLogService.record(AiCallSource.CLAUDE_DIRECT, endpointPath, model, false,
                    System.currentTimeMillis() - startedAtMilliseconds, toErrorType(e), null, null);
            throw e;
        }
    }

    private String resolveApiKey() {
        String apiKey = appSettingService.getSecret(AppSettingKeys.AI_CLAUDE_API_KEY);
        if (apiKey == null || apiKey.isBlank()) {
            log.error("[claude client] rejected : api key not configured");
            throw new CustomException(ErrorCode.AI_UNAVAILABLE);
        }
        return apiKey;
    }

    private JsonNode readJson(String json) {
        try {
            return objectMapper.readTree(json);
        } catch (Exception e) {
            throw new IllegalStateException("Claude json parse failed", e);
        }
    }

    /** 실패 종류: 429 > CLAUDE_QUOTA_EXCEEDED, 401·403 > CLAUDE_PERMISSION_DENIED, CustomException 은 ErrorCode 이름, 그 외 예외 클래스 이름 */
    static String toErrorType(RuntimeException e) {
        if (e instanceof HttpStatusCodeException httpStatusCodeException) {
            int statusCode = httpStatusCodeException.getStatusCode().value();
            if (statusCode == QUOTA_EXCEEDED_STATUS_CODE) {
                return QUOTA_EXCEEDED_ERROR_TYPE;
            }
            if (statusCode == UNAUTHORIZED_STATUS_CODE || statusCode == FORBIDDEN_STATUS_CODE) {
                return PERMISSION_DENIED_ERROR_TYPE;
            }
        }
        if (e instanceof CustomException customException) {
            return customException.getErrorCode().name();
        }
        return e.getClass().getSimpleName();
    }
}
