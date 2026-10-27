-- =============================================================================
-- V1_61_0: 전체 AI 기본 모델 > claude-haiku-5-5 (#688)
--   프롬프트(문제 생성·선택지·해설·코멘트 등) 모델을 모두 Haiku 로 지정
--   기능별 변경: 관리자 프롬프트 화면 모델 칸 / 전체 일괄 변경: 관리자 설정 ai.model_override
--   Gemini 복귀: 해당 프롬프트 모델을 gemini-* 로 바꾸면 됨 (키 설정 유지)
-- =============================================================================

UPDATE prompt_template
SET model      = 'claude-haiku-5-5',
    updated_at = NOW()
WHERE model IS DISTINCT FROM 'claude-haiku-5-5';

-- 새 프롬프트 기본 모델 표시값 (ai.default_model)
UPDATE app_setting
SET value_text = 'claude-haiku-5-5',
    updated_at = NOW()
WHERE setting_key = 'ai.default_model';
