"""개념: 윈도우 함수로 TOP N (8단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

# 계산에 쓰는 원본 열 (이 개념의 예시는 모두 이 표로 계산)
EMPLOYEE_BASE_TABLE = to_employee_table_md("사번", "이름", "급여", "부서번호")

EMPLOYEE_SALARY_TABLE = to_employee_table_md("이름", "급여")

# 본문 예시 SQL > 결과 행 (본문 표와 sqlChecks 가 같은 원본을 씀, ROW_NUMBER 는 사번으로 동점 순서 고정)
TOP_THREE_SQL = """SELECT 이름, 급여, 순위
FROM (SELECT 이름, 급여,
             ROW_NUMBER() OVER (ORDER BY 급여 DESC, 사번) AS 순위
      FROM 사원)
WHERE 순위 <= 3
ORDER BY 순위;"""
TOP_THREE_ROWS = [["최유나", 3200, 1], ["김민수", 3000, 2], ["박서준", 2800, 3]]

PARTITION_RANK_TOP_SQL = """SELECT 부서번호, 이름, 급여, 순위
FROM (SELECT 부서번호, 사번, 이름, 급여,
             RANK() OVER (PARTITION BY 부서번호 ORDER BY 급여 DESC) AS 순위
      FROM 사원)
WHERE 순위 <= 2
ORDER BY 부서번호, 순위, 사번;"""
PARTITION_RANK_TOP_ROWS = [
    [10, "김민수", 3000, 1], [20, "박서준", 2800, 1], [20, "이지은", 2500, 2], [20, "정하늘", 2500, 2],
    [30, "최유나", 3200, 1], [30, "한도윤", 2700, 2], [None, "윤서연", 2000, 1],
]

PARTITION_ROW_NUMBER_TOP_SQL = """SELECT 부서번호, 이름, 급여, 순위
FROM (SELECT 부서번호, 이름, 급여,
             ROW_NUMBER() OVER (PARTITION BY 부서번호 ORDER BY 급여 DESC, 사번) AS 순위
      FROM 사원)
WHERE 순위 <= 2
ORDER BY 부서번호, 순위;"""
PARTITION_ROW_NUMBER_TOP_ROWS = [
    [10, "김민수", 3000, 1], [20, "박서준", 2800, 1], [20, "이지은", 2500, 2],
    [30, "최유나", 3200, 1], [30, "한도윤", 2700, 2], [None, "윤서연", 2000, 1],
]

ROWNUM_TOP_SQL = """SELECT 이름, 급여
FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC, 사번)
WHERE ROWNUM <= 5;"""
ROWNUM_TOP_ROWS = [["최유나", 3200], ["김민수", 3000], ["박서준", 2800], ["한도윤", 2700], ["이지은", 2500]]

FETCH_WITH_TIES_SQL = """SELECT 이름, 급여
FROM 사원
ORDER BY 급여 DESC
FETCH FIRST 5 ROWS WITH TIES;"""
FETCH_WITH_TIES_ROWS = [["최유나", 3200], ["김민수", 3000], ["박서준", 2800], ["한도윤", 2700], ["이지은", 2500], ["정하늘", 2500]]

# 안쪽 WHERE(순위 전) <-> 바깥 WHERE(순위 후)
INNER_FILTER_SQL = """SELECT 이름, 급여
FROM (SELECT 이름, 급여, RANK() OVER (ORDER BY 급여 DESC) AS 순위
      FROM 사원
      WHERE 급여 < 3000)
WHERE 순위 = 1;"""
INNER_FILTER_ROWS = [["박서준", 2800]]
OUTER_FILTER_SQL = """SELECT 이름, 급여
FROM (SELECT 이름, 급여, RANK() OVER (ORDER BY 급여 DESC) AS 순위
      FROM 사원)
WHERE 급여 < 3000 AND 순위 = 1;"""

# 순위 함수별 결과 행 수 (전체 사원, 급여 내림차순)
# 행 수는 동점끼리 순서와 무관 > 사번 없이 급여만 기준 (RANK·DENSE_RANK 동점 유지)
RANK_COUNT_SQL_TEMPLATE = "SELECT COUNT(*) FROM (SELECT {function} OVER (ORDER BY 급여 DESC) AS 순위 FROM 사원) WHERE 순위 <= {limit}"
RANK_COUNT_ROWS = [("ROW_NUMBER()", 5, 5), ("RANK()", 5, 6), ("DENSE_RANK()", 5, 6),
                   ("ROW_NUMBER()", 6, 6), ("RANK()", 6, 6), ("DENSE_RANK()", 6, 7)]

# 확인 문제 stemSql
DEPARTMENT_RANK_STEM_SQL = ("SELECT 이름 FROM (SELECT 이름, RANK() OVER (PARTITION BY 부서번호 ORDER BY 급여 DESC) AS 순위 "
                            "FROM 사원 WHERE 부서번호 = 20) WHERE 순위 <= 2;")
DENSE_RANK_STEM_SQL = "SELECT 이름 FROM (SELECT 이름, DENSE_RANK() OVER (ORDER BY 급여 DESC) AS 순위 FROM 사원) WHERE 순위 <= 6;"
FETCH_STEM_SQL = "SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC FETCH FIRST 5 ROWS WITH TIES;"

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
TOP_THREE_EXAMPLE = sql_example(TOP_THREE_SQL, ("이름", "급여", "순위"), TOP_THREE_ROWS)
PARTITION_RANK_TOP_EXAMPLE = sql_example(PARTITION_RANK_TOP_SQL, ("부서번호", "이름", "급여", "순위"), PARTITION_RANK_TOP_ROWS)
PARTITION_ROW_NUMBER_TOP_EXAMPLE = sql_example(PARTITION_ROW_NUMBER_TOP_SQL, ("부서번호", "이름", "급여", "순위"), PARTITION_ROW_NUMBER_TOP_ROWS)
ROWNUM_TOP_EXAMPLE = sql_example(ROWNUM_TOP_SQL, ("이름", "급여"), ROWNUM_TOP_ROWS)
FETCH_WITH_TIES_EXAMPLE = sql_example(FETCH_WITH_TIES_SQL, ("이름", "급여"), FETCH_WITH_TIES_ROWS, is_ordered=False)
INNER_FILTER_EXAMPLE = sql_example(INNER_FILTER_SQL, ("이름", "급여"), INNER_FILTER_ROWS, is_ordered=False)

CONCEPT = {
    "tagKey": "window-top-n",
    "topicCode": "sql_window",
    "sortOrder": 6,
    "title": "윈도우 함수로 TOP N",
    "summary": "인라인 뷰에서 순위를 매기고 바깥에서 걸러, 부서별 상위 N명을 뽑아요",
    "coreMd": (
        "- 윈도우 함수는 WHERE 절에 쓸 수 없어서, 인라인 뷰 안에서 순위를 매기고 바깥 WHERE로 걸러요.\n"
        "- PARTITION BY를 넣으면 부서마다 1위부터 다시 매기므로, 부서별 상위 N명을 한 번에 구해요.\n"
        "- 동점자를 모두 넣으려면 RANK나 DENSE_RANK를, 정확히 N명만 뽑으려면 ROW_NUMBER를 써요.\n"
        "- ROWNUM과 `FETCH FIRST N ROWS`는 결과 전체에서만 N개를 자르고, 부서별로 나눠 뽑지는 못해요."
    ),
    "detailMd": f"""## 부서마다 상위 몇 명 — 왜 윈도우 함수일까요 {{#why}}

| 용어 | 뜻 |
|---|---|
| TOP N | 어떤 기준으로 줄을 세웠을 때 위에서부터 N개를 뽑는 일이에요. N에는 3이나 5처럼 원하는 개수가 들어가요 |
| 묶음별 TOP N | "부서마다 급여가 가장 높은 2명"처럼 묶음마다 따로 상위 몇 개를 뽑는 일이에요 |

SELECT 기본 단원의 ROWNUM이나 `FETCH FIRST`는 결과 전체에서 앞의 N개를 자를 뿐이라서, 부서마다 따로 자를 수 없어요. 순위 함수에 PARTITION BY를 붙이면 부서마다 순위를 따로 매길 수 있으니, 그 순위로 거르면 돼요.

상위 몇 명을 뽑을 대상은 아래 사원 여덟 명이에요. 부서번호 10은 기획부, 20은 개발부, 30은 영업부이고, 윤서연은 부서번호가 NULL이라 부서가 없어요.

{EMPLOYEE_BASE_TABLE}

## 기본 틀 — 안에서 순위, 바깥에서 거르기 {{#definition}}

```sql
-- 문법
SELECT 열
FROM (SELECT 열, 순위함수() OVER (PARTITION BY 묶을 열 ORDER BY 정렬할 열) AS 순위
      FROM 테이블)
WHERE 순위 <= N;
```

| 단계 | 내용 |
|---|---|
| 순위 매기기 | 인라인 뷰(FROM 절 안에 넣은 서브쿼리) 안에서 순위 함수를 계산하고, 별칭(AS 뒤에 적는 새 열 이름)을 붙여요 |
| 순위 확정 | 인라인 뷰가 먼저 끝나서, 바깥 쿼리에서는 순위가 평범한 열처럼 보여요 |
| 거르기 | 바깥 WHERE에서 순위 <= N으로 걸러요 |

인라인 뷰를 거쳐야 하는 이유는 실행 순서에 있어요. 윈도우 함수는 WHERE가 끝난 뒤에 계산되기 때문에, 같은 SELECT 문의 WHERE에서는 쓸 수 없어요.

## 작은 예시 — 회사 전체 상위 3명 {{#small-example}}

PARTITION BY 없이 회사 전체에서 급여 상위 3명을 뽑으면 아래와 같아요.

{TOP_THREE_EXAMPLE.markdown}

## 부서별 상위 2명 — RANK와 ROW_NUMBER로 비교 {{#partition}}

인라인 뷰 안의 OVER에 `PARTITION BY 부서번호`를 넣으면 부서마다 1위부터 순위가 다시 시작돼요. 바깥에서 `순위 <= 2`로 거르면 부서별 상위 2명이 남아요.

{PARTITION_RANK_TOP_EXAMPLE.markdown}

부서별로 순위를 매긴 여덟 명 가운데 3위인 오지민만 빠져요.

| 행 | 처리 |
|---|---|
| 김민수 3000 1위 | 10번 |
| 박서준 2800 1위 | 20번 |
| 이지은 2500 2위 | 20번 |
| 정하늘 2500 2위 | 20번 |
| 최유나 3200 1위 | 30번 |
| 한도윤 2700 2위 | 30번 |
| 오지민 2200 3위 | 빠짐 |
| 윤서연 2000 1위 | NULL |

개발부는 이지은과 정하늘이 함께 2위라서 세 명이 나왔어요. RANK는 동점에 같은 순위를 주므로 "2위 이내"에 동점자가 모두 들어가고, 부서가 없는 윤서연도 NULL끼리 한 묶음이 되어 1위로 나왔어요.

같은 SQL에서 RANK만 ROW_NUMBER로 바꾸면 부서마다 정확히 2명까지만 남아요.

{PARTITION_ROW_NUMBER_TOP_EXAMPLE.markdown}

| 행 | 처리 |
|---|---|
| 김민수 3000 1위 | 10번 |
| 박서준 2800 1위 | 20번 |
| 이지은 2500 2위 | 20번 |
| 정하늘 2500 3위 | 빠짐 |
| 최유나 3200 1위 | 30번 |
| 한도윤 2700 2위 | 30번 |
| 오지민 2200 3위 | 빠짐 |
| 윤서연 2000 1위 | NULL |

ROW_NUMBER는 동점이어도 2와 3을 나눠 주기 때문에 정하늘이 빠졌어요. 사번을 두 번째 정렬 기준으로 넣어서 이지은이 2번이 됐고, 사번이 없었다면 누가 남을지는 정해지지 않아요.

## 어떤 순위 함수를 쓰느냐에 따라 — 남는 행 수가 달라요 {{#rank-choice}}

회사 전체를 급여 내림차순으로 줄 세우면, 이지은과 정하늘이 RANK와 DENSE_RANK에서 함께 5위예요. 그다음인 오지민은 RANK로 7위, DENSE_RANK로 6위예요.

| 조건 | ROW_NUMBER | RANK | DENSE_RANK |
|---|---|---|---|
| 순위 <= 5 | 5명 | 6명 (동점 둘 다) | 6명 (동점 둘 다) |
| 순위 <= 6 | 6명 | 6명 (6위가 비어 있음) | 7명 (6위 오지민까지) |

| 고르는 기준 | 쓸 함수 |
|---|---|
| 동점과 상관없이 정확히 N명 | ROW_NUMBER, 언제나 N명이에요 |
| 동점자를 함께 넣고, 순위 번호는 건너뛰기 | RANK |
| 동점자를 함께 넣고, 순위 번호는 촘촘하게 | DENSE_RANK |

## ROWNUM, FETCH FIRST와 비교 — 부서별로는 못 잘라요 {{#compare}}

| 용어 | 뜻 |
|---|---|
| ROWNUM | Oracle이 결과 행에 나오는 순서대로 1, 2, 3을 붙여 주는 번호예요. 테이블에 저장된 열은 아니지만 열처럼 써서 가상 열이라고 불러요 |
| FETCH FIRST N ROWS ONLY | 정렬한 결과에서 앞의 N개를 잘라요 |
| FETCH FIRST N ROWS WITH TIES | N번째 행과 정렬 값이 같은 행까지 함께 가져와요 |

ROWNUM은 번호가 정렬보다 먼저 붙기 때문에, 인라인 뷰에서 먼저 정렬한 뒤 바깥에서 걸러야 해요.

{ROWNUM_TOP_EXAMPLE.markdown}

아래 WITH TIES는 5번째인 이지은과 급여가 같은 정하늘까지 6행을 돌려줘요.

{FETCH_WITH_TIES_EXAMPLE.markdown}

| 방법 | 동점자 | 부서별로 N명 |
|---|---|---|
| ROWNUM (정렬 후 거름) | N개에서 잘라요 | 못 해요 |
| FETCH FIRST N ROWS ONLY | N개에서 잘라요 | 못 해요 |
| FETCH FIRST N ROWS WITH TIES | 함께 가져와요 | 못 해요 |
| ROW_NUMBER | N개에서 잘라요 | 할 수 있어요 |
| RANK, DENSE_RANK | 함께 가져와요 | 할 수 있어요 |

## 자주 헷갈리는 점 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| SELECT 절에서 붙인 순위 별칭은 같은 문장의 WHERE에서 쓸 수 있어요 | WHERE가 SELECT 절보다 먼저 처리되어 별칭이 아직 없어서, ORA-00904(알 수 없는 열 이름) 오류가 나요. 윈도우 함수를 WHERE에 직접 쓰면 ORA-30483(윈도우 함수를 쓸 수 없는 자리) 오류예요 |
| 조건을 인라인 뷰 안에 두나 바깥에 두나 결과는 같아요 | 안쪽 WHERE는 순위를 매기기 전에, 바깥 WHERE는 순위를 매긴 뒤에 걸러서 결과가 달라요 |
| RANK와 DENSE_RANK는 TOP N 결과가 늘 달라요 | 차이는 동점 다음 순위에서만 드러나요. N이 동점 순위 이하면 같고, 그보다 크면 DENSE_RANK 쪽이 더 많이 남을 수 있어요. 시험은 이 경계를 N으로 골라 물어요 |
| 하위 N명은 다른 틀이 필요해요 | OVER 안의 ORDER BY를 오름차순으로 바꾸면 급여가 낮은 사람이 1위가 되어, 같은 틀로 뽑을 수 있어요 |
| WHERE ROWNUM <= 3 ORDER BY 급여 DESC는 급여 상위 3명이에요 | ROWNUM은 정렬보다 먼저 붙어요. 읽어 온 순서대로 앞의 세 명을 고른 뒤 정렬해서, 급여 1위가 빠질 수 있어요 |

```sql
-- 오류: 윈도우 함수는 WHERE 절에 쓸 수 없어요 (ORA-30483)
SELECT 이름 FROM 사원 WHERE RANK() OVER (ORDER BY 급여 DESC) <= 3;
-- 오류: SELECT 절의 별칭은 같은 문장의 WHERE에서 쓸 수 없어요 (ORA-00904)
SELECT 이름, RANK() OVER (ORDER BY 급여 DESC) AS 순위 FROM 사원 WHERE 순위 <= 3;
```

"급여가 3000 미만인 사원 중 1위"를 구할 때 조건을 안쪽에 두면, 3000 미만인 사원끼리 순위를 매겨 박서준이 1위가 돼요.

{INNER_FILTER_EXAMPLE.markdown}

같은 조건을 바깥에 두면 전체 사원으로 순위를 먼저 매겨요. 전체 1위인 최유나(3200)가 `급여 < 3000`을 통과하지 못해서, 결과는 0행이에요.

```sql
{OUTER_FILTER_SQL}
```

ROWNUM 함정을 위 사원 표로 보면, `WHERE ROWNUM <= 3 ORDER BY 급여 DESC`는 표의 첫 세 행인 김민수, 이지은, 박서준을 먼저 고른 뒤 정렬해요. 그래서 급여 1위인 최유나가 빠져요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| FETCH FIRST 3 ROWS WITH TIES로 부서마다 상위 3명을 뽑을 수 있어요 | X | FETCH FIRST는 결과 전체에서만 잘라서, 부서별로 나누려면 PARTITION BY를 쓴 순위 함수가 필요해요 |
| ROW_NUMBER로 순위 <= 3을 거르면 동점자가 있어도 3행이에요 | O | ROW_NUMBER는 동점에도 서로 다른 번호를 줘요 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

| 나오는 문제 | 확인할 것 |
|---|---|
| 부서별 상위 N명 SQL의 결과 행 수 | 묶음마다 동점자, 순위 함수 종류, NULL 묶음 |
| 올바르게 동작하는 SQL 고르기 | 인라인 뷰로 감쌌는지, 조건이 안쪽인지 바깥인지 |
| 오류가 나는 SQL 고르기 | WHERE에 윈도우 함수나 순위 별칭을 직접 썼는지 |
| 동점자를 포함하는 방법 고르기 | RANK, DENSE_RANK, FETCH FIRST WITH TIES |""",
    "checkQuestions": [
        question(1, "윈도우 함수로 상위 N명을 거를 때 인라인 뷰를 쓰는 이유로 옳은 것은 무엇인가요?", "definition",
                 "윈도우 함수는 WHERE가 끝난 뒤에 계산되므로 같은 SELECT 문의 WHERE에서 쓸 수 없어요. 인라인 뷰에서 순위를 먼저 계산하면 바깥 WHERE에서 걸러 낼 수 있어요.",
                 [choice("A", "인라인 뷰를 쓰면 순위가 더 빨리 계산되기 때문이다", rationale="속도 때문이 아니라 실행 순서 때문에 인라인 뷰가 필요해요."),
                  choice("B", "순위 함수는 FROM 절에서만 쓸 수 있기 때문이다", rationale="순위 함수는 SELECT 절과 ORDER BY 절에 쓰고, 인라인 뷰 안에서도 SELECT 절에 써요."),
                  choice("C", "윈도우 함수는 WHERE보다 나중에 계산되어 같은 문장의 WHERE에서 쓸 수 없기 때문이다", True,
                         "인라인 뷰로 감싸면 바깥 WHERE에서 순위를 열처럼 쓸 수 있어요."),
                  choice("D", "PARTITION BY는 인라인 뷰 안에서만 쓸 수 있기 때문이다", rationale="PARTITION BY는 인라인 뷰가 없어도 OVER 안에 쓸 수 있어요.")]),
        question(2, "20번 부서 사원은 박서준(급여 2800), 이지은(2500), 정하늘(2500) 세 명이에요. 다음 SQL은 몇 행을 돌려주나요?", "partition",
                 "RANK로 매기면 박서준 1위, 이지은과 정하늘이 함께 2위예요. 2위 이내에 동점자가 모두 들어가서 3행이 나와요.",
                 [choice("A", "2행", rationale="정확히 2명으로 자르는 것은 ROW_NUMBER이고, RANK는 동점자를 함께 넣어요."),
                  choice("B", "3행", True, "동점인 2위 두 명이 모두 들어가요."),
                  choice("C", "1행", rationale="순위 <= 2라서 1위만 남지 않아요."),
                  choice("D", "0행", rationale="인라인 뷰로 감쌌기 때문에 오류 없이 걸러져요.")],
                 stem_sql=DEPARTMENT_RANK_STEM_SQL),
        question(3, "부서마다 급여 상위 2명을 뽑되, 동점자가 있어도 부서마다 정확히 2명씩만 남기려고 해요. 인라인 뷰 안에서 쓸 함수로 알맞은 것은 무엇인가요?", "rank-choice",
                 "ROW_NUMBER는 동점이어도 서로 다른 번호를 주므로 언제나 N명만 남아요. RANK와 DENSE_RANK는 동점자를 함께 넣어서 N명을 넘을 수 있어요.",
                 [choice("A", "RANK", rationale="RANK는 동점에 같은 순위를 줘서 2명을 넘을 수 있어요."),
                  choice("B", "DENSE_RANK", rationale="DENSE_RANK도 동점에 같은 순위를 줘서 2명을 넘을 수 있어요."),
                  choice("C", "RANK와 DENSE_RANK 중 어느 것이든 된다", rationale="두 함수 모두 동점에 같은 순위를 줘서 2명을 넘을 수 있어요."),
                  choice("D", "ROW_NUMBER", True, "동점이어도 다른 번호를 줘서 부서마다 정확히 2명이 남아요.")]),
        question(4, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_SALARY_TABLE, "rank-choice",
                 "DENSE_RANK는 2500인 두 명에게 함께 5위를 주고, 오지민에게 6위를 줘요. 그래서 6위 이내는 1위부터 오지민까지 7명이에요.",
                 [choice("A", "7행", True, "동점 두 명이 5위, 오지민이 6위라서 7명이 들어가요."),
                  choice("B", "6행", rationale="6위를 비워 두는 RANK의 결과이고, DENSE_RANK는 오지민에게 6위를 줘요."),
                  choice("C", "5행", rationale="동점자 두 명이 같은 순위를 받아서 6위 이내에는 더 많은 사람이 들어가요."),
                  choice("D", "8행", rationale="가장 급여가 낮은 윤서연은 DENSE_RANK로 7위라서 빠져요.")],
                 stem_sql=DENSE_RANK_STEM_SQL),
        question(5, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_SALARY_TABLE, "compare",
                 "WITH TIES는 5번째 행과 정렬 값이 같은 행까지 함께 가져와요. 5번째인 이지은과 급여가 같은 정하늘이 더해져 6행이에요.",
                 [choice("A", "5행", rationale="ONLY였다면 5행이지만, WITH TIES는 동점 행을 함께 가져와요."),
                  choice("B", "4행", rationale="앞에서 5개를 가져오므로 4행보다 많아요."),
                  choice("C", "6행", True, "5번째 행과 급여가 같은 정하늘까지 들어가요."),
                  choice("D", "8행", rationale="동점이 아닌 오지민과 윤서연은 들어가지 않아요.")],
                 stem_sql=FETCH_STEM_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 결과 표
        TOP_THREE_EXAMPLE.check,
        PARTITION_RANK_TOP_EXAMPLE.check,
        PARTITION_ROW_NUMBER_TOP_EXAMPLE.check,
        # 부서별 순위 그림: 여덟 명 전체 순위 (RANK <-> ROW_NUMBER)
        sql_check("SELECT 이름, RANK() OVER (PARTITION BY 부서번호 ORDER BY 급여 DESC) FROM 사원",
                  [["김민수", 1], ["박서준", 1], ["이지은", 2], ["정하늘", 2], ["최유나", 1], ["한도윤", 2], ["오지민", 3], ["윤서연", 1]]),
        sql_check("SELECT 이름, ROW_NUMBER() OVER (PARTITION BY 부서번호 ORDER BY 급여 DESC, 사번) FROM 사원",
                  [["김민수", 1], ["박서준", 1], ["이지은", 2], ["정하늘", 3], ["최유나", 1], ["한도윤", 2], ["오지민", 3], ["윤서연", 1]]),
        ROWNUM_TOP_EXAMPLE.check,
        FETCH_WITH_TIES_EXAMPLE.check,
        INNER_FILTER_EXAMPLE.check,
        sql_check(OUTER_FILTER_SQL, []),
        # 순위 함수별 행 수 표 (동점 2500 이 5위)
        *[sql_check(RANK_COUNT_SQL_TEMPLATE.format(function=function, limit=limit), [[count]])
          for function, limit, count in RANK_COUNT_ROWS],
        # 본문 설명: 오류 2개, FETCH ONLY 는 5행, 하위 N(오름차순), ROWNUM 정렬 함정
        sql_error_check("SELECT 이름 FROM 사원 WHERE RANK() OVER (ORDER BY 급여 DESC) <= 3", "ORA-30483"),
        sql_error_check("SELECT 이름, RANK() OVER (ORDER BY 급여 DESC) AS 순위 FROM 사원 WHERE 순위 <= 3", "ORA-00904"),
        sql_check("SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC, 사번 FETCH FIRST 5 ROWS ONLY", ROWNUM_TOP_ROWS, is_ordered=True),
        sql_check("SELECT 이름 FROM (SELECT 이름, RANK() OVER (ORDER BY 급여) AS 순위 FROM 사원) WHERE 순위 <= 2",
                  [["윤서연"], ["오지민"]]),
        sql_check("SELECT 이름, 급여 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC",
                  [["김민수", 3000], ["박서준", 2800], ["이지은", 2500]], is_ordered=True),
        # 확인 문제 2·4·5번 stemSql
        sql_check(DEPARTMENT_RANK_STEM_SQL, [["박서준"], ["이지은"], ["정하늘"]]),
        sql_check(DENSE_RANK_STEM_SQL, [["최유나"], ["김민수"], ["박서준"], ["한도윤"], ["이지은"], ["정하늘"], ["오지민"]]),
        sql_check(FETCH_STEM_SQL, FETCH_WITH_TIES_ROWS),
    ],
}
