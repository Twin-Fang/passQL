-- AI 해설(diff_explain, explain_error) 프롬프트 v2 (#356 모델 비교 결과 반영)
-- - v1 은 다른 주제(UNION, JOIN 등) 팁을 유도해 해설에 엉뚱한 내용이 섞였고, '옳지 않은 것' 문제의 방향을 자주 거꾸로 이해했다.
-- - lite 등급 3종(2.5 / 3.1 / 3.5-flash-lite)을 같은 실제 문제로 비교해 오류가 가장 적은 gemini-3.5-flash-lite 로 바꾼다.
-- - 답변 규칙(문제 방향·샘플 데이터 근거·형식)은 서버 코드(AiExplainService)가 사용자 프롬프트에 붙인다.
-- 줄바꿈이 글자로 저장되지 않도록 달러 인용($$)을 쓴다(V0_0_159 문제 재발 방지). 여러 번 실행해도 결과가 같다.

UPDATE prompt_template SET is_active = false, updated_at = now()
WHERE key_name IN ('diff_explain', 'explain_error') AND version < 2;

INSERT INTO prompt_template (prompt_template_uuid, key_name, version, is_active, model,
                             system_prompt, user_template, temperature, max_tokens, note, created_at, updated_at)
SELECT gen_random_uuid(), 'diff_explain', 2, true, 'gemini-3.5-flash-lite',
       $$당신은 SQLD 시험 대비 SQL 튜터입니다. 학습자가 문제를 틀렸을 때 정확하고 간결하게 해설합니다.
확실하지 않은 내용은 추측하지 않고, 이 문제와 직접 관련된 개념만 설명합니다.$$,
       NULL, 0.3, 1024, '선택지 비교 해설 v2 — 모델 비교(#356) 결과 반영', now(), now()
WHERE NOT EXISTS (SELECT 1 FROM prompt_template WHERE key_name = 'diff_explain' AND version = 2);

INSERT INTO prompt_template (prompt_template_uuid, key_name, version, is_active, model,
                             system_prompt, user_template, temperature, max_tokens, note, created_at, updated_at)
SELECT gen_random_uuid(), 'explain_error', 2, true, 'gemini-3.5-flash-lite',
       $$당신은 SQLD 시험 대비 SQL 튜터입니다. 학습자가 실행한 SQL 에서 난 오류의 원인과 고치는 방법을 정확하고 간결하게 설명합니다.
확실하지 않은 내용은 추측하지 않습니다.$$,
       NULL, 0.3, 1024, 'SQL 오류 해설 v2 — 모델 비교(#356) 결과 반영', now(), now()
WHERE NOT EXISTS (SELECT 1 FROM prompt_template WHERE key_name = 'explain_error' AND version = 2);
