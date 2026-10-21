package com.passql.ai.client;

import com.google.genai.Client;
import com.google.genai.errors.ApiException;
import com.google.genai.types.Content;
import com.google.genai.types.GenerateContentConfig;
import com.google.genai.types.GenerateContentResponse;
import com.google.genai.types.GenerateContentResponseUsageMetadata;
import com.google.genai.types.GetModelConfig;
import com.google.genai.types.HttpOptions;
import com.google.genai.types.Part;
import com.google.genai.types.Schema;
import com.passql.ai.constant.AiCallSource;
import com.passql.ai.dto.GeminiApiKeyHealth;
import com.passql.ai.service.AiCallLogService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Spring 직접 Gemini 호출: 최신 키 클라이언트, 동시 호출 제한, 호출 기록(모델·지연·토큰, #557), 키 유효성 확인
 */
@Slf4j
@Component
public class GeminiClient {

    // 호출 기록 endpointPath (직접 호출 기능 구분)
    static final String CHAT_ENDPOINT_PATH = "gemini:chat";
    static final String CHAT_STRUCTURED_ENDPOINT_PATH = "gemini:chatStructured";
    // 호출 기록 errorType: 429 한도 초과, 401·403 키 무효·권한·결제 문제
    static final String QUOTA_EXCEEDED_ERROR_TYPE = "GEMINI_QUOTA_EXCEEDED";
    static final String PERMISSION_DENIED_ERROR_TYPE = "GEMINI_PERMISSION_DENIED";
    private static final int QUOTA_EXCEEDED_STATUS_CODE = 429;
    private static final int UNAUTHORIZED_STATUS_CODE = 401;
    private static final int FORBIDDEN_STATUS_CODE = 403;

    // 키 유효성 확인 캐시 (5분) + 응답 대기 상한 (3초, 모니터링 화면이 묶이지 않게)
    private static final long API_KEY_HEALTH_CACHE_MINUTES = 5;
    private static final int API_KEY_HEALTH_TIMEOUT_MILLISECONDS = 3000;

    private final AppSettingService appSettingService;
    private final AiCallLogService aiCallLogService;
    private final String defaultModel;

    // 마지막 키 유효성 확인 결과 (5분 지나면 다시 확인)
    private volatile GeminiApiKeyHealth cachedApiKeyHealth;
    private final Object apiKeyHealthLock = new Object();

    // 마지막으로 만든 클라이언트와 그때의 키 (키가 바뀌었을 때만 재생성)
    private volatile CachedClient cachedClient;

    private record CachedClient(String apiKey, Client client) {
    }

    /** 서버 기동 이후 Gemini API 호출 횟수 (인메모리 누적) */
    private final AtomicLong callCount = new AtomicLong(0);

    // 호출 1회 응답 대기 상한 (30초, 넘으면 실패 처리해 요청 스레드를 오래 잡지 않음) (#497)
    private static final int CALL_TIMEOUT_MILLISECONDS = 30_000;
    // 동시 호출 상한 (8건) + 자리 대기 상한 (20초): 몰릴 때 스레드·비용 폭주 방지 (#497)
    private static final int MAX_CONCURRENT_CALLS = 8;
    private static final long CALL_SLOT_WAIT_SECONDS = 20;
    private final Semaphore concurrentCallSlots = new Semaphore(MAX_CONCURRENT_CALLS, true);

    public GeminiClient(
            AppSettingService appSettingService,
            AiCallLogService aiCallLogService,
            @Value("${gemini.model}") String defaultModel
    ) {
        this.appSettingService = appSettingService;
        this.aiCallLogService = aiCallLogService;
        this.defaultModel = defaultModel;
    }

    /**
     * 호출 시점의 최신 키로 클라이언트 반환 (관리자 화면 키 변경이 재배포 없이 반영)
     */
    Client resolveClient() {
        String apiKey = appSettingService.getSecret(AppSettingKeys.AI_GEMINI_API_KEY);
        if (apiKey == null || apiKey.isBlank()) {
            log.error("[gemini client] rejected : api key not configured");
            throw new CustomException(ErrorCode.AI_UNAVAILABLE);
        }
        CachedClient current = cachedClient;
        if (current != null && current.apiKey().equals(apiKey)) {
            return current.client();
        }
        synchronized (this) {
            current = cachedClient;
            if (current == null || !current.apiKey().equals(apiKey)) {
                log.info("[gemini client] rebuilt : api key changed");
                current = new CachedClient(apiKey, Client.builder()
                        .apiKey(apiKey)
                        .httpOptions(HttpOptions.builder().timeout(CALL_TIMEOUT_MILLISECONDS).build())
                        .build());
                cachedClient = current;
            }
            return current.client();
        }
    }

    /**
     * 일반 텍스트 응답
     */
    public String chat(String systemPrompt, String userPrompt, float temperature, int maxTokens) {
        return chat(defaultModel, systemPrompt, userPrompt, temperature, maxTokens);
    }

    /** 서버 기동 이후 누적 호출 횟수 반환 */
    public long getCallCount() {
        return callCount.get();
    }

    /**
     * 일반 텍스트 응답 (모델 명시)
     */
    public String chat(String model, String systemPrompt, String userPrompt, float temperature, int maxTokens) {
        log.debug("Gemini chat: model={}, maxTokens={}", model, maxTokens);
        callCount.incrementAndGet();

        GenerateContentConfig config = GenerateContentConfig.builder()
                .systemInstruction(Content.fromParts(Part.fromText(systemPrompt)))
                .temperature(temperature)
                .maxOutputTokens(maxTokens)
                .build();

        return extractText(generateWithinCallLimit(CHAT_ENDPOINT_PATH, model, userPrompt, config), model);
    }

    /**
     * JSON 강제 응답 (responseSchema 지정)
     */
    public String chatStructured(String systemPrompt, String userPrompt, float temperature, int maxTokens, Schema responseSchema) {
        return chatStructured(defaultModel, systemPrompt, userPrompt, temperature, maxTokens, responseSchema);
    }

    /**
     * JSON 강제 응답 (모델 명시 + responseSchema 지정)
     */
    public String chatStructured(String model, String systemPrompt, String userPrompt, float temperature, int maxTokens, Schema responseSchema) {
        log.debug("Gemini chatStructured: model={}, maxTokens={}", model, maxTokens);
        callCount.incrementAndGet();

        GenerateContentConfig config = GenerateContentConfig.builder()
                .systemInstruction(Content.fromParts(Part.fromText(systemPrompt)))
                .temperature(temperature)
                .maxOutputTokens(maxTokens)
                .responseMimeType("application/json")
                .responseSchema(responseSchema)
                .build();

        return extractText(generateWithinCallLimit(CHAT_STRUCTURED_ENDPOINT_PATH, model, userPrompt, config), model);
    }

    /** 동시 호출 자리 확보 > 호출 > 기록 > 자리 반환 (성공·실패 공통, 자리 부족도 실패로 기록) */
    private GenerateContentResponse generateWithinCallLimit(String endpointPath, String model, String userPrompt,
                                                            GenerateContentConfig config) {
        long startedAtMilliseconds = System.currentTimeMillis();
        boolean hasSlot;
        try {
            hasSlot = concurrentCallSlots.tryAcquire(CALL_SLOT_WAIT_SECONDS, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            recordFailure(endpointPath, model, startedAtMilliseconds, ErrorCode.AI_UNAVAILABLE.name());
            throw new CustomException(ErrorCode.AI_UNAVAILABLE);
        }
        if (!hasSlot) {
            log.warn("[gemini client] rejected : no call slot within {}s (limit={})", CALL_SLOT_WAIT_SECONDS, MAX_CONCURRENT_CALLS);
            recordFailure(endpointPath, model, startedAtMilliseconds, ErrorCode.AI_UNAVAILABLE.name());
            throw new CustomException(ErrorCode.AI_UNAVAILABLE);
        }
        try {
            GenerateContentResponse response = resolveClient().models.generateContent(model, userPrompt, config);
            recordSuccess(endpointPath, model, startedAtMilliseconds, response);
            return response;
        } catch (RuntimeException e) {
            recordFailure(endpointPath, model, startedAtMilliseconds, toErrorType(e));
            throw e;
        } finally {
            concurrentCallSlots.release();
        }
    }

    /** 성공 기록: 입력 = promptTokenCount, 출력 = candidatesTokenCount + thoughtsTokenCount (thinking 은 출력 단가) */
    private void recordSuccess(String endpointPath, String model, long startedAtMilliseconds,
                               GenerateContentResponse response) {
        Optional<GenerateContentResponseUsageMetadata> usageMetadata = response.usageMetadata();
        Integer promptTokenCount = usageMetadata.flatMap(GenerateContentResponseUsageMetadata::promptTokenCount).orElse(null);
        Integer completionTokenCount = usageMetadata.map(GeminiClient::sumCompletionTokenCount).orElse(null);
        aiCallLogService.record(AiCallSource.GEMINI_DIRECT, endpointPath, model, true,
                System.currentTimeMillis() - startedAtMilliseconds, null, promptTokenCount, completionTokenCount);
    }

    private void recordFailure(String endpointPath, String model, long startedAtMilliseconds, String errorType) {
        aiCallLogService.record(AiCallSource.GEMINI_DIRECT, endpointPath, model, false,
                System.currentTimeMillis() - startedAtMilliseconds, errorType, null, null);
    }

    // 출력 토큰 합계 (두 값 모두 없으면 null)
    private static Integer sumCompletionTokenCount(GenerateContentResponseUsageMetadata usageMetadata) {
        Optional<Integer> candidatesTokenCount = usageMetadata.candidatesTokenCount();
        Optional<Integer> thoughtsTokenCount = usageMetadata.thoughtsTokenCount();
        if (candidatesTokenCount.isEmpty() && thoughtsTokenCount.isEmpty()) {
            return null;
        }
        return candidatesTokenCount.orElse(0) + thoughtsTokenCount.orElse(0);
    }

    /** 실패 종류: Gemini 429 > GEMINI_QUOTA_EXCEEDED, 401·403 > GEMINI_PERMISSION_DENIED, CustomException 은 ErrorCode 이름, 그 외 예외 클래스 이름 */
    static String toErrorType(RuntimeException e) {
        if (e instanceof ApiException apiException) {
            if (apiException.code() == QUOTA_EXCEEDED_STATUS_CODE) {
                return QUOTA_EXCEEDED_ERROR_TYPE;
            }
            if (apiException.code() == UNAUTHORIZED_STATUS_CODE || apiException.code() == FORBIDDEN_STATUS_CODE) {
                return PERMISSION_DENIED_ERROR_TYPE;
            }
        }
        if (e instanceof CustomException customException) {
            return customException.getErrorCode().name();
        }
        return e.getClass().getSimpleName();
    }

    // ========================
    //  키 유효성 확인 (#557, 호출 기록·호출 수에 넣지 않음)
    // ========================

    /** Gemini API 키 유효성 (기본 모델 models.get 무료 호출, 5분 캐시) */
    public GeminiApiKeyHealth checkApiKeyHealth() {
        GeminiApiKeyHealth cached = cachedApiKeyHealth;
        if (isApiKeyHealthFresh(cached)) {
            return cached;
        }
        synchronized (apiKeyHealthLock) {
            cached = cachedApiKeyHealth;
            if (!isApiKeyHealthFresh(cached)) {
                cached = requestApiKeyHealth();
                cachedApiKeyHealth = cached;
            }
            return cached;
        }
    }

    private static boolean isApiKeyHealthFresh(GeminiApiKeyHealth health) {
        return health != null
                && health.checkedAt().isAfter(LocalDateTime.now().minusMinutes(API_KEY_HEALTH_CACHE_MINUTES));
    }

    /** models.get 1회 (3초 제한) > 결과 (실패 원인: 키 미설정 / 429 / 401·403 / 그 외) */
    private GeminiApiKeyHealth requestApiKeyHealth() {
        long startedAtMilliseconds = System.currentTimeMillis();
        try {
            GetModelConfig config = GetModelConfig.builder()
                    .httpOptions(HttpOptions.builder().timeout(API_KEY_HEALTH_TIMEOUT_MILLISECONDS).build())
                    .build();
            resolveClient().models.get(defaultModel, config);
            return new GeminiApiKeyHealth(true, System.currentTimeMillis() - startedAtMilliseconds,
                    "키 유효 (models.get " + defaultModel + ")", LocalDateTime.now());
        } catch (Exception e) {
            log.warn("[gemini client] api key health down : {}", e.getClass().getSimpleName());
            return new GeminiApiKeyHealth(false, System.currentTimeMillis() - startedAtMilliseconds,
                    toApiKeyHealthFailureDetail(e), LocalDateTime.now());
        }
    }

    // 실패 원인 문구 (예외 원문은 넣지 않음)
    private static String toApiKeyHealthFailureDetail(Exception e) {
        if (e instanceof CustomException) {
            return "API 키 미설정";
        }
        if (e instanceof ApiException apiException) {
            int statusCode = apiException.code();
            if (statusCode == QUOTA_EXCEEDED_STATUS_CODE) {
                return "한도 초과 (429)";
            }
            if (statusCode == UNAUTHORIZED_STATUS_CODE || statusCode == FORBIDDEN_STATUS_CODE) {
                return "키 무효·권한·결제 확인 필요 (" + statusCode + ")";
            }
            return "응답 오류 (" + statusCode + ")";
        }
        return "확인 실패: " + e.getClass().getSimpleName();
    }

    private String extractText(GenerateContentResponse response, String model) {
        String text = response.text();
        if (text == null || text.isBlank()) {
            throw new IllegalStateException("Gemini returned empty response for model: " + model);
        }
        return text;
    }
}
