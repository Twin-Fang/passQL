-- =============================================================================
-- V1_62_0: AI 연결 관리 (#695)
--   ai_connection: 제공자(GEMINI·CLAUDE·OPENAI) + API 키(암호문) + 기본 모델 + 우선순위
--   호출 순서: priority 오름차순, 사용량 초과·키 무효·서버 오류면 다음 연결
--   기존 키(ai.gemini_api_key·ai.claude_api_key)는 기동 시 AiConnectionService 가 옮김 (암호문 AAD 가 달라 SQL 로 못 옮김)
-- =============================================================================

CREATE TABLE IF NOT EXISTS ai_connection (
    ai_connection_uuid  UUID         PRIMARY KEY,
    -- provider: GEMINI, CLAUDE, OPENAI
    provider            VARCHAR(20)  NOT NULL,
    connection_name     VARCHAR(100) NOT NULL,
    -- 암호문 enc:v1:... (AAD = ai_connection:{uuid})
    encrypted_api_key   TEXT         NOT NULL,
    default_model       VARCHAR(100) NOT NULL,
    -- 작을수록 먼저 시도 (1부터)
    priority            INTEGER      NOT NULL,
    is_enabled          BOOLEAN      NOT NULL DEFAULT TRUE,
    last_success_at     TIMESTAMP(6),
    last_failure_at     TIMESTAMP(6),
    last_error_type     VARCHAR(100),
    created_at          TIMESTAMP(6),
    updated_at          TIMESTAMP(6),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255),
    CONSTRAINT uk_ai_connection_name UNIQUE (connection_name),
    CONSTRAINT ck_ai_connection_provider CHECK (provider IN ('GEMINI', 'CLAUDE', 'OPENAI'))
);

-- 호출 기록: 어느 연결로 호출했는지 (연결별 이번 달 호출 수)
ALTER TABLE ai_call_log ADD COLUMN IF NOT EXISTS connection_name VARCHAR(100);

-- 연결 관리로 대체된 설정 정리 (키 2개는 이관 후 서비스가 삭제)
DELETE FROM app_setting WHERE setting_key IN ('ai.model_override', 'ai.gemini_model', 'ai.default_model');
