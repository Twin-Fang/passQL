-- ===================================================================
-- V1_63_4__choice_set_prompts_claude_gemini: 선택지 생성 프롬프트 Claude Haiku·Gemini 공통 개선 (#710)
--   운영 문제 48개(일반 6, 결과가 다른 것 18, 결과표 24) x Haiku·Gemini x 2회, 운영 검증 로직으로 비교
--   - max_tokens 1536 > 4096: 결과표가 긴 문제에서 Claude 응답이 잘려 빈 JSON 이 되던 문제
--   - 온도는 유지 (Claude 는 미사용, Gemini 는 낮추면 재시도마다 같은 답 반복)
-- 줄바꿈이 글자로 저장되지 않도록 달러 인용($$). 여러 번 실행해도 결과가 같다.
-- ===================================================================

UPDATE prompt_template SET is_active = false, updated_at = now()
WHERE key_name = 'generate_choice_set' AND version < 5;

INSERT INTO prompt_template (prompt_template_uuid, key_name, version, is_active, model,
                             system_prompt, user_template, temperature, max_tokens, note, created_at, updated_at)
SELECT gen_random_uuid(), 'generate_choice_set', 5, true, 'claude-haiku-5-5',
$$너는 SQL 4지선다 선택지 출제자다.

<task>
[기준 SQL]과 실행 결과가 같은 SQL 1개(정답, is_correct=true)와
실행은 되지만 결과가 다른 SQL 3개(오답, is_correct=false)를 만든다.
</task>

<rules>
1. 선택지는 정확히 4개(A, B, C, D), is_correct=true 는 정확히 1개.
2. body 는 PostgreSQL 에서 그대로 실행되는 SELECT 문 하나. 실행 결과 텍스트·데이터 나열·설명 금지.
3. 정답: 기준 SQL 과 문법·표현은 다르되 결과가 완전히 같다. 결과 비교는 컬럼 이름(별칭)·컬럼 순서·행 수·값을 모두 본다(행 순서는 보지 않음).
   - 기준 SQL 의 SELECT 컬럼 이름·순서를 4개 선택지 모두 똑같이 맞춘다. 식 컬럼에 별칭이 없으면 기준 SQL 그대로 둔다.
4. 오답: 샘플 데이터에서 기준 SQL 과 결과가 실제로 달라야 한다(행 수 또는 값). 컬럼 이름만 다른 것은 오답 근거로 쓰지 않는다.
   - 조건이 샘플 데이터에서 아무 행도 바꾸지 않으면(예: NULL 이 없는 컬럼의 IS NOT NULL, 없는 값의 제외) 결과가 같아지므로 쓰지 않는다.
   - 오답마다 rationale 에 기준 SQL 과 달라지는 구체적인 행·값을 적는다.
5. 오답 차이는 SQLD 핵심 개념에서 만든다: NULL 이 섞인 연산·집계, COUNT(*) <-> COUNT(컬럼), JOIN 종류·조인 조건, WHERE <-> HAVING, 중복 제거, 서브쿼리 범위.
</rules>

<equivalent_traps>
아래는 달라 보여도 결과가 같다. 오답으로 쓰지 않는다:
- INNER JOIN <-> JOIN, != <-> <>, 비교 방향만 뒤집기, BETWEEN <-> 부등호(경계 포함 동일)
- ORDER BY ASC 생략, 중복 없는 결과에 DISTINCT 추가
- 결과가 같은 서브쿼리 <-> JOIN, 결과가 같은 GROUP BY 컬럼 추가·제거
</equivalent_traps>

<self_check>
응답 전에 4개 SQL 을 샘플 데이터로 한 행씩 직접 계산한다.
- 정답 1개만 기준 SQL 결과와 같고, 오답 3개는 기준 SQL 결과와 다른지 확인한다.
- NULL 이 섞인 연산·집계는 반드시 다시 계산한다(NULL + 값 = NULL, 집계 함수는 NULL 행 제외, COUNT(*) 는 포함).
- 확인이 어긋나면 선택지를 고친 뒤 응답한다.
rationale 첫 줄에 "결과: ..." 로 계산한 실행 결과를 쓰고, 다음 줄에 정답/오답 근거를 쓴다.
</self_check>

반드시 response_schema 에 맞는 JSON 으로만 응답한다.$$,
$$[문제]
{stem}

[기준 SQL]
{answer_sql}

[DB 스키마]
{schema_ddl}

[샘플 데이터]
{schema_sample_data}

[스키마 의도]
{schema_intent}

[난이도] {difficulty}/5

기준 SQL 과 결과가 같은 SQL 1개(정답)와 결과가 다른 SQL 3개(오답)로 4지선다를 만들어줘.
각 body 는 실행 가능한 SELECT SQL 이고, rationale 첫 줄에 계산한 실행 결과를 적어.$$,
       0.9, 4096, 'v5: Claude Haiku·Gemini 공통 구조(task·rules·self_check), 오답 무변화 조건 금지, 출력 4096 (#710)', now(), now()
WHERE NOT EXISTS (SELECT 1 FROM prompt_template WHERE key_name = 'generate_choice_set' AND version = 5);

UPDATE prompt_template SET is_active = false, updated_at = now()
WHERE key_name = 'generate_choice_set_result_match' AND version < 2;

INSERT INTO prompt_template (prompt_template_uuid, key_name, version, is_active, model,
                             system_prompt, user_template, temperature, max_tokens, note, created_at, updated_at)
SELECT gen_random_uuid(), 'generate_choice_set_result_match', 2, true, 'claude-haiku-5-5',
$$너는 SQL 4지선다 선택지 출제자다.

<task>
"다음 SQL 의 실행 결과로 올바른 것은?" 유형이다.
선택지 body 는 SQL 이 아니라 실행 결과 표를 JSON 배열 문자열로 쓴 것이다.
- 정답(is_correct=true) 1개: [기준 SQL 실행 결과]와 같은 표
- 오답(is_correct=false) 3개: 학습자가 흔히 착각하는 다른 표
</task>

<rules>
1. 선택지는 정확히 4개(A, B, C, D), is_correct=true 는 정확히 1개.
2. body 는 JSON 배열 문자열. 행 하나 = 객체 하나, 키 = 결과 컬럼 이름(대문자).
   - 예: [{"NAME":"홍길동","CNT":2},{"NAME":"김영희","CNT":1}]
   - 결과가 없으면 []
   - SQL 쿼리·설명 문장 금지
3. 정답 body 는 [기준 SQL 실행 결과]의 컬럼·행·값을 빠짐없이 그대로 옮긴다.
   - 실행 결과 첫 줄이 컬럼 이름, 다음 줄부터 행(값은 쉼표 구분). "null" 은 JSON null 로 쓴다.
   - 숫자는 따옴표 없는 숫자, 문자는 문자열로 쓴다. 값을 반올림·변형하지 않는다.
4. 오답 3개: 4개 모두 같은 키(컬럼)를 쓰고, 행 수 또는 값이 정답과 다르다. 오답끼리도 서로 달라야 한다.
   - 채점은 행 순서와 키 대소문자를 무시한다. 행 순서만 바꾼 표, 키 순서만 바꾼 표, 숫자 표기만 다른 표(2000 <-> 2000.0)는 정답과 같은 표로 채점되므로 오답으로 쓰지 않는다.
   - 오답마다 정답과 다른 셀 값이 최소 1개 있거나 행 수가 달라야 한다.
5. 오답은 실제 착각에서 만든다: NULL 처리(집계 제외·연산 결과 NULL), COUNT(*) <-> COUNT(컬럼), 조인으로 늘어나거나 빠지는 행, WHERE <-> HAVING, 중복 제거, 정렬 오해.
</rules>

<self_check>
응답 전에 확인한다.
- 정답 body 가 [기준 SQL 실행 결과]와 행 수·값이 정확히 같은가
- 오답 3개가 행 순서를 무시하고 비교해도 정답과 다르고, 서로도 다른가
- 모든 body 가 올바른 JSON 배열인가
어긋나면 고친 뒤 응답한다.
</self_check>

반드시 response_schema 에 맞는 JSON 으로만 응답한다.$$,
$$[문제]
{stem}

[기준 SQL]
{answer_sql}

[기준 SQL 실행 결과]
{answer_result}

[DB 스키마]
{schema_ddl}

[샘플 데이터]
{schema_sample_data}

[난이도] {difficulty}/5

기준 SQL 실행 결과와 같은 표(정답 1개)와 다른 표(오답 3개)로 4지선다를 만들어줘.
각 body 는 JSON 배열 문자열이고, 정답 body 는 기준 SQL 실행 결과를 그대로 옮겨.$$,
       0.9, 4096, 'v2: 행 순서만 다른 오답 금지, 정답 표 그대로 옮기기, 자기 검증, 출력 4096 (#710)', now(), now()
WHERE NOT EXISTS (SELECT 1 FROM prompt_template WHERE key_name = 'generate_choice_set_result_match' AND version = 2);


-- 결과가 다른 것(odd_one_out) v2 는 비교에서 Haiku 100%·Gemini 78% 로 유지, 출력 한도만 4096 (잘림 방지)
UPDATE prompt_template SET max_tokens = 4096, updated_at = now()
WHERE key_name = 'generate_choice_set_odd_one_out' AND version = 2 AND max_tokens < 4096;
