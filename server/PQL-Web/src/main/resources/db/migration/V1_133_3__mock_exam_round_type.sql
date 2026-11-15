-- =============================================================================
-- V1_133_3: 기출 복원 회차 (#1079)
-- 1. round_type: MOCK 모의고사(기존 행), PAST_EXAM 기출 복원 회차
-- 2. exam_date: 실제 시험일 (PAST_EXAM 만, 회차 번호는 round_number 에 실제 시험 회차)
-- 3. 회차 번호 유니크: 전체 > 종류별 (모의고사 제3회와 기출 62회가 따로 번호를 가짐)
-- =============================================================================

-- 1. 회차 종류 (기존 행은 모의고사)
ALTER TABLE mock_exam_round ADD COLUMN IF NOT EXISTS round_type VARCHAR(20) NOT NULL DEFAULT 'MOCK';

-- 2. 실제 시험일
ALTER TABLE mock_exam_round ADD COLUMN IF NOT EXISTS exam_date DATE;

-- 3. 유니크 교체 (기존 행은 모두 MOCK 이라 새 유니크와 충돌 없음)
ALTER TABLE mock_exam_round DROP CONSTRAINT IF EXISTS uk_mock_exam_round_number;
CREATE UNIQUE INDEX IF NOT EXISTS uk_mock_exam_round_type_number ON mock_exam_round (round_type, round_number);
