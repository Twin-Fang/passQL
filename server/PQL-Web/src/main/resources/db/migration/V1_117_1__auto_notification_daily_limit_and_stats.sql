-- =============================================================================
-- V1_117_1: 재방문 자동 알림 하루 상한 설정·열람/복귀 통계 (#649)
-- 1. app_setting: 회원당 하루 자동 알림 최대 건수 (기본 1 = 기존 동작)
-- 2. auto_notification_log: 하루 순번(daily_sequence) + 알림함 알림 연결(member_notification_uuid)
-- 3. 유니크 교체: (회원, 날짜) > (회원, 날짜, 순번) 상한 선점 + (회원, 날짜, 규칙) 같은 규칙 하루 1건
-- =============================================================================

-- 1. 하루 상한 설정 (관리자 > 자동 알림 또는 설정 화면에서 변경)
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES (gen_random_uuid(), 'notification.auto.daily_limit_per_member', 'INT', '1', 'NOTIFICATION',
        '회원당 하루 자동 알림 최대 건수 (건, 1~5, 범위 밖이면 1)')
ON CONFLICT (setting_key) DO NOTHING;

-- 2. 하루 순번 (기존 행은 하루 1건이었으므로 1), 알림함 알림 (열람·복귀 집계용, 이전 행은 NULL)
ALTER TABLE auto_notification_log ADD COLUMN IF NOT EXISTS daily_sequence INTEGER NOT NULL DEFAULT 1;
ALTER TABLE auto_notification_log ADD COLUMN IF NOT EXISTS member_notification_uuid UUID;

-- 3. 유니크 교체 (기존 행은 회원·날짜당 1행이라 새 유니크와 충돌 없음)
ALTER TABLE auto_notification_log DROP CONSTRAINT IF EXISTS uk_auto_notification_log_member_date;
CREATE UNIQUE INDEX IF NOT EXISTS uk_auto_notification_log_member_date_sequence
    ON auto_notification_log (member_uuid, sent_date, daily_sequence);
CREATE UNIQUE INDEX IF NOT EXISTS uk_auto_notification_log_member_date_rule
    ON auto_notification_log (member_uuid, sent_date, rule_type);
