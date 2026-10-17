package com.passql.question.service;

import com.passql.ai.dto.LlmConfigDto;
import com.passql.meta.entity.PromptTemplate;

import java.util.Map;

/**
 * 프롬프트 템플릿 > AI 서버 LLM 설정 변환 공통 지점
 * 모델·시스템 프롬프트·온도·최대 토큰은 템플릿 값 그대로, user 템플릿·응답 스키마는 호출부 지정
 */
public final class PromptLlmConfigFactory {

    private PromptLlmConfigFactory() {
    }

    /** 템플릿 + user 템플릿(조립본 또는 원문) + 응답 스키마(null 이면 자유 형식) > LLM 설정 */
    public static LlmConfigDto toLlmConfig(PromptTemplate prompt, String userTemplate, Map<String, Object> responseSchema) {
        return new LlmConfigDto(
                prompt.getModel(),
                prompt.getSystemPrompt(),
                userTemplate,
                prompt.getTemperature(),
                prompt.getMaxTokens(),
                responseSchema
        );
    }
}
