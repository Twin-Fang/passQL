"""개념: CUBE (7단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check
from concept_dataset import to_employee_table_md, to_markdown_table

# 20·30번 부서 사원 6명 (ROLLUP 개념과 같은 예시 범위)
DEPARTMENT_20_30_EMPLOYEE_TABLE = to_employee_table_md(
    "사번", "이름", "직급", "급여", "부서번호", employee_numbers=(1002, 1003, 1004, 1005, 1006, 1007))
# 사원 8명 전체 (전체 행 수 18·13 계산용, 직급 5종류·부서번호 NULL 1명이 보여야 함)
EMPLOYEE_POSITION_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")

# CUBE(부서번호, 직급) 결과 13행 (본문 표 = 검증 기대값)
CUBE_COLUMNS = ("부서번호", "직급", "급여합계")
CUBE_ROWS = [
    [20, "과장", 2500], [20, "대리", 2800], [20, "사원", 2500], [20, None, 7800],
    [30, "대리", 2700], [30, "부장", 3200], [30, "사원", 2200], [30, None, 8100],
    [None, "과장", 2500], [None, "대리", 5500], [None, "부장", 3200], [None, "사원", 4700],
    [None, None, 15900],
]

CONCEPT = {
    "tagKey": "group-cube",
    "topicCode": "sql_group_aggregate",
    "sortOrder": 4,
    "title": "CUBE",
    "summary": "묶음 기준으로 만들 수 있는 모든 조합을 집계해요",
    "coreMd": (
        "- `GROUP BY CUBE(A, B)`는 (A, B), (A), (B), () 네 가지 묶음을 모두 집계해요.\n"
        "- 열이 n개면 묶음이 2의 n제곱 개 생겨서, 열 두 개면 4개이고 세 개면 8개예요.\n"
        "- 모든 조합을 만들기 때문에 `CUBE(A, B)`와 `CUBE(B, A)`는 같은 행들을 돌려줘요.\n"
        "- 같은 열로 쓴 ROLLUP보다 B별 소계가 더 붙어서 행이 많아지고, 그만큼 계산할 양도 늘어나요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

`ROLLUP(부서번호, 직급)`으로는 부서별 소계는 볼 수 있지만, "회사 전체에서 대리의 급여 합계는 얼마인가요?" 같은 직급별 소계는 볼 수 없어요. 부서 기준과 직급 기준을 양쪽 다 보고 싶을 때 쓰는 것이 CUBE예요. 엑셀에서 부서를 맨 왼쪽 칸에, 직급을 맨 윗줄에 놓은 급여 합계 표를 떠올려 보면 이해가 쉬워요. 그 표의 오른쪽 끝에 부서별 합계를, 아래 끝에 직급별 합계를, 오른쪽 아래 구석에 전체 합계를 달면 CUBE가 만드는 값이 모두 모여요. CUBE 결과는 이 표의 칸들을 한 줄에 하나씩 풀어서 늘어놓은 모양이에요. 예시는 ROLLUP 개념과 같은 20번과 30번 부서 사원 여섯 명으로 설명해요.

{DEPARTMENT_20_30_EMPLOYEE_TABLE}

## 한 줄 정의 {{#definition}}

CUBE는 괄호 안에 적은 열로 만들 수 있는 모든 조합마다 집계하는, GROUP BY의 확장 기능이에요. `CUBE(부서번호, 직급)`은 아래 네 가지 묶음을 만들어요.

| 묶는 기준 | 뜻 |
|---|---|
| (부서번호, 직급) | 부서 안에서 직급별 합계 |
| (부서번호) | 부서별 소계 |
| (직급) | 직급별 소계 |
| () | 전체 총계 |

열 하나마다 "묶음에 넣는다"와 "뺀다" 두 가지 선택이 있으므로, 열이 n개면 묶음은 2를 n번 곱한 2의 n제곱 개가 돼요.

## 예시로 보는 결과 {{#example}}

```sql
SELECT 부서번호, 직급, SUM(급여) AS 급여합계
FROM 사원
WHERE 부서번호 IN (20, 30)
GROUP BY CUBE(부서번호, 직급)
ORDER BY 부서번호, 직급;
```

{to_markdown_table(CUBE_COLUMNS, CUBE_ROWS)}

위에서 여덟 번째 행까지는 `ROLLUP(부서번호, 직급)`의 결과와 같아요. 그 아래 `NULL | 대리 | 5500` 같은 네 행이 CUBE에서 새로 생긴 직급별 소계이고, 이 행에서는 부서번호를 묶음에서 뺐기 때문에 부서번호 칸이 NULL이에요. 마지막 행은 두 열을 모두 뺀 총계예요.

## 자주 헷갈리는 점 {{#confusing}}

**ROLLUP과 CUBE는 묶음 수가 늘어나는 방식이 달라요.** ROLLUP은 열 개수에 1을 더한 만큼, CUBE는 2의 n제곱만큼 묶음을 만들어요. 열이 하나뿐이면 두 방식 모두 (A)와 () 두 묶음이라서, `CUBE(부서번호)`와 `ROLLUP(부서번호)`는 결과가 같아요. 차이는 열이 둘 이상일 때부터 생겨요.

| 열 개수 | ROLLUP 묶음 수 | CUBE 묶음 수 |
|---|---|---|
| 1 | 2 | 2 |
| 2 | 3 | 4 |
| 3 | 4 | 8 |

열이 세 개인 `CUBE(A, B, C)`는 (A, B, C), (A, B), (A, C), (B, C), (A), (B), (C), () 여덟 묶음을 만들어요.

**열 순서를 바꿔도 같은 행들이 나와요.** ROLLUP은 오른쪽 열부터 빼기 때문에, 열 순서를 바꾸면 소계의 기준도 함께 바뀌어요. CUBE는 순서와 상관없이 모든 조합을 만들기 때문에 `CUBE(직급, 부서번호)`도 위 예시와 똑같은 13행을 돌려줘요. 화면에 열이 보이는 순서와 정렬 순서는 SELECT와 ORDER BY가 정할 뿐이에요.

**행 수는 묶음마다 그룹 수를 세어 더해요.** 위 예시는 (부서번호, 직급) 조합 6행, 부서 2행, 직급 4행, 총계 1행이라서 13행이에요. 같은 여섯 명을 `ROLLUP(부서번호, 직급)`으로 묶으면 직급 4행이 빠진 9행이므로, CUBE가 4행 더 많아요. 아래 사원 여덟 명 전체로 세면 차이가 더 커져요.

{EMPLOYEE_POSITION_TABLE}

여덟 명은 (부서번호, 직급) 조합이 모두 달라서 조합이 8개예요. 부서번호 값은 10, 20, 30, NULL 네 가지이고, 직급 값은 사장, 과장, 대리, 부장, 사원 다섯 가지예요. 그래서 CUBE는 8 + 4 + 5 + 1 = 18행이고, 직급별 소계가 없는 ROLLUP은 8 + 4 + 1 = 13행이에요. 부서번호가 NULL인 윤서연도 부서번호 값 하나로 세야 해요.

```sql
SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY CUBE(부서번호, 직급));    -- 18이 나와요
SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY ROLLUP(부서번호, 직급));  -- 13이 나와요
```

**NULL이 두 가지 뜻으로 섞여 나와요.** CUBE 결과에는 부서번호가 비어 있는 행과 직급이 비어 있는 행이 모두 있어서, 어느 열을 빼고 묶은 행인지 칸마다 따져야 해요. 원래 데이터에 NULL이 있는 경우까지 구분하려면, 소계 때문에 생긴 NULL이면 1을 돌려주는 GROUPING 함수를 써요. 이 함수는 이 단원의 마지막 개념에서 다뤄요.

**계산할 양이 많아요.** CUBE는 열이 하나 늘 때마다 묶음 수가 두 배가 되므로, 열을 많이 넣으면 데이터베이스가 계산할 양이 빠르게 커져요. 모든 조합이 다 필요한 경우가 아니라면 GROUPING SETS를 쓰는 편이 효율적이에요. GROUPING SETS는 원하는 묶음 기준만 괄호 안에 골라 적어서 집계하는 문법이고, 다음 개념에서 다뤄요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

같은 표에 ROLLUP과 CUBE를 각각 쓴 SQL을 주고 결과 행 수를 비교하거나, CUBE 결과의 행 수를 묻는 문제가 가장 많아요. 이때는 2의 n제곱 개의 묶음을 먼저 적고, 묶음마다 그룹 수를 세어 더하면 돼요. 열 순서를 바꾼 두 SQL의 결과가 같은지 묻는 문제도 자주 나오는데, ROLLUP은 결과가 달라지고 CUBE는 같다는 점이 정답의 근거가 돼요.""",
    "checkQuestions": [
        question(1, "`GROUP BY CUBE(부서번호, 직급)`이 만드는 묶음 기준을 모두 고른 것은 무엇인가요?", "definition",
                 "CUBE는 두 열로 만들 수 있는 모든 조합을 집계해요. 그래서 (부서번호, 직급), (부서번호), (직급), () 네 묶음이에요.",
                 [choice("A", "(부서번호, 직급), (부서번호), ()", rationale="ROLLUP의 묶음이고, CUBE는 직급별 묶음도 만들어요."),
                  choice("B", "(부서번호, 직급), (부서번호), (직급), ()", True, "가능한 조합 네 가지를 모두 만들어요."),
                  choice("C", "(부서번호), (직급)", rationale="CUBE는 두 열을 함께 묶은 조합과 총계도 만들어요."),
                  choice("D", "(부서번호, 직급), (직급), ()", rationale="부서번호만으로 묶은 소계가 빠졌어요.")]),
        question(2, "`GROUP BY CUBE(A, B, C)`는 몇 가지 묶음 기준으로 집계하나요?", "confusing",
                 "CUBE는 열마다 넣거나 빼는 두 가지 선택이 있어서 2의 3제곱인 8가지 묶음을 만들어요.",
                 [choice("A", "4가지", rationale="열 개수에 1을 더한 것은 ROLLUP의 묶음 수예요."),
                  choice("B", "6가지", rationale="열 개수에 2를 곱한 값인데, CUBE는 2의 n제곱이에요."),
                  choice("C", "9가지", rationale="열 개수의 제곱인데, CUBE는 2의 n제곱이에요."),
                  choice("D", "8가지", True, "2의 3제곱이라서 8가지예요.")]),
        question(3, "아래 20·30번 부서 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + DEPARTMENT_20_30_EMPLOYEE_TABLE, "confusing",
                 "(부서번호, 직급) 조합 6행, 부서 소계 2행, 직급 소계 4행, 총계 1행을 더해서 13행이에요.",
                 [choice("A", "13행", True, "조합 6행, 부서 2행, 직급 4행, 총계 1행이에요."),
                  choice("B", "9행", rationale="ROLLUP의 행 수이고, CUBE는 직급별 소계 4행이 더 붙어요."),
                  choice("C", "12행", rationale="총계 1행을 빠뜨렸어요."),
                  choice("D", "6행", rationale="(부서번호, 직급) 조합만 셌어요.")],
                 stem_sql="SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY CUBE(부서번호, 직급);"),
        question(4, "`GROUP BY CUBE(부서번호, 직급)`과 `GROUP BY CUBE(직급, 부서번호)`를 비교한 설명으로 알맞은 것은 무엇인가요? (SELECT 절은 같아요)", "confusing",
                 "CUBE는 순서와 상관없이 모든 조합을 만들기 때문에 두 SQL은 같은 행들을 돌려줘요. 순서에 따라 결과가 바뀌는 것은 ROLLUP이에요.",
                 [choice("A", "앞쪽은 부서별 소계만, 뒤쪽은 직급별 소계만 만든다", rationale="CUBE는 순서와 상관없이 두 소계를 모두 만들어요."),
                  choice("B", "뒤쪽 SQL만 총계 행을 만든다", rationale="두 SQL 모두 총계 행 ()를 만들어요."),
                  choice("C", "두 SQL은 같은 행들을 돌려준다", True, "만드는 묶음이 같아서 결과 행의 집합이 같아요."),
                  choice("D", "CUBE 안의 열 순서를 바꾸면 오류가 난다", rationale="열 순서는 자유롭게 써도 돼요.")]),
        question(5, "아래 사원 표 전체에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_POSITION_TABLE, "confusing",
                 "(부서번호, 직급) 조합 8개, 부서번호 값 4개(10, 20, 30, NULL), 직급 값 5개, 총계 1행을 더해서 18행이에요.",
                 [choice("A", "13행", rationale="ROLLUP(부서번호, 직급)의 행 수이고, CUBE는 직급별 소계 5행이 더 붙어요."),
                  choice("B", "18행", True, "조합 8, 부서 4, 직급 5, 총계 1을 더한 수예요."),
                  choice("C", "17행", rationale="부서번호가 NULL인 윤서연의 부서 그룹도 소계 1행이 돼요."),
                  choice("D", "14행", rationale="부서별 소계 4행을 빠뜨렸어요.")],
                 stem_sql="SELECT 부서번호, 직급, COUNT(*) FROM 사원 GROUP BY CUBE(부서번호, 직급);"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 예시 결과 (정렬 확인)
        sql_check("SELECT 부서번호, 직급, SUM(급여) AS 급여합계 FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY CUBE(부서번호, 직급) ORDER BY 부서번호, 직급",
                  CUBE_ROWS, is_ordered=True),
        # 열 하나면 ROLLUP 과 같음
        sql_check("SELECT 부서번호, SUM(급여) FROM 사원 GROUP BY CUBE(부서번호)",
                  [[10, 3000], [20, 7800], [30, 8100], [None, 2000], [None, 20900]]),
        sql_check("SELECT 부서번호, SUM(급여) FROM 사원 GROUP BY ROLLUP(부서번호)",
                  [[10, 3000], [20, 7800], [30, 8100], [None, 2000], [None, 20900]]),
        # 열 순서 바꿔도 같은 행
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY CUBE(직급, 부서번호)", CUBE_ROWS),
        # 같은 범위 ROLLUP 9행 (CUBE 보다 4행 적음)
        sql_check("SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY ROLLUP(부서번호, 직급))", [[9]]),
        # 전체 사원 행 수 (CUBE 18, ROLLUP 13)
        sql_check("SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY CUBE(부서번호, 직급))", [[18]]),
        sql_check("SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY ROLLUP(부서번호, 직급))", [[13]]),
        # 확인 문제 stemSql
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY CUBE(부서번호, 직급);", CUBE_ROWS),
        sql_check("SELECT 부서번호, 직급, COUNT(*) FROM 사원 GROUP BY CUBE(부서번호, 직급);", [
            [10, "사장", 1], [20, "과장", 1], [20, "대리", 1], [20, "사원", 1],
            [30, "대리", 1], [30, "부장", 1], [30, "사원", 1], [None, "사원", 1],
            [10, None, 1], [20, None, 3], [30, None, 3], [None, None, 1],
            [None, "과장", 1], [None, "대리", 2], [None, "부장", 1], [None, "사원", 3], [None, "사장", 1],
            [None, None, 8],
        ]),
    ],
}
