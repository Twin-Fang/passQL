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
        "- 계층 쿼리는 `START WITH`로 시작 행(루트)을 고르고 `CONNECT BY` 규칙으로 자식 행을 찾아 펼쳐요.\n"
        "- `CONNECT BY PRIOR 사번 = 관리자사번`은 이미 찾은 행의 부하를 찾아 아래로 내려가요.\n"
        "- 결과는 한 가지를 끝까지 내려간 뒤 옆 가지로 넘어가는 깊이 우선 순서로 나와요.\n"
        "- 처리 순서는 START WITH > CONNECT BY > WHERE이고, 루트는 CONNECT BY 조건으로 걸러지지 않아요.\n"
        "- WHERE 조건은 걸린 행 하나만 빼고, CONNECT BY에 붙인 조건은 그 아래 가지까지 통째로 잘라요."
    ),
    "detailMd": f"""## 표 안의 조직도 — 왜 계층 쿼리가 필요할까요 {{#why}}

사원 표의 관리자사번 열에는 그 사원의 상사 사번이 들어 있어요. 급여와 부서번호 열은 뒤에서 조건을 거는 예시에 써요.

{EMPLOYEE_MANAGER_TABLE}

| 용어 | 뜻 |
|---|---|
| 계층형 데이터 | 한 표 안에서 어떤 행이 같은 표의 다른 행을 윗사람(부모)으로 가리키는 데이터예요. 이지은의 관리자사번 1001은 상사 김민수를 가리켜요 |
| 맨 꼭대기 행 | 관리자사번이 NULL이라서 위에 아무도 없는 행이에요. 사원 표에서는 김민수 한 명이에요 |

| 관리자 | 직속 부하 |
|---|---|
| 김민수(1001) | 이지은(1002), 최유나(1004), 윤서연(1008) |
| 이지은(1002) | 박서준(1003), 정하늘(1005) |
| 최유나(1004) | 한도윤(1006), 오지민(1007) |

같은 표를 두 번 불러와 잇는 셀프 조인은 한 번에 한 단계만 내려가서, 조직이 깊어질 때마다 조인을 하나씩 늘려야 해요. 몇 단계까지 있는지 모르면 SQL을 미리 쓸 수도 없어서, Oracle은 이 일을 조인 없이 한 문장으로 하는 계층 쿼리를 제공해요.

## 한 줄 정의 — 시작 행을 고르고 규칙대로 펼쳐요 {{#definition}}

계층 쿼리(hierarchical query)는 시작 행을 정한 뒤, 부모와 자식을 잇는 규칙을 따라 자식 행을 차례로 찾아 펼치는 SQL이에요.

```sql
-- 문법
SELECT 열
FROM 테이블
WHERE 조건                           -- 다 펼친 결과에서 행을 걸러요 (생략할 수 있어요)
START WITH 시작 행 조건                 -- 맨 위에서 출발할 행(루트)을 골라요
CONNECT BY PRIOR 사번 = 관리자사번;      -- 부모 행과 자식 행을 잇는 규칙이에요
```

| 용어 | 뜻 |
|---|---|
| START WITH | 맨 위에서 출발할 행을 고르는 절이에요 |
| CONNECT BY | 부모 행과 자식 행을 잇는 규칙을 적는 절이에요 |
| 루트 (root) | START WITH로 고른 시작 행이에요. 나무의 뿌리처럼 트리가 여기서 시작돼요 |
| 부모와 자식 | 어떤 행 바로 위에 이어진 행이 부모이고, 바로 아래에 이어진 행이 자식이에요 |
| PRIOR | "이미 찾은 앞 행"을 가리키는 표시예요. `PRIOR 사번 = 관리자사번`은 이미 찾은 행의 사번을 관리자사번으로 가진 행, 곧 부하를 다음 행으로 찾아요 |

그래서 `PRIOR 사번 = 관리자사번`은 상사에서 부하 쪽으로 내려가요. PRIOR를 어느 열에 붙이느냐에 따라 방향이 바뀌는 규칙은 다음 개념에서 따로 다뤄요.

## 펼치는 순서 — 한 가지를 끝까지 내려간 뒤 옆으로 {{#depth-first}}

이지은(1002)에서 출발하면 이지은을 첫 행으로 꺼내고, 관리자사번이 1002인 박서준과 정하늘을 이어 붙여요. 두 사람을 상사로 둔 행은 없으므로 여기서 펼치기가 끝나요.

{FROM_LEE_EXAMPLE.markdown}

맨 꼭대기부터 펼칠 때는 관리자사번이 NULL인 행이 김민수 하나뿐이라서 `START WITH 관리자사번 IS NULL`로 루트를 골라요.

{FULL_TREE_EXAMPLE.markdown}

| 순서 방식 | 김민수 다음 다섯 행 | 계층 쿼리는 |
|---|---|---|
| 깊이 우선 (depth-first) | 이지은, 박서준, 정하늘, 최유나, 한도윤 | 이 순서로 나와요 |
| 같은 단계끼리 먼저 | 이지은, 최유나, 윤서연, 박서준, 정하늘 | 이 순서로 나오지 않아요 |

한 가지(branch)를 끝까지 내려간 다음 옆 가지로 넘어가므로, 최유나는 이지은 아래를 모두 훑은 뒤에야 나와요.

같은 관리자 밑 형제끼리의 순서는 정해져 있지 않아서, 이 예시는 저장된 사번 순으로 나왔어요. 형제 순서를 직접 정하는 `ORDER SIBLINGS BY`는 세 번째 개념에서 다뤄요.

## 처리 순서 — START WITH > CONNECT BY > WHERE {{#order}}

계층 쿼리는 적힌 순서와 상관없이 아래 순서로 처리돼요.

| 단계 | 내용 |
|---|---|
| 조인 (있을 때) | FROM 절에서 여러 표를 이어 붙이는 조인이 있으면 표를 먼저 합쳐요 |
| START WITH | 루트를 골라요 |
| CONNECT BY | 규칙을 따라 트리(나무 모양 구조)를 끝까지 펼쳐요 |
| WHERE | 다 펼친 결과에서 행을 하나씩 걸러요 |

{WHERE_DEPARTMENT_EXAMPLE.markdown}

부서번호가 10인 김민수는 마지막 WHERE 단계에서 빠졌지만, 김민수를 거쳐 찾은 이지은, 박서준, 정하늘은 그대로 남았어요. WHERE는 트리를 다 펼친 뒤에 행을 거르기만 하므로 부모 행이 빠져도 자식 행은 영향을 받지 않아요.

## 자주 헷갈리는 점 — 조건을 어디에 두느냐 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| 조건을 WHERE에 두든 CONNECT BY에 두든 같은 행이 빠져요 | WHERE는 걸린 행 하나만 빼고, CONNECT BY 조건은 그 행 아래 가지까지 통째로 잘라요 |
| 부모 행이 WHERE에서 빠지면 자식 행도 함께 빠져요 | WHERE는 다 펼친 뒤에 행마다 거르므로 자식 행은 그대로 남아요 |
| CONNECT BY 조건에 맞지 않으면 루트도 빠져요 | CONNECT BY 조건은 자식을 이어 붙일 때만 검사해서, START WITH로 고른 루트는 항상 남아요 |
| 계층 쿼리는 같은 단계끼리 모아서 보여 줘요 | 한 가지를 끝까지 내려간 뒤 옆 가지로 가는 깊이 우선 순서예요 |

이지은(1002)을 빼는 같은 조건을 두 자리에 각각 두면 결과가 이렇게 달라져요.

```sql
{WHERE_EXCLUDE_SQL}

{CONNECT_BY_EXCLUDE_SQL}
```

| 조건 위치 | 결과 (나온 순서대로) | 행 수 |
|---|---|---|
| WHERE 절 | {to_name_flow(WHERE_EXCLUDE_NAMES)} | {len(WHERE_EXCLUDE_NAMES)}행 |
| CONNECT BY 절 | {to_name_flow(CONNECT_BY_EXCLUDE_NAMES)} | {len(CONNECT_BY_EXCLUDE_NAMES)}행 |

CONNECT BY에 둔 조건은 "다음 행을 이어 붙일 때 이 조건도 맞아야 한다"는 뜻이에요. 이지은은 김민수 아래에 붙는 순간 조건에 걸려 트리에 들어오지 못하고, 이지은을 거쳐야만 닿는 박서준과 정하늘도 함께 사라져요.

처리 순서 예시의 `부서번호 = 20`을 CONNECT BY로 옮기면, 부서 10인 김민수는 루트라서 그대로 남아요. 최유나와 윤서연은 김민수 아래에 붙지 못했고, 그 바람에 최유나의 부하인 한도윤과 오지민도 함께 빠졌어요.

{CONNECT_BY_DEPARTMENT_EXAMPLE.markdown}

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| CONNECT BY 조건은 루트 행에도 똑같이 검사돼요 | X | 자식을 이어 붙일 때만 검사하므로 루트는 조건과 상관없이 남아요 |
| WHERE 절에 `부서번호 = 20`을 두면 박서준은 결과에 남아요 | O | WHERE는 다 펼친 뒤 행마다 거르고, 박서준은 부서 20이에요 |

## 루트가 여럿일 때 — START WITH를 빼거나 여러 행이 맞으면 {{#roots}}

START WITH는 조건에 맞는 행을 모두 루트로 삼고, 루트마다 트리를 따로 하나씩 펼쳐요.

| 경우 | 루트 | 결과 행 수 |
|---|---|---|
| START WITH를 뺌 | 8명 모두가 각자 루트 | 김민수 트리 8 + 이지은 트리 3 + 최유나 트리 3 + 부하 없는 5명 1씩 = 19행 |
| `START WITH 부서번호 = 30` | 최유나, 한도윤, 오지민 | 최유나 트리 3 + 한도윤 1 + 오지민 1 = 5행 |

START WITH 절은 생략할 수 있지만, 그러면 모든 행이 루트가 돼요. 아래 SQL의 `COUNT(*)`는 결과 행 수를 세는 함수이고, 그룹 함수 단원에서 자세히 다뤄요.

```sql
{NO_START_WITH_SQL}  -- 19가 나와요
```

부서 30이 루트 조건이면 한도윤과 오지민은 최유나 트리에서 한 번, 자기 자신이 루트인 트리에서 한 번 나와서 두 번씩 보여요.

{MULTI_ROOT_EXAMPLE.markdown}

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| START WITH 절을 빼면 SQL을 실행할 수 없어요 | X | 생략할 수 있고, 그러면 모든 행이 각자 루트가 돼요 |

## 다른 DBMS — SQL Server는 재귀 CTE {{#sql-server}}

START WITH와 CONNECT BY는 Oracle 문법이라서 SQL Server에는 없어요. 시험에서는 "SQL Server는 CONNECT BY 대신 재귀 CTE를 쓴다"는 정도만 알아 두면 돼요.

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

| 용어 | 뜻 |
|---|---|
| WITH 이름 AS (...) | 괄호 안 SELECT 결과에 이름을 붙여 표처럼 쓰는 문법이에요 |
| UNION ALL | 두 SELECT의 결과를 위아래로 이어 붙이는 연산자예요. 아래쪽 SELECT가 이름 붙인 결과(조직)를 다시 불러 부하를 한 단계씩 더 찾아요 |

재귀 CTE는 펼친 행은 같아도, 결과가 깊이 우선 순서로 나온다는 보장이 없어요.

## 시험에서는 이렇게 나와요 — 행 수와 몇 번째 행 {{#exam-point}}

사원 표 같은 예시를 주고 결과 행 수나 몇 번째 행이 누구인지를 묻는 문제가 가장 많아요.

| 묻는 것 | 푸는 법 |
|---|---|
| 결과 행 수 | 조건이 WHERE에 있는지 CONNECT BY에 있는지부터 봐요. CONNECT BY라면 걸린 행 아래 가지까지 지우고 세요 |
| 몇 번째 행이 누구인가 | 한 가지를 끝까지 내려간 뒤 옆으로 가는 깊이 우선 순서로 따라가요 |
| 처리 순서 | START WITH > CONNECT BY > WHERE예요 |
| START WITH를 뺀 결과 | 모든 행이 루트가 되어 트리가 여러 개 나와요 |""",
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
