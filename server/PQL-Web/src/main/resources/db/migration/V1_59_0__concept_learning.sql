-- =============================================================================
-- V1_59_0: 단원별 개념 학습 (#577)
-- 1. concept_tag: 단원 연결(topic_uuid), 공개 상태(DRAFT/PUBLISHED), 한 줄 요약
-- 2. concept_doc: 핵심만(core_md) · 자세히(detail_md, "## 제목 {#앵커}" 문단) 분리 저장
-- 3. concept_check_question / concept_check_choice: 개념 확인 문제 5개 (기존 question 풀과 분리)
-- 4. member_concept_progress: 회원별 읽음·마지막 모드·확인 문제 정답 수
-- 5. app_setting: 공개 스위치, 무료 단원 수, 초안 미리보기 회원
-- =============================================================================

-- 1. concept_tag 확장
ALTER TABLE concept_tag
    ADD COLUMN IF NOT EXISTS topic_uuid UUID NULL REFERENCES topic (topic_uuid),
    ADD COLUMN IF NOT EXISTS publish_status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    ADD COLUMN IF NOT EXISTS summary VARCHAR(255) NULL;

CREATE INDEX IF NOT EXISTS idx_concept_tag_topic ON concept_tag (topic_uuid, sort_order);

-- 2. concept_doc 확장 (기존 body_md 는 그대로 둠)
ALTER TABLE concept_doc
    ADD COLUMN IF NOT EXISTS core_md TEXT NULL,
    ADD COLUMN IF NOT EXISTS detail_md TEXT NULL;

-- 3. 확인 문제
CREATE TABLE IF NOT EXISTS concept_check_question (
    concept_check_question_uuid UUID PRIMARY KEY,
    concept_tag_uuid            UUID         NOT NULL REFERENCES concept_tag (concept_tag_uuid),
    sort_order                  INTEGER      NOT NULL,
    stem                        TEXT         NOT NULL,
    stem_sql                    TEXT         NULL,
    explanation                 TEXT         NOT NULL,
    reread_anchor               VARCHAR(80)  NOT NULL,
    created_at                  TIMESTAMP(6) NULL,
    updated_at                  TIMESTAMP(6) NULL,
    created_by                  VARCHAR(255) NULL,
    updated_by                  VARCHAR(255) NULL,
    CONSTRAINT uk_concept_check_question_order UNIQUE (concept_tag_uuid, sort_order)
);

CREATE TABLE IF NOT EXISTS concept_check_choice (
    concept_check_choice_uuid   UUID PRIMARY KEY,
    concept_check_question_uuid UUID         NOT NULL REFERENCES concept_check_question (concept_check_question_uuid) ON DELETE CASCADE,
    choice_key                  VARCHAR(4)   NOT NULL,
    body                        TEXT         NOT NULL,
    is_correct                  BOOLEAN      NOT NULL,
    rationale                   TEXT         NULL,
    sort_order                  INTEGER      NOT NULL,
    created_at                  TIMESTAMP(6) NULL,
    updated_at                  TIMESTAMP(6) NULL,
    created_by                  VARCHAR(255) NULL,
    updated_by                  VARCHAR(255) NULL,
    CONSTRAINT uk_concept_check_choice_key UNIQUE (concept_check_question_uuid, choice_key)
);

-- 4. 진행 기록 (answered_choice_keys_json: 확인 문제 UUID > 마지막 선택 키)
CREATE TABLE IF NOT EXISTS member_concept_progress (
    member_concept_progress_uuid UUID PRIMARY KEY,
    member_uuid                  UUID         NOT NULL,
    concept_tag_uuid             UUID         NOT NULL REFERENCES concept_tag (concept_tag_uuid),
    is_read                      BOOLEAN      NOT NULL DEFAULT FALSE,
    last_mode                    VARCHAR(10)  NOT NULL DEFAULT 'READ',
    last_depth                   VARCHAR(10)  NOT NULL DEFAULT 'CORE',
    check_correct_count          INTEGER      NOT NULL DEFAULT 0,
    check_solved_count           INTEGER      NOT NULL DEFAULT 0,
    answered_choice_keys_json    TEXT         NOT NULL DEFAULT '{}',
    created_at                   TIMESTAMP(6) NULL,
    updated_at                   TIMESTAMP(6) NULL,
    created_by                   VARCHAR(255) NULL,
    updated_by                   VARCHAR(255) NULL,
    CONSTRAINT uk_member_concept_progress UNIQUE (member_uuid, concept_tag_uuid)
);

-- 5. 설정 (공개 전에는 미리보기 회원만 초안까지 봄)
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'concept.is_published', 'BOOLEAN', 'false', 'CONCEPT', '개념 학습 공개 (true 공개, false 미리보기 회원만)'),
    (gen_random_uuid(), 'concept.free_topic_count', 'INT', '2', 'CONCEPT', '무료 단원 수 (topic.sort_order 앞에서부터, 나머지 프로)'),
    (gen_random_uuid(), 'concept.preview_member_uuids', 'STRING', '', 'CONCEPT', '초안 미리보기 회원 UUID 목록 (쉼표 구분)')
ON CONFLICT (setting_key) DO NOTHING;
