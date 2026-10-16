-- 알림함 (#491): 회원별 일반 알림, 공지 읽음, 발송 이력 확장
-- Hibernate ddl-auto=update 도 같은 스키마를 만들지만, 부분 인덱스는 Hibernate 가 만들 수 없어 여기서 명시한다
CREATE TABLE IF NOT EXISTS member_notification (
    member_notification_uuid UUID PRIMARY KEY,
    member_uuid              UUID         NOT NULL,
    notification_type        VARCHAR(30)  NOT NULL,
    title                    VARCHAR(100) NOT NULL,
    body                     VARCHAR(500) NOT NULL,
    link_target              VARCHAR(30)  NOT NULL,
    link_question_uuid       UUID,
    push_send_history_uuid   UUID,
    read_at                  TIMESTAMP(6),
    is_hidden                BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at               TIMESTAMP(6),
    updated_at               TIMESTAMP(6),
    created_by               VARCHAR(255),
    updated_by               VARCHAR(255)
);
-- 목록: 회원별 최신순 커서
CREATE INDEX IF NOT EXISTS idx_member_notification_member_created
    ON member_notification (member_uuid, created_at DESC, member_notification_uuid DESC);
-- 안 읽은 개수: 안 읽음 + 노출 중인 행만 (부분 인덱스)
CREATE INDEX IF NOT EXISTS idx_member_notification_unread
    ON member_notification (member_uuid) WHERE read_at IS NULL AND is_hidden = FALSE;
-- 발송 회수·읽음률 집계
CREATE INDEX IF NOT EXISTS idx_member_notification_history
    ON member_notification (push_send_history_uuid);
-- 보관 기간 정리
CREATE INDEX IF NOT EXISTS idx_member_notification_created_at
    ON member_notification (created_at);

CREATE TABLE IF NOT EXISTS member_notice_read (
    member_uuid     UUID         NOT NULL,
    app_notice_uuid UUID         NOT NULL,
    read_at         TIMESTAMP(6) NOT NULL,
    CONSTRAINT pk_member_notice_read PRIMARY KEY (member_uuid, app_notice_uuid)
);
-- 공지별 읽은 회원 수
CREATE INDEX IF NOT EXISTS idx_member_notice_read_notice
    ON member_notice_read (app_notice_uuid);

-- 기존 발송 이력은 푸시 + 알림함 방식, 알림함 수신 수 0 으로 둔다
ALTER TABLE push_send_history ADD COLUMN IF NOT EXISTS delivery_mode VARCHAR(20) NOT NULL DEFAULT 'PUSH_AND_INBOX';
ALTER TABLE push_send_history ADD COLUMN IF NOT EXISTS recipient_count INTEGER NOT NULL DEFAULT 0;
ALTER TABLE push_send_history ADD COLUMN IF NOT EXISTS is_retracted BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE push_send_history ADD COLUMN IF NOT EXISTS retracted_at TIMESTAMP(6);
ALTER TABLE push_send_history ADD COLUMN IF NOT EXISTS retracted_by VARCHAR(100);
