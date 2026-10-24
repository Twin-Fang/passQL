-- 관리자 회원 메모, 제재 사유 분류, 커뮤니티 신고 처리 기록, 건의 답변 기록 (#626, #627, #628)
ALTER TABLE member ADD COLUMN IF NOT EXISTS admin_memo VARCHAR(1000);
ALTER TABLE member_suspend_history ADD COLUMN IF NOT EXISTS reason_category VARCHAR(30);
ALTER TABLE community_report ADD COLUMN IF NOT EXISTS handled_by VARCHAR(100);
ALTER TABLE community_report ADD COLUMN IF NOT EXISTS handled_note VARCHAR(200);
ALTER TABLE community_report ADD COLUMN IF NOT EXISTS handled_at TIMESTAMP(6);
ALTER TABLE feedback ADD COLUMN IF NOT EXISTS reply_message VARCHAR(500);
ALTER TABLE feedback ADD COLUMN IF NOT EXISTS replied_at TIMESTAMP(6);
