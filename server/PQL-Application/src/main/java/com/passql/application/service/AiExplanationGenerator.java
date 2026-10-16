package com.passql.application.service;

import com.passql.ai.client.GeminiClient;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

/**
 * AI 해설 문구 생성: 프롬프트 조립 > Gemini 호출 > 공백 정리 (저장은 호출한 쪽 책임)
 * 프롬프트는 DB(prompt_template)의 'diff_explain'·'explain_error' 활성 버전 (관리자 화면에서 변경)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AiExplanationGenerator {

    static final String PROMPT_DIFF = "diff_explain";
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

    private final GeminiClient geminiClient;
    private final PromptService promptService;

    /** 생성된 해설 문구 + 만든 프롬프트 버전 */
    public record GeneratedExplanation(String text, Integer promptVersion) {}

    /** 선택지 해설 프롬프트의 현재 활성 버전 (저장된 해설이 낡았는지 판단) */
    public Integer activeChoicePromptVersion() {
        return promptService.getActivePrompt(PROMPT_DIFF).getVersion();
    }

    /** 선택지 1개를 골랐을 때의 해설: 문제·샘플 데이터·전체 선택지·정답 비교 */
    public GeneratedExplanation generateChoiceExplanation(
            Question question, List<QuestionChoiceSetItem> items, String selectedKey) {
        QuestionChoiceSetItem selected = items.stream()
                .filter(item -> item.getChoiceKey().equals(selectedKey)).findFirst().orElse(null);
        QuestionChoiceSetItem correct = items.stream()
                .filter(item -> Boolean.TRUE.equals(item.getIsCorrect())).findFirst().orElse(null);
        PromptTemplate prompt = promptService.getActivePrompt(PROMPT_DIFF);
        String userPrompt = buildDiffPrompt(question, items, selected, correct, selectedKey);
        return new GeneratedExplanation(
                call(prompt, userPrompt, "diffExplain", question.getQuestionUuid()), prompt.getVersion());
    }

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

    /**
     * 문제·샘플 데이터·전체 선택지·고른 답·정답을 함께 넘긴다.
     * 전체 선택지와 샘플 데이터가 있어야 '나머지와 다른 것' 같은 문제를 실제 결과로 비교할 수 있다(#356 실험).
     */
    private String buildDiffPrompt(Question q, List<QuestionChoiceSetItem> items,
                                   QuestionChoiceSetItem selected, QuestionChoiceSetItem correct, String selectedKey) {
        StringBuilder sb = new StringBuilder();
        sb.append("문제: ").append(nz(q.getStem())).append("\n\n");
        appendIfPresent(sb, "테이블 구조", q.getSchemaDdl());
        appendIfPresent(sb, "샘플 데이터", q.getSchemaSampleData());
        appendIfPresent(sb, "기준 SQL", q.getAnswerSql());
        if (!items.isEmpty()) {
            sb.append("선택지 전체:\n");
            for (QuestionChoiceSetItem i : items) {
                sb.append(i.getChoiceKey()).append(". ").append(nz(i.getBody())).append("\n");
            }
            sb.append("\n");
        }
        String sel = selected != null ? selected.getChoiceKey() : selectedKey;
        if (sel != null) sb.append("학습자가 고른 선택지: ").append(sel).append("\n");
        if (correct != null) {
            sb.append("정답 선택지: ").append(correct.getChoiceKey()).append("\n");
            if (correct.getRationale() != null && !correct.getRationale().isBlank()) {
                sb.append("정답 근거(참고): ").append(correct.getRationale()).append("\n");
            }
        }
        boolean isCorrect = selected != null && correct != null && selected.getChoiceKey().equals(correct.getChoiceKey());
        sb.append("\n").append(isCorrect
                ? "학습자는 정답을 골랐습니다. 이 선택지가 왜 답인지, 다른 선택지와 무엇이 다른지 설명해 주세요."
                : "학습자가 고른 선택지가 왜 답이 아닌지, 정답 선택지가 왜 답인지 비교해서 설명해 주세요.");
        return sb + ANSWER_RULES;
    }

    private static void appendIfPresent(StringBuilder sb, String label, String value) {
        if (value != null && !value.isBlank()) sb.append(label).append(":\n").append(value).append("\n\n");
    }

    private String call(PromptTemplate prompt, String userPrompt, String kind, UUID questionUuid) {
        try {
            String text = geminiClient.chat(
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
