-- =============================================================================
-- V1_60_0: Claude 제공자 전환 설정 (#688)
--   ai.claude_api_key  : Claude API 키 (SECRET, 관리자 화면에서 입력 > 암호문 저장)
--   ai.model_override  : 전체 AI 모델 일괄 지정 (비우면 프롬프트별 모델, claude-* > Claude, 그 외 > Gemini)
--   ai.model_price_table: Claude 단가 추가 (USD / 1M 토큰, 출처 https://platform.claude.com/docs/en/about-claude/pricing 2026-10-27 확인)
-- =============================================================================

INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description, created_at, updated_at)
VALUES
    (gen_random_uuid(), 'ai.claude_api_key', 'SECRET', '', 'ai',
     'Anthropic Claude API Key (관리자만 수정 가능, Console 조직에서 발급)', NOW(), NOW()),
    (gen_random_uuid(), 'ai.model_override', 'STRING', '', 'ai',
     '전체 AI 모델 일괄 지정 (비우면 프롬프트별 모델 사용, 예: claude-haiku-5-5 > 모든 호출 Claude, gemini-2.5-flash-lite > 모든 호출 Gemini)', NOW(), NOW())
ON CONFLICT (setting_key) DO NOTHING;

-- 단가표에 Claude 모델 추가 (기존 JSON 값이 있을 때만, 같은 모델 키는 덮어씀)
UPDATE app_setting
SET value_text = (value_text::jsonb || ('{"claude-haiku-5-5":{"inputUsdPerMillion":0.10,"outputUsdPerMillion":0.50},'
        || '"claude-sonnet-5-5":{"inputUsdPerMillion":2.00,"outputUsdPerMillion":10.00}}')::jsonb)::text,
    updated_at = NOW()
WHERE setting_key = 'ai.model_price_table'
  AND value_text IS NOT NULL
  AND value_text <> '';
