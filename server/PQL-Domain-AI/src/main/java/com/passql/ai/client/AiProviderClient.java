package com.passql.ai.client;

import com.passql.ai.constant.AiProvider;
import com.passql.ai.dto.AiConnectionTarget;

/**
 * 제공자별 LLM 클라이언트 공통 모양 (#695): 실패는 AiProviderException 으로 통일
 */
public interface AiProviderClient {

    AiProvider provider();

    /** 일반 텍스트 응답 */
    String chat(AiConnectionTarget connection, String model, String systemPrompt, String userPrompt,
                float temperature, int maxTokens);

    /** JSON 강제 응답 (응답 스키마 = Gemini 형식 JSON 문자열) > JSON 문자열 */
    String chatStructured(AiConnectionTarget connection, String model, String systemPrompt, String userPrompt,
                          float temperature, int maxTokens, String responseSchemaJson);

    /** 키·모델 확인 (무료 모델 조회 1회, 실패 > AiProviderException) */
    void verifyConnection(String apiKey, String model);
}
