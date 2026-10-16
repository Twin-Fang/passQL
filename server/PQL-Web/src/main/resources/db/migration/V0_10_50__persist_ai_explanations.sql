-- AI 해설 영구 저장 (#496)
-- 1) 선택지별 해설: "이 선택지를 골랐을 때" 해설, 세트 저장 직후 미리 생성 (Redis 24시간 캐시 대체)
ALTER TABLE question_choice_set_item ADD COLUMN IF NOT EXISTS explanation TEXT;
ALTER TABLE question_choice_set_item ADD COLUMN IF NOT EXISTS explanation_prompt_version INT;

-- 2) SQL 오류 해설: (문제, 정규화 SQL 해시, 오류 해시) 단위로 재사용
CREATE TABLE IF NOT EXISTS ai_error_explanation (
    ai_error_explanation_uuid UUID         PRIMARY KEY,
    question_uuid             UUID         NOT NULL,
    sql_hash                  VARCHAR(64)  NOT NULL,
    error_hash                VARCHAR(64)  NOT NULL,
    explanation               TEXT         NOT NULL,
    prompt_version            INT,
    created_at                TIMESTAMP(6) NOT NULL,
    CONSTRAINT uk_ai_error_explanation_key UNIQUE (question_uuid, sql_hash, error_hash)
);

-- 3) 선택지 세트 재사용 조회 (question_uuid, status, created_at DESC) 인덱스 (#497 S8)
CREATE INDEX IF NOT EXISTS idx_choice_set_question_status_created
    ON question_choice_set (question_uuid, status, created_at DESC);
