-- =============================================================================
-- V1_110_1: SQLD 시험 일정 자동 수집 (#991)
-- 1. exam_schedule: 접수·수험표·사전점수·발표 일정 칸, 출처, 수동 고정, 마지막 수집 시각 (기존 행 유지, 출처 MANUAL)
-- 2. exam_schedule_sync_run: 수집 1회 = 1행 (성공·실패, 실패 사유·원문 일부)
-- 3. auto_notification_rule: 시험 일정 알림 규칙 5종 (기본 꺼짐, 관리자 > 자동 알림에서 켬)
-- =============================================================================

-- 1. 시험 일정 칸 확장
--    source: AUTO 공식 페이지 수집, MANUAL 관리자 입력 / is_manual_locked: TRUE 면 자동 수집이 덮어쓰지 않음
ALTER TABLE exam_schedule ADD COLUMN IF NOT EXISTS application_start_date       DATE;
ALTER TABLE exam_schedule ADD COLUMN IF NOT EXISTS application_end_date         DATE;
ALTER TABLE exam_schedule ADD COLUMN IF NOT EXISTS admission_ticket_date        DATE;
ALTER TABLE exam_schedule ADD COLUMN IF NOT EXISTS preliminary_score_start_date DATE;
ALTER TABLE exam_schedule ADD COLUMN IF NOT EXISTS preliminary_score_end_date   DATE;
ALTER TABLE exam_schedule ADD COLUMN IF NOT EXISTS result_announcement_date     DATE;
ALTER TABLE exam_schedule ADD COLUMN IF NOT EXISTS source                       VARCHAR(10) NOT NULL DEFAULT 'MANUAL';
ALTER TABLE exam_schedule ADD COLUMN IF NOT EXISTS is_manual_locked             BOOLEAN     NOT NULL DEFAULT FALSE;
ALTER TABLE exam_schedule ADD COLUMN IF NOT EXISTS last_collected_at            TIMESTAMP(6);

-- 2. 수집 기록
--    trigger_type: SCHEDULED 자동(매일 06:05 KST), ADMIN 관리자 「지금 수집」
--    failure_reason: NULL 성공, FETCH_FAILED·TABLE_NOT_FOUND·COLUMN_COUNT_MISMATCH·SQLD_ROWS_NOT_FOUND·DATE_PARSE_FAILED·
--      DATE_ORDER_INVALID·ROUND_ORDER_INVALID·ROUND_DECREASED·UNEXPECTED_ERROR
--    year_source: HEADING·CAPTION·KNOWN_ROUND·REFERENCE_DATE (연도 결정 근거)
--    published_year: 이 수집으로 처음 생긴 연도 (새 연도 공개 알림 대상), is_publish_announced: 그 알림을 보냈는지
CREATE TABLE IF NOT EXISTS exam_schedule_sync_run (
    exam_schedule_sync_run_uuid UUID         PRIMARY KEY,
    trigger_type                VARCHAR(20)  NOT NULL,
    started_at                  TIMESTAMP(6) NOT NULL,
    finished_at                 TIMESTAMP(6),
    is_success                  BOOLEAN      NOT NULL DEFAULT FALSE,
    failure_reason              VARCHAR(40),
    failure_detail              VARCHAR(500),
    source_excerpt              TEXT,
    schedule_year               INTEGER,
    year_source                 VARCHAR(20),
    collected_round_count       INTEGER      NOT NULL DEFAULT 0,
    max_round                   INTEGER,
    created_count               INTEGER      NOT NULL DEFAULT 0,
    updated_count               INTEGER      NOT NULL DEFAULT 0,
    skipped_locked_count        INTEGER      NOT NULL DEFAULT 0,
    published_year              INTEGER,
    is_publish_announced        BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at                  TIMESTAMP(6),
    updated_at                  TIMESTAMP(6),
    created_by                  VARCHAR(255),
    updated_by                  VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_exam_schedule_sync_run_started_at ON exam_schedule_sync_run (started_at);

-- 3. 시험 일정 알림 규칙 (이동 화면 EXAM_SCHEDULE = 앱 시험 일정 화면, 앱 미구현 버전은 이동 없이 열림)
--    문구 치환: {year} 연도, {round} 회차, {examDate} 시험일 "3.7(토)", {applicationEndDate} 접수 마감일
INSERT INTO auto_notification_rule
    (auto_notification_rule_uuid, rule_type, is_enabled, send_hour, threshold_days, title, body, link_target, created_at, updated_at)
VALUES
    (gen_random_uuid(), 'EXAM_SCHEDULE_PUBLISHED', FALSE, 11, NULL,
     '{year}년 SQLD 시험 일정이 공개됐어요', '접수 기간과 시험일을 미리 확인해 두세요.', 'EXAM_SCHEDULE', NOW(), NOW()),
    (gen_random_uuid(), 'EXAM_APPLICATION_OPEN', FALSE, 10, NULL,
     '제{round}회 SQLD 접수가 시작됐어요', '{applicationEndDate}까지 공식 사이트에서 신청해요.', 'EXAM_SCHEDULE', NOW(), NOW()),
    (gen_random_uuid(), 'EXAM_APPLICATION_CLOSING', FALSE, 12, NULL,
     '내일 SQLD 접수가 마감돼요', '제{round}회 접수는 {applicationEndDate}까지예요. 놓치지 마세요.', 'EXAM_SCHEDULE', NOW(), NOW()),
    (gen_random_uuid(), 'EXAM_ADMISSION_TICKET', FALSE, 10, NULL,
     '제{round}회 SQLD 수험표가 나왔어요', '시험일은 {examDate}이에요. 수험표를 미리 확인해 두세요.', 'EXAM_SCHEDULE', NOW(), NOW()),
    (gen_random_uuid(), 'EXAM_RESULT_ANNOUNCED', FALSE, 10, NULL,
     '오늘 제{round}회 SQLD 합격 발표일이에요', '공식 사이트에서 결과를 확인해 보세요.', 'EXAM_SCHEDULE', NOW(), NOW())
ON CONFLICT (rule_type) DO NOTHING;
