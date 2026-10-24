package com.passql.application.monitor;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 모니터링 시간대별 집계 (PostgreSQL native): AI 호출, 서버 오류, SQL 실행
 * 시각 컬럼 인덱스(called_at·occurred_at·executed_at) 범위 조회 후 시 단위 묶음
 */
@Repository
@RequiredArgsConstructor
public class AdminMonitorQueryRepository {

    private final NamedParameterJdbcTemplate jdbcTemplate;

    /** 시간별 AI 호출 수·실패 수·지연 합(ms) */
    public List<HourlyCallRow> countAiCallsByHour(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT date_trunc('hour', c.called_at), COUNT(*),
                       COUNT(*) FILTER (WHERE c.is_success = FALSE), COALESCE(SUM(c.latency_milliseconds), 0)
                FROM ai_call_log c
                WHERE c.called_at >= :start AND c.called_at < :end
                GROUP BY 1
                """;
        return queryHourlyCalls(sql, start, end);
    }

    /** 시간별 SQL 실행 수·실패 수(OK 아님)·소요 합(ms) */
    public List<HourlyCallRow> countSqlExecutionsByHour(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT date_trunc('hour', e.executed_at), COUNT(*),
                       COUNT(*) FILTER (WHERE e.status <> 'OK'), COALESCE(SUM(e.elapsed_ms), 0)
                FROM execution_log e
                WHERE e.executed_at >= :start AND e.executed_at < :end
                GROUP BY 1
                """;
        return queryHourlyCalls(sql, start, end);
    }

    /** 시간별 서버 오류(5xx) 수 */
    public List<HourlyCountRow> countServerErrorsByHour(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT date_trunc('hour', s.occurred_at), COUNT(*)
                FROM server_error_log s
                WHERE s.occurred_at >= :start AND s.occurred_at < :end
                GROUP BY 1
                """;
        return jdbcTemplate.query(sql, periodParameters(start, end), (resultSet, rowNumber) -> new HourlyCountRow(
                resultSet.getTimestamp(1).toLocalDateTime(), resultSet.getLong(2)));
    }

    private List<HourlyCallRow> queryHourlyCalls(String sql, LocalDateTime start, LocalDateTime end) {
        return jdbcTemplate.query(sql, periodParameters(start, end), (resultSet, rowNumber) -> new HourlyCallRow(
                resultSet.getTimestamp(1).toLocalDateTime(), resultSet.getLong(2), resultSet.getLong(3), resultSet.getLong(4)));
    }

    private static MapSqlParameterSource periodParameters(LocalDateTime start, LocalDateTime end) {
        return new MapSqlParameterSource().addValue("start", start).addValue("end", end);
    }

    /** 시각(정시)별 호출·실패·지연 합 */
    public record HourlyCallRow(LocalDateTime hourStart, long callCount, long failureCount, long totalLatencyMilliseconds) {}

    /** 시각(정시)별 건수 */
    public record HourlyCountRow(LocalDateTime hourStart, long count) {}
}
