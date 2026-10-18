package com.passql.application.service.explanation;

import com.google.genai.types.Schema;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 구조화 해설 프롬프트 (#521): 리소스 로딩, 길이 상한 치환, 응답 스키마, 문제 입력 조립
 */
class ChoiceSetExplanationPromptTest {

    @Test
    void 시스템_지시의_길이_상한_자리는_검증기_값으로_채운다() {
        String systemInstruction = ChoiceSetExplanationPrompt.systemInstruction();

        assertThat(systemInstruction).doesNotContain("{{");
        assertThat(systemInstruction).contains(ChoiceSetExplanationValidator.CORRECT_REASON_MAX_LENGTH + "자 이내");
    }

    @Test
    void 응답_스키마는_필수_필드_6개() {
        Schema schema = ChoiceSetExplanationPrompt.responseSchema();

        assertThat(schema.required()).hasValueSatisfying(required -> assertThat(required).containsExactlyInAnyOrder(
                "correctChoiceKey", "correctReason", "keyConcepts", "confusingPoints", "choiceAnalyses", "examTip"));
        assertThat(schema.properties()).hasValueSatisfying(properties -> assertThat(properties).containsKey("choiceAnalyses"));
    }

    @Test
    void 문제_입력은_지문_스키마_기준_SQL_보기_정답_표시를_담는다() {
        Question question = Question.builder().stem("결과는?").schemaDdl("CREATE TABLE T (X NUMBER);")
                .schemaSampleData("INSERT INTO T VALUES (1);").answerSql("SELECT X FROM T").build();
        List<QuestionChoiceSetItem> items = List.of(
                QuestionChoiceSetItem.builder().choiceKey("A").body("1").isCorrect(true).rationale("X 는 1").build(),
                QuestionChoiceSetItem.builder().choiceKey("B").body("2").isCorrect(false).build());

        String userPrompt = ChoiceSetExplanationPrompt.buildUserPrompt(question, items);

        assertThat(userPrompt).contains("[문제]\n결과는?", "[테이블 구조]", "[샘플 데이터]", "[기준 SQL",
                "A. [정답] 1", "생성 근거(참고): X 는 1", "B. [오답] 2");
        assertThat(ChoiceSetExplanationPrompt.buildRetryUserPrompt(userPrompt, List.of("correctChoiceKey 불일치")))
                .endsWith("[직전 응답의 문제, 고쳐서 다시 작성]\n- correctChoiceKey 불일치\n");
    }
}
