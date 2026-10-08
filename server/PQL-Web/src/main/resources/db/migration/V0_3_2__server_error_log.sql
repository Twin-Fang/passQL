-- 서버 오류 기록 (#440) — 관리자 모니터링 "최근 서버 오류"
-- Hibernate ddl-auto=update 도 같은 스키마를 만들지만, 운영 스키마 이력을 남기려고 명시한다
CREATE TABLE IF NOT EXISTS server_error_log (
    server_error_log_uuid UUID PRIMARY KEY,
    occurred_at           TIMESTAMP    NOT NULL,
    request_id            VARCHAR(64),
    member_id             VARCHAR(8),
    method                VARCHAR(10)  NOT NULL,
    uri                   VARCHAR(500) NOT NULL,
    status                INTEGER      NOT NULL,
    detail                TEXT
);
CREATE INDEX IF NOT EXISTS idx_server_error_log_occurred_at ON server_error_log (occurred_at);
