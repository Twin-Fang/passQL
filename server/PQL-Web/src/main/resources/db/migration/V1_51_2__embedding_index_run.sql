-- =============================================================================
-- V1_51_2: 임베딩 색인 실행 이력 (#616)
-- =============================================================================

-- run_type: ALL 전체, SELECTED 선택, RETRY_FAILED 실패 재시도
-- status: RUNNING, COMPLETED, FAILED (서버 재시작 등으로 중단된 실행도 FAILED)
CREATE TABLE IF NOT EXISTS embedding_index_run (
    embedding_index_run_uuid  UUID         PRIMARY KEY,
    run_type                  VARCHAR(20)  NOT NULL,
    status                    VARCHAR(20)  NOT NULL,
    started_at                TIMESTAMP(6) NOT NULL,
    finished_at               TIMESTAMP(6),
    total_count               INTEGER      NOT NULL DEFAULT 0,
    succeeded_count           INTEGER      NOT NULL DEFAULT 0,
    failed_count              INTEGER      NOT NULL DEFAULT 0,
    -- 실패 문제 UUID 줄바꿈 구분 (재시도 대상)
    failed_question_uuids     TEXT,
    error_message             VARCHAR(500),
    triggered_by_admin_username VARCHAR(100),
    created_at                TIMESTAMP(6),
    updated_at                TIMESTAMP(6),
    created_by                VARCHAR(255),
    updated_by                VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_embedding_index_run_started_at ON embedding_index_run (started_at DESC);
