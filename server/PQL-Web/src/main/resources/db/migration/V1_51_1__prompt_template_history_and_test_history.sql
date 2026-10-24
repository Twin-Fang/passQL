-- =============================================================================
-- V1_51_1: 프롬프트 변경 이력 + 테스트 결과 이력 (#615)
-- =============================================================================

-- 변경 이력: 변경 직후 본문 스냅숏 (change_type: CREATE, UPDATE, RESTORE, ACTIVATE, DELETE)
CREATE TABLE IF NOT EXISTS prompt_template_history (
    prompt_template_history_uuid UUID         PRIMARY KEY,
    prompt_template_uuid         UUID         NOT NULL,
    key_name                     VARCHAR(255) NOT NULL,
    version                      INTEGER      NOT NULL,
    change_type                  VARCHAR(20)  NOT NULL,
    is_active                    BOOLEAN      NOT NULL,
    model                        VARCHAR(100),
    system_prompt                TEXT,
    user_template                TEXT,
    temperature                  REAL,
    max_tokens                   INTEGER,
    changed_by_admin_username    VARCHAR(100),
    created_at                   TIMESTAMP(6),
    updated_at                   TIMESTAMP(6),
    created_by                   VARCHAR(255),
    updated_by                   VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_prompt_template_history_template
    ON prompt_template_history (prompt_template_uuid, created_at DESC);

-- 테스트 결과 이력: 변수 입력(JSON 문자열)과 응답 원문
CREATE TABLE IF NOT EXISTS prompt_test_history (
    prompt_test_history_uuid  UUID         PRIMARY KEY,
    prompt_template_uuid      UUID         NOT NULL,
    variables_json            TEXT,
    result_text               TEXT,
    elapsed_milliseconds      INTEGER,
    is_success                BOOLEAN      NOT NULL,
    error_message             VARCHAR(500),
    tested_by_admin_username  VARCHAR(100),
    created_at                TIMESTAMP(6),
    updated_at                TIMESTAMP(6),
    created_by                VARCHAR(255),
    updated_by                VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_prompt_test_history_template
    ON prompt_test_history (prompt_template_uuid, created_at DESC);
