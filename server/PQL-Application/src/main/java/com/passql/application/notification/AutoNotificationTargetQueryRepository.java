package com.passql.application.notification;

import com.passql.member.constant.AutoNotificationGroup;
import com.passql.member.constant.AutoNotificationRuleType;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * 자동 알림 대상 조회·하루 1건 선점·최근 발송 건수 (PostgreSQL native)
 * 공통 대상: 삭제·탈퇴 아님 + 수신 동의 푸시 기기 보유 + 오늘 자동 알림을 아직 안 받음 + 그 알림 그룹을 끄지 않음
 */
@Repository
@RequiredArgsConstructor
public class AutoNotificationTargetQueryRepository {

    // 공통 조건 (alias m = member)
    private static final String COMMON_CONDITION = """
            m.is_deleted = FALSE AND m.status <> 'WITHDRAWN'
              AND EXISTS (SELECT 1 FROM member_push_token t WHERE t.member_uuid = m.member_uuid AND t.is_push_enabled = TRUE)
              AND NOT EXISTS (SELECT 1 FROM auto_notification_log l WHERE l.member_uuid = m.member_uuid AND l.sent_date = :today)
            """;

    // 규칙별 추가 조건
    private static final String DAILY_SET_NOT_SOLVED = """
            AND NOT EXISTS (SELECT 1 FROM daily_set_submission d WHERE d.member_uuid = m.member_uuid AND d.challenge_date = :today)
            """;
    // 어제 풀이 있음 > 오늘 풀이·세트 없음
    private static final String STREAK_AT_RISK = """
            AND EXISTS (SELECT 1 FROM submission s WHERE s.member_uuid = m.member_uuid
                        AND s.submitted_at >= CAST(:yesterday AS timestamp) AND s.submitted_at < CAST(:today AS timestamp))
            AND NOT EXISTS (SELECT 1 FROM submission s WHERE s.member_uuid = m.member_uuid
                            AND s.submitted_at >= CAST(:today AS timestamp))
            AND NOT EXISTS (SELECT 1 FROM daily_set_submission d WHERE d.member_uuid = m.member_uuid AND d.challenge_date = :today)
            """;
    // 마지막 접속 날짜 == 오늘 - N일
    private static final String LAST_SEEN_EXACT_DAYS_AGO = """
            AND m.last_seen_at IS NOT NULL AND CAST(m.last_seen_at AS date) = CAST(:today AS date) - CAST(:thresholdDays AS integer)
            """;

    private final NamedParameterJdbcTemplate jdbcTemplate;

    /** 규칙 대상 회원 (thresholdDays 는 COMEBACK 규칙만 사용) */
    public List<UUID> findTargetMemberUuids(AutoNotificationRuleType ruleType, LocalDate today, Integer thresholdDays) {
        String sql = "SELECT m.member_uuid FROM member m WHERE " + COMMON_CONDITION
                + groupOptOutCondition(ruleType.getGroup()) + extraCondition(ruleType);
        MapSqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("today", today).addValue("yesterday", today.minusDays(1))
                .addValue("thresholdDays", thresholdDays == null ? 0 : thresholdDays);
        return jdbcTemplate.query(sql, parameters, (resultSet, rowNumber) -> resultSet.getObject(1, UUID.class));
    }

    /** 회원당 하루 1건 선점: 이미 있으면 false (동시 인스턴스·재실행 중복 방지) */
    public boolean tryClaim(UUID memberUuid, AutoNotificationRuleType ruleType, LocalDate today) {
        String sql = """
                INSERT INTO auto_notification_log (auto_notification_log_uuid, member_uuid, rule_type, sent_date, created_at, updated_at)
                VALUES (gen_random_uuid(), :memberUuid, :ruleType, :today, NOW(), NOW())
                ON CONFLICT (member_uuid, sent_date) DO NOTHING
                """;
        MapSqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("memberUuid", memberUuid).addValue("ruleType", ruleType.name()).addValue("today", today);
        return jdbcTemplate.update(sql, parameters) == 1;
    }

    /** 규칙별 최근 발송 건수 (기준일 포함 직전 days 일) */
    public int countSentSince(AutoNotificationRuleType ruleType, LocalDate sinceDate) {
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM auto_notification_log WHERE rule_type = :ruleType AND sent_date >= :sinceDate",
                new MapSqlParameterSource().addValue("ruleType", ruleType.name()).addValue("sinceDate", sinceDate),
                Integer.class);
        return count == null ? 0 : count;
    }

    // 회원이 그 그룹을 끈 경우 제외 (설정 행이 없으면 수신)
    private static String groupOptOutCondition(AutoNotificationGroup group) {
        String column = switch (group) {
            case STUDY_REMINDER -> "is_study_reminder_enabled";
            case COMEBACK -> "is_comeback_enabled";
            case EXAM_COUNTDOWN -> "is_exam_countdown_enabled";
        };
        return " AND NOT EXISTS (SELECT 1 FROM member_notification_preference p WHERE p.member_uuid = m.member_uuid AND p."
                + column + " = FALSE) ";
    }

    private static String extraCondition(AutoNotificationRuleType ruleType) {
        return switch (ruleType) {
            case DAILY_SET_REMINDER -> DAILY_SET_NOT_SOLVED;
            case STREAK_RISK -> STREAK_AT_RISK;
            case COMEBACK_SHORT, COMEBACK_LONG -> LAST_SEEN_EXACT_DAYS_AGO;
            case EXAM_COUNTDOWN -> "";
        };
    }
}
