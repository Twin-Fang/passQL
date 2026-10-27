-- ===================================================================
-- V1_63_2: ODD_ONE_OUT("실행 결과가 나머지 셋과 다른 것은?") 전용 선택지 프롬프트 (#699)
--   기본 프롬프트(generate_choice_set)는 "기준과 같은 결과 1개 + 다른 결과 3개"를 요구해
--   SandboxValidator 의 ODD_ONE_OUT 판정(같은 결과 3개 + 다른 결과 1개)과 반대 > 생성이 늘 실패
--   이 키는 ChoiceSetGenerationService.toStandardPromptKey 가 ODD_ONE_OUT 문제에만 사용
--   변수는 기본 프롬프트와 같음: stem, answer_sql, schema_ddl, schema_sample_data, schema_intent, difficulty
-- ===================================================================

INSERT INTO prompt_template (
    prompt_template_uuid, key_name, version, is_active, model,
    system_prompt, user_template, temperature, max_tokens, note,
    created_at, updated_at
)
SELECT gen_random_uuid(), 'generate_choice_set_odd_one_out', 1, TRUE, 'claude-haiku-5-5',
'너는 SQL 문제의 4지선다 선택지를 생성하는 출제자야.

이 문제 유형은 "다음 중 실행 결과가 나머지 셋과 다른 SQL은?" 유형이다.
정답(is_correct=true)은 실행 결과가 다른 SQL 1개이고,
오답(is_correct=false) 3개는 기준 SQL과 실행 결과가 완전히 같은 SQL이다.

반드시 아래 규칙을 지킨다:
1. 선택지는 정확히 4개(A, B, C, D), 정답(is_correct=true)은 정확히 1개.
2. 각 선택지의 "body" 는 PostgreSQL 에서 실행 가능한 SELECT SQL 쿼리 하나. 실행 결과 텍스트·데이터 나열 금지.
3. 오답 3개는 샘플 데이터 기준으로 기준 SQL과 행 수·값이 모두 같아야 한다. 서로 다른 문법으로 쓴다.
   - 예: JOIN <-> 서브쿼리, CASE <-> COALESCE, BETWEEN <-> 부등호, IN <-> OR, 집계 식 분해(NULL 이 없을 때만)
4. 정답 1개는 그럴듯하지만 샘플 데이터에서 결과가 달라지는 SQL. 차이는 시험 핵심 개념에서 나온다.
   - 예: NULL 이 섞인 연산·집계, COUNT(*) <-> COUNT(컬럼), 조인 조건 누락, WHERE <-> HAVING, 중복 제거 여부
5. 결과 비교는 컬럼 이름까지 본다. 4개 모두 SELECT 컬럼 개수·순서·이름(별칭)을 똑같이 맞춘다.
   - 기준 SQL에 별칭이 없는 식 컬럼이면 4개 모두 같은 별칭을 붙인다 (예: AS RESULT).
6. 행 순서는 비교하지 않는다. ORDER BY 는 결과 행 수를 바꾸지 않는 범위에서만 쓴다.
7. 응답 전에 샘플 데이터로 4개 결과를 한 줄씩 계산해, 오답 3개가 서로 같고 정답 1개만 다른지 확인한다.
8. rationale: 오답은 기준 SQL과 같은 결과가 나오는 이유, 정답은 결과가 달라지는 이유와 실제 값.
9. 반드시 response_schema 에 맞는 JSON 으로만 응답한다.',
'[문제]\n{stem}\n\n[기준 SQL]\n{answer_sql}\n\n[DB 스키마]\n{schema_ddl}\n\n[샘플 데이터]\n{schema_sample_data}\n\n[스키마 의도]\n{schema_intent}\n\n[난이도] {difficulty}/5\n\n기준 SQL과 실행 결과가 같은 SQL 3개(오답)와 결과가 다른 SQL 1개(정답)로 4지선다를 생성해줘.\n4개 모두 SELECT 컬럼 개수·순서·이름(별칭)을 똑같이 맞추고, 각 선택지 body 는 실행 가능한 SELECT SQL 이어야 한다.\n각 선택지에 rationale(왜 정답/오답인지 근거)을 포함해.',
0.7, 1536,
'v1: ODD_ONE_OUT 정책 전용. 같은 결과 3개(오답) + 다른 결과 1개(정답), 컬럼 이름까지 일치 (#699)',
NOW(), NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM prompt_template
    WHERE key_name = 'generate_choice_set_odd_one_out' AND version = 1
);
