-- =============================================================================
-- V1_32_1: Play Developer API 서비스 계정 키 (#576)
-- value_type SECRET: 빈 값으로 넣고 실제 키는 배포 후 관리자 화면에서 입력 (서버가 암호화 저장)
-- =============================================================================

INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description, created_at, updated_at)
VALUES
    (gen_random_uuid(), 'billing.play_service_account_json', 'SECRET', '', 'BILLING',
     'Play Developer API 서비스 계정 키 JSON (구매 확인·소모·환불 조회, 비면 결제 확인 불가)', NOW(), NOW())
ON CONFLICT (setting_key) DO UPDATE
    SET value_type  = EXCLUDED.value_type,
        category    = EXCLUDED.category,
        description = EXCLUDED.description;
