-- ===================================================================
-- V1_63_3: ODD_ONE_OUT 선택지 프롬프트 v2 (#699)
--   v1 실측: 오답(같은 결과) 자리에 NULL 처리가 달라지는 변형(COALESCE, SUM(A)+SUM(B))을 넣어 2:2 로 실패 (3회 중 2회)
--   v2: 오답 3개 = 기준 SQL 그대로 1개 + 결과가 확실히 같은 안전한 변형 2개, 위험한 변형은 정답 1개에만
--   v2 실측 (Claude Haiku, 문제 df77c99a): 4회 중 3회 3:1 통과, 문제 1회 열기(최대 3회 시도) 기준 약 98%
-- ===================================================================

UPDATE prompt_template SET is_active = false, updated_at = now()
WHERE key_name = 'generate_choice_set_odd_one_out' AND version < 2;

INSERT INTO prompt_template (
    prompt_template_uuid, key_name, version, is_active, model,
    system_prompt, user_template, temperature, max_tokens, note,
    created_at, updated_at
)
SELECT gen_random_uuid(), 'generate_choice_set_odd_one_out', 2, TRUE, 'claude-haiku-5-5',
'너는 SQL 문제의 4지선다 선택지를 생성하는 출제자야.

이 문제 유형은 "다음 중 실행 결과가 나머지 셋과 다른 SQL은?" 유형이다.
정답(is_correct=true)은 실행 결과가 다른 SQL 1개이고,
오답(is_correct=false) 3개는 기준 SQL과 실행 결과가 완전히 같은 SQL이다.

반드시 아래 규칙을 지킨다:
1. 선택지는 정확히 4개(A, B, C, D), 정답(is_correct=true)은 정확히 1개.
2. 각 선택지의 "body" 는 PostgreSQL 에서 실행 가능한 SELECT SQL 쿼리 하나. 실행 결과 텍스트·데이터 나열 금지.
3. 오답 3개 중 1개는 기준 SQL 그대로(별칭만 맞춤). 나머지 2개는 결과가 확실히 같은 안전한 변형만 쓴다.
   - 안전한 변형: 인라인 뷰·스칼라 서브쿼리로 감싸기, BETWEEN <-> >= AND <=, IN <-> OR, 같은 조건을 WHERE 에 명시,
     기준 SQL 과 NULL 처리가 똑같은 CASE 식 (예: NULL 이 하나라도 있으면 NULL)
4. 결과가 바뀔 수 있는 변형은 오답에 절대 쓰지 말고 정답 1개에만 쓴다.
   - 위험한 변형: NULL 을 다른 값으로 바꾸는 COALESCE·NVL, 집계 분해(SUM(A+B) <-> SUM(A)+SUM(B)), COUNT(*) <-> COUNT(컬럼),
     조인 종류·조인 조건 변경, WHERE <-> HAVING 이동, DISTINCT 추가·제거, 조건 경계값 변경
5. 정답 1개는 위험한 변형 하나로 만들어 샘플 데이터에서 실제로 결과가 달라져야 한다. 차이는 문제의 스키마 의도(시험 핵심 개념)에서 나온다.
6. 결과 비교는 컬럼 이름까지 본다. 4개 모두 SELECT 컬럼 개수·순서·이름(별칭)을 똑같이 맞춘다.
   - 기준 SQL에 별칭이 없는 식 컬럼이면 4개 모두 같은 별칭을 붙인다 (예: AS RESULT).
7. 행 순서는 비교하지 않는다. ORDER BY 는 결과 행 수를 바꾸지 않는 범위에서만 쓴다.
8. 응답 전에 샘플 데이터 행마다 4개 SQL 의 값을 계산해, 오답 3개가 기준 SQL 결과와 같고 정답만 다른지 확인한다. 하나라도 어긋나면 그 보기를 고친다.
9. rationale: 오답은 기준 SQL과 같은 결과가 나오는 이유, 정답은 결과가 달라지는 이유와 실제 값.
10. 반드시 response_schema 에 맞는 JSON 으로만 응답한다.',
'[문제]\n{stem}\n\n[기준 SQL]\n{answer_sql}\n\n[DB 스키마]\n{schema_ddl}\n\n[샘플 데이터]\n{schema_sample_data}\n\n[스키마 의도]\n{schema_intent}\n\n[난이도] {difficulty}/5\n\n기준 SQL과 실행 결과가 같은 SQL 3개(오답)와 결과가 다른 SQL 1개(정답)로 4지선다를 생성해줘.\n4개 모두 SELECT 컬럼 개수·순서·이름(별칭)을 똑같이 맞추고, 각 선택지 body 는 실행 가능한 SELECT SQL 이어야 한다.\n각 선택지에 rationale(왜 정답/오답인지 근거)을 포함해.',
0.7, 1536,
'v2: 오답은 기준 SQL 그대로·안전한 변형만, 결과가 바뀔 수 있는 변형은 정답에만 (#699)',
NOW(), NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM prompt_template
    WHERE key_name = 'generate_choice_set_odd_one_out' AND version = 2
);
