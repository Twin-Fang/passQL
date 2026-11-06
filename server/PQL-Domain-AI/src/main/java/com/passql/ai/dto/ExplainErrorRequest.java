package com.passql.ai.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

/** SQL 오류 해설 요청: 문제, 실행한 SQL, 오류 메시지 (sql·errorMessage 형식 검사는 서비스) */
public record ExplainErrorRequest(
    @NotNull UUID questionUuid,
    String sql,
    String errorMessage
) {
}
