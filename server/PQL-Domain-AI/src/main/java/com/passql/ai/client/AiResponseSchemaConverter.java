package com.passql.ai.client;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

import java.util.Map;

/**
 * Gemini 응답 스키마(type 대문자, nullable) > JSON Schema (type 소문자, null 허용 type 배열)
 * Claude 도구 input_schema·OpenAI 시스템 지시 공통 (AI 서버 llm_schema.py 와 같은 규칙)
 */
public final class AiResponseSchemaConverter {

    // Gemini 스키마 전용 키 (JSON Schema 에 없음 > 제거)
    private static final String GEMINI_PROPERTY_ORDERING_KEY = "propertyOrdering";
    private static final String GEMINI_NULLABLE_KEY = "nullable";
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private AiResponseSchemaConverter() {
    }

    public static JsonNode toJsonSchema(String geminiSchemaJson) {
        try {
            return toJsonSchema(OBJECT_MAPPER.readTree(geminiSchemaJson));
        } catch (Exception e) {
            throw new IllegalStateException("response schema json parse failed", e);
        }
    }

    public static JsonNode toJsonSchema(JsonNode geminiSchema) {
        if (geminiSchema.isArray()) {
            ArrayNode converted = OBJECT_MAPPER.createArrayNode();
            geminiSchema.forEach(element -> converted.add(toJsonSchema(element)));
            return converted;
        }
        if (!geminiSchema.isObject()) {
            return geminiSchema;
        }
        ObjectNode converted = OBJECT_MAPPER.createObjectNode();
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
}
