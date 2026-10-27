"""개념: GROUP BY와 HAVING (7단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import DEPARTMENT_TABLE_MD, to_employee_table_md, to_markdown_table

EMPLOYEE_DEPARTMENT_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")

# 부서별 인원·급여 합계 (본문 결과 표 = 검증 기대값)
DEPARTMENT_SUMMARY_COLUMNS = ("부서번호", "인원", "급여합계")
DEPARTMENT_SUMMARY_ROWS = [[10, 1, 3000], [20, 3, 7800], [30, 3, 8100], [None, 1, 2000]]

# 급여 합계 큰 순 부서별 인원 (본문 결과 표 = 검증 기대값)
HEADCOUNT_BY_SALARY_TOTAL_ROWS = [[30, 3], [20, 3], [10, 1], [None, 1]]

CONCEPT = {
    "tagKey": "group-group-by-having",
    "topicCode": "sql_group_aggregate",
    "sortOrder": 2,
    "title": "GROUP BY와 HAVING",
    "summary": "같은 값을 가진 행끼리 묶어 집계하고, 묶은 결과를 HAVING으로 걸러요",
    "coreMd": (
        "- `GROUP BY 열`을 쓰면 그 열의 값이 같은 행끼리 한 그룹이 되고, 집계 함수는 그룹마다 하나씩 계산돼요.\n"
        "- GROUP BY를 쓰면 SELECT, HAVING, ORDER BY 절에 GROUP BY에 적은 열과 집계 함수만 올 수 있고, 다른 열을 쓰면 ORA-00979(GROUP BY에 없는 열) 오류가 나요. 집계 함수는 SELECT에 없어도 HAVING과 ORDER BY에 쓸 수 있어요.\n"
        "- WHERE는 묶기 전에 행을 거르고 HAVING은 묶은 뒤에 그룹을 거르며, WHERE에 집계 함수를 쓰면 ORA-00934(이 자리에 그룹 함수를 쓸 수 없음) 오류가 나요.\n"
        "- 실행 순서가 FROM > WHERE > GROUP BY > HAVING > SELECT > ORDER BY라서, GROUP BY에는 SELECT에서 붙인 별칭을 쓸 수 없어요.\n"
        "- 부서번호가 NULL인 행들도 한 그룹으로 묶여서 결과에 한 행으로 나와요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

집계 함수만 쓰면 사원 전체가 한 묶음이라서 결과가 1행으로 끝나요. 그런데 실제로는 "부서마다 몇 명이고, 급여 합계는 얼마인가요?"처럼 묶음을 나눠서 계산하고 싶을 때가 많아요. 부서번호가 같은 사원끼리 나눠 담고, 담은 바구니마다 집계 함수를 따로 계산하게 해 주는 것이 GROUP BY예요. 이 글의 예시는 아래 사원 표로 설명해요.

{EMPLOYEE_DEPARTMENT_TABLE}

## 한 줄 정의 {{#definition}}

GROUP BY는 지정한 열의 값이 같은 행끼리 묶어 그룹을 만들고, 집계 함수를 그룹마다 계산하게 하는 절이에요. HAVING은 이렇게 만들어진 그룹 가운데 조건에 맞는 그룹만 남기는 절이에요.

```sql
SELECT 부서번호, COUNT(*) AS 인원, SUM(급여) AS 급여합계
FROM 사원
GROUP BY 부서번호
ORDER BY 부서번호;
```

{to_markdown_table(DEPARTMENT_SUMMARY_COLUMNS, DEPARTMENT_SUMMARY_ROWS)}

여덟 행이 부서번호 값에 따라 네 그룹으로 묶였고, 결과는 그룹마다 한 행씩 나와요. 아래 부서 표에는 40번 인사부도 있지만, 이 쿼리는 사원 표만 읽어서 사원 표에 있는 부서번호 값으로만 그룹을 만들어요. 40번 부서에 속한 사원이 한 명도 없으므로 40번 그룹은 결과에 나오지 않아요.

{DEPARTMENT_TABLE_MD}

## 실행 순서로 보면 규칙이 풀려요 {{#order}}

GROUP BY와 HAVING의 규칙은 대부분 SQL이 절을 처리하는 순서에서 나와요. 적는 순서는 SELECT가 맨 앞이지만, 실제로 처리하는 순서는 아래와 같아요.

1. FROM에서 사원 표를 읽어요.
2. WHERE로 조건에 맞지 않는 행을 버려요.
3. GROUP BY로 남은 행을 그룹으로 묶어요.
4. HAVING으로 조건에 맞지 않는 그룹을 버려요.
5. SELECT로 보여 줄 값을 계산하고 별칭을 붙여요.
6. ORDER BY로 결과를 정렬해요.

## 자주 헷갈리는 점 {{#confusing}}

**SELECT 절에는 GROUP BY 열과 집계 함수만 올 수 있어요.** 부서번호로 묶으면 20번 그룹에는 이지은, 박서준, 정하늘 세 명이 들어 있어요. 그룹 하나가 결과 한 행이 되는데 이름은 세 개라서, SQL은 어느 이름을 보여 줄지 정할 수 없어요. 그래서 GROUP BY에 없는 열을 SELECT에 쓰면 ORA-00979(GROUP BY에 없는 열) 오류가 나요. 같은 규칙이 HAVING과 ORDER BY에도 적용되는데, 집계 함수는 그룹마다 값이 하나뿐이라서 SELECT에 없어도 HAVING과 ORDER BY에 쓸 수 있어요. 이 두 절은 아래에서 다시 다뤄요. 반대로 GROUP BY에 적은 열을 SELECT에서 빼는 것은 괜찮아서, `SELECT COUNT(*) FROM 사원 GROUP BY 부서번호`는 인원만 네 행으로 보여 줘요.

```sql
-- 오류: 이름이 GROUP BY에 없어요 (ORA-00979, GROUP BY에 없는 열)
SELECT 부서번호, 이름, SUM(급여) FROM 사원 GROUP BY 부서번호;
```

앞 개념에서 본 오류와 헷갈리지 않게 구분해 두면 좋아요. GROUP BY 없이 일반 열과 집계 함수를 섞으면 ORA-00937(한 행으로 묶을 수 없는 그룹 함수)이 나고, GROUP BY가 있는데 거기에 없는 열을 쓰면 ORA-00979(GROUP BY에 없는 열)가 나요. 시험에서는 번호보다 오류가 나는지 여부를 물어요.

**GROUP BY에는 SELECT 별칭을 쓸 수 없어요.** 별칭은 5번째 단계인 SELECT에서 붙는데, GROUP BY는 3번째 단계라서 그 이름을 아직 몰라요. 그래서 `GROUP BY 부서`처럼 별칭으로 묶으면 ORA-00904(없는 열 이름) 오류가 나요. ORDER BY는 SELECT보다 뒤에 처리되므로 별칭을 쓸 수 있어요. 2024년에 나온 새 버전인 Oracle 23ai부터는 GROUP BY에도 별칭을 허용하지만, 시험은 그 이전 버전을 기준으로 하므로 오류라고 답해요.

```sql
-- 오류: GROUP BY 시점에는 별칭 '부서'가 아직 없어요 (ORA-00904, 없는 열 이름)
SELECT 부서번호 AS 부서, COUNT(*) FROM 사원 GROUP BY 부서;
```

**WHERE와 HAVING은 거르는 대상이 달라요.** WHERE는 묶기 전의 행 하나하나를 거르고, HAVING은 묶은 뒤의 그룹을 걸러요. 아래 SQL은 급여가 2500 이상인 사원만 남긴 뒤 부서별로 묶고, 그중 인원이 2명 이상인 부서만 보여 줘요.

```sql
SELECT 부서번호, COUNT(*) AS 인원
FROM 사원
WHERE 급여 >= 2500
GROUP BY 부서번호
HAVING COUNT(*) >= 2
ORDER BY 부서번호;
```

| 부서번호 | 인원 |
|---|---|
| 20 | 3 |
| 30 | 2 |

WHERE에서 오지민(2200)과 윤서연(2000)이 먼저 빠지므로 30번 부서는 2명이 되고, NULL 그룹은 아예 만들어지지 않아요. 남은 그룹은 10번(1명), 20번(3명), 30번(2명)이고, HAVING이 1명뿐인 10번을 버려요. 그룹마다 계산하는 `COUNT(*)`는 묶은 뒤에야 값이 생기므로 WHERE에는 쓸 수 없고, 쓰면 ORA-00934(이 자리에 그룹 함수를 쓸 수 없음) 오류가 나요.

```sql
-- 오류: WHERE 단계에서는 아직 그룹이 없어요 (ORA-00934, 여기서 쓸 수 없는 그룹 함수)
SELECT 부서번호, COUNT(*) FROM 사원 WHERE COUNT(*) >= 2 GROUP BY 부서번호;
```

HAVING에도 SELECT와 같은 제한이 있어서, GROUP BY 열과 집계 함수로만 조건을 써요. `HAVING 부서번호 = 20`은 동작하지만, 그룹으로 묶기 전에 걸러도 결과가 같으니 WHERE에 쓰는 편이 처리할 행이 줄어 효율적이에요. `HAVING 급여 > 2000`처럼 그룹에 속한 행마다 값이 다른 열을 쓰면 SELECT 때와 같은 ORA-00979(GROUP BY에 없는 열) 오류가 나요.

**NULL끼리도 한 그룹으로 묶여요.** 2단원 'WHERE 절과 NULL'에서 본 것처럼, WHERE 절에서는 `부서번호 = NULL`이 참이 되지 않아서 NULL과 NULL을 같다고 보지 않아요. 하지만 GROUP BY는 NULL인 행을 모두 모아 그룹 하나로 만들어요. 그래서 부서번호로 묶은 결과는 10, 20, 30, NULL 네 행이에요. 서로 다른 부서번호를 세는 `COUNT(DISTINCT 부서번호)`가 NULL을 빼고 3인 것과 헷갈리기 쉬우니, 그룹 수를 셀 때는 NULL 그룹까지 하나로 세요.

**GROUP BY 없이 HAVING만 쓸 수도 있어요.** 이때는 테이블 전체가 그룹 하나로 취급돼요. 그래서 `HAVING COUNT(*) > 5`는 전체 인원 8이 조건에 맞으니 1행을 보여 주고, `HAVING COUNT(*) > 10`은 그 하나뿐인 그룹이 걸러져서 0행이 돼요.

```sql
SELECT COUNT(*) FROM 사원 HAVING COUNT(*) > 5;   -- 8이 나와요
SELECT COUNT(*) FROM 사원 HAVING COUNT(*) > 10;  -- 0행이 나와요
```

**그룹 쿼리의 ORDER BY에도 같은 제한이 있어요.** 정렬하는 시점에는 이미 행이 그룹으로 합쳐졌기 때문에, ORDER BY에도 GROUP BY 열, 집계 함수, SELECT 별칭만 쓸 수 있어요. 집계 함수는 SELECT에 없어도 정렬 기준으로 쓸 수 있어서, 아래 SQL은 화면에 보이지 않는 급여 합계가 큰 순서로 부서를 정렬해요. 반면에 `ORDER BY 이름`처럼 그룹에 속한 행마다 다른 열을 쓰면 ORA-00979(GROUP BY에 없는 열) 오류가 나요.

```sql
SELECT 부서번호, COUNT(*) AS 인원 FROM 사원 GROUP BY 부서번호 ORDER BY SUM(급여) DESC;
```

{to_markdown_table(("부서번호", "인원"), HEADCOUNT_BY_SALARY_TOTAL_ROWS)}

**집계 함수를 한 번 더 겹쳐 쓸 수 있어요.** Oracle에서는 GROUP BY가 있을 때 `MAX(SUM(급여))`처럼 집계 결과를 다시 집계할 수 있고, 부서별 합계 중 가장 큰 8100이 1행으로 나와요. 결과가 다시 하나로 줄어들었으므로, 이때 SELECT에 부서번호를 함께 쓰면 ORA-00937(한 행으로 묶을 수 없는 그룹 함수) 오류가 나요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

WHERE와 HAVING이 함께 있는 SQL을 주고 결과 행 수를 묻는 문제가 가장 많아요. 이때는 실행 순서를 따라 WHERE로 지울 행을 먼저 지우고, 남은 행으로 그룹을 만든 다음 HAVING을 적용하면 돼요. 그 밖에 오류가 나는 SQL을 고르는 문제가 자주 나오는데, SELECT, HAVING, ORDER BY에 GROUP BY에 없는 열이 있는지와 GROUP BY에 별칭을 썼는지, WHERE에 집계 함수를 썼는지를 차례로 확인하면 돼요.""",
    "checkQuestions": [
        question(1, "HAVING 절에 대한 설명으로 알맞은 것은 무엇인가요?", "definition",
                 "HAVING은 GROUP BY로 묶은 뒤 만들어진 그룹을 조건으로 걸러요. 묶기 전의 행을 거르는 것은 WHERE의 일이에요.",
                 [choice("A", "그룹으로 묶기 전에 행을 하나씩 거른다", rationale="묶기 전에 행을 거르는 것은 WHERE예요."),
                  choice("B", "GROUP BY 절이 없으면 쓸 수 없다", rationale="GROUP BY가 없으면 테이블 전체를 한 그룹으로 보고 HAVING을 적용해요."),
                  choice("C", "그룹으로 묶은 뒤 조건에 맞는 그룹만 남긴다", True, "HAVING의 정의예요."),
                  choice("D", "SELECT 절보다 나중에 처리된다", rationale="HAVING은 GROUP BY 바로 다음, SELECT보다 앞에서 처리돼요.")]),
        question(2, "다음 중 실행하면 오류가 나는 SQL은 무엇인가요?", "confusing",
                 "부서번호로 묶으면 그룹 하나에 이름이 여러 개라서 SELECT에 이름을 쓸 수 없어요. 집계 함수는 SELECT에 없어도 ORDER BY에 쓸 수 있어요.",
                 [choice("A", "SELECT 부서번호, 이름 FROM 사원 GROUP BY 부서번호", True,
                         "이름은 GROUP BY에 없는 열이라 오류가 나요."),
                  choice("B", "SELECT COUNT(*) FROM 사원 GROUP BY 부서번호", rationale="GROUP BY 열을 SELECT에서 빼는 것은 괜찮아요."),
                  choice("C", "SELECT 부서번호, SUM(급여) FROM 사원 GROUP BY 부서번호", rationale="GROUP BY 열과 집계 함수만 썼어요."),
                  choice("D", "SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 ORDER BY SUM(급여)",
                         rationale="집계 함수는 SELECT에 없어도 ORDER BY 기준으로 쓸 수 있어요.")]),
        question(3, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_DEPARTMENT_TABLE, "confusing",
                 "WHERE가 오지민과 윤서연을 먼저 빼서 10번 1명, 20번 3명, 30번 2명 그룹이 생겨요. HAVING이 1명뿐인 10번을 버려서 2행이 남아요.",
                 [choice("A", "1행", rationale="30번 부서도 WHERE를 통과한 사원이 최유나와 한도윤 2명이라 남아요."),
                  choice("B", "2행", True, "20번과 30번 부서가 남아요."),
                  choice("C", "3행", rationale="10번 부서는 1명뿐이라 HAVING에서 빠져요."),
                  choice("D", "4행", rationale="윤서연이 WHERE에서 빠져서 부서번호 NULL 그룹은 만들어지지 않아요.")],
                 stem_sql="SELECT 부서번호, COUNT(*) FROM 사원 WHERE 급여 >= 2500 GROUP BY 부서번호 HAVING COUNT(*) >= 2;"),
        question(4, "다음 SQL을 실행한 결과로 알맞은 것은 무엇인가요?", "confusing",
                 "GROUP BY는 SELECT보다 먼저 처리되므로 SELECT에서 붙인 별칭을 알지 못해요. 그래서 ORA-00904(없는 열 이름) 오류가 나요.",
                 [choice("A", "부서번호별로 4행이 나온다", rationale="GROUP BY에 쓴 '부서'를 열 이름으로 찾지 못해 실행되지 않아요."),
                  choice("B", "NULL을 뺀 3행이 나온다", rationale="실행 자체가 되지 않아요."),
                  choice("C", "전체가 한 그룹이 되어 1행이 나온다", rationale="알 수 없는 이름을 무시하고 실행하지 않아요."),
                  choice("D", "오류가 난다", True, "GROUP BY 시점에는 별칭이 없어서 없는 열 이름으로 처리돼요.")],
                 stem_sql="SELECT 부서번호 AS 부서, COUNT(*) FROM 사원 GROUP BY 부서;"),
        question(5, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_DEPARTMENT_TABLE, "confusing",
                 "그룹은 10번 1명, 20번 3명, 30번 3명, NULL 1명으로 네 개예요. 인원이 1명인 그룹은 10번과 NULL 그룹이라 2행이 나와요.",
                 [choice("A", "1행", rationale="부서번호가 NULL인 윤서연도 그룹 하나가 되어 함께 나와요."),
                  choice("B", "2행", True, "10번 그룹과 NULL 그룹이 나와요."),
                  choice("C", "3행", rationale="40번 부서는 사원이 없어서 그룹이 만들어지지 않아요."),
                  choice("D", "4행", rationale="HAVING이 인원이 3명인 20번과 30번 그룹을 걸러요.")],
                 stem_sql="SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 HAVING COUNT(*) = 1;"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 정의 예시 (부서별 인원·합계, 정렬 확인)
        sql_check("SELECT 부서번호, COUNT(*) AS 인원, SUM(급여) AS 급여합계 FROM 사원 GROUP BY 부서번호 ORDER BY 부서번호",
                  DEPARTMENT_SUMMARY_ROWS, is_ordered=True),
        # SELECT 제한 (GROUP BY 열 생략 가능, 다른 열 오류, 별칭 오류)
        sql_check("SELECT COUNT(*) FROM 사원 GROUP BY 부서번호", [[1], [3], [3], [1]]),
        sql_error_check("SELECT 부서번호, 이름, SUM(급여) FROM 사원 GROUP BY 부서번호", "ORA-00979"),
        sql_error_check("SELECT 부서번호 AS 부서, COUNT(*) FROM 사원 GROUP BY 부서;", "ORA-00904"),
        # WHERE <-> HAVING (결과, WHERE 집계 오류, HAVING 열 제한)
        sql_check("SELECT 부서번호, COUNT(*) AS 인원 FROM 사원 WHERE 급여 >= 2500 GROUP BY 부서번호 HAVING COUNT(*) >= 2 ORDER BY 부서번호",
                  [[20, 3], [30, 2]], is_ordered=True),
        sql_error_check("SELECT 부서번호, COUNT(*) FROM 사원 WHERE COUNT(*) >= 2 GROUP BY 부서번호", "ORA-00934"),
        sql_check("SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 HAVING 부서번호 = 20", [[20, 3]]),
        sql_error_check("SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 HAVING 급여 > 2000", "ORA-00979"),
        # NULL 그룹 <-> COUNT(DISTINCT)
        sql_check("SELECT COUNT(DISTINCT 부서번호) FROM 사원", [[3]]),
        # GROUP BY 없는 HAVING
        sql_check("SELECT COUNT(*) FROM 사원 HAVING COUNT(*) > 5", [[8]]),
        sql_check("SELECT COUNT(*) FROM 사원 HAVING COUNT(*) > 10", []),
        # ORDER BY 제한 (SELECT 에 없는 집계 가능, 일반 열 오류)
        sql_check("SELECT 부서번호, COUNT(*) AS 인원 FROM 사원 GROUP BY 부서번호 ORDER BY SUM(급여) DESC",
                  HEADCOUNT_BY_SALARY_TOTAL_ROWS, is_ordered=True),
        sql_error_check("SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 ORDER BY 이름", "ORA-00979"),
        # 집계 중첩
        sql_check("SELECT MAX(SUM(급여)) FROM 사원 GROUP BY 부서번호", [[8100]]),
        sql_error_check("SELECT 부서번호, MAX(SUM(급여)) FROM 사원 GROUP BY 부서번호", "ORA-00937"),
        # 확인 문제 보기·stemSql
        sql_error_check("SELECT 부서번호, 이름 FROM 사원 GROUP BY 부서번호", "ORA-00979"),
        sql_check("SELECT 부서번호, SUM(급여) FROM 사원 GROUP BY 부서번호", [[10, 3000], [20, 7800], [30, 8100], [None, 2000]]),
        sql_check("SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 ORDER BY SUM(급여)",
                  [[None, 1], [10, 1], [20, 3], [30, 3]], is_ordered=True),
        sql_check("SELECT 부서번호, COUNT(*) FROM 사원 WHERE 급여 >= 2500 GROUP BY 부서번호 HAVING COUNT(*) >= 2;", [[20, 3], [30, 2]]),
        sql_check("SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 HAVING COUNT(*) = 1;", [[10, 1], [None, 1]]),
    ],
}
