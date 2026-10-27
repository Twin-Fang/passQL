package com.passql.application.service.explanation;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.client.AiChatClient;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.question.dto.explanation.ChoiceSetExplanation;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

/**
 * 선택지 세트 구조화 해설 생성 (#521): 프롬프트 조립 > Gemini JSON 응답 > 파싱 > 검증 > 위반 있으면 위반 목록 붙여 1회 재시도
 * 모델·온도는 관리자 화면의 'diff_explain' 활성 프롬프트 설정을 따른다 (프롬프트 문구는 리소스 파일)
 * 저장은 호출한 쪽 책임, 호출 실패도 예외 대신 실패 결과로 돌려준다
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ChoiceSetExplanationGenerator {

    // 모델·온도 설정을 빌려 오는 프롬프트 키 (선택지 해설 v2 모델 비교 결과, #356)
    static final String MODEL_SETTING_PROMPT_KEY = "diff_explain";
    // 최대 시도 횟수 (첫 시도 + 위반 피드백 재시도 1회)
    static final int MAX_ATTEMPTS_PER_GENERATION = 2;
    // 응답 토큰 상한 (보기 4개 + 개념·지점 JSON, 사고 토큰 포함 여유)
    private static final int MIN_OUTPUT_TOKENS = 4096;
    private static final float DEFAULT_TEMPERATURE = 0.3f;

    private static final ObjectMapper RESPONSE_MAPPER = new ObjectMapper()
            .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

    private final AiChatClient aiChatClient;
    private final PromptService promptService;

    /** 세트 1개 해설 생성 (실행 근거 없음) */
    public ChoiceSetExplanationGenerationResult generate(Question question, List<QuestionChoiceSetItem> items) {
        return generate(question, items, Map.of());
    }

    /** 세트 1개 해설 생성: 보기별 실행 결과를 근거로 넣고 시도마다 호출 > 파싱 > 검증, 통과하면 바로 반환 */
    public ChoiceSetExplanationGenerationResult generate(Question question, List<QuestionChoiceSetItem> items,
                                                         Map<String, String> resultSummaryByChoiceKey) {
        long startedAt = System.currentTimeMillis();
        PromptTemplate modelSetting = promptService.getActivePrompt(MODEL_SETTING_PROMPT_KEY);
        String userPrompt = ChoiceSetExplanationPrompt.buildUserPrompt(question, items, resultSummaryByChoiceKey);

        ChoiceSetExplanation lastExplanation = null;
        String lastRawResponse = null;
        ExplanationValidationResult lastValidation = null;
        int attempt = 0;
        while (attempt < MAX_ATTEMPTS_PER_GENERATION) {
            attempt++;
            String attemptPrompt = lastValidation == null
                    ? userPrompt
                    : ChoiceSetExplanationPrompt.buildRetryUserPrompt(userPrompt, lastValidation.violations());
            lastRawResponse = callModel(modelSetting, attemptPrompt, question);
            lastExplanation = parseOrNull(lastRawResponse);
            lastValidation = lastExplanation == null
                    ? new ExplanationValidationResult(List.of(lastRawResponse == null ? "AI 호출 실패" : "응답 JSON 파싱 실패"), List.of())
                    : ChoiceSetExplanationValidator.validate(lastExplanation, items);
            if (lastValidation.isValid()) break;
            log.warn("[choice explanation] rejected attempt {} : question={} violations={}",
                    attempt, question.getQuestionUuid(), lastValidation.violations());
        }
        return new ChoiceSetExplanationGenerationResult(lastValidation.isValid() ? lastExplanation : null,
                lastRawResponse, lastValidation, attempt, System.currentTimeMillis() - startedAt);
    }

    /** LLM 구조화 호출 (실패 > null, 원인은 로그) */
    private String callModel(PromptTemplate modelSetting, String userPrompt, Question question) {
        try {
            return aiChatClient.chatStructured(
                    modelSetting.getModel(),
                    ChoiceSetExplanationPrompt.systemInstruction(),
                    userPrompt,
                    modelSetting.getTemperature() != null ? modelSetting.getTemperature() : DEFAULT_TEMPERATURE,
                    Math.max(modelSetting.getMaxTokens() != null ? modelSetting.getMaxTokens() : 0, MIN_OUTPUT_TOKENS),
                    ChoiceSetExplanationPrompt.responseSchemaJson());
        } catch (Exception e) {
            log.error("[choice explanation] ai call failed : question={}", question.getQuestionUuid(), e);
            return null;
        }
    }

    /** 응답 원문 > 해설 (코드 블록으로 감싼 응답도 허용, 실패 > null) */
    static ChoiceSetExplanation parseOrNull(String rawResponse) {
        if (rawResponse == null || rawResponse.isBlank()) return null;
        String json = rawResponse.strip();
        if (json.startsWith("```")) {
            json = json.replaceFirst("^```(?:json)?\\s*", "").replaceFirst("\\s*```$", "");
        }
        try {
            return RESPONSE_MAPPER.readValue(json, ChoiceSetExplanation.class);
        } catch (JsonProcessingException e) {
            return null;
        }
    }
}
