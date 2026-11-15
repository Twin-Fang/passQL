-- =============================================================================
-- V1_133_1: 문제 즐겨찾기 (#1082)
-- question_bookmark: 회원·문제당 1행, 해제는 행 삭제, 목록은 created_at 내림차순
-- =============================================================================

CREATE TABLE IF NOT EXISTS question_bookmark (
    question_bookmark_uuid UUID         PRIMARY KEY,
    member_uuid            UUID         NOT NULL,
    question_uuid          UUID         NOT NULL,
    created_at             TIMESTAMP(6),
    updated_at             TIMESTAMP(6),
    created_by             VARCHAR(255),
    updated_by             VARCHAR(255),
    CONSTRAINT uk_question_bookmark_member_question UNIQUE (member_uuid, question_uuid)
);

-- 회원별 최근 추가 순 목록
CREATE INDEX IF NOT EXISTS idx_question_bookmark_member_created
    ON question_bookmark (member_uuid, created_at);
