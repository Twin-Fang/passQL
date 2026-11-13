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
 * 자동 알림 대상 조회·하루 상한 선점·최근 발송 통계 (PostgreSQL native)
 * 공통 대상: 삭제·탈퇴 아님 + 수신 동의 푸시 기기 보유 + 오늘 받은 자동 알림 < 하루 상한 + 오늘 그 규칙 미수신 + 그 알림 그룹을 끄지 않음
 */
@Repository
@RequiredArgsConstructor
public class AutoNotificationTargetQueryRepository {

    // 공통 조건 (alias m = member)
    private static final String COMMON_CONDITION = """
            m.is_deleted = FALSE AND m.status <> 'WITHDRAWN'
              AND EXISTS (SELECT 1 FROM member_push_token t WHERE t.member_uuid = m.member_uuid AND t.is_push_enabled = TRUE)
              AND (SELECT COUNT(*) FROM auto_notification_log l WHERE l.member_uuid = m.member_uuid AND l.sent_date = :today) < :dailyLimit
              AND NOT EXISTS (SELECT 1 FROM auto_notification_log l WHERE l.member_uuid = m.member_uuid AND l.sent_date = :today
                              AND l.rule_type = :ruleType)
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

    // 복귀 판정 구간: 알림 저장 시각이 속한 시(시 단위 활동 기록) ~ 저장 후 24시간
    private static final String RETURNED_WITHIN_DAY = """
            EXISTS (SELECT 1 FROM member_activity_hour a WHERE a.member_uuid = l.member_uuid
                    AND a.activity_hour >= date_trunc('hour', n.created_at) AND a.activity_hour < n.created_at + INTERVAL '24 hours')
            """;

    private final NamedParameterJdbcTemplate jdbcTemplate;

    /** 규칙별 최근 발송 통계: 발송 / 알림함 연결(집계 가능) / 열람 / 24시간 내 복귀 (열람·복귀는 연결된 건만) */
    public record DeliveryStats(int sentCount, int trackedCount, int readCount, int returnedCount) {
    }

    /** 규칙 대상 회원 (thresholdDays 는 COMEBACK 규칙만 사용) */
    public List<UUID> findTargetMemberUuids(AutoNotificationRuleType ruleType, LocalDate today, Integer thresholdDays,
                                            int dailyLimit) {
        String sql = "SELECT m.member_uuid FROM member m WHERE " + COMMON_CONDITION
                + groupOptOutCondition(ruleType.getGroup()) + extraCondition(ruleType);
        MapSqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("today", today).addValue("yesterday", today.minusDays(1))
                .addValue("thresholdDays", thresholdDays == null ? 0 : thresholdDays)
                .addValue("ruleType", ruleType.name()).addValue("dailyLimit", dailyLimit);
        return jdbcTemplate.query(sql, parameters, (resultSet, rowNumber) -> resultSet.getObject(1, UUID.class));
    }

    /**
     * 하루 상한 선점: 다음 순번(오늘 최대 순번 + 1)이 상한 이하일 때만 기록 > 성공 여부
     * 유니크 2개(회원·날짜·순번 / 회원·날짜·규칙)가 동시 인스턴스·재실행 중복을 막음 (충돌 시 false)
     */
    public boolean tryClaim(UUID autoNotificationLogUuid, UUID memberUuid, AutoNotificationRuleType ruleType,
                            LocalDate today, int dailyLimit) {
        String sql = """
                INSERT INTO auto_notification_log
                    (auto_notification_log_uuid, member_uuid, rule_type, sent_date, daily_sequence, created_at, updated_at)
                SELECT :logUuid, :memberUuid, :ruleType, :today, claimed.next_sequence, NOW(), NOW()
                FROM (SELECT COALESCE(MAX(daily_sequence), 0) + 1 AS next_sequence FROM auto_notification_log
                      WHERE member_uuid = :memberUuid AND sent_date = :today) claimed
                WHERE claimed.next_sequence <= :dailyLimit
                ON CONFLICT DO NOTHING
                """;
        MapSqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("logUuid", autoNotificationLogUuid).addValue("memberUuid", memberUuid)
                .addValue("ruleType", ruleType.name()).addValue("today", today).addValue("dailyLimit", dailyLimit);
        return jdbcTemplate.update(sql, parameters) == 1;
    }

    /** 발송 기록 <-> 알림함 알림 연결 (열람·복귀 집계용) */
    public void linkMemberNotification(UUID autoNotificationLogUuid, UUID memberNotificationUuid) {
        jdbcTemplate.update(
                "UPDATE auto_notification_log SET member_notification_uuid = :notificationUuid, updated_at = NOW() "
                        + "WHERE auto_notification_log_uuid = :logUuid",
                new MapSqlParameterSource().addValue("notificationUuid", memberNotificationUuid)
                        .addValue("logUuid", autoNotificationLogUuid));
    }

    /** 규칙별 최근 발송 통계 (기준일 포함 이후, 열람 = 알림함 읽음, 복귀 = 24시간 내 앱 활동) */
    public DeliveryStats summarizeDeliverySince(AutoNotificationRuleType ruleType, LocalDate sinceDate) {
        String sql = """
                SELECT COUNT(*) AS sent_count,
                       COUNT(n.member_notification_uuid) AS tracked_count,
                       COUNT(n.read_at) AS read_count,
                       COUNT(*) FILTER (WHERE n.member_notification_uuid IS NOT NULL AND %s) AS returned_count
                FROM auto_notification_log l
                LEFT JOIN member_notification n ON n.member_notification_uuid = l.member_notification_uuid
                WHERE l.rule_type = :ruleType AND l.sent_date >= :sinceDate
                """.formatted(RETURNED_WITHIN_DAY);
        return jdbcTemplate.queryForObject(sql,
                new MapSqlParameterSource().addValue("ruleType", ruleType.name()).addValue("sinceDate", sinceDate),
                (resultSet, rowNumber) -> new DeliveryStats(resultSet.getInt("sent_count"), resultSet.getInt("tracked_count"),
                        resultSet.getInt("read_count"), resultSet.getInt("returned_count")));
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
            // 시험 일정 규칙: 대상은 전체 수신 동의 회원, 발송일 판정은 ExamNotificationOccasionFinder
            case EXAM_COUNTDOWN, EXAM_SCHEDULE_PUBLISHED, EXAM_APPLICATION_OPEN, EXAM_APPLICATION_CLOSING,
                 EXAM_ADMISSION_TICKET, EXAM_RESULT_ANNOUNCED -> "";
        };
    }
}
