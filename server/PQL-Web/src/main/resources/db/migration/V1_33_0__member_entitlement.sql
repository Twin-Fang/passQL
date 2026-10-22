-- =============================================================================
-- V1_33_0: 무료/프로 플랜과 Android 회차 패스 결제 (#576)
-- 1. member_entitlement: 회원 등급 (회원 1명당 1행)
-- 2. entitlement_purchase: 스토어 구매 이력 (주문·토큰 중복 방지)
-- 3. app_setting: 결제 스위치 billing.android.enabled
-- 4. app_setting: Play Developer API 서비스 계정 키 billing.play_service_account_json
-- =============================================================================

-- 1. 회원 등급
--    plan: FREE, PRO / expires_at: 프로 만료 시각 (KST 기준, 서버 로컬 시간, FREE 면 null)
--    source: 등급을 준 경로 (PLAY_PURCHASE 스토어 구매, ADMIN_GRANT 관리자 부여)
CREATE TABLE IF NOT EXISTS member_entitlement (
    member_uuid UUID PRIMARY KEY,
    plan        VARCHAR(20) NOT NULL,
    expires_at  TIMESTAMP(6),
    source      VARCHAR(30) NOT NULL,
    created_at  TIMESTAMP(6),
    updated_at  TIMESTAMP(6),
    created_by  VARCHAR(255),
    updated_by  VARCHAR(255)
);

-- 2. 구매 이력
--    store: PLAY / status: VERIFIED 검증 완료, REVOKED 환불 등으로 회수
--    granted_expires_at: 이 구매로 부여한 만료 시각
--    is_consumed: 스토어 소모(consume) 완료 여부 (false 면 소모 재시도 대상)
--    order_id, purchase_token 은 UNIQUE (같은 구매 재검증 시 중복 반영 차단)
CREATE TABLE IF NOT EXISTS entitlement_purchase (
    entitlement_purchase_uuid UUID PRIMARY KEY,
    member_uuid               UUID         NOT NULL,
    store                     VARCHAR(20)  NOT NULL,
    product_id                VARCHAR(100) NOT NULL,
    order_id                  VARCHAR(100) NOT NULL,
    purchase_token            TEXT         NOT NULL,
    purchased_at              TIMESTAMP(6) NOT NULL,
    status                    VARCHAR(20)  NOT NULL,
    granted_expires_at        TIMESTAMP(6),
    is_consumed               BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at                TIMESTAMP(6),
    updated_at                TIMESTAMP(6),
    created_by                VARCHAR(255),
    updated_by                VARCHAR(255),
    CONSTRAINT uk_entitlement_purchase_order_id UNIQUE (order_id),
    CONSTRAINT uk_entitlement_purchase_purchase_token UNIQUE (purchase_token)
);
-- 회원별 구매 이력 조회용
CREATE INDEX IF NOT EXISTS idx_entitlement_purchase_member ON entitlement_purchase (member_uuid);

-- 3. 결제 스위치 (false 면 모든 판정 허용, 하루 제한 없음, 앱은 결제 UI 숨김)
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'billing.android.enabled', 'BOOLEAN', 'false',
     'BILLING', 'Android 결제 스위치 (true 이면 무료/프로 제한 적용과 결제 UI 노출, false 이면 모든 기능 허용)')
ON CONFLICT (setting_key) DO NOTHING;

-- 4. Play Developer API 서비스 계정 키
--    value_type SECRET: 빈 값으로 넣고 실제 키는 배포 후 관리자 화면에서 입력 (서버가 암호화 저장)
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description, created_at, updated_at)
VALUES
    (gen_random_uuid(), 'billing.play_service_account_json', 'SECRET', '', 'BILLING',
     'Play Developer API 서비스 계정 키 JSON (구매 확인·소모·환불 조회, 비면 결제 확인 불가)', NOW(), NOW())
ON CONFLICT (setting_key) DO UPDATE
    SET value_type  = EXCLUDED.value_type,
        category    = EXCLUDED.category,
        description = EXCLUDED.description;
