package com.passql.question.service;

import com.passql.question.dto.explanation.ChoiceAnalysis;
import com.passql.question.dto.explanation.ChoiceExplanation;
import com.passql.question.dto.explanation.ChoiceSetExplanation;
import com.passql.question.dto.explanation.KeyConcept;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 구조화 해설 변환 (#521): 저장 JSON 왕복, 깨진 JSON 무시, 판정 조립, 출시 앱 호환 마크다운
 */
class ChoiceExplanationComposerTest {

    private final ChoiceSetExplanation setExplanation = new ChoiceSetExplanation("B",
            "`DENSE_RANK` 는 동점 뒤 순위를 건너뛰지 않아 CHOI 는 3.",
            List.of(new KeyConcept("DENSE_RANK", "동점 같은 순위, 다음 순위 연속")),
            List.of("`RANK` 는 동점 수만큼 건너뜀"),
            // 일부러 키 역순 (조립 시 키 순 정렬 확인)
            List.of(new ChoiceAnalysis("C", false, "동점 순위"), new ChoiceAnalysis("B", true, "연속 순위 3"),
                    new ChoiceAnalysis("A", false, "RANK 기준 4")),
            "동점 다음 순위 번호부터 확인");

    @Test
    void 저장_JSON_왕복과_알_수_없는_필드_무시() {
        String json = ChoiceExplanationComposer.toJson(setExplanation);
        String jsonWithNewField = json.replaceFirst("\\{", "{\"futureField\":1,");

        assertThat(ChoiceExplanationComposer.parse(json)).contains(setExplanation);
        assertThat(ChoiceExplanationComposer.parse(jsonWithNewField)).contains(setExplanation);
    }

    @Test
    void 깨진_JSON_과_빈_값은_저장본_없음() {
        assertThat(ChoiceExplanationComposer.parse("{oops")).isEmpty();
        assertThat(ChoiceExplanationComposer.parse(" ")).isEmpty();
        assertThat(ChoiceExplanationComposer.composeOrNull(null, "A")).isNull();
    }

    @Test
    void 오답_판정은_고른_키와_정답_키와_고른_보기_이유() {
        ChoiceExplanation explanation = ChoiceExplanationComposer.composeForSelectedChoice(setExplanation, "A");

        assertThat(explanation.isSelectedCorrect()).isFalse();
        assertThat(explanation.verdict()).isEqualTo("오답 · A 선택, 정답은 B · RANK 기준 4");
        assertThat(explanation.choiceAnalyses()).extracting(ChoiceAnalysis::choiceKey).containsExactly("A", "B", "C");
    }

    @Test
    void 정답_판정() {
        ChoiceExplanation explanation = ChoiceExplanationComposer.composeForSelectedChoice(setExplanation, "B");

        assertThat(explanation.isSelectedCorrect()).isTrue();
        assertThat(explanation.verdict()).isEqualTo("정답 · 연속 순위 3");
    }

    @Test
    void 마크다운은_출시_앱이_그리는_표기만_쓰고_섹션_순서를_지킨다() {
        String markdown = ChoiceExplanationComposer.toMarkdown(ChoiceExplanationComposer.composeForSelectedChoice(setExplanation, "A"));

        assertThat(markdown).doesNotContain("#").doesNotContain("```");
        assertThat(markdown.indexOf("**오답")).isLessThan(markdown.indexOf("**정답 B 근거**"));
        assertThat(markdown.indexOf("**정답 B 근거**")).isLessThan(markdown.indexOf("**핵심 개념**"));
        assertThat(markdown.indexOf("**핵심 개념**")).isLessThan(markdown.indexOf("**헷갈리는 지점**"));
        assertThat(markdown.indexOf("**헷갈리는 지점**")).isLessThan(markdown.indexOf("**보기별 판단**"));
        assertThat(markdown).contains("- **A** (오답, 내 선택): RANK 기준 4");
        assertThat(markdown).contains("- **B** (정답): 연속 순위 3");
        assertThat(markdown).endsWith("**시험 팁** 동점 다음 순위 번호부터 확인");
    }
}
