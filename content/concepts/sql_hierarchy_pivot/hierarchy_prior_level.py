"""개념: PRIOR 방향과 LEVEL (9단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md, to_markdown_table

EMPLOYEE_MANAGER_TABLE = to_employee_table_md("사번", "이름", "직급", "관리자사번")

# 순환 예시 준비: 김민수(1001)의 관리자를 박서준(1003)으로 바꿔 1001 > 1002 > 1003 > 1001 고리를 만듦
MAKE_CYCLE_SQL = "UPDATE 사원 SET 관리자사번 = 1003 WHERE 사번 = 1001;"

# 본문 SQL·결과 표와 검증 항목의 원본 (결과 순서까지 검증)
UPWARD_SQL = """SELECT LEVEL, 사번, 이름
FROM 사원
START WITH 사번 = 1005
CONNECT BY PRIOR 관리자사번 = 사번;"""
UPWARD_ROWS = [[1, 1005, "정하늘"], [2, 1002, "이지은"], [3, 1001, "김민수"]]

DOWNWARD_FROM_JUNG_SQL = """SELECT LEVEL, 사번, 이름
FROM 사원
START WITH 사번 = 1005
CONNECT BY PRIOR 사번 = 관리자사번;"""
DOWNWARD_FROM_JUNG_ROWS = [[1, 1005, "정하늘"]]

UPWARD_FROM_ROOT_SQL = """SELECT LEVEL, 사번, 이름
FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 관리자사번 = 사번;"""
UPWARD_FROM_ROOT_ROWS = [[1, 1001, "김민수"]]

SWAPPED_SIDES_SQL = """SELECT LEVEL, 사번, 이름
FROM 사원
START WITH 사번 = 1005
CONNECT BY 사번 = PRIOR 관리자사번;"""

PRIOR_SELECT_SQL = """SELECT 이름, PRIOR 이름 AS 상사이름
FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번;"""
PRIOR_SELECT_ROWS = [
    ["김민수", None], ["이지은", "김민수"], ["박서준", "이지은"], ["정하늘", "이지은"],
    ["최유나", "김민수"], ["한도윤", "최유나"], ["오지민", "최유나"], ["윤서연", "김민수"],
]

INDENT_SQL = """SELECT LEVEL, LPAD('-', LEVEL * 2, '-') || 이름 AS 조직도
FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번;"""
INDENT_ROWS = [
    [1, "--김민수"], [2, "----이지은"], [3, "------박서준"], [3, "------정하늘"],
    [2, "----최유나"], [3, "------한도윤"], [3, "------오지민"], [2, "----윤서연"],
]

WHERE_LEVEL_SQL = """SELECT LEVEL, 이름
FROM 사원
WHERE LEVEL = 2
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번;"""
WHERE_LEVEL_ROWS = [[2, "이지은"], [2, "최유나"], [2, "윤서연"]]

CONNECT_BY_LEVEL_SQL = """SELECT LEVEL, 이름
FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번 AND LEVEL <= 2;"""
CONNECT_BY_LEVEL_ROWS = [[1, "김민수"], [2, "이지은"], [2, "최유나"], [2, "윤서연"]]

CONNECT_BY_LEVEL_EQUAL_SQL = """SELECT LEVEL, 이름
FROM 사원
START WITH 관리자사번 IS NULL
CONNECT BY PRIOR 사번 = 관리자사번 AND LEVEL = 2;"""

CYCLE_DATA_SQL = """SELECT 사번, 이름, 관리자사번
FROM 사원
WHERE 사번 IN (1001, 1002, 1003);"""
CYCLE_DATA_ROWS = [[1001, "김민수", 1003], [1002, "이지은", 1001], [1003, "박서준", 1002]]

CYCLE_ERROR_SQL = """SELECT LEVEL, 이름
FROM 사원
START WITH 사번 = 1001
CONNECT BY PRIOR 사번 = 관리자사번;"""

NOCYCLE_SQL = """SELECT LEVEL, 이름
FROM 사원
START WITH 사번 = 1001
CONNECT BY NOCYCLE PRIOR 사번 = 관리자사번;"""
NOCYCLE_ROWS = [
    [1, "김민수"], [2, "이지은"], [3, "박서준"], [3, "정하늘"],
    [2, "최유나"], [3, "한도윤"], [3, "오지민"], [2, "윤서연"],
]

# 확인 문제 2 보기: 위로 올라가는 조건(정답) <-> 아래로 내려가는 조건 두 가지 <-> PRIOR 없는 조건
DIRECTION_CHOICE_SQL_FORMAT = "SELECT 이름 FROM 사원 START WITH 사번 = 1005 CONNECT BY {condition}"
STEP_FROM_UPWARD_SQL = "SELECT 이름, LEVEL FROM 사원 START WITH 사번 = 1005 CONNECT BY PRIOR 관리자사번 = 사번;"
REVERSE_FROM_ROOT_STEM_SQL = "SELECT 이름 FROM 사원 START WITH 사번 = 1001 CONNECT BY PRIOR 관리자사번 = 사번;"

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
PRIOR_SELECT_EXAMPLE = sql_example(PRIOR_SELECT_SQL, ("이름", "상사이름"), PRIOR_SELECT_ROWS)
UPWARD_EXAMPLE = sql_example(UPWARD_SQL, ("LEVEL", "사번", "이름"), UPWARD_ROWS)
INDENT_EXAMPLE = sql_example(INDENT_SQL, ("LEVEL", "조직도"), INDENT_ROWS)
WHERE_LEVEL_EXAMPLE = sql_example(WHERE_LEVEL_SQL, ("LEVEL", "이름"), WHERE_LEVEL_ROWS)
CONNECT_BY_LEVEL_EXAMPLE = sql_example(CONNECT_BY_LEVEL_SQL, ("LEVEL", "이름"), CONNECT_BY_LEVEL_ROWS)

CONCEPT = {
    "tagKey": "hierarchy-prior-level",
    "topicCode": "sql_hierarchy_pivot",
    "sortOrder": 2,
    "title": "PRIOR 방향과 LEVEL",
    "summary": "PRIOR가 붙은 열은 이미 찾은 행이고, LEVEL은 몇 단계째인지 알려 줘요",
    "coreMd": (
        "- `PRIOR`가 붙은 열은 이미 찾은 행의 값이라서, `PRIOR 사번 = 관리자사번`은 부하 쪽(아래)으로, `PRIOR 관리자사번 = 사번`은 상사 쪽(위)으로 펼쳐요.\n"
        "- 등호 양쪽 자리를 바꿔도 결과는 같고, 방향은 PRIOR가 어느 열에 붙었는지로만 정해져요.\n"
        "- `LEVEL`은 시작 행을 1로 두고 한 단계 이어질 때마다 1씩 커지는 값이라서, 들여쓰기나 단계 거르기에 써요.\n"
        "- 데이터에 고리(순환)가 있으면 오류가 나는데, `CONNECT BY NOCYCLE`을 쓰면 이미 지나온 행에서 멈춰요."
    ),
    "detailMd": f"""## 왜 헷갈리나요 {{#why}}

CONNECT BY 절은 짧지만, PRIOR를 어느 열에 붙이느냐에 따라 위로 올라갈지 아래로 내려갈지가 정반대로 바뀌어요. 글자 몇 개 차이라서 시험에서 보기를 바꿔 놓기 좋은 부분이에요. 이 개념에서도 사원 표의 사번과 관리자사번 두 열로 설명할게요.

{EMPLOYEE_MANAGER_TABLE}

## PRIOR 읽는 법 {{#prior}}

계층 쿼리는 이미 찾아 둔 행에 이어 붙일 다음 행을 찾는 일을 되풀이해요. 이때 PRIOR가 붙은 열은 "이미 찾은 행"의 값이고, PRIOR가 없는 열은 "이제 찾을 행"의 값이에요. 그래서 CONNECT BY 조건을 문장으로 바꿔 읽으면 방향이 보여요.

| CONNECT BY 조건 | 문장으로 읽으면 | 펼치는 방향 |
|---|---|---|
| `PRIOR 사번 = 관리자사번` | 이미 찾은 행의 사번을 관리자사번으로 가진 행, 즉 부하를 찾아요 | 상사에서 부하로 (순방향) |
| `PRIOR 관리자사번 = 사번` | 이미 찾은 행의 관리자사번을 사번으로 가진 행, 즉 상사를 찾아요 | 부하에서 상사로 (역방향) |

수험서에서는 두 조건을 줄여서 부르기도 해요. 사원 표에서 행 자신을 나타내는 사번을 자식 쪽 열, 윗사람을 가리키는 관리자사번을 부모 쪽 열이라고 하면, `PRIOR 사번 = 관리자사번`은 PRIOR가 자식 쪽 열에 붙은 "PRIOR 자식 = 부모" 형태예요. 이 형태는 위에서 아래로 내려가므로 순방향이라고 불러요. 반대로 `PRIOR 관리자사번 = 사번`은 "PRIOR 부모 = 자식" 형태이고, 아래에서 위로 올라가므로 역방향이라고 불러요.

PRIOR는 SELECT 절에도 쓸 수 있는데, 그러면 각 행의 부모 행 값을 함께 볼 수 있어요. 루트는 부모가 없으므로 NULL이 나와요.

{PRIOR_SELECT_EXAMPLE.markdown}

## 예시: 아래에서 위로 거슬러 오르기 {{#direction}}

정하늘(1005)에서 출발해 상사 쪽으로 올라가 보면, 정하늘의 관리자사번 1002를 사번으로 가진 이지은을 찾고, 다시 이지은의 관리자사번 1001을 사번으로 가진 김민수를 찾아요.

{UPWARD_EXAMPLE.markdown}

같은 조건을 `CONNECT BY 사번 = PRIOR 관리자사번`처럼 등호 양쪽을 바꿔 적어도 결과는 똑같아요. 등호의 왼쪽과 오른쪽은 상관이 없고, PRIOR가 어느 열 앞에 붙었는지만 보면 돼요.

## LEVEL로 단계 알기 {{#level}}

`LEVEL`은 계층 쿼리가 행마다 붙여 주는 의사 열이에요. 의사 열(pseudo column)은 테이블에 실제로 저장된 열은 아니지만 SELECT 절에서 열처럼 꺼내 쓸 수 있는 값을 말해요. 루트가 1이고, 자식은 2, 자식의 자식은 3처럼 한 단계 이어질 때마다 1씩 커져요.

LEVEL을 쓰는 가장 흔한 예는 조직도처럼 들여쓰기를 하는 것이에요. `LPAD(문자, 길이, 채울 문자)`는 문자의 왼쪽을 채울 문자로 채워서 정한 길이로 만드는 함수라서, `LPAD('-', LEVEL * 2, '-')`는 LEVEL이 1이면 `--`, 2면 `----`, 3이면 `------`가 돼요. `||`는 두 문자열을 하나로 이어 붙이는 연산자예요. 그래서 아래 SQL은 단계가 하나 깊어질 때마다 이름 앞의 `-`가 두 개씩 늘어나요. 보통은 공백으로 들여쓰지만, 화면에서 잘 보이도록 여기서는 `-`로 채웠어요.

{INDENT_EXAMPLE.markdown}

특정 단계만 고를 때도 LEVEL을 써요. `WHERE LEVEL = 2`는 트리를 다 펼친 뒤 2단계 행만 남겨요.

{WHERE_LEVEL_EXAMPLE.markdown}

## 순환과 NOCYCLE {{#nocycle}}

데이터를 잘못 넣어서 김민수의 관리자가 박서준이 되었다고 가정해요. 아래 UPDATE 문은 김민수(1001)의 관리자사번을 1003으로 바꾸는 문장이에요.

```sql
{MAKE_CYCLE_SQL}
{CYCLE_DATA_SQL}
```

{to_markdown_table(("사번", "이름", "관리자사번"), CYCLE_DATA_ROWS)}

이제 김민수의 상사는 박서준, 박서준의 상사는 이지은, 이지은의 상사는 다시 김민수예요. 김민수 > 이지은 > 박서준 > 김민수로 돌아오는 고리가 생겼고, 이것을 순환(cycle)이라고 불러요.

이 상태에서 김민수부터 아래로 펼치면, Oracle은 끝없이 돌지 않고 ORA-01436(데이터에 순환이 있음) 오류를 내고 멈춰요. 결과 행은 하나도 나오지 않아요.

```sql
{MAKE_CYCLE_SQL}
-- 오류: 데이터에 순환이 있어서 멈춰요 (ORA-01436, 데이터에 순환이 있음)
{CYCLE_ERROR_SQL}
```

같은 데이터에서 `CONNECT BY NOCYCLE`로 바꾸면 오류 없이 결과가 나와요.

```sql
{MAKE_CYCLE_SQL}
{NOCYCLE_SQL}
```

{to_markdown_table(("LEVEL", "이름"), NOCYCLE_ROWS)}

`CONNECT BY NOCYCLE`을 쓰면 이미 지나온 행이 다시 자식으로 나타날 때 그 행을 이어 붙이지 않고 넘어가요. 그래서 박서준 아래에 김민수가 다시 붙지 않고, 8명이 한 번씩만 나와요. 어느 행에서 고리가 생겼는지 알려 주는 `CONNECT_BY_ISCYCLE`은 다음 개념에서 다뤄요.

## 자주 헷갈리는 점 {{#confusing}}

**방향과 시작 행이 맞지 않으면 시작 행 하나만 나와요.** 정하늘에서 출발하면서 아래로 내려가는 조건을 쓰면, 정하늘의 부하가 없으므로 결과는 정하늘 한 행뿐이에요. 거꾸로 맨 꼭대기 김민수에서 출발하면서 위로 올라가는 조건을 쓰면, 김민수의 상사가 없으므로 역시 김민수 한 행만 나와요. 시작 행은 START WITH 조건에 맞기만 하면 CONNECT BY와 상관없이 결과에 들어가기 때문에 0행이 되지는 않아요.

```sql
{DOWNWARD_FROM_JUNG_SQL}  -- 정하늘 한 행이 나와요
{UPWARD_FROM_ROOT_SQL}  -- 김민수 한 행이 나와요
```

**LEVEL은 직급이 아니라 시작 행에서 떨어진 거리예요.** 앞의 거슬러 오르기 예시에서 정하늘이 LEVEL 1이고 사장인 김민수는 LEVEL 3이었어요. 이지은에서 출발해 아래로 펼치면 과장인 이지은이 LEVEL 1이 돼요. "LEVEL 1은 사장"처럼 외우면 시작 행을 바꾼 문제에서 틀리게 돼요.

**LEVEL 조건도 WHERE에 두느냐 CONNECT BY에 두느냐에 따라 다르게 동작해요.** `CONNECT BY ... AND LEVEL <= 2`는 2단계까지만 이어 붙이고 3단계 행은 처음부터 찾지 않아요. 결과는 김민수와 2단계 세 명으로 `WHERE LEVEL <= 2`와 같지만, WHERE 쪽은 3단계까지 다 펼친 뒤에 지운다는 점이 달라요.

{CONNECT_BY_LEVEL_EXAMPLE.markdown}

같은 자리에 `LEVEL = 2`를 쓰면 2단계만 남을 것 같지만, 루트 김민수(LEVEL 1)가 함께 나와서 결과가 위와 똑같은 4행이에요. 2단계 행만 원한다면 앞에서 본 것처럼 WHERE 절에 `LEVEL = 2`를 써야 해요.

```sql
{CONNECT_BY_LEVEL_EQUAL_SQL}  -- 위 표와 같은 4행이 나와요
```

**NOCYCLE은 고리를 없애 주는 것이 아니에요.** 데이터는 그대로 두고, 펼치는 도중 이미 지나온 행을 만나면 거기서 멈추기만 해요. 순환이 없는 데이터에 NOCYCLE을 붙여도 결과는 달라지지 않아요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

CONNECT BY 절 네 가지를 보기로 주고 위로(또는 아래로) 펼치는 것을 고르게 하거나, 시작 행과 방향을 바꾼 SQL의 결과를 묻는 문제가 많이 나와요. 이때는 PRIOR가 붙은 열을 "이미 찾은 행"으로 두고 문장으로 읽어 보면 방향을 헷갈리지 않아요. LEVEL은 시작 행이 1이라는 점과, 순환이 있는 데이터에서는 NOCYCLE이 없으면 오류가 난다는 점도 자주 물어요.""",
    "checkQuestions": [
        question(1, "`CONNECT BY PRIOR 사번 = 관리자사번`에서 `PRIOR 사번`이 가리키는 것은 무엇인가요?", "prior",
                 "PRIOR가 붙은 열은 이미 찾은 행의 값이에요. 그래서 이 조건은 이미 찾은 행의 사번을 관리자사번으로 가진 행, 즉 부하를 다음 행으로 찾아요.",
                 [choice("A", "이미 찾은 행(부모 쪽)의 사번", True, "PRIOR는 이미 찾은 앞 행을 가리켜요."),
                  choice("B", "이제 찾을 행(자식 쪽)의 사번", rationale="PRIOR가 없는 열이 이제 찾을 행의 값이에요."),
                  choice("C", "루트 행의 사번", rationale="루트 값은 CONNECT_BY_ROOT로 얻고, PRIOR는 바로 앞 행을 가리켜요."),
                  choice("D", "표에서 가장 작은 사번", rationale="PRIOR는 값의 크기와 관계없이 이미 찾은 행을 가리켜요.")]),
        question(2, "정하늘(1005)에서 출발해 상사 쪽(아래에서 위로)으로 거슬러 올라가는 CONNECT BY 절은 무엇인가요?", "prior",
                 "PRIOR가 관리자사번에 붙어야 \"이미 찾은 행의 관리자사번을 사번으로 가진 행\", 즉 상사를 찾아요. 등호 양쪽 자리는 방향과 관계없어요.",
                 [choice("A", "CONNECT BY PRIOR 사번 = 관리자사번", rationale="부하를 찾는 순방향이라서 정하늘 한 행만 나와요."),
                  choice("B", "CONNECT BY 관리자사번 = PRIOR 사번", rationale="A와 자리만 바꾼 같은 조건이라 역시 부하를 찾아요."),
                  choice("C", "CONNECT BY PRIOR 관리자사번 = 사번", True, "이미 찾은 행의 상사를 다음 행으로 찾는 역방향이에요."),
                  choice("D", "CONNECT BY 사번 = 관리자사번", rationale="PRIOR가 없으면 앞 행과 이어 주는 조건이 없어서 정하늘 한 행만 나와요.")]),
        question(3, "공통 예시의 사원 표에 다음 SQL을 실행하면 김민수의 LEVEL은 얼마인가요?\n\n" + EMPLOYEE_MANAGER_TABLE, "confusing",
                 "LEVEL은 시작 행 정하늘이 1이고 한 단계 이어질 때마다 1씩 커져요. 정하늘 > 이지은 > 김민수 순서로 올라가므로 김민수는 3이에요.",
                 [choice("A", "1", rationale="LEVEL 1은 직급이 아니라 시작 행인 정하늘이에요."),
                  choice("B", "2", rationale="LEVEL 2는 정하늘 바로 위의 이지은이에요."),
                  choice("C", "0", rationale="LEVEL은 1부터 시작해요."),
                  choice("D", "3", True, "시작 행에서 두 단계 위라서 3이에요.")],
                 stem_sql=STEP_FROM_UPWARD_SQL),
        question(4, "공통 예시의 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_MANAGER_TABLE, "confusing",
                 "김민수에서 출발해 상사 쪽으로 올라가는데 김민수의 관리자사번이 NULL이라 이어 붙을 행이 없어요. 시작 행은 항상 결과에 들어가므로 1행이에요.",
                 [choice("A", "8행", rationale="아래로 내려가는 순방향 조건일 때의 행 수예요."),
                  choice("B", "1행", True, "위에 아무도 없어서 시작 행 김민수만 나와요."),
                  choice("C", "0행", rationale="START WITH로 고른 시작 행은 CONNECT BY와 상관없이 결과에 들어가요."),
                  choice("D", "오류가 난다", rationale="문법에 문제가 없고 순환도 없어서 오류가 나지 않아요.")],
                 stem_sql=REVERSE_FROM_ROOT_STEM_SQL),
        question(5, "김민수(1001)의 관리자사번을 1003(박서준)으로 바꿔서 1001 > 1002 > 1003 > 1001 고리가 생겼어요. 이 상태에서 다음 SQL을 실행하면 어떻게 되나요?", "nocycle",
                 "순환이 있는 데이터를 NOCYCLE 없이 펼치면 Oracle은 순환 오류(ORA-01436)를 내요. CONNECT BY NOCYCLE을 쓰면 이미 지나온 행에서 멈추고 8행이 나와요.",
                 [choice("A", "순환 오류(ORA-01436)가 난다", True, "NOCYCLE이 없으면 순환을 만난 순간 오류가 나요."),
                  choice("B", "8행이 나온다", rationale="이미 지나온 행에서 멈추는 것은 NOCYCLE을 썼을 때의 결과예요."),
                  choice("C", "행이 끝없이 반복해서 나온다", rationale="Oracle은 순환을 감지하면 무한히 돌지 않고 오류를 내요."),
                  choice("D", "김민수 한 행만 나온다", rationale="이지은과 박서준으로 이어지므로 한 행에서 끝나지 않아요.")],
                 stem_sql=CYCLE_ERROR_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        PRIOR_SELECT_EXAMPLE.check,
        UPWARD_EXAMPLE.check,
        sql_check(SWAPPED_SIDES_SQL, UPWARD_ROWS, is_ordered=True),
        INDENT_EXAMPLE.check,
        sql_check(CYCLE_DATA_SQL, CYCLE_DATA_ROWS, setup=MAKE_CYCLE_SQL),
        WHERE_LEVEL_EXAMPLE.check,
        sql_check(NOCYCLE_SQL, NOCYCLE_ROWS, is_ordered=True, setup=MAKE_CYCLE_SQL),
        sql_check(DOWNWARD_FROM_JUNG_SQL, DOWNWARD_FROM_JUNG_ROWS, is_ordered=True),
        sql_check(UPWARD_FROM_ROOT_SQL, UPWARD_FROM_ROOT_ROWS, is_ordered=True),
        CONNECT_BY_LEVEL_EXAMPLE.check,
        sql_check(CONNECT_BY_LEVEL_EQUAL_SQL, CONNECT_BY_LEVEL_ROWS, is_ordered=True),
        # NOCYCLE 은 순환 없는 데이터에서 결과를 바꾸지 않음
        sql_check(NOCYCLE_SQL, NOCYCLE_ROWS, is_ordered=True),
        # 확인 문제 2 보기 4개 (C만 위로 올라감)
        sql_check(DIRECTION_CHOICE_SQL_FORMAT.format(condition="PRIOR 사번 = 관리자사번"), [["정하늘"]]),
        sql_check(DIRECTION_CHOICE_SQL_FORMAT.format(condition="관리자사번 = PRIOR 사번"), [["정하늘"]]),
        sql_check(DIRECTION_CHOICE_SQL_FORMAT.format(condition="PRIOR 관리자사번 = 사번"),
                  [["정하늘"], ["이지은"], ["김민수"]], is_ordered=True),
        sql_check(DIRECTION_CHOICE_SQL_FORMAT.format(condition="사번 = 관리자사번"), [["정하늘"]]),
        sql_check(STEP_FROM_UPWARD_SQL, [["정하늘", 1], ["이지은", 2], ["김민수", 3]], is_ordered=True),
        sql_check(REVERSE_FROM_ROOT_STEM_SQL, [["김민수"]]),
        sql_error_check(CYCLE_ERROR_SQL, "ORA-01436", setup=MAKE_CYCLE_SQL),
    ],
}
