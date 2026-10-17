package com.passql.application.service;

import com.passql.ai.client.AiGatewayClient;
import com.passql.ai.dto.TestPromptRequest;
import com.passql.ai.dto.TestPromptResult;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.question.service.PromptLlmConfigFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.UUID;

/**
 * 관리자 프롬프트 테스트: 템플릿 조회 > LLM 설정 변환(응답 스키마 없음) > AI 서버 테스트 호출
 */
@Service
@RequiredArgsConstructor
public class AdminPromptTestService {

    private final PromptService promptService;
    private final AiGatewayClient aiGatewayClient;

    /** 프롬프트 UUID + 치환 변수 > AI 응답 원문·소요 시간 (없는 프롬프트 > PROMPT_NOT_FOUND) */
    public TestPromptResult testPrompt(UUID promptTemplateUuid, Map<String, String> variables) {
        PromptTemplate prompt = promptService.findById(promptTemplateUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.PROMPT_NOT_FOUND));
        TestPromptRequest request = new TestPromptRequest(
                PromptLlmConfigFactory.toLlmConfig(prompt, prompt.getUserTemplate(), null), variables);
        return aiGatewayClient.testPrompt(request);
    }
}
