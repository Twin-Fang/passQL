-- =============================================================================
-- V1_128_1: 회차별 가답안·OMR 가채점 (#1075)
-- 1. exam_answer_round: 자격증·회차 1개 = 1행
-- 2. exam_answer_item: 회차당 문항 50행 (원문 없음, 출제 개념 한 줄 + 운영 가답안)
-- 3. exam_answer_sheet: 응시자 답안 (회차·클라이언트 토큰 해시당 1장)
-- 4. SQLD 63회 회차 + 빈 문항 50행 시드 (시험 당일 바로 공개, 없을 때만 넣음)
-- =============================================================================

-- 1. 회차
--    status: COLLECTING 수집 중, OFFICIAL 공식 정답 반영, CLOSED 마감(제출 거부)
CREATE TABLE IF NOT EXISTS exam_answer_round (
    exam_answer_round_uuid UUID         PRIMARY KEY,
    cert_type              VARCHAR(20)  NOT NULL,
    round_number           INTEGER      NOT NULL,
    exam_date              DATE         NOT NULL,
    title                  VARCHAR(100) NOT NULL,
    status                 VARCHAR(20)  NOT NULL DEFAULT 'COLLECTING',
    notice                 TEXT,
    created_at             TIMESTAMP(6),
    updated_at             TIMESTAMP(6),
    created_by             VARCHAR(255),
    updated_by             VARCHAR(255),
    CONSTRAINT uk_exam_answer_round_cert_number UNIQUE (cert_type, round_number)
);

-- 2. 문항
--    subject_no: 1 (1~10번), 2 (11~50번) / operator_answer: 1~4, 없으면 NULL
--    operator_answer_status: UNKNOWN 모름, LEADING 우세, DISPUTED 갈림, CONFIRMED 확정, OFFICIAL 공식
--    alternative_answers: 복수 정답 (예: '2,3')
CREATE TABLE IF NOT EXISTS exam_answer_item (
    exam_answer_item_uuid  UUID         PRIMARY KEY,
    exam_answer_round_uuid UUID         NOT NULL,
    question_no            INTEGER      NOT NULL,
    subject_no             INTEGER      NOT NULL,
    concept_title          VARCHAR(200),
    concept_tags           VARCHAR(300),
    topic_code             VARCHAR(50),
    operator_answer        INTEGER,
    operator_answer_status VARCHAR(20)  NOT NULL DEFAULT 'UNKNOWN',
    alternative_answers    VARCHAR(20),
    note                   TEXT,
    created_at             TIMESTAMP(6),
    updated_at             TIMESTAMP(6),
    created_by             VARCHAR(255),
    updated_by             VARCHAR(255),
    CONSTRAINT uk_exam_answer_item_round_question UNIQUE (exam_answer_round_uuid, question_no)
);

-- 3. 답안
--    client_token_hash: 클라이언트 토큰 SHA-256 hex (원본 저장 안 함) / member_uuid: 로그인 제출이면 회원, 아니면 NULL
--    answers: 50자, 자리마다 '0' 모름 · '1'~'4' / source: WEB 소개 사이트, APP 앱
CREATE TABLE IF NOT EXISTS exam_answer_sheet (
    exam_answer_sheet_uuid UUID         PRIMARY KEY,
    exam_answer_round_uuid UUID         NOT NULL,
    client_token_hash      VARCHAR(64)  NOT NULL,
    member_uuid            UUID,
    answers                VARCHAR(50)  NOT NULL,
    source                 VARCHAR(10)  NOT NULL,
    created_at             TIMESTAMP(6),
    updated_at             TIMESTAMP(6),
    created_by             VARCHAR(255),
    updated_by             VARCHAR(255),
    CONSTRAINT uk_exam_answer_sheet_round_client UNIQUE (exam_answer_round_uuid, client_token_hash)
);

-- 4. SQLD 63회 시드 (회차 UUID 고정, 이미 있으면 그대로)
INSERT INTO exam_answer_round (exam_answer_round_uuid, cert_type, round_number, exam_date, title, status, notice,
                               created_at, updated_at)
VALUES ('b7c1a063-1075-4e00-8000-000000000063', 'SQLD', 63, DATE '2026-11-14', '제63회 SQLD 가답안', 'COLLECTING',
        '공식 정답이 아닙니다. 정답은 한국데이터산업진흥원 발표로 확인해 주세요.', NOW(), NOW())
ON CONFLICT (cert_type, round_number) DO NOTHING;

-- 빈 문항 50행 (63회 회차가 있을 때, 이미 있는 번호는 건너뜀)
INSERT INTO exam_answer_item (exam_answer_item_uuid, exam_answer_round_uuid, question_no, subject_no,
                              operator_answer_status, created_at, updated_at)
SELECT gen_random_uuid(), round_row.exam_answer_round_uuid, question_number,
       CASE WHEN question_number <= 10 THEN 1 ELSE 2 END, 'UNKNOWN', NOW(), NOW()
FROM exam_answer_round round_row
CROSS JOIN generate_series(1, 50) AS question_number
WHERE round_row.cert_type = 'SQLD' AND round_row.round_number = 63
ON CONFLICT (exam_answer_round_uuid, question_no) DO NOTHING;
