"""개념: PIVOT과 UNPIVOT (9단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_example
from concept_dataset import to_employee_table_md, to_insert_statements, to_markdown_table

EMPLOYEE_PIVOT_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")
# 원본 테이블을 그대로 PIVOT 할 때 결과 계산에 쓰는 열 (사번이 사원마다 달라 8행, 칸 값은 이름, 급여, 부서번호)
EMPLOYEE_WHOLE_TABLE_KEY_TABLE = to_employee_table_md("사번", "이름", "급여", "부서번호")
EMPLOYEE_ALL_COLUMN_NAMES = "사번, 이름, 직급, 관리자사번, 입사일, 급여, 커미션, 부서번호"

# UNPIVOT 예시 전용 표: 지점별 1~3월 매출 (부산 2월은 NULL > INCLUDE NULLS 예시)
MONTHLY_SALES_COLUMNS = ("지점", "일월", "이월", "삼월")
MONTHLY_SALES_ROWS = (("서울", 100, 150, 120), ("부산", 80, None, 90))
MONTHLY_SALES_TABLE = to_markdown_table(MONTHLY_SALES_COLUMNS, MONTHLY_SALES_ROWS)


# 본문 블록과 검증 setup 이 같은 생성 SQL 을 씀
CREATE_MONTHLY_SALES_SQL = "\n".join(
    ["CREATE TABLE 월별매출 (지점 VARCHAR2(10), 일월 NUMBER(5), 이월 NUMBER(5), 삼월 NUMBER(5));"]
    + to_insert_statements("월별매출", MONTHLY_SALES_ROWS)
)

# 본문 SQL, 결과 표와 검증 항목의 원본
GROUP_BY_SQL = """SELECT 부서번호, SUM(급여) AS 급여합계
FROM 사원
GROUP BY 부서번호
ORDER BY 부서번호;"""
GROUP_BY_ROWS = [[10, 3000], [20, 7800], [30, 8100], [None, 2000]]

PIVOT_ONE_ROW_SQL = """SELECT *
FROM (SELECT 부서번호, 급여 FROM 사원)
PIVOT (SUM(급여) FOR 부서번호 IN (10 AS 기획부, 20 AS 개발부, 30 AS 영업부));"""
PIVOT_ONE_ROW_ROWS = [[3000, 7800, 8100]]

PIVOT_BY_POSITION_SQL = """SELECT *
FROM (SELECT 직급, 부서번호, 급여 FROM 사원)
PIVOT (SUM(급여) FOR 부서번호 IN (10 AS 기획부, 20 AS 개발부, 30 AS 영업부))
ORDER BY 직급;"""
PIVOT_BY_POSITION_ROWS = [
    ["과장", None, 2500, None], ["대리", None, 2800, 2700], ["부장", None, None, 3200],
    ["사원", None, 2500, 2200], ["사장", 3000, None, None],
]

CASE_SQL = """SELECT 직급,
       SUM(CASE WHEN 부서번호 = 10 THEN 급여 END) AS 기획부,
       SUM(CASE WHEN 부서번호 = 20 THEN 급여 END) AS 개발부,
       SUM(CASE WHEN 부서번호 = 30 THEN 급여 END) AS 영업부
FROM 사원
GROUP BY 직급
ORDER BY 직급;"""

PIVOT_WHOLE_TABLE_SQL = """SELECT 이름, 기획부, 개발부, 영업부
FROM 사원
PIVOT (SUM(급여) FOR 부서번호 IN (10 AS 기획부, 20 AS 개발부, 30 AS 영업부))
ORDER BY 사번;"""
PIVOT_WHOLE_TABLE_ROWS = [
    ["김민수", 3000, None, None], ["이지은", None, 2500, None], ["박서준", None, 2800, None],
    ["최유나", None, None, 3200], ["정하늘", None, 2500, None], ["한도윤", None, None, 2700],
    ["오지민", None, None, 2200], ["윤서연", None, None, None],
]

COUNT_WITH_SALARY_SQL = """SELECT *
FROM (SELECT 부서번호, 급여 FROM 사원)
PIVOT (COUNT(*) FOR 부서번호 IN (10 AS 기획부, 20 AS 개발부, 30 AS 영업부));"""
# 급여 2000(윤서연, 부서 NULL)도 급여 묶음 하나로 남아 세 칸 모두 0 (행 순서는 정해지지 않음)
COUNT_WITH_SALARY_ROWS = [
    [3000, 1, 0, 0], [2500, 0, 2, 0], [2800, 0, 1, 0], [3200, 0, 0, 1],
    [2700, 0, 0, 1], [2200, 0, 0, 1], [2000, 0, 0, 0],
]
COUNT_ONLY_DEPARTMENT_SQL = """SELECT *
FROM (SELECT 부서번호 FROM 사원)
PIVOT (COUNT(*) FOR 부서번호 IN (10 AS 기획부, 20 AS 개발부, 30 AS 영업부, 40 AS 인사부));"""
COUNT_ONLY_DEPARTMENT_ROWS = [[1, 3, 3, 0]]

NO_ALIAS_SQL = """SELECT *
FROM (SELECT 직급, 부서번호, 급여 FROM 사원)
PIVOT (SUM(급여) FOR 부서번호 IN (10, 20))
ORDER BY 직급;"""

NO_AGGREGATE_SQL = """SELECT *
FROM (SELECT 부서번호, 급여 FROM 사원)
PIVOT (급여 FOR 부서번호 IN (10, 20));"""
SUBQUERY_IN_LIST_SQL = """SELECT *
FROM (SELECT 부서번호, 급여 FROM 사원)
PIVOT (SUM(급여) FOR 부서번호 IN (SELECT 부서번호 FROM 부서));"""

UNPIVOT_SQL = """SELECT *
FROM 월별매출
UNPIVOT (매출 FOR 월 IN (일월, 이월, 삼월));"""
UNPIVOT_ROWS = [["서울", "일월", 100], ["서울", "이월", 150], ["서울", "삼월", 120],
                ["부산", "일월", 80], ["부산", "삼월", 90]]

UNPIVOT_INCLUDE_NULLS_SQL = """SELECT *
FROM 월별매출
UNPIVOT INCLUDE NULLS (매출 FOR 월 IN (일월, 이월, 삼월));"""
UNPIVOT_INCLUDE_NULLS_ROWS = [["서울", "일월", 100], ["서울", "이월", 150], ["서울", "삼월", 120],
                              ["부산", "일월", 80], ["부산", "이월", None], ["부산", "삼월", 90]]

UNPIVOT_NUMBER_ALIAS_SQL = """SELECT *
FROM 월별매출
UNPIVOT (매출 FOR 월 IN (일월 AS 1, 이월 AS 2, 삼월 AS 3))
ORDER BY 지점, 월;"""
UNPIVOT_NUMBER_ALIAS_ROWS = [["부산", 1, 80], ["부산", 3, 90],
                             ["서울", 1, 100], ["서울", 2, 150], ["서울", 3, 120]]

PIVOT_THEN_UNPIVOT_SQL = """SELECT *
FROM (SELECT *
      FROM (SELECT 부서번호, 급여 FROM 사원)
      PIVOT (SUM(급여) FOR 부서번호 IN (10 AS 기획부, 20 AS 개발부, 30 AS 영업부)))
UNPIVOT (급여합계 FOR 부서 IN (기획부, 개발부, 영업부));"""
# PIVOT 후 UNPIVOT 결과: 부서 합계 3행 (본문 결과 표 = 검증 기대값)
PIVOT_THEN_UNPIVOT_ROWS = [["기획부", 3000], ["개발부", 7800], ["영업부", 8100]]

WHOLE_TABLE_STEM_SQL = "SELECT * FROM 사원 PIVOT (SUM(급여) FOR 부서번호 IN (10 AS 기획부, 20 AS 개발부, 30 AS 영업부));"
OUTSIDE_LIST_STEM_SQL = "SELECT * FROM (SELECT 부서번호, 급여 FROM 사원) PIVOT (SUM(급여) FOR 부서번호 IN (20 AS 개발부, 40 AS 인사부));"

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
GROUP_BY_EXAMPLE = sql_example(GROUP_BY_SQL, ("부서번호", "급여합계"), GROUP_BY_ROWS)
PIVOT_ONE_ROW_EXAMPLE = sql_example(PIVOT_ONE_ROW_SQL, ("기획부", "개발부", "영업부"), PIVOT_ONE_ROW_ROWS, is_ordered=False)
PIVOT_BY_POSITION_EXAMPLE = sql_example(PIVOT_BY_POSITION_SQL, ("직급", "기획부", "개발부", "영업부"), PIVOT_BY_POSITION_ROWS)
PIVOT_WHOLE_TABLE_EXAMPLE = sql_example(PIVOT_WHOLE_TABLE_SQL, ("이름", "기획부", "개발부", "영업부"), PIVOT_WHOLE_TABLE_ROWS)
COUNT_WITH_SALARY_EXAMPLE = sql_example(COUNT_WITH_SALARY_SQL, ("급여", "기획부", "개발부", "영업부"), COUNT_WITH_SALARY_ROWS, is_ordered=False)
COUNT_ONLY_DEPARTMENT_EXAMPLE = sql_example(COUNT_ONLY_DEPARTMENT_SQL, ("기획부", "개발부", "영업부", "인사부"), COUNT_ONLY_DEPARTMENT_ROWS, is_ordered=False)
NO_ALIAS_EXAMPLE = sql_example(NO_ALIAS_SQL, ("직급", "10", "20"), [[row[0], row[1], row[2]] for row in PIVOT_BY_POSITION_ROWS])
PIVOT_THEN_UNPIVOT_EXAMPLE = sql_example(PIVOT_THEN_UNPIVOT_SQL, ("부서", "급여합계"), PIVOT_THEN_UNPIVOT_ROWS, is_ordered=False)

CONCEPT = {
    "tagKey": "pivot-unpivot",
    "topicCode": "sql_hierarchy_pivot",
    "sortOrder": 4,
    "title": "PIVOT과 UNPIVOT",
    "summary": "PIVOT은 행의 값을 열로 세우고, UNPIVOT은 열을 다시 행으로 눕혀요",
    "coreMd": (
        "- `PIVOT (집계 함수 FOR 열 IN (값 AS 별칭, ...))`은 FOR 열의 값마다 새 열을 만들고, 그 칸을 집계 함수로 채워요.\n"
        "- PIVOT은 집계와 FOR에 쓰지 않은 **나머지 열 전부**로 저절로 GROUP BY를 하므로, 필요한 열만 인라인 뷰로 골라 넣어요.\n"
        "- **IN 목록에 적은 값만** 열이 되고, 목록에 없는 값을 가진 행은 어느 칸에도 들어가지 않아요.\n"
        "- PIVOT 안에는 집계 함수가 꼭 있어야 하고, IN 목록에는 상수만 쓸 수 있어요.\n"
        "- UNPIVOT은 여러 열을 행으로 풀고, 기본으로는 **NULL 칸의 행**을 만들지 않아요(`INCLUDE NULLS`를 쓰면 만들어요)."
    ),
    "detailMd": f"""## 세로를 가로로: 왜 표를 돌릴까요 {{#why}}

부서별 급여 합계를 GROUP BY로 구하면 부서마다 한 행씩 세로로 쌓여요.

| 용어 | 뜻 |
|---|---|
| GROUP BY | 같은 값을 가진 행끼리 묶는 절이에요. 그룹 함수 단원에서 자세히 다뤄요 |
| SUM | 묶인 행들의 값을 더하는 집계 함수예요 |

{GROUP_BY_EXAMPLE.markdown}

보고서에서는 부서를 가로로 늘어놓고 한 줄에 합계를 보여 주는 표가 더 읽기 쉬울 때가 많아요.

| 문법 | 하는 일 | 방향 |
|---|---|---|
| PIVOT | 행으로 쌓인 값을 열 머리글로 세워요 | 행 > 열 |
| UNPIVOT | 여러 열에 나뉜 값을 행으로 눕혀요 | 열 > 행 |

PIVOT 예시는 공통 사원 표의 직급, 급여, 부서번호를 써요.

{EMPLOYEE_PIVOT_TABLE}

## 한 줄 정의와 문법: 집계 FOR 열 IN 값 {{#definition}}

PIVOT은 FOR 뒤에 적은 열의 값 하나하나를 새 열로 만들고, 그 칸에 집계 함수로 계산한 값을 채워 넣는 연산이에요.

```sql
-- 문법
SELECT *
FROM (SELECT 남길 열, FOR에 쓸 열, 집계할 열 FROM 테이블)     -- 필요한 열만 고른 인라인 뷰예요
PIVOT (
    집계 함수(집계할 열)                                   -- 칸에 들어갈 값을 계산해요
    FOR FOR에 쓸 열 IN (값1 AS 별칭1, 값2 AS 별칭2)          -- 이 값들이 새 열이 돼요
);
```

| 용어 | 뜻 |
|---|---|
| 집계 함수 자리 | 칸에 들어갈 값을 계산해요. 예: `SUM(급여)` |
| FOR 열 | 값이 새 열 머리글로 바뀌는 열이에요. 예: 부서번호 |
| IN 목록 | 열로 세울 값과 그 열의 이름(별칭)이에요. 예: `10 AS 기획부` |
| 남은 열 | 집계와 FOR에 쓰이지 않은 열이에요. PIVOT이 이 열로 저절로 GROUP BY를 해서 행을 묶어요 |
| 인라인 뷰 | FROM 절 안에 괄호로 넣은 SELECT예요. 남은 열을 내가 고르려고 써요 |

## 예시: 한 행으로, 직급별로, CASE로 {{#example}}

부서번호와 급여 두 열만 고르면 부서번호는 FOR에, 급여는 SUM에 쓰여서 남은 열이 하나도 없어요. 그래서 전체가 한 그룹이 되어 결과가 한 행으로 나와요.

{PIVOT_ONE_ROW_EXAMPLE.markdown}

부서가 없는 윤서연의 급여 2000은 IN 목록에 맞는 값이 없어서 어느 칸에도 들어가지 않았어요.

인라인 뷰에 직급을 더하면 직급이 남은 열이 되어, PIVOT이 `GROUP BY 직급`을 저절로 해 준 결과가 나와요.

{PIVOT_BY_POSITION_EXAMPLE.markdown}

해당하는 행이 없는 칸은 SUM의 결과가 NULL이에요. 개발부의 사원 칸 2500은 정하늘 한 명의 급여이고, 대리 칸의 2800과 2700은 각각 박서준과 한도윤의 급여예요.

같은 표를 PIVOT 없이 CASE와 SUM으로도 만들 수 있어요. `CASE WHEN 조건 THEN 값 END`는 조건이 맞으면 값을, 맞지 않으면 NULL을 돌려주는 식이에요(SQL 함수 단원에서 자세히 다뤄요).

```sql
{CASE_SQL}
```

| 비교 | PIVOT | CASE와 SUM |
|---|---|---|
| GROUP BY | 남은 열로 저절로 해요 | 직접 적어야 해요 |
| 빈 칸 | SUM이라 NULL | CASE가 NULL을 주고 SUM이 NULL을 빼고 더해서 NULL |
| 쓸 수 있는 곳 | PIVOT 문법이 있는 DBMS | PIVOT이 없는 DBMS에서도 써요 |

결과는 앞의 PIVOT 예시와 행 하나 다르지 않아요. 시험에서는 "PIVOT과 결과가 같은 SQL"을 고르는 보기로 자주 나와요.

## 자주 헷갈리는 점: 몇 행이 나오나 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| 원본 테이블을 그대로 넣어도 부서별 한 줄이 나와요 | 집계와 FOR에 쓰지 않은 열 전부가 묶는 기준이 되어, 사번이 다른 8명이 8행으로 나와요 |
| SUM을 COUNT(*)로 바꿔도 행 수는 그대로예요 | 급여가 집계에 쓰이지 않게 되어 급여가 묶는 기준으로 남고, 행 수가 바뀌어요 |
| IN 목록의 값 개수만큼 행이 생겨요 | IN 목록의 값 개수는 열 수를 정하고, 행 수는 남은 열이 정해요 |

실제 사원 표에는 {EMPLOYEE_ALL_COLUMN_NAMES} 여덟 열이 있어요. 인라인 뷰 없이 바로 넣으면 급여와 부서번호를 뺀 **여섯 열**이 모두 묶는 기준이 되는데, 아래처럼 사번이 사원마다 달라서 한 사람이 한 묶음이 돼요.

{EMPLOYEE_WHOLE_TABLE_KEY_TABLE}

{PIVOT_WHOLE_TABLE_EXAMPLE.markdown}

칸마다 그 사원 한 명의 급여만 들어가서, 부서별 합계 한 줄을 기대했다면 틀린 결과예요. 인라인 뷰에 남긴 열만 묶는 기준이 되므로, 필요한 열만 고르면 몇 행이 나올지를 내가 정할 수 있어요.

부서별 인원을 세려고 `SUM(급여)`만 `COUNT(*)`로 바꾸면 급여가 묶는 기준이 돼요. `COUNT(*)`는 묶인 행의 수를 세는 집계 함수이고, 급여 값은 2500이 두 명이라 3000, 2500, 2800, 3200, 2700, 2200, 2000의 7가지예요.

{COUNT_WITH_SALARY_EXAMPLE.markdown}

마지막 행은 부서번호가 NULL인 윤서연이에요. IN 목록의 어느 칸에도 세어지지 않지만 급여 2000이라는 묶음은 혼자서도 생기므로 세 칸이 모두 0인 행으로 남고, 행의 순서는 정해져 있지 않아요.

인라인 뷰에 부서번호만 남기면 묶는 기준이 없어져서 한 행으로 인원이 나와요.

{COUNT_ONLY_DEPARTMENT_EXAMPLE.markdown}

사원이 없는 40 인사부는 COUNT라서 0이에요. 같은 자리에 SUM을 썼다면 NULL이 나와요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 인라인 뷰에 부서번호와 급여만 넣고 `SUM(급여)`로 PIVOT하면 한 행이 나와요 | O | 두 열이 모두 PIVOT 안에서 쓰여서 묶는 기준이 남지 않아요 |
| PIVOT 결과에서 사원이 없는 부서의 COUNT 칸은 NULL이에요 | X | COUNT는 셀 행이 없으면 0이고, NULL이 되는 것은 SUM이에요 |

## IN 목록, 별칭, 집계 함수: 문법 규칙 {{#in-list}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| PIVOT은 테이블에 있는 값을 스스로 찾아 열로 만들어요 | IN 목록에 적힌 값만 열이 돼요. 목록에 없는 값은 어느 칸에도 더해지거나 세어지지 않아요 |
| 목록에 있는데 데이터가 없는 값은 열이 생기지 않아요 | 열은 생기고 칸이 NULL(COUNT라면 0)이에요 |
| IN 목록을 서브쿼리로 채울 수 있어요 | 10, 20 같은 상수만 쓸 수 있어요. 서브쿼리(SQL 안에 괄호로 넣은 또 다른 SELECT)를 쓰면 ORA-00936(있어야 할 식이 없음) 오류가 나요 |
| 집계 함수 없이 열 이름만 적어도 돼요 | 한 칸에 여러 행이 모일 수 있어서 집계 함수가 꼭 있어야 해요. 없으면 ORA-56902(집계 함수가 필요함) 오류가 나요 |
| 별칭을 빼면 열 이름이 자동으로 붙어요 | 값 자체가 열 이름이 돼요. `IN (10, 20)`이면 열 이름이 10, 20이고, 문자 값이면 따옴표까지 포함한 '대리'가 열 이름이에요 |

```sql
-- 오류: IN 목록에는 서브쿼리를 쓸 수 없어요 (ORA-00936, 있어야 할 식이 없음)
{SUBQUERY_IN_LIST_SQL}
```

```sql
-- 오류: PIVOT 안에 집계 함수가 없어요 (ORA-56902, 집계 함수가 필요함)
{NO_AGGREGATE_SQL}
```

별칭 없이 만든 열을 SELECT 절에서 따로 부르려면 `"10"`처럼 큰따옴표로 감싸야 해서 불편하므로 보통 별칭을 붙여요.

{NO_ALIAS_EXAMPLE.markdown}

## UNPIVOT: 열을 행으로 눕혀요 {{#unpivot}}

UNPIVOT은 같은 종류의 값이 여러 열에 나뉘어 있을 때 그 열들을 행으로 풀어 줘요. 아래 월별매출 표에서 부산의 2월 매출은 아직 없어서 NULL이에요.

{MONTHLY_SALES_TABLE}

```sql
-- 문법
SELECT *
FROM 테이블
UNPIVOT [INCLUDE NULLS] (
    값을 담을 새 열 FOR 열 이름을 담을 새 열 IN (열1, 열2, 열3)
);
```

| 비교 | PIVOT | UNPIVOT |
|---|---|---|
| 괄호 안 모양 | 집계 함수 FOR 열 IN (값 AS 별칭) | 값 열 FOR 이름 열 IN (열 목록) |
| 집계 함수 | 꼭 있어야 해요 | 쓰지 않아요 |
| IN 목록 | 열로 세울 값 | 행으로 풀 열 |

```sql
{CREATE_MONTHLY_SALES_SQL}
{UNPIVOT_SQL}
{UNPIVOT_INCLUDE_NULLS_SQL}
```

첫 번째 SQL은 IN 목록의 열 하나를 행 하나로 만들고, 원래 열 이름(일월, 이월, 삼월)은 새 열 `월`에, 칸의 값은 새 열 `매출`에 넣어요. 부산의 이월 칸은 NULL이라서 행이 만들어지지 않아 6행이 아니라 5행이에요.

{to_markdown_table(("지점", "월", "매출"), UNPIVOT_ROWS)}

두 번째 SQL처럼 `INCLUDE NULLS`를 쓰면 NULL 칸까지 행으로 만들어요. 아무것도 적지 않으면 NULL을 빼는 `EXCLUDE NULLS`로 동작하고, 행 순서가 필요하면 ORDER BY를 붙여요.

{to_markdown_table(("지점", "월", "매출"), UNPIVOT_INCLUDE_NULLS_ROWS)}

## UNPIVOT에서 헷갈리는 점: 별칭과 되돌리기 {{#unpivot-confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| UNPIVOT은 NULL 칸도 기본으로 행을 만들어요 | 기본은 EXCLUDE NULLS라서 NULL 칸의 행을 만들지 않아요 |
| 이름 열에는 원래 열 이름만 들어갈 수 있어요 | `일월 AS 1`처럼 AS로 다른 값을 넣을 수 있어요. 숫자로 바꾸면 월 순서로 정렬하기도 쉬워요 |
| PIVOT한 결과를 UNPIVOT하면 원래 행으로 돌아가요 | SUM으로 합쳐진 값은 다시 나뉘지 않아요. 사원 7명의 행이 아니라 부서 합계 3행이 나와요 |

```sql
{CREATE_MONTHLY_SALES_SQL}
{UNPIVOT_NUMBER_ALIAS_SQL}
```

{to_markdown_table(("지점", "월", "매출"), UNPIVOT_NUMBER_ALIAS_ROWS)}

앞에서 만든 부서별 급여 합계 한 행을 UNPIVOT하면 아래처럼 부서마다 합계 한 행씩만 나와요.

{PIVOT_THEN_UNPIVOT_EXAMPLE.markdown}

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| UNPIVOT에 `INCLUDE NULLS`를 쓰면 월별매출 결과는 6행이에요 | O | 부산의 이월 NULL 칸도 행으로 만들어서 지점마다 3행씩이에요 |

## 꼭 외울 것: 행 수와 열 수를 정하는 것 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| PIVOT 괄호 안 모양 | 집계 함수 FOR 열 IN (값 AS 별칭, ...) |
| PIVOT 행 수를 정하는 것 | 집계와 FOR에 쓰지 않은 남은 열 (없으면 1행) |
| PIVOT 열 수를 정하는 것 | IN 목록의 값 개수 |
| IN 목록에 없는 값 | 어느 칸에도 들어가지 않아요 |
| 행이 없는 칸 | SUM이면 NULL, COUNT면 0 |
| 집계 함수와 IN 목록 | 집계 함수는 필수, IN 목록은 상수만 |
| UNPIVOT과 NULL 칸 | 기본 EXCLUDE NULLS라 행이 안 생겨요 (INCLUDE NULLS면 생김) |
| PIVOT 없이 같은 결과 | CASE와 SUM, GROUP BY로 만들어요 |

## 시험에서는 이렇게 나와요: 행 수와 칸 값 {{#exam-point}}

PIVOT SQL을 주고 결과 표의 행 수나 특정 칸의 값을 묻는 문제가 가장 많아요.

| 단계 | 내용 |
|---|---|
| 남은 열 찾기 | 인라인 뷰의 열 가운데 집계와 FOR에 쓰이지 않은 열을 찾아요 |
| 행 수 세기 | 남은 열의 값 조합마다 한 행이에요. 남은 열이 없으면 한 행이에요 |
| 열 세기 | IN 목록의 값 하나가 열 하나예요. 목록에 없는 값은 버려져요 |
| 칸 채우기 | 행이 없는 칸은 SUM이면 NULL, COUNT면 0이에요 |

그 밖에 같은 결과를 CASE와 SUM으로 쓰는 방법, UNPIVOT이 기본으로 NULL을 빼는 점도 자주 나와요.""",
    "checkQuestions": [
        question(1, "PIVOT 절 `SUM(급여) FOR 부서번호 IN (10 AS 기획부, 20 AS 개발부)`에서 부서번호 열의 역할은 무엇인가요?", "definition",
                 "FOR 뒤에 적은 열의 값(10, 20)이 새 열(기획부, 개발부)이 돼요. 칸의 값은 SUM(급여)로 계산하고, 행을 묶는 기준은 PIVOT에 쓰이지 않은 나머지 열이에요.",
                 [choice("A", "칸에 들어갈 값을 계산하는 열", rationale="칸의 값은 집계 함수 안의 급여로 계산해요."),
                  choice("B", "값이 새 열로 바뀌는 열", True, "부서번호 값 10, 20이 기획부, 개발부 열이 돼요."),
                  choice("C", "결과를 정렬하는 기준 열", rationale="PIVOT은 정렬을 하지 않고, 순서는 ORDER BY로 정해요."),
                  choice("D", "행을 묶는 기준 열", rationale="행을 묶는 기준은 PIVOT에 쓰이지 않은 나머지 열이에요.")]),
        question(2, "사원 표에는 " + EMPLOYEE_ALL_COLUMN_NAMES + " 여덟 열이 있고, 아래는 그중 네 열이에요. "
                    "이 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_WHOLE_TABLE_KEY_TABLE, "confusing",
                 "사원 표를 그대로 넣었으므로 급여와 부서번호를 뺀 나머지 열 전부로 묶여요. 사번이 사원마다 달라서 8명이 각자 한 그룹이 돼요.",
                 [choice("A", "1행", rationale="부서번호와 급여만 있는 인라인 뷰를 넣었을 때의 행 수예요."),
                  choice("B", "3행", rationale="IN 목록의 값 개수는 열 수이지 행 수가 아니에요."),
                  choice("C", "8행", True, "사번을 포함한 나머지 열로 묶이므로 사원마다 한 행이에요."),
                  choice("D", "7행", rationale="부서가 없는 윤서연도 사번이 있어서 한 행으로 나오고, 칸만 모두 NULL이에요.")],
                 stem_sql=WHOLE_TABLE_STEM_SQL),
        question(3, "공통 예시의 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_PIVOT_TABLE, "confusing",
                 "COUNT(*)는 급여 열을 쓰지 않으므로 급여가 묶는 기준으로 남아요. 급여 값은 3000, 2500, 2800, 3200, 2700, 2200, 2000으로 7가지라서 7행이에요.",
                 [choice("A", "7행", True, "급여 값 7가지마다 한 행이 생겨요."),
                  choice("B", "1행", rationale="인라인 뷰에 부서번호만 있을 때의 행 수예요."),
                  choice("C", "8행", rationale="급여가 2500인 이지은과 정하늘은 한 그룹으로 묶여요."),
                  choice("D", "3행", rationale="IN 목록의 값 개수는 열 수를 정해요.")],
                 stem_sql=COUNT_WITH_SALARY_SQL),
        question(4, "공통 예시의 사원 표에 다음 SQL을 실행하면 개발부 열과 인사부 열의 값은 각각 무엇인가요?\n\n" + EMPLOYEE_PIVOT_TABLE, "confusing",
                 "개발부는 부서 20의 급여 2500, 2800, 2500을 더한 7800이에요. 40 인사부에는 사원이 없어서 SUM 결과가 NULL이고, 목록에 없는 부서의 급여는 어디에도 들어가지 않아요.",
                 [choice("A", "7800, 0", rationale="빈 칸이 0이 되는 것은 COUNT일 때이고, SUM은 NULL이에요."),
                  choice("B", "7800, 13100", rationale="IN 목록에 없는 10, 30, NULL 부서의 급여가 인사부로 모이지는 않아요."),
                  choice("C", "2500, NULL", rationale="SUM이므로 부서 20의 급여 세 명분을 모두 더해요."),
                  choice("D", "7800, NULL", True, "개발부는 세 명의 합계이고, 사원이 없는 인사부는 NULL이에요.")],
                 stem_sql=OUTSIDE_LIST_STEM_SQL),
        question(5, "아래 월별매출 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + MONTHLY_SALES_TABLE, "unpivot",
                 "열 세 개를 행으로 풀어 지점마다 3행씩 6행이 될 것 같지만, UNPIVOT은 기본으로 NULL인 칸의 행을 만들지 않아요. 부산의 이월이 빠져서 5행이에요.",
                 [choice("A", "6행", rationale="INCLUDE NULLS를 썼을 때의 행 수예요."),
                  choice("B", "5행", True, "NULL인 부산 이월 칸만 빠져요."),
                  choice("C", "2행", rationale="UNPIVOT은 열을 행으로 늘려서 원래 지점 수보다 행이 많아져요."),
                  choice("D", "3행", rationale="열 이름 개수만 센 답이에요. 지점마다 행이 따로 생겨요.")],
                 stem_sql="SELECT * FROM 월별매출 UNPIVOT (매출 FOR 월 IN (일월, 이월, 삼월));"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        GROUP_BY_EXAMPLE.check,
        PIVOT_ONE_ROW_EXAMPLE.check,
        PIVOT_BY_POSITION_EXAMPLE.check,
        sql_check(CASE_SQL, PIVOT_BY_POSITION_ROWS, is_ordered=True),
        PIVOT_WHOLE_TABLE_EXAMPLE.check,
        sql_check("SELECT COUNT(*) FROM (" + COUNT_WITH_SALARY_SQL.rstrip(";") + ")", [[7]]),
        COUNT_ONLY_DEPARTMENT_EXAMPLE.check,
        NO_ALIAS_EXAMPLE.check,
        # 별칭 없는 열은 큰따옴표로 불러야 함
        sql_check('SELECT 직급, "10", "20" FROM (SELECT 직급, 부서번호, 급여 FROM 사원) '
                  'PIVOT (SUM(급여) FOR 부서번호 IN (10, 20)) ORDER BY 직급',
                  [[row[0], row[1], row[2]] for row in PIVOT_BY_POSITION_ROWS], is_ordered=True),
        sql_check(UNPIVOT_SQL, UNPIVOT_ROWS, setup=CREATE_MONTHLY_SALES_SQL),
        sql_check(UNPIVOT_INCLUDE_NULLS_SQL, UNPIVOT_INCLUDE_NULLS_ROWS, setup=CREATE_MONTHLY_SALES_SQL),
        sql_check(UNPIVOT_NUMBER_ALIAS_SQL, UNPIVOT_NUMBER_ALIAS_ROWS, is_ordered=True, setup=CREATE_MONTHLY_SALES_SQL),
        PIVOT_THEN_UNPIVOT_EXAMPLE.check,
        # 확인 문제 stemSql
        sql_check(WHOLE_TABLE_STEM_SQL, [list(row) for row in (
            (1001, "김민수", "사장", None, "2015-03-02", None, 3000, None, None),
            (1002, "이지은", "과장", 1001, "2018-07-16", 300, None, 2500, None),
            (1003, "박서준", "대리", 1002, "2020-01-06", 0, None, 2800, None),
            (1004, "최유나", "부장", 1001, "2016-11-21", None, None, None, 3200),
            (1005, "정하늘", "사원", 1002, "2022-03-14", None, None, 2500, None),
            (1006, "한도윤", "대리", 1004, "2019-09-02", 500, None, None, 2700),
            (1007, "오지민", "사원", 1004, "2023-02-01", 200, None, None, 2200),
            (1008, "윤서연", "사원", 1001, "2024-05-20", None, None, None, None),
        )]),
        COUNT_WITH_SALARY_EXAMPLE.check,
        sql_check(OUTSIDE_LIST_STEM_SQL, [[7800, None]]),
        sql_check("SELECT * FROM 월별매출 UNPIVOT (매출 FOR 월 IN (일월, 이월, 삼월));", UNPIVOT_ROWS,
                  setup=CREATE_MONTHLY_SALES_SQL),
    ],
}
