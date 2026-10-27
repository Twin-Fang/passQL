package com.passql.ai.client;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.passql.ai.constant.AiCallSource;
import com.passql.ai.dto.*;
import com.passql.ai.dto.ComponentHealth;
import com.passql.ai.service.AiCallLogService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Java 코드에서 AI 기능 사용 시 유일한 진입점.
 * <p>
 * 메인 경로: Python AI 서버 (HTTP)
 * Fallback: {@link GeminiFallbackClient} (AiChatClient 로 AI 연결 직접 호출)
 */
@Slf4j
@Component
public class AiGatewayClient {

    // 상태 확인 전용 짧은 제한 시간 (ms) — 모니터링 화면이 AI 장애에 묶이지 않게
    private static final int HEALTH_CHECK_TIMEOUT_MILLISECONDS = 3000;
    private static final String HEALTH_PATH = "/health";
    private static final String INDEX_STATUS_PATH = "/api/ai/index-status";
    // 벡터 색인·검색 경로 5개 (LLM 아님 > 호출 출처 VECTOR_SEARCH 로 기록, #699)
    private static final Set<String> VECTOR_SEARCH_PATHS = Set.of(
            "/api/ai/index-question", "/api/ai/index-questions-bulk", "/api/ai/recommend",
            INDEX_STATUS_PATH, "/api/ai/prune-index");

    private final RestTemplate restTemplate;
    private final RestTemplate healthCheckRestTemplate;
    private final ObjectMapper snakeCaseMapper;
    private final GeminiFallbackClient fallbackClient;
    private final AiCallLogService aiCallLogService;
    private final String baseUrl;
    private final String apiKey;

    public AiGatewayClient(
            GeminiFallbackClient fallbackClient,
            AiCallLogService aiCallLogService,
            @Value("${passql.ai-server.base-url:http://localhost:8001}") String baseUrl,
            @Value("${passql.ai-server.api-key:}") String apiKey,
            @Value("${passql.ai-server.timeout-ms:15000}") int timeoutMs
    ) {
        this.fallbackClient = fallbackClient;
        this.aiCallLogService = aiCallLogService;
        this.baseUrl = baseUrl;
        this.apiKey = apiKey;

        // Python 서버는 snake_case JSON
        this.snakeCaseMapper = new ObjectMapper();
        this.snakeCaseMapper.setPropertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE);

        // RestTemplate with timeout
        var factory = new org.springframework.http.client.SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(Duration.ofMillis(timeoutMs));
        factory.setReadTimeout(Duration.ofMillis(timeoutMs));
        this.restTemplate = new RestTemplate(factory);

        var healthCheckFactory = new org.springframework.http.client.SimpleClientHttpRequestFactory();
        healthCheckFactory.setConnectTimeout(Duration.ofMillis(HEALTH_CHECK_TIMEOUT_MILLISECONDS));
        healthCheckFactory.setReadTimeout(Duration.ofMillis(HEALTH_CHECK_TIMEOUT_MILLISECONDS));
        this.healthCheckRestTemplate = new RestTemplate(healthCheckFactory);
    }

    // ========================
    //  generateQuestionFull
    // ========================

    @CircuitBreaker(name = "aiServer", fallbackMethod = "generateQuestionFullFallback")
    @Retry(name = "aiServer")
    public GenerateQuestionFullResult generateQuestionFull(GenerateQuestionFullRequest request) {
        return postToPython("/api/ai/generate-question-full", request, GenerateQuestionFullResult.class);
    }

    private GenerateQuestionFullResult generateQuestionFullFallback(
            GenerateQuestionFullRequest request, Throwable t) {
        log.warn("[AiGateway] generateQuestionFull fallback 진입: {}", t.getMessage());
        return fallbackClient.generateQuestionFull(request);
    }

    // ========================
    //  generateChoiceSet
    // ========================

    @CircuitBreaker(name = "aiServer", fallbackMethod = "generateChoiceSetFallback")
    @Retry(name = "aiServer")
    public GenerateChoiceSetResult generateChoiceSet(GenerateChoiceSetRequest request) {
        return postToPython("/api/ai/generate-choice-set", request, GenerateChoiceSetResult.class);
    }

    private GenerateChoiceSetResult generateChoiceSetFallback(
            GenerateChoiceSetRequest request, Throwable t) {
        log.warn("[AiGateway] generateChoiceSet fallback 진입: {}", t.getMessage());
        return fallbackClient.generateChoiceSet(request);
    }

    // ========================
    //  testPrompt
    // ========================

    @CircuitBreaker(name = "aiServer", fallbackMethod = "testPromptFallback")
    @Retry(name = "aiServer")
    public TestPromptResult testPrompt(TestPromptRequest request) {
        return postToPython("/api/ai/test-prompt", request, TestPromptResult.class);
    }

    private TestPromptResult testPromptFallback(TestPromptRequest request, Throwable t) {
        log.warn("[AiGateway] testPrompt fallback 진입: {}", t.getMessage());
        return fallbackClient.testPrompt(request);
    }

    // ========================
    //  indexQuestion
    // ========================

    /**
     * 문제 1개를 Qdrant에 임베딩 적재.
     * 실패해도 문제 등록 흐름에 영향을 주지 않도록 예외를 catch하여 warn 로그만 남긴다.
     */
    public IndexQuestionResult indexQuestion(IndexQuestionRequest request) {
        try {
            return postToPython("/api/ai/index-question", request, IndexQuestionResult.class);
        } catch (Exception e) {
            log.warn("[AiGateway] indexQuestion 실패 (non-critical): questionUuid={}, error={}",
                    request.questionUuid(), e.getMessage());
            return null;
        }
    }

    /**
     * 문제 목록을 Qdrant에 일괄 적재 (관리자 전체 재색인용).
     */
    public IndexQuestionsBulkResult indexQuestionsBulk(IndexQuestionsBulkRequest request) {
        return postToPython("/api/ai/index-questions-bulk", request, IndexQuestionsBulkResult.class);
    }

    // ========================
    //  recommend
    // ========================

    /**
     * 사용자 신호 기반 개인화 문제 추천.
     * Fallback 없음 — 호출부에서 null 결과 시 RANDOM fallback 처리.
     */
    public RecommendResult recommend(RecommendRequest request) {
        try {
            return postToPython("/api/ai/recommend", request, RecommendResult.class);
        } catch (Exception e) {
            log.warn("[AiGateway] recommend 실패 (RANDOM fallback 예정): error={}", e.getMessage());
            return null;
        }
    }

    // ========================
    //  getIndexStatus
    // ========================

    /**
     * DB 전체 문제 UUID vs Qdrant 색인 UUID 비교하여 미색인 목록 반환.
     * 관리자 임베딩 인덱스 관리 화면에서 사용.
     * AI 서버 장애 시 null 반환 — 호출부에서 에러 배너 처리.
     */
    public IndexStatusResult getIndexStatus(IndexStatusRequest request) {
        try {
            log.info("[AiGateway] getIndexStatus 요청: db_uuid_count={}", request.questionUuids().size());
            IndexStatusResult result = postToPython("/api/ai/index-status", request, IndexStatusResult.class);
            log.info("[AiGateway] getIndexStatus 완료: unindexed_count={}", result.unindexedCount());
            return result;
        } catch (Exception e) {
            log.warn("[AiGateway] getIndexStatus 실패 (null 반환): error={}", e.getMessage());
            return null;
        }
    }

    /**
     * 활성 문제 UUID에 없는 Qdrant 포인트(고아 벡터)를 삭제한다 (#412).
     * 정리 실패가 삭제·재색인 흐름을 막지 않도록 null을 반환한다 — 다음 정리 때 다시 지워진다.
     */
    public PruneIndexResult pruneIndex(IndexStatusRequest request) {
        try {
            PruneIndexResult result = postToPython("/api/ai/prune-index", request, PruneIndexResult.class);
            log.info("[AiGateway] pruneIndex 완료: deleted_count={}", result.deletedCount());
            return result;
        } catch (Exception e) {
            log.warn("[AiGateway] pruneIndex 실패 (null 반환): error={}", e.getMessage());
            return null;
        }
    }

    // ========================
    //  상태 확인 (#475, 호출 통계에 넣지 않음)
    // ========================

    /** AI 서버 GET /health (3초 제한) */
    public ComponentHealth checkAiServerHealth() {
        long startedAtMilliseconds = System.currentTimeMillis();
        try {
            ResponseEntity<String> response = healthCheckRestTemplate.getForEntity(baseUrl + HEALTH_PATH, String.class);
            long latency = System.currentTimeMillis() - startedAtMilliseconds;
            return response.getStatusCode().is2xxSuccessful()
                    ? ComponentHealth.up("AI 서버", latency, "GET /health " + response.getStatusCode().value())
                    : ComponentHealth.down("AI 서버", latency, "GET /health " + response.getStatusCode().value());
        } catch (Exception e) {
            return ComponentHealth.down("AI 서버", System.currentTimeMillis() - startedAtMilliseconds, e.getClass().getSimpleName());
        }
    }

    /** Qdrant: AI 서버 index-status(빈 목록) 경유 > 컬렉션 포인트 수 (AI 서버가 Qdrant 를 읽을 수 있어야 성공) */
    public ComponentHealth checkQdrantThroughAiServer() {
        long startedAtMilliseconds = System.currentTimeMillis();
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            if (apiKey != null && !apiKey.isBlank()) {
                headers.set("X-API-Key", apiKey);
            }
            String body = snakeCaseMapper.writeValueAsString(new IndexStatusRequest(List.of()));
            ResponseEntity<String> response = healthCheckRestTemplate.exchange(
                    baseUrl + INDEX_STATUS_PATH, HttpMethod.POST, new HttpEntity<>(body, headers), String.class);
            IndexStatusResult result = snakeCaseMapper.readValue(response.getBody(), IndexStatusResult.class);
            return ComponentHealth.up("Qdrant", System.currentTimeMillis() - startedAtMilliseconds,
                    "포인트 " + result.collectionPointsCount() + "개 (AI 서버 경유)");
        } catch (Exception e) {
            return ComponentHealth.down("Qdrant", System.currentTimeMillis() - startedAtMilliseconds,
                    "AI 서버 경유 조회 실패: " + e.getClass().getSimpleName());
        }
    }

    // ========================
    //  내부 HTTP 처리
    // ========================

    /** AI 서버 POST 1회 + 호출 기록 (성공·실패·지연·모델·토큰, #474, #557) — Python 호출의 유일한 통로 */
    private <T> T postToPython(String path, Object request, Class<T> responseType) {
        long startedAtMilliseconds = System.currentTimeMillis();
        try {
            T response = exchangeWithPython(path, request, responseType);
            recordSuccess(path, System.currentTimeMillis() - startedAtMilliseconds, response);
            return response;
        } catch (RuntimeException e) {
            aiCallLogService.record(toCallSource(path), path, null, false,
                    System.currentTimeMillis() - startedAtMilliseconds, toErrorType(e), null, null);
            throw e;
        }
    }

    /** 성공 기록 (생성 메타데이터가 있는 응답이면 모델·토큰 수 포함, 없으면 null) */
    private void recordSuccess(String path, long latencyMilliseconds, Object response) {
        GenerationMetadataDto metadata = response instanceof GenerationMetadataCarrier carrier ? carrier.metadata() : null;
        if (metadata == null) {
            aiCallLogService.record(toCallSource(path), path, null, true, latencyMilliseconds, null, null, null);
            return;
        }
        aiCallLogService.recordConnectionCall(AiCallSource.AI_SERVER, metadata.connectionName(), path,
                metadata.modelName(), true, latencyMilliseconds, null, metadata.promptTokens(), metadata.completionTokens());
    }

    /** 경로 > 호출 출처 (벡터 색인·검색 경로 > VECTOR_SEARCH, 그 외 LLM > AI_SERVER) */
    private static AiCallSource toCallSource(String path) {
        return VECTOR_SEARCH_PATHS.contains(path) ? AiCallSource.VECTOR_SEARCH : AiCallSource.AI_SERVER;
    }

    /** 실패 종류: CustomException 은 ErrorCode 이름, 그 외는 예외 클래스 이름 */
    private String toErrorType(RuntimeException e) {
        if (e instanceof CustomException customException) {
            return customException.getErrorCode().name();
        }
        return e.getClass().getSimpleName();
    }

    private <T> T exchangeWithPython(String path, Object request, Class<T> responseType) {
        String url = baseUrl + path;
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            if (apiKey != null && !apiKey.isBlank()) {
                headers.set("X-API-Key", apiKey);
            }

            String body = snakeCaseMapper.writeValueAsString(request);
            HttpEntity<String> entity = new HttpEntity<>(body, headers);

            ResponseEntity<String> response = restTemplate.exchange(
                    url, HttpMethod.POST, entity, String.class);

            if (!response.getStatusCode().is2xxSuccessful()) {
                throw new CustomException(ErrorCode.AI_SERVER_UNAVAILABLE,
                        "Python AI 서버 응답 코드: " + response.getStatusCode());
            }

            return snakeCaseMapper.readValue(response.getBody(), responseType);
        } catch (CustomException e) {
            throw e;
        } catch (Exception e) {
            log.error("[AiGateway] Python AI 서버 호출 실패: url={}, error={}", url, e.getMessage());
            throw new CustomException(ErrorCode.AI_SERVER_UNAVAILABLE,
                    "Python AI 서버 호출 실패", e);
        }
    }
}
