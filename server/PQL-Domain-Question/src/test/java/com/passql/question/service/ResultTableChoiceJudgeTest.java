package com.passql.question.service;

import com.passql.question.dto.ExecuteResult;
import com.passql.question.service.ResultTableChoiceJudge.Rejection;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/** 결과형 보기 판정 (#828): 틀리면 정답 2개·빈 결과·근거 없는 오답 표가 회원에게 나감 */
class ResultTableChoiceJudgeTest {

    // 부서별 인원·급여 합계 (부서 2 에 급여 NULL 1명)
    private static final List<String> COLUMNS = List.of("dept_id", "cnt", "total");
    private static final ExecuteResult EXPECTED = ok(COLUMNS, row(1, 2, 7000), row(2, 2, 5000));

    private static ExecuteResult ok(List<String> columns, List<Object>... rows) {
        return new ExecuteResult("OK", columns, List.of(rows), rows.length, 3, null, null);
    }

    private static List<Object> row(Object... cells) {
        return Arrays.asList(cells);
    }

    private static Map<String, ExecuteResult> choices(ExecuteResult a, ExecuteResult b, ExecuteResult c, ExecuteResult d) {
        Map<String, ExecuteResult> resultsByKey = new LinkedHashMap<>();
        resultsByKey.put("A", a);
        resultsByKey.put("B", b);
        resultsByKey.put("C", c);
        resultsByKey.put("D", d);
        return resultsByKey;
    }

    @Test
    @DisplayName("정답 1개 + 서로 다른 오답 3개면 통과 (숫자 7000 <-> 7000.00, 열 대소문자는 같은 값)")
    void accepts() {
        var verdict = ResultTableChoiceJudge.judge(EXPECTED, choices(
                ok(COLUMNS, row(1, 2, 7000), row(2, 1, 5000)),                     // COUNT(SAL) 오해
                ok(List.of("DEPT_ID", "CNT", "TOTAL"), row(2, 2, new BigDecimal("5000.00")), row(1, 2, 7000)),
                ok(COLUMNS, row(1, 2, 7000), row(2, 2, null)),                     // NULL 이 섞이면 합계 NULL 오해
                ok(COLUMNS, row(1, 2, 3500), row(2, 2, 5000))));                   // AVG 오해
        assertThat(verdict.isAccepted()).isTrue();
        assertThat(verdict.correctKey()).isEqualTo("B");
    }

    @Test
    @DisplayName("거부: 빈 오답, 오답끼리 같은 결과, 정답 2개, 열 다름, 실행 오류")
    void rejects() {
        ExecuteResult wrongCount = ok(COLUMNS, row(1, 2, 7000), row(2, 1, 5000));
        ExecuteResult wrongAverage = ok(COLUMNS, row(1, 2, 3500), row(2, 2, 5000));

        assertThat(ResultTableChoiceJudge.judge(EXPECTED, choices(EXPECTED, wrongCount, ok(COLUMNS), wrongAverage))
                .rejection()).isEqualTo(Rejection.EMPTY_WRONG_RESULT);
        assertThat(ResultTableChoiceJudge.judge(EXPECTED, choices(EXPECTED, wrongCount, wrongCount, wrongAverage))
                .rejectedKeys()).containsExactly("B", "C");
        assertThat(ResultTableChoiceJudge.judge(EXPECTED, choices(EXPECTED, EXPECTED, wrongCount, wrongAverage))
                .rejection()).isEqualTo(Rejection.MULTIPLE_CORRECT);
        assertThat(ResultTableChoiceJudge.judge(EXPECTED, choices(wrongCount, wrongCount, wrongAverage, wrongAverage))
                .rejection()).isEqualTo(Rejection.NO_CORRECT);
        assertThat(ResultTableChoiceJudge.judge(EXPECTED, choices(EXPECTED, wrongCount,
                ok(List.of("dept_id", "cnt", "sum"), row(1, 2, 1), row(2, 2, 2)), wrongAverage))
                .rejection()).isEqualTo(Rejection.COLUMN_MISMATCH);
        ExecuteResult error = new ExecuteResult("ERROR", List.of(), List.of(), 0, 3, "PSQLException", "syntax");
        assertThat(ResultTableChoiceJudge.judge(EXPECTED, choices(EXPECTED, wrongCount, error, wrongAverage))
                .rejection()).isEqualTo(Rejection.EXECUTION_ERROR);
    }
}
