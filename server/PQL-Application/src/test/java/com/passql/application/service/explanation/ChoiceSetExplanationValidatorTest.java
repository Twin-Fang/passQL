package com.passql.application.service.explanation;

import com.passql.question.dto.explanation.ChoiceAnalysis;
import com.passql.question.dto.explanation.ChoiceSetExplanation;
import com.passql.question.dto.explanation.KeyConcept;
import com.passql.question.entity.QuestionChoiceSetItem;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 구조화 해설 검증 (#521): 형식·사실 위반은 거부, 길이·문체는 경고 (서버 저장·하네스 공통)
 */
class ChoiceSetExplanationValidatorTest {

    private final List<QuestionChoiceSetItem> items = List.of(item("A", true), item("B", false), item("C", false), item("D", false));

    private static QuestionChoiceSetItem item(String key, boolean isCorrect) {
        return QuestionChoiceSetItem.builder().choiceKey(key).body(key + " 보기").isCorrect(isCorrect).build();
    }

    private static List<ChoiceAnalysis> analyses(String correctKey) {
        return List.of("A", "B", "C", "D").stream()
                .map(key -> new ChoiceAnalysis(key, key.equals(correctKey), key + " 보기 판단 근거"))
                .toList();
    }

    private static ChoiceSetExplanation explanation(String correctKey, String correctReason, List<ChoiceAnalysis> analyses) {
        return new ChoiceSetExplanation(correctKey, correctReason,
                List.of(new KeyConcept("DENSE_RANK", "동점 같은 순위, 다음 순위 연속")),
                List.of("`RANK` 와 혼동 주의"), analyses, "동점 다음 순위부터 확인");
    }

    @Test
    void 정답_데이터와_맞는_해설은_통과() {
        ExplanationValidationResult result = ChoiceSetExplanationValidator.validate(
                explanation("A", "`DENSE_RANK` 는 동점 뒤 순위 연속. 정답은 A.", analyses("A")), items);

        assertThat(result.isValid()).isTrue();
        assertThat(result.warnings()).isEmpty();
    }

    @Test
    void 정답_키가_다르면_위반() {
        ExplanationValidationResult result = ChoiceSetExplanationValidator.validate(
                explanation("B", "근거", analyses("A")), items);

        assertThat(result.violations()).anyMatch(violation -> violation.startsWith("correctChoiceKey 불일치"));
    }

    @Test
    void 보기_판정이_정답_데이터와_모순이면_위반() {
        ExplanationValidationResult result = ChoiceSetExplanationValidator.validate(
                explanation("A", "근거", analyses("C")), items);

        assertThat(result.violations()).anyMatch(violation -> violation.contains("A 정답 여부 모순"));
        assertThat(result.violations()).anyMatch(violation -> violation.contains("C 정답 여부 모순"));
    }

    @Test
    void 보기가_빠지면_위반() {
        ExplanationValidationResult result = ChoiceSetExplanationValidator.validate(
                explanation("A", "근거", analyses("A").subList(0, 3)), items);

        assertThat(result.violations()).anyMatch(violation -> violation.startsWith("choiceAnalyses 보기 키 불일치"));
    }

    @Test
    void 본문이_다른_보기를_정답으로_말하면_위반_DENSE_RANK_는_오탐하지_않음() {
        ExplanationValidationResult wrongMention = ChoiceSetExplanationValidator.validate(
                explanation("A", "정답은 B 이다", analyses("A")), items);
        ExplanationValidationResult functionName = ChoiceSetExplanationValidator.validate(
                explanation("A", "정답 DENSE_RANK 결과와 일치", analyses("A")), items);

        assertThat(wrongMention.violations()).anyMatch(violation -> violation.startsWith("본문이 다른 보기를 정답으로 언급"));
        assertThat(functionName.isValid()).isTrue();
    }

    @Test
    void 개념_개수와_필수값_누락은_위반() {
        ChoiceSetExplanation missingFields = new ChoiceSetExplanation("A", " ", List.of(), null, analyses("A"), null);

        ExplanationValidationResult result = ChoiceSetExplanationValidator.validate(missingFields, items);

        assertThat(result.violations()).contains("correctReason 빈 값", "examTip 빈 값",
                "keyConcepts 개수 0개 (1~3개)", "confusingPoints 개수 0개 (1~3개)");
    }

    @Test
    void 길이_상한_초과는_경고_1점5배_초과는_위반() {
        String slightlyLong = "가".repeat(ChoiceSetExplanationValidator.CORRECT_REASON_MAX_LENGTH + 10);
        String tooLong = "가".repeat(ChoiceSetExplanationValidator.CORRECT_REASON_MAX_LENGTH * 2);

        assertThat(ChoiceSetExplanationValidator.validate(explanation("A", slightlyLong, analyses("A")), items).warnings())
                .anyMatch(warning -> warning.startsWith("correctReason 길이"));
        assertThat(ChoiceSetExplanationValidator.validate(explanation("A", tooLong, analyses("A")), items).violations())
                .anyMatch(violation -> violation.startsWith("correctReason 길이"));
    }

    @Test
    void 서술_어미와_코드_블록은_경고() {
        ExplanationValidationResult result = ChoiceSetExplanationValidator.validate(
                explanation("A", "동점 뒤 순위가 연속됩니다. ```sql SELECT 1```", analyses("A")), items);

        assertThat(result.isValid()).isTrue();
        assertThat(result.warnings()).contains("서술 어미(~습니다/~해요) 1곳", "코드 블록(```) 사용");
    }
}
