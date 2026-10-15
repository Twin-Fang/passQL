-- 신고 처리자: 관리자 로그인 아이디 저장 (#472)
-- 관리자는 회원이 아니라 UUID 컬럼(resolved_by)에 담을 수 없음, resolved_by 는 데이터 보존을 위해 남기고 미사용
ALTER TABLE question_report ADD COLUMN IF NOT EXISTS resolved_by_admin_username VARCHAR(100);
