-- =============================================================================
-- V1_114_2: 관리자 결제 관리 (#1032) — 회수 시각, 환불 확인 스토어 구분, App Store 알림 수신 기록, 실수령액 설정
-- =============================================================================

-- 1) 구매 회수 시각 (회수 전 NULL), 기존 회수 건은 마지막 수정 시각으로 채움 (그동안 회수 시각 = updated_at)
ALTER TABLE entitlement_purchase ADD COLUMN IF NOT EXISTS revoked_at TIMESTAMP(6);
UPDATE entitlement_purchase SET revoked_at = updated_at WHERE status = 'REVOKED' AND revoked_at IS NULL;

-- 2) 환불 회수 확인 실행 기록 스토어 구분: PLAY(#984 기존 행), APP_STORE(#1032)
ALTER TABLE billing_refund_check_run ADD COLUMN IF NOT EXISTS store VARCHAR(20);
UPDATE billing_refund_check_run SET store = 'PLAY' WHERE store IS NULL;
ALTER TABLE billing_refund_check_run ALTER COLUMN store SET NOT NULL;

-- 3) App Store 서버 알림 수신 기록 (서명 원문·개인정보 저장 안 함)
-- handling_result: REVOKED 회수, NO_VERIFIED_PURCHASE 기록 없음·이미 회수, IGNORED 무시, VERIFICATION_FAILED 서명 검증 실패,
--   REFUND_REQUESTED 환불 요청 접수, CONSUMPTION_SENT 소비 정보 보냄, CONSUMPTION_FAILED 소비 정보 실패
CREATE TABLE IF NOT EXISTS app_store_notification_log (
    app_store_notification_log_uuid UUID         PRIMARY KEY,
    notification_uuid               VARCHAR(64),
    notification_type               VARCHAR(50),
    subtype                         VARCHAR(50),
    transaction_id                  VARCHAR(100),
    environment                     VARCHAR(20),
    handling_result                 VARCHAR(30)  NOT NULL,
    received_at                     TIMESTAMP(6) NOT NULL,
    created_at                      TIMESTAMP(6),
    updated_at                      TIMESTAMP(6),
    created_by                      VARCHAR(255),
    updated_by                      VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_app_store_notification_log_received_at ON app_store_notification_log (received_at);
CREATE INDEX IF NOT EXISTS idx_app_store_notification_log_transaction_id ON app_store_notification_log (transaction_id);

-- 4) 결제 관리 설정
--    billing.fee_rate_percent.play / app_store: 스토어 수수료율 (%, 기본 15 = 소규모 사업자·첫해 기준 가정)
--    billing.krw_vat_rate_percent: 원화 판매가에 포함된 부가세율 (%, 기본 10, 스토어가 떼고 정산)
--    billing.app_store.sandbox_fallback_enabled: App Store 환불 점검 운영 404 > 샌드박스 재조회 (기본 켜짐)
--    billing.app_store.consumption_response_enabled: 환불 요청(CONSUMPTION_REQUEST) 소비 정보 자동 응답 (기본 꺼짐, 고객 동의 장치 확인 후 켬)
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'billing.fee_rate_percent.play', 'FLOAT', '15',
     'BILLING', 'Google Play 수수료율 (%, 실수령액 추정용)'),
    (gen_random_uuid(), 'billing.fee_rate_percent.app_store', 'FLOAT', '15',
     'BILLING', 'App Store 수수료율 (%, 실수령액 추정용, 소규모 사업자 프로그램 15)'),
    (gen_random_uuid(), 'billing.krw_vat_rate_percent', 'FLOAT', '10',
     'BILLING', '원화 판매가 포함 부가세율 (%, 스토어가 떼고 정산, 실수령액 추정용)'),
    (gen_random_uuid(), 'billing.app_store.sandbox_fallback_enabled', 'BOOLEAN', 'true',
     'BILLING', 'App Store 환불 점검: 운영에 없는 거래는 샌드박스에서 다시 조회 (true 사용, false 운영만)'),
    (gen_random_uuid(), 'billing.app_store.consumption_response_enabled', 'BOOLEAN', 'false',
     'BILLING', 'App Store 환불 요청 소비 정보 자동 응답 (true 응답, false 접수만 — 고객 동의를 받는 경우에만 켬)')
ON CONFLICT (setting_key) DO NOTHING;
