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
import com.passql.ai.constant.AiProvider;
import com.passql.ai.dto.AiConnectionTarget;
import com.passql.ai.service.AiCallLogService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;

/**
 * Gemini SDK 호출: 연결 키별 클라이언트, 동시 호출 제한, 호출 기록(연결·모델·지연·토큰), 실패 > AiProviderException (#557, #695)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class GeminiClient implements AiProviderClient {

    // 호출 기록 endpointPath (직접 호출 기능 구분)
    static final String CHAT_ENDPOINT_PATH = "gemini:chat";
    static final String CHAT_STRUCTURED_ENDPOINT_PATH = "gemini:chatStructured";
    // 호출 1회 응답 대기 상한 (30초, 넘으면 실패 처리해 요청 스레드를 오래 잡지 않음) (#497)
    private static final int CALL_TIMEOUT_MILLISECONDS = 30_000;
    // 연결 확인 응답 대기 상한 (3초)
    private static final int VERIFY_TIMEOUT_MILLISECONDS = 3_000;
    // 동시 호출 상한 (8건) + 자리 대기 상한 (20초): 몰릴 때 스레드·비용 폭주 방지 (#497)
    private static final int MAX_CONCURRENT_CALLS = 8;
    private static final long CALL_SLOT_WAIT_SECONDS = 20;

    private final AiCallLogService aiCallLogService;
    private final Semaphore concurrentCallSlots = new Semaphore(MAX_CONCURRENT_CALLS, true);
    // API 키 > SDK 클라이언트 (키마다 1개, 키 교체 시 새 키로 새로 만듦)
    private final Map<String, Client> clientByApiKey = new ConcurrentHashMap<>();

    @Override
    public AiProvider provider() {
        return AiProvider.GEMINI;
    }

    @Override
    public String chat(AiConnectionTarget connection, String model, String systemPrompt, String userPrompt,
                       float temperature, int maxTokens) {
        GenerateContentConfig config = GenerateContentConfig.builder()
                .systemInstruction(Content.fromParts(Part.fromText(systemPrompt)))
                .temperature(temperature)
                .maxOutputTokens(maxTokens)
                .build();
        return extractText(generateWithinCallLimit(connection, CHAT_ENDPOINT_PATH, model, userPrompt, config), model);
    }

    @Override
    public String chatStructured(AiConnectionTarget connection, String model, String systemPrompt, String userPrompt,
                                 float temperature, int maxTokens, String responseSchemaJson) {
        GenerateContentConfig config = GenerateContentConfig.builder()
                .systemInstruction(Content.fromParts(Part.fromText(systemPrompt)))
                .temperature(temperature)
                .maxOutputTokens(maxTokens)
                .responseMimeType("application/json")
                .responseSchema(Schema.fromJson(responseSchemaJson))
                .build();
        return extractText(generateWithinCallLimit(connection, CHAT_STRUCTURED_ENDPOINT_PATH, model, userPrompt, config), model);
    }

    /** 모델 조회 (models.get, 과금 없음, 3초 제한) */
    @Override
    public void verifyConnection(String apiKey, String model) {
        try {
            GetModelConfig config = GetModelConfig.builder()
                    .httpOptions(HttpOptions.builder().timeout(VERIFY_TIMEOUT_MILLISECONDS).build())
                    .build();
            resolveClient(apiKey).models.get(model, config);
        } catch (RuntimeException e) {
            throw toProviderException(e);
        }
    }

    private Client resolveClient(String apiKey) {
        return clientByApiKey.computeIfAbsent(apiKey, key -> Client.builder()
                .apiKey(key)
                .httpOptions(HttpOptions.builder().timeout(CALL_TIMEOUT_MILLISECONDS).build())
                .build());
    }

    /** 동시 호출 자리 확보 > 호출 > 기록 > 자리 반환 (성공·실패 공통, 자리 부족은 응답 없음 실패) */
    private GenerateContentResponse generateWithinCallLimit(AiConnectionTarget connection, String endpointPath, String model,
                                                            String userPrompt, GenerateContentConfig config) {
        long startedAtMilliseconds = System.currentTimeMillis();
        if (!tryAcquireCallSlot()) {
            log.warn("[gemini client] rejected : no call slot within {}s (limit={})", CALL_SLOT_WAIT_SECONDS, MAX_CONCURRENT_CALLS);
            AiProviderException exception = new AiProviderException(provider(), null, "no call slot", null);
            recordFailure(connection, endpointPath, model, startedAtMilliseconds, exception);
            throw exception;
        }
        try {
            GenerateContentResponse response = resolveClient(connection.apiKey()).models.generateContent(model, userPrompt, config);
            recordSuccess(connection, endpointPath, model, startedAtMilliseconds, response);
            return response;
        } catch (RuntimeException e) {
            AiProviderException exception = toProviderException(e);
            recordFailure(connection, endpointPath, model, startedAtMilliseconds, exception);
            throw exception;
        } finally {
            concurrentCallSlots.release();
        }
    }

    private boolean tryAcquireCallSlot() {
        try {
            return concurrentCallSlots.tryAcquire(CALL_SLOT_WAIT_SECONDS, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return false;
        }
    }

    /** SDK 예외 > 공통 예외 (ApiException 은 상태 코드 보존, 그 외 응답 없음) */
    private AiProviderException toProviderException(RuntimeException e) {
        if (e instanceof AiProviderException providerException) {
            return providerException;
        }
        if (e instanceof ApiException apiException) {
            return new AiProviderException(provider(), apiException.code(), apiException.getMessage(), e);
        }
        return new AiProviderException(provider(), null, null, e);
    }

    /** 성공 기록: 입력 = promptTokenCount, 출력 = candidatesTokenCount + thoughtsTokenCount (thinking 은 출력 단가) */
    private void recordSuccess(AiConnectionTarget connection, String endpointPath, String model, long startedAtMilliseconds,
                               GenerateContentResponse response) {
        Optional<GenerateContentResponseUsageMetadata> usageMetadata = response.usageMetadata();
        Integer promptTokenCount = usageMetadata.flatMap(GenerateContentResponseUsageMetadata::promptTokenCount).orElse(null);
        Integer completionTokenCount = usageMetadata.map(GeminiClient::sumCompletionTokenCount).orElse(null);
        aiCallLogService.recordConnectionCall(AiCallSource.GEMINI_DIRECT, connection.connectionName(), endpointPath, model,
                true, System.currentTimeMillis() - startedAtMilliseconds, null, promptTokenCount, completionTokenCount);
    }

    private void recordFailure(AiConnectionTarget connection, String endpointPath, String model, long startedAtMilliseconds,
                               AiProviderException exception) {
        aiCallLogService.recordConnectionCall(AiCallSource.GEMINI_DIRECT, connection.connectionName(), endpointPath, model,
                false, System.currentTimeMillis() - startedAtMilliseconds, exception.toErrorType(), null, null);
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

    private static String extractText(GenerateContentResponse response, String model) {
        String text = response.text();
        if (text == null || text.isBlank()) {
            throw new IllegalStateException("Gemini returned empty response for model: " + model);
        }
        return text;
    }
}
