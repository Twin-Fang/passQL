package com.passql.ai.client;

import com.google.genai.types.Schema;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Locale;

/**
 * Spring 직접 LLM 호출 단일 진입점: 관리자 일괄 모델 적용 > 모델 이름으로 제공자 선택 (#688)
 * 규칙: claude-* > ClaudeClient, 그 외 > GeminiClient (AI 서버 llm_client.py 와 같은 규칙)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AiChatClient {

    // 이 접두사로 시작하는 모델은 Claude 로 보냄
    static final String CLAUDE_MODEL_PREFIX = "claude-";

    private final GeminiClient geminiClient;
    private final ClaudeClient claudeClient;
    private final AppSettingService appSettingService;

    public static boolean isClaudeModel(String model) {
        return model != null && model.strip().toLowerCase(Locale.ROOT).startsWith(CLAUDE_MODEL_PREFIX);
    }

    /** 관리자 일괄 모델(ai.model_override)이 있으면 그 값, 없거나 읽기 실패면 프롬프트 모델 */
    public String resolveModel(String promptModel) {
        try {
            String overrideModel = appSettingService.getString(AppSettingKeys.AI_MODEL_OVERRIDE);
            if (overrideModel != null && !overrideModel.isBlank()) {
                return overrideModel.strip();
            }
        } catch (RuntimeException e) {
            log.warn("[ai chat] model override read failed, prompt model used : {}", e.getClass().getSimpleName());
        }
        return promptModel;
    }

    /** 일반 텍스트 응답 */
    public String chat(String promptModel, String systemPrompt, String userPrompt, float temperature, int maxTokens) {
        String model = resolveModel(promptModel);
        return isClaudeModel(model)
                ? claudeClient.chat(model, systemPrompt, userPrompt, temperature, maxTokens)
                : geminiClient.chat(model, systemPrompt, userPrompt, temperature, maxTokens);
    }

    /** JSON 강제 응답 (응답 스키마 = Gemini 형식 JSON 문자열) */
    public String chatStructured(String promptModel, String systemPrompt, String userPrompt, float temperature,
                                 int maxTokens, String responseSchemaJson) {
        String model = resolveModel(promptModel);
        return isClaudeModel(model)
                ? claudeClient.chatStructured(model, systemPrompt, userPrompt, temperature, maxTokens, responseSchemaJson)
                : geminiClient.chatStructured(model, systemPrompt, userPrompt, temperature, maxTokens,
                        Schema.fromJson(responseSchemaJson));
    }
}
