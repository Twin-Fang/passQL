-- =============================================================================
-- V1_31_0: 관리자 대시보드 통계 수집 (#557)
-- 1. member_activity_hour: 회원 시간대별 활동 (시간당 회원 1행, 400일 보관)
-- 2. ai_call_log: 호출 출처·모델·토큰 수 컬럼
-- 3. app_setting: 모델별 단가표, 월 예산
-- =============================================================================

-- 1. 회원 시간대별 활동 (activity_hour: 활동 시각을 시 단위로 자른 값, 서버 로컬 시간)
--    PK 선두 activity_hour 가 기간 집계 인덱스 역할
CREATE TABLE IF NOT EXISTS member_activity_hour (
    activity_hour TIMESTAMP(6) NOT NULL,
    member_uuid   UUID         NOT NULL,
    CONSTRAINT pk_member_activity_hour PRIMARY KEY (activity_hour, member_uuid)
);
-- 회원별 활동 이력 조회용
CREATE INDEX IF NOT EXISTS idx_member_activity_hour_member ON member_activity_hour (member_uuid);

-- 2. AI 호출 기록 확장
--    call_source: AI_SERVER Python AI 서버 경유, GEMINI_DIRECT Spring 직접 Gemini 호출
--    completion_token_count: 출력 + thinking 토큰 (thinking 도 출력 단가)
ALTER TABLE ai_call_log ADD COLUMN IF NOT EXISTS call_source VARCHAR(20) NOT NULL DEFAULT 'AI_SERVER';
ALTER TABLE ai_call_log ADD COLUMN IF NOT EXISTS model_name VARCHAR(100);
ALTER TABLE ai_call_log ADD COLUMN IF NOT EXISTS prompt_token_count INTEGER;
ALTER TABLE ai_call_log ADD COLUMN IF NOT EXISTS completion_token_count INTEGER;

-- 3. 비용 추정 설정 (단가: USD / 1M 토큰, 출처 https://ai.google.dev/gemini-api/docs/pricing 2026-10-20 확인)
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'ai.model_price_table', 'STRING',
     '{"gemini-2.5-flash-lite":{"inputUsdPerMillion":0.10,"outputUsdPerMillion":0.40},'
         || '"gemini-3.1-flash-lite":{"inputUsdPerMillion":0.25,"outputUsdPerMillion":1.50},'
         || '"gemini-3.5-flash-lite":{"inputUsdPerMillion":0.30,"outputUsdPerMillion":2.50},'
         || '"gemini-2.5-flash":{"inputUsdPerMillion":0.30,"outputUsdPerMillion":2.50},'
         || '"gemini-3.6-flash":{"inputUsdPerMillion":0.75,"outputUsdPerMillion":3.75},'
         || '"gemini-3.8-flash":{"inputUsdPerMillion":0.75,"outputUsdPerMillion":3.75}}',
     'ai', 'AI 모델별 단가표 (JSON, USD / 1M 토큰, output 은 thinking 포함, 모델명 정확 일치 > 가장 긴 접두 일치, 출처 https://ai.google.dev/gemini-api/docs/pricing 2026-10-20 확인)'),
    (gen_random_uuid(), 'ai.monthly_budget_usd', 'FLOAT', '10',
     'ai', 'AI 월 예산 (USD, 대시보드 예산 사용률 기준, 2026-10-20 설정)')
ON CONFLICT (setting_key) DO NOTHING;
