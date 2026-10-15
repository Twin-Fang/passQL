-- AI 서버 호출 기록 (#474): 대시보드·모니터링 성공·실패·지연 집계, 30일 보관 (AiCallLogCleanupScheduler)
CREATE TABLE IF NOT EXISTS ai_call_log (
    ai_call_log_uuid     UUID         PRIMARY KEY,
    endpoint_path        VARCHAR(100) NOT NULL,
    is_success           BOOLEAN      NOT NULL,
    latency_milliseconds BIGINT       NOT NULL,
    error_type           VARCHAR(100),
    called_at            TIMESTAMP(6) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_ai_call_log_called_at ON ai_call_log (called_at);
