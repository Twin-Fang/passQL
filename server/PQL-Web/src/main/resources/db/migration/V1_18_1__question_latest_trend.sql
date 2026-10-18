-- 최신 출제 경향 문제 표시 (#523)
-- is_latest_trend: 최신 경향 반영 문제 TRUE (앱·웹 '최신 경향' 배지, 경향 화면 풀기 대상), 기본 FALSE
-- 값 지정은 관리자 일괄 API(PUT /admin/questions/latest-trend)로만 (운영 데이터 조건 UPDATE 없음)
ALTER TABLE question ADD COLUMN IF NOT EXISTS is_latest_trend BOOLEAN NOT NULL DEFAULT FALSE;
CREATE INDEX IF NOT EXISTS idx_question_latest_trend ON question (is_latest_trend);
