package com.passql.application.service.explanation;

import com.passql.question.dto.ExecuteResult;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/** 해설 근거 실행 결과 요약 (#555): 행 수·열·행 값(NULL 표기), 오류, 긴 결과 생략 */
class ChoiceSetExecutionEvidenceCollectorTest {

    @Test
    void 성공_결과는_행_수_열_행_값을_NULL_까지_요약한다() {
        ExecuteResult result = new ExecuteResult("SUCCESS", List.of("ID", "BONUS"),
                List.of(Arrays.asList(2, 50), Arrays.asList(3, null)), 2, 5, null, null);

        assertThat(ChoiceSetExecutionEvidenceCollector.toResultSummary(result))
                .isEqualTo("2행 | 열: ID, BONUS | 1행: 2, 50 | 2행: 3, NULL");
    }

    @Test
    void 오류_결과는_오류_코드만_남긴다() {
        ExecuteResult result = new ExecuteResult("ERROR", List.of(), List.of(), 0, 1, "SQL_SYNTAX_ERROR", "원문");

        assertThat(ChoiceSetExecutionEvidenceCollector.toResultSummary(result)).isEqualTo("실행 오류 SQL_SYNTAX_ERROR");
    }

    @Test
    void 상한을_넘는_행은_생략_표시한다() {
        List<List<Object>> rows = new ArrayList<>();
        for (int rowIndex = 0; rowIndex < ChoiceSetExecutionEvidenceCollector.MAX_SUMMARY_ROW_COUNT + 2; rowIndex++) {
            rows.add(List.of(rowIndex));
        }
        ExecuteResult result = new ExecuteResult("SUCCESS", List.of("N"), rows, rows.size(), 1, null, null);

        assertThat(ChoiceSetExecutionEvidenceCollector.toResultSummary(result)).endsWith("이하 2행 생략");
    }
}
