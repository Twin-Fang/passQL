package com.passql.application.statistics;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 관리자 리텐션 읽기 전용 집계 (PostgreSQL native): N일 리텐션, 가입 주차 코호트, 기능별 이용 회원
 * 활동 기준 member_activity_hour (시간당 회원 1행, member_uuid 인덱스 사용), 테스트 계정 제외
 */
@Repository
@RequiredArgsConstructor
public class AdminRetentionQueryRepository {

    private final NamedParameterJdbcTemplate jdbcTemplate;

    /**
     * 가입일 + dayOffset 일에 활동한 회원 수 (가입일 + dayOffset 이 오늘 이전인 가입자만 대상)
     * 가입 시각이 [start, end) 인 회원
     */
    public RetentionCountRow countDayRetention(int dayOffset, LocalDateTime start, LocalDateTime end, LocalDate today) {
        String sql = """
                SELECT COUNT(*), COUNT(*) FILTER (WHERE EXISTS (
                           SELECT 1 FROM member_activity_hour a
                           WHERE a.member_uuid = c.member_uuid
                             AND a.activity_hour >= c.signup_date + CAST(:dayOffset AS integer)
                             AND a.activity_hour < c.signup_date + CAST(:dayOffset AS integer) + 1))
                FROM (SELECT m.member_uuid, CAST(m.created_at AS date) AS signup_date
                      FROM member m
                      WHERE m.is_test_account = FALSE AND m.created_at >= :start AND m.created_at < :end) c
                WHERE c.signup_date + CAST(:dayOffset AS integer) < :today
                """;
        MapSqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("dayOffset", dayOffset).addValue("start", start).addValue("end", end).addValue("today", today);
        return jdbcTemplate.queryForObject(sql, parameters, (resultSet, rowNumber) ->
                new RetentionCountRow(resultSet.getLong(1), resultSet.getLong(2)));
    }

    /** 가입 주차(월요일 시작)별 가입자 수 */
    public List<WeekCohortSizeRow> countCohortSizeByWeek(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT CAST(date_trunc('week', m.created_at) AS date), COUNT(*)
                FROM member m
                WHERE m.is_test_account = FALSE AND m.created_at >= :start AND m.created_at < :end
                GROUP BY 1
                ORDER BY 1
                """;
        MapSqlParameterSource parameters = new MapSqlParameterSource().addValue("start", start).addValue("end", end);
        return jdbcTemplate.query(sql, parameters, (resultSet, rowNumber) -> new WeekCohortSizeRow(
                resultSet.getDate(1).toLocalDate(), resultSet.getLong(2)));
    }

    /**
     * 가입 주차 코호트별 주차 오프셋(0 = 가입 주)에 활동한 회원 수
     * 오프셋 주가 아직 시작하지 않은 조합은 행이 없음 (maxWeekOffset 이하 오프셋만)
     */
    public List<WeekCohortRetentionRow> countWeeklyCohortRetention(LocalDateTime start, LocalDateTime end,
                                                                   int maxWeekOffset, LocalDate today) {
        String sql = """
                SELECT c.week_start_date, w.week_offset,
                       COUNT(*) FILTER (WHERE EXISTS (
                           SELECT 1 FROM member_activity_hour a
                           WHERE a.member_uuid = c.member_uuid
                             AND a.activity_hour >= c.week_start_date + w.week_offset * 7
                             AND a.activity_hour < c.week_start_date + (w.week_offset + 1) * 7))
                FROM (SELECT m.member_uuid, CAST(date_trunc('week', m.created_at) AS date) AS week_start_date
                      FROM member m
                      WHERE m.is_test_account = FALSE AND m.created_at >= :start AND m.created_at < :end) c
                CROSS JOIN generate_series(0, CAST(:maxWeekOffset AS integer)) AS w(week_offset)
                WHERE c.week_start_date + w.week_offset * 7 <= :today
                GROUP BY c.week_start_date, w.week_offset
                ORDER BY c.week_start_date, w.week_offset
                """;
        MapSqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("start", start).addValue("end", end).addValue("maxWeekOffset", maxWeekOffset).addValue("today", today);
        return jdbcTemplate.query(sql, parameters, (resultSet, rowNumber) -> new WeekCohortRetentionRow(
                resultSet.getDate(1).toLocalDate(), resultSet.getInt(2), resultSet.getLong(3)));
    }

    /** 구간에 활동 기록이 있는 회원 수 (기능 사용률의 분모) */
    public long countActiveMembers(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT COUNT(DISTINCT a.member_uuid)
                FROM member_activity_hour a
                JOIN member m ON m.member_uuid = a.member_uuid AND m.is_test_account = FALSE
                WHERE a.activity_hour >= :start AND a.activity_hour < :end
                """;
        Long count = jdbcTemplate.queryForObject(sql,
                new MapSqlParameterSource().addValue("start", start).addValue("end", end), Long.class);
        return count == null ? 0 : count;
    }

    /** 기능별 구간 이용 회원 수 (기능 순서 고정) */
    public List<FeatureUserCountRow> countFeatureUsers(LocalDateTime start, LocalDateTime end) {
        MapSqlParameterSource parameters = new MapSqlParameterSource().addValue("start", start).addValue("end", end);
        List<FeatureUserCountRow> rows = new ArrayList<>();
        for (FeatureSource featureSource : FeatureSource.values()) {
            // 테이블·컬럼명은 enum 상수 (사용자 입력 아님)
            String sql = """
                    SELECT COUNT(DISTINCT t.%1$s)
                    FROM %2$s t
                    JOIN member m ON m.member_uuid = t.%1$s AND m.is_test_account = FALSE
                    WHERE t.%3$s >= :start AND t.%3$s < :end
                    """.formatted(featureSource.memberColumnName, featureSource.tableName, featureSource.timeColumnName);
            Long userCount = jdbcTemplate.queryForObject(sql, parameters, Long.class);
            rows.add(new FeatureUserCountRow(featureSource.name(), featureSource.featureLabel, userCount == null ? 0 : userCount));
        }
        return rows;
    }

    /** 기능 이용 기록 출처: 테이블, 회원 컬럼, 시각 컬럼 (선언 순서 = 화면 표시 순서) */
    @Getter
    @RequiredArgsConstructor
    private enum FeatureSource {
        SUBMISSION("문제 풀이", "submission", "member_uuid", "submitted_at"),
        QUIZ_SESSION("퀴즈 시작", "quiz_session", "member_uuid", "started_at"),
        DAILY_SET("오늘의 세트 완료", "daily_set_submission", "member_uuid", "completed_at"),
        COMMUNITY_POST("토론 글 작성", "community_post", "author_member_uuid", "created_at"),
        COMMUNITY_LIKE("토론 좋아요", "community_post_like", "member_uuid", "created_at");

        private final String featureLabel;
        private final String tableName;
        private final String memberColumnName;
        private final String timeColumnName;
    }

    /** 대상 회원 수와 그중 활동한 회원 수 */
    public record RetentionCountRow(long eligibleCount, long retainedCount) {}

    /** 가입 주차별 가입자 수 */
    public record WeekCohortSizeRow(LocalDate weekStartDate, long cohortSize) {}

    /** 가입 주차·오프셋별 활동 회원 수 */
    public record WeekCohortRetentionRow(LocalDate weekStartDate, int weekOffset, long retainedCount) {}

    /** 기능별 이용 회원 수 */
    public record FeatureUserCountRow(String featureCode, String featureLabel, long userCount) {}
}
