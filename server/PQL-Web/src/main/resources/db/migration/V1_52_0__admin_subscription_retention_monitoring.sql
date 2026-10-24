-- =============================================================================
-- V1_52_0: 관리자 구독·리텐션·모니터링 개선 (#619 #620 #621 #622)
-- 1. entitlement_purchase: 결제 금액·통화 컬럼 (스토어가 알려 준 값만 저장, 없으면 NULL)
-- 2. 집계용 인덱스: 구매 시각, 등급 만료 시각, 제출 시각
-- 3. app_setting: 모니터링 장애 알림 설정 (기본 꺼짐)
-- =============================================================================

-- 1. 결제 금액·통화
--    price_amount_micros: 통화 단위 x 1,000,000 (Play priceAmountMicros 와 같은 단위), currency_code: ISO 4217 (KRW)
ALTER TABLE entitlement_purchase ADD COLUMN IF NOT EXISTS price_amount_micros BIGINT;
ALTER TABLE entitlement_purchase ADD COLUMN IF NOT EXISTS currency_code VARCHAR(3);

-- 2. 집계 인덱스
--    구독 현황: 구간 구매·회수 건수 / 만료 임박 조회 / 리텐션·기능 사용률의 구간 제출 조회
CREATE INDEX IF NOT EXISTS idx_entitlement_purchase_purchased_at ON entitlement_purchase (purchased_at);
CREATE INDEX IF NOT EXISTS idx_member_entitlement_expires_at ON member_entitlement (expires_at);
CREATE INDEX IF NOT EXISTS idx_submission_submitted_at ON submission (submitted_at);

-- 3. 모니터링 장애 알림 (Slack Incoming Webhook)
--    monitor.alert.slack_webhook_url: SECRET, 빈 값으로 넣고 실제 URL 은 배포 후 관리자 화면에서 입력
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'monitor.alert.enabled', 'BOOLEAN', 'false',
     'MONITOR', '장애 알림 사용 여부 (true 사용, false 미사용, 켜도 웹훅 URL 이 비어 있으면 발송하지 않음)'),
    (gen_random_uuid(), 'monitor.alert.slack_webhook_url', 'SECRET', '',
     'MONITOR', '장애 알림을 보낼 Slack Incoming Webhook URL (관리자만 수정 가능)'),
    (gen_random_uuid(), 'monitor.alert.window_minutes', 'INT', '10',
     'MONITOR', '장애 판정 집계 구간 (분, 최근 N분의 서버 오류·AI 실패율을 봄)'),
    (gen_random_uuid(), 'monitor.alert.server_error_threshold_count', 'INT', '10',
     'MONITOR', '서버 오류(5xx) 알림 기준 (건, 집계 구간 안에서 이 건수 이상이면 알림)'),
    (gen_random_uuid(), 'monitor.alert.ai_failure_rate_threshold_percent', 'INT', '50',
     'MONITOR', 'AI 호출 실패율 알림 기준 (%, 집계 구간 안 호출이 5건 이상일 때만 판정)'),
    (gen_random_uuid(), 'monitor.alert.ai_budget_threshold_percent', 'INT', '100',
     'MONITOR', 'AI 월 예산 사용률 알림 기준 (%, 이번 달 추정 비용 / ai.monthly_budget_usd, 달마다 1회)'),
    (gen_random_uuid(), 'monitor.alert.cooldown_minutes', 'INT', '60',
     'MONITOR', '같은 종류 알림 재발송 대기 시간 (분)')
ON CONFLICT (setting_key) DO NOTHING;
