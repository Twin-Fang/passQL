package com.passql.question.service;

import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.dto.CuratedChoiceDto;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 고정 보기 검증 (#511): 보기 4개, 정답 1개, 키 중복·빈 키·빈 본문·빈 근거 금지, CURATED_ONLY 는 보기 필수
 */
class CuratedChoiceValidatorTest {

    private static CuratedChoiceDto choice(String key, boolean isCorrect) {
        return new CuratedChoiceDto(key, "TEXT", "보기 " + key, isCorrect, "근거 " + key);
    }

    private static List<CuratedChoiceDto> validChoices() {
        return new ArrayList<>(List.of(choice("A", true), choice("B", false), choice("C", false), choice("D", false)));
    }

    @Test
    void validChoices_passes() {
        assertThat(CuratedChoiceValidator.findRejectReason(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.CONCEPT_ONLY, validChoices())).isNull();
    }

    @Test
    void curatedWithoutChoices_rejected() {
        assertThat(CuratedChoiceValidator.findRejectReason(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.CONCEPT_ONLY, null)).contains("보기");
    }

    @Test
    void aiOnlyWithoutChoices_passes() {
        assertThat(CuratedChoiceValidator.findRejectReason(ChoiceSetPolicy.AI_ONLY, ExecutionMode.EXECUTABLE, null)).isNull();
    }

    @Test
    void threeChoices_rejected() {
        List<CuratedChoiceDto> choices = validChoices();
        choices.remove(3);
        assertThat(CuratedChoiceValidator.findRejectReason(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.CONCEPT_ONLY, choices)).contains("4개");
    }

    @Test
    void zeroOrTwoCorrect_rejected() {
        List<CuratedChoiceDto> noCorrect = List.of(choice("A", false), choice("B", false), choice("C", false), choice("D", false));
        List<CuratedChoiceDto> twoCorrect = List.of(choice("A", true), choice("B", true), choice("C", false), choice("D", false));
        assertThat(CuratedChoiceValidator.findRejectReason(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.CONCEPT_ONLY, noCorrect)).contains("정답");
        assertThat(CuratedChoiceValidator.findRejectReason(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.CONCEPT_ONLY, twoCorrect)).contains("정답");
    }

    @Test
    void duplicateKey_rejected() {
        List<CuratedChoiceDto> choices = List.of(choice("A", true), choice("A", false), choice("C", false), choice("D", false));
        assertThat(CuratedChoiceValidator.findRejectReason(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.CONCEPT_ONLY, choices)).contains("중복");
    }

    @Test
    void blankBodyOrRationale_rejected() {
        List<CuratedChoiceDto> blankBody = validChoices();
        blankBody.set(1, new CuratedChoiceDto("B", "TEXT", " ", false, "근거"));
        List<CuratedChoiceDto> blankRationale = validChoices();
        blankRationale.set(2, new CuratedChoiceDto("C", "TEXT", "보기", false, null));
        assertThat(CuratedChoiceValidator.findRejectReason(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.CONCEPT_ONLY, blankBody)).contains("본문");
        assertThat(CuratedChoiceValidator.findRejectReason(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.CONCEPT_ONLY, blankRationale)).contains("근거");
    }

    @Test
    void nonCuratedPolicyWithChoices_rejected() {
        assertThat(CuratedChoiceValidator.findRejectReason(ChoiceSetPolicy.AI_ONLY, ExecutionMode.CONCEPT_ONLY, validChoices()))
                .contains("CURATED_ONLY");
    }

    @Test
    void executableWithTextChoice_rejected() {
        assertThat(CuratedChoiceValidator.findRejectReason(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.EXECUTABLE, validChoices()))
                .contains("SQL");
    }

    @Test
    void executableWithSqlChoices_passes() {
        List<CuratedChoiceDto> sqlChoices = validChoices().stream()
                .map(choice -> new CuratedChoiceDto(choice.choiceKey(), "SQL", "SELECT 1 FROM DUAL", choice.isCorrect(), choice.rationale()))
                .toList();
        assertThat(CuratedChoiceValidator.findRejectReason(ChoiceSetPolicy.CURATED_ONLY, ExecutionMode.EXECUTABLE, sqlChoices)).isNull();
    }
}
