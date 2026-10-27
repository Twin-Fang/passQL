"""개념: GROUPING SETS (7단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import to_employee_table_md, to_markdown_table

# 20·30번 부서 사원 6명 (ROLLUP·CUBE 개념과 같은 예시 범위)
DEPARTMENT_20_30_EMPLOYEE_TABLE = to_employee_table_md(
    "사번", "이름", "직급", "급여", "부서번호", employee_numbers=(1002, 1003, 1004, 1005, 1006, 1007))
# 사원 8명 전체 (괄호 위치별 행 수 계산용, 직급 5종류·부서번호 NULL 1명이 보여야 함)
EMPLOYEE_POSITION_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")

# GROUPING SETS(부서번호, 직급) 결과 6행 (본문 표 = 검증 기대값)
GROUPING_SETS_COLUMNS = ("부서번호", "직급", "급여합계")
GROUPING_SETS_ROWS = [
    [20, None, 7800], [30, None, 8100],
    [None, "과장", 2500], [None, "대리", 5500], [None, "부장", 3200], [None, "사원", 4700],
]
GRAND_TOTAL_ROW = [None, None, 15900]
# 20·30번 부서 (부서번호, 직급) 조합 6행
DETAIL_ROWS = [[20, "과장", 2500], [20, "대리", 2800], [20, "사원", 2500],
               [30, "대리", 2700], [30, "부장", 3200], [30, "사원", 2200]]
ROLLUP_ROWS = DETAIL_ROWS + GROUPING_SETS_ROWS[:2] + [GRAND_TOTAL_ROW]
CUBE_ROWS = DETAIL_ROWS + GROUPING_SETS_ROWS + [GRAND_TOTAL_ROW]

CONCEPT = {
    "tagKey": "group-grouping-sets",
    "topicCode": "sql_group_aggregate",
    "sortOrder": 5,
    "title": "GROUPING SETS",
    "summary": "필요한 묶음 기준만 골라 적어서 한 번에 집계해요",
    "coreMd": (
        "- `GROUPING SETS`는 괄호 안에 적은 묶음 기준마다 따로 집계한 뒤, 그 결과를 위아래로 이어 붙여 하나로 보여 줘요.\n"
        "- `GROUPING SETS(A, B)`는 A별 집계와 B별 집계만 만들고, 총계는 빈 괄호 `()`를 적어야 생겨요.\n"
        "- `GROUPING SETS((A, B))`는 (A, B) 한 묶음이라 `GROUP BY A, B`와 같아서, 안쪽 괄호 위치에 따라 묶음이 달라져요.\n"
        "- 적은 순서와 상관없이 같은 묶음을 만들고, ROLLUP과 CUBE도 GROUPING SETS로 똑같이 바꿔 쓸 수 있어요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

부서별 급여 합계와 직급별 급여 합계만 보고 싶은데, 모든 조합을 집계하는 `CUBE(부서번호, 직급)`을 쓰면 부서 안 직급별 합계와 총계까지 따라 나와요. 필요 없는 행을 빼려면 원래는 부서번호로 묶는 쿼리와 직급으로 묶는 쿼리를 따로 만들어, 두 결과를 위아래로 이어 붙이는 UNION ALL 연산자로 합쳐야 했어요. GROUPING SETS를 쓰면 원하는 묶음만 골라 적어서 쿼리 하나로 해결할 수 있어요. 예시는 ROLLUP과 CUBE 개념처럼 20번과 30번 부서 사원 여섯 명으로 설명해요.

{DEPARTMENT_20_30_EMPLOYEE_TABLE}

## 한 줄 정의 {{#definition}}

GROUPING SETS는 괄호 안에 나열한 묶음 기준마다 GROUP BY를 따로 한 것처럼 집계하고, 그 결과를 합쳐서 돌려주는 GROUP BY의 확장 기능이에요. 각 묶음 기준을 그룹핑 집합이라고 부르고, 쉼표로 나눠 적어요.

```sql
SELECT 부서번호, 직급, SUM(급여) AS 급여합계
FROM 사원
WHERE 부서번호 IN (20, 30)
GROUP BY GROUPING SETS(부서번호, 직급)
ORDER BY 부서번호, 직급;
```

{to_markdown_table(GROUPING_SETS_COLUMNS, GROUPING_SETS_ROWS)}

위 두 행은 부서번호로 묶은 결과라서 직급 칸이 NULL이고, 아래 네 행은 직급으로 묶은 결과라서 부서번호 칸이 NULL이에요. 아래처럼 쿼리 두 개를 UNION ALL로 이어 붙인 것과 같은 행이 나와요.

```sql
SELECT 부서번호, NULL AS 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY 부서번호
UNION ALL
SELECT NULL, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY 직급;
```

## 자주 헷갈리는 점 {{#confusing}}

**총계는 저절로 생기지 않아요.** ROLLUP과 CUBE는 언제나 총계 행을 만들지만, GROUPING SETS는 적은 묶음만 집계해요. 총계가 필요하면 아무 열로도 나누지 않는다는 뜻의 빈 괄호 `()`를 묶음 하나로 함께 적어요. `GROUPING SETS(부서번호, 직급, ())`는 위 6행에 `(NULL, NULL, 15900)` 총계 1행이 더해져서 7행이 돼요.

**안쪽 괄호가 묶음 하나의 범위를 정해요.** 쉼표로 나눈 것 하나하나가 묶음 기준이고, 안쪽 괄호로 감싼 열들은 함께 하나의 묶음이 돼요. 그래서 괄호 위치만 달라도 결과가 달라져요. 아래 표의 행 수는 이 사원 여덟 명 전체로 셌어요.

{EMPLOYEE_POSITION_TABLE}

여덟 명의 부서번호 값은 10, 20, 30, NULL 네 가지이고, 직급 값은 사장, 과장, 대리, 부장, 사원 다섯 가지예요. (부서번호, 직급) 조합은 여덟 명이 모두 달라서 8개예요.

| 쓴 모양 | 만드는 묶음 | 전체 사원 행 수 |
|---|---|---|
| `GROUPING SETS(부서번호, 직급)` | (부서번호), (직급) | 4 + 5 = 9 |
| `GROUPING SETS((부서번호), (직급))` | (부서번호), (직급) | 9 |
| `GROUPING SETS((부서번호, 직급))` | (부서번호, 직급) | 8 |
| `GROUPING SETS((부서번호, 직급), ())` | (부서번호, 직급), () | 8 + 1 = 9 |

첫째 줄과 둘째 줄은 열 하나짜리 묶음에 괄호를 붙였느냐만 다를 뿐이라서, 같은 두 묶음을 만들고 결과도 같아요. 열이 하나뿐인 묶음은 괄호를 써도 되고 빼도 된다는 뜻이에요. 반면에 셋째 줄은 두 열을 한 괄호 안에 넣었기 때문에 묶음이 (부서번호, 직급) 하나뿐이고, 그래서 평범한 `GROUP BY 부서번호, 직급`과 같은 결과가 나와요. 부서번호로 묶은 4행에는 부서번호가 NULL인 윤서연의 그룹도 들어가 있어요.

**ROLLUP과 CUBE를 GROUPING SETS로 바꿔 쓸 수 있어요.** ROLLUP은 오른쪽 열부터 하나씩 빼며 소계를 만들고, CUBE는 모든 조합을 집계해요. 두 문법이 만드는 묶음을 GROUPING SETS 안에 그대로 나열하면 같은 결과가 나와요. 앞에서 본 것처럼 열 하나짜리 묶음은 괄호를 빼고 써도 되므로, 표의 오른쪽 칸처럼 줄여 쓴 모양도 결과가 같아요.

| 원래 SQL | 같은 결과의 GROUPING SETS | 열 하나짜리 괄호를 뺀 모양 |
|---|---|---|
| `GROUP BY 부서번호, 직급` | `GROUPING SETS((부서번호, 직급))` | 같음 |
| `ROLLUP(부서번호, 직급)` | `GROUPING SETS((부서번호, 직급), (부서번호), ())` | `GROUPING SETS((부서번호, 직급), 부서번호, ())` |
| `CUBE(부서번호, 직급)` | `GROUPING SETS((부서번호, 직급), (부서번호), (직급), ())` | `GROUPING SETS((부서번호, 직급), 부서번호, 직급, ())` |
| `GROUP BY 부서번호, ROLLUP(직급)` | `GROUPING SETS((부서번호, 직급), (부서번호))` | `GROUPING SETS((부서번호, 직급), 부서번호)` |

두 열을 함께 묶은 (부서번호, 직급)은 괄호를 빼면 열 하나짜리 묶음 두 개로 바뀌므로, 이 괄호는 줄일 수 없어요. 시험에서는 두 SQL의 결과가 같은지 묻는 문제가 자주 나오므로, 이 대응표를 묶음 단위로 기억해 두면 좋아요.

```sql
SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY ROLLUP(부서번호, 직급);
SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY GROUPING SETS((부서번호, 직급), (부서번호), ());
-- 두 SQL 모두 같은 9행이 나와요
```

**적는 순서를 바꿔도 같은 묶음이에요.** GROUPING SETS는 묶음을 나열할 뿐이라서, `GROUPING SETS(직급, 부서번호)`도 위 예시와 같은 6행을 돌려줘요. 순서에 따라 결과가 달라지는 ROLLUP과 다르고, 이 점에서는 CUBE와 같아요.

**SELECT에 쓸 수 있는 열도 GROUP BY와 같은 규칙을 따라요.** GROUPING SETS 안에 나오는 열과 집계 함수만 SELECT에 쓸 수 있고, `SELECT 이름, SUM(급여) ... GROUPING SETS(부서번호, 직급)`처럼 다른 열을 쓰면 ORA-00979(GROUP BY에 없는 열) 오류가 나요. 결과에서 묶음에 없는 열이 NULL로 표시되는 것도 ROLLUP, CUBE와 같아요. 원래 데이터의 NULL과 구분하려면, 소계 때문에 생긴 NULL이면 1을 돌려주는 GROUPING 함수를 쓰는데, 이 함수는 다음 개념에서 다뤄요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

GROUPING SETS를 쓴 SQL의 결과 행 수를 묻거나, ROLLUP·CUBE를 쓴 SQL과 같은 결과를 내는 GROUPING SETS를 고르는 문제가 가장 많아요. 행 수를 셀 때는 쉼표로 나뉜 묶음마다 그룹 수를 세어 더하고, 총계는 `()`가 있을 때만 1행을 더해요. 같은 결과를 고르는 문제는 보기마다 만드는 묶음 목록을 적어 보고, 그 목록이 원래 SQL의 묶음과 똑같은지 비교하면 돼요.""",
    "checkQuestions": [
        question(1, "`GROUP BY GROUPING SETS(부서번호, 직급)`이 만드는 묶음 기준을 모두 고른 것은 무엇인가요?", "definition",
                 "GROUPING SETS는 적은 묶음만 집계하므로 (부서번호)와 (직급) 두 묶음만 만들어요. 총계는 ()를 적었을 때만 생겨요.",
                 [choice("A", "(부서번호, 직급), (부서번호), ()", rationale="ROLLUP(부서번호, 직급)의 묶음이에요."),
                  choice("B", "(부서번호), (직급), ()", rationale="()를 적지 않았으므로 총계는 생기지 않아요."),
                  choice("C", "(부서번호), (직급)", True, "적은 두 묶음만 집계해요."),
                  choice("D", "(부서번호, 직급)", rationale="두 열을 한 괄호에 넣은 GROUPING SETS((부서번호, 직급))의 묶음이에요.")]),
        question(2, "아래 20·30번 부서 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + DEPARTMENT_20_30_EMPLOYEE_TABLE, "definition",
                 "부서번호로 묶은 2행과 직급으로 묶은 4행(과장, 대리, 부장, 사원)을 합쳐 6행이에요. ()가 없으므로 총계는 없어요.",
                 [choice("A", "7행", rationale="총계 1행까지 셌는데, ()를 적지 않아서 총계는 없어요."),
                  choice("B", "9행", rationale="ROLLUP(부서번호, 직급)의 행 수예요."),
                  choice("C", "13행", rationale="CUBE(부서번호, 직급)의 행 수예요."),
                  choice("D", "6행", True, "부서 2행과 직급 4행을 합친 수예요.")],
                 stem_sql="SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY GROUPING SETS(부서번호, 직급);"),
        question(3, "`GROUP BY ROLLUP(부서번호, 직급)`과 결과가 같은 것은 무엇인가요?", "confusing",
                 "ROLLUP(부서번호, 직급)은 (부서번호, 직급), (부서번호), () 세 묶음을 만들어요. 이 세 묶음을 그대로 나열한 GROUPING SETS가 같은 결과를 내요.",
                 [choice("A", "GROUP BY GROUPING SETS((부서번호, 직급), (직급), ())", rationale="ROLLUP은 오른쪽 열인 직급을 빼므로 (직급)이 아니라 (부서번호) 묶음이 생겨요."),
                  choice("B", "GROUP BY GROUPING SETS((부서번호, 직급), 부서번호, ())", True, "ROLLUP과 같은 세 묶음을 나열했어요."),
                  choice("C", "GROUP BY GROUPING SETS(부서번호, 직급, ())", rationale="(부서번호, 직급) 묶음이 빠지고 (직급) 묶음이 들어갔어요."),
                  choice("D", "GROUP BY GROUPING SETS((부서번호, 직급), (부서번호), (직급), ())", rationale="CUBE(부서번호, 직급)과 같은 묶음이에요.")]),
        question(4, "`GROUP BY GROUPING SETS((부서번호, 직급))`과 결과가 같은 것은 무엇인가요?", "confusing",
                 "두 열이 한 괄호 안에 있으므로 (부서번호, 직급) 한 묶음만 만들어요. 그래서 평범한 GROUP BY 부서번호, 직급과 같아요.",
                 [choice("A", "GROUP BY 부서번호, 직급", True, "(부서번호, 직급) 한 묶음만 집계해요."),
                  choice("B", "GROUP BY GROUPING SETS(부서번호, 직급)", rationale="이것은 (부서번호)와 (직급) 두 묶음을 만들어요."),
                  choice("C", "GROUP BY ROLLUP(부서번호, 직급)", rationale="부서별 소계와 총계 행이 더 붙어요."),
                  choice("D", "GROUP BY 부서번호", rationale="부서번호 하나로만 묶는 결과예요.")]),
        question(5, "아래 사원 표 전체에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_POSITION_TABLE, "confusing",
                 "부서번호 묶음은 10, 20, 30, NULL 네 그룹이고, ()가 총계 1행을 더해서 5행이에요.",
                 [choice("A", "4행", rationale="()가 만드는 총계 1행을 빠뜨렸어요."),
                  choice("B", "5행", True, "부서번호 그룹 4행과 총계 1행이에요."),
                  choice("C", "6행", rationale="40번 부서는 사원이 없어서 그룹이 만들어지지 않아요."),
                  choice("D", "1행", rationale="()만 있는 것이 아니라 부서번호 묶음도 함께 집계해요.")],
                 stem_sql="SELECT 부서번호, SUM(급여) FROM 사원 GROUP BY GROUPING SETS(부서번호, ());"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 정의 예시 (정렬 확인), UNION ALL 과 같은 행
        sql_check("SELECT 부서번호, 직급, SUM(급여) AS 급여합계 FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY GROUPING SETS(부서번호, 직급) ORDER BY 부서번호, 직급",
                  GROUPING_SETS_ROWS, is_ordered=True),
        sql_check("SELECT 부서번호, NULL AS 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY 부서번호 "
                  "UNION ALL SELECT NULL, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY 직급",
                  GROUPING_SETS_ROWS),
        # 총계 ()
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY GROUPING SETS(부서번호, 직급, ())",
                  GROUPING_SETS_ROWS + [GRAND_TOTAL_ROW]),
        # 괄호 위치별 전체 사원 행 수 (9, 9, 8, 9)
        sql_check("SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY GROUPING SETS(부서번호, 직급))", [[9]]),
        sql_check("SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY GROUPING SETS((부서번호), (직급)))", [[9]]),
        sql_check("SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY GROUPING SETS((부서번호, 직급)))", [[8]]),
        sql_check("SELECT COUNT(*) FROM (SELECT 부서번호, 직급 FROM 사원 GROUP BY GROUPING SETS((부서번호, 직급), ()))", [[9]]),
        # 대응표 (GROUP BY, ROLLUP, CUBE, 부분 ROLLUP)
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY GROUPING SETS((부서번호, 직급))", DETAIL_ROWS),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY 부서번호, 직급", DETAIL_ROWS),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY ROLLUP(부서번호, 직급)", ROLLUP_ROWS),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY GROUPING SETS((부서번호, 직급), (부서번호), ())", ROLLUP_ROWS),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY GROUPING SETS((부서번호, 직급), (부서번호), (직급), ())", CUBE_ROWS),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY CUBE(부서번호, 직급)", CUBE_ROWS),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY GROUPING SETS((부서번호, 직급), (부서번호))", DETAIL_ROWS + GROUPING_SETS_ROWS[:2]),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY 부서번호, ROLLUP(직급)",
                  DETAIL_ROWS + GROUPING_SETS_ROWS[:2]),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY GROUPING SETS((부서번호, 직급), 부서번호, 직급, ())", CUBE_ROWS),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY GROUPING SETS((부서번호, 직급), 부서번호)", DETAIL_ROWS + GROUPING_SETS_ROWS[:2]),
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY GROUPING SETS((부서번호, 직급), 부서번호, ())", ROLLUP_ROWS),
        # 순서 바꿔도 같은 묶음, 다른 열 오류
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY GROUPING SETS(직급, 부서번호)",
                  GROUPING_SETS_ROWS),
        sql_error_check("SELECT 이름, SUM(급여) FROM 사원 GROUP BY GROUPING SETS(부서번호, 직급)", "ORA-00979"),
        # 확인 문제 stemSql, 3번 오답 보기 (ROLLUP 9행과 다름)
        sql_check("SELECT 부서번호, 직급, SUM(급여) FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY GROUPING SETS(부서번호, 직급);",
                  GROUPING_SETS_ROWS),
        sql_check("SELECT COUNT(*) FROM (SELECT 1 FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY GROUPING SETS((부서번호, 직급), (직급), ()))", [[11]]),
        sql_check("SELECT COUNT(*) FROM (SELECT 1 FROM 사원 WHERE 부서번호 IN (20, 30) "
                  "GROUP BY GROUPING SETS((부서번호, 직급), 부서번호, ()))", [[9]]),
        sql_check("SELECT 부서번호, SUM(급여) FROM 사원 GROUP BY GROUPING SETS(부서번호, ());",
                  [[10, 3000], [20, 7800], [30, 8100], [None, 2000], [None, 20900]]),
    ],
}
