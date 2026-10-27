# 개념 학습 콘텐츠 (#577)

SQLD 수험서를 대체하는 개념 글 62개와 확인 문제 310개의 원본이다. 설계는 `docs/superpowers/specs/2026-10-24-concept-learning-design.md`(로컬 전용)를 따르고, 이 문서는 파일을 쓰는 사람이 지켜야 할 규칙만 모았다.

## 파일 구조

```
content/concepts/
  concept_bundle.py         choice() · question() · sql_check() · sql_error_check(), 단원 코드 9개
  concept_dataset.py        공통 예시 데이터 (부서·사원·급여등급) 마크다운 표 + Oracle 생성 SQL
  build_concept_bundle.py   수집 > 구조 검증 > 글 점검 > build/concept_bundle.json (관리자 가져오기용)
  verify_concept_sql.py     Oracle 21c 에서 본문 SQL 블록·sqlChecks·stemSql 검증
  {topicCode}/{tagKey 밑줄}.py   개념 1개 = 파일 1개, 모듈 변수 CONCEPT 하나
```

## 명령

```bash
python3 -I content/concepts/build_concept_bundle.py                 # 전체 구조 검증 + JSON
python3 -I content/concepts/build_concept_bundle.py --topic sql_join
tools/sqld-question-harness/.venv/bin/python -I content/concepts/verify_concept_sql.py --tag-key join-outer
```

Oracle 은 `tools/sqld-question-harness/README.md` 의 XE 21c 컨테이너(`localhost:1522/XEPDB1`)를 쓴다. 가져오기는 관리자 > 개념 학습 관리 > 개념 묶음 가져오기에서 검증 후 등록하며, 새 개념은 초안(DRAFT)으로 들어간다.

## 개념 파일 형식

`sql_basic_select/select_where_null.py`(SQL 개념)와 `data_modeling/modeling_entity.py`(이론 개념)가 기준 예시다.

| 키 | 규칙 |
|---|---|
| `tagKey` | 아래 목록의 값 그대로, 파일 이름은 `-` 를 `_` 로 바꾼 것 |
| `topicCode`, `sortOrder` | 아래 목록의 값 그대로 (단원 안 순서) |
| `title` | 개념 이름 |
| `summary` | 한 문장, 단원 목록에 보이는 요약 (40자 안팎) |
| `coreMd` | `- ` 목록 3~5줄, "꼭 기억할 것"만, 1분 안에 읽힘 |
| `detailMd` | `## 제목 {#앵커}` 문단들. 첫 줄부터 제목, 앵커는 소문자·숫자·`-` |
| `checkQuestions` | `question()` 5개, 1번 정의 > 5번 짧은 응용, 보기 A~D 4개·정답 1개·보기마다 이유 |
| `relatedQuestionUuids` | 빈 목록 (기존 문제 연결은 관리자에서) |
| `sqlChecks` | Oracle 검증 전용, 가져오기 JSON 에서 빠짐 |

**자세히 본문 틀**: 왜 필요한가 > 한 줄 정의 > 예시 > 자주 헷갈리는 점 > 시험에서는 이렇게 나와요. 제목 문구는 개념에 맞게 바꿔도 되고, 내용이 많으면 예시를 단계별 문단으로 나눈다. **"자주 헷갈리는 점"을 가장 두껍게** 쓴다. 앵커 `why`, `definition`, `confusing`, `exam-point` 는 가능하면 같은 이름을 쓴다.

**쓸 수 있는 표기 (앱 렌더러 기준)**: `**굵게**`, `` `인라인 코드` ``, `- ` 목록, `1. ` 번호 줄, 마크다운 표, ```` ```sql ```` 코드 블록. `###` 이하 제목, 인용(`>`), 기울임, 이미지, HTML 은 쓰지 않는다.

## 공통 예시 데이터

모든 개념은 `concept_dataset.py` 의 표 세 개를 쓴다. 새 표를 외우게 하지 않는다. 표를 본문에 보일 때는 상수(`EMPLOYEE_TABLE_MD`, `DEPARTMENT_TABLE_MD`, `SALARY_GRADE_TABLE_MD`)나 `to_employee_table_md("사번", "이름", ...)`(일부 열·사번만)를 f-string 으로 넣고, 값을 손으로 다시 적지 않는다.

- 부서 4개: 10 기획부 서울, 20 개발부 판교, 30 영업부 부산, 40 인사부 서울(소속 사원 없음)
- 사원 8명: 커미션 NULL 4명(1001·1004·1005·1008), 커미션 0 1명(1003), 부서 없는 사원 1008, 20번 부서에 급여 2500 동점 2명, 관리자 3단계(1001 > 1002·1004·1008 > 1003·1005·1006·1007)
- 급여등급 4개: 급여 범위로 등급을 찾는 비등가 조인용

개념에 꼭 필요한 다른 표(MERGE 대상, PIVOT 용 월별 매출 등)는 그 SQL 블록 안에서 `CREATE TABLE` 로 만들고, 같은 블록 안에서 쓴다.

## Oracle 검증 규칙

- ```` ```sql ```` 블록과 `sqlChecks` 항목은 각각 공통 데이터 초기 상태에서 따로 실행된다. 블록끼리 상태를 이어 쓰지 않는다.
- 블록 안 문장은 순서대로 실행된다. 일부러 오류를 보여 주는 문장은 같은 줄이나 바로 윗줄 주석에 `오류`를 적는다(`-- 오류: GROUP BY 에 없는 열`). 그 문장은 실제로 오류가 나야 통과한다.
- 실행하지 않을 틀 설명 블록(`SELECT 열 FROM 테이블` 같은 문법 틀, 다른 계정이 필요한 GRANT 등)은 첫 줄을 `-- 문법` 으로 시작한다.
- 본문에 결과를 적었거나 결과 표를 보였으면 같은 SQL 의 `sql_check()` 를 넣는다. 날짜는 `'YYYY-MM-DD'` 문자열로 비교된다. 소수가 길게 나오면 `ROUND` 로 감싼다.
- `stemSql` 이 있는 확인 문제는 같은 SQL(공백·대소문자·끝 `;` 무시)의 `sql_check()` 또는 `sql_error_check()` 가 반드시 있어야 한다.
- 보기가 SQL 조각이면 정답 보기와 헷갈리기 쉬운 오답 보기도 검증 항목으로 확인한다.

## 글쓰기 규칙 (사용자 기준 2026-10-27, 가장 중요)

1. **교재를 대체한다.** 이 글만 읽고 시험 범위를 빠짐없이 공부할 수 있어야 한다. 시험에 나오는 세부 규칙·예외·용어를 빠뜨리지 않는다.
2. **개념은 쉽게, 헷갈리는 부분은 제대로.** 정의를 늘어놓지 말고, 수험생이 실제로 틀리는 지점(비슷한 개념끼리의 차이, NULL 처리, 실행 순서, 예외 규칙, 비슷한 함수·문법)을 예시와 함께 풀어 준다. 확인 문제도 그 지점을 묻는다.
3. **조사를 빠짐없이 붙여 이어지는 문장으로 쓴다.** "정규화: 중복 제거" 같은 메모체, 명사로 끝나는 문장, 조사가 빠진 문장을 쓰지 않는다. 한 문장에는 사실을 하나나 둘만 담는다.
4. 해요체로 통일하고, 사람이 책에 쓰듯 담백하게 쓴다. SQL·DB 지식이 0인 사람을 가정하고, 처음 나오는 용어는 그 자리에서 쉬운 말로 풀어 준다. 시험 용어는 쉬운 말 옆에 함께 적는다.
5. **금지 말투**: "~해 볼게요!" 반복, 과장("완벽하게", "핵심 중의 핵심", "마스터"), "중요합니다", "~라고 할 수 있습니다", 느낌표, 이모지, "먼저·다음으로·마지막으로" 나열식 전개.
6. **금지 구성**: 모든 개념이 같은 개수의 불릿으로 끝나는 대칭 구성, 굵은 글씨 남발, 이유 없는 비유. 비유는 개념이 추상적일 때만 쓴다. 같은 문장 시작이 세 번 이어지면 고친다.
7. 수험서 문장·예제를 옮기지 않는다. Oracle 공식 문서와 일반 지식으로 새로 쓴다. 사실이 애매하면 Oracle 에서 직접 실행해 확인한다.
8. 확인 문제: 그 개념 하나만 묻고, 쉬운 순서로 놓고, 정답 위치(A~D)가 한쪽에 몰리지 않게 한다. 오답 이유는 "왜 그걸 고르기 쉬운지"가 아니라 "왜 틀렸는지"를 한 문장으로 적는다. 해설(`explanation`)은 두 문장 안팎.
9. 결과 행 수·값을 묻는 문제는 지문에 표를 넣거나 공통 예시 데이터를 기준으로 하고, 반드시 Oracle 로 확인한다.

## 개념 목록 (62개)

| 단원 (topicCode) | sortOrder · tagKey · 제목 |
|---|---|
| 1 데이터 모델링 (`data_modeling`) | 1 `modeling-concept` 데이터 모델링의 개념과 특징 · 2 `modeling-three-levels` 개념·논리·물리 모델링과 3층 스키마 · 3 `modeling-erd` ERD 표기법 · 4 `modeling-entity` 엔터티 · 5 `modeling-attribute` 속성 · 6 `modeling-relationship` 관계 · 7 `modeling-identifier` 식별자 · 8 `modeling-normalization` 정규화 · 9 `modeling-denormalization` 반정규화 · 10 `modeling-supertype-subtype` 슈퍼타입과 서브타입 · 11 `modeling-performance` 성능 데이터 모델링 · 12 `modeling-transaction` 트랜잭션과 데이터 모델 · 13 `modeling-null-attribute` NULL 속성 |
| 2 SELECT 기본 (`sql_basic_select`) | 1 `select-structure-order` SELECT 문의 구조와 실행 순서 · 2 `select-alias-distinct` 별칭과 DISTINCT · 3 `select-operators` 비교·논리 연산자와 우선순위 · 4 `select-like-between-in` LIKE·BETWEEN·IN · 5 `select-where-null` WHERE 절과 NULL · 6 `select-order-by` ORDER BY · 7 `select-rownum-top-n` ROWNUM과 TOP N |
| 3 DDL·DML·TCL (`sql_ddl_dml_tcl`) | 1 `ddl-data-types` 데이터 타입 · 2 `ddl-create-alter-drop` CREATE·ALTER·DROP·TRUNCATE · 3 `ddl-constraints` 제약조건 · 4 `dml-insert-update-delete` INSERT·UPDATE·DELETE · 5 `dml-merge` MERGE · 6 `tcl-commit-rollback` 트랜잭션과 COMMIT·ROLLBACK·SAVEPOINT · 7 `dcl-grant-revoke` GRANT·REVOKE와 ROLE |
| 4 SQL 함수 (`sql_function`) | 1 `function-character` 문자 함수 · 2 `function-number` 숫자 함수 · 3 `function-date` 날짜 함수 · 4 `function-conversion` 변환 함수 · 5 `function-case-decode` CASE와 DECODE · 6 `function-null` NULL 관련 함수 |
| 5 조인 (`sql_join`) | 1 `join-equi-non-equi` 등가 조인과 비등가 조인 · 2 `join-inner` INNER JOIN · 3 `join-natural-using` NATURAL JOIN과 USING · 4 `join-outer` OUTER JOIN · 5 `join-cross` CROSS JOIN · 6 `join-self` 셀프 조인 |
| 6 서브쿼리 (`sql_subquery`) | 1 `subquery-single-multi-row` 단일행·다중행 서브쿼리 · 2 `subquery-multi-column` 다중 컬럼 서브쿼리 · 3 `subquery-correlated` 연관 서브쿼리와 EXISTS · 4 `subquery-scalar-inline-view` 스칼라 서브쿼리와 인라인 뷰 · 5 `subquery-view` 뷰 · 6 `subquery-set-operators` 집합 연산자 |
| 7 그룹 함수 (`sql_group_aggregate`) | 1 `group-aggregate-null` 집계 함수와 NULL · 2 `group-group-by-having` GROUP BY와 HAVING · 3 `group-rollup` ROLLUP · 4 `group-cube` CUBE · 5 `group-grouping-sets` GROUPING SETS · 6 `group-grouping-function` GROUPING 함수 |
| 8 윈도우 함수 (`sql_window`) | 1 `window-syntax` 윈도우 함수 문법 · 2 `window-rank` 순위 함수 · 3 `window-aggregate` 집계 윈도우 함수 · 4 `window-row-order` 행 순서 함수 · 5 `window-ratio` 비율 함수 · 6 `window-top-n` 윈도우 함수로 TOP N |
| 9 계층 쿼리·PIVOT (`sql_hierarchy_pivot`) | 1 `hierarchy-start-with-connect-by` START WITH와 CONNECT BY · 2 `hierarchy-prior-level` PRIOR 방향과 LEVEL · 3 `hierarchy-functions` 계층 쿼리 함수와 정렬 · 4 `pivot-unpivot` PIVOT과 UNPIVOT · 5 `regular-expression` 정규 표현식 |
