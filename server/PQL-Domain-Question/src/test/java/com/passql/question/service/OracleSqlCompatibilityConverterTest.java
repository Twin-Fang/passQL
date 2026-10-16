package com.passql.question.service;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Oracle 문법 처리 고정: 1:1 치환 2개(NVL, SYSDATE) > 치환 불가 키워드 감지
 */
class OracleSqlCompatibilityConverterTest {

    private final QuestionImportExportService converter =
            new QuestionImportExportService(null, null, null, null, null, null, null);

    @Test
    void NVL과_SYSDATE는_PostgreSQL_문법으로_바꾼다() {
        assertThat(converter.translateOracleToPostgres("SELECT nvl (a, 0), SYSDATE, NVL2(a, b, c) FROM t"))
                .isEqualTo("SELECT COALESCE(a, 0), NOW(), NVL2(a, b, c) FROM t");
        assertThat(converter.translateOracleToPostgres(null)).isNull();
    }

    @Test
    void 치환할_수_없는_Oracle_전용_문법은_첫_키워드를_돌려준다() {
        assertThat(converter.detectOracleOnlySyntax("SELECT * FROM t CONNECT BY prior id = pid", null, null, null))
                .isEqualTo("CONNECT BY");
        assertThat(converter.detectOracleOnlySyntax("SELECT 1", "CREATE TABLE t (id int)", null, "select 1 from dual"))
                .isEqualTo("FROM DUAL");
        assertThat(converter.detectOracleOnlySyntax("SELECT decode(a, 1, 'x') FROM t", null, null, null))
                .isEqualTo("DECODE");
    }

    @Test
    void PostgreSQL에서_되는_문법이면_null이다() {
        assertThat(converter.detectOracleOnlySyntax("SELECT COALESCE(a, 0) FROM t FULL OUTER JOIN s ON true",
                null, null, null)).isNull();
        assertThat(converter.detectOracleOnlySyntax(null, null, null, null)).isNull();
    }
}
