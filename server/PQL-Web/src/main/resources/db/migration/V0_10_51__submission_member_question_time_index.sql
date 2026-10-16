-- 회원별·문제별 최근 제출 조회 인덱스 (#497): 진행률·토픽 분석·오늘의 세트 복원이 쓰는 "문제별 마지막 시도" 패턴
-- (member_uuid, question_uuid) 인덱스를 시간 정렬까지 포함한 인덱스로 대체
CREATE INDEX IF NOT EXISTS idx_submission_member_question_submitted
    ON submission (member_uuid, question_uuid, submitted_at DESC);
DROP INDEX IF EXISTS idx_submission_member_question;
