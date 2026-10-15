-- FCM 푸시 알림 (#467): 회원 기기 토큰, 관리자 발송 이력
-- Hibernate ddl-auto=update 도 같은 스키마를 만들지만, 운영 스키마 이력을 남기려고 명시한다
CREATE TABLE IF NOT EXISTS member_push_token (
    member_push_token_uuid UUID PRIMARY KEY,
    member_uuid            UUID         NOT NULL,
    token                  VARCHAR(512) NOT NULL,
    platform               VARCHAR(20)  NOT NULL,
    is_push_enabled        BOOLEAN      NOT NULL DEFAULT TRUE,
    last_refreshed_at      TIMESTAMP(6) NOT NULL,
    created_at             TIMESTAMP(6),
    updated_at             TIMESTAMP(6),
    created_by             VARCHAR(255),
    updated_by             VARCHAR(255),
    CONSTRAINT uk_member_push_token_token UNIQUE (token)
);
CREATE INDEX IF NOT EXISTS idx_member_push_token_member ON member_push_token (member_uuid);

CREATE TABLE IF NOT EXISTS push_send_history (
    push_send_history_uuid UUID PRIMARY KEY,
    title                  VARCHAR(100) NOT NULL,
    body                   VARCHAR(500) NOT NULL,
    audience               VARCHAR(20)  NOT NULL,
    target_member_uuid     UUID,
    link_target            VARCHAR(30)  NOT NULL,
    link_question_uuid     UUID,
    target_device_count    INTEGER      NOT NULL,
    success_count          INTEGER      NOT NULL,
    failure_count          INTEGER      NOT NULL,
    removed_token_count    INTEGER      NOT NULL,
    sent_by_admin          VARCHAR(100) NOT NULL,
    sent_at                TIMESTAMP(6) NOT NULL,
    created_at             TIMESTAMP(6),
    updated_at             TIMESTAMP(6),
    created_by             VARCHAR(255),
    updated_by             VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_push_send_history_sent_at ON push_send_history (sent_at);
