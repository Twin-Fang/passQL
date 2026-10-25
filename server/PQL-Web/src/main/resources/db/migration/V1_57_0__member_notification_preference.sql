-- =============================================================================
-- V1_57_0: 회원별 자동 알림 수신 설정 (#653)
-- 그룹 3개(학습 리마인더·복귀 알림·시험 D-day) 켜기/끄기, 회원당 1행
-- 행이 없는 회원은 전부 수신으로 취급 (기존 회원 호환)
-- =============================================================================
CREATE TABLE IF NOT EXISTS member_notification_preference (
    member_uuid                UUID PRIMARY KEY,
    is_study_reminder_enabled  BOOLEAN NOT NULL DEFAULT TRUE,
    is_comeback_enabled        BOOLEAN NOT NULL DEFAULT TRUE,
    is_exam_countdown_enabled  BOOLEAN NOT NULL DEFAULT TRUE,
    created_at                 TIMESTAMP(6),
    updated_at                 TIMESTAMP(6),
    created_by                 VARCHAR(255),
    updated_by                 VARCHAR(255)
);
