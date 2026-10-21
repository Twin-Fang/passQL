package com.passql.application.service.explanation;

import com.google.genai.types.Schema;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

/**
 * 선택지 세트 구조화 해설 프롬프트 (#521): 시스템 지시·응답 스키마(리소스 파일) + 문제 입력 조립
 * 원본: resources/ai-prompts/choice-set-explanation/ (서버·하네스 공통, 바꾸면 PROMPT_VERSION 올리고 하네스 재실행)
 */
public final class ChoiceSetExplanationPrompt {

    // 프롬프트 버전: 올리면 저장된 해설이 낡은 것으로 보고 백그라운드 재생성
    public static final int PROMPT_VERSION = 2;

    private static final String RESOURCE_DIRECTORY = "/ai-prompts/choice-set-explanation/";
    private static final String SYSTEM_INSTRUCTION_TEMPLATE = readResource("system-instruction.md");
    private static final String RESPONSE_SCHEMA_JSON = readResource("response-schema.json");

    // 시스템 지시의 {{이름}} 자리 > 검증 상한 (프롬프트와 검증기가 같은 값을 쓰게)
    private static final String SYSTEM_INSTRUCTION = fillLengthLimits(SYSTEM_INSTRUCTION_TEMPLATE, Map.of(
            "CORRECT_REASON_MAX_LENGTH", ChoiceSetExplanationValidator.CORRECT_REASON_MAX_LENGTH,
            "CONCEPT_NAME_MAX_LENGTH", ChoiceSetExplanationValidator.CONCEPT_NAME_MAX_LENGTH,
            "CONCEPT_DESCRIPTION_MAX_LENGTH", ChoiceSetExplanationValidator.CONCEPT_DESCRIPTION_MAX_LENGTH,
            "CONFUSING_POINT_MAX_LENGTH", ChoiceSetExplanationValidator.CONFUSING_POINT_MAX_LENGTH,
            "CHOICE_REASON_MAX_LENGTH", ChoiceSetExplanationValidator.CHOICE_REASON_MAX_LENGTH,
            "EXAM_TIP_MAX_LENGTH", ChoiceSetExplanationValidator.EXAM_TIP_MAX_LENGTH));

    private ChoiceSetExplanationPrompt() {
    }

    public static String systemInstruction() {
        return SYSTEM_INSTRUCTION;
    }

    /** Gemini 응답 스키마 (호출마다 새 객체, SDK 객체 공유 방지) */
    public static Schema responseSchema() {
        return Schema.fromJson(RESPONSE_SCHEMA_JSON);
    }

    /** 문제 입력: 지문 > 테이블 구조 > 샘플 데이터 > 기준 SQL > 보기 전체([정답]/[오답] + 생성 근거) */
    public static String buildUserPrompt(Question question, List<QuestionChoiceSetItem> items) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("[문제]\n").append(nullToEmpty(question.getStem()).trim()).append("\n\n");
        appendSectionIfPresent(prompt, "테이블 구조", question.getSchemaDdl());
        appendSectionIfPresent(prompt, "샘플 데이터", question.getSchemaSampleData());
        appendSectionIfPresent(prompt, "기준 SQL (정답 결과를 내는 SQL)", question.getAnswerSql());
        prompt.append("[보기]\n");
        for (QuestionChoiceSetItem item : items) {
            String correctLabel = Boolean.TRUE.equals(item.getIsCorrect()) ? "[정답]" : "[오답]";
            prompt.append(item.getChoiceKey()).append(". ").append(correctLabel).append(" ")
                    .append(nullToEmpty(item.getBody()).trim()).append("\n");
            if (item.getRationale() != null && !item.getRationale().isBlank()) {
                prompt.append("   생성 근거(참고): ").append(item.getRationale().trim()).append("\n");
            }
        }
        return prompt.toString();
    }

    /** 재시도 입력: 원래 입력 + 직전 응답의 위반 목록 (같은 실수 반복 방지) */
    public static String buildRetryUserPrompt(String userPrompt, List<String> previousViolations) {
        StringBuilder prompt = new StringBuilder(userPrompt).append("\n[직전 응답의 문제, 고쳐서 다시 작성]\n");
        previousViolations.forEach(violation -> prompt.append("- ").append(violation).append("\n"));
        return prompt.toString();
    }

    private static void appendSectionIfPresent(StringBuilder prompt, String label, String value) {
        if (value != null && !value.isBlank()) {
            prompt.append("[").append(label).append("]\n").append(value.trim()).append("\n\n");
        }
    }

    private static String fillLengthLimits(String template, Map<String, Integer> lengthLimitByName) {
        String filled = template;
        for (Map.Entry<String, Integer> entry : lengthLimitByName.entrySet()) {
            filled = filled.replace("{{" + entry.getKey() + "}}", String.valueOf(entry.getValue()));
        }
        if (filled.contains("{{")) {
            throw new IllegalStateException("choice set explanation prompt has unfilled placeholder");
        }
        return filled;
    }

    private static String readResource(String fileName) {
        try (InputStream stream = ChoiceSetExplanationPrompt.class.getResourceAsStream(RESOURCE_DIRECTORY + fileName)) {
            if (stream == null) throw new IllegalStateException("missing prompt resource: " + fileName);
            return new String(stream.readAllBytes(), StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    private static String nullToEmpty(String value) {
        return value == null ? "" : value;
    }
}
