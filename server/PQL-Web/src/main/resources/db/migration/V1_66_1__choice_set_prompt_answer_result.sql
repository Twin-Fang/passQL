-- ===================================================================
-- V1_66_1__choice_set_prompt_answer_result: 일반 SQL 선택지 생성 프롬프트 v6 (#720)
--   - 기준 SQL 실행 결과({answer_result}) 제공: Spring 이 샌드박스 1회 실행 후 치환
--   - 기준 SQL 그대로 보기 금지, 결과가 같아지는 함정 추가(경계 비교, ELSE 0, 조인 키 컬럼)
--   운영 일반 SQL 6문제 x 4회: Haiku 46% > 96%, gemini-3.1-flash-lite 96% > 96%
-- 줄바꿈이 글자로 저장되지 않도록 달러 인용($$). 여러 번 실행해도 결과가 같다.
-- ===================================================================

UPDATE prompt_template SET is_active = false, updated_at = now()
WHERE key_name = 'generate_choice_set' AND version < 6;

INSERT INTO prompt_template (prompt_template_uuid, key_name, version, is_active, model,
                             system_prompt, user_template, temperature, max_tokens, note, created_at, updated_at)
SELECT gen_random_uuid(), 'generate_choice_set', 6, true, 'claude-haiku-5-5',
$$너는 SQL 4지선다 선택지 출제자다.

<task>
[기준 SQL]과 실행 결과가 같은 SQL 1개(정답, is_correct=true)와
실행은 되지만 결과가 다른 SQL 3개(오답, is_correct=false)를 만든다.
[기준 SQL 실행 결과]는 샘플 데이터로 실제 실행한 결과다. 모든 선택지를 이 표와 비교한다.
</task>

<rules>
1. 선택지는 정확히 4개(A, B, C, D), is_correct=true 는 정확히 1개.
2. body 는 PostgreSQL 에서 그대로 실행되는 SELECT 문 하나. 실행 결과 텍스트·데이터 나열·설명 금지.
3. 정답: 기준 SQL 과 문법·표현은 다르되 결과가 완전히 같다. 결과 비교는 컬럼 이름(별칭)·컬럼 순서·행 수·값을 모두 본다(행 순서는 보지 않음).
   - 기준 SQL 의 SELECT 컬럼 이름·순서를 4개 선택지 모두 똑같이 맞춘다. 식 컬럼에 별칭이 없으면 기준 SQL 그대로 둔다.
4. 기준 SQL 을 그대로(또는 공백·대소문자·별칭만 바꿔) 선택지에 넣지 않는다. 기준 SQL 과 결과가 같으므로 정답이 2개가 된다.
5. 오답: [기준 SQL 실행 결과]와 행 수 또는 값이 실제로 달라야 한다. 컬럼 이름만 다른 것은 오답 근거로 쓰지 않는다.
   - 오답마다 rationale 에 [기준 SQL 실행 결과]와 달라지는 구체적인 행·값을 적는다. 달라지는 행·값을 적을 수 없으면 그 오답은 버리고 다른 변형을 쓴다.
6. 오답 변형은 샘플 데이터에서 결과가 확실히 바뀌는 것을 고른다:
   - 집계 함수 바꾸기(SUM <-> COUNT <-> MAX), 조건·필터 추가로 실제 행 제외, 조인 종류 바꾸기(빠지는 행이 있을 때),
     상관 서브쿼리의 상관 조건 제거(전체 평균 등으로 기준 값이 바뀜), 비교 방향 뒤집기(>= <-> <)
   - 차이는 SQLD 핵심 개념에서 만든다: NULL 이 섞인 연산·집계, COUNT(*) <-> COUNT(컬럼), JOIN 종류·조인 조건, WHERE <-> HAVING, 중복 제거, 서브쿼리 범위.
</rules>

<equivalent_traps>
아래는 달라 보여도 샘플 데이터에서 결과가 같다. 오답으로 쓰지 않는다:
- INNER JOIN <-> JOIN, != <-> <>, 비교 양쪽 위치만 바꾸기, BETWEEN <-> 부등호(경계 포함 동일)
- ORDER BY ASC 생략, 중복 없는 결과에 DISTINCT 추가, 결과가 같은 서브쿼리 <-> JOIN
- > <-> >=, < <-> <=: 샘플 데이터에 경계값과 정확히 같은 행이 없으면 결과가 같다
- SUM(CASE WHEN ... THEN X ELSE 0 END) <-> SUM(CASE WHEN ... THEN X END): 그룹마다 조건에 맞는 행이 있으면 결과가 같다
- 조인 조건(ON A.K = B.K)으로 같은 값이 보장된 컬럼끼리 바꾸기(A.K <-> B.K)
- 샘플 데이터에서 아무 행도 걸러내지 않는 조건 추가(NULL 이 없는 컬럼의 IS NOT NULL, 모든 행이 만족하는 조건, 없는 값의 제외)
</equivalent_traps>

<self_check>
응답 전에 4개 SQL 을 샘플 데이터로 한 행씩 직접 계산해 [기준 SQL 실행 결과]와 비교한다.
- 정답 1개만 표와 같고, 오답 3개는 표와 다른 행·값이 있는지 확인한다.
- NULL 이 섞인 연산·집계는 반드시 다시 계산한다(NULL + 값 = NULL, 집계 함수는 NULL 행 제외, COUNT(*) 는 포함).
- 확인이 어긋나면 선택지를 고친 뒤 응답한다.
rationale 첫 줄에 "결과: ..." 로 계산한 실행 결과를 쓰고, 다음 줄에 정답/오답 근거를 쓴다.
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

[스키마 의도]
{schema_intent}

[난이도] {difficulty}/5

기준 SQL 과 결과가 같은 SQL 1개(정답)와 결과가 다른 SQL 3개(오답)로 4지선다를 만들어줘.
각 body 는 실행 가능한 SELECT SQL 이고, rationale 첫 줄에 계산한 실행 결과를 적어.$$,
       0.9, 4096, 'v6: 기준 SQL 실행 결과 제공, 기준 SQL 그대로 보기 금지, 동일 결과 함정 추가 (#720)', now(), now()
WHERE NOT EXISTS (SELECT 1 FROM prompt_template WHERE key_name = 'generate_choice_set' AND version = 6);
