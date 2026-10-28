package com.passql.question.service;

import com.passql.question.dto.ExecuteResult;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/** 실행 결과 캐시 저장 판정·SQL 정리 (#727): 틀리면 다른 회원에게 잘못된 결과가 공유됨 */
class CachedSandboxExecutorTest {

    private static ExecuteResult okResult(int rowCount) {
        return new ExecuteResult("OK", List.of("count"), List.of(List.of(rowCount)), rowCount, 12, null, null);
    }

    private static ExecuteResult errorResult(String errorCode, String errorMessage) {
        return new ExecuteResult("ERROR", List.of(), List.of(), 0, 10_000, errorCode, errorMessage);
    }

    @Test
    @DisplayName("읽기 SQL 성공·늘 같은 SQL 오류만 저장, 시간 초과·연결 오류·쓰기 SQL 은 저장 안 함")
    void isCacheable() {
        assertThat(CachedSandboxExecutor.isCacheable("SELECT 1", okResult(1))).isTrue();
        assertThat(CachedSandboxExecutor.isCacheable(" with t as (select 1) select * from t", okResult(1))).isTrue();
        assertThat(CachedSandboxExecutor.isCacheable("SELECT x FROM t",
                errorResult("PSQLException", "ERROR: column \"x\" does not exist"))).isTrue();

        assertThat(CachedSandboxExecutor.isCacheable("SELECT pg_sleep(20)",
                errorResult("PSQLException", "ERROR: canceling statement due to user request"))).isFalse();
        assertThat(CachedSandboxExecutor.isCacheable("SELECT 1",
                errorResult("PSQLException", "This connection has been closed."))).isFalse();
        assertThat(CachedSandboxExecutor.isCacheable("SELECT 1",
                errorResult("SQLTimeoutException", "query timed out"))).isFalse();
        assertThat(CachedSandboxExecutor.isCacheable("UPDATE t SET a = 1", okResult(0))).isFalse();
        assertThat(CachedSandboxExecutor.isCacheable("SELECT * FROM big", okResult(1_001))).isFalse();
    }

    @Test
    @DisplayName("SQL 정리: 앞뒤 공백·끝 세미콜론·줄바꿈 차이는 같은 키, 문자열 안 공백은 유지")
    void toNormalizedSql() {
        assertThat(CachedSandboxExecutor.toNormalizedSql("  SELECT 1;\r\n"))
                .isEqualTo(CachedSandboxExecutor.toNormalizedSql("SELECT 1"));
        assertThat(CachedSandboxExecutor.toNormalizedSql("SELECT 'a  b' ;;"))
                .isEqualTo("SELECT 'a  b'");
    }
}
