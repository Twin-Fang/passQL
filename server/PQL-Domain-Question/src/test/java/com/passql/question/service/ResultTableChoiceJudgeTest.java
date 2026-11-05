package com.passql.question.service;

import com.passql.question.dto.ExecuteResult;
import com.passql.question.service.ResultTableChoiceJudge.Discard;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

/** 결과형 오답 후보 걸러내기 (#828): 틀리면 정답과 같은 오답·빈 결과·중복 표가 회원에게 나감 */
class ResultTableChoiceJudgeTest {

    // 부서별 인원·급여 합계 (부서 2 에 급여 NULL 1명)
    private static final List<String> COLUMNS = List.of("dept_id", "cnt", "total");
    private static final ExecuteResult EXPECTED = ok(COLUMNS, row(1, 2, 7000), row(2, 2, 5000));
    private static final ExecuteResult WRONG_COUNT = ok(COLUMNS, row(1, 2, 7000), row(2, 1, 5000));   // COUNT(SAL) 오해
    private static final ExecuteResult WRONG_MAX = ok(COLUMNS, row(1, 2, 4000), row(2, 2, 5000));     // SUM 대신 MAX 오해

    @SafeVarargs
    private static ExecuteResult ok(List<String> columns, List<Object>... rows) {
        return new ExecuteResult("OK", columns, List.of(rows), rows.length, 3, null, null);
    }

    private static List<Object> row(Object... cells) {
        return Arrays.asList(cells);
    }

    private static Map<String, ExecuteResult> results(ExecuteResult... resultsInOrder) {
        Map<String, ExecuteResult> resultsByKey = new LinkedHashMap<>();
        String[] keys = {"A", "B", "C", "D"};
        for (int index = 0; index < resultsInOrder.length; index++) {
            resultsByKey.put(keys[index], resultsInOrder[index]);
        }
        return resultsByKey;
    }

    @Test
    @DisplayName("오답 후보만 남김: 정답과 같음(7000 <-> 7000.00, 열 대소문자 무시)·빈 결과·열 다름·오류·이번 중복은 버림")
    void screensWrongTables() {
        ExecuteResult sameAsCorrect = ok(List.of("DEPT_ID", "CNT", "TOTAL"),
                row(2, 2, new BigDecimal("5000.00")), row(1, 2, 7000));
        var screening = ResultTableChoiceJudge.screen(EXPECTED,
                results(sameAsCorrect, WRONG_COUNT, ok(COLUMNS), WRONG_COUNT), Set.of());
        assertThat(screening.acceptedKeys()).containsExactly("B");
        assertThat(screening.discardByKey()).containsEntry("A", Discard.SAME_AS_CORRECT)
                .containsEntry("C", Discard.EMPTY_RESULT)
                .containsEntry("D", Discard.DUPLICATE_RESULT);

        ExecuteResult otherColumns = ok(List.of("dept_id", "cnt", "sum"), row(1, 2, 1));
        ExecuteResult error = new ExecuteResult("ERROR", List.of(), List.of(), 0, 3, "PSQLException", "syntax");
        var second = ResultTableChoiceJudge.screen(EXPECTED, results(otherColumns, error, WRONG_MAX), Set.of());
        assertThat(second.acceptedKeys()).containsExactly("C");
        assertThat(second.discardByKey()).containsEntry("A", Discard.COLUMN_MISMATCH)
                .containsEntry("B", Discard.EXECUTION_ERROR);
    }

    @Test
    @DisplayName("이전 시도에서 모은 오답과 같은 결과는 중복으로 버림")
    void discardsAlreadyCollected() {
        var screening = ResultTableChoiceJudge.screen(EXPECTED, results(WRONG_COUNT, WRONG_MAX),
                Set.of(ResultTableChoiceJudge.toSignature(WRONG_COUNT)));
        assertThat(screening.acceptedKeys()).containsExactly("B");
        assertThat(screening.discardByKey()).containsEntry("A", Discard.DUPLICATE_RESULT);
    }

    @Test
    @DisplayName("오답 해설은 결과 메모 줄과 '오답:' 꼬리표를 지우고 문장만 남김")
    void cleansRationale() {
        assertThat(ResultTableChoiceBuilder.toLearnerRationale(
                "결과: [2, 1, 5000], [1, 2, 7000]\n오답: COUNT(컬럼)은 NULL을 세지 않아 부서 2가 1명이 된다."))
                .isEqualTo("COUNT(컬럼)은 NULL을 세지 않아 부서 2가 1명이 된다.");
        assertThat(ResultTableChoiceBuilder.toLearnerRationale("결과: []")).isNull();
    }
}
