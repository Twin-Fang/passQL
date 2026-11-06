"""개념: OUTER JOIN (5단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import DEPARTMENT_ROWS, DEPARTMENT_TABLE_MD, EMPLOYEE_ROWS, to_employee_table_md, to_markdown_table

# 외부 조인 계산에 쓰는 열만 (사번: COUNT(E.사번)·IS NULL, 급여: ON·WHERE 조건, 커미션: IS NULL 함정)
EMPLOYEE_JOIN_TABLE = to_employee_table_md("사번", "이름", "급여", "커미션", "부서번호")

# 본문·문제 공통 SQL
LEFT_JOIN_SQL = "SELECT E.이름, D.부서명 FROM 사원 E LEFT OUTER JOIN 부서 D ON E.부서번호 = D.부서번호"
FULL_JOIN_COUNT_SQL = "SELECT COUNT(*) FROM 사원 E FULL OUTER JOIN 부서 D ON E.부서번호 = D.부서번호;"
HIGH_SALARY_WHERE_SQL = ("SELECT D.부서명, E.이름 FROM 부서 D LEFT JOIN 사원 E "
                         "ON D.부서번호 = E.부서번호 WHERE E.급여 >= 3000;")
EMPTY_DEPARTMENT_SQL = ("SELECT D.부서명 FROM 부서 D LEFT JOIN 사원 E "
                        "ON D.부서번호 = E.부서번호 WHERE E.사번 IS NULL;")

# 짝이 맞는 7행 (이름, 부서명)
MATCHED_ROWS = [["김민수", "기획부"], ["이지은", "개발부"], ["박서준", "개발부"], ["정하늘", "개발부"],
                ["최유나", "영업부"], ["한도윤", "영업부"], ["오지민", "영업부"]]
LEFT_JOIN_ROWS = MATCHED_ROWS + [["윤서연", None]]
RIGHT_JOIN_ROWS = MATCHED_ROWS + [[None, "인사부"]]
FULL_JOIN_ROWS = MATCHED_ROWS + [["윤서연", None], [None, "인사부"]]
# 부서 기준, 급여 3000 이상 사원만 붙임 (조건을 ON 에 둔 결과 4행)
HIGH_SALARY_ON_ROWS = [["기획부", "김민수"], ["개발부", None], ["영업부", "최유나"], ["인사부", None]]
# 부서 기준 LEFT JOIN 8행 (부서명, 이름, 급여), WHERE 로 거르기 전 (인사부는 이름·급여 NULL)
DEPARTMENT_EMPLOYEE_SALARY_ROWS = [["기획부", "김민수", 3000], ["개발부", "이지은", 2500], ["개발부", "박서준", 2800],
                                   ["개발부", "정하늘", 2500], ["영업부", "최유나", 3200], ["영업부", "한도윤", 2700],
                                   ["영업부", "오지민", 2200], ["인사부", None, None]]
# ON <-> WHERE 예시의 급여 조건 (E.급여 >= 3000)
HIGH_SALARY_MINIMUM = 3000

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본, 정렬 없는 조인이라 순서 무시)
NAME_DEPARTMENT_COLUMNS = ("이름", "부서명")
LEFT_JOIN_EXAMPLE = sql_example(
    "SELECT E.이름, D.부서명\nFROM 사원 E LEFT OUTER JOIN 부서 D\n  ON E.부서번호 = D.부서번호;",
    NAME_DEPARTMENT_COLUMNS, LEFT_JOIN_ROWS, is_ordered=False)
RIGHT_JOIN_EXAMPLE = sql_example(
    "SELECT E.이름, D.부서명\nFROM 사원 E RIGHT OUTER JOIN 부서 D\n  ON E.부서번호 = D.부서번호;",
    NAME_DEPARTMENT_COLUMNS, RIGHT_JOIN_ROWS, is_ordered=False)
FULL_JOIN_EXAMPLE = sql_example(
    "SELECT E.이름, D.부서명\nFROM 사원 E FULL OUTER JOIN 부서 D\n  ON E.부서번호 = D.부서번호;",
    NAME_DEPARTMENT_COLUMNS, FULL_JOIN_ROWS, is_ordered=False)
# 같은 입력, 조건 위치만 다른 두 SQL (ON 4행 <-> WHERE 2행)
HIGH_SALARY_ON_EXAMPLE = sql_example(
    "SELECT D.부서명, E.이름\nFROM 부서 D LEFT JOIN 사원 E\n  ON D.부서번호 = E.부서번호 AND E.급여 >= 3000;",
    ("부서명", "이름"), HIGH_SALARY_ON_ROWS, is_ordered=False)
HIGH_SALARY_WHERE_EXAMPLE = sql_example(
    "SELECT D.부서명, E.이름\nFROM 부서 D LEFT JOIN 사원 E\n  ON D.부서번호 = E.부서번호\nWHERE E.급여 >= 3000;",
    ("부서명", "이름"), [["기획부", "김민수"], ["영업부", "최유나"]], is_ordered=False)
EMPTY_DEPARTMENT_EXAMPLE = sql_example(
    "SELECT D.부서명\nFROM 부서 D LEFT JOIN 사원 E\n  ON D.부서번호 = E.부서번호\nWHERE E.사번 IS NULL;",
    ("부서명",), [["인사부"]])
DEPARTMENT_COUNT_EXAMPLE = sql_example(
    "SELECT D.부서명, COUNT(*), COUNT(E.사번)\nFROM 부서 D LEFT JOIN 사원 E ON D.부서번호 = E.부서번호\n"
    "GROUP BY D.부서명;",
    ("부서명", "COUNT(*)", "COUNT(E.사번)"),
    [["기획부", 1, 1], ["개발부", 3, 3], ["영업부", 3, 3], ["인사부", 1, 0]], is_ordered=False)

# 그림 블록 (#853): 위 검증된 결과 행 > 잇는 값(부서번호)·거르는 값(급여)이 보이는 행 글
JOIN_DIAGRAM_COLUMNS = ("왼쪽 행", "오른쪽 행")
_EMPLOYEE_BY_NAME = {row[1]: row for row in EMPLOYEE_ROWS}
_DEPARTMENT_BY_NAME = {row[1]: row for row in DEPARTMENT_ROWS}


def _to_cell_text(value):
    """None > NULL (행 글 안의 빈 값 표시)"""
    return "NULL" if value is None else value


# 사원 기준 LEFT JOIN: "윤서연 (NULL)" | NULL 칸
LEFT_JOIN_DIAGRAM_MD = to_markdown_table(JOIN_DIAGRAM_COLUMNS, [
    [f"{name} ({_to_cell_text(_EMPLOYEE_BY_NAME[name][7])})",
     None if department is None else f"{department} ({_DEPARTMENT_BY_NAME[department][0]})"]
    for name, department in LEFT_JOIN_ROWS])
# 부서 기준, 급여 조건을 ON 에 둠: "기획부 (10)" | "김민수 3000" 또는 NULL 칸
HIGH_SALARY_ON_DIAGRAM_MD = to_markdown_table(JOIN_DIAGRAM_COLUMNS, [
    [f"{department} ({_DEPARTMENT_BY_NAME[department][0]})",
     None if name is None else f"{name} {_EMPLOYEE_BY_NAME[name][5]}"]
    for department, name in HIGH_SALARY_ON_ROWS])
# 급여 조건을 WHERE 에 둠: 조인 8행 > 급여 3000 이상만 남음 (NULL 급여도 빠짐)
HIGH_SALARY_WHERE_FILTER_DIAGRAM_MD = to_markdown_table(("행", "처리"), [
    [f"{department} {_to_cell_text(name)} {_to_cell_text(salary)}",
     "남음" if salary is not None and salary >= HIGH_SALARY_MINIMUM else "빠짐"]
    for department, name, salary in DEPARTMENT_EMPLOYEE_SALARY_ROWS])

CONCEPT = {
    "tagKey": "join-outer",
    "topicCode": "sql_join",
    "sortOrder": 4,
    "title": "OUTER JOIN",
    "summary": "짝이 없는 행도 버리지 않고, 모자란 쪽 열을 NULL로 채워 남겨요",
    "coreMd": (
        "- OUTER JOIN은 기준 표의 행을 짝이 없어도 **모두 남기고**, 짝이 없는 상대 쪽 열은 NULL로 채워요.\n"
        "- LEFT는 왼쪽, RIGHT는 오른쪽, FULL은 양쪽 표의 행을 모두 남기고, `OUTER`는 **생략**할 수 있어요.\n"
        "- Oracle의 `(+)`는 **NULL로 채워질 쪽** 열에 붙여서 `E.부서번호 = D.부서번호(+)`가 사원 기준 LEFT JOIN이고, `(+)`로는 FULL을 못 써요.\n"
        "- NULL로 채워지는 쪽 표의 조건을 WHERE에 두면 INNER JOIN처럼 되므로, 그 조건은 **ON에** 둬요."
    ),
    "detailMd": f"""## 왜 필요한가요 — 짝 없는 행도 남기기 {{#why}}

부서별 사원 수 보고서를 INNER JOIN으로 만들면, 사원이 없는 인사부는 "0명"으로 나오지 않고 아예 사라져요. 부서가 정해지지 않은 윤서연도 사원 명단에서 사라지기는 마찬가지예요.

이렇게 짝이 없는 행도 버리지 않고 남길 때 OUTER JOIN(외부 조인)을 써요. 예시는 모두 아래 사원 표(8명)와 부서 표(4개)로 계산하고, 사원 표는 계산에 쓰는 다섯 열만 보여요.

{EMPLOYEE_JOIN_TABLE}

{DEPARTMENT_TABLE_MD}

## 한 줄 정의 — 기준 표는 모두 남아요 {{#definition}}

| 용어 | 뜻 |
|---|---|
| OUTER JOIN (외부 조인) | 기준 표의 행을 짝이 있든 없든 모두 남기고, 짝이 없는 행은 상대 표의 열을 NULL로 채우는 조인이에요 |
| 기준 표 | 모든 행이 남는 쪽 표예요. LEFT는 왼쪽, RIGHT는 오른쪽, FULL은 양쪽 표가 기준이에요 |

| 종류 | 모두 남는 행 | 위 표로 계산한 결과 |
|---|---|---|
| `사원 E LEFT OUTER JOIN 부서 D` | 왼쪽 표(사원)의 모든 행 | 짝 7행 + 윤서연 = 8행 |
| `사원 E RIGHT OUTER JOIN 부서 D` | 오른쪽 표(부서)의 모든 행 | 짝 7행 + 인사부 = 8행 |
| `사원 E FULL OUTER JOIN 부서 D` | 양쪽 표의 모든 행 | 짝 7행 + 윤서연 + 인사부 = 9행 |

결과 행 수는 "짝이 맞는 행 수 + 기준 표에서 짝을 못 찾은 행 수"로 세요. `OUTER`는 생략할 수 있어서 `LEFT JOIN`이라고만 써도 같아요.

## LEFT·RIGHT·FULL — 같은 입력, 기준만 달라요 {{#right-full}}

{LEFT_JOIN_EXAMPLE.markdown}

괄호 안의 부서번호로 짝을 잇고, 짝이 없는 행은 NULL 칸과 이어져요.

{LEFT_JOIN_DIAGRAM_MD}

{RIGHT_JOIN_EXAMPLE.markdown}

{FULL_JOIN_EXAMPLE.markdown}

LEFT에서는 윤서연의 부서명이, RIGHT에서는 인사부의 이름이 NULL로 채워지고, FULL은 둘 다 남겨요. FULL이 LEFT 8행과 RIGHT 8행을 더한 16행이 아닌 까닭은, 짝이 맞는 7행이 양쪽에 똑같이 들어 있어 한 번만 세기 때문이에요.

표 순서를 바꿔 `부서 D LEFT JOIN 사원 E`라고 써도 기준이 부서 표가 되므로 RIGHT JOIN과 같은 결과가 나와요.

## Oracle의 (+) 표기 — 모자란 쪽에 붙여요 {{#oracle-plus}}

Oracle 방식은 WHERE 절의 조인 조건에 `(+)`를 붙여 외부 조인을 표시해요. `(+)`를 붙이는 자리는 짝이 없을 때 **NULL로 채워질 쪽** 표의 열이에요.

| 한 줄로 외우기 | 뜻 |
|---|---|
| (+)는 모자란 쪽에 붙여요 | 짝이 없을 때 NULL 행이 더해지는(+) 쪽 표의 열에 붙여요 |
| (+)가 없는 쪽이 기준이에요 | `E.부서번호 = D.부서번호(+)`는 사원이 기준이라 LEFT JOIN과 같아요 |

```sql
SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호(+);     -- 사원이 기준이라 LEFT JOIN과 같은 8행이 나와요
SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호(+) = D.부서번호;     -- 부서가 기준이라 RIGHT JOIN과 같은 8행이 나와요
SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호(+) = D.부서번호(+);  -- 오류: (+)는 양쪽에 붙일 수 없어요 (ORA-01468, 외부 조인 표시는 한쪽에만)
```

| (+)로 할 수 없는 것 | 결과 |
|---|---|
| 양쪽에 (+) 붙이기 | ORA-01468(외부 조인 표시는 한쪽에만) 오류예요. 그래서 FULL OUTER JOIN은 ANSI 문법으로만 써요 |
| (+)를 붙인 조건을 OR로 묶기 | ORA-01719(OR와 함께 쓸 수 없음) 오류예요 |
| `JOIN ... ON` 같은 ANSI 조인과 한 문장에 섞기 | ORA-25156(ANSI 조인과 섞을 수 없음) 오류예요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `(+)`를 양쪽 열에 붙이면 FULL OUTER JOIN을 만들 수 있어요 | X | 양쪽에 붙이면 오류라서 FULL은 ANSI 문법으로만 써요 |

## ON과 WHERE — 조건 위치가 결과를 바꿔요 {{#on-where}}

아래 두 SQL은 부서를 기준으로 급여 3000 이상인 사원을 붙이려는 것이고, 급여 조건의 위치만 달라요. 급여가 3000 이상인 사원은 김민수(기획부, 3000)와 최유나(영업부, 3200)뿐이에요.

{HIGH_SALARY_ON_EXAMPLE.markdown}

왼쪽은 부서명과 부서번호, 오른쪽은 짝지어진 사원의 이름과 급여예요.

{HIGH_SALARY_ON_DIAGRAM_MD}

{HIGH_SALARY_WHERE_EXAMPLE.markdown}

ON 절의 조건은 짝을 찾을 때 쓰여서, 급여 3000 이상인 사원이 없는 개발부와 인사부도 기준 행으로 남고 이름만 NULL이 돼요. WHERE 절의 조건은 조인이 끝난 뒤에 쓰여서 아래 순서로 행이 줄어요.

| 단계 | 내용 |
|---|---|
| 조인 | 급여와 상관없이 짝 7행과 (인사부, NULL) 1행, 모두 8행을 만들어요 |
| WHERE 거르기 | 급여 3000 미만인 다섯 행이 빠져요. 인사부 행도 급여가 NULL이라 `E.급여 >= 3000`이 UNKNOWN(알 수 없음)이 되어 빠져요 |
| 결과 | 김민수와 최유나 2행만 남아서, INNER JOIN에 같은 조건을 건 것과 같아져요 |

{HIGH_SALARY_WHERE_FILTER_DIAGRAM_MD}

## 짝 없는 행 찾기와 세기 — IS NULL과 COUNT {{#count}}

`IS NULL`은 값이 NULL인지 확인하는 조건이에요. 외부 조인으로 NULL이 채워진 행만 남기면 짝이 없는 쪽을 찾을 수 있어요.

{EMPTY_DEPARTMENT_EXAMPLE.markdown}

부서별 인원은 `COUNT(*)` 대신 `COUNT(상대 열)`로 세요. `GROUP BY D.부서명`은 부서명이 같은 행끼리 묶고, `COUNT(*)`는 묶음의 행 수를, `COUNT(E.사번)`은 사번이 NULL이 아닌 행 수를 세요(7단원 그룹 함수에서 다뤄요).

{DEPARTMENT_COUNT_EXAMPLE.markdown}

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 부서 기준 LEFT JOIN 뒤 `COUNT(*)`로 세면 인사부는 0이 나와요 | X | NULL로 채워진 한 행이 있어서 1이에요. 0을 보려면 `COUNT(E.사번)`을 써요 |

## 자주 헷갈리는 점 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| 외부 조인이니 조건을 WHERE에 둬도 짝 없는 행은 남아요 | NULL로 채워지는 쪽 표의 조건을 WHERE에 두면 NULL 행이 걸러져서 INNER JOIN처럼 돼요. 부서 기준 급여 조건을 WHERE에 두면 4행이 아니라 2행이에요 |
| (+) 표기에서는 조인 조건에만 (+)를 붙이면 돼요 | `(+)`가 붙은 조건은 ON처럼 짝을 찾는 데, 없는 조건은 WHERE처럼 거르는 데 쓰여요. 그래서 상대 표의 다른 조건에도 `E.급여(+) >= 3000`처럼 붙여야 ON에 둔 결과와 같아요 |
| 기준 표의 조건을 ON에 두면 기준 행이 걸러져요 | 걸러지지 않고 상대 열만 NULL이 돼요. `사원 E LEFT JOIN 부서 D ON E.부서번호 = D.부서번호 AND E.급여 >= 2800`은 8명이 모두 나오고 김민수, 박서준, 최유나만 부서명이 채워져요. 기준 행을 거르려면 WHERE에 둬요 |
| 짝 없는 행은 상대 표의 아무 열로나 IS NULL을 확인하면 돼요 | 사번처럼 원래 NULL이 없는 열로 확인해요. `E.커미션 IS NULL`로 확인하면 커미션이 NULL인 김민수(기획부), 최유나(영업부), 정하늘(개발부)도 걸려서 4행이 나와요 |
| (+)가 붙은 쪽이 기준 표예요 | `(+)`는 NULL로 채워질 쪽에 붙으니, 모든 행이 남는 기준 표는 `(+)`가 없는 쪽이에요 |

```sql
SELECT D.부서명, E.이름 FROM 부서 D, 사원 E WHERE D.부서번호 = E.부서번호(+) AND E.급여(+) >= 3000;  -- ON에 둔 것과 같은 4행이 나와요
SELECT D.부서명, E.이름 FROM 부서 D, 사원 E WHERE D.부서번호 = E.부서번호(+) AND E.급여 >= 3000;     -- WHERE에 둔 것과 같은 2행이 나와요
```

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 사원 기준 LEFT JOIN에서 사원 쪽 조건을 ON에 두면, 조건에 맞지 않는 사원도 결과에 남아요 | O | ON 조건은 짝을 찾을 때만 쓰여서, 기준 행은 상대 열이 NULL인 채로 남아요 |
| `WHERE E.부서번호 = D.부서번호(+)`의 기준 표는 사원이에요 | O | `(+)`가 없는 쪽이 기준이에요 |

## 꼭 외울 것 — 기준 표와 (+) 위치 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| LEFT·RIGHT·FULL의 기준 | 차례로 왼쪽 표, 오른쪽 표, 양쪽 표의 모든 행이 남아요 |
| 외부 조인 결과 행 수 | 짝 맞는 행 수 + 기준 표에서 짝을 못 찾은 행 수 |
| OUTER 키워드 | 생략할 수 있어서 LEFT JOIN만 써도 같아요 |
| (+)를 붙이는 쪽 | NULL로 채워질 쪽 열, 기준 표는 (+)가 없는 쪽 |
| (+)로 FULL 만들기 | 양쪽에 못 붙여서(ORA-01468) FULL은 ANSI 문법으로만 |
| 상대 표 조건을 WHERE에 | NULL 행이 걸러져 INNER JOIN처럼 돼요 |
| 기준 표 조건을 ON에 | 기준 행은 그대로 남고 상대 열만 NULL |
| 짝 없는 부서의 인원 | COUNT(*)는 1, COUNT(상대 열)은 0 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

| 나오는 문제 | 푸는 법 |
|---|---|
| LEFT, RIGHT, FULL 결과가 몇 행인가 | 짝이 맞는 행 수를 먼저 세고, 기준 표에서 짝을 못 찾은 행을 더해요 |
| ANSI 문법과 같은 (+) 표기 고르기 | `(+)`가 없는 쪽이 기준이고, 양쪽에 붙은 것은 오류예요 |
| 조건을 ON과 WHERE 중 어디에 뒀는가 | NULL로 채워지는 쪽 조건이 WHERE에 있으면 INNER JOIN처럼 세요 |
| 짝 없는 행 찾기, 부서별 인원 | IS NULL은 원래 NULL이 없는 열로, 인원은 COUNT(상대 열)로 세요 |""",
    "checkQuestions": [
        question(1, "`사원 E LEFT OUTER JOIN 부서 D ON E.부서번호 = D.부서번호`의 결과에 짝이 없어도 반드시 모두 남는 행은 무엇인가요?", "definition",
                 "LEFT OUTER JOIN은 왼쪽에 쓴 표를 기준으로 삼아요. 그래서 사원 표의 행은 짝이 없어도 모두 남고, 짝이 없는 부서 열은 NULL로 채워져요.",
                 [choice("A", "부서 표의 모든 행", rationale="부서 표를 모두 남기는 것은 RIGHT OUTER JOIN이에요."),
                  choice("B", "양쪽 표에 짝이 있는 행만", rationale="짝이 있는 행만 남기는 것은 INNER JOIN이에요."),
                  choice("C", "사원 표의 모든 행", True, "왼쪽 표가 기준이라 사원 8명이 모두 남아요."),
                  choice("D", "양쪽 표의 모든 행", rationale="양쪽을 모두 남기는 것은 FULL OUTER JOIN이에요.")]),
        question(2, "`FROM 사원 E LEFT OUTER JOIN 부서 D ON E.부서번호 = D.부서번호`와 같은 결과를 내는 Oracle 방식의 조건은 무엇인가요?", "oracle-plus",
                 "`(+)`는 NULL이 채워질 쪽 표의 열에 붙여요. 사원이 기준이면 짝이 없을 때 부서 열이 NULL로 채워지므로 부서 쪽 열에 붙여요.",
                 [choice("A", "FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호(+)", True, "부서 쪽에 (+)가 붙어 사원이 기준이 돼요."),
                  choice("B", "FROM 사원 E, 부서 D WHERE E.부서번호(+) = D.부서번호", rationale="사원 쪽에 (+)를 붙이면 부서가 기준인 RIGHT JOIN이 돼요."),
                  choice("C", "FROM 사원 E, 부서 D WHERE E.부서번호(+) = D.부서번호(+)", rationale="(+)는 양쪽에 붙일 수 없어서 오류가 나요."),
                  choice("D", "FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호", rationale="(+)가 없으면 짝이 있는 7행만 남는 등가 조인이에요.")]),
        question(3, "본문의 사원 표와 부서 표에서 사원 1008 윤서연은 부서가 없고, 부서 40 인사부는 사원이 없어요. 다음 SQL의 결과는 무엇인가요? `COUNT(*)`는 결과 행의 개수를 세요.", "right-full",
                 "짝이 맞는 7행에 짝이 없는 윤서연과 인사부가 한 행씩 더해져요. LEFT 8행과 RIGHT 8행을 단순히 더하지 않도록 주의해요.",
                 [choice("A", "7", rationale="짝이 있는 행만 센 INNER JOIN의 결과예요."),
                  choice("B", "8", rationale="한쪽의 짝 없는 행만 더한 LEFT나 RIGHT의 결과예요."),
                  choice("C", "16", rationale="짝이 맞는 7행은 한 번만 세므로 LEFT와 RIGHT를 단순히 더하지 않아요."),
                  choice("D", "9", True, "짝 7행에 윤서연과 인사부가 더해져요.")],
                 stem_sql=FULL_JOIN_COUNT_SQL),
        question(4, "급여가 3000 이상인 사원은 기획부의 김민수(3000)와 영업부의 최유나(3200)뿐이에요. 다음 SQL은 몇 행을 돌려주나요?", "confusing",
                 "조인 단계에서 인사부는 이름과 급여가 NULL인 행으로 남지만, WHERE 절에서 급여 조건이 UNKNOWN이 되어 빠져요. 급여 3000 미만인 사원 행도 함께 걸러져 김민수와 최유나 2행만 남아요.",
                 [choice("A", "4행", rationale="4행은 급여 조건을 ON 절에 두었을 때의 결과예요."),
                  choice("B", "2행", True, "WHERE 절이 NULL 행을 걸러서 김민수와 최유나만 남아요."),
                  choice("C", "8행", rationale="급여 조건 때문에 사원 대부분이 걸러져요."),
                  choice("D", "0행", rationale="김민수와 최유나는 급여 조건을 만족해서 남아요.")],
                 stem_sql=HIGH_SALARY_WHERE_SQL),
        question(5, "다음 SQL의 결과로 알맞은 것은 무엇인가요? `IS NULL`은 값이 NULL인지 확인하는 조건이에요.", "confusing",
                 "부서를 기준으로 외부 조인하면 사원이 없는 인사부만 사번이 NULL로 채워져요. WHERE 절이 그 행만 남기므로 인사부 한 행이 나와요.",
                 [choice("A", "인사부 1행", True, "짝이 없는 부서는 인사부 하나뿐이에요."),
                  choice("B", "0행", rationale="외부 조인이라 짝 없는 인사부가 NULL로 채워져 남아 있어요."),
                  choice("C", "기획부, 개발부, 영업부 3행", rationale="이 세 부서는 사원과 짝이 있어 사번이 NULL이 아니에요."),
                  choice("D", "부서 4개 모두", rationale="WHERE 절이 사번이 NULL인 행만 남겨요.")],
                 stem_sql=EMPTY_DEPARTMENT_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 예시 7개 (sql_example: LEFT·RIGHT·FULL, ON <-> WHERE, IS NULL, COUNT)
        LEFT_JOIN_EXAMPLE.check,
        RIGHT_JOIN_EXAMPLE.check,
        FULL_JOIN_EXAMPLE.check,
        HIGH_SALARY_ON_EXAMPLE.check,
        HIGH_SALARY_WHERE_EXAMPLE.check,
        EMPTY_DEPARTMENT_EXAMPLE.check,
        DEPARTMENT_COUNT_EXAMPLE.check,
        # 본문: LEFT 원문, 표 순서 바꾸기
        sql_check(LEFT_JOIN_SQL, LEFT_JOIN_ROWS),
        # 본문 거르기 그림: WHERE 로 거르기 전 부서 기준 8행
        sql_check("SELECT D.부서명, E.이름, E.급여 FROM 부서 D LEFT JOIN 사원 E ON D.부서번호 = E.부서번호",
                  DEPARTMENT_EMPLOYEE_SALARY_ROWS),
        sql_check("SELECT E.이름, D.부서명 FROM 부서 D LEFT JOIN 사원 E ON E.부서번호 = D.부서번호", RIGHT_JOIN_ROWS),
        # 본문: (+) 표기와 제약
        sql_check("SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호(+)", LEFT_JOIN_ROWS),
        sql_check("SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호(+) = D.부서번호", RIGHT_JOIN_ROWS),
        sql_error_check("SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호(+) = D.부서번호(+)", "ORA-01468"),
        sql_error_check("SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호(+) OR E.사번 = 1001", "ORA-01719"),
        sql_error_check("SELECT E.이름 FROM 사원 E JOIN 부서 D ON E.부서번호 = D.부서번호 WHERE D.지역(+) = '서울'", "ORA-25156"),
        # 본문: 헷갈리는 점 ((+) 다른 조건, 기준 표 조건, 커미션 IS NULL)
        sql_check("SELECT D.부서명, E.이름 FROM 부서 D, 사원 E WHERE D.부서번호 = E.부서번호(+) AND E.급여(+) >= 3000",
                  HIGH_SALARY_ON_ROWS),
        sql_check("SELECT D.부서명, E.이름 FROM 부서 D, 사원 E WHERE D.부서번호 = E.부서번호(+) AND E.급여 >= 3000",
                  [["기획부", "김민수"], ["영업부", "최유나"]]),
        sql_check("SELECT E.이름, D.부서명 FROM 사원 E LEFT JOIN 부서 D ON E.부서번호 = D.부서번호 AND E.급여 >= 2800",
                  [["김민수", "기획부"], ["박서준", "개발부"], ["최유나", "영업부"], ["이지은", None], ["정하늘", None],
                   ["한도윤", None], ["오지민", None], ["윤서연", None]]),
        sql_check("SELECT D.부서명 FROM 부서 D LEFT JOIN 사원 E ON D.부서번호 = E.부서번호 WHERE E.커미션 IS NULL",
                  [["기획부"], ["개발부"], ["영업부"], ["인사부"]]),
        # 확인 문제: stemSql, 2번 보기 4개
        sql_check(FULL_JOIN_COUNT_SQL, [[9]]),
        sql_check(HIGH_SALARY_WHERE_SQL, [["기획부", "김민수"], ["영업부", "최유나"]]),
        sql_check(EMPTY_DEPARTMENT_SQL, [["인사부"]]),
        sql_check("SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호", MATCHED_ROWS),
    ],
}
