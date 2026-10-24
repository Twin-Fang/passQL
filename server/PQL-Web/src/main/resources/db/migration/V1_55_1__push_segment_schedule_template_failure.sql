-- 푸시 발송 확장 (#629): 세그먼트 대상, 예약 발송, 테스트 발송 표시, 템플릿, 실패 기기 기록
ALTER TABLE push_send_history ADD COLUMN IF NOT EXISTS inactive_days INTEGER;
ALTER TABLE push_send_history ADD COLUMN IF NOT EXISTS scheduled_at TIMESTAMP(6);
-- dispatch_status: 예약 대기 SCHEDULED, 발송 시작 DISPATCHED (기존 이력 전부), 예약 취소 CANCELED
ALTER TABLE push_send_history ADD COLUMN IF NOT EXISTS dispatch_status VARCHAR(20) NOT NULL DEFAULT 'DISPATCHED';
ALTER TABLE push_send_history ADD COLUMN IF NOT EXISTS is_test BOOLEAN NOT NULL DEFAULT FALSE;
CREATE INDEX IF NOT EXISTS idx_push_send_history_schedule ON push_send_history (dispatch_status, scheduled_at);

-- 발송 실패 기기 (토큰 전체는 저장하지 않고 끝 8자만)
CREATE TABLE IF NOT EXISTS push_delivery_failure (
    push_delivery_failure_uuid UUID PRIMARY KEY,
    push_send_history_uuid     UUID         NOT NULL,
    member_uuid                UUID         NOT NULL,
    token_suffix               VARCHAR(16)  NOT NULL,
    is_token_expired           BOOLEAN      NOT NULL,
    failure_reason             VARCHAR(100) NOT NULL,
    created_at                 TIMESTAMP(6),
    updated_at                 TIMESTAMP(6),
    created_by                 VARCHAR(255),
    updated_by                 VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_push_delivery_failure_history ON push_delivery_failure (push_send_history_uuid);

-- 관리자 푸시 템플릿
CREATE TABLE IF NOT EXISTS push_template (
    push_template_uuid UUID PRIMARY KEY,
    name               VARCHAR(50)  NOT NULL,
    title              VARCHAR(100) NOT NULL,
    body               VARCHAR(500) NOT NULL,
    link_target        VARCHAR(30)  NOT NULL,
    link_question_uuid UUID,
    created_at         TIMESTAMP(6),
    updated_at         TIMESTAMP(6),
    created_by         VARCHAR(255),
    updated_by         VARCHAR(255),
    CONSTRAINT uk_push_template_name UNIQUE (name)
);
