"""개념: START WITH와 CONNECT BY (9단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_example
from concept_dataset import to_employee_table_md

# 본문·문제의 계산에 쓰는 열 전부 (관리자사번 > 계층, 급여·부서번호 > 조건 예시)
EMPLOYEE_MANAGER_TABLE = to_employee_table_md("사번", "이름", "관리자사번", "급여", "부서번호")

# 본문 SQL·결과 표와 검증 항목의 원본 (결과 순서가 핵심이라 순서까지 검증)
FROM_LEE_SQL = """SELECT 사번, 이름, 관리자사번
FROM 사원
START WITH 사번 = 1002
CONNECT BY PRIOR 사번 = 관리자사번;"""
FROM_LEE_ROWS = [[1002, "이지은", 1001], [1003, "박서준", 1002], [1005, "정하늘", 1002]]

FULL_TREE_SQL = """SELECT 사번, 이름, 관리자사번
FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번;"""
FULL_TREE_ROWS = [
    [1001, "김민수", None], [1002, "이지은", 1001], [1003, "박서준", 1002], [1005, "정하늘", 1002],
    [1004, "최유나", 1001], [1006, "한도윤", 1004], [1007, "오지민", 1004], [1008, "윤서연", 1001],
]

WHERE_DEPARTMENT_SQL = """SELECT 사번, 이름, 부서번호
FROM 사원
WHERE 부서번호 = 20
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번;"""
WHERE_DEPARTMENT_ROWS = [[1002, "이지은", 20], [1003, "박서준", 20], [1005, "정하늘", 20]]

CONNECT_BY_DEPARTMENT_SQL = """SELECT 사번, 이름, 부서번호
FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번 AND 부서번호 = 20;"""
CONNECT_BY_DEPARTMENT_ROWS = [[1001, "김민수", 10], [1002, "이지은", 20], [1003, "박서준", 20], [1005, "정하늘", 20]]

WHERE_EXCLUDE_SQL = """SELECT 이름 FROM 사원
WHERE 사번 <> 1002
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번;"""
WHERE_EXCLUDE_NAMES = ["김민수", "박서준", "정하늘", "최유나", "한도윤", "오지민", "윤서연"]

CONNECT_BY_EXCLUDE_SQL = """SELECT 이름 FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번 AND 사번 <> 1002;"""
CONNECT_BY_EXCLUDE_NAMES = ["김민수", "최유나", "한도윤", "오지민", "윤서연"]

NO_START_WITH_SQL = """SELECT COUNT(*) FROM 사원
CONNECT BY PRIOR 사번 = 관리자사번;"""

MULTI_ROOT_SQL = """SELECT 사번, 이름 FROM 사원
START WITH 부서번호 = 30
CONNECT BY PRIOR 사번 = 관리자사번;"""
MULTI_ROOT_ROWS = [[1004, "최유나"], [1006, "한도윤"], [1007, "오지민"], [1006, "한도윤"], [1007, "오지민"]]

SALARY_CONNECT_BY_SQL = ("SELECT 이름 FROM 사원 START WITH 관리자사번 IS NULL "
                         "CONNECT BY PRIOR 사번 = 관리자사번 AND 급여 >= 2700;")
SALARY_WHERE_SQL = ("SELECT 이름 FROM 사원 WHERE 급여 >= 2700 START WITH 관리자사번 IS NULL "
                    "CONNECT BY PRIOR 사번 = 관리자사번;")
THIRD_ROW_SQL = "SELECT 이름 FROM 사원 START WITH 관리자사번 IS NULL CONNECT BY PRIOR 사번 = 관리자사번;"


def to_name_flow(names):
    """이름 목록 > '김민수 > 박서준 > ...' (결과 순서 한 줄 표시)"""
    return " > ".join(names)


# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
FROM_LEE_EXAMPLE = sql_example(FROM_LEE_SQL, ("사번", "이름", "관리자사번"), FROM_LEE_ROWS)
FULL_TREE_EXAMPLE = sql_example(FULL_TREE_SQL, ("사번", "이름", "관리자사번"), FULL_TREE_ROWS)
WHERE_DEPARTMENT_EXAMPLE = sql_example(WHERE_DEPARTMENT_SQL, ("사번", "이름", "부서번호"), WHERE_DEPARTMENT_ROWS)
CONNECT_BY_DEPARTMENT_EXAMPLE = sql_example(CONNECT_BY_DEPARTMENT_SQL, ("사번", "이름", "부서번호"), CONNECT_BY_DEPARTMENT_ROWS)
MULTI_ROOT_EXAMPLE = sql_example(MULTI_ROOT_SQL, ("사번", "이름"), MULTI_ROOT_ROWS)

CONCEPT = {
    "tagKey": "hierarchy-start-with-connect-by",
    "topicCode": "sql_hierarchy_pivot",
    "sortOrder": 1,
    "title": "START WITH와 CONNECT BY",
    "summary": "시작 행을 고른 뒤 부모와 자식을 잇는 규칙을 따라 표를 나무 모양으로 펼쳐요",
    "coreMd": (
        "- 한 표 안에서 행이 같은 표의 다른 행을 부모로 가리키는 데이터를 계층형 데이터라고 하고, 사원 표의 관리자사번이 그런 열이에요.\n"
        "- `START WITH`로 시작 행을 고르고 `CONNECT BY PRIOR 사번 = 관리자사번`으로 부하를 따라 내려가면, 한 가지를 끝까지 내려간 뒤 옆 가지로 넘어가는 순서로 결과가 나와요.\n"
        "- 처리 순서는 START WITH > CONNECT BY > WHERE라서, WHERE 조건은 걸린 행 하나만 빼지만 CONNECT BY에 붙인 조건은 그 행 아래 가지까지 통째로 잘라 내요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

회사 조직도를 표 하나에 담으려면 사원마다 "내 상사가 누구인지"만 적어 두면 돼요. 공통 예시의 사원 표가 바로 그렇게 생겼는데, 관리자사번 열에는 그 사원의 상사 사번이 들어 있어요.

{EMPLOYEE_MANAGER_TABLE}

급여와 부서번호 열은 뒤에서 조건을 거는 예시에 써요. 이지은의 관리자사번은 1001이므로 상사는 김민수예요. 김민수는 관리자사번이 NULL이라서 위에 아무도 없는 맨 꼭대기 사원이에요. 이처럼 한 표 안에서 어떤 행이 같은 표의 다른 행을 윗사람(부모)으로 가리키는 데이터를 **계층형 데이터**라고 불러요. 사원 표를 관리자별로 정리하면 아래처럼 3단계 조직도가 돼요.

| 관리자 | 직속 부하 |
|---|---|
| 김민수(1001) | 이지은(1002), 최유나(1004), 윤서연(1008) |
| 이지은(1002) | 박서준(1003), 정하늘(1005) |
| 최유나(1004) | 한도윤(1006), 오지민(1007) |

그런데 "김민수 밑에 있는 사람을 모두 찾아 줘"를 일반 SQL로 풀기는 번거로워요. 같은 표를 두 번 불러와 이어 붙이는 셀프 조인을 한 번 하면 직속 부하만 나오고, 부하의 부하까지 보려면 한 번 더 조인해야 해요. 조직이 한 단계 깊어질 때마다 조인을 하나씩 늘려야 하고, 몇 단계까지 있는지 모르면 SQL을 미리 쓸 수도 없어요. Oracle의 계층 쿼리는 이 일을 조인 없이 한 문장으로 해결해요.

## 한 줄 정의 {{#definition}}

계층 쿼리(hierarchical query)는 시작 행을 정한 뒤, 부모와 자식을 잇는 규칙을 따라 자식 행을 차례로 찾아 펼치는 SQL이에요. 시작 행은 `START WITH` 절로 고르고, 잇는 규칙은 `CONNECT BY` 절에 적어요.

```sql
-- 문법
SELECT 열
FROM 테이블
WHERE 조건                           -- 다 펼친 결과에서 행을 걸러요 (생략할 수 있어요)
START WITH 시작 행 조건                 -- 맨 위에서 출발할 행(루트)을 골라요
CONNECT BY PRIOR 사번 = 관리자사번;      -- 부모 행과 자식 행을 잇는 규칙이에요
```

출발하는 시작 행을 루트(root, 뿌리)라고 불러요. 어떤 행 바로 아래에 이어진 행은 그 행의 자식이고, 바로 위의 행은 부모예요. `PRIOR`는 "이미 찾은 앞 행"을 가리키는 표시라서, `PRIOR 사번 = 관리자사번`은 "이미 찾은 행의 사번을 관리자사번으로 가진 행을 다음 행으로 찾으라"는 뜻이 돼요. 그래서 이 규칙은 상사에서 부하 쪽으로 내려가요. PRIOR를 어느 열에 붙이느냐에 따라 방향이 바뀌는데, 이 부분은 다음 개념에서 따로 다뤄요.

## 예시: 이지은 팀부터 펼치기 {{#example}}

작은 예시부터 보면, 이지은(1002)에서 출발해 부하를 따라 내려가는 SQL은 아래와 같아요.

{FROM_LEE_EXAMPLE.markdown}

Oracle은 START WITH 조건에 맞는 이지은을 첫 행으로 꺼내요. 그다음 CONNECT BY 규칙에 따라 관리자사번이 1002인 행을 찾아 박서준과 정하늘을 이어 붙여요. 두 사람의 사번을 관리자사번으로 가진 행은 없으므로 여기서 펼치기가 끝나요.

## 예시: 전체 조직도와 깊이 우선 순서 {{#depth-first}}

이번에는 맨 꼭대기 사원부터 출발해요. 관리자사번이 NULL인 행은 김민수 하나뿐이라서 `START WITH 관리자사번 IS NULL`로 루트를 고를 수 있어요.

{FULL_TREE_EXAMPLE.markdown}

결과 순서를 잘 보면, 김민수 다음에 이지은이 나오고 곧바로 이지은의 부하인 박서준과 정하늘이 이어져요. 최유나는 이지은 아래를 모두 훑은 뒤에야 나와요. 이렇게 한 가지(branch)를 끝까지 내려간 다음 옆 가지로 넘어가는 순서를 **깊이 우선(depth-first)** 순서라고 불러요. 같은 단계끼리 먼저 모아서 김민수, 이지은, 최유나, 윤서연, 박서준 순으로 보여 주는 방식이 아니라는 점이 시험에 자주 나와요.

같은 관리자 밑에 있는 형제 행끼리는 어떤 순서로 나올지 정해져 있지 않아요. 이 글의 예시는 저장된 순서인 사번 순으로 나왔고, 형제의 순서를 직접 정하는 `ORDER SIBLINGS BY`는 세 번째 개념에서 다뤄요.

## 처리 순서 {{#order}}

계층 쿼리는 적힌 순서와 상관없이 START WITH > CONNECT BY > WHERE 순서로 처리돼요. 루트를 고르고, 규칙을 따라 트리(나무 모양 구조)를 끝까지 펼친 다음, 마지막에 WHERE 조건으로 행을 걸러요.

{WHERE_DEPARTMENT_EXAMPLE.markdown}

김민수는 부서번호가 10이라서 마지막 WHERE 단계에서 빠졌어요. 그런데 김민수를 거쳐서 찾은 이지은, 박서준, 정하늘은 그대로 남아 있어요. WHERE는 트리를 다 펼친 뒤에 행을 하나씩 거르기만 하므로, 부모 행이 빠져도 자식 행은 영향을 받지 않아요.

FROM 절에서 여러 표를 이어 붙이는 조인을 함께 쓴 경우에는, 조인으로 표를 먼저 합친 다음 위 순서대로 계층을 펼쳐요.

## 자주 헷갈리는 점 {{#confusing}}

**WHERE 조건은 그 행만 빼고, CONNECT BY 조건은 그 가지 전체를 빼요.** 결과에서 이지은(1002)을 빼고 싶을 때 조건을 어디에 두느냐에 따라 결과가 달라져요.

```sql
{WHERE_EXCLUDE_SQL}

{CONNECT_BY_EXCLUDE_SQL}
```

| 조건 위치 | 결과 (나온 순서대로) | 행 수 |
|---|---|---|
| WHERE 절 | {to_name_flow(WHERE_EXCLUDE_NAMES)} | {len(WHERE_EXCLUDE_NAMES)}행 |
| CONNECT BY 절 | {to_name_flow(CONNECT_BY_EXCLUDE_NAMES)} | {len(CONNECT_BY_EXCLUDE_NAMES)}행 |

WHERE에 둔 쪽은 트리를 다 펼친 뒤 이지은 한 행만 지우므로, 부하인 박서준과 정하늘은 남아요. CONNECT BY에 둔 조건은 "다음 행을 이어 붙일 때 이 조건도 맞아야 한다"는 뜻이 돼요. 이지은은 김민수 아래에 이어 붙는 순간 조건에 걸려 트리에 들어오지 못하고, 이지은을 거쳐야만 닿는 박서준과 정하늘도 함께 사라져요.

**루트 행은 CONNECT BY 조건으로 걸러지지 않아요.** CONNECT BY 조건은 자식을 이어 붙일 때만 검사하므로, START WITH로 고른 루트에는 적용되지 않아요. 앞의 처리 순서 예시에서 WHERE에 두었던 `부서번호 = 20`을 이번에는 CONNECT BY에 옮겨 보면 결과가 이렇게 달라져요.

{CONNECT_BY_DEPARTMENT_EXAMPLE.markdown}

김민수는 부서번호가 10인데도 루트라서 남았어요. 최유나와 윤서연은 부서 20이 아니라서 김민수 아래에 이어 붙지 못했고, 그 바람에 최유나의 부하인 한도윤과 오지민도 함께 빠졌어요.

**START WITH를 빼면 모든 행이 루트가 돼요.** START WITH 절은 생략할 수 있지만, 그러면 8명 모두가 각자 루트가 되어 자기 아래 트리를 펼쳐요. 김민수의 트리가 8행, 이지은과 최유나의 트리가 3행씩이고, 부하가 없는 나머지 5명은 자기 혼자 1행씩이라서 결과는 모두 19행이에요(8 + 3 + 3 + 5). 아래 SQL의 `COUNT(*)`는 결과 행 수를 세는 함수이고, 그룹 함수 단원에서 자세히 다뤄요.

```sql
{NO_START_WITH_SQL}  -- 19가 나와요
```

**START WITH 조건에 맞는 행이 여러 개면 트리도 여러 개 생겨요.** START WITH는 조건에 맞는 행을 모두 루트로 삼고, 루트마다 트리를 따로 하나씩 펼쳐요. `START WITH 부서번호 = 30`이면 위 표에서 부서번호가 30인 최유나, 한도윤, 오지민 세 명이 각각 루트가 돼요. 최유나의 트리는 최유나와 부하 한도윤, 오지민으로 3행이고, 한도윤과 오지민은 자기 자신이 루트인 트리를 1행씩 따로 만들어요. 그래서 한도윤과 오지민이 두 번씩 나와 모두 5행이에요.

{MULTI_ROOT_EXAMPLE.markdown}

**START WITH와 CONNECT BY는 Oracle 문법이에요.** SQL Server에는 이 문법이 없고, 같은 일을 재귀 CTE라는 다른 문법으로 해요. 시험에서는 "SQL Server는 CONNECT BY 대신 재귀 CTE를 쓴다"는 정도만 알아 두면 돼요.

```sql
-- 문법 (SQL Server 재귀 CTE, 참고용)
WITH 조직 (사번, 이름) AS (
    SELECT 사번, 이름 FROM 사원 WHERE 관리자사번 IS NULL       -- 시작 행을 골라요 (START WITH 역할)
    UNION ALL
    SELECT 사원.사번, 사원.이름
    FROM 사원 JOIN 조직 ON 사원.관리자사번 = 조직.사번         -- 이미 찾은 행의 부하를 찾아요 (CONNECT BY 역할)
)
SELECT 사번, 이름 FROM 조직;
```

`WITH 이름 AS (...)`는 괄호 안 SELECT 결과에 이름을 붙여 표처럼 쓰는 문법이에요. UNION ALL은 두 SELECT의 결과를 위아래로 이어 붙이는 연산자이고, 아래쪽 SELECT가 이름 붙인 결과(조직)를 다시 불러서 부하를 한 단계씩 더 찾아요. 이 방식은 결과가 깊이 우선 순서로 나온다는 보장이 없어요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

사원 표 같은 예시를 주고 계층 쿼리의 결과 행 수나 몇 번째 행이 누구인지를 묻는 문제가 가장 많아요. 행 수를 셀 때는 조건이 WHERE에 있는지 CONNECT BY에 있는지부터 확인하고, CONNECT BY 조건이라면 걸린 행 아래의 가지까지 함께 지우고 세면 돼요. 순서를 물으면 한 가지를 끝까지 내려간 뒤 옆으로 가는 깊이 우선 순서로 따라가요. 그 밖에 처리 순서(START WITH > CONNECT BY > WHERE)와 START WITH를 생략했을 때의 결과도 가끔 나와요.""",
    "checkQuestions": [
        question(1, "계층 쿼리에서 트리를 펼치기 시작할 행(루트)을 고르는 절은 무엇인가요?", "definition",
                 "START WITH 절에 맞는 행이 루트가 되고, CONNECT BY 절이 그 아래로 이어 붙일 규칙을 정해요.",
                 [choice("A", "CONNECT BY", rationale="부모 행과 자식 행을 잇는 규칙을 적는 절이에요."),
                  choice("B", "START WITH", True, "이 절의 조건에 맞는 행에서 펼치기가 시작돼요."),
                  choice("C", "PRIOR", rationale="절이 아니라 CONNECT BY 안에서 이미 찾은 행을 가리키는 표시예요."),
                  choice("D", "WHERE", rationale="트리를 다 펼친 뒤 행을 거르는 절이에요.")]),
        question(2, "Oracle 계층 쿼리의 처리 순서로 알맞은 것은 무엇인가요? (조인은 없다고 가정해요)", "order",
                 "루트를 고르고(START WITH), 규칙대로 트리를 펼친 뒤(CONNECT BY), 마지막에 WHERE로 행을 걸러요.",
                 [choice("A", "WHERE > START WITH > CONNECT BY", rationale="WHERE는 트리를 다 펼친 뒤에 적용돼요."),
                  choice("B", "CONNECT BY > START WITH > WHERE", rationale="루트가 정해져야 펼칠 수 있으므로 START WITH가 먼저예요."),
                  choice("C", "START WITH > CONNECT BY > WHERE", True, "루트 선택, 펼치기, 거르기 순서예요."),
                  choice("D", "START WITH > WHERE > CONNECT BY", rationale="WHERE가 펼치기 전에 적용된다면 부모 행이 빠질 때 자식 행도 빠져야 하는데, 실제로는 그렇지 않아요.")]),
        question(3, "공통 예시의 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_MANAGER_TABLE, "confusing",
                 "CONNECT BY에 붙인 조건은 이지은을 트리에 들이지 않으므로, 이지은 아래의 박서준과 정하늘도 함께 빠져요. 김민수, 최유나, 한도윤, 오지민, 윤서연 5행이 남아요.",
                 [choice("A", "5행", True, "이지은 가지 3명이 통째로 빠져요."),
                  choice("B", "7행", rationale="WHERE 절에 조건을 둔 경우의 행 수예요."),
                  choice("C", "8행", rationale="조건이 이지은을 막으므로 8명이 모두 나올 수 없어요."),
                  choice("D", "3행", rationale="잘리는 것은 이지은 가지뿐이고, 최유나 가지는 그대로 남아요.")],
                 stem_sql=CONNECT_BY_EXCLUDE_SQL),
        question(4, "아래 사원 표에 다음 SQL을 실행했을 때 결과에 나오지 않는 사원은 누구인가요?\n\n" + EMPLOYEE_MANAGER_TABLE, "confusing",
                 "박서준은 급여가 2800이지만, 상사 이지은(2500)이 조건에 걸려 트리에 들어오지 못했기 때문에 함께 빠져요. 같은 조건을 WHERE에 두었다면 박서준은 나왔을 거예요.",
                 [choice("A", "김민수", rationale="루트는 CONNECT BY 조건과 상관없이 결과에 들어가요."),
                  choice("B", "최유나", rationale="급여 3200이라 조건을 만족해서 김민수 아래에 이어져요."),
                  choice("C", "한도윤", rationale="급여 2700이고 상사 최유나도 남아 있어서 이어져요."),
                  choice("D", "박서준", True, "상사 이지은의 가지가 잘리면서 함께 빠져요.")],
                 stem_sql=SALARY_CONNECT_BY_SQL),
        question(5, "공통 예시의 사원 표에 다음 SQL을 실행하면 세 번째 행에 나오는 사원은 누구인가요?\n\n" + EMPLOYEE_MANAGER_TABLE, "depth-first",
                 "계층 쿼리는 깊이 우선 순서로 결과를 내므로 김민수, 이지은 다음에 이지은의 부하 박서준이 나와요. 최유나는 이지은 아래를 모두 훑은 뒤에 나와요.",
                 [choice("A", "최유나", rationale="같은 단계를 먼저 모으는 순서로 본 답이에요."),
                  choice("B", "박서준", True, "이지은 가지를 끝까지 내려가므로 세 번째가 박서준이에요."),
                  choice("C", "이지은", rationale="이지은은 두 번째 행이에요."),
                  choice("D", "윤서연", rationale="윤서연은 김민수의 마지막 가지라서 맨 끝에 나와요.")],
                 stem_sql=THIRD_ROW_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        FROM_LEE_EXAMPLE.check,
        FULL_TREE_EXAMPLE.check,
        WHERE_DEPARTMENT_EXAMPLE.check,
        sql_check(WHERE_EXCLUDE_SQL, [[name] for name in WHERE_EXCLUDE_NAMES], is_ordered=True),
        sql_check(CONNECT_BY_EXCLUDE_SQL, [[name] for name in CONNECT_BY_EXCLUDE_NAMES], is_ordered=True),
        CONNECT_BY_DEPARTMENT_EXAMPLE.check,
        sql_check(NO_START_WITH_SQL, [[19]]),
        MULTI_ROOT_EXAMPLE.check,
        # SQL Server 재귀 CTE 블록 (같은 문법이 Oracle 에서도 돌아서 펼친 행 집합만 확인)
        sql_check("WITH 조직 (사번, 이름) AS (SELECT 사번, 이름 FROM 사원 WHERE 관리자사번 IS NULL"
                  " UNION ALL SELECT 사원.사번, 사원.이름 FROM 사원 JOIN 조직 ON 사원.관리자사번 = 조직.사번)"
                  " SELECT 사번, 이름 FROM 조직",
                  [[row[0], row[1]] for row in FULL_TREE_ROWS]),
        # 확인 문제 4: CONNECT BY 조건(3명) <-> WHERE 조건(박서준 포함 4명)
        sql_check(SALARY_CONNECT_BY_SQL, [["김민수"], ["최유나"], ["한도윤"]], is_ordered=True),
        sql_check(SALARY_WHERE_SQL, [["김민수"], ["박서준"], ["최유나"], ["한도윤"]], is_ordered=True),
        sql_check(THIRD_ROW_SQL, [[row[1]] for row in FULL_TREE_ROWS], is_ordered=True),
    ],
}
