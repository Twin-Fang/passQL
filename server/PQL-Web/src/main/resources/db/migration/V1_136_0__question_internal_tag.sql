-- =============================================================================
-- V1_136_0: 문제 내부 관리 태그 (#1117)
-- question_internal_tag: 문제·태그 쌍당 1행, 관리자 전용 (사용자 API 미노출)
-- tag 형식: 소문자 네임스페이스:값 (source:63-17, trend:t41, round:63, batch:batch06, concept:비등가조인, new-type), 최대 64자
-- question_concept_tag(개념 사전 concept_tag 연결, 개념 학습용)와 별개
-- =============================================================================

CREATE TABLE IF NOT EXISTS question_internal_tag (
    question_internal_tag_uuid UUID         PRIMARY KEY,
    question_uuid              UUID         NOT NULL,
    tag                        VARCHAR(64)  NOT NULL,
    created_at                 TIMESTAMP(6),
    updated_at                 TIMESTAMP(6),
    created_by                 VARCHAR(255),
    updated_by                 VARCHAR(255),
    CONSTRAINT uk_question_internal_tag_question_tag UNIQUE (question_uuid, tag)
);

-- 태그 필터·요약 (정확 일치, 앞부분 일치 LIKE 'source:63-%')
CREATE INDEX IF NOT EXISTS idx_question_internal_tag_tag
    ON question_internal_tag (tag varchar_pattern_ops);
