package com.passql.ai.client;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyFloat;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 제공자 선택(모델 이름 접두사)·관리자 일괄 모델·Gemini 스키마 > JSON Schema 변환 (#688)
 */
class AiChatClientTest {

    private final GeminiClient geminiClient = mock(GeminiClient.class);
    private final ClaudeClient claudeClient = mock(ClaudeClient.class);
    private final AppSettingService appSettingService = mock(AppSettingService.class);
    private final AiChatClient aiChatClient = new AiChatClient(geminiClient, claudeClient, appSettingService);

    @Test
    void 일괄_모델이_비면_프롬프트_모델로_Gemini_호출() {
        when(appSettingService.getString(AppSettingKeys.AI_MODEL_OVERRIDE)).thenReturn("");

        aiChatClient.chat("gemini-2.5-flash-lite", "system", "user", 0.3f, 512);

        verify(geminiClient).chat("gemini-2.5-flash-lite", "system", "user", 0.3f, 512);
        verify(claudeClient, never()).chat(anyString(), anyString(), anyString(), anyFloat(), anyInt());
    }

    @Test
    void 일괄_모델이_claude면_프롬프트_모델과_무관하게_Claude_호출() {
        when(appSettingService.getString(AppSettingKeys.AI_MODEL_OVERRIDE)).thenReturn(" claude-haiku-5-5 ");

        aiChatClient.chat("gemini-2.5-flash-lite", "system", "user", 0.3f, 512);

        verify(claudeClient).chat("claude-haiku-5-5", "system", "user", 0.3f, 512);
        verify(geminiClient, never()).chat(anyString(), anyString(), anyString(), anyFloat(), anyInt());
    }

    @Test
    void 일괄_모델_읽기_실패면_프롬프트_모델_사용() {
        when(appSettingService.getString(AppSettingKeys.AI_MODEL_OVERRIDE)).thenThrow(new IllegalStateException());

        assertThat(aiChatClient.resolveModel("claude-sonnet-5-5")).isEqualTo("claude-sonnet-5-5");
    }

    @Test
    void Gemini_스키마를_JSON_Schema로_변환() throws Exception {
        ObjectMapper objectMapper = new ObjectMapper();
        String geminiSchema = """
                {"type":"OBJECT","propertyOrdering":["stem"],
                 "properties":{"stem":{"type":"STRING"},"hint":{"type":"STRING","nullable":true},
                   "choices":{"type":"ARRAY","minItems":1,"items":{"type":"OBJECT","properties":{"key":{"type":"STRING"}}}}},
                 "required":["stem"]}
                """;
        String expectedJsonSchema = """
                {"type":"object",
                 "properties":{"stem":{"type":"string"},"hint":{"type":["string","null"]},
                   "choices":{"type":"array","minItems":1,"items":{"type":"object","properties":{"key":{"type":"string"}}}}},
                 "required":["stem"]}
                """;

        assertThat(ClaudeClient.toJsonSchema(objectMapper.readTree(geminiSchema)))
                .isEqualTo(objectMapper.readTree(expectedJsonSchema));
    }
}
