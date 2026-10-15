-- 앱 공지 (#464): 노출 기간·활성 여부로 앱 홈 노출 결정, 중요 공지 먼저
-- Hibernate ddl-auto=update 도 같은 스키마를 만들지만, 운영 스키마 이력을 남기려고 명시한다
CREATE TABLE IF NOT EXISTS app_notice (
    app_notice_uuid UUID PRIMARY KEY,
    title           VARCHAR(100) NOT NULL,
    body            TEXT         NOT NULL,
    starts_at       TIMESTAMP,
    ends_at         TIMESTAMP,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    is_important    BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP(6),
    updated_at      TIMESTAMP(6),
    created_by      VARCHAR(255),
    updated_by      VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_app_notice_is_active ON app_notice (is_active);
