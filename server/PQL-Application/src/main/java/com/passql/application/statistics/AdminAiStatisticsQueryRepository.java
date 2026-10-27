package com.passql.application.statistics;

import com.passql.ai.constant.AiCallSource;
import com.passql.application.constant.StatisticsRange;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 관리자 AI 사용량 읽기 전용 집계 (ai_call_log, PostgreSQL native): 묶음별 호출, 묶음·모델별 토큰, 실패 종류, 출처·경로·모델별 사용량
 * 토큰 수 null(모델·토큰 미기록 호출)은 0 으로 합산
 */
@Repository
@RequiredArgsConstructor
public class AdminAiStatisticsQueryRepository {

    // LLM 통계에서 빼는 호출 출처 (벡터 색인·검색, 토큰 과금 없음)
    private static final String VECTOR_SEARCH_SOURCE = AiCallSource.VECTOR_SEARCH.name();

    private final NamedParameterJdbcTemplate jdbcTemplate;

    /** 묶음별 LLM 호출 수·성공 수·지연 합 (벡터 색인·검색 제외, #699) */
    public List<AiCallBucketRow> countCallsByBucket(StatisticsRange range, LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT CAST(date_trunc(:unit, c.called_at) AS date), COUNT(*),
                       COUNT(*) FILTER (WHERE c.is_success = TRUE), COALESCE(SUM(c.latency_milliseconds), 0)
                FROM ai_call_log c
                WHERE c.called_at >= :start AND c.called_at < :end
                  AND c.call_source <> :vectorSearchSource
                GROUP BY 1
                """;
        return jdbcTemplate.query(sql, rangeParameters(range, start, end), (resultSet, rowNumber) -> new AiCallBucketRow(
                resultSet.getDate(1).toLocalDate(), resultSet.getLong(2), resultSet.getLong(3), resultSet.getLong(4)));
    }

    /** 묶음·모델별 토큰 합 (비용 계산 원본) */
    public List<AiTokenBucketRow> sumTokensByBucketAndModel(StatisticsRange range, LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT CAST(date_trunc(:unit, c.called_at) AS date), c.model_name,
                       COALESCE(SUM(c.prompt_token_count), 0), COALESCE(SUM(c.completion_token_count), 0)
                FROM ai_call_log c
                WHERE c.called_at >= :start AND c.called_at < :end
                GROUP BY 1, 2
                """;
        return jdbcTemplate.query(sql, rangeParameters(range, start, end), (resultSet, rowNumber) -> new AiTokenBucketRow(
                resultSet.getDate(1).toLocalDate(), resultSet.getString(2), resultSet.getLong(3), resultSet.getLong(4)));
    }

    /** 실패 LLM 호출의 error_type 별 건수 (since 이후, 벡터 색인·검색 제외) */
    public List<ErrorTypeCountRow> countFailuresByErrorType(LocalDateTime since) {
        String sql = """
                SELECT c.error_type, COUNT(*)
                FROM ai_call_log c
                WHERE c.is_success = FALSE AND c.called_at >= :since
                  AND c.call_source <> :vectorSearchSource
                GROUP BY c.error_type
                """;
        MapSqlParameterSource parameters = new MapSqlParameterSource("since", since)
                .addValue("vectorSearchSource", VECTOR_SEARCH_SOURCE);
        return jdbcTemplate.query(sql, parameters, (resultSet, rowNumber) -> new ErrorTypeCountRow(
                resultSet.getString(1), resultSet.getLong(2)));
    }

    /** 출처·경로·모델별 호출·실패·지연 합·토큰 합 (모델별·경로별 표 원본) */
    public List<AiUsageGroupRow> sumUsageBySourceEndpointAndModel(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT c.call_source, c.endpoint_path, c.model_name, COUNT(*),
                       COUNT(*) FILTER (WHERE c.is_success = FALSE),
                       COALESCE(SUM(c.latency_milliseconds), 0),
                       COALESCE(SUM(c.prompt_token_count), 0), COALESCE(SUM(c.completion_token_count), 0)
                FROM ai_call_log c
                WHERE c.called_at >= :start AND c.called_at < :end
                GROUP BY c.call_source, c.endpoint_path, c.model_name
                ORDER BY COUNT(*) DESC
                """;
        MapSqlParameterSource parameters = new MapSqlParameterSource().addValue("start", start).addValue("end", end);
        return jdbcTemplate.query(sql, parameters, (resultSet, rowNumber) -> new AiUsageGroupRow(
                resultSet.getString(1), resultSet.getString(2), resultSet.getString(3),
                resultSet.getLong(4), resultSet.getLong(5), resultSet.getLong(6), resultSet.getLong(7), resultSet.getLong(8)));
    }

    private static MapSqlParameterSource rangeParameters(StatisticsRange range, LocalDateTime start, LocalDateTime end) {
        return new MapSqlParameterSource()
                .addValue("start", start)
                .addValue("end", end)
                .addValue("unit", range.getTruncateUnit())
                .addValue("vectorSearchSource", VECTOR_SEARCH_SOURCE);
    }

    /** 묶음별 호출 수·성공 수·지연 합(ms) */
    public record AiCallBucketRow(LocalDate bucketStartDate, long callCount, long successCount,
                                  long totalLatencyMilliseconds) {}

    /** 묶음·모델별 토큰 합 (modelName 미기록이면 null) */
    public record AiTokenBucketRow(LocalDate bucketStartDate, String modelName, long promptTokenCount,
                                   long completionTokenCount) {}

    /** error_type 별 실패 건수 */
    public record ErrorTypeCountRow(String errorType, long count) {}

    /** 출처·경로·모델 1묶음 사용량 (callSource: AI_SERVER | GEMINI_DIRECT) */
    public record AiUsageGroupRow(String callSource, String endpointPath, String modelName, long callCount,
                                  long failureCount, long totalLatencyMilliseconds, long promptTokenCount,
                                  long completionTokenCount) {}
}
