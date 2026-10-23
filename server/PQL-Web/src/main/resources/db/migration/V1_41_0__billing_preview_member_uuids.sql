-- =============================================================================
-- V1_41_0: 회원별 결제 미리 켜기 (#596)
-- 1. app_setting: billing.preview_member_uuids (결제 스위치 꺼짐이어도 목록 회원만 결제 켜짐 취급)
-- =============================================================================

-- 1. 결제 미리보기 회원 목록
--    value_text: 회원 UUID 쉼표 구분 (예: 'uuid-a,uuid-b'), 빈 값 > 대상 없음
--    용도: App Store 심사·실구매 점검 계정만 결제 화면 노출, 그 외 회원은 전원 무료
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'billing.preview_member_uuids', 'STRING', '',
     'BILLING', '결제 미리보기 회원 UUID 목록 (쉼표 구분, 결제 스위치가 꺼져 있어도 목록 회원만 무료/프로 제한과 결제 화면 적용, 비우면 대상 없음)')
ON CONFLICT (setting_key) DO NOTHING;
