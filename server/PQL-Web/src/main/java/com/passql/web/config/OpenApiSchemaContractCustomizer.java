package com.passql.web.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.media.Schema;
import org.springdoc.core.customizers.OpenApiCustomizer;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * OpenAPI 스키마를 클라이언트 타입 생성에 맞게 보정: 응답 필드 전부 required, null 가능한 객체 참조는 oneOf 로 표현
 * 서버는 null 값도 필드로 내보내므로 "있음"이 계약이고 null 가능 여부는 nullable 로 구분
 */
@Component
public class OpenApiSchemaContractCustomizer implements OpenApiCustomizer {

    // 요청 본문 스키마 접미사 (required 는 Bean Validation 이 만든 값을 그대로 둠)
    private static final String REQUEST_SCHEMA_SUFFIX = "Request";
    // Spring 이 만드는 페이지·정렬·SSE 스키마
    private static final Set<String> INFRASTRUCTURE_SCHEMA_NAMES = Set.of("Pageable", "PageableObject", "SortObject", "SseEmitter");
    private static final String NULL_TYPE = "null";

    @Override
    @SuppressWarnings({"rawtypes", "unchecked"})
    public void customise(OpenAPI openApi) {
        if (openApi.getComponents() == null || openApi.getComponents().getSchemas() == null) return;
        for (Map.Entry<String, Schema> entry : openApi.getComponents().getSchemas().entrySet()) {
            String schemaName = entry.getKey();
            Schema<?> schema = entry.getValue();
            if (schema.getProperties() == null || INFRASTRUCTURE_SCHEMA_NAMES.contains(schemaName)) continue;

            // null 가능한 참조 (springdoc 은 $ref 옆에 type: null 을 붙여 의미가 깨짐) > oneOf [참조, null]
            Map<String, Schema> properties = (Map<String, Schema>) schema.getProperties();
            for (Map.Entry<String, Schema> property : new LinkedHashMap<>(properties).entrySet()) {
                if (isNullableReference(property.getValue())) {
                    properties.put(property.getKey(), toNullableReference(property.getValue()));
                }
            }
            if (!schemaName.endsWith(REQUEST_SCHEMA_SUFFIX)) {
                schema.setRequired(new ArrayList<>(properties.keySet()));
            }
        }
    }

    private static boolean isNullableReference(Schema<?> property) {
        return property.get$ref() != null && property.getTypes() != null && property.getTypes().contains(NULL_TYPE);
    }

    @SuppressWarnings("rawtypes")
    private static Schema toNullableReference(Schema<?> property) {
        Schema reference = new Schema<>().$ref(property.get$ref());
        Schema nullSchema = new Schema<>();
        nullSchema.setTypes(Set.of(NULL_TYPE));
        Schema wrapper = new Schema<>();
        wrapper.setOneOf(List.of(reference, nullSchema));
        return wrapper;
    }
}
