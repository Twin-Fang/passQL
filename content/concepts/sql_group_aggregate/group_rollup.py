"""개념: ROLLUP (7단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check
from concept_dataset import to_employee_table_md, to_markdown_table

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
# ROLLUP(직급, 부서번호) 결과 11행
ROLLUP_POSITION_DEPARTMENT_COLUMNS = ("직급", "부서번호", "급여합계")
ROLLUP_POSITION_DEPARTMENT_ROWS = [
    ["과장", 20, 2500], ["과장", None, 2500],
    ["대리", 20, 2800], ["대리", 30, 2700], ["대리", None, 5500],
    ["부장", 30, 3200], ["부장", None, 3200],
    ["사원", 20, 2500], ["사원", 30, 2200], ["사원", None, 4700],
    [None, None, 15900],
]
# 부서번호, ROLLUP(직급) 결과 8행 (총계 없음)
PARTIAL_ROLLUP_ROWS = ROLLUP_DEPARTMENT_POSITION_ROWS[:-1]

CONCEPT = {
    "tagKey": "group-rollup",
    "topicCode": "sql_group_aggregate",
    "sortOrder": 3,
    "title": "ROLLUP",
    "summary": "묶음 기준을 오른쪽부터 하나씩 빼면서 소계와 총계를 붙여요",
    "coreMd": (
        "- `GROUP BY ROLLUP(A, B)`는 (A, B)별 집계, A별 소계, 전체 총계를 한 번에 만들어서, 묶음 단계가 열 개수보다 하나 많아요.\n"
        "- 소계와 총계 행에서는 묶음에서 빠진 열이 NULL로 표시돼요.\n"
        "- 오른쪽 열부터 하나씩 빠지기 때문에 `ROLLUP(A, B)`와 `ROLLUP(B, A)`는 결과가 달라요.\n"
        "- 결과 행 수는 (A, B) 조합 수에 A 값의 개수와 총계 1행을 더해서 세요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

보고서를 만들다 보면 부서 안 직급별 급여 합계와 함께, 부서마다의 중간 합계와 회사 전체 합계를 한 표에 보고 싶어져요. 이때 중간 합계를 소계, 전체 합계를 총계라고 불러요. GROUP BY만으로 이것을 만들려면 묶는 기준이 다른 쿼리 세 개를 따로 실행해서 이어 붙여야 하는데, ROLLUP을 쓰면 쿼리 하나로 끝나요. 표가 길어지지 않도록 이 글에서는 20번과 30번 부서 사원 여섯 명으로 설명해요.

{DEPARTMENT_20_30_EMPLOYEE_TABLE}

## 한 줄 정의 {{#definition}}

ROLLUP은 GROUP BY에 적은 열 목록을 오른쪽부터 하나씩 줄여 가며 여러 단계로 집계하는, GROUP BY의 확장 기능이에요. `ROLLUP(부서번호, 직급)`은 아래 세 단계의 묶음을 만들어요.

| 단계 | 묶는 기준 | 뜻 |
|---|---|---|
| 1 | (부서번호, 직급) | 부서 안에서 직급별 합계 |
| 2 | (부서번호) | 부서별 소계 |
| 3 | () | 전체 총계 |

빈 괄호 `()`는 아무 열로도 나누지 않는다는 뜻이라서, 테이블 전체가 한 묶음이 돼요. 열이 두 개면 단계가 세 개이고, 열이 세 개인 `ROLLUP(A, B, C)`는 (A, B, C), (A, B), (A), () 네 단계를 만들어요. 열 개수에 1을 더한 만큼 단계가 생긴다고 기억하면 돼요.

## 예시로 보는 결과 {{#example}}

```sql
SELECT 부서번호, 직급, SUM(급여) AS 급여합계
FROM 사원
WHERE 부서번호 IN (20, 30)
GROUP BY ROLLUP(부서번호, 직급)
ORDER BY 부서번호, 직급;
```

{to_markdown_table(ROLLUP_DEPARTMENT_POSITION_COLUMNS, ROLLUP_DEPARTMENT_POSITION_ROWS)}

직급 칸이 NULL인 `20 | NULL | 7800` 행은 20번 부서의 소계이고, 직급을 묶음에서 뺐기 때문에 직급 칸이 비어 있어요. 마지막 `NULL | NULL | 15900` 행은 두 열을 모두 뺀 총계예요. ORDER BY에서 NULL은 오름차순일 때 맨 뒤로 가기 때문에, 이렇게 정렬하면 소계가 각 부서의 마지막 줄에, 총계가 표의 맨 끝에 놓여요.

## 자주 헷갈리는 점 {{#confusing}}

**소계 행의 NULL은 실제 데이터가 아니에요.** 20번 부서에 직급이 NULL인 사원이 있어서 생긴 행이 아니라, 직급을 빼고 묶었다는 표시로 비워 둔 것이에요. 원래 데이터에 NULL이 있으면 결과만 보고는 두 경우를 구분하기 어려워요. 이때는 소계 때문에 생긴 NULL이면 1, 아니면 0을 돌려주는 GROUPING 함수로 구분하는데, 이 단원의 마지막 개념에서 자세히 다뤄요.

**열 순서를 바꾸면 결과가 달라져요.** ROLLUP은 오른쪽 열부터 빼기 때문에, 열 순서를 바꾼 `ROLLUP(직급, 부서번호)`는 오른쪽에 있는 부서번호를 빼고 직급만 남겨서 소계를 만들어요. 그러면 묶음 단계가 (직급, 부서번호), (직급), ()로 바뀌어서 부서별 소계 대신 직급별 소계가 생겨요.

```sql
SELECT 직급, 부서번호, SUM(급여) AS 급여합계
FROM 사원
WHERE 부서번호 IN (20, 30)
GROUP BY ROLLUP(직급, 부서번호)
ORDER BY 직급, 부서번호;
```

{to_markdown_table(ROLLUP_POSITION_DEPARTMENT_COLUMNS, ROLLUP_POSITION_DEPARTMENT_ROWS)}

같은 여섯 명을 묶었는데도 결과가 9행에서 11행으로 늘었어요. 부서별 소계 2행이 사라지고, 과장, 대리, 부장, 사원 네 직급의 소계 4행이 새로 생겼기 때문이에요. 이렇게 괄호 안 맨 왼쪽 열은 소계 행에서도 값이 남아 소계의 기준이 되고, 그 오른쪽 열은 소계 행에서 NULL이 돼요. 그러니 ROLLUP 문제를 풀 때는 괄호 안 맨 왼쪽에 어떤 열이 있는지부터 확인하면 돼요.

**결과 행 수는 단계별로 나눠 세요.** 1단계 행 수는 (부서번호, 직급) 조합의 개수이고, 2단계 행 수는 부서번호 값의 개수이고, 3단계는 언제나 1행이에요. 위 예시는 조합 6개, 부서 2개, 총계 1행이라서 9행이 나왔어요. 아래 사원 여덟 명 전체로 세면 행 수가 더 늘어나요.

{EMPLOYEE_POSITION_TABLE}

여덟 명은 (부서번호, 직급) 조합이 모두 달라서 1단계는 8행이에요. 부서번호 값은 10, 20, 30, NULL 네 가지이므로 `ROLLUP(부서번호, 직급)`은 8 + 4 + 1 = 13행이에요. 순서를 바꾼 `ROLLUP(직급, 부서번호)`는 2단계가 직급별 소계가 되는데, 직급 값이 사장, 과장, 대리, 부장, 사원 다섯 가지라서 8 + 5 + 1 = 14행이 돼요. 부서번호가 NULL인 윤서연도 하나의 그룹 값으로 세야 한다는 점을 놓치기 쉬워요.

```sql
SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY ROLLUP(부서번호, 직급));  -- 13이 나와요
SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY ROLLUP(직급, 부서번호));  -- 14가 나와요
```

**ROLLUP 괄호 밖에 둔 열은 빠지지 않아요.** `GROUP BY 부서번호, ROLLUP(직급)`처럼 쓰면 ROLLUP 안의 직급만 빠졌다 들어갔다 하고, 바깥의 부서번호는 모든 단계에 남아요. 그래서 (부서번호, 직급)과 (부서번호) 두 단계만 만들어지고, 전체 총계 행은 생기지 않아요. 20·30번 부서 예시로 실행하면 앞의 9행에서 총계 1행만 빠진 8행이 나와요.

```sql
SELECT 부서번호, 직급, SUM(급여) AS 급여합계
FROM 사원
WHERE 부서번호 IN (20, 30)
GROUP BY 부서번호, ROLLUP(직급)
ORDER BY 부서번호, 직급;
```

**괄호로 묶은 열은 한 덩어리로 움직여요.** `ROLLUP((부서번호, 직급))`처럼 안쪽 괄호로 두 열을 묶으면, ROLLUP은 이것을 열 하나처럼 다뤄요. 그래서 (부서번호, 직급)과 () 두 단계만 생기고, 부서별 소계 없이 조합 6행과 총계 1행을 합친 7행이 나와요.

**결과 순서는 ORDER BY로 정해요.** ORDER BY가 없으면 Oracle이 돌려주는 행 순서는 실행 방식에 따라 달라질 수 있어서, 소계가 꼭 각 부서 바로 아래에 온다고 장담할 수 없어요. 시험에 보이는 결과 표는 대부분 정렬된 모양이니, 소계 위치를 물으면 ORDER BY 절이 있는지 확인해요.

**ROLLUP은 GROUPING SETS로 바꿔 쓸 수 있어요.** GROUPING SETS는 원하는 묶음 기준을 괄호 안에 직접 나열해서 집계하는 문법이에요. 그래서 `ROLLUP(부서번호, 직급)`은 같은 묶음 세 개를 나열한 `GROUPING SETS((부서번호, 직급), (부서번호), ())`와 결과가 같아요. 이 대응 관계는 GROUPING SETS 개념에서 자세히 다뤄요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

ROLLUP을 쓴 SQL과 예시 표를 주고 결과 행 수를 묻는 문제가 가장 많아요. 이때는 단계별 묶음을 먼저 적고, 각 단계의 그룹 수를 더하면 돼요. 결과 표의 빈칸을 채우게 하거나 특정 행이 소계인지 총계인지 묻는 문제도 나오는데, NULL로 비어 있는 열이 묶음에서 빠진 열이라는 점을 떠올리면 돼요. 열 순서를 바꾼 두 SQL이 같은 결과를 내는지 묻는 문제에서는 ROLLUP은 순서가 중요하다는 점이 정답의 근거가 돼요.""",
    "checkQuestions": [
        question(1, "`GROUP BY ROLLUP(부서번호, 직급)`이 만드는 묶음 기준을 모두 고른 것은 무엇인가요?", "definition",
                 "ROLLUP은 오른쪽 열부터 하나씩 빼므로 (부서번호, 직급), (부서번호), () 세 단계를 만들어요. 직급만 따로 묶는 단계는 없어요.",
                 [choice("A", "(부서번호, 직급), (부서번호), ()", True, "오른쪽 열인 직급부터 빼서 만든 세 단계예요."),
                  choice("B", "(부서번호, 직급), (직급), ()", rationale="ROLLUP은 오른쪽 열을 먼저 빼므로 직급만 남는 단계는 없어요."),
                  choice("C", "(부서번호, 직급), (부서번호), (직급), ()", rationale="모든 조합을 만드는 것은 ROLLUP이 아니라 CUBE예요."),
                  choice("D", "(부서번호), (직급)", rationale="ROLLUP은 (부서번호, 직급) 단계와 총계 ()도 만들어요.")]),
        question(2, "`GROUP BY ROLLUP(부서번호, 직급)` 결과에 `20 | NULL | 7800` 행이 있어요. 이 행이 뜻하는 것은 무엇인가요?", "example",
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
        sql_check("SELECT 부서번호, 직급, SUM(급여) AS 급여합계 FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY ROLLUP(부서번호, 직급) ORDER BY 부서번호, 직급",
                  ROLLUP_DEPARTMENT_POSITION_ROWS, is_ordered=True),
        # 열 순서 바꾼 결과
        sql_check("SELECT 직급, 부서번호, SUM(급여) AS 급여합계 FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY ROLLUP(직급, 부서번호) ORDER BY 직급, 부서번호",
                  ROLLUP_POSITION_DEPARTMENT_ROWS, is_ordered=True),
        # 전체 사원 행 수 (13, 14)
        sql_check("SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY ROLLUP(부서번호, 직급))", [[13]]),
        sql_check("SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY ROLLUP(직급, 부서번호))", [[14]]),
        # 부분 ROLLUP (총계 없음), 묶은 열 ROLLUP (7행)
        sql_check("SELECT 부서번호, 직급, SUM(급여) AS 급여합계 FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY 부서번호, ROLLUP(직급) ORDER BY 부서번호, 직급",
                  PARTIAL_ROLLUP_ROWS, is_ordered=True),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY ROLLUP((부서번호, 직급))",
                  [row for row in ROLLUP_DEPARTMENT_POSITION_ROWS if row[1] is not None or row[0] is None]),
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
