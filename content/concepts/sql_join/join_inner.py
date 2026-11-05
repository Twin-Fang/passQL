"""개념: INNER JOIN (5단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import (DEPARTMENT_ROWS, DEPARTMENT_TABLE_MD, EMPLOYEE_ROWS, EMPLOYEE_TABLE_MD,
                             SALARY_GRADE_TABLE_MD, to_markdown_table)

# 본문·문제 공통 SQL
INNER_JOIN_COUNT_SQL = "SELECT COUNT(*) FROM 사원 E INNER JOIN 부서 D ON E.부서번호 = D.부서번호;"
SEOUL_ON_SQL = "SELECT E.이름, D.부서명 FROM 사원 E JOIN 부서 D ON E.부서번호 = D.부서번호 AND D.지역 = '서울';"
THREE_TABLES_SQL = ("SELECT E.이름, D.부서명, G.등급 FROM 사원 E "
                    "JOIN 부서 D ON E.부서번호 = D.부서번호 "
                    "JOIN 급여등급 G ON E.급여 BETWEEN G.최저급여 AND G.최고급여;")

# 사원·부서 INNER JOIN 결과 7행 (윤서연·인사부 제외)
INNER_JOIN_ROWS = [["김민수", "기획부"], ["이지은", "개발부"], ["박서준", "개발부"], ["정하늘", "개발부"],
                   ["최유나", "영업부"], ["한도윤", "영업부"], ["오지민", "영업부"]]
# 세 표 조인 결과 7행 (이름, 부서명, 등급)
THREE_TABLES_ROWS = [["김민수", "기획부", 4], ["이지은", "개발부", 2], ["정하늘", "개발부", 2], ["박서준", "개발부", 3],
                     ["오지민", "영업부", 1], ["한도윤", "영업부", 3], ["최유나", "영업부", 4]]
# 세 표 조인 예시의 WHERE G.등급 >= 3 (본문 결과 표·거르기 그림 공통)
MINIMUM_KEPT_GRADE = 3

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본, 정렬 없는 조인이라 순서 무시)
INNER_JOIN_EXAMPLE = sql_example(
    "SELECT E.이름, D.부서명\nFROM 사원 E INNER JOIN 부서 D\n  ON E.부서번호 = D.부서번호;",
    ("이름", "부서명"), INNER_JOIN_ROWS, is_ordered=False)
THREE_TABLES_GRADE_EXAMPLE = sql_example(
    "SELECT E.이름, D.부서명, G.등급\nFROM 사원 E\n  JOIN 부서 D ON E.부서번호 = D.부서번호\n"
    "  JOIN 급여등급 G ON E.급여 BETWEEN G.최저급여 AND G.최고급여\nWHERE G.등급 >= 3;",
    ("이름", "부서명", "등급"),
    [row for row in THREE_TABLES_ROWS if row[2] >= MINIMUM_KEPT_GRADE], is_ordered=False)

# 조인 연결 그림 (#853): 결과 행 > "이름 (부서번호)" | "부서명 (부서번호)"
_EMPLOYEE_BY_NAME = {row[1]: row for row in EMPLOYEE_ROWS}
_DEPARTMENT_BY_NAME = {row[1]: row for row in DEPARTMENT_ROWS}
INNER_JOIN_DIAGRAM_MD = to_markdown_table(("왼쪽 행", "오른쪽 행"), [
    [f"{name} ({_EMPLOYEE_BY_NAME[name][7]})", f"{department} ({_DEPARTMENT_BY_NAME[department][0]})"]
    for name, department in INNER_JOIN_ROWS])
# 행 거르기 그림 (#853): 세 표 조인 7행 > WHERE G.등급 >= 3 으로 남음·빠짐
GRADE_FILTER_DIAGRAM_MD = to_markdown_table(("행", "처리"), [
    [f"{name} {grade}등급", "남음" if grade >= MINIMUM_KEPT_GRADE else "빠짐"]
    for name, _department, grade in THREE_TABLES_ROWS])

CONCEPT = {
    "tagKey": "join-inner",
    "topicCode": "sql_join",
    "sortOrder": 2,
    "title": "INNER JOIN",
    "summary": "표준 문법으로 쓰는 조인이고, 양쪽 표에 짝이 있는 행만 남겨요",
    "coreMd": (
        "- INNER JOIN은 `표1 INNER JOIN 표2 ON 조건`으로 쓰는 ANSI 표준 조인이고, `JOIN`만 써도 같아요.\n"
        "- 양쪽에 짝이 있는 행만 남아서, 사원이 없는 부서 40과 부서가 없는 사원 1008은 빠져요.\n"
        "- ON에는 잇는 조건, WHERE에는 거르는 조건을 쓰고, INNER JOIN에서는 거르는 조건을 어느 쪽에 써도 결과가 같아요.\n"
        "- ON처럼 잇는 조건이 없으면 오류가 나고, 표가 세 개면 `JOIN ... ON`을 두 번 이어 써요."
    ),
    "detailMd": f"""## 왜 필요한가요 — 잇는 조건을 따로 적기 {{#why}}

Oracle 방식은 표를 잇는 조건과 행을 거르는 조건을 WHERE 절에 함께 적어서, 표가 늘면 어느 줄이 어떤 조건인지 구분하기 어려워요. 조인 조건 하나를 빠뜨려도 오류 없이 행만 불어나니 실수를 알아채기도 어려워요.

그래서 SQL 표준을 정하는 ANSI(미국 국가표준협회)가 잇는 조건을 FROM 절 안의 `ON`에 따로 쓰는 문법을 만들었어요.

| 구분 | Oracle 방식 | ANSI 방식 |
|---|---|---|
| 표 나열 | `FROM 사원, 부서` | `FROM 사원 JOIN 부서` |
| 잇는 조건 | WHERE 절 | ON 절 |
| 거르는 조건 | WHERE 절 | WHERE 절 |
| 쓸 수 있는 곳 | Oracle | Oracle, SQL Server, MySQL 등 |

## 한 줄 정의 — ON 조건에 맞는 짝만 남겨요 {{#definition}}

| 용어 | 뜻 |
|---|---|
| INNER JOIN (내부 조인) | 두 표에서 ON 절의 조건을 만족하는 행끼리만 짝지어 남기는 조인이에요 |
| ON 절 | 어떤 행끼리 짝지을지 적는 자리예요. `=`뿐 아니라 BETWEEN 같은 조건도 쓸 수 있어요 |

아래 문법 틀에서 대괄호 `[ ]`로 감싼 부분은 생략할 수 있다는 뜻이에요.

```sql
-- 문법
SELECT 열 목록
FROM 표1 [INNER] JOIN 표2
  ON 표1.열 = 표2.열
WHERE 거르는 조건;
```

## 예시 — Oracle 방식 등가 조인과 같은 결과 {{#example}}

이 개념의 예시는 모두 아래 사원 표(8명)와 부서 표(4개)로 계산하고, 표 세 개를 잇는 예시에서는 급여등급 표도 함께 써요.

{EMPLOYEE_TABLE_MD}

{DEPARTMENT_TABLE_MD}

{INNER_JOIN_EXAMPLE.markdown}

괄호 안의 부서번호가 같은 행끼리 선으로 이어져요.

{INNER_JOIN_DIAGRAM_MD}

`사원 E`, `부서 D`의 E와 D는 표에 붙인 별칭이에요. 결과는 Oracle 방식으로 `WHERE E.부서번호 = D.부서번호`라고 쓴 등가 조인과 똑같은 7행이고, 문법만 달라요.

## 짝이 없는 행은 빠져요 — 윤서연과 인사부 {{#unmatched}}

| 빠지는 행 | 이유 |
|---|---|
| 윤서연 (1008) | 부서번호가 NULL이에요. NULL과 `=`로 비교하면 참도 거짓도 아닌 UNKNOWN(알 수 없음)이 되고, 조인은 참인 짝만 남겨요 |
| 인사부 (40) | 부서번호 40을 가진 사원이 없어서 짝을 찾지 못해요 |

행 수만 궁금하면 `COUNT(*)`로 세요. `COUNT(*)`는 결과 행이 몇 개인지 세어 숫자 하나로 돌려주는 함수이고, 7단원에서 자세히 다뤄요.

```sql
SELECT COUNT(*)
FROM 사원 E INNER JOIN 부서 D
  ON E.부서번호 = D.부서번호;  -- 7이 나와요
```

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| INNER JOIN 결과에는 부서가 없는 사원도 부서명이 NULL인 채로 나와요 | X | 짝이 없는 행은 빠져요. NULL로 채워 남기는 것은 OUTER JOIN이에요 |

## ON 절과 WHERE 절 — INNER JOIN에서는 결과가 같아요 {{#on-where}}

| 절 | 쓰는 조건 | 언제 쓰이나 |
|---|---|---|
| ON | 두 표를 잇는 조건 | 짝을 지을 때 |
| WHERE | 원하는 행만 고르는 조건 | 짝을 다 지은 뒤 |

원칙은 위 표와 같지만, INNER JOIN에서는 거르는 조건을 ON 절에 `AND`로 붙여도 결과가 같아요. 짝이 맞지 않는 행은 어차피 버려지기 때문이에요.

```sql
SELECT E.이름, D.부서명 FROM 사원 E JOIN 부서 D ON E.부서번호 = D.부서번호 WHERE D.지역 = '서울';  -- 김민수(기획부) 한 행이 나와요
SELECT E.이름, D.부서명 FROM 사원 E JOIN 부서 D ON E.부서번호 = D.부서번호 AND D.지역 = '서울';    -- 같은 한 행이 나와요
```

인사부도 지역이 서울이지만 소속 사원이 없어서 조인 단계에서 이미 빠졌어요. OUTER JOIN에서는 이 두 SQL의 결과가 달라지고, 그 차이는 OUTER JOIN 개념에서 다뤄요.

## 표 세 개 이어 붙이기 — JOIN ... ON을 두 번 {{#three-tables}}

{SALARY_GRADE_TABLE_MD}

{THREE_TABLES_GRADE_EXAMPLE.markdown}

| 단계 | 내용 |
|---|---|
| 사원 JOIN 부서 | 부서번호로 이어서 7행이 돼요. 부서번호가 NULL인 윤서연은 여기서 빠져요 |
| JOIN 급여등급 | 7행마다 급여가 범위에 드는 등급 하나가 붙어요. ON 절에 BETWEEN을 쓴 비등가 조건이에요 |
| WHERE G.등급 >= 3 | 이어진 결과에서 3등급 이상인 4행만 골라요 |

{GRADE_FILTER_DIAGRAM_MD}

윤서연은 급여 2000으로 1등급과 짝이 맞지만, 첫 번째 조인에서 이미 빠졌기 때문에 등급 조건이 없어도 결과에 나오지 않아요.

## 자주 헷갈리는 점 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| `JOIN`만 쓰면 어떤 조인인지 정해지지 않아요 | `INNER`는 생략할 수 있어서 `JOIN`만 쓰면 INNER JOIN이에요. LEFT, RIGHT, FULL이 붙어야 OUTER JOIN이에요 |
| INNER JOIN은 ON 절 없이도 쓸 수 있어요 | 잇는 조건이 꼭 있어야 해요. ON 절이 기본이고 다음 개념의 USING으로도 쓸 수 있어요. 조건 없이 모두 짝짓는 문법은 CROSS JOIN이에요 |
| ON 절 안에서는 접두사를 붙이지 않아도 돼요 | `ON 부서번호 = 부서번호`는 어느 표의 열인지 몰라서 오류예요. ORDER BY에서 접두사 없이 `부서번호`를 써도 같은 오류가 나요 |
| INNER JOIN은 등가 조인만 뜻해요 | INNER JOIN은 짝이 있는 행만 남기는 방식이에요. ON에 `=`를 쓰면 등가 조인, BETWEEN을 쓰면 비등가 조인이에요 |
| 표 순서를 바꾸면 INNER JOIN 결과가 달라져요 | `사원 JOIN 부서`와 `부서 JOIN 사원`은 짝지어지는 행이 같아요. 순서가 결과를 바꾸는 것은 LEFT와 RIGHT가 붙는 OUTER JOIN뿐이에요 |

```sql
SELECT 이름 FROM 사원 JOIN 부서;                               -- 오류: ON 절이 없어요 (ORA-00905, 키워드가 빠짐)
SELECT 이름 FROM 사원 INNER JOIN 부서;                         -- 오류: INNER를 붙여도 ON 절이 없으면 같아요 (ORA-00905, 키워드가 빠짐)
SELECT E.이름 FROM 사원 E JOIN 부서 D ON 부서번호 = 부서번호;  -- 오류: 부서번호가 어느 표의 열인지 몰라요 (ORA-00918, 열 이름이 모호함)
```

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `부서 D JOIN 사원 E ON E.부서번호 = D.부서번호`도 7행을 돌려줘요 | O | INNER JOIN은 표 순서와 상관없이 짝이 같은 행을 남겨요 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

| 나오는 문제 | 푸는 법 |
|---|---|
| INNER JOIN 결과가 몇 행인가 | 양쪽 중 한쪽에라도 짝이 없는 행을 지우고 세요 |
| Oracle 방식 등가 조인과 같은 ANSI 문장 고르기 | WHERE의 잇는 조건이 ON으로 옮겨 갔는지 봐요 |
| `JOIN`과 `INNER JOIN`이 같은가 | INNER는 생략할 수 있어서 같아요 |
| 세 표 조인에서 빠지는 행 고르기 | 첫 번째 조인에서 빠진 행은 뒤 조인에도 나오지 않아요 |""",
    "checkQuestions": [
        question(1, "`사원 E INNER JOIN 부서 D ON E.부서번호 = D.부서번호`와 항상 같은 결과를 내는 것은 무엇인가요?", "confusing",
                 "`INNER`는 생략할 수 있어서 `JOIN`만 써도 INNER JOIN이에요. LEFT, FULL, CROSS가 붙으면 다른 조인이 돼요.",
                 [choice("A", "사원 E LEFT JOIN 부서 D ON E.부서번호 = D.부서번호", rationale="LEFT JOIN은 짝이 없는 사원 윤서연까지 남겨서 8행이 나와요."),
                  choice("B", "사원 E FULL JOIN 부서 D ON E.부서번호 = D.부서번호", rationale="FULL JOIN은 양쪽의 짝 없는 행을 모두 남겨서 9행이 나와요."),
                  choice("C", "사원 E JOIN 부서 D ON E.부서번호 = D.부서번호", True, "INNER를 생략한 같은 문장이라서 7행이 나와요."),
                  choice("D", "사원 E CROSS JOIN 부서 D", rationale="CROSS JOIN은 조건 없이 모든 행을 짝지어 32행이 나와요.")]),
        question(2, "본문의 사원 표(8명)와 부서 표(4개)에 다음 SQL을 실행하면 결과는 무엇인가요? `COUNT(*)`는 결과 행의 개수를 세요.", "unmatched",
                 "INNER JOIN은 양쪽에 짝이 있는 행만 남겨요. 부서번호가 NULL인 윤서연과 사원이 없는 인사부가 빠져서 7이 나와요.",
                 [choice("A", "7", True, "짝이 맞는 사원 7명만 세어요."),
                  choice("B", "8", rationale="부서번호가 NULL인 윤서연은 짝이 맞지 않아 빠져요."),
                  choice("C", "9", rationale="짝이 없는 윤서연과 인사부는 INNER JOIN 결과에 들어가지 않아요."),
                  choice("D", "4", rationale="부서 수를 세었어요. 결과는 짝지어진 사원 행의 수예요.")],
                 stem_sql=INNER_JOIN_COUNT_SQL),
        question(3, "사원 표와 부서 표를 부서번호로 INNER JOIN했을 때, 결과에서 빠지는 행을 바르게 설명한 것은 무엇인가요?", "unmatched",
                 "윤서연은 부서번호가 NULL이라 짝이 없고, 인사부는 소속 사원이 없어 짝이 없어요. INNER JOIN은 이 두 행을 모두 버려요.",
                 [choice("A", "부서가 없는 사원 윤서연만 빠진다", rationale="사원이 없는 인사부도 짝이 없어서 함께 빠져요."),
                  choice("B", "사원이 없는 부서 인사부만 빠진다", rationale="부서번호가 NULL인 윤서연도 짝이 없어서 함께 빠져요."),
                  choice("C", "빠지는 행이 없다", rationale="INNER JOIN은 짝이 없는 행을 남기지 않아요."),
                  choice("D", "윤서연과 인사부가 둘 다 빠진다", True, "양쪽 모두 짝이 없는 행이라 빠져요.")]),
        question(4, "부서 표에서 지역이 서울인 부서는 기획부(10)와 인사부(40)예요. 다음 SQL의 결과는 몇 행인가요?", "on-where",
                 "INNER JOIN에서는 거르는 조건을 ON 절에 붙여도 WHERE 절에 쓴 것과 같아요. 인사부는 소속 사원이 없어 짝이 없으므로 김민수 한 행만 남아요.",
                 [choice("A", "2행", rationale="인사부는 서울이지만 소속 사원이 없어서 짝이 맞지 않아요."),
                  choice("B", "1행", True, "서울 부서 중 짝이 있는 사원은 기획부의 김민수뿐이에요."),
                  choice("C", "8행", rationale="INNER JOIN은 짝이 맞지 않는 사원을 남기지 않아요."),
                  choice("D", "0행", rationale="기획부와 김민수는 부서번호도 맞고 지역도 서울이라 남아요.")],
                 stem_sql=SEOUL_ON_SQL),
        question(5, "본문의 사원·부서·급여등급 표로 다음 SQL을 실행했을 때, 결과에 나오지 않는 사원은 누구인가요?", "three-tables",
                 "윤서연은 급여 2000으로 1등급과 짝이 맞지만, 부서번호가 NULL이라 첫 번째 조인에서 이미 빠져요. 나머지 일곱 명은 부서와 등급 모두 짝이 있어요.",
                 [choice("A", "오지민", rationale="급여 2200으로 1등급과 짝이 맞고 영업부도 있어서 결과에 나와요."),
                  choice("B", "윤서연", True, "부서번호가 NULL이라 부서와의 조인에서 빠져요."),
                  choice("C", "최유나", rationale="급여 3200으로 4등급과 짝이 맞고 영업부도 있어서 결과에 나와요."),
                  choice("D", "김민수", rationale="급여 3000으로 4등급과 짝이 맞고 기획부도 있어서 결과에 나와요.")],
                 stem_sql=THREE_TABLES_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 예시 2개 (sql_example: 기본 INNER JOIN, 세 표 조인 + 등급 거르기)
        INNER_JOIN_EXAMPLE.check,
        THREE_TABLES_GRADE_EXAMPLE.check,
        # 본문: ON·WHERE, 세 표 조인, 표 순서, 접두사·ON 누락 오류
        sql_check("SELECT E.이름, D.부서명 FROM 사원 E JOIN 부서 D ON E.부서번호 = D.부서번호 WHERE D.지역 = '서울'",
                  [["김민수", "기획부"]]),
        sql_check(SEOUL_ON_SQL, [["김민수", "기획부"]]),
        sql_check(THREE_TABLES_SQL, THREE_TABLES_ROWS),
        sql_check("SELECT E.이름, D.부서명 FROM 부서 D JOIN 사원 E ON E.부서번호 = D.부서번호", INNER_JOIN_ROWS),
        sql_error_check("SELECT E.이름, D.부서명 FROM 사원 E JOIN 부서 D ON E.부서번호 = D.부서번호 ORDER BY 부서번호", "ORA-00918"),
        sql_error_check("SELECT 이름 FROM 사원 JOIN 부서", "ORA-00905"),
        # 확인 문제: stemSql, 1번 보기 4개
        sql_check(INNER_JOIN_COUNT_SQL, [[7]]),
        sql_check("SELECT E.이름, D.부서명 FROM 사원 E JOIN 부서 D ON E.부서번호 = D.부서번호", INNER_JOIN_ROWS),
        sql_check("SELECT COUNT(*) FROM 사원 E LEFT JOIN 부서 D ON E.부서번호 = D.부서번호", [[8]]),
        sql_check("SELECT COUNT(*) FROM 사원 E FULL JOIN 부서 D ON E.부서번호 = D.부서번호", [[9]]),
        sql_check("SELECT COUNT(*) FROM 사원 E CROSS JOIN 부서 D", [[32]]),
    ],
}
