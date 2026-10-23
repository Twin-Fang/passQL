-- =============================================================================
-- V1_38_0: 회차 패스 > 1개월·3개월 이용권 교체 (#591)
-- 1. entitlement_purchase.granted_days: 이 구매로 더한 이용 일수
-- =============================================================================

-- 1. 구매 이력 이용 일수
--    granted_days: 이용권 일수 (pro_pass_3m 90, pro_pass_1m 30), #576 회차 패스 옛 행은 null
--    환불 재계산: 남은 구매를 구매 시각 순으로 재생 (일수 있으면 max(구매 시각, 누적 만료일) + 일수, null 이면 granted_expires_at)
ALTER TABLE entitlement_purchase ADD COLUMN IF NOT EXISTS granted_days INT;
