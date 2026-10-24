-- =============================================================================
-- V1_51_0: 신고 처리 사유 메모 (#613)
-- =============================================================================

-- 처리·기각 시 관리자가 남기는 사유 (최대 500자, 없으면 NULL)
ALTER TABLE question_report ADD COLUMN IF NOT EXISTS resolution_note VARCHAR(500);

-- 신고 목록 기간·상태 필터와 문제별 집계 조회용
CREATE INDEX IF NOT EXISTS idx_question_report_created_at ON question_report (created_at);
