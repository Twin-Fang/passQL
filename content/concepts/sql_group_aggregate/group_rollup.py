"""개념: ROLLUP (7단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_example
from concept_dataset import to_employee_table_md

# 20·30번 부서 사원 6명 (예시 범위, 1008 부서 NULL 은 GROUPING 함수 개념에서 다룸)
DEPARTMENT_20_30_EMPLOYEE_TABLE = to_employee_table_md(
    "사번", "이름", "직급", "급여", "부서번호", employee_numbers=(1002, 1003, 1004, 1005, 1006, 1007))

# 사원 8명 전체 (전체 행 수 13·14 계산용, 직급 5종류·부서번호 NULL 1명이 보여야 함)
EMPLOYEE_POSITION_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")

# ROLLUP(부서번호, 직급) 결과 9행 (본문 표 = 검증 기대값)
ROLLUP_DEPARTMENT_POSITION_COLUMNS = ("부서번호", "직급", "급여합계")
ROLLUP_DEPARTMENT_POSITION_ROWS = [
    [20, "과장", 2500], [20, "대리", 2800], [20, "사원", 2500], [20, None, 7800],
    [30, "대리", 2700], [30, "부장", 3200], [30, "사원", 2200], [30, None, 8100],
    [None, None, 15900],
]
ROLLUP_DEPARTMENT_POSITION_EXAMPLE = sql_example(
    "SELECT 부서번호, 직급, SUM(급여) AS 급여합계\n"
    "FROM 사원\n"
    "WHERE 부서번호 IN (20, 30)\n"
    "GROUP BY ROLLUP(부서번호, 직급)\n"
    "ORDER BY 부서번호, 직급;",
    ROLLUP_DEPARTMENT_POSITION_COLUMNS,
    ROLLUP_DEPARTMENT_POSITION_ROWS,
)
# ROLLUP(직급, 부서번호) 결과 11행
ROLLUP_POSITION_DEPARTMENT_COLUMNS = ("직급", "부서번호", "급여합계")
ROLLUP_POSITION_DEPARTMENT_ROWS = [
    ["과장", 20, 2500], ["과장", None, 2500],
    ["대리", 20, 2800], ["대리", 30, 2700], ["대리", None, 5500],
    ["부장", 30, 3200], ["부장", None, 3200],
    ["사원", 20, 2500], ["사원", 30, 2200], ["사원", None, 4700],
    [None, None, 15900],
]
ROLLUP_POSITION_DEPARTMENT_EXAMPLE = sql_example(
    "SELECT 직급, 부서번호, SUM(급여) AS 급여합계\n"
    "FROM 사원\n"
    "WHERE 부서번호 IN (20, 30)\n"
    "GROUP BY ROLLUP(직급, 부서번호)\n"
    "ORDER BY 직급, 부서번호;",
    ROLLUP_POSITION_DEPARTMENT_COLUMNS,
    ROLLUP_POSITION_DEPARTMENT_ROWS,
)
# 부서번호, ROLLUP(직급) 결과 8행 (총계 없음)
PARTIAL_ROLLUP_ROWS = ROLLUP_DEPARTMENT_POSITION_ROWS[:-1]
PARTIAL_ROLLUP_EXAMPLE = sql_example(
    "SELECT 부서번호, 직급, SUM(급여) AS 급여합계\n"
    "FROM 사원\n"
    "WHERE 부서번호 IN (20, 30)\n"
    "GROUP BY 부서번호, ROLLUP(직급)\n"
    "ORDER BY 부서번호, 직급;",
    ROLLUP_DEPARTMENT_POSITION_COLUMNS,
    PARTIAL_ROLLUP_ROWS,
)

CONCEPT = {
    "tagKey": "group-rollup",
    "topicCode": "sql_group_aggregate",
    "sortOrder": 3,
    "title": "ROLLUP",
    "summary": "묶음 기준을 오른쪽부터 하나씩 빼면서 소계와 총계를 붙여요",
    "coreMd": (
        "- `ROLLUP(A, B)`는 (A, B), (A), () 세 단계를 만들어서, 단계 수가 열 개수보다 **하나 많아요**.\n"
        "- 소계와 총계 행에서는 묶음에서 빠진 열이 **NULL**로 표시돼요.\n"
        "- **오른쪽 열부터** 빠지므로 `ROLLUP(A, B)`와 `ROLLUP(B, A)`는 결과가 달라요.\n"
        "- 행 수는 (A, B) 조합 수, A 값의 개수, 총계 1행을 더해서 세요."
    ),
    "detailMd": f"""## 소계와 총계를 한 번에 — ROLLUP이 필요한 이유 {{#why}}

보고서에는 부서 안 직급별 합계와 함께 부서마다의 중간 합계, 회사 전체 합계가 한 표에 필요할 때가 많아요. GROUP BY만으로는 묶는 기준이 다른 쿼리 세 개를 따로 실행해 이어 붙여야 하지만, ROLLUP은 쿼리 하나로 끝내요.

| 용어 | 뜻 |
|---|---|
| 소계 | 중간 합계예요. 예: 20번 부서 전체의 급여 합계 |
| 총계 | 전체 합계예요. 예: 표에 있는 모든 사원의 급여 합계 |

표가 길어지지 않도록 20번과 30번 부서 사원 여섯 명으로 설명해요.

{DEPARTMENT_20_30_EMPLOYEE_TABLE}

## 한 줄 정의 — 오른쪽 열부터 하나씩 빼기 {{#definition}}

ROLLUP은 GROUP BY에 적은 열 목록을 **오른쪽부터 하나씩** 줄여 가며 여러 단계로 집계하는 GROUP BY의 확장 기능이에요. `ROLLUP(부서번호, 직급)`은 아래 세 단계를 만들어요.

| 단계 | 내용 |
|---|---|
| 1 (부서번호, 직급) | 부서 안에서 직급별 합계 |
| 2 (부서번호) | 오른쪽 직급을 빼고 부서별 소계 |
| 3 () | 둘 다 빼고 전체 총계. 빈 괄호는 아무 열로도 나누지 않아 테이블 전체가 한 묶음이에요 |

| 한 줄 공식 | 뜻 |
|---|---|
| 롤업은 순서 의존 | 열 순서를 바꾸면 소계 기준이 바뀌어요 |
| n개 열이면 n + 1 단계 | `ROLLUP(A, B, C)`는 (A, B, C), (A, B), (A), () 네 단계예요 |
| 단계 수는 행 수가 아님 | 행 수는 단계마다 그룹 수를 세어 더해요 |

ROLLUP은 같은 묶음을 나열한 `GROUPING SETS((부서번호, 직급), (부서번호), ())`와 결과가 같아요. GROUPING SETS는 묶음 기준을 직접 나열하는 문법이고, 그 개념에서 자세히 다뤄요.

## 예시로 보는 결과 — 직급 칸 NULL이 소계 {{#example}}

{ROLLUP_DEPARTMENT_POSITION_EXAMPLE.markdown}

`(20, NULL, 7800)`은 직급을 빼고 묶은 20번 부서 소계이고, `(NULL, NULL, 15900)`은 두 열을 모두 뺀 총계예요. ORDER BY에서 NULL은 오름차순일 때 맨 뒤로 가므로, 소계는 부서마다 마지막 줄에, 총계는 표 맨 끝에 놓여요.

## 열 순서를 바꾸면 — 소계 기준이 바뀌어요 {{#order-matters}}

`ROLLUP(직급, 부서번호)`는 오른쪽의 부서번호를 먼저 빼서 (직급, 부서번호), (직급), () 단계를 만들어요. 그래서 부서별 소계 대신 직급별 소계가 생겨요.

{ROLLUP_POSITION_DEPARTMENT_EXAMPLE.markdown}

| 비교 | ROLLUP(부서번호, 직급) | ROLLUP(직급, 부서번호) |
|---|---|---|
| 2단계 소계 | 부서별 2행 | 직급별 4행 (과장, 대리, 부장, 사원) |
| 소계 행에서 값이 남는 열 | 부서번호 | 직급 |
| 20·30번 여섯 명 행 수 | 6 + 2 + 1 = 9 | 6 + 4 + 1 = 11 |

괄호 안 맨 왼쪽 열은 소계 행에서도 값이 남아 소계의 기준이 되고, 그 오른쪽 열은 NULL이 돼요. ROLLUP 문제는 괄호 안 맨 왼쪽에 어떤 열이 있는지부터 확인하면 돼요.

## 행 수 세기 — 단계마다 그룹 수를 더해요 {{#row-count}}

1단계는 (부서번호, 직급) 조합 수, 2단계는 부서번호 값의 개수, 3단계는 언제나 1행이에요. 아래 사원 여덟 명 전체로 세면 행 수가 더 늘어나요.

{EMPLOYEE_POSITION_TABLE}

| 단계 | 내용 |
|---|---|
| 조합 세기 | 여덟 명은 (부서번호, 직급) 조합이 모두 달라서 8행이에요 |
| 소계 세기 | 부서번호 값은 10, 20, 30, NULL 네 가지라서 4행이에요. 직급 값은 사장, 과장, 대리, 부장, 사원 다섯 가지예요 |
| 더하기 | `ROLLUP(부서번호, 직급)`은 8 + 4 + 1 = 13행, `ROLLUP(직급, 부서번호)`는 8 + 5 + 1 = 14행이에요 |

```sql
SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY ROLLUP(부서번호, 직급));  -- 13이 나와요
SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY ROLLUP(직급, 부서번호));  -- 14가 나와요
```

부서번호가 NULL인 윤서연도 그룹 값 하나로 세야 한다는 점을 놓치기 쉬워요.

## 자주 헷갈리는 점 — 소계 NULL, 괄호 밖 열, 묶은 열 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| 소계 행의 NULL은 직급이 NULL인 사원이에요 | 직급을 빼고 묶었다는 표시예요. 원래 NULL과 구분하려면 이 단원 마지막 개념인 GROUPING 함수를 써요 |
| `ROLLUP(A, B)` 결과는 늘 n + 1행이에요 | n + 1은 묶음 단계 수예요. 행 수는 데이터에 따라 달라져요 |
| `GROUP BY 부서번호, ROLLUP(직급)`도 총계가 있어요 | 괄호 밖 부서번호는 모든 단계에 남아서 (부서번호, 직급), (부서번호) 두 단계뿐이에요. 총계가 없어요 |
| `ROLLUP((부서번호, 직급))`도 부서별 소계를 만들어요 | 안쪽 괄호로 묶은 열은 한 덩어리라서 (부서번호, 직급)과 () 두 단계예요. 조합 6행과 총계 1행으로 7행이에요 |
| 소계는 늘 각 부서 바로 아래에 와요 | ORDER BY가 없으면 행 순서는 실행 방식에 따라 달라질 수 있어요. 소계 위치를 물으면 ORDER BY가 있는지 봐요 |

아래는 괄호 밖에 부서번호를 둔 SQL이에요. 앞의 9행에서 총계 1행만 빠진 8행이 나와요.

{PARTIAL_ROLLUP_EXAMPLE.markdown}

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `ROLLUP(A, B, C)`는 네 단계로 집계해요 | O | (A, B, C), (A, B), (A), () 네 단계예요 |
| `ROLLUP(부서번호, 직급)`에는 직급별 소계 행이 있어요 | X | 오른쪽 직급부터 빼므로 부서별 소계만 생겨요 |
| `ROLLUP((부서번호, 직급))`을 20·30번 여섯 명에 쓰면 7행이에요 | O | 조합 6행과 총계 1행이에요 |

## 꼭 외울 것 — 단계 수와 빠지는 순서 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| `ROLLUP(n개 열)` 묶음 수 | n + 1개 |
| `ROLLUP(A, B)`의 묶음 | (A, B), (A), () |
| 묶음에서 빠지는 순서 | 오른쪽 열부터 하나씩 |
| 열 순서를 바꾸면 | 소계 기준이 바뀌어 결과가 달라요 |
| 소계·총계 행의 빠진 열 | NULL로 표시돼요 |
| `GROUP BY A, ROLLUP(B)` | (A, B), (A) 두 단계, 총계 없음 |
| 결과 행 수 세기 | 단계마다 그룹 수를 더해요 (NULL 값도 한 그룹) |

## 시험에서는 이렇게 나와요 {{#exam-point}}

ROLLUP을 쓴 SQL과 예시 표를 주고 결과 행 수를 묻는 문제가 가장 많아요. 단계별 묶음을 먼저 적고, 각 단계의 그룹 수를 더하면 돼요.

| 자주 나오는 문제 | 푸는 기준 |
|---|---|
| 결과 표 빈칸, 소계인지 총계인지 | NULL로 비어 있는 열이 묶음에서 빠진 열이에요 |
| 열 순서를 바꾼 두 SQL이 같은지 | ROLLUP은 순서가 중요해서 결과가 달라요 |""",
    "checkQuestions": [
        question(1, "`GROUP BY ROLLUP(부서번호, 직급)`이 만드는 묶음 기준을 모두 고른 것은 무엇인가요?", "definition",
                 "ROLLUP은 오른쪽 열부터 하나씩 빼므로 (부서번호, 직급), (부서번호), () 세 단계를 만들어요. 직급만 따로 묶는 단계는 없어요.",
                 [choice("A", "(부서번호, 직급), (부서번호), ()", True, "오른쪽 열인 직급부터 빼서 만든 세 단계예요."),
                  choice("B", "(부서번호, 직급), (직급), ()", rationale="ROLLUP은 오른쪽 열을 먼저 빼므로 직급만 남는 단계는 없어요."),
                  choice("C", "(부서번호, 직급), (부서번호), (직급), ()", rationale="모든 조합을 만드는 것은 ROLLUP이 아니라 CUBE예요."),
                  choice("D", "(부서번호), (직급)", rationale="ROLLUP은 (부서번호, 직급) 단계와 총계 ()도 만들어요.")]),
        question(2, "`GROUP BY ROLLUP(부서번호, 직급)` 결과에 `(20, NULL, 7800)` 행이 있어요. 이 행이 뜻하는 것은 무엇인가요?", "example",
                 "직급 칸의 NULL은 직급을 묶음에서 뺐다는 표시예요. 그래서 이 행은 20번 부서 전체의 급여 소계예요.",
                 [choice("A", "20번 부서에서 직급이 NULL인 사원들의 급여 합계", rationale="직급이 NULL인 사원이 있는 것이 아니라 직급을 빼고 묶은 표시예요."),
                  choice("B", "회사 전체의 급여 총계", rationale="총계는 부서번호와 직급이 모두 NULL인 행이에요."),
                  choice("C", "20번 부서 전체의 급여 소계", True, "부서번호만으로 묶은 2단계 행이에요."),
                  choice("D", "20번 부서에서 급여가 가장 많은 사원의 급여", rationale="SUM(급여)를 썼으므로 합계이고, 7800은 세 명의 급여를 더한 값이에요.")]),
        question(3, "아래 20·30번 부서 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + DEPARTMENT_20_30_EMPLOYEE_TABLE, "confusing",
                 "(부서번호, 직급) 조합 6행, 부서별 소계 2행, 총계 1행을 더해서 9행이에요.",
                 [choice("A", "6행", rationale="(부서번호, 직급) 조합만 센 것이고, 소계와 총계 행이 더 붙어요."),
                  choice("B", "8행", rationale="총계 1행을 빠뜨렸어요."),
                  choice("C", "13행", rationale="직급별 소계 4행까지 센 것인데, ROLLUP은 직급만 따로 묶지 않아요."),
                  choice("D", "9행", True, "조합 6행, 부서 소계 2행, 총계 1행이에요.")],
                 stem_sql="SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY ROLLUP(부서번호, 직급);"),
        question(4, "같은 20·30번 부서 사원 여섯 명을 대상으로, ROLLUP 안의 열 순서를 바꾼 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + DEPARTMENT_20_30_EMPLOYEE_TABLE, "confusing",
                 "ROLLUP(직급, 부서번호)는 부서번호를 먼저 빼서 직급별 소계를 만들어요. 조합 6행, 직급 소계 4행(과장, 대리, 부장, 사원), 총계 1행이라 11행이에요.",
                 [choice("A", "9행", rationale="ROLLUP은 열 순서에 따라 소계 기준이 바뀌어서 결과가 달라져요."),
                  choice("B", "11행", True, "조합 6행, 직급 소계 4행, 총계 1행이에요."),
                  choice("C", "10행", rationale="직급 값은 과장, 대리, 부장, 사원 네 가지라서 직급 소계가 4행이에요."),
                  choice("D", "13행", rationale="부서별 소계 2행까지 더한 수인데, 이 순서에서는 부서별 소계가 생기지 않아요.")],
                 stem_sql="SELECT 직급, 부서번호, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY ROLLUP(직급, 부서번호);"),
        question(5, "다음 SQL의 결과에 대한 설명으로 알맞은 것은 무엇인가요?", "confusing",
                 "ROLLUP 밖에 둔 부서번호는 모든 단계에 남으므로 (부서번호, 직급)과 (부서번호) 두 단계만 생겨요. 그래서 부서별 소계는 있지만 전체 총계 행은 없어요.",
                 [choice("A", "부서별 소계와 전체 총계가 모두 있다", rationale="부서번호가 ROLLUP 밖에 있어서 부서번호까지 빼는 총계 단계는 생기지 않아요."),
                  choice("B", "직급별 소계와 전체 총계가 있다", rationale="ROLLUP 안의 직급을 빼는 단계만 있어서 직급별 소계는 생기지 않아요."),
                  choice("C", "부서별 소계는 있지만 전체 총계는 없다", True, "(부서번호, 직급)과 (부서번호) 두 단계만 만들어져요."),
                  choice("D", "GROUP BY 부서번호, 직급과 결과가 같다", rationale="부서별 소계 행이 더 붙어요.")],
                 stem_sql="SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY 부서번호, ROLLUP(직급);"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 예시 결과 (정렬 확인)
        ROLLUP_DEPARTMENT_POSITION_EXAMPLE.check,
        sql_check("SELECT 부서번호, 직급, SUM(급여) AS 급여합계 FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY ROLLUP(부서번호, 직급) ORDER BY 부서번호, 직급",
                  ROLLUP_DEPARTMENT_POSITION_ROWS, is_ordered=True),
        # 열 순서 바꾼 결과
        ROLLUP_POSITION_DEPARTMENT_EXAMPLE.check,
        sql_check("SELECT 직급, 부서번호, SUM(급여) AS 급여합계 FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY ROLLUP(직급, 부서번호) ORDER BY 직급, 부서번호",
                  ROLLUP_POSITION_DEPARTMENT_ROWS, is_ordered=True),
        # 전체 사원 행 수 (13, 14)
        sql_check("SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY ROLLUP(부서번호, 직급))", [[13]]),
        sql_check("SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY ROLLUP(직급, 부서번호))", [[14]]),
        # 부분 ROLLUP (총계 없음), 묶은 열 ROLLUP (7행)
        PARTIAL_ROLLUP_EXAMPLE.check,
        sql_check("SELECT 부서번호, 직급, SUM(급여) AS 급여합계 FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY 부서번호, ROLLUP(직급) ORDER BY 부서번호, 직급",
                  PARTIAL_ROLLUP_ROWS, is_ordered=True),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY ROLLUP((부서번호, 직급))",
                  [row for row in ROLLUP_DEPARTMENT_POSITION_ROWS if row[1] is not None or row[0] is None]),
        # 열 3개 ROLLUP 4단계 (바로 확인)
        sql_check("SELECT COUNT(DISTINCT 묶음) FROM (SELECT GROUPING_ID(부서번호, 직급, 사번) AS 묶음 FROM 사원 "
                  "GROUP BY ROLLUP(부서번호, 직급, 사번))", [[4]]),
        # GROUPING SETS 대응
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY GROUPING SETS((부서번호, 직급), (부서번호), ())",
                  ROLLUP_DEPARTMENT_POSITION_ROWS),
        # 확인 문제 stemSql
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY ROLLUP(부서번호, 직급);",
                  ROLLUP_DEPARTMENT_POSITION_ROWS),
        sql_check("SELECT 직급, 부서번호, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY ROLLUP(직급, 부서번호);",
                  ROLLUP_POSITION_DEPARTMENT_ROWS),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY 부서번호, ROLLUP(직급);",
                  PARTIAL_ROLLUP_ROWS),
    ],
}
