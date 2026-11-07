"""개념: 셀프 조인 (5단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import EMPLOYEE_ROWS, to_employee_table_md, to_markdown_table

# 셀프 조인 계산에 쓰는 열만 (관리자사번 <-> 사번으로 잇고 급여를 비교)
EMPLOYEE_MANAGER_TABLE = to_employee_table_md("사번", "이름", "관리자사번", "급여")

# 본문, 문제 공통 SQL
EMPLOYEE_MANAGER_SQL = "SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E, 사원 M WHERE E.관리자사번 = M.사번;"
MANAGER_NAME_SQL = "SELECT M.이름 AS 관리자 FROM 사원 E JOIN 사원 M ON E.관리자사번 = M.사번;"
EARNS_MORE_THAN_MANAGER_SQL = ("SELECT E.이름 FROM 사원 E JOIN 사원 M "
                               "ON E.관리자사번 = M.사번 WHERE E.급여 > M.급여;")

# 사원-관리자 짝 7행 (김민수는 관리자 없음)
EMPLOYEE_MANAGER_ROWS = [["이지은", "김민수"], ["최유나", "김민수"], ["윤서연", "김민수"], ["박서준", "이지은"],
                         ["정하늘", "이지은"], ["한도윤", "최유나"], ["오지민", "최유나"]]
# 관리자 쪽(M)을 기준으로 남긴 12행: 짝 7행 + 부하가 없는 사원 5명
MANAGER_SIDE_OUTER_ROWS = EMPLOYEE_MANAGER_ROWS + [[None, name] for name in ("박서준", "정하늘", "한도윤", "오지민", "윤서연")]

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본, 정렬 없는 조인이라 순서 무시)
EMPLOYEE_MANAGER_EXAMPLE = sql_example(
    "SELECT E.이름 AS 사원, M.이름 AS 관리자\nFROM 사원 E, 사원 M\nWHERE E.관리자사번 = M.사번;",
    ("사원", "관리자"), EMPLOYEE_MANAGER_ROWS, is_ordered=False)
EMPLOYEE_SIDE_OUTER_EXAMPLE = sql_example(
    "SELECT E.이름 AS 사원, M.이름 AS 관리자\nFROM 사원 E LEFT JOIN 사원 M\n  ON E.관리자사번 = M.사번;",
    ("사원", "관리자"), [["김민수", None]] + EMPLOYEE_MANAGER_ROWS, is_ordered=False)
TWO_LEVELS_EXAMPLE = sql_example(
    "SELECT E.이름 AS 사원, M.이름 AS 관리자, T.이름 AS 윗관리자\nFROM 사원 E\n"
    "  JOIN 사원 M ON E.관리자사번 = M.사번\n  JOIN 사원 T ON M.관리자사번 = T.사번;",
    ("사원", "관리자", "윗관리자"),
    [["박서준", "이지은", "김민수"], ["정하늘", "이지은", "김민수"],
     ["한도윤", "최유나", "김민수"], ["오지민", "최유나", "김민수"]], is_ordered=False)
# 조건 방향만 바꾼 쌍: E 가 관리자, M 이 부하
REVERSED_DIRECTION_EXAMPLE = sql_example(
    "SELECT E.이름 AS 관리자, M.이름 AS 부하\nFROM 사원 E, 사원 M\nWHERE E.사번 = M.관리자사번;",
    ("관리자", "부하"), [[manager, employee] for employee, manager in EMPLOYEE_MANAGER_ROWS], is_ordered=False)
EARNS_MORE_EXAMPLE = sql_example(
    "SELECT E.이름, E.급여, M.이름 AS 관리자, M.급여 AS 관리자급여\nFROM 사원 E JOIN 사원 M ON E.관리자사번 = M.사번\n"
    "WHERE E.급여 > M.급여;",
    ("이름", "급여", "관리자", "관리자급여"),
    [["최유나", 3200, "김민수", 3000], ["박서준", 2800, "이지은", 2500]], is_ordered=False)

# 조인 연결 그림 (#853): 사원 E "이름 (관리자사번)" | 관리자 M "이름 (사번)"
JOIN_DIAGRAM_COLUMNS = ("왼쪽 행", "오른쪽 행")
_EMPLOYEE_BY_NAME = {row[1]: row for row in EMPLOYEE_ROWS}


def _to_employee_side_text(name):
    """사원 쪽 행 글: 이름 (관리자사번, 없으면 NULL)"""
    manager_number = _EMPLOYEE_BY_NAME[name][3]
    return f"{name} ({'NULL' if manager_number is None else manager_number})"


def _to_manager_side_text(name):
    """관리자 쪽 행 글: 이름 (사번)"""
    return f"{name} ({_EMPLOYEE_BY_NAME[name][0]})"


EMPLOYEE_MANAGER_DIAGRAM_MD = to_markdown_table(JOIN_DIAGRAM_COLUMNS, [
    [_to_employee_side_text(employee), _to_manager_side_text(manager)] for employee, manager in EMPLOYEE_MANAGER_ROWS])
# 사원 쪽 기준 외부 조인: 짝 7행 + 김민수 > NULL 칸 (선이 엉키지 않게 맨 끝)
EMPLOYEE_SIDE_OUTER_DIAGRAM_MD = to_markdown_table(JOIN_DIAGRAM_COLUMNS, [
    *([_to_employee_side_text(employee), _to_manager_side_text(manager)] for employee, manager in EMPLOYEE_MANAGER_ROWS),
    [_to_employee_side_text("김민수"), None]])

CONCEPT = {
    "tagKey": "join-self",
    "topicCode": "sql_join",
    "sortOrder": 6,
    "title": "셀프 조인",
    "summary": "같은 표를 별칭 두 개로 두 번 읽어, 사원과 관리자를 짝지어요",
    "coreMd": (
        "- 셀프 조인은 한 표를 자기 자신과 조인하는 것이고, `사원 E, 사원 M`처럼 **서로 다른 별칭**이 꼭 필요해요.\n"
        "- 사원과 관리자는 \"사원 쪽의 관리자사번 = 관리자 쪽의 사번\"으로 이어요.\n"
        "- 관리자사번이 NULL인 김민수는 빠져서 **7행**이고, 김민수까지 보려면 사원 쪽 기준 외부 조인으로 8행을 만들어요.\n"
        "- 관리자의 관리자는 같은 표를 세 번 읽어 찾고, 단계 수를 모르는 관계는 9단원의 **계층 쿼리**로 다뤄요."
    ),
    "detailMd": f"""## 왜 필요한가요: 관리자도 같은 표에 있어요 {{#why}}

사원 표의 관리자사번은 관리자의 사번이에요. 관리자도 회사의 사원이라서, 관리자의 정보는 다른 표가 아니라 같은 사원 표 안에 들어 있어요. 아래에는 셀프 조인에 쓰는 네 열만 보여요.

{EMPLOYEE_MANAGER_TABLE}

이지은의 관리자사번 1001이 누구인지 알려면 같은 표에서 사번이 1001인 행을 다시 찾아야 해요. 표 하나 안에서 행과 행을 짝짓는 이 방법이 셀프 조인이고, 예시는 모두 위 사원 표(8명)로 계산해요.

## 한 줄 정의: 같은 표를 두 번 읽기 {{#definition}}

| 용어 | 뜻 |
|---|---|
| 셀프 조인 (SELF JOIN) | 같은 표를 두 번 읽어서 자기 자신과 조인하는 거예요. `SELF JOIN`이라는 키워드는 따로 없어요 |
| 별칭 두 개 | FROM 절에 같은 표를 두 번 쓰고 `사원 E, 사원 M`처럼 별칭을 다르게 붙여요. 별칭이 없으면 두 표를 구분할 수 없어요 |

사원 표를 두 장 복사해서 한 장(E)은 사원 역할로, 다른 한 장(M)은 관리자 역할로 본다고 생각하면 쉬워요. 문제를 풀 때는 아래 순서로 역할을 먼저 한국어로 적어 두면 헷갈리지 않아요.

| 단계 | 내용 |
|---|---|
| 역할 정하기 | E는 사원, M은 관리자라고 먼저 적어요 |
| 조건 읽기 | `E.관리자사번 = M.사번`이면 E의 옆에 E의 관리자가 붙어요 |
| 짝 세기 | 관리자사번이 NULL인 행부터 빼고 세요 |

## 사원과 관리자 짝짓기: 결과는 7행 {{#example}}

두 열이 모두 `이름`이라서, SELECT 절에 `AS 사원`, `AS 관리자`처럼 결과 열 이름(별칭)을 붙여야 어느 쪽인지 구분돼요.

{EMPLOYEE_MANAGER_EXAMPLE.markdown}

왼쪽은 사원(E)의 이름과 관리자사번, 오른쪽은 관리자(M)의 이름과 사번이에요. 괄호 안의 번호가 같은 행끼리 이어져요.

{EMPLOYEE_MANAGER_DIAGRAM_MD}

ANSI 문법으로 `FROM 사원 E JOIN 사원 M ON E.관리자사번 = M.사번`이라고 써도 결과는 같아요. 결과는 관리자 수(3명)가 아니라 관리자가 있는 사원 수(7명)만큼 나오고, 부하가 여럿인 김민수는 부하 수만큼 반복돼요.

## 김민수가 빠지는 이유: 사원 쪽 기준 외부 조인 {{#outer}}

사장인 김민수는 관리자사번이 NULL이라서, `=` 비교가 참도 거짓도 아닌 UNKNOWN(알 수 없음)이 되어 짝이 맞지 않아요. 김민수도 남기려면 사원 쪽(E)을 기준으로 LEFT OUTER JOIN을 해요.

{EMPLOYEE_SIDE_OUTER_EXAMPLE.markdown}

김민수는 짝이 없어서 NULL 칸과 이어져요.

{EMPLOYEE_SIDE_OUTER_DIAGRAM_MD}

Oracle 방식으로는 NULL로 채워질 관리자 쪽(M)의 열에 `(+)`를 붙여 `WHERE E.관리자사번 = M.사번(+)`라고 써요. 기준을 잘못 골라 `사원 E RIGHT JOIN 사원 M ON E.관리자사번 = M.사번`이라고 쓰면 관리자 쪽(M)이 기준이 되어 다른 사람이 남아요.

| 단계 | 내용 |
|---|---|
| 짝이 맞는 행 | INNER JOIN과 같은 7행이에요. 김민수(3명), 이지은(2명), 최유나(2명)가 관리자 칸에 부하 수만큼 나와요 |
| 기준 쪽의 짝 없는 행 | 관리자 쪽에 놓인 8명 가운데 부하가 없는 박서준, 정하늘, 한도윤, 오지민, 윤서연이 사원 칸이 NULL인 행으로 하나씩 남아요 |
| 결과 | 7 + 5 = 12행이고, 김민수가 사원 칸에 나오는 행은 하나도 없어요. `(+)`를 사원 쪽에 붙인 `E.관리자사번(+) = M.사번`도 이와 같아요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `WHERE E.관리자사번 = M.사번(+)`는 김민수까지 8행을 돌려줘요 | O | 관리자 쪽에 `(+)`가 붙어서 사원 쪽이 기준이 돼요 |

## 관리자의 관리자: 같은 표를 세 번 {{#two-levels}}

관리자의 관리자를 찾으려면 사원 표를 한 번 더 읽어서, 관리자 쪽(M)의 관리자사번을 세 번째 별칭(T)의 사번과 이어요.

{TWO_LEVELS_EXAMPLE.markdown}

| 빠진 사람 | 이유 |
|---|---|
| 김민수 | 관리자사번이 NULL이라 첫 번째 조인에서 빠져요 |
| 이지은, 최유나, 윤서연 | 관리자인 김민수의 관리자사번이 NULL이라, 세 번째 표(T)에서 짝을 찾지 못해 두 번째 조인에서 빠져요 |

단계가 하나 늘 때마다 같은 표를 한 번씩 더 읽어야 해요. 조직도처럼 몇 단계인지 모르는 위아래 관계는 `START WITH`와 `CONNECT BY`를 쓰는 계층 쿼리로 따라가고, 9단원에서 배워요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 위 SQL의 결과에 이지은도 사원으로 나와요 | X | 이지은의 관리자 김민수는 관리자사번이 NULL이라 두 번째 조인에서 빠져요 |

## 조건의 방향: 바꾸면 역할도 바뀌어요 {{#direction}}

`E.관리자사번 = M.사번`에서는 E가 사원이고 M이 관리자예요. 조건을 `E.사번 = M.관리자사번`으로 바꾸면 E가 관리자, M이 부하가 돼요.

{REVERSED_DIRECTION_EXAMPLE.markdown}

짝지어지는 행은 똑같이 7행이지만 `E.이름`이 가리키는 사람이 달라져요. SELECT 절의 별칭과 조건을 함께 맞춰 읽어야 해요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 조건을 `E.사번 = M.관리자사번`으로 쓰면 E가 관리자 역할이 돼요 | O | E의 사번을 M의 관리자사번과 비교하니, E가 M의 관리자예요 |

## 자주 헷갈리는 점 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| 같은 표를 두 번 쓸 때는 테이블 이름을 접두사로 붙이면 돼요 | 두 표의 이름이 같아서 구분되지 않아요. 별칭이 없으면 ORA-00918(열 이름이 모호함) 오류가 나요 |
| 셀프 조인 결과는 관리자 수만큼 나와요 | 관리자가 있는 사원 수만큼 나와요. 부하가 여럿인 관리자는 부하 수만큼 반복돼요 |
| 김민수를 살리려면 아무 외부 조인이나 쓰면 돼요 | 사원 쪽(E)이 기준인 LEFT JOIN이어야 해요. RIGHT JOIN은 부하 없는 다섯 명을 관리자 칸에 남길 뿐이에요 |
| 셀프 조인 한 번으로 몇 단계든 따라갈 수 있어요 | 한 단계 늘 때마다 같은 표를 한 번 더 읽어요. 단계 수를 모르면 계층 쿼리를 써요 |
| 같은 표 안의 두 행 값은 서로 비교할 수 없어요 | 셀프 조인하면 사원 값과 관리자 값이 한 행에 나란히 놓여서 바로 비교할 수 있어요 |

```sql
SELECT 이름 FROM 사원, 사원 WHERE 사원.관리자사번 = 사원.사번;  -- 오류: 두 사원 표를 구분할 수 없어요 (ORA-00918, 열 이름이 모호함)
SELECT E.이름 FROM 사원 E, 사원 M WHERE E.관리자사번 = M.사번;   -- 별칭을 붙이면 실행돼요
```

아래 SQL은 사원의 급여와 관리자의 급여를 한 행에 놓고 비교해서, 자기 관리자보다 급여가 많은 사원을 찾아요.

{EARNS_MORE_EXAMPLE.markdown}

## 꼭 외울 것: 별칭 두 개와 기준 쪽 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| 별칭 없이 같은 표 두 번 | ORA-00918(열 이름이 모호함) 오류 |
| SELF JOIN 키워드 | 따로 없고, FROM에 같은 표를 두 번 써요 |
| 사원과 관리자를 잇는 조건 | E.관리자사번 = M.사번 (E는 사원, M은 관리자) |
| 셀프 조인 결과 행 수 | 관리자가 있는 사원 수, 관리자는 부하 수만큼 반복 |
| 최상위 관리자까지 남기기 | 사원 쪽(E) 기준 LEFT JOIN, 또는 M 쪽 열에 (+) |
| 조건 방향을 바꾸면 | E.사번 = M.관리자사번이면 E가 관리자 역할 |
| 관리자의 관리자 | 같은 표를 세 번 읽고, 단계 수를 모르면 계층 쿼리 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

| 나오는 문제 | 푸는 법 |
|---|---|
| 셀프 조인 결과가 몇 행인가 | 관리자사번이 NULL인 행부터 빼고 세요 |
| 특정 사원의 관리자, 관리자의 관리자 | E와 M의 역할을 한국어로 적고 조건을 따라가요 |
| 외부 조인이 붙은 셀프 조인 | 어느 쪽이 기준인지부터 확인하고, 기준 쪽의 짝 없는 행을 더해요 |
| 오류가 나는 SQL 고르기 | 같은 표를 두 번 쓰면서 별칭이 없는지 봐요 |""",
    "checkQuestions": [
        question(1, "사원 표 하나로 셀프 조인을 하려면 꼭 필요한 것은 무엇인가요?", "definition",
                 "셀프 조인은 같은 표를 두 번 읽으므로, 두 번 읽은 표를 구분할 서로 다른 별칭이 꼭 필요해요. 별도 키워드나 외부 조인은 필요하지 않아요.",
                 [choice("A", "SELF JOIN이라는 키워드", rationale="SELF JOIN이라는 키워드는 따로 없고 같은 표를 두 번 쓰면 돼요."),
                  choice("B", "이름이 같은 열을 가진 다른 표", rationale="셀프 조인은 다른 표 없이 같은 표끼리 이어요."),
                  choice("C", "같은 표에 붙인 서로 다른 별칭 두 개", True, "두 번 읽은 표를 구분하려면 별칭이 달라야 해요."),
                  choice("D", "LEFT OUTER JOIN", rationale="외부 조인은 짝 없는 행을 남길 때만 쓰고, 셀프 조인에 꼭 필요하지는 않아요.")]),
        question(2, "본문의 사원 표에서 관리자사번이 NULL인 사원은 김민수 한 명이에요. 다음 SQL은 몇 행을 돌려주나요?", "example",
                 "관리자사번이 NULL인 김민수는 짝이 맞지 않아 빠지고, 관리자가 있는 사원 7명이 한 행씩 나와요.",
                 [choice("A", "8행", rationale="관리자사번이 NULL인 김민수는 짝이 없어 빠져요."),
                  choice("B", "7행", True, "관리자가 있는 사원 7명만 짝이 맞아요."),
                  choice("C", "3행", rationale="관리자 수를 세었어요. 결과는 사원마다 한 행이에요."),
                  choice("D", "64행", rationale="64행은 조인 조건이 없을 때의 8 × 8 결과예요.")],
                 stem_sql=EMPLOYEE_MANAGER_SQL),
        question(3, "`SELECT E.이름 AS 사원, M.이름 AS 관리자`의 사원 칸에 김민수까지 8명이 모두 나오게 하려면 FROM 절을 어떻게 써야 하나요?", "outer",
                 "관리자사번이 NULL인 김민수를 남기려면 사원 쪽(E)을 기준으로 외부 조인해야 해요. 관리자 쪽(M)을 기준으로 하면 부하 없는 사원들이 관리자 칸에 남을 뿐이에요.",
                 [choice("A", "FROM 사원 E JOIN 사원 M ON E.관리자사번 = M.사번", rationale="INNER JOIN이라 김민수가 빠진 7행이 나와요."),
                  choice("B", "FROM 사원 E RIGHT JOIN 사원 M ON E.관리자사번 = M.사번", rationale="관리자 쪽이 기준이 되어 사원 칸이 NULL인 행만 늘어나요."),
                  choice("C", "FROM 사원 E, 사원 M WHERE E.관리자사번(+) = M.사번", rationale="사원 쪽에 (+)가 붙어 관리자 쪽이 기준인 RIGHT JOIN과 같아요."),
                  choice("D", "FROM 사원 E LEFT JOIN 사원 M ON E.관리자사번 = M.사번", True, "사원 쪽이 기준이라 김민수가 관리자 NULL로 남아요.")]),
        question(4, "본문의 사원 표에 다음 SQL을 실행하면 결과에서 '김민수'는 몇 번 나오나요?", "example",
                 "김민수를 관리자사번으로 가진 사원은 이지은, 최유나, 윤서연 세 명이에요. 관리자는 부하 수만큼 반복해서 나와요.",
                 [choice("A", "3번", True, "부하 세 명과 한 번씩 짝지어져요."),
                  choice("B", "1번", rationale="관리자는 한 번만 나오는 것이 아니라 부하 수만큼 반복돼요."),
                  choice("C", "0번", rationale="김민수는 사원 칸에서는 빠지지만 관리자 칸에는 나와요."),
                  choice("D", "7번", rationale="7은 전체 결과 행 수이고, 그중 김민수가 관리자인 행은 일부예요.")],
                 stem_sql=MANAGER_NAME_SQL),
        question(5, "아래 사원 표에 다음 SQL을 실행한 결과로 알맞은 것은 무엇인가요?\n\n" + EMPLOYEE_MANAGER_TABLE, "confusing",
                 "셀프 조인으로 사원의 급여와 관리자의 급여를 한 행에 놓고 비교해요. 최유나(3200)는 김민수(3000)보다, 박서준(2800)은 이지은(2500)보다 급여가 많아요.",
                 [choice("A", "최유나", rationale="박서준도 관리자 이지은보다 급여가 많아서 함께 나와요."),
                  choice("B", "최유나, 박서준", True, "두 사람만 자기 관리자보다 급여가 많아요."),
                  choice("C", "김민수, 이지은", rationale="이 두 사람은 관리자 쪽 값이고, SELECT 절은 사원 쪽 이름을 보여 줘요."),
                  choice("D", "0행", rationale="관리자보다 급여가 많은 사원이 두 명 있어요.")],
                 stem_sql=EARNS_MORE_THAN_MANAGER_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 예시 5개 (sql_example: 사원-관리자, 사원 쪽 외부 조인, 관리자의 관리자, 방향 바꾸기, 급여 비교)
        EMPLOYEE_MANAGER_EXAMPLE.check,
        EMPLOYEE_SIDE_OUTER_EXAMPLE.check,
        TWO_LEVELS_EXAMPLE.check,
        REVERSED_DIRECTION_EXAMPLE.check,
        EARNS_MORE_EXAMPLE.check,
        # 본문: ANSI 같은 결과, (+) 표기, 기준을 잘못 고른 RIGHT JOIN, 별칭 오류
        sql_check(EMPLOYEE_MANAGER_SQL, EMPLOYEE_MANAGER_ROWS),
        sql_check("SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E JOIN 사원 M ON E.관리자사번 = M.사번", EMPLOYEE_MANAGER_ROWS),
        sql_check("SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E, 사원 M WHERE E.관리자사번 = M.사번(+)",
                  EMPLOYEE_MANAGER_ROWS + [["김민수", None]]),
        sql_check("SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E RIGHT JOIN 사원 M ON E.관리자사번 = M.사번",
                  MANAGER_SIDE_OUTER_ROWS),
        sql_error_check("SELECT 이름 FROM 사원, 사원 WHERE 사원.관리자사번 = 사원.사번", "ORA-00918"),
        # 확인 문제: stemSql, 3번 보기 (RIGHT, (+) 오답)
        sql_check(MANAGER_NAME_SQL, [[manager] for _, manager in EMPLOYEE_MANAGER_ROWS]),
        sql_check(EARNS_MORE_THAN_MANAGER_SQL, [["최유나"], ["박서준"]]),
        sql_check("SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E RIGHT JOIN 사원 M ON E.관리자사번 = M.사번 WHERE E.이름 IS NULL",
                  MANAGER_SIDE_OUTER_ROWS[len(EMPLOYEE_MANAGER_ROWS):]),
        sql_check("SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E, 사원 M WHERE E.관리자사번(+) = M.사번",
                  MANAGER_SIDE_OUTER_ROWS),
    ],
}
