package com.passql.question.service;

import com.passql.common.util.TextPreview;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.dto.ExecuteResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;

/**
 * 샌드박스 DB에서 SQL을 실행하고 결과를 반환한다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class SandboxExecutor {

    private final SandboxPool sandboxPool;

    /**
     * 임시 샌드박스 1회 실행 공통 지점: DB 획득 > DDL + 샘플 적용 > 작업(dbName) > 반납
     * DDL·샘플 모두 비면 적용 생략, 반납은 SandboxPool 이 보장 (성공·실패 공통)
     */
    public <T> T runInTemporarySandbox(String schemaDdl, String schemaSampleData, Function<String, T> sandboxTask) {
        return sandboxPool.runWithTemporaryDatabase(dbName -> {
            String setupSql = toSetupSql(schemaDdl, schemaSampleData);
            if (!setupSql.isBlank()) {
                applyDdl(dbName, setupSql);
            }
            return sandboxTask.apply(dbName);
        });
    }

    /**
     * 샌드박스 준비 실패 원인 문장 (DDL 오류 원문, 관리자 화면 전용)
     * 공개 API 응답에는 쓰지 않음 (응답 detail 은 고정 문구)
     */
    public static String toAdminFailureReason(Throwable failure) {
        Throwable cause = failure.getCause() != null ? failure.getCause() : failure;
        return cause.getMessage();
    }

    /** DDL + 샘플 INSERT > 실행할 준비 SQL 한 덩어리 (";\n" 연결) */
    private String toSetupSql(String schemaDdl, String schemaSampleData) {
        String setupSql = schemaDdl != null ? schemaDdl : "";
        if (schemaSampleData != null && !schemaSampleData.isBlank()) {
            setupSql = setupSql + ";\n" + schemaSampleData;
        }
        return setupSql;
    }

    /**
     * 특정 샌드박스 DB에 DDL + sample data 를 적용한다.
     */
    public void applyDdl(String dbName, String ddl) {
        try {
            try (Connection conn = sandboxPool.openConnection(dbName);
                 Statement stmt = conn.createStatement()) {
                String[] tokens = splitStatements(ddl);
                log.debug("[applyDdl] DB={} 총 {}개 토큰", dbName, tokens.length);
                for (int i = 0; i < tokens.length; i++) {
                    String sql = tokens[i];
                    if (!sql.isBlank()) {
                        String normalized = normalizeDdl(sql.trim());
                        log.debug("[applyDdl] [{}/{}] 실행: {}", i + 1, tokens.length,
                                TextPreview.truncateWithEllipsis(normalized, TextPreview.LOG_SQL_LENGTH));
                        stmt.execute(normalized);
                    }
                }
            }
        } catch (Exception e) {
            // 원인 메시지는 로그·cause 에만 (응답 detail 은 고정 문구)
            log.warn("[sandbox ddl] apply failed : db={}, error={}", dbName, e.getMessage());
            throw new CustomException(ErrorCode.SANDBOX_SETUP_FAILED, "DDL 적용 실패", e);
        }
    }

    /**
     * CREATE TABLE → CREATE TABLE IF NOT EXISTS 자동 변환.
     * 관리자가 IF NOT EXISTS를 빠뜨려도 sandbox에서 안전하게 실행되도록 보정한다.
     */
    private String normalizeDdl(String sql) {
        String upper = sql.toUpperCase();
        if (upper.startsWith("CREATE TABLE") && !upper.startsWith("CREATE TABLE IF NOT EXISTS")) {
            return sql.replaceFirst("(?i)CREATE\\s+TABLE\\s+", "CREATE TABLE IF NOT EXISTS ");
        }
        return sql;
    }

    /**
     * 샌드박스 DB에서 SQL을 실행하고 결과를 반환한다.
     */
    public ExecuteResult execute(String dbName, String sql) {
        long started = System.currentTimeMillis();
        try {
            try (Connection conn = sandboxPool.openConnection(dbName);
                 Statement stmt = conn.createStatement()) {
                stmt.setQueryTimeout(10); // 10초 타임아웃

                boolean hasResultSet = stmt.execute(sql);
                long elapsed = System.currentTimeMillis() - started;

                if (hasResultSet) {
                    ResultSet rs = stmt.getResultSet();
                    ResultSetMetaData meta = rs.getMetaData();
                    int colCount = meta.getColumnCount();
                    List<String> columns = new ArrayList<>();
                    for (int i = 1; i <= colCount; i++) {
                        columns.add(meta.getColumnLabel(i));
                    }
                    List<List<Object>> rows = new ArrayList<>();
                    while (rs.next()) {
                        List<Object> row = new ArrayList<>();
                        for (int i = 1; i <= colCount; i++) {
                            row.add(rs.getObject(i));
                        }
                        rows.add(row);
                    }
                    return new ExecuteResult("OK", columns, rows, rows.size(), elapsed, null, null);
                } else {
                    return new ExecuteResult("OK", List.of(), List.of(), 0, elapsed, null, null);
                }
            }
        } catch (Exception e) {
            long elapsed = System.currentTimeMillis() - started;
            return new ExecuteResult("ERROR", List.of(), List.of(), 0, elapsed,
                    e.getClass().getSimpleName(), e.getMessage());
        }
    }

    private String[] splitStatements(String sql) {
        return sql.split(";");
    }
}
