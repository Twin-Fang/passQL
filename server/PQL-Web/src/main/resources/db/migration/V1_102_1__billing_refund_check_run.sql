-- =============================================================================
-- V1_102_1: Play 환불 회수 확인 실행 기록 (#984)
-- =============================================================================

-- 실행 1회 = 1행 (자동 스케줄·관리자 수동 공통)
-- trigger_type: SCHEDULED 자동(매일 04:50 KST), ADMIN 관리자 「지금 확인」
-- voided_purchase_count: 취소 구매 목록(voidedpurchases) 토큰 수
-- checked_order_count: 주문 상태(orders.batchget)를 확인한 프로 유효 회원 구매 수
-- refunded_order_count: 전액 환불(REFUNDED) 주문 수, revoked_count: 이번 실행에서 회수한 구매 수
-- failure_reason: NULL 성공, SERVICE_ACCOUNT_NOT_CONFIGURED·VOIDED_PURCHASE_LIST_FAILED·ORDER_LOOKUP_FAILED·UNEXPECTED_ERROR
--   (원인 종류만, 토큰·응답 원문 저장 안 함)
CREATE TABLE IF NOT EXISTS billing_refund_check_run (
    billing_refund_check_run_uuid UUID         PRIMARY KEY,
    trigger_type                  VARCHAR(20)  NOT NULL,
    started_at                    TIMESTAMP(6) NOT NULL,
    finished_at                   TIMESTAMP(6),
    voided_purchase_count         INTEGER      NOT NULL DEFAULT 0,
    checked_order_count           INTEGER      NOT NULL DEFAULT 0,
    refunded_order_count          INTEGER      NOT NULL DEFAULT 0,
    revoked_count                 INTEGER      NOT NULL DEFAULT 0,
    failure_reason                VARCHAR(50),
    created_at                    TIMESTAMP(6),
    updated_at                    TIMESTAMP(6),
    created_by                    VARCHAR(255),
    updated_by                    VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_billing_refund_check_run_started_at ON billing_refund_check_run (started_at);
