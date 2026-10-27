package com.passql.ai.client;

import com.passql.ai.constant.AiProvider;
import com.passql.ai.dto.AiCallAttempt;
import com.passql.ai.dto.AiConnectionTarget;
import com.passql.ai.service.AiConnectionRegistry;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;

/**
 * Spring 직접 LLM 호출 단일 진입점: 시도 순서 계산 > 연결별 호출 > 한도·키·서버 오류면 다음 연결 (#688, #695)
 * 시도 순서·대체 판정은 AiCallAttemptPlanner·AiFallbackPolicy (AI 서버 llm_client.py 와 같은 규칙)
 */
@Slf4j
@Component
public class AiChatClient {

    private final AiConnectionRegistry aiConnectionRegistry;
    private final Map<AiProvider, AiProviderClient> providerClientByProvider = new EnumMap<>(AiProvider.class);

    public AiChatClient(AiConnectionRegistry aiConnectionRegistry, List<AiProviderClient> providerClients) {
        this.aiConnectionRegistry = aiConnectionRegistry;
        providerClients.forEach(providerClient -> providerClientByProvider.put(providerClient.provider(), providerClient));
    }

    /** 일반 텍스트 응답 */
    public String chat(String promptModel, String systemPrompt, String userPrompt, float temperature, int maxTokens) {
        return callWithFallback(promptModel, (providerClient, attempt) -> providerClient.chat(
                attempt.connection(), attempt.model(), systemPrompt, userPrompt, temperature, maxTokens));
    }

    /** JSON 강제 응답 (응답 스키마 = Gemini 형식 JSON 문자열) */
    public String chatStructured(String promptModel, String systemPrompt, String userPrompt, float temperature,
                                 int maxTokens, String responseSchemaJson) {
        return callWithFallback(promptModel, (providerClient, attempt) -> providerClient.chatStructured(
                attempt.connection(), attempt.model(), systemPrompt, userPrompt, temperature, maxTokens, responseSchemaJson));
    }

    @FunctionalInterface
    private interface ProviderCall {
        String call(AiProviderClient providerClient, AiCallAttempt attempt);
    }

    /** 시도 순서대로 호출 > 성공 시 반환, 대체 대상 오류면 다음, 그 외 오류는 즉시 전파, 모두 실패면 AI_UNAVAILABLE */
    private String callWithFallback(String promptModel, ProviderCall providerCall) {
        List<AiCallAttempt> attempts = AiCallAttemptPlanner.planAttempts(promptModel, aiConnectionRegistry.findCallTargets());
        if (attempts.isEmpty()) {
            log.error("[ai fallback] rejected : no enabled ai connection");
            throw new CustomException(ErrorCode.AI_UNAVAILABLE);
        }
        for (int attemptIndex = 0; attemptIndex < attempts.size(); attemptIndex++) {
            AiCallAttempt attempt = attempts.get(attemptIndex);
            AiConnectionTarget connection = attempt.connection();
            try {
                String result = providerCall.call(providerClientByProvider.get(connection.provider()), attempt);
                aiConnectionRegistry.recordSuccess(connection.aiConnectionUuid());
                return result;
            } catch (AiProviderException e) {
                aiConnectionRegistry.recordFailure(connection.aiConnectionUuid(), e.toErrorType());
                if (!AiFallbackPolicy.shouldTryNextConnection(e)) {
                    log.error("[ai fallback] failed without retry : connection={}, model={}, error={}",
                            connection.connectionName(), attempt.model(), e.toErrorType());
                    throw e;
                }
                log.warn("[ai fallback] next connection : failed={}, model={}, error={}, remaining={}",
                        connection.connectionName(), attempt.model(), e.toErrorType(), attempts.size() - attemptIndex - 1);
            }
        }
        log.error("[ai fallback] all connections failed : attempts={}", attempts.size());
        throw new CustomException(ErrorCode.AI_UNAVAILABLE);
    }
}
