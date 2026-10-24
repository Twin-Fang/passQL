package com.passql.application.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.client.AiGatewayClient;
import com.passql.ai.dto.TestPromptRequest;
import com.passql.ai.dto.TestPromptResult;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.question.service.PromptLlmConfigFactory;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.UUID;

/**
 * 관리자 프롬프트 테스트: 템플릿 조회 > LLM 설정 변환(응답 스키마 없음) > AI 서버 테스트 호출 > 결과 이력 저장
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminPromptTestService {

    private final PromptService promptService;
    private final AiGatewayClient aiGatewayClient;
    private final ObjectMapper objectMapper;

    /** 프롬프트 UUID + 치환 변수 > AI 응답 원문·소요 시간 (없는 프롬프트 > PROMPT_NOT_FOUND, 성공·실패 모두 이력 저장) */
    public TestPromptResult testPrompt(UUID promptTemplateUuid, Map<String, String> variables, String adminUsername) {
        PromptTemplate prompt = promptService.findById(promptTemplateUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.PROMPT_NOT_FOUND));
        TestPromptRequest request = new TestPromptRequest(
                PromptLlmConfigFactory.toLlmConfig(prompt, prompt.getUserTemplate(), null), variables);
        String variablesJson = toVariablesJson(variables);
        try {
            TestPromptResult result = aiGatewayClient.testPrompt(request);
            promptService.recordTestResult(promptTemplateUuid, variablesJson, result.result(),
                    result.elapsedMs(), true, null, adminUsername);
            return result;
        } catch (RuntimeException e) {
            // 실패도 이력에 남김 (예외 시에도 기록)
            promptService.recordTestResult(promptTemplateUuid, variablesJson, null, null, false,
                    e.getMessage(), adminUsername);
            throw e;
        }
    }

    /** 입력 변수 > JSON 문자열 (직렬화 실패 시 null, 이력 저장이 테스트를 막지 않음) */
    private String toVariablesJson(Map<String, String> variables) {
        try {
            return objectMapper.writeValueAsString(variables);
        } catch (JsonProcessingException e) {
            log.warn("[prompt test] variables serialize failed : {}", e.getClass().getSimpleName());
            return null;
        }
    }
}
