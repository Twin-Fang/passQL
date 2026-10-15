package com.passql.submission.dto;

/**
 * SQL 실행 통계 (최근 24시간, execution_log DB 집계, #475)
 * failCount: status 가 OK 가 아닌 실행 (회원 SQL 오류 포함)
 */
public record MonitorStats(
        long successCount,
        long failCount,
        double avgElapsedMs
) {}
