package com.passql.ai.client;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.constant.AiProvider;
import com.passql.ai.dto.AiCallAttempt;
import com.passql.ai.dto.AiConnectionTarget;
import com.passql.ai.service.AiConnectionRegistry;
import com.passql.common.exception.CustomException;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyFloat;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * AI 연결 시도 순서·대체 판정·대체 호출 (#695, AI 서버 test_llm_client.py 와 같은 규칙)
 */
class AiChatClientTest {

    private static final AiConnectionTarget CLAUDE_PRO = target("claude-pro", AiProvider.CLAUDE, "claude-haiku-5-5");
    private static final AiConnectionTarget CLAUDE_DEV = target("claude-dev", AiProvider.CLAUDE, "claude-haiku-5-5");
    private static final AiConnectionTarget GEMINI = target("gemini", AiProvider.GEMINI, "gemini-2.5-flash-lite");

    private final AiConnectionRegistry aiConnectionRegistry = mock(AiConnectionRegistry.class);
    private final AiProviderClient claudeClient = providerClient(AiProvider.CLAUDE);
    private final AiProviderClient geminiClient = providerClient(AiProvider.GEMINI);
    private final AiChatClient aiChatClient = new AiChatClient(aiConnectionRegistry, List.of(claudeClient, geminiClient));

    @Test
    void 모델_접두사로_제공자_판정() {
        assertThat(AiProvider.fromModelName(" Claude-sonnet-5-5")).contains(AiProvider.CLAUDE);
        assertThat(AiProvider.fromModelName("gemini-2.5-flash-lite")).contains(AiProvider.GEMINI);
        assertThat(AiProvider.fromModelName("gpt-5-mini")).contains(AiProvider.OPENAI);
        assertThat(AiProvider.fromModelName("o4-mini")).contains(AiProvider.OPENAI);
        assertThat(AiProvider.fromModelName("llama3")).isEmpty();
        assertThat(AiProvider.fromModelName("")).isEmpty();
    }

    @Test
    void 프롬프트_모델_제공자_연결을_먼저_그_모델로_시도() {
        List<AiCallAttempt> attempts = AiCallAttemptPlanner.planAttempts("gemini-2.5-flash",
                List.of(CLAUDE_PRO, GEMINI, CLAUDE_DEV));

        assertThat(attempts).extracting(attempt -> attempt.connection().connectionName() + ":" + attempt.model())
                .containsExactly("gemini:gemini-2.5-flash", "claude-pro:claude-haiku-5-5", "claude-dev:claude-haiku-5-5");
    }

    @Test
    void 프롬프트_모델_제공자_연결이_없으면_우선순위대로_기본_모델() {
        List<AiCallAttempt> attempts = AiCallAttemptPlanner.planAttempts("gpt-5-mini", List.of(CLAUDE_PRO, GEMINI));

        assertThat(attempts).extracting(attempt -> attempt.connection().connectionName() + ":" + attempt.model())
                .containsExactly("claude-pro:claude-haiku-5-5", "gemini:gemini-2.5-flash-lite");
    }

    @Test
    void 한도_키_서버_오류는_다음_연결_요청_오류는_즉시_실패() {
        assertThat(AiFallbackPolicy.shouldTryNextConnection(failure(429, ""))).isTrue();
        assertThat(AiFallbackPolicy.shouldTryNextConnection(failure(401, ""))).isTrue();
        assertThat(AiFallbackPolicy.shouldTryNextConnection(failure(503, ""))).isTrue();
        assertThat(AiFallbackPolicy.shouldTryNextConnection(failure(null, null))).isTrue();
        assertThat(AiFallbackPolicy.shouldTryNextConnection(
                failure(400, "{\"error\":{\"message\":\"Your credit balance is too low\"}}"))).isTrue();
        assertThat(AiFallbackPolicy.shouldTryNextConnection(
                failure(400, "API key not valid. Please pass a valid API key. [API_KEY_INVALID]"))).isTrue();
        assertThat(AiFallbackPolicy.shouldTryNextConnection(failure(400, "messages.0: content empty"))).isFalse();
    }

    @Test
    void 첫_연결이_한도_초과면_다음_연결로_응답() {
        when(aiConnectionRegistry.findCallTargets()).thenReturn(List.of(CLAUDE_PRO, GEMINI));
        when(claudeClient.chat(eq(CLAUDE_PRO), anyString(), anyString(), anyString(), anyFloat(), anyInt()))
                .thenThrow(failure(429, "rate limit"));
        when(geminiClient.chat(eq(GEMINI), anyString(), anyString(), anyString(), anyFloat(), anyInt()))
                .thenReturn("gemini answer");

        assertThat(aiChatClient.chat("claude-haiku-5-5", "system", "user", 0.3f, 512)).isEqualTo("gemini answer");
        verify(aiConnectionRegistry).recordFailure(CLAUDE_PRO.aiConnectionUuid(), "CLAUDE_429");
        verify(aiConnectionRegistry).recordSuccess(GEMINI.aiConnectionUuid());
    }

    @Test
    void 요청_오류면_다음_연결을_시도하지_않음() {
        when(aiConnectionRegistry.findCallTargets()).thenReturn(List.of(CLAUDE_PRO, GEMINI));
        when(claudeClient.chat(eq(CLAUDE_PRO), anyString(), anyString(), anyString(), anyFloat(), anyInt()))
                .thenThrow(failure(400, "invalid request"));

        assertThatThrownBy(() -> aiChatClient.chat("claude-haiku-5-5", "system", "user", 0.3f, 512))
                .isInstanceOf(AiProviderException.class);
        verify(geminiClient, never()).chat(any(), anyString(), anyString(), anyString(), anyFloat(), anyInt());
    }

    @Test
    void 연결이_없으면_AI_사용_불가() {
        when(aiConnectionRegistry.findCallTargets()).thenReturn(List.of());

        assertThatThrownBy(() -> aiChatClient.chat("claude-haiku-5-5", "system", "user", 0.3f, 512))
                .isInstanceOf(CustomException.class);
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

        assertThat(AiResponseSchemaConverter.toJsonSchema(geminiSchema)).isEqualTo(objectMapper.readTree(expectedJsonSchema));
    }

    private static AiConnectionTarget target(String connectionName, AiProvider provider, String defaultModel) {
        return new AiConnectionTarget(UUID.randomUUID(), connectionName, provider, "key-" + connectionName, defaultModel);
    }

    private static AiProviderException failure(Integer statusCode, String responseBody) {
        return new AiProviderException(AiProvider.CLAUDE, statusCode, responseBody, null);
    }

    private static AiProviderClient providerClient(AiProvider provider) {
        AiProviderClient providerClient = mock(AiProviderClient.class);
        when(providerClient.provider()).thenReturn(provider);
        return providerClient;
    }
}
