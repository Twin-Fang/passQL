-- =============================================================================
-- V1_78_1_1: SQLD 모의고사 (#866)
-- 1. mock_exam_round: 관리자 구성 회차 (DRAFT > PUBLISHED > ARCHIVED)
-- 2. mock_exam_round_item: 회차 문항 = 문제 + 고정 보기 세트 (1과목 1~10, 2과목 11~50)
-- 3. mock_exam_attempt: 응시 1회 (시작·마감 KST, 채점 결과 고정 저장)
-- 4. mock_exam_answer: 응시 문항 답 (고른 보기·표시, 채점 뒤 정오)
-- =============================================================================

-- 1. 회차
CREATE TABLE IF NOT EXISTS mock_exam_round (
    mock_exam_round_uuid UUID         NOT NULL PRIMARY KEY,
    round_number         INTEGER      NOT NULL,
    title                VARCHAR(100) NOT NULL,
    status               VARCHAR(20)  NOT NULL,
    published_at         TIMESTAMP(6),
    created_at           TIMESTAMP(6),
    updated_at           TIMESTAMP(6),
    created_by           VARCHAR(255),
    updated_by           VARCHAR(255),
    CONSTRAINT uk_mock_exam_round_number UNIQUE (round_number)
);
CREATE INDEX IF NOT EXISTS idx_mock_exam_round_status ON mock_exam_round (status);

-- 2. 회차 문항 (subject: SUBJECT_ONE 데이터 모델링, SUBJECT_TWO SQL)
CREATE TABLE IF NOT EXISTS mock_exam_round_item (
    mock_exam_round_item_uuid UUID        NOT NULL PRIMARY KEY,
    mock_exam_round_uuid      UUID        NOT NULL,
    question_number           INTEGER     NOT NULL,
    subject                   VARCHAR(20) NOT NULL,
    topic_uuid                UUID        NOT NULL,
    question_uuid             UUID        NOT NULL,
    choice_set_uuid           UUID        NOT NULL,
    created_at                TIMESTAMP(6),
    updated_at                TIMESTAMP(6),
    created_by                VARCHAR(255),
    updated_by                VARCHAR(255),
    CONSTRAINT uk_mock_exam_item_number UNIQUE (mock_exam_round_uuid, question_number),
    CONSTRAINT uk_mock_exam_item_question UNIQUE (mock_exam_round_uuid, question_uuid)
);
CREATE INDEX IF NOT EXISTS idx_mock_exam_item_question ON mock_exam_round_item (question_uuid);

-- 3. 응시 (status: IN_PROGRESS 풀이 중, SUBMITTED 채점 끝 / submit_reason: MEMBER, TIME_UP)
CREATE TABLE IF NOT EXISTS mock_exam_attempt (
    mock_exam_attempt_uuid    UUID        NOT NULL PRIMARY KEY,
    member_uuid               UUID        NOT NULL,
    mock_exam_round_uuid      UUID        NOT NULL,
    status                    VARCHAR(20) NOT NULL,
    started_at                TIMESTAMP(6) NOT NULL,
    deadline_at               TIMESTAMP(6) NOT NULL,
    submitted_at              TIMESTAMP(6),
    submit_reason             VARCHAR(20),
    correct_count             INTEGER,
    subject_one_correct_count INTEGER,
    subject_two_correct_count INTEGER,
    total_score               INTEGER,
    is_passed                 BOOLEAN,
    fail_reason               VARCHAR(30),
    created_at                TIMESTAMP(6),
    updated_at                TIMESTAMP(6),
    created_by                VARCHAR(255),
    updated_by                VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_mock_exam_attempt_member_status ON mock_exam_attempt (member_uuid, status);
CREATE INDEX IF NOT EXISTS idx_mock_exam_attempt_member_round ON mock_exam_attempt (member_uuid, mock_exam_round_uuid);
CREATE INDEX IF NOT EXISTS idx_mock_exam_attempt_round_status ON mock_exam_attempt (mock_exam_round_uuid, status);
CREATE INDEX IF NOT EXISTS idx_mock_exam_attempt_status_deadline ON mock_exam_attempt (status, deadline_at);
-- 풀이 중 응시는 회원당 1개 (두 번 누름·두 기기 동시 시작 방지, 엔티티로 표현 못 하는 부분 유일 인덱스)
CREATE UNIQUE INDEX IF NOT EXISTS uk_mock_exam_attempt_member_in_progress
    ON mock_exam_attempt (member_uuid) WHERE status = 'IN_PROGRESS';

-- 4. 응시 문항 답 (selected_choice_key NULL: 안 고름, is_correct NULL: 채점 전)
CREATE TABLE IF NOT EXISTS mock_exam_answer (
    mock_exam_answer_uuid     UUID        NOT NULL PRIMARY KEY,
    mock_exam_attempt_uuid    UUID        NOT NULL,
    mock_exam_round_item_uuid UUID        NOT NULL,
    question_number           INTEGER     NOT NULL,
    selected_choice_key       VARCHAR(8),
    is_flagged                BOOLEAN     NOT NULL DEFAULT FALSE,
    is_correct                BOOLEAN,
    answered_at               TIMESTAMP(6),
    created_at                TIMESTAMP(6),
    updated_at                TIMESTAMP(6),
    created_by                VARCHAR(255),
    updated_by                VARCHAR(255),
    CONSTRAINT uk_mock_exam_answer_item UNIQUE (mock_exam_attempt_uuid, mock_exam_round_item_uuid)
);
CREATE INDEX IF NOT EXISTS idx_mock_exam_answer_item ON mock_exam_answer (mock_exam_round_item_uuid);
