package com.passql.ai.client;

import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.introspect.BeanPropertyDefinition;
import com.passql.ai.constant.AiServerErrorKind;
import com.passql.ai.dto.*;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Spring DTO <-> AI 서버 계약 스냅샷 (ai/tests/snapshots, AI 서버 pytest 가 같은 파일을 고정, #877)
 * 검사 3개: 요청 필드 이름 일치, AI 서버 응답 필드 ⊂ Spring 응답 필드(모르는 필드면 역직렬화 실패), error_kind 이름 일치
 */
class AiServerContractSnapshotTest {

    // 레포 루트 기준 스냅샷 위치
    private static final Path SNAPSHOT_DIRECTORY = Path.of("ai", "tests", "snapshots");
    private static final String ENDPOINT_SNAPSHOT_FILE = "spring_called_endpoints_openapi.json";
    private static final String ERROR_KIND_SNAPSHOT_FILE = "error_kinds.json";
    private static final String DTO_PACKAGE_PREFIX = "com.passql.ai.dto.";

    // AiGatewayClient 호출 경로 8개 > (요청 DTO, 응답 DTO)
    private static final Map<String, Class<?>[]> DTO_CLASSES_BY_PATH = Map.of(
            "/api/ai/generate-question-full", new Class<?>[]{GenerateQuestionFullRequest.class, GenerateQuestionFullResult.class},
            "/api/ai/generate-choice-set", new Class<?>[]{GenerateChoiceSetRequest.class, GenerateChoiceSetResult.class},
            "/api/ai/test-prompt", new Class<?>[]{TestPromptRequest.class, TestPromptResult.class},
            "/api/ai/index-question", new Class<?>[]{IndexQuestionRequest.class, IndexQuestionResult.class},
            "/api/ai/index-questions-bulk", new Class<?>[]{IndexQuestionsBulkRequest.class, IndexQuestionsBulkResult.class},
            "/api/ai/recommend", new Class<?>[]{RecommendRequest.class, RecommendResult.class},
            "/api/ai/index-status", new Class<?>[]{IndexStatusRequest.class, IndexStatusResult.class},
            "/api/ai/prune-index", new Class<?>[]{IndexStatusRequest.class, PruneIndexResult.class});

    // AiGatewayClient 와 같은 snake_case 변환
    private final ObjectMapper snakeCaseMapper = new ObjectMapper()
            .setPropertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE);

    @Test
    void 호출_경로_8개가_스냅샷과_같다() throws IOException {
        JsonNode endpointSnapshot = readSnapshot(ENDPOINT_SNAPSHOT_FILE);

        Set<String> snapshotPaths = new TreeSet<>();
        endpointSnapshot.fieldNames().forEachRemaining(snapshotPaths::add);
        assertThat(snapshotPaths).isEqualTo(new TreeSet<>(DTO_CLASSES_BY_PATH.keySet()));
    }

    @Test
    void 요청_DTO_필드가_AI_서버_요청_스키마와_같다() throws IOException {
        JsonNode endpointSnapshot = readSnapshot(ENDPOINT_SNAPSHOT_FILE);
        List<String> mismatches = new ArrayList<>();
        DTO_CLASSES_BY_PATH.forEach((path, dtoClasses) -> collectRequestMismatches(
                path, snakeCaseMapper.constructType(dtoClasses[0]), endpointSnapshot.path(path).path("request"), mismatches));
        assertThat(mismatches).isEmpty();
    }

    @Test
    void AI_서버_응답_필드는_모두_응답_DTO에_있다() throws IOException {
        JsonNode endpointSnapshot = readSnapshot(ENDPOINT_SNAPSHOT_FILE);
        List<String> mismatches = new ArrayList<>();
        DTO_CLASSES_BY_PATH.forEach((path, dtoClasses) -> collectResponseMismatches(
                path, snakeCaseMapper.constructType(dtoClasses[1]), endpointSnapshot.path(path).path("response"), mismatches));
        assertThat(mismatches).isEmpty();
    }

    @Test
    void 실패_종류_이름이_AI_서버와_같다() throws IOException {
        Set<String> snapshotErrorKinds = new TreeSet<>();
        readSnapshot(ERROR_KIND_SNAPSHOT_FILE).forEach(errorKind -> snapshotErrorKinds.add(errorKind.asText()));

        Set<String> springErrorKinds = Arrays.stream(AiServerErrorKind.values()).map(Enum::name)
                .collect(Collectors.toCollection(TreeSet::new));
        assertThat(springErrorKinds).isEqualTo(snapshotErrorKinds);
    }

    /** 요청: Spring 직렬화 필드 이름 == 스키마 properties (중첩 DTO 는 재귀) */
    private void collectRequestMismatches(String location, JavaType dtoType, JsonNode schema, List<String> mismatches) {
        JsonNode objectSchema = toObjectSchema(schema);
        Map<String, JavaType> springFields = readFieldTypes(dtoType);
        Set<String> schemaFields = readPropertyNames(objectSchema);
        if (!springFields.keySet().equals(schemaFields)) {
            mismatches.add(location + " spring=" + new TreeSet<>(springFields.keySet()) + " ai=" + schemaFields);
            return;
        }
        springFields.forEach((fieldName, fieldType) -> visitNestedDto(fieldType, objectSchema.path("properties").path(fieldName),
                (nestedType, nestedSchema) -> collectRequestMismatches(location + "." + fieldName, nestedType, nestedSchema, mismatches)));
    }

    /** 응답: 스키마 properties ⊂ Spring 역직렬화 필드 (중첩 DTO 는 재귀) */
    private void collectResponseMismatches(String location, JavaType dtoType, JsonNode schema, List<String> mismatches) {
        JsonNode objectSchema = toObjectSchema(schema);
        Map<String, JavaType> springFields = readFieldTypes(dtoType);
        Set<String> schemaFields = readPropertyNames(objectSchema);
        if (!springFields.keySet().containsAll(schemaFields)) {
            mismatches.add(location + " spring=" + new TreeSet<>(springFields.keySet()) + " ai=" + schemaFields);
            return;
        }
        schemaFields.forEach(fieldName -> visitNestedDto(springFields.get(fieldName), objectSchema.path("properties").path(fieldName),
                (nestedType, nestedSchema) -> collectResponseMismatches(location + "." + fieldName, nestedType, nestedSchema, mismatches)));
    }

    /** 필드 타입이 DTO(또는 DTO 목록)면 짝 스키마와 함께 방문 */
    private void visitNestedDto(JavaType fieldType, JsonNode fieldSchema, NestedDtoVisitor visitor) {
        boolean isList = fieldType.isCollectionLikeType();
        JavaType elementType = isList ? fieldType.getContentType() : fieldType;
        if (!elementType.getRawClass().getName().startsWith(DTO_PACKAGE_PREFIX)) {
            return;
        }
        JsonNode elementSchema = isList ? toArraySchema(fieldSchema).path("items") : fieldSchema;
        visitor.visit(elementType, elementSchema);
    }

    private Map<String, JavaType> readFieldTypes(JavaType dtoType) {
        Map<String, JavaType> fieldTypes = new TreeMap<>();
        for (BeanPropertyDefinition property : snakeCaseMapper.getSerializationConfig().introspect(dtoType).findProperties()) {
            fieldTypes.put(property.getName(), property.getPrimaryType());
        }
        return fieldTypes;
    }

    private static Set<String> readPropertyNames(JsonNode objectSchema) {
        Set<String> propertyNames = new TreeSet<>();
        objectSchema.path("properties").fieldNames().forEachRemaining(propertyNames::add);
        return propertyNames;
    }

    /** Optional 필드(anyOf [object, null]) > object 스키마 */
    private static JsonNode toObjectSchema(JsonNode schema) {
        return findSchemaOfType(schema, "object");
    }

    private static JsonNode toArraySchema(JsonNode schema) {
        return findSchemaOfType(schema, "array");
    }

    private static JsonNode findSchemaOfType(JsonNode schema, String schemaType) {
        if (schema.has("anyOf")) {
            for (JsonNode candidate : schema.get("anyOf")) {
                if (schemaType.equals(candidate.path("type").asText())) {
                    return candidate;
                }
            }
        }
        return schema;
    }

    /** 레포 루트(ai/tests/snapshots 가 있는 상위 폴더)에서 스냅샷 읽기 (Gradle 테스트 작업 폴더 = 모듈 폴더) */
    private JsonNode readSnapshot(String fileName) throws IOException {
        for (Path directory = Path.of("").toAbsolutePath(); directory != null; directory = directory.getParent()) {
            Path candidate = directory.resolve(SNAPSHOT_DIRECTORY).resolve(fileName);
            if (Files.exists(candidate)) {
                return snakeCaseMapper.readTree(candidate.toFile());
            }
        }
        throw new IllegalStateException("AI 서버 계약 스냅샷 없음: " + SNAPSHOT_DIRECTORY.resolve(fileName));
    }

    @FunctionalInterface
    private interface NestedDtoVisitor {
        void visit(JavaType nestedType, JsonNode nestedSchema);
    }
}
