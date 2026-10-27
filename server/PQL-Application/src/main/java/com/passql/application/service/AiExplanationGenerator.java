package com.passql.application.service;

import com.passql.ai.client.AiChatClient;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.question.entity.Question;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * SQL 오류 AI 해설 문구 생성: 프롬프트 조립 > Gemini 호출 > 공백 정리 (저장은 호출한 쪽 책임)
 * 프롬프트는 DB(prompt_template)의 'explain_error' 활성 버전 (관리자 화면에서 변경)
 * 선택지 해설은 세트 단위 구조화 해설 ChoiceSetExplanationGenerator (#521)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AiExplanationGenerator {

    static final String PROMPT_ERROR = "explain_error";

    /**
     * 답변 규칙. DB 프롬프트(system) 뒤 사용자 프롬프트 끝에 붙인다.
     * lite 모델 3종 비교(#356)에서 이 규칙을 넣었을 때 '옳지 않은 것' 문제의 방향 오해와 엉뚱한 팁이 사라졌다.
     */
    private static final String ANSWER_RULES = """

            [답변 규칙]
            - 문제가 '옳지 않은 것', '틀린 것', '나머지와 다른 것'을 묻는 경우: 정답 선택지가 '틀린 설명/결과가 다른 쿼리'이다. 학습자가 고른 선택지는 왜 답이 될 수 없는지(옳은 설명이거나 결과가 같은 이유)를 설명한다.
            - 샘플 데이터가 있으면 실제 행을 근거로 결과를 비교한다.
            - 이 문제와 직접 관련된 개념만 설명하고 다른 주제 팁은 덧붙이지 않는다.
            - 수식 기호(LaTeX, $ 기호)는 쓰지 않는다.

            [답변 형식]
            - 한국어, 마크다운 사용 가능
            - 핵심 원인 1~2문장 → 정답이 맞는 이유 → 기억할 포인트 순서
            - 600자 이내, 불필요한 인사말 없이""";

    private final AiChatClient aiChatClient;
    private final PromptService promptService;

    /** 생성된 해설 문구 + 만든 프롬프트 버전 */
    public record GeneratedExplanation(String text, Integer promptVersion) {}

    /** SQL 실행 오류 해설: 문제·스키마·실행한 SQL·오류 메시지 */
    public GeneratedExplanation generateErrorExplanation(Question question, String sql, String errorMessage) {
        PromptTemplate prompt = promptService.getActivePrompt(PROMPT_ERROR);
        String userPrompt = """
                문제: %s

                테이블 구조:
                %s

                샘플 데이터:
                %s

                학습자가 실행한 SQL:
                %s

                발생한 오류:
                %s

                오류가 난 원인과 고치는 방법을 설명해 주세요.
                """.formatted(nz(question.getStem()), nz(question.getSchemaDdl()), nz(question.getSchemaSampleData()),
                        nz(sql), nz(errorMessage))
                + ANSWER_RULES;
        return new GeneratedExplanation(
                call(prompt, userPrompt, "explainError", question.getQuestionUuid()), prompt.getVersion());
    }

    private String call(PromptTemplate prompt, String userPrompt, String kind, UUID questionUuid) {
        try {
            String text = aiChatClient.chat(
                    prompt.getModel(),
                    // DB 프롬프트에 줄바꿈이 '\n' 글자로 저장된 경우가 있어 실제 줄바꿈으로 바꾼다.
                    prompt.getSystemPrompt().replace("\\n", "\n"),
                    userPrompt,
                    prompt.getTemperature() != null ? prompt.getTemperature() : 0.3f,
                    prompt.getMaxTokens() != null ? Math.max(prompt.getMaxTokens(), 1024) : 1024);
            if (text == null || text.isBlank()) throw new IllegalStateException("빈 응답");
            return text.trim();
        } catch (Exception e) {
            log.error("[ai-explain] {} 실패: question={}", kind, questionUuid, e);
            throw new CustomException(ErrorCode.AI_UNAVAILABLE);
        }
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }
}
