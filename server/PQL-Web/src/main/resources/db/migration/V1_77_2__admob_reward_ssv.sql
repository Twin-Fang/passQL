-- =============================================================================
-- V1_77_2: 광고 보너스 AdMob 서버 검증 (#860)
-- 1. member_daily_ad_bonus: 보상 표식·AdMob 거래 ID (같은 광고 중복 기록 방지)
-- 2. app_setting: ads.reward.ssv_required, ads.reward.ssv_ad_unit_ids
-- =============================================================================

-- 1. 같은 광고 1회 기록 (NULL 은 여러 행 허용 = 옛 앱 신고 기록)
--    reward_nonce: 앱이 광고마다 만든 표식 (AdMob custom_data 와 같은 값)
--    ssv_transaction_id: AdMob 서버 검증 콜백 transaction_id
ALTER TABLE member_daily_ad_bonus ADD COLUMN IF NOT EXISTS reward_nonce VARCHAR(64);
ALTER TABLE member_daily_ad_bonus ADD COLUMN IF NOT EXISTS ssv_transaction_id VARCHAR(128);
CREATE UNIQUE INDEX IF NOT EXISTS uk_member_daily_ad_bonus_reward_nonce
    ON member_daily_ad_bonus (reward_nonce);
CREATE UNIQUE INDEX IF NOT EXISTS uk_member_daily_ad_bonus_ssv_transaction_id
    ON member_daily_ad_bonus (ssv_transaction_id);

-- 2. 서버 검증 설정
--    ssv_required: 'false' 앱 신고로도 기록(출시 앱 호환), 'true' AdMob 콜백으로만 기록
--    AdMob 콘솔에 콜백 URL(/api/ads/admob/reward-callback) 등록·새 앱 배포 뒤 관리자 화면에서 켠다
--    ssv_ad_unit_ids: 콜백을 받을 보상형 광고 단위 ID (쉼표 구분, 비우면 단위 확인 안 함)
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'ads.reward.ssv_required', 'BOOLEAN', 'false',
     'BILLING', '광고 보너스 AdMob 서버 검증 필수 (true 면 AdMob 콜백으로만 기록, false 면 앱 신고로도 기록. 콘솔 콜백 URL 등록과 새 앱 배포 뒤 켬)'),
    (gen_random_uuid(), 'ads.reward.ssv_ad_unit_ids', 'STRING', '',
     'BILLING', '서버 검증 콜백을 받을 보상형 광고 단위 ID 목록 (쉼표 구분, 비우면 단위 확인 안 함)')
ON CONFLICT (setting_key) DO NOTHING;
