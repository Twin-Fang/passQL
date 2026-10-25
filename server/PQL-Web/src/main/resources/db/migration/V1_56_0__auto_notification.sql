-- =============================================================================
-- V1_56_0: 재방문 자동 알림 (#649)
-- 1. auto_notification_rule: 규칙 5종 (켜기/끄기, 발송 시각, 일수, 문구, 이동 화면) > 관리자 화면에서 제어
-- 2. auto_notification_log: 회원당 하루 자동 알림 1건 선점 (unique member_uuid + sent_date)
-- =============================================================================

-- 1. 자동 알림 규칙
--    rule_type: DAILY_SET_REMINDER | STREAK_RISK | COMEBACK_SHORT | COMEBACK_LONG | EXAM_COUNTDOWN
--    send_hour: 발송 시각 (0~23시, KST), threshold_days: 미접속 일수 (COMEBACK 규칙만)
--    title/body 의 {days} 는 미접속 일수 또는 시험까지 남은 일수로 치환
CREATE TABLE IF NOT EXISTS auto_notification_rule (
    auto_notification_rule_uuid UUID PRIMARY KEY,
    rule_type                   VARCHAR(30)  NOT NULL,
    is_enabled                  BOOLEAN      NOT NULL DEFAULT FALSE,
    send_hour                   INTEGER      NOT NULL,
    threshold_days              INTEGER,
    title                       VARCHAR(100) NOT NULL,
    body                        VARCHAR(500) NOT NULL,
    link_target                 VARCHAR(30)  NOT NULL,
    created_at                  TIMESTAMP(6),
    updated_at                  TIMESTAMP(6),
    created_by                  VARCHAR(255),
    updated_by                  VARCHAR(255),
    CONSTRAINT uk_auto_notification_rule_type UNIQUE (rule_type)
);

-- 2. 자동 발송 기록 (하루 1건 상한 + 최근 발송 건수 집계)
CREATE TABLE IF NOT EXISTS auto_notification_log (
    auto_notification_log_uuid UUID PRIMARY KEY,
    member_uuid                UUID         NOT NULL,
    rule_type                  VARCHAR(30)  NOT NULL,
    sent_date                  DATE         NOT NULL,
    created_at                 TIMESTAMP(6),
    updated_at                 TIMESTAMP(6),
    created_by                 VARCHAR(255),
    updated_by                 VARCHAR(255),
    CONSTRAINT uk_auto_notification_log_member_date UNIQUE (member_uuid, sent_date)
);
CREATE INDEX IF NOT EXISTS idx_auto_notification_log_date_rule ON auto_notification_log (sent_date, rule_type);

-- 3. 기본 규칙 5행 (전부 꺼짐: 실사용자에게 나가므로 관리자가 확인 후 켬)
INSERT INTO auto_notification_rule
    (auto_notification_rule_uuid, rule_type, is_enabled, send_hour, threshold_days, title, body, link_target, created_at, updated_at)
VALUES
    (gen_random_uuid(), 'DAILY_SET_REMINDER', FALSE, 20, NULL,
     '🔥 오늘의 세트 5문제, 3분이면 끝나요', '지금 풀면 오늘 학습이 완성돼요. 가볍게 시작해 볼까요?', 'DAILY_SET', NOW(), NOW()),
    (gen_random_uuid(), 'STREAK_RISK', FALSE, 21, NULL,
     '⏳ 연속 학습이 끊기기 전에!', '어제처럼 한 문제만 풀어도 연속 기록이 이어져요.', 'QUESTIONS', NOW(), NOW()),
    (gen_random_uuid(), 'COMEBACK_SHORT', FALSE, 12, 3,
     '👋 {days}일째 쉬고 있어요', 'SQLD 합격까지 한 걸음씩, 오늘 5문제로 다시 시작해요.', 'DAILY_SET', NOW(), NOW()),
    (gen_random_uuid(), 'COMEBACK_LONG', FALSE, 12, 7,
     '🌱 {days}일 만이에요, 반가워요', '부담 없이 한 문제부터 감각을 되살려 봐요.', 'HOME', NOW(), NOW()),
    (gen_random_uuid(), 'EXAM_COUNTDOWN', FALSE, 9, NULL,
     '📅 SQLD 시험이 D-{days}예요', '남은 기간 알차게 준비해요. 오늘의 학습을 시작해 볼까요?', 'STATS', NOW(), NOW())
ON CONFLICT (rule_type) DO NOTHING;
