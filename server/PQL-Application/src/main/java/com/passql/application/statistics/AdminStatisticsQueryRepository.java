package com.passql.application.statistics;

import com.passql.application.community.CommunityAdminService;
import com.passql.application.constant.StatisticsRange;
import com.passql.application.statistics.dto.DashboardCommunityResponse.RecentCommunityPost;
import com.passql.common.util.TextPreview;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 관리자 통계 읽기 전용 집계 (PostgreSQL native): 가입·방문·제출·토론·토픽별 풀이
 * 테스트 계정 제외 (member.is_test_account), 시각은 서버 로컬 LocalDateTime 그대로 비교
 */
@Repository
@RequiredArgsConstructor
public class AdminStatisticsQueryRepository {

    // 제출·활동·글 작성자가 테스트 계정이 아님 (member 행 없는 탈퇴 정리 건도 포함)
    private static final String NOT_TEST_MEMBER_OF_SUBMISSION =
            "NOT EXISTS (SELECT 1 FROM member tm WHERE tm.member_uuid = s.member_uuid AND tm.is_test_account = TRUE)";
    private static final String NOT_TEST_MEMBER_OF_ACTIVITY =
            "NOT EXISTS (SELECT 1 FROM member tm WHERE tm.member_uuid = a.member_uuid AND tm.is_test_account = TRUE)";
    private static final String NOT_TEST_MEMBER_OF_POST =
            "NOT EXISTS (SELECT 1 FROM member tm WHERE tm.member_uuid = p.author_member_uuid AND tm.is_test_account = TRUE)";
    // 대시보드 최근 글 본문 미리보기 (문자 수)
    private static final int RECENT_POST_PREVIEW_LENGTH = 60;

    private final NamedParameterJdbcTemplate jdbcTemplate;

    /** 묶음별 가입 수 + 지금 남아 있는(비삭제) 가입 수 */
    public List<SignupBucketRow> countSignupsByBucket(StatisticsRange range, LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT CAST(date_trunc(:unit, m.created_at) AS date) AS bucket_start_date,
                       COUNT(*) AS signup_count,
                       COUNT(*) FILTER (WHERE m.is_deleted = FALSE) AS remaining_member_count
                FROM member m
                WHERE m.is_test_account = FALSE AND m.created_at >= :start AND m.created_at < :end
                GROUP BY 1
                """;
        return jdbcTemplate.query(sql, rangeParameters(range, start, end), (resultSet, rowNumber) -> new SignupBucketRow(
                toLocalDate(resultSet, 1), resultSet.getLong(2), resultSet.getLong(3)));
    }

    /** before 이전 가입해 지금 남아 있는 회원 수 (누적 회원 수 시작값, 대시보드 totalMembers 와 같은 기준) */
    public long countRemainingMembersCreatedBefore(LocalDateTime before) {
        String sql = """
                SELECT COUNT(*) FROM member m
                WHERE m.is_test_account = FALSE AND m.is_deleted = FALSE AND m.created_at < :before
                """;
        return queryForLong(sql, new MapSqlParameterSource("before", before));
    }

    /** 구간 가입 수 (탈퇴 포함) */
    public long countSignups(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT COUNT(*) FROM member m
                WHERE m.is_test_account = FALSE AND m.created_at >= :start AND m.created_at < :end
                """;
        return queryForLong(sql, periodParameters(start, end));
    }

    /** 묶음별 방문자 수 (활동 기록 distinct 회원) */
    public List<BucketCountRow> countVisitorsByBucket(StatisticsRange range, LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT CAST(date_trunc(:unit, a.activity_hour) AS date), COUNT(DISTINCT a.member_uuid)
                FROM member_activity_hour a
                WHERE a.activity_hour >= :start AND a.activity_hour < :end AND %s
                GROUP BY 1
                """.formatted(NOT_TEST_MEMBER_OF_ACTIVITY);
        return jdbcTemplate.query(sql, rangeParameters(range, start, end), (resultSet, rowNumber) -> new BucketCountRow(
                toLocalDate(resultSet, 1), resultSet.getLong(2)));
    }

    /** 구간 방문자 수 (activity_hour 는 정시 내림 값) */
    public long countVisitors(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT COUNT(DISTINCT a.member_uuid)
                FROM member_activity_hour a
                WHERE a.activity_hour >= :start AND a.activity_hour < :end AND %s
                """.formatted(NOT_TEST_MEMBER_OF_ACTIVITY);
        return queryForLong(sql, periodParameters(start, end));
    }

    /** 시간대(0~23)별 방문 회원 수 합 (시간당 회원 1행이라 행 수 = 시간대별 distinct 합) */
    public List<HourCountRow> countVisitorsByHourOfDay(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT CAST(EXTRACT(HOUR FROM a.activity_hour) AS integer), COUNT(*)
                FROM member_activity_hour a
                WHERE a.activity_hour >= :start AND a.activity_hour < :end AND %s
                GROUP BY 1
                """.formatted(NOT_TEST_MEMBER_OF_ACTIVITY);
        return jdbcTemplate.query(sql, periodParameters(start, end), (resultSet, rowNumber) -> new HourCountRow(
                resultSet.getInt(1), resultSet.getLong(2)));
    }

    /** 일별 제출 수·정답 수 */
    public List<SubmissionBucketRow> countSubmissionsByDay(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT CAST(date_trunc('day', s.submitted_at) AS date), COUNT(*),
                       COUNT(*) FILTER (WHERE s.is_correct = TRUE)
                FROM submission s
                WHERE s.submitted_at >= :start AND s.submitted_at < :end AND %s
                GROUP BY 1
                """.formatted(NOT_TEST_MEMBER_OF_SUBMISSION);
        return jdbcTemplate.query(sql, periodParameters(start, end), (resultSet, rowNumber) -> new SubmissionBucketRow(
                toLocalDate(resultSet, 1), resultSet.getLong(2), resultSet.getLong(3)));
    }

    /** 토픽별 제출 수 (since 이후) */
    public List<TopicCountRow> countSubmissionsByTopic(LocalDateTime since) {
        String sql = """
                SELECT q.topic_uuid, COUNT(*)
                FROM submission s
                JOIN question q ON q.question_uuid = s.question_uuid
                WHERE s.submitted_at >= :since AND %s
                GROUP BY q.topic_uuid
                """.formatted(NOT_TEST_MEMBER_OF_SUBMISSION);
        return jdbcTemplate.query(sql, new MapSqlParameterSource("since", since), (resultSet, rowNumber) -> new TopicCountRow(
                resultSet.getObject(1, UUID.class), resultSet.getLong(2)));
    }

    /** 일별 토론 새 글 수 (삭제 제외) */
    public List<BucketCountRow> countCommunityPostsByDay(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT CAST(date_trunc('day', p.created_at) AS date), COUNT(*)
                FROM community_post p
                WHERE p.status <> 'DELETED' AND p.created_at >= :start AND p.created_at < :end AND %s
                GROUP BY 1
                """.formatted(NOT_TEST_MEMBER_OF_POST);
        return jdbcTemplate.query(sql, periodParameters(start, end), (resultSet, rowNumber) -> new BucketCountRow(
                toLocalDate(resultSet, 1), resultSet.getLong(2)));
    }

    /** 최근 토론 글 limit 건 (삭제 제외, 작성자 닉네임 포함) */
    public List<RecentCommunityPost> findRecentCommunityPosts(int limit) {
        String sql = """
                SELECT p.post_uuid, p.board_type, p.content, p.like_count, p.comment_count, p.status,
                       p.report_count, p.created_at, m.nickname
                FROM community_post p
                LEFT JOIN member m ON m.member_uuid = p.author_member_uuid
                WHERE p.status <> 'DELETED' AND %s
                ORDER BY p.created_at DESC
                LIMIT :limit
                """.formatted(NOT_TEST_MEMBER_OF_POST);
        return jdbcTemplate.query(sql, new MapSqlParameterSource("limit", limit), (resultSet, rowNumber) -> new RecentCommunityPost(
                resultSet.getObject("post_uuid", UUID.class),
                resultSet.getString("board_type"),
                TextPreview.truncateWithEllipsis(resultSet.getString("content"), RECENT_POST_PREVIEW_LENGTH),
                toAuthorNickname(resultSet.getString("nickname")),
                resultSet.getLong("like_count"),
                resultSet.getLong("comment_count"),
                resultSet.getString("status"),
                resultSet.getLong("report_count"),
                resultSet.getObject("created_at", LocalDateTime.class)));
    }

    /** 월별·가입 경로별 가입 수 (탈퇴 포함) */
    public List<ProviderSignupRow> countMonthlySignupsByProvider(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT CAST(date_trunc('month', m.created_at) AS date), m.auth_provider, COUNT(*)
                FROM member m
                WHERE m.is_test_account = FALSE AND m.created_at >= :start AND m.created_at < :end
                GROUP BY 1, 2
                ORDER BY 2
                """;
        return jdbcTemplate.query(sql, periodParameters(start, end), (resultSet, rowNumber) -> new ProviderSignupRow(
                toLocalDate(resultSet, 1), resultSet.getString(2), resultSet.getLong(3)));
    }

    private long queryForLong(String sql, MapSqlParameterSource parameters) {
        Long count = jdbcTemplate.queryForObject(sql, parameters, Long.class);
        return count == null ? 0 : count;
    }

    private static MapSqlParameterSource periodParameters(LocalDateTime start, LocalDateTime end) {
        return new MapSqlParameterSource().addValue("start", start).addValue("end", end);
    }

    private static MapSqlParameterSource rangeParameters(StatisticsRange range, LocalDateTime start, LocalDateTime end) {
        return periodParameters(start, end).addValue("unit", range.getTruncateUnit());
    }

    /** member 행 없는 작성자 > 탈퇴회원 표기 */
    private static String toAuthorNickname(String nickname) {
        return nickname == null ? CommunityAdminService.WITHDRAWN_AUTHOR_NICKNAME : nickname;
    }

    private static LocalDate toLocalDate(ResultSet resultSet, int columnIndex) throws SQLException {
        return resultSet.getDate(columnIndex).toLocalDate();
    }

    /** 묶음 시작일별 건수 */
    public record BucketCountRow(LocalDate bucketStartDate, long count) {}

    /** 묶음별 가입 수 (signupCount 탈퇴 포함, remainingMemberCount 비삭제만) */
    public record SignupBucketRow(LocalDate bucketStartDate, long signupCount, long remainingMemberCount) {}

    /** 일별 제출 수·정답 수 */
    public record SubmissionBucketRow(LocalDate bucketStartDate, long submissionCount, long correctCount) {}

    /** 시간대(0~23)별 건수 */
    public record HourCountRow(int hourOfDay, long count) {}

    /** 토픽별 건수 */
    public record TopicCountRow(UUID topicUuid, long count) {}

    /** 월별·가입 경로별 가입 수 */
    public record ProviderSignupRow(LocalDate monthStartDate, String authProvider, long count) {}
}
