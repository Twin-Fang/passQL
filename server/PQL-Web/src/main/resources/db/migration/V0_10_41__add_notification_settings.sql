-- 알림함 설정 (#491): 보관 기간(일), 자동 알림 사용 여부. 관리자 > 푸시 발송 > 알림 설정에서 바꾼다.
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'notification.retention_days', 'INT', '90', 'NOTIFICATION', '알림함 일반 알림 보관 기간 (일, 지난 알림은 매일 새벽 삭제)'),
    (gen_random_uuid(), 'notification.report_resolved.enabled', 'BOOLEAN', 'true', 'NOTIFICATION', '신고 처리 결과 자동 알림 (true 이면 처리 완료·기각 시 신고한 회원에게 알림)'),
    (gen_random_uuid(), 'notification.daily_set_reminder.enabled', 'BOOLEAN', 'false', 'NOTIFICATION', '오늘의 세트 리마인드 자동 알림 (발송은 후속 이슈, 지금은 설정만)')
ON CONFLICT (setting_key) DO NOTHING;
