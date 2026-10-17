package com.passql.question.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.dto.GeneratedChoiceDto;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.dto.ValidationReport;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * RESULT_MATCH 선택지 비교 고정: 열 이름 대소문자·행 순서 무시, 숫자 1 <-> 1.0 동일, JSON 아니면 ERROR
 */
class ResultMatchChoiceValidatorTest {

    private final ResultMatchChoiceValidator validator = new ResultMatchChoiceValidator(null, new ObjectMapper());

    private final ExecuteResult expectedResult = new ExecuteResult("OK", List.of("ID", "NAME"),
            List.of(List.of(1, "kim"), List.of(2, "lee")), 2, 1L, null, null);

    @Test
    void 열_대소문자와_행_순서와_숫자_표기가_달라도_같은_결과로_본다() {
        ValidationReport report = validator.validate(List.of(
                choice("A", "[{\"name\": \"lee\", \"id\": 2.0}, {\"Id\": 1, \"NAME\": \"kim\"}]")), expectedResult);

        assertThat(report.correctCount()).isEqualTo(1);
        assertThat(report.items().get(0).status()).isEqualTo("OK");
        assertThat(report.items().get(0).matchesExpected()).isTrue();
    }

    @Test
    void 값이나_행_수가_다르면_오답이다() {
        ValidationReport report = validator.validate(List.of(
                choice("A", "[{\"id\": 1, \"name\": \"kim\"}, {\"id\": 3, \"name\": \"lee\"}]"),
                choice("B", "[{\"id\": 1, \"name\": \"kim\"}]")), expectedResult);

        assertThat(report.correctCount()).isZero();
        assertThat(report.items()).extracting(ValidationReport.ChoiceValidation::matchesExpected)
                .containsExactly(false, false);
    }

    @Test
    void 본문이_비었거나_JSON_배열이_아니면_ERROR로_기록한다() {
        ValidationReport report = validator.validate(List.of(
                choice("A", " "),
                choice("B", "SELECT 1")), expectedResult);

        assertThat(report.correctCount()).isZero();
        assertThat(report.items()).extracting(ValidationReport.ChoiceValidation::status)
                .containsExactly("ERROR", "ERROR");
        assertThat(report.items().get(0).error()).isEqualTo("body가 비어있습니다.");
        assertThat(report.items().get(1).error()).isEqualTo(ResultMatchChoiceValidator.BODY_NOT_JSON_ARRAY_MESSAGE);
    }

    private GeneratedChoiceDto choice(String key, String body) {
        return new GeneratedChoiceDto(key, body, false, "r");
    }
}
