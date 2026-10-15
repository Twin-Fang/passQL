-- 건의 관리자 메모 (답변·처리 내용, 앱 미노출, #479)
-- 신고 기각 상태 DISMISSED 는 question_report.status VARCHAR(20) 에 그대로 저장 (DDL 변경 없음)
ALTER TABLE feedback ADD COLUMN IF NOT EXISTS admin_memo VARCHAR(1000);
