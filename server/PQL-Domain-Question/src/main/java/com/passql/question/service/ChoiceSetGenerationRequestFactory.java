package com.passql.question.service;

import com.passql.ai.dto.ChoiceSetContextDto;
import com.passql.ai.dto.GenerateChoiceSetRequest;
import com.passql.ai.dto.GeneratedChoiceDto;
import com.passql.ai.dto.LlmConfigDto;
import com.passql.meta.entity.PromptTemplate;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.dto.ValidationReport;
import com.passql.question.entity.Question;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 선택지 세트 AI 요청 조립: 유형 3개(표준 SQL, 개념, 결과 일치) 문맥·프롬프트·응답 스키마, 재시도 피드백
 * 공통 응답 스키마 1개 + 유형별 문맥·user prompt 치환
 */
@Component
public class ChoiceSetGenerationRequestFactory {

    // AI 응답 스키마: 선택지 정확히 4개 (key, body, is_correct, rationale)
    private static final Map<String, Object> CHOICE_SET_RESPONSE_SCHEMA = Map.of(
            "type", "object",
            "properties", Map.of(
                    "choices", Map.of(
                            "type", "array",
                            "minItems", 4, "maxItems", 4,
                            "items", Map.of(
                                    "type", "object",
                                    "properties", Map.of(
                                            "key", Map.of("type", "string"),
                                            "body", Map.of("type", "string"),
                                            "is_correct", Map.of("type", "boolean"),
                                            "rationale", Map.of("type", "string")
                                    ),
                                    "required", List.of("key", "body", "is_correct", "rationale")
                            )
                    )
            ),
            "required", List.of("choices")
    );
    // RESULT_MATCH user prompt 치환 자리: 정답 SQL 실행 결과 텍스트
    private static final String ANSWER_RESULT_PLACEHOLDER = "{answer_result}";

    /**
     * AI_ONLY 선택지 생성 요청을 빌드한다.
     * equivalentSqls가 있으면 user prompt 하단에 "이미 동치임이 확인된 SQL은 피해라" 피드백을 추가한다.
     * 이를 통해 재시도 시 AI가 동일한 SQL 동치 실수를 반복하지 않도록 유도한다.
     */
    public GenerateChoiceSetRequest buildStandardRequest(
            Question question, PromptTemplate prompt, List<String> equivalentSqls) {
        // 이전 시도에서 정답과 동치임이 확인된 SQL들을 피드백으로 user prompt에 추가
        String userTemplate = prompt.getUserTemplate();
        if (!equivalentSqls.isEmpty()) {
            StringBuilder feedback = new StringBuilder("\n\n[재시도 피드백]\n");
            feedback.append("아래 SQL들은 기준 SQL과 동일한 실행 결과를 내는 것으로 확인되었다.\n");
            feedback.append("오답 선택지로 절대 사용하지 말 것:\n");
            for (int i = 0; i < equivalentSqls.size(); i++) {
                feedback.append(i + 1).append(". ").append(equivalentSqls.get(i)).append("\n");
            }
            feedback.append("위 SQL과 다른 표현/문법으로 명확히 다른 결과를 내는 오답 SQL을 생성해야 한다.");
            userTemplate = userTemplate + feedback;
        }
        return new GenerateChoiceSetRequest(toSqlContext(question), toLlmConfig(prompt, userTemplate));
    }

    /**
     * CONCEPT_ONLY 전용 요청 빌드 — stem + hint만 사용, SQL 관련 필드는 null.
     */
    public GenerateChoiceSetRequest buildConceptRequest(Question question, PromptTemplate prompt) {
        // hint를 stem에 병합하여 AI 컨텍스트로 제공 (ChoiceSetContextDto는 hint 필드 없음)
        String stemWithHint = question.getStem()
                + (question.getHint() != null && !question.getHint().isBlank()
                ? "\n\n[힌트] " + question.getHint() : "");

        ChoiceSetContextDto context = new ChoiceSetContextDto(
                question.getQuestionUuid(),
                stemWithHint,
                null,  // CONCEPT_ONLY — 정답 SQL 없음
                null,  // CONCEPT_ONLY — 스키마 DDL 없음
                null,  // CONCEPT_ONLY — 샘플 데이터 없음
                null,  // CONCEPT_ONLY — 스키마 의도 없음
                question.getDifficulty()
        );
        return new GenerateChoiceSetRequest(context, toLlmConfig(prompt, prompt.getUserTemplate()));
    }

    /**
     * RESULT_MATCH 전용 AI 요청 빌드 — answerSql 실행 결과를 user prompt에 직접 치환하여 포함.
     */
    public GenerateChoiceSetRequest buildResultMatchRequest(
            Question question, PromptTemplate prompt, ExecuteResult expectedResult) {
        // {answer_result} 플레이스홀더를 실행 결과 텍스트로 치환하여 AI에 전달
        String userPrompt = prompt.getUserTemplate()
                .replace(ANSWER_RESULT_PLACEHOLDER, serializeExecuteResult(expectedResult));
        return new GenerateChoiceSetRequest(toSqlContext(question), toLlmConfig(prompt, userPrompt));
    }

    /**
     * MULTIPLE_CORRECT 실패 시 정답과 동치(동일 결과)인 오답 SQL을 피드백 목록에 추가한다.
     * AI가 is_correct=false로 설정했지만 sandbox 결과 matchesExpected=true인 선택지를 수집한다.
     */
    public void collectEquivalentSqls(
            List<GeneratedChoiceDto> choices,
            ValidationReport report,
            List<String> equivalentSqls
    ) {
        // ValidationReport.items에서 matchesExpected=true인 선택지 key를 맵핑
        Map<String, Boolean> matchMap = new HashMap<>();
        for (var cv : report.items()) {
            matchMap.put(cv.key(), cv.matchesExpected());
        }

        for (GeneratedChoiceDto choice : choices) {
            // sandbox에서 matchesExpected=true로 판정된 SQL을 모두 수집
            // AI의 is_correct 판단과 무관하게 — MULTIPLE_CORRECT 상황에서 동치인 SQL 전부가 피드백 대상
            if (Boolean.TRUE.equals(matchMap.get(choice.key()))) {
                if (choice.body() != null && !choice.body().isBlank()
                        && !equivalentSqls.contains(choice.body())) {
                    equivalentSqls.add(choice.body());
                }
            }
        }
    }

    /** 문제 > SQL 문맥 (지문·정답 SQL·스키마·난이도) */
    private ChoiceSetContextDto toSqlContext(Question question) {
        return new ChoiceSetContextDto(
                question.getQuestionUuid(),
                question.getStem(),
                question.getAnswerSql(),
                question.getSchemaDdl(),
                question.getSchemaSampleData(),
                question.getSchemaIntent(),
                question.getDifficulty()
        );
    }

    /** 프롬프트 템플릿 + 조립된 user prompt > LLM 설정 (공통 응답 스키마) */
    private LlmConfigDto toLlmConfig(PromptTemplate prompt, String userPrompt) {
        return new LlmConfigDto(
                prompt.getModel(),
                prompt.getSystemPrompt(),
                userPrompt,
                prompt.getTemperature(),
                prompt.getMaxTokens(),
                CHOICE_SET_RESPONSE_SCHEMA
        );
    }

    /**
     * ExecuteResult를 사람이 읽기 쉬운 텍스트로 직렬화하여 AI 컨텍스트로 제공한다.
     * 형식: "COLUMN1, COLUMN2\nVAL1, VAL2\nVAL3, VAL4"
     * <p>
     * 보안: DB 값에 {placeholder} 형태의 문자열이 있으면 프롬프트 치환 로직을 오염시킬 수 있어
     * 중괄호를 대괄호로 치환하여 치환 대상에서 제외한다.
     */
    private String serializeExecuteResult(ExecuteResult result) {
        if (result.rows().isEmpty()) {
            return "(결과 없음)";
        }
        StringBuilder sb = new StringBuilder();
        sb.append(String.join(", ", result.columns()));
        for (var row : result.rows()) {
            sb.append("\n");
            List<String> vals = new ArrayList<>();
            for (Object v : row) {
                // 중괄호를 대괄호로 치환 — {placeholder} 패턴 오염 방지
                vals.add(String.valueOf(v).replace("{", "[").replace("}", "]"));
            }
            sb.append(String.join(", ", vals));
        }
        return sb.toString();
    }
}
