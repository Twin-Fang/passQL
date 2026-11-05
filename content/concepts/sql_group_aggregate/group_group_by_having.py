"""개념: GROUP BY와 HAVING (7단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import DEPARTMENT_TABLE_MD, to_employee_table_md

EMPLOYEE_DEPARTMENT_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")

# 부서별 인원·급여 합계 (본문 결과 표 = 검증 기대값)
DEPARTMENT_SUMMARY_COLUMNS = ("부서번호", "인원", "급여합계")
DEPARTMENT_SUMMARY_ROWS = [[10, 1, 3000], [20, 3, 7800], [30, 3, 8100], [None, 1, 2000]]
DEPARTMENT_SUMMARY_EXAMPLE = sql_example(
    "SELECT 부서번호, COUNT(*) AS 인원, SUM(급여) AS 급여합계\n"
    "FROM 사원\n"
    "GROUP BY 부서번호\n"
    "ORDER BY 부서번호;",
    DEPARTMENT_SUMMARY_COLUMNS,
    DEPARTMENT_SUMMARY_ROWS,
)

# WHERE(급여 2500 이상) > GROUP BY > HAVING(2명 이상)
WHERE_HAVING_EXAMPLE = sql_example(
    "SELECT 부서번호, COUNT(*) AS 인원\n"
    "FROM 사원\n"
    "WHERE 급여 >= 2500\n"
    "GROUP BY 부서번호\n"
    "HAVING COUNT(*) >= 2\n"
    "ORDER BY 부서번호;",
    ("부서번호", "인원"),
    [[20, 3], [30, 2]],
)

# 급여 합계 큰 순 부서별 인원 (SELECT 에 없는 집계로 정렬)
HEADCOUNT_BY_SALARY_TOTAL_ROWS = [[30, 3], [20, 3], [10, 1], [None, 1]]
ORDER_BY_AGGREGATE_EXAMPLE = sql_example(
    "SELECT 부서번호, COUNT(*) AS 인원 FROM 사원 GROUP BY 부서번호 ORDER BY SUM(급여) DESC;",
    ("부서번호", "인원"),
    HEADCOUNT_BY_SALARY_TOTAL_ROWS,
)

# KEEP 문단: 입사일 순서를 셀 수 있게 입사일 열까지 보임 (README 글쓰기 규칙 10)
EMPLOYEE_HIRE_DATE_TABLE = to_employee_table_md("사번", "이름", "입사일", "급여", "부서번호")
# 부서별 첫 입사자·마지막 입사자 급여 <-> 그냥 MAX(급여)
KEEP_FIRST_LAST_EXAMPLE = sql_example(
    "SELECT 부서번호,\n"
    "       MAX(급여) KEEP (DENSE_RANK FIRST ORDER BY 입사일) AS 첫입사자급여,\n"
    "       MAX(급여) KEEP (DENSE_RANK LAST ORDER BY 입사일) AS 마지막입사자급여,\n"
    "       MAX(급여) AS 최고급여\n"
    "FROM 사원\n"
    "GROUP BY 부서번호\n"
    "ORDER BY 부서번호;",
    ("부서번호", "첫입사자급여", "마지막입사자급여", "최고급여"),
    [[10, 3000, 3000, 3000], [20, 2500, 2500, 2800], [30, 3200, 2200, 3200], [None, 2000, 2000, 2000]],
)
# 동점 1위(20번 급여 2500: 1002·1005) > 앞 집계 함수가 하나를 고름
KEEP_TIE_EXAMPLE = sql_example(
    "SELECT MIN(사번) KEEP (DENSE_RANK FIRST ORDER BY 급여) AS 작은사번,\n"
    "       MAX(사번) KEEP (DENSE_RANK FIRST ORDER BY 급여) AS 큰사번\n"
    "FROM 사원\n"
    "WHERE 부서번호 = 20;",
    ("작은사번", "큰사번"),
    [[1002, 1005]],
)

CONCEPT = {
    "tagKey": "group-group-by-having",
    "topicCode": "sql_group_aggregate",
    "sortOrder": 2,
    "title": "GROUP BY와 HAVING",
    "summary": "같은 값을 가진 행끼리 묶어 집계하고, 묶은 결과를 HAVING으로 걸러요",
    "coreMd": (
        "- `GROUP BY 열`은 값이 같은 행끼리 그룹으로 묶고, 집계 함수를 그룹마다 계산해요.\n"
        "- SELECT, HAVING, ORDER BY에는 GROUP BY 열과 집계 함수만 쓰고, 다른 열은 ORA-00979(GROUP BY에 없는 열) 오류예요.\n"
        "- WHERE는 묶기 전에 행을, HAVING은 묶은 뒤에 그룹을 거르고, WHERE에는 집계 함수를 쓸 수 없어요.\n"
        "- 실행 순서는 FROM > WHERE > GROUP BY > HAVING > SELECT > ORDER BY라서 GROUP BY에는 SELECT 별칭을 못 써요.\n"
        "- 부서번호가 NULL인 행들도 한 그룹으로 묶여 결과에 한 행으로 나와요."
    ),
    "detailMd": f"""## 부서마다 따로 계산 — GROUP BY가 필요한 이유 {{#why}}

집계 함수만 쓰면 사원 전체가 한 묶음이라 결과가 1행으로 끝나요. "부서마다 몇 명이고 급여 합계는 얼마인가요?"처럼 묶음을 나눠 계산하려면 GROUP BY를 쓰고, 이 글은 아래 사원 표로 설명해요.

{EMPLOYEE_DEPARTMENT_TABLE}

## 한 줄 정의 — 묶는 GROUP BY, 거르는 HAVING {{#definition}}

| 용어 | 뜻 |
|---|---|
| GROUP BY | 지정한 열의 값이 같은 행끼리 묶어 그룹을 만들고, 집계 함수를 그룹마다 계산하게 하는 절이에요 |
| HAVING | 만들어진 그룹 가운데 조건에 맞는 그룹만 남기는 절이에요 |

{DEPARTMENT_SUMMARY_EXAMPLE.markdown}

| 행 | 처리 |
|---|---|
| 김민수 3000 | 10번 |
| 이지은 2500 | 20번 |
| 박서준 2800 | 20번 |
| 최유나 3200 | 30번 |
| 정하늘 2500 | 20번 |
| 한도윤 2700 | 30번 |
| 오지민 2200 | 30번 |
| 윤서연 2000 | NULL |

여덟 행이 부서번호 값에 따라 네 그룹으로 묶였고, 그룹마다 한 행씩 나왔어요. 아래 부서 표에는 40번 인사부도 있지만, 이 쿼리는 사원 표의 부서번호 값으로만 그룹을 만들어서 사원이 없는 40번은 나오지 않아요.

{DEPARTMENT_TABLE_MD}

## 실행 순서 — WHERE는 행을, HAVING은 그룹을 걸러요 {{#order}}

GROUP BY와 HAVING의 규칙은 대부분 절을 처리하는 순서에서 나와요. 적는 순서는 SELECT가 맨 앞이지만 실제 처리 순서는 아래와 같아요.

| 단계 | 내용 |
|---|---|
| 1 FROM | 사원 표를 읽어요 |
| 2 WHERE | 조건에 맞지 않는 행을 버려요 |
| 3 GROUP BY | 남은 행을 그룹으로 묶어요 |
| 4 HAVING | 조건에 맞지 않는 그룹을 버려요 |
| 5 SELECT | 보여 줄 값을 계산하고 별칭을 붙여요 |
| 6 ORDER BY | 결과를 정렬해요 |

아래 SQL은 WHERE에서 오지민(2200)과 윤서연(2000)을 먼저 빼므로 30번 부서는 2명이 되고, NULL 그룹은 아예 만들어지지 않아요. 남은 10번(1명), 20번(3명), 30번(2명) 가운데 HAVING이 1명뿐인 10번을 버려요.

{WHERE_HAVING_EXAMPLE.markdown}

두 단계를 거친 뒤 남는 사원과 묶음이에요. 김민수는 WHERE를 통과했지만 HAVING이 10번 그룹을 버릴 때 함께 사라져요.

| 행 | 처리 |
|---|---|
| 김민수 10 3000 | 빠짐 |
| 이지은 20 2500 | 20번 |
| 박서준 20 2800 | 20번 |
| 최유나 30 3200 | 30번 |
| 정하늘 20 2500 | 20번 |
| 한도윤 30 2700 | 30번 |
| 오지민 30 2200 | 빠짐 |
| 윤서연 NULL 2000 | 빠짐 |

`COUNT(*)`는 묶은 뒤에야 그룹마다 값이 생기므로 WHERE에는 쓸 수 없어요.

```sql
-- 오류: WHERE 단계에서는 아직 그룹이 없어요 (ORA-00934, 여기서 쓸 수 없는 그룹 함수)
SELECT 부서번호, COUNT(*) FROM 사원 WHERE COUNT(*) >= 2 GROUP BY 부서번호;
```

## SELECT에 쓸 수 있는 것 — GROUP BY 열과 집계 함수 {{#select-rule}}

20번 그룹에는 이지은, 박서준, 정하늘 세 명이 있어요. 그룹 하나가 결과 한 행이 되는데 이름은 세 개라서, SQL은 어느 이름을 보여 줄지 정할 수 없어요.

```sql
-- 오류: 이름이 GROUP BY에 없어요 (ORA-00979, GROUP BY에 없는 열)
SELECT 부서번호, 이름, SUM(급여) FROM 사원 GROUP BY 부서번호;
```

| 절 | 쓸 수 있는 것 | 오류가 나는 예 |
|---|---|---|
| SELECT | GROUP BY 열, 집계 함수 | `SELECT 이름` |
| HAVING | GROUP BY 열, 집계 함수 (SELECT에 없어도 돼요) | `HAVING 급여 > 2000` |
| ORDER BY | GROUP BY 열, 집계 함수, SELECT 별칭 | `ORDER BY 이름` |

반대로 GROUP BY 열을 SELECT에서 빼는 것은 괜찮아서, `SELECT COUNT(*) FROM 사원 GROUP BY 부서번호`는 인원만 네 행으로 보여 줘요. 앞 개념의 오류와 헷갈리지 않게 아래처럼 나눠 두고, 시험은 번호보다 오류가 나는지를 물어요.

| 상황 | 오류 |
|---|---|
| GROUP BY 없이 일반 열과 집계 함수를 섞음 | ORA-00937(한 행으로 묶을 수 없는 그룹 함수) |
| GROUP BY가 있는데 거기에 없는 열을 씀 | ORA-00979(GROUP BY에 없는 열) |

## 자주 헷갈리는 점 — 별칭, NULL 그룹, HAVING만 쓰기 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| GROUP BY에 SELECT 별칭을 쓸 수 있어요 | GROUP BY는 3단계, 별칭은 5단계 SELECT에서 붙어서 ORA-00904(없는 열 이름) 오류예요. ORDER BY는 SELECT 뒤라서 별칭을 쓸 수 있어요 |
| Oracle은 GROUP BY 별칭을 늘 막아요 | 2024년에 나온 Oracle 23ai부터는 허용하지만, 시험은 그 이전 버전 기준이라 오류로 답해요 |
| NULL끼리는 같지 않으니 NULL 행은 그룹이 되지 않아요 | WHERE의 `= NULL`과 달리 GROUP BY는 NULL 행을 모아 그룹 하나로 만들어요. 그래서 10, 20, 30, NULL 네 행이에요 |
| 그룹 수는 `COUNT(DISTINCT 부서번호)`와 같아요 | `COUNT(DISTINCT 부서번호)`는 NULL을 빼고 3이고, 그룹 수는 NULL 그룹까지 세어 4예요 |
| HAVING은 GROUP BY가 있어야만 써요 | GROUP BY 없이 쓰면 테이블 전체가 그룹 하나예요. `HAVING COUNT(*) > 5`는 8이 나오고, `> 10`은 0행이에요 |
| `HAVING 부서번호 = 20`은 오류예요 | GROUP BY 열이라 동작해요. 다만 묶기 전에 걸러도 결과가 같으니 WHERE에 쓰면 처리할 행이 줄어요 |
| 집계 함수는 겹쳐 쓸 수 없어요 | GROUP BY가 있으면 `MAX(SUM(급여))`로 부서 합계 중 최댓값 8100이 1행으로 나와요. 여기에 부서번호를 함께 쓰면 ORA-00937(한 행으로 묶을 수 없는 그룹 함수) 오류예요 |

```sql
-- 오류: GROUP BY 시점에는 별칭 '부서'가 아직 없어요 (ORA-00904, 없는 열 이름)
SELECT 부서번호 AS 부서, COUNT(*) FROM 사원 GROUP BY 부서;
```

집계 함수는 SELECT에 없어도 정렬 기준으로 쓸 수 있어요. 아래 SQL은 화면에 보이지 않는 급여 합계가 큰 순서로 부서를 정렬해요.

{ORDER_BY_AGGREGATE_EXAMPLE.markdown}

## KEEP — 첫째·마지막 행의 값으로 집계 {{#keep}}

"부서마다 가장 먼저 입사한 사람의 급여"는 `MIN(입사일)`로도, `MAX(급여)`로도 구할 수 없어요. Oracle은 집계 함수 뒤에 KEEP을 붙여, 정해 둔 순서로 줄 세운 맨 앞이나 맨 뒤 행만 남기고 집계할 수 있어요.

```sql
-- 문법
집계함수(열) KEEP (DENSE_RANK FIRST ORDER BY 정렬기준)
집계함수(열) KEEP (DENSE_RANK LAST ORDER BY 정렬기준)
```

| 단계 | 내용 |
|---|---|
| 줄 세우기 | 그룹 안의 행을 괄호 안 ORDER BY 기준으로 줄 세워요 |
| 순위 매기기 | DENSE_RANK로 순위를 매겨요. 같은 값에 같은 순위를 주는 순위 함수이고 8단원에서 다뤄요 |
| 남기기 | FIRST면 1위 행만, LAST면 마지막 순위 행만 남겨요 |
| 집계하기 | 앞에 적은 집계 함수를 남은 행에만 계산해요 |

아래 표에서 입사일 순서를 확인하면서 결과를 따라가 보세요.

{EMPLOYEE_HIRE_DATE_TABLE}

{KEEP_FIRST_LAST_EXAMPLE.markdown}

20번 부서의 입사 순서는 이지은(2018-07-16), 박서준(2020-01-06), 정하늘(2022-03-14)이라서, FIRST는 이지은의 2500을, LAST는 정하늘의 2500을 돌려줘요. KEEP 없는 `MAX(급여)`는 그룹에서 가장 큰 박서준의 2800이에요.

30번 부서는 가장 먼저 입사한 최유나가 급여도 가장 커서 3200으로 같고, 가장 늦은 오지민의 2200이 LAST로 나와요. 사원이 한 명뿐인 10번과 NULL 그룹은 세 값이 모두 같아요.

## KEEP의 함정 — 동점, 정렬 방향, DENSE_RANK만 {{#keep-trap}}

20번 부서를 급여 순으로 줄 세우면 이지은(1002)과 정하늘(1005)이 2500으로 함께 1위라서 두 행이 남아요. 이때는 앞에 적은 집계 함수가 하나를 골라서, `MIN(사번)`이면 1002, `MAX(사번)`이면 1005가 나와요.

{KEEP_TIE_EXAMPLE.markdown}

| 헷갈리는 말 | 실제로는 |
|---|---|
| KEEP 앞의 MAX가 그 값이 가장 큰 행을 찾아요 | 순위 기준은 괄호 안 ORDER BY예요. 앞 함수는 남은 행 안에서만 계산해요 |
| 앞 함수를 MIN으로 바꾸면 결과가 달라져요 | 입사일이 모두 다른 공통 데이터에서는 `MIN(급여) KEEP (DENSE_RANK FIRST ORDER BY 입사일)`도 결과가 같아요. MAX는 동점일 때 하나를 고르는 역할이에요 |
| FIRST는 가장 작은 값이에요 | FIRST는 ORDER BY로 줄 세운 맨 앞이에요. `ORDER BY 입사일 DESC`면 30번의 FIRST는 오지민의 2200이에요 |
| KEEP 괄호 안에 RANK를 써도 돼요 | DENSE_RANK만 쓸 수 있어서 RANK는 ORA-02000(DENSE_RANK 키워드 없음) 오류예요 |

```sql
SELECT MAX(급여) KEEP (DENSE_RANK FIRST ORDER BY 입사일 DESC) FROM 사원 WHERE 부서번호 = 30;  -- 2200이 나와요
-- 오류: KEEP 괄호 안에는 DENSE_RANK만 써요 (ORA-02000, DENSE_RANK 키워드 없음)
SELECT MAX(급여) KEEP (RANK FIRST ORDER BY 입사일) FROM 사원;
```

KEEP 뒤에 `OVER (PARTITION BY 부서번호)`를 붙이면 행을 줄이지 않고 사원마다 부서의 값을 함께 보여 주는 윈도우 함수가 돼요. 윈도우 함수는 8단원에서 다뤄요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

WHERE와 HAVING이 함께 있는 SQL의 결과 행 수를 묻는 문제가 가장 많아요. 실행 순서대로 WHERE로 행을 지우고, 남은 행으로 그룹을 만든 뒤 HAVING을 적용하면 돼요.

| 오류 SQL 고르기 | 확인할 것 |
|---|---|
| SELECT, HAVING, ORDER BY | GROUP BY에 없는 일반 열이 있나요 |
| GROUP BY | SELECT 별칭을 썼나요 |
| WHERE | 집계 함수를 썼나요 |
| KEEP | 괄호 안 ORDER BY로 맨 앞 행을 남기고, 여럿이면 앞 집계 함수로 골라요 (2025년 상반기 출제) |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| ORDER BY에는 SELECT에서 붙인 별칭을 쓸 수 있어요 | O | ORDER BY는 SELECT보다 뒤에 처리돼요 |
| `HAVING COUNT(*) > 10`을 GROUP BY 없이 쓰면 오류가 나요 | X | 전체가 그룹 하나가 되고, 조건에 맞지 않아 0행이 나와요 |
| 부서번호로 묶으면 사원이 없는 40번 그룹도 나와요 | X | 사원 표에 있는 값으로만 그룹을 만들어요 |""",
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
        DEPARTMENT_SUMMARY_EXAMPLE.check,
        sql_check("SELECT 부서번호, COUNT(*) AS 인원, SUM(급여) AS 급여합계 FROM 사원 GROUP BY 부서번호 ORDER BY 부서번호",
                  DEPARTMENT_SUMMARY_ROWS, is_ordered=True),
        # SELECT 제한 (GROUP BY 열 생략 가능, 다른 열 오류, 별칭 오류)
        sql_check("SELECT COUNT(*) FROM 사원 GROUP BY 부서번호", [[1], [3], [3], [1]]),
        sql_error_check("SELECT 부서번호, 이름, SUM(급여) FROM 사원 GROUP BY 부서번호", "ORA-00979"),
        sql_error_check("SELECT 부서번호 AS 부서, COUNT(*) FROM 사원 GROUP BY 부서;", "ORA-00904"),
        # WHERE <-> HAVING (결과, WHERE 집계 오류, HAVING 열 제한)
        WHERE_HAVING_EXAMPLE.check,
        # WHERE·HAVING 그림: 남는 사원 5명
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 >= 2500 AND 부서번호 IN "
                  "(SELECT 부서번호 FROM 사원 WHERE 급여 >= 2500 GROUP BY 부서번호 HAVING COUNT(*) >= 2)",
                  [["이지은"], ["박서준"], ["최유나"], ["정하늘"], ["한도윤"]]),
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
        ORDER_BY_AGGREGATE_EXAMPLE.check,
        sql_check("SELECT 부서번호, COUNT(*) AS 인원 FROM 사원 GROUP BY 부서번호 ORDER BY SUM(급여) DESC",
                  HEADCOUNT_BY_SALARY_TOTAL_ROWS, is_ordered=True),
        sql_error_check("SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 ORDER BY 이름", "ORA-00979"),
        # 집계 중첩
        sql_check("SELECT MAX(SUM(급여)) FROM 사원 GROUP BY 부서번호", [[8100]]),
        sql_error_check("SELECT 부서번호, MAX(SUM(급여)) FROM 사원 GROUP BY 부서번호", "ORA-00937"),
        # KEEP (첫·마지막 입사자 급여, 동점은 앞 함수로 선택, 정렬 방향, DENSE_RANK 필수)
        KEEP_FIRST_LAST_EXAMPLE.check,
        KEEP_TIE_EXAMPLE.check,
        sql_check("SELECT 부서번호, MIN(급여) KEEP (DENSE_RANK FIRST ORDER BY 입사일) FROM 사원 GROUP BY 부서번호",
                  [[10, 3000], [20, 2500], [30, 3200], [None, 2000]]),
        sql_check("SELECT MAX(급여) KEEP (DENSE_RANK FIRST ORDER BY 입사일 DESC) FROM 사원 WHERE 부서번호 = 30", [[2200]]),
        sql_error_check("SELECT MAX(급여) KEEP (RANK FIRST ORDER BY 입사일) FROM 사원", "ORA-02000"),
        # 확인 문제 보기·stemSql
        sql_error_check("SELECT 부서번호, 이름 FROM 사원 GROUP BY 부서번호", "ORA-00979"),
        sql_check("SELECT 부서번호, SUM(급여) FROM 사원 GROUP BY 부서번호", [[10, 3000], [20, 7800], [30, 8100], [None, 2000]]),
        sql_check("SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 ORDER BY SUM(급여)",
                  [[None, 1], [10, 1], [20, 3], [30, 3]], is_ordered=True),
        sql_check("SELECT 부서번호, COUNT(*) FROM 사원 WHERE 급여 >= 2500 GROUP BY 부서번호 HAVING COUNT(*) >= 2;", [[20, 3], [30, 2]]),
        sql_check("SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 HAVING COUNT(*) = 1;", [[10, 1], [None, 1]]),
    ],
}
