"""개념: 계층 쿼리 함수와 정렬 (9단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md, to_markdown_table

# 본문·문제의 계산에 쓰는 열 전부 (직급 > 여러 루트 예시, 급여 > 형제 정렬 예시)
EMPLOYEE_MANAGER_SALARY_TABLE = to_employee_table_md("사번", "이름", "직급", "관리자사번", "급여")

# 순환 예시 준비: 김민수(1001)의 관리자를 박서준(1003)으로 바꿔 1001 > 1002 > 1003 > 1001 고리를 만듦
MAKE_CYCLE_SQL = "UPDATE 사원 SET 관리자사번 = 1003 WHERE 사번 = 1001;"

# 본문 SQL·결과 표와 검증 항목의 원본 (결과 순서까지 검증)
PATH_ROOT_LEAF_SQL = """SELECT LEVEL, 이름,
       SYS_CONNECT_BY_PATH(이름, '/') AS 경로,
       CONNECT_BY_ROOT 이름 AS 루트,
       CONNECT_BY_ISLEAF AS 잎
FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번;"""
PATH_ROOT_LEAF_ROWS = [
    [1, "김민수", "/김민수", "김민수", 0],
    [2, "이지은", "/김민수/이지은", "김민수", 0],
    [3, "박서준", "/김민수/이지은/박서준", "김민수", 1],
    [3, "정하늘", "/김민수/이지은/정하늘", "김민수", 1],
    [2, "최유나", "/김민수/최유나", "김민수", 0],
    [3, "한도윤", "/김민수/최유나/한도윤", "김민수", 1],
    [3, "오지민", "/김민수/최유나/오지민", "김민수", 1],
    [2, "윤서연", "/김민수/윤서연", "김민수", 1],
]

MULTI_ROOT_SQL = """SELECT 이름, CONNECT_BY_ROOT 이름 AS 팀장
FROM 사원
START WITH 직급 IN ('과장', '부장')
CONNECT BY PRIOR 사번 = 관리자사번;"""
MULTI_ROOT_ROWS = [["이지은", "이지은"], ["박서준", "이지은"], ["정하늘", "이지은"],
                   ["최유나", "최유나"], ["한도윤", "최유나"], ["오지민", "최유나"]]

UPWARD_FUNCTIONS_SQL = """SELECT 이름, SYS_CONNECT_BY_PATH(이름, '/') AS 경로,
       CONNECT_BY_ROOT 이름 AS 루트, CONNECT_BY_ISLEAF AS 잎
FROM 사원
START WITH 사번 = 1007
CONNECT BY PRIOR 관리자사번 = 사번;"""
UPWARD_FUNCTIONS_ROWS = [["오지민", "/오지민", "오지민", 0],
                         ["최유나", "/오지민/최유나", "오지민", 0],
                         ["김민수", "/오지민/최유나/김민수", "오지민", 1]]

LEAF_CONNECT_BY_LEVEL_SQL = """SELECT LEVEL, 이름, CONNECT_BY_ISLEAF AS 잎
FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번 AND LEVEL <= 2;"""
LEAF_CONNECT_BY_LEVEL_ROWS = [[1, "김민수", 0], [2, "이지은", 1], [2, "최유나", 1], [2, "윤서연", 1]]

LEAF_WHERE_LEVEL_SQL = """SELECT LEVEL, 이름, CONNECT_BY_ISLEAF AS 잎
FROM 사원
WHERE LEVEL <= 2
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번;"""
PATH_WITH_WHERE_SQL = """SELECT 이름, SYS_CONNECT_BY_PATH(이름, '/') AS 경로
FROM 사원
WHERE 사번 = 1006
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번;"""
PATH_WITH_WHERE_ROWS = [["한도윤", "/김민수/최유나/한도윤"]]

LEAF_WHERE_LEVEL_ROWS = [[1, "김민수", 0], [2, "이지은", 0], [2, "최유나", 0], [2, "윤서연", 1]]

CYCLE_FLAG_SQL = """SELECT LEVEL, 이름, CONNECT_BY_ISCYCLE AS 순환
FROM 사원
START WITH 사번 = 1001
CONNECT BY NOCYCLE PRIOR 사번 = 관리자사번;"""
CYCLE_FLAG_ROWS = [
    [1, "김민수", 0], [2, "이지은", 0], [3, "박서준", 1], [3, "정하늘", 0],
    [2, "최유나", 0], [3, "한도윤", 0], [3, "오지민", 0], [2, "윤서연", 0],
]
CYCLE_FLAG_WITHOUT_NOCYCLE_SQL = """SELECT 이름, CONNECT_BY_ISCYCLE
FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번;"""

ORDER_SIBLINGS_SQL = """SELECT LEVEL, 이름, 급여
FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번
ORDER SIBLINGS BY 급여 DESC;"""
ORDER_SIBLINGS_ROWS = [
    [1, "김민수", 3000], [2, "최유나", 3200], [3, "한도윤", 2700], [3, "오지민", 2200],
    [2, "이지은", 2500], [3, "박서준", 2800], [3, "정하늘", 2500], [2, "윤서연", 2000],
]

ORDER_BY_SQL = """SELECT LEVEL, 이름, 급여
FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번
ORDER BY 급여 DESC;"""
# 급여 2500 동점(이지은·정하늘)은 순서가 정해지지 않아 순서 없이 검증
ORDER_BY_ROWS = [
    [2, "최유나", 3200], [1, "김민수", 3000], [3, "박서준", 2800], [3, "한도윤", 2700],
    [2, "이지은", 2500], [3, "정하늘", 2500], [3, "오지민", 2200], [2, "윤서연", 2000],
]

ORDER_SIBLINGS_WITHOUT_HIERARCHY_SQL = "SELECT 이름 FROM 사원 ORDER SIBLINGS BY 이름;"

PATH_STEM_SQL = ("SELECT SYS_CONNECT_BY_PATH(이름, '/') FROM 사원 WHERE 사번 = 1005 "
                 "START WITH 관리자사번 IS NULL CONNECT BY PRIOR 사번 = 관리자사번;")
SIBLINGS_STEM_SQL = ("SELECT 이름 FROM 사원 START WITH 관리자사번 IS NULL "
                     "CONNECT BY PRIOR 사번 = 관리자사번 ORDER SIBLINGS BY 급여 DESC;")
LEAF_COUNT_STEM_SQL = ("SELECT COUNT(*) FROM 사원 WHERE CONNECT_BY_ISLEAF = 1 START WITH 관리자사번 IS NULL "
                       "CONNECT BY PRIOR 사번 = 관리자사번 AND LEVEL <= 2;")
CYCLE_STEM_SQL = ("SELECT 이름 FROM 사원 WHERE CONNECT_BY_ISCYCLE = 1 START WITH 사번 = 1001 "
                  "CONNECT BY NOCYCLE PRIOR 사번 = 관리자사번;")

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
PATH_ROOT_LEAF_EXAMPLE = sql_example(PATH_ROOT_LEAF_SQL, ("LEVEL", "이름", "경로", "루트", "잎"), PATH_ROOT_LEAF_ROWS)
MULTI_ROOT_EXAMPLE = sql_example(MULTI_ROOT_SQL, ("이름", "팀장"), MULTI_ROOT_ROWS)
ORDER_SIBLINGS_EXAMPLE = sql_example(ORDER_SIBLINGS_SQL, ("LEVEL", "이름", "급여"), ORDER_SIBLINGS_ROWS)
ORDER_BY_EXAMPLE = sql_example(ORDER_BY_SQL, ("LEVEL", "이름", "급여"), ORDER_BY_ROWS, is_ordered=False)
UPWARD_FUNCTIONS_EXAMPLE = sql_example(UPWARD_FUNCTIONS_SQL, ("이름", "경로", "루트", "잎"), UPWARD_FUNCTIONS_ROWS)
LEAF_CONNECT_BY_LEVEL_EXAMPLE = sql_example(LEAF_CONNECT_BY_LEVEL_SQL, ("LEVEL", "이름", "잎"), LEAF_CONNECT_BY_LEVEL_ROWS)
LEAF_WHERE_LEVEL_EXAMPLE = sql_example(LEAF_WHERE_LEVEL_SQL, ("LEVEL", "이름", "잎"), LEAF_WHERE_LEVEL_ROWS)
PATH_WITH_WHERE_EXAMPLE = sql_example(PATH_WITH_WHERE_SQL, ("이름", "경로"), PATH_WITH_WHERE_ROWS, is_ordered=False)

CONCEPT = {
    "tagKey": "hierarchy-functions",
    "topicCode": "sql_hierarchy_pivot",
    "sortOrder": 3,
    "title": "계층 쿼리 함수와 정렬",
    "summary": "경로·루트·잎을 알려 주는 함수와, 계층 모양을 지키는 정렬을 다뤄요",
    "coreMd": (
        "- `SYS_CONNECT_BY_PATH(열, 구분자)`는 루트부터 지금 행까지 거쳐 온 값을 이어 붙이고, `CONNECT_BY_ROOT 열`은 그 행이 속한 트리의 루트 값을 돌려줘요.\n"
        "- `CONNECT_BY_ISLEAF`는 결과 트리에서 아래에 이어진 행이 없으면 1, 있으면 0이에요.\n"
        "- `CONNECT_BY_ISCYCLE`은 자식 중에 자기 조상이 있는 행(고리가 생기는 행)이면 1을 돌려주고, `NOCYCLE`과 함께 쓸 때만 쓸 수 있어요.\n"
        "- `ORDER BY`는 트리 모양을 깨고 전체를 다시 줄 세우지만, `ORDER SIBLINGS BY`는 같은 부모 아래 형제끼리만 정렬해서 모양을 지켜요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

LEVEL만 보아서는 어떤 사원이 누구를 거쳐 그 자리에 왔는지, 그 트리의 꼭대기가 누구인지, 더 아래에 부하가 있는지를 알 수 없어요. Oracle은 이런 정보를 계층 쿼리 전용 함수와 의사 열(테이블에 없지만 열처럼 꺼내 쓰는 값)로 제공해요. 또 계층 결과에 일반 ORDER BY를 붙이면 조직도 모양이 무너지기 때문에, 계층 모양을 지키는 정렬 문법이 따로 있어요. 이 개념의 예시도 공통 사원 표를 써요.

{EMPLOYEE_MANAGER_SALARY_TABLE}

## 한눈에 보기 {{#definition}}

아래 표의 예는 김민수에서 출발해 아래로 펼쳤을 때 박서준 행의 값이에요.

| 이름 | 돌려주는 값 | 박서준 행의 값 |
|---|---|---|
| `SYS_CONNECT_BY_PATH(이름, '/')` | 루트부터 지금 행까지의 값을 구분자로 이은 문자열 | /김민수/이지은/박서준 |
| `CONNECT_BY_ROOT 이름` | 지금 행이 속한 트리의 루트 행 값 | 김민수 |
| `CONNECT_BY_ISLEAF` | 아래에 이어진 자식이 없으면 1, 있으면 0 | 1 |
| `CONNECT_BY_ISCYCLE` | 자식 중에 자기 조상이 있는 행이면 1, 아니면 0 | NOCYCLE을 쓸 때만 볼 수 있어요 |

`CONNECT_BY_ROOT`는 함수처럼 보이지만 연산자예요. 연산자는 `+`나 `PRIOR`처럼 값 옆에 붙어서 일을 하는 기호나 단어를 말해요. 그래서 괄호로 감싸지 않고 열 이름 앞에 붙여 `CONNECT_BY_ROOT 이름`으로 써요. 잎(leaf)은 나뭇가지 끝에 달린 잎처럼 더 내려갈 곳이 없는 행을 말해요.

## 예시: 경로, 루트, 잎을 한 번에 보기 {{#example}}

{PATH_ROOT_LEAF_EXAMPLE.markdown}

경로는 맨 앞에도 구분자가 붙어서 `/김민수`로 시작해요. 루트는 모두 김민수이고, 부하가 없는 박서준, 정하늘, 한도윤, 오지민, 윤서연이 잎으로 1을 받았어요.

START WITH 조건에 맞는 행이 여러 개면 트리도 여러 개가 생기고, `CONNECT_BY_ROOT`는 행마다 자기가 속한 트리의 루트를 알려 줘요. 과장과 부장에서 출발하면 각 사원이 어느 팀장 아래에 있는지 바로 보여요.

{MULTI_ROOT_EXAMPLE.markdown}

## 예시: 고리가 생기는 행 찾기 {{#cycle}}

아래 UPDATE 문으로 김민수의 관리자사번을 1003(박서준)으로 잘못 바꾸면 김민수 > 이지은 > 박서준 > 김민수로 돌아오는 고리가 생겨요. `CONNECT BY NOCYCLE`로 펼치면서 `CONNECT_BY_ISCYCLE`을 함께 보면 고리가 생기는 자리를 찾을 수 있어요.

```sql
{MAKE_CYCLE_SQL}
{CYCLE_FLAG_SQL}
```

{to_markdown_table(("LEVEL", "이름", "순환"), CYCLE_FLAG_ROWS)}

바뀐 데이터에서 박서준의 자식은 김민수예요. 그런데 김민수는 루트이자 박서준의 조상이라서, 박서준은 자식 중에 자기 조상이 있는 행이 되어 1을 받았어요. NOCYCLE 덕분에 김민수가 박서준 아래에 다시 붙지는 않으므로, 김민수 행에는 1이 표시되지 않아요.

## 예시: ORDER SIBLINGS BY와 ORDER BY {{#order-siblings}}

같은 부모 아래의 형제(siblings)끼리만 순서를 정하고 싶을 때는 `ORDER SIBLINGS BY`를 써요. 아래 SQL은 형제끼리 급여가 높은 순으로 정렬해요.

{ORDER_SIBLINGS_EXAMPLE.markdown}

김민수의 부하 세 명은 급여가 높은 최유나(3200), 이지은(2500), 윤서연(2000) 순서로 바뀌었고, 각자의 부하는 여전히 자기 상사 바로 아래에 붙어 있어요. 최유나 밑의 한도윤과 오지민, 이지은 밑의 박서준과 정하늘도 각각 형제끼리 급여 순이에요.

같은 SQL에 일반 `ORDER BY 급여 DESC`를 쓰면 계층과 상관없이 8행 전체를 급여 순으로 다시 줄 세워요.

{ORDER_BY_EXAMPLE.markdown}

LEVEL 2인 최유나가 루트 김민수보다 먼저 나오고, 박서준이 자기 상사 이지은보다 앞에 나와서 조직도 모양이 깨졌어요. 이지은과 정하늘은 급여가 2500으로 같아서 둘의 순서는 정해져 있지 않아요.

## 자주 헷갈리는 점 {{#confusing}}

**"루트"는 회사의 꼭대기가 아니라 START WITH로 고른 시작 행이에요.** 오지민에서 출발해 위로 올라가면 경로는 오지민부터 시작하고, `CONNECT_BY_ROOT`도 오지민이 돼요. 결과 트리에서는 사장인 김민수가 가장 아래에 있으므로 잎이 1이 돼요.

{UPWARD_FUNCTIONS_EXAMPLE.markdown}

**잎은 원래 표가 아니라 결과 트리를 기준으로 정해져요.** `CONNECT BY ... AND LEVEL <= 2`로 2단계까지만 펼치면 이지은과 최유나는 실제로 부하가 있어도 결과 트리에서 더 내려가지 않으므로 잎이 1이에요.

{LEAF_CONNECT_BY_LEVEL_EXAMPLE.markdown}

같은 조건을 WHERE 절에 쓰면 트리는 3단계까지 다 펼친 뒤 행만 거르므로, 이지은과 최유나의 잎은 0으로 남아요.

{LEAF_WHERE_LEVEL_EXAMPLE.markdown}

**경로의 맨 앞에도 구분자가 붙어요.** `SYS_CONNECT_BY_PATH(이름, '/')`의 결과는 `김민수/이지은`이 아니라 `/김민수/이지은`이에요. 보기에서 앞의 `/` 하나로 정답과 오답을 가르는 경우가 있어요. 또 경로는 트리를 펼치는 동안 만들어지므로, WHERE로 행 하나만 남겨도 그 행의 경로는 루트부터 그대로 나와요.

{PATH_WITH_WHERE_EXAMPLE.markdown}

WHERE는 다 펼친 뒤에 한도윤 행만 남겼고, 한도윤의 경로는 이미 김민수와 최유나를 거쳐 만들어진 뒤라서 `/김민수/최유나/한도윤`이 나와요.

**CONNECT_BY_ISCYCLE은 NOCYCLE 없이 쓰면 오류가 나요.** 순환이 없는 데이터라도 NOCYCLE을 빼고 쓰면 ORA-30930(CONNECT_BY_ISCYCLE에는 NOCYCLE이 필요함) 오류가 나요.

```sql
-- 오류: CONNECT_BY_ISCYCLE은 NOCYCLE 없이 쓸 수 없어요 (ORA-30930, NOCYCLE이 필요함)
{CYCLE_FLAG_WITHOUT_NOCYCLE_SQL}
```

**ORDER SIBLINGS BY는 계층 쿼리에서만 쓸 수 있어요.** START WITH나 CONNECT BY가 없는 일반 SELECT에 쓰면 ORA-30929(ORDER SIBLINGS BY를 쓸 수 없는 자리) 오류가 나요. 정렬 기준은 ORDER BY처럼 열 이름, ASC와 DESC를 그대로 쓸 수 있어요.

```sql
-- 오류: ORDER SIBLINGS BY는 계층 쿼리에서만 쓸 수 있어요 (ORA-30929, 쓸 수 없는 자리)
{ORDER_SIBLINGS_WITHOUT_HIERARCHY_SQL}
```

## 시험에서는 이렇게 나와요 {{#exam-point}}

계층 쿼리 결과 표의 빈칸에 들어갈 경로나 잎 값을 묻거나, 함수 이름과 설명을 짝짓는 문제가 많이 나와요. ORDER SIBLINGS BY와 ORDER BY 중 계층 모양을 지키는 쪽을 고르거나, 정렬 뒤 몇 번째 행이 누구인지를 묻기도 해요. 잎과 루트를 물으면 원래 표가 아니라 START WITH와 CONNECT BY로 만들어진 결과 트리를 기준으로 판단하면 돼요.""",
    "checkQuestions": [
        question(1, "계층 쿼리 결과에서 아래에 이어진 자식 행이 없으면 1, 있으면 0을 돌려주는 것은 무엇인가요?", "definition",
                 "CONNECT_BY_ISLEAF는 결과 트리에서 더 내려갈 행이 없는 잎이면 1을 돌려줘요.",
                 [choice("A", "CONNECT_BY_ROOT", rationale="그 행이 속한 트리의 루트 값을 돌려줘요."),
                  choice("B", "CONNECT_BY_ISCYCLE", rationale="자식 중에 자기 조상이 있는 행이면 1을 돌려줘요."),
                  choice("C", "CONNECT_BY_ISLEAF", True, "자식이 없는 잎 행이면 1이에요."),
                  choice("D", "LEVEL", rationale="루트에서 몇 단계째인지를 돌려줘요.")]),
        question(2, "공통 예시의 사원 표에 다음 SQL을 실행하면 결과는 무엇인가요?", "confusing",
                 "SYS_CONNECT_BY_PATH는 루트 김민수부터 정하늘까지 거쳐 온 이름을 이어 붙이고, 맨 앞에도 구분자를 붙여요. WHERE는 펼친 뒤에 정하늘 행만 남기므로 경로에는 영향을 주지 않아요.",
                 [choice("A", "김민수/이지은/정하늘", rationale="맨 앞에도 구분자 /가 붙어요."),
                  choice("B", "/김민수/이지은/정하늘", True, "루트부터 지금 행까지의 경로예요."),
                  choice("C", "/정하늘/이지은/김민수", rationale="경로는 지금 행이 아니라 루트에서 시작해요."),
                  choice("D", "/이지은/정하늘", rationale="루트는 START WITH로 고른 김민수라서 경로가 김민수부터 시작해요.")],
                 stem_sql=PATH_STEM_SQL),
        question(3, "아래 사원 표에 다음 SQL을 실행하면 두 번째 행에 나오는 사원은 누구인가요?\n\n" + EMPLOYEE_MANAGER_SALARY_TABLE, "order-siblings",
                 "ORDER SIBLINGS BY는 트리 모양을 지킨 채 형제끼리만 정렬하므로 루트 김민수가 첫 행이에요. 김민수의 부하 중 급여가 가장 높은 최유나(3200)가 두 번째예요.",
                 [choice("A", "최유나", True, "김민수의 부하 중 급여가 가장 높아요."),
                  choice("B", "김민수", rationale="김민수는 루트라서 첫 번째 행이에요."),
                  choice("C", "이지은", rationale="정렬 전 순서로 본 답이에요. 형제끼리 급여 순으로 바뀌어요."),
                  choice("D", "박서준", rationale="박서준은 이지은 아래에 붙어 있어서 이지은보다 먼저 나올 수 없어요.")],
                 stem_sql=SIBLINGS_STEM_SQL),
        question(4, "다음 SQL은 결과 트리에서 잎(CONNECT_BY_ISLEAF = 1)인 행이 몇 개인지 세요. 아래 사원 표에 실행하면 어떤 숫자가 나오나요? (COUNT(*)는 행 수를 세는 함수예요)\n\n" + EMPLOYEE_MANAGER_SALARY_TABLE, "confusing",
                 "CONNECT BY에 LEVEL <= 2를 두면 2단계에서 펼치기가 멈춰서 이지은, 최유나, 윤서연이 모두 잎이 돼요. 잎은 원래 표가 아니라 결과 트리를 기준으로 정해져요.",
                 [choice("A", "1", rationale="원래 표에서 부하가 없는 윤서연만 센 답이에요."),
                  choice("B", "5", rationale="3단계까지 다 펼친 트리의 잎 수예요."),
                  choice("C", "0", rationale="2단계 행들은 결과 트리에서 아래로 이어진 행이 없어서 잎이에요."),
                  choice("D", "3", True, "2단계의 세 명이 모두 잎이 돼요.")],
                 stem_sql=LEAF_COUNT_STEM_SQL),
        question(5, "김민수(1001)의 관리자사번을 1003(박서준)으로 바꿔서 1001 > 1002 > 1003 > 1001 고리가 생겼어요. 이 상태에서 다음 SQL을 실행하면 나오는 사원은 누구인가요?", "cycle",
                 "바뀐 데이터에서 박서준의 자식은 김민수인데, 김민수는 박서준의 조상이에요. 그래서 자식 중에 자기 조상이 있는 행인 박서준이 CONNECT_BY_ISCYCLE 1을 받아요.",
                 [choice("A", "김민수", rationale="김민수는 NOCYCLE 때문에 박서준 아래에 다시 붙지 않아서 0이에요."),
                  choice("B", "박서준", True, "자식 중에 자기 조상(김민수)이 있는 행이에요."),
                  choice("C", "이지은", rationale="이지은의 자식 박서준과 정하늘은 이지은의 조상이 아니에요."),
                  choice("D", "아무도 나오지 않는다", rationale="고리가 있으므로 1이 표시되는 행이 하나 있어요.")],
                 stem_sql=CYCLE_STEM_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        PATH_ROOT_LEAF_EXAMPLE.check,
        MULTI_ROOT_EXAMPLE.check,
        sql_check(CYCLE_FLAG_SQL, CYCLE_FLAG_ROWS, is_ordered=True, setup=MAKE_CYCLE_SQL),
        ORDER_SIBLINGS_EXAMPLE.check,
        ORDER_BY_EXAMPLE.check,
        # ORDER BY 순서 확인 (동점 2500 두 행은 앞뒤가 바뀔 수 있어 급여 열만 순서 비교)
        sql_check("SELECT 급여 FROM 사원 START WITH 관리자사번 IS NULL CONNECT BY PRIOR 사번 = 관리자사번 ORDER BY 급여 DESC",
                  [[row[2]] for row in ORDER_BY_ROWS], is_ordered=True),
        UPWARD_FUNCTIONS_EXAMPLE.check,
        LEAF_CONNECT_BY_LEVEL_EXAMPLE.check,
        LEAF_WHERE_LEVEL_EXAMPLE.check,
        PATH_WITH_WHERE_EXAMPLE.check,
        sql_error_check(CYCLE_FLAG_WITHOUT_NOCYCLE_SQL, "ORA-30930"),
        sql_error_check(ORDER_SIBLINGS_WITHOUT_HIERARCHY_SQL, "ORA-30929"),
        sql_check(PATH_STEM_SQL, [["/김민수/이지은/정하늘"]]),
        sql_check(SIBLINGS_STEM_SQL, [[row[1]] for row in ORDER_SIBLINGS_ROWS], is_ordered=True),
        sql_check(LEAF_COUNT_STEM_SQL, [[3]]),
        sql_check(CYCLE_STEM_SQL, [["박서준"]], setup=MAKE_CYCLE_SQL),
    ],
}
