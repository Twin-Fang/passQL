package com.passql.question.dto;

import com.passql.question.constant.ExecutionMode;

/**
 * Oracle 호환 처리 결과: 치환된 DDL·샘플 데이터·정답 SQL, 치환 후 남은 Oracle 전용 키워드(없으면 null)
 * 직접 등록·가져오기 검증·가져오기 저장 공통 (OracleSqlCompatibilityConverter.toPostgresCompatible)
 */
public record PostgresCompatibleSql(
        String schemaDdl,
        String schemaSampleData,
        String answerSql,
        String oracleOnlyKeyword) {

    public boolean hasOracleOnlySyntax() {
        return oracleOnlyKeyword != null;
    }

    /** 요청 실행 모드 > 저장 실행 모드 (EXECUTABLE 인데 Oracle 전용 문법이 남으면 CONCEPT_ONLY, 그 외 그대로) */
    public ExecutionMode resolveExecutionMode(ExecutionMode requestedMode) {
        if (requestedMode == ExecutionMode.EXECUTABLE && hasOracleOnlySyntax()) {
            return ExecutionMode.CONCEPT_ONLY;
        }
        return requestedMode;
    }
}
