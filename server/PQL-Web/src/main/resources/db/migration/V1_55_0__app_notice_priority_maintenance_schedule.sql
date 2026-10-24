-- 공지 노출 우선순위 + 점검 예약 시각 (#630)
-- display_priority: 클수록 먼저 노출 (중요 공지 안에서, 기본 0)
ALTER TABLE app_notice ADD COLUMN IF NOT EXISTS display_priority INT NOT NULL DEFAULT 0;

-- 점검 예약: KST 시각 문자열 (yyyy-MM-dd'T'HH:mm, 빈 값이면 예약 없음)
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'app.maintenance.starts_at', 'STRING', '', 'APP', '점검 예약 시작 (KST, yyyy-MM-ddTHH:mm, 비우면 예약 없음)'),
    (gen_random_uuid(), 'app.maintenance.ends_at', 'STRING', '', 'APP', '점검 예약 종료 (KST, yyyy-MM-ddTHH:mm, 비우면 수동 해제 전까지)')
ON CONFLICT (setting_key) DO NOTHING;
