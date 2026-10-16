package com.passql.ai.client;

import com.google.genai.Client;
import com.google.genai.types.Content;
import com.google.genai.types.GenerateContentConfig;
import com.google.genai.types.GenerateContentResponse;
import com.google.genai.types.Part;
import com.google.genai.types.Schema;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.concurrent.atomic.AtomicLong;

@Slf4j
@Component
public class GeminiClient {

    private final AppSettingService appSettingService;
    private final String defaultModel;

    // 마지막으로 만든 클라이언트와 그때의 키 (키가 바뀌었을 때만 재생성)
    private volatile CachedClient cachedClient;

    private record CachedClient(String apiKey, Client client) {
    }

    /** 서버 기동 이후 Gemini API 호출 횟수 (인메모리 누적) */
    private final AtomicLong callCount = new AtomicLong(0);

    public GeminiClient(
            AppSettingService appSettingService,
            @Value("${gemini.model}") String defaultModel
    ) {
        this.appSettingService = appSettingService;
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
                current = new CachedClient(apiKey, Client.builder().apiKey(apiKey).build());
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

        GenerateContentResponse response = resolveClient().models.generateContent(model, userPrompt, config);
        return extractText(response, model);
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

        GenerateContentResponse response = resolveClient().models.generateContent(model, userPrompt, config);
        return extractText(response, model);
    }

    private String extractText(GenerateContentResponse response, String model) {
        String text = response.text();
        if (text == null || text.isBlank()) {
            throw new IllegalStateException("Gemini returned empty response for model: " + model);
        }
        return text;
    }
}
