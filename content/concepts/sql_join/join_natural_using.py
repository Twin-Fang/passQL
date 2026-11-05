"""개념: NATURAL JOIN과 USING (5단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import (DEPARTMENT_ROWS, DEPARTMENT_TABLE_MD, EMPLOYEE_ROWS, EMPLOYEE_TABLE_MD,
                             SALARY_GRADE_TABLE_MD, to_markdown_table)

# 이름만 같고 뜻이 다른 열(이름) 함정용 표: 프로젝트번호, 이름(프로젝트 이름), 부서번호
PROJECT_ROWS = ((101, "신규 앱", 20), (102, "판촉 행사", 30))
PROJECT_TABLE_MD = to_markdown_table(("프로젝트번호", "이름", "부서번호"), PROJECT_ROWS)
PROJECT_SETUP_SQL = "\n".join(
    ["CREATE TABLE 프로젝트 (프로젝트번호 NUMBER(3), 이름 VARCHAR2(20), 부서번호 NUMBER(2));"]
    + [f"INSERT INTO 프로젝트 VALUES ({number}, '{name}', {department_number});"
       for number, name, department_number in PROJECT_ROWS])

# 본문·문제 공통 SQL
USING_SELECT_ALL_SQL = "SELECT * FROM 사원 JOIN 부서 USING (부서번호);"
USING_QUALIFIER_SQL = "SELECT E.부서번호 FROM 사원 E JOIN 부서 D USING (부서번호)"
PROJECT_NATURAL_COUNT_SQL = "SELECT COUNT(*) FROM 사원 NATURAL JOIN 프로젝트;"
GRADE_NATURAL_COUNT_SQL = "SELECT COUNT(*) FROM 사원 NATURAL JOIN 급여등급;"

# 사원·부서 이름+부서명 7행 (윤서연·인사부 제외)
NAME_DEPARTMENT_ROWS = [["김민수", "기획부"], ["이지은", "개발부"], ["박서준", "개발부"], ["정하늘", "개발부"],
                        ["최유나", "영업부"], ["한도윤", "영업부"], ["오지민", "영업부"]]
_DEPARTMENT_BY_NUMBER = {row[0]: row for row in DEPARTMENT_ROWS}
# USING·NATURAL 의 SELECT * 10열: 부서번호 > 사원 나머지 7열 > 부서 나머지 2열
USING_SELECT_ALL_ROWS = [[employee[7], *employee[:7], *_DEPARTMENT_BY_NUMBER[employee[7]][1:]]
                         for employee in EMPLOYEE_ROWS if employee[7] is not None]

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본, NATURAL 은 정렬 없어 순서 무시)
NATURAL_JOIN_EXAMPLE = sql_example(
    "SELECT 사번, 이름, 부서번호, 부서명\nFROM 사원 NATURAL JOIN 부서;",
    ("사번", "이름", "부서번호", "부서명"),
    [[row[0], row[1], row[7], _DEPARTMENT_BY_NUMBER[row[7]][1]] for row in EMPLOYEE_ROWS if row[7] is not None],
    is_ordered=False)
USING_JOIN_EXAMPLE = sql_example(
    "SELECT 이름, 부서명\nFROM 사원 JOIN 부서 USING (부서번호)\nORDER BY 부서번호, 이름;",
    ("이름", "부서명"),
    [["김민수", "기획부"], ["박서준", "개발부"], ["이지은", "개발부"], ["정하늘", "개발부"],
     ["오지민", "영업부"], ["최유나", "영업부"], ["한도윤", "영업부"]])

CONCEPT = {
    "tagKey": "join-natural-using",
    "topicCode": "sql_join",
    "sortOrder": 3,
    "title": "NATURAL JOIN과 USING",
    "summary": "이름이 같은 열로 알아서 잇는 NATURAL JOIN, 잇는 열을 고르는 USING이에요",
    "coreMd": (
        "- NATURAL JOIN은 이름이 같은 모든 열을 찾아, 그 값이 모두 같은 행끼리 등가 조인해요.\n"
        "- USING은 이름이 같은 열 가운데 조인에 쓸 열만 `USING (부서번호)`처럼 괄호 안에 적어요.\n"
        "- 두 방식 모두 조인에 쓴 공통 열에는 `E.부서번호`처럼 접두사를 붙일 수 없어요.\n"
        "- `SELECT *`로 보면 공통 열은 맨 앞에 한 번만 나와서, 사원과 부서를 ON으로 이을 때(11열)보다 하나 적은 10열이에요."
    ),
    "detailMd": f"""## 왜 필요한가요 — 같은 이름의 열이면 짧게 {{#why}}

사원과 부서를 이을 때마다 `ON E.부서번호 = D.부서번호`라고 쓰는데, 잇는 열의 이름이 두 표에서 똑같은 경우가 많아요. 이럴 때 조건을 짧게 쓰는 문법이 NATURAL JOIN과 USING이에요.

| 문법 | 잇는 열 | 쓸 수 있는 조건 |
|---|---|---|
| `ON 조건` | 조건에 적은 열 | `=`, BETWEEN 등 무엇이든 |
| `USING (열)` | 괄호 안에 고른 같은 이름의 열 | `=`만 (등가 조인) |
| `NATURAL JOIN` | 이름이 같은 모든 열 (데이터베이스가 찾음) | `=`만 (등가 조인) |

이 개념은 열 이름과 열 개수가 중요해서 표를 열까지 모두 보여 줘요. 사원 표(8열)와 부서 표(3열)에 똑같이 있는 열 이름은 부서번호 하나뿐이고, 급여등급 표(3열)는 사원 표와 같은 이름의 열이 없어요.

{EMPLOYEE_TABLE_MD}

{DEPARTMENT_TABLE_MD}

{SALARY_GRADE_TABLE_MD}

## NATURAL JOIN — 이름이 같은 열로 알아서 {{#natural}}

NATURAL JOIN은 ON 절 없이 쓰고, 데이터베이스가 이름이 같은 열을 스스로 찾아 그 값이 같은 행끼리 이어요. 사원과 부서는 부서번호만 이름이 같아서, 아래 SQL은 부서번호로 등가 조인한 것과 같아요.

{NATURAL_JOIN_EXAMPLE.markdown}

등가 조인이라서 부서번호가 NULL인 윤서연과 사원이 없는 인사부는 빠지고 7행이 나와요. SELECT 절의 `부서번호`에 `E.` 같은 접두사가 없어도 되는 까닭은 두 표의 부서번호가 하나의 열로 합쳐지기 때문이에요.

## USING — 잇는 열을 직접 골라요 {{#using}}

USING은 이름이 같은 열 가운데 조인에 쓸 열을 괄호 안에 적어요. `JOIN` 앞에 `INNER`를 붙여도 되고, 열이 여러 개면 `USING (열1, 열2)`처럼 쉼표로 나열해요.

{USING_JOIN_EXAMPLE.markdown}

`ORDER BY 부서번호, 이름`은 부서번호 순으로, 같은 부서 안에서는 이름 순으로 정렬하라는 뜻이에요. USING에 적은 부서번호도 하나의 열로 합쳐져서 ORDER BY에서 접두사 없이 쓸 수 있어요.

## 결과 열이 몇 개인가요 — 공통 열은 한 번만 {{#columns}}

`SELECT *`의 `*`는 모든 열을 보여 달라는 뜻이에요. 같은 조인을 세 가지 방식으로 쓰고 `SELECT *`로 보면 부서번호가 나오는 모양이 달라요.

| 방식 | SELECT * 열 수 | 부서번호 열 |
|---|---|---|
| `ON E.부서번호 = D.부서번호` | 8 + 3 = 11열 | 사원 쪽과 부서 쪽에 한 번씩, 두 번 나와요 |
| `USING (부서번호)` | 8 + 3 - 1 = 10열 | 맨 앞에 한 번만 나와요 |
| `NATURAL JOIN` | 8 + 3 - 1 = 10열 | 맨 앞에 한 번만 나와요 |

USING과 NATURAL JOIN은 열을 아래 순서로 늘어놓고, ON은 열을 합치지 않고 두 표의 열을 원래 순서대로 모두 이어 붙여요.

| 단계 | 내용 |
|---|---|
| 공통 열 | 부서번호가 맨 앞에 한 번 나와요 |
| 왼쪽 표의 나머지 | 사원 표의 사번, 이름, 직급, 관리자사번, 입사일, 급여, 커미션 7열이 이어져요 |
| 오른쪽 표의 나머지 | 부서 표의 부서명, 지역 2열이 끝에 붙어요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `사원 NATURAL JOIN 부서`를 `SELECT *`로 보면 첫 행은 10, 1001, 김민수 순서로 시작해요 | O | 공통 열인 부서번호가 맨 앞에 오고, 그 뒤에 사원 열이 이어져요 |

## 자주 헷갈리는 점 {{#confusing}}

외울 규칙은 하나예요. **NATURAL JOIN과 USING으로 합쳐진 열에는 접두사를 붙이지 않아요.**

| 헷갈리는 말 | 실제로는 |
|---|---|
| NATURAL JOIN에서도 공통 열에 `E.부서번호`처럼 접두사를 붙여야 정확해요 | 합쳐진 공통 열에 접두사를 붙이면 SELECT 절이든 WHERE 절이든 오류예요 (ORA-25155, 공통 열에 붙인 접두사) |
| USING에 쓴 열은 `E.부서번호`로 불러야 해요 | USING 열에도 접두사를 붙이면 오류예요 (ORA-25154, USING 열에 붙인 접두사). 괄호 안에 `USING (E.부서번호)`로 써도 오류예요 (ORA-01748, 열 이름만 쓸 수 있음) |
| NATURAL JOIN과 USING에서는 접두사를 아예 못 써요 | 공통 열이 아닌 `D.부서명` 같은 열에는 붙여도 괜찮아요 |
| NATURAL JOIN에 ON이나 USING을 덧붙여 잇는 열을 바꿀 수 있어요 | 둘 다 함께 쓸 수 없어서 ORA-00933(문법에 없는 단어) 오류가 나요 |
| NATURAL JOIN과 USING으로 BETWEEN 같은 범위 조건도 쓸 수 있어요 | 둘 다 `=`로 잇는 등가 조인만 해요. 비등가 조건은 ON 절로 써요 |
| 이름이 같은 열이 하나도 없으면 NATURAL JOIN은 오류가 나요 | 오류 없이 모든 행을 짝지어요. 사원 8행 × 급여등급 4행 = 32행이라서 행 수를 보고서야 알아채요 |
| 이름이 같은 열이면 데이터 타입이 달라도 이어져요 | 숫자와 날짜처럼 서로 비교할 수 없으면 ORA-00932(데이터 타입이 맞지 않음) 오류가 나요 |
| NATURAL JOIN은 잇고 싶은 열 하나로만 이어요 | 이름이 같은 열을 모두 비교해요. 이름만 같고 뜻이 다른 열이 있으면 엉뚱한 결과가 나와요 (아래 문단) |
| 두 문법은 SQL Server에서도 똑같이 써요 | ANSI 표준이라 Oracle은 지원하지만 SQL Server는 지원하지 않아서, SQL Server에서는 ON 절로 써요 |

```sql
SELECT E.부서번호 FROM 사원 E NATURAL JOIN 부서 D;                         -- 오류: 공통 열에 접두사를 붙였어요 (ORA-25155, 공통 열에 붙인 접두사)
SELECT 이름 FROM 사원 NATURAL JOIN 부서 WHERE 사원.부서번호 = 20;           -- 오류: WHERE 절에서도 같아요 (ORA-25155, 공통 열에 붙인 접두사)
SELECT E.부서번호 FROM 사원 E JOIN 부서 D USING (부서번호);                 -- 오류: USING 열에 접두사를 붙였어요 (ORA-25154, USING 열에 붙인 접두사)
SELECT 이름 FROM 사원 E JOIN 부서 D USING (E.부서번호);                     -- 오류: 괄호 안에는 열 이름만 써요 (ORA-01748, 열 이름만 쓸 수 있음)
SELECT D.부서명 FROM 사원 NATURAL JOIN 부서 D;                              -- 공통 열이 아니라서 실행돼요
SELECT 이름 FROM 사원 NATURAL JOIN 부서 ON 사원.부서번호 = 부서.부서번호;  -- 오류: NATURAL JOIN에는 ON을 함께 못 써요 (ORA-00933, 문법에 없는 단어)
SELECT 이름 FROM 사원 NATURAL JOIN 부서 USING (부서번호);                  -- 오류: USING도 함께 못 써요 (ORA-00933, 문법에 없는 단어)
```

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| USING 괄호 안에 `E.부서번호`처럼 접두사를 붙이면 오류가 나요 | O | 괄호 안에는 열 이름만 쓸 수 있어요 |
| `사원 NATURAL JOIN 부서`에 ON 절을 덧붙이면 그 조건이 먼저 적용돼요 | X | NATURAL JOIN에는 ON을 함께 쓸 수 없어서 오류가 나요 |

## 이름만 같은 열 — NATURAL JOIN의 함정 {{#same-name}}

프로젝트 이름을 `이름`이라는 열에 담은 프로젝트 표가 있으면, 사원 표와 이름이 같은 열이 부서번호와 이름 두 개가 돼요.

{PROJECT_TABLE_MD}

| 단계 | 내용 |
|---|---|
| NATURAL JOIN | 부서번호와 이름을 모두 비교해요. 사원 이름과 프로젝트 이름이 같은 행이 없어서 0행이에요 |
| USING (부서번호) | 부서번호만 하나의 열로 합쳐서 이어요. 20번과 30번 부서 사원 6명이 프로젝트와 짝지어져요 |
| 남은 이름 열 | USING에 적지 않은 이름은 사원 쪽과 프로젝트 쪽에 따로 남아서 `E.이름`, `P.이름`처럼 접두사를 붙여요 |

```sql
CREATE TABLE 프로젝트 (프로젝트번호 NUMBER(3), 이름 VARCHAR2(20), 부서번호 NUMBER(2));
INSERT INTO 프로젝트 VALUES (101, '신규 앱', 20);
INSERT INTO 프로젝트 VALUES (102, '판촉 행사', 30);
SELECT COUNT(*) FROM 사원 NATURAL JOIN 프로젝트;                                -- 부서번호와 이름을 함께 비교해서 0이 나와요
SELECT E.이름, P.이름 AS 프로젝트명 FROM 사원 E JOIN 프로젝트 P USING (부서번호);  -- 20번과 30번 부서 사원 6행이 나와요
SELECT 이름 FROM 사원 E JOIN 프로젝트 P USING (부서번호);                       -- 오류: 이름 열이 두 표에 다 있어요 (ORA-00918, 열 이름이 모호함)
```

`COUNT(*)`는 결과 행이 몇 개인지 세는 함수(7단원)이고, `AS 프로젝트명`은 결과 열에 보여 줄 이름을 바꾸는 별칭이에요. 접두사 규칙을 정리하면, 합쳐진 열에는 붙이지 않고 합쳐지지 않은 채 두 표에 같은 이름으로 있는 열에는 붙여요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

| 나오는 문제 | 푸는 법 |
|---|---|
| 오류가 나는 SQL 고르기 | 공통 열에 접두사가 붙었는지, NATURAL JOIN에 ON이나 USING이 붙었는지 봐요 |
| `SELECT *` 결과의 열 개수와 첫 열 | ON이면 두 표 열 수의 합, USING과 NATURAL이면 공통 열 수만큼 빼고, 첫 열은 공통 열이에요 |
| 같은 이름의 열이 둘 이상인 표의 NATURAL JOIN 행 수 | 이름이 같은 열을 모두 비교해서 짝을 세요 |
| 같은 이름의 열이 없는 표의 NATURAL JOIN 행 수 | 두 표 행 수를 곱해요 |""",
    "checkQuestions": [
        question(1, "NATURAL JOIN을 가장 알맞게 설명한 것은 무엇인가요?", "natural",
                 "NATURAL JOIN은 두 표에서 이름이 같은 모든 열을 찾아 그 값이 같은 행끼리 등가 조인해요. 잇는 열을 직접 고르는 것은 USING이에요.",
                 [choice("A", "ON 절에 적은 조건으로 두 표를 잇는다", rationale="NATURAL JOIN에는 ON 절을 함께 쓸 수 없어요."),
                  choice("B", "이름이 같은 모든 열의 값이 같은 행끼리 잇는다", True, "NATURAL JOIN의 정의예요."),
                  choice("C", "괄호 안에 적은 열만으로 두 표를 잇는다", rationale="잇는 열을 괄호 안에 고르는 것은 USING이에요."),
                  choice("D", "범위 조건으로 두 표를 잇는다", rationale="NATURAL JOIN은 = 연산자로 잇는 등가 조인만 해요.")]),
        question(2, "다음 중 실행하면 오류가 나는 SQL은 무엇인가요?", "confusing",
                 "USING에 쓴 부서번호는 합쳐진 하나의 열이라서 `E.부서번호`처럼 접두사를 붙이면 오류가 나요. 공통 열이 아닌 부서명에는 접두사를 붙여도 돼요.",
                 [choice("A", "SELECT 이름, 부서명 FROM 사원 NATURAL JOIN 부서", rationale="공통 열에 접두사를 붙이지 않았으니 정상 실행돼요."),
                  choice("B", "SELECT 부서번호, 이름 FROM 사원 JOIN 부서 USING (부서번호)", rationale="USING 열을 접두사 없이 썼으니 정상 실행돼요."),
                  choice("C", "SELECT D.부서명 FROM 사원 NATURAL JOIN 부서 D", rationale="부서명은 공통 열이 아니라서 접두사를 붙여도 돼요."),
                  choice("D", "SELECT E.부서번호 FROM 사원 E JOIN 부서 D USING (부서번호)", True,
                         "USING에 쓴 열에 접두사를 붙여서 오류가 나요.")]),
        question(3, "본문의 사원 표는 8열, 부서 표는 3열이에요. 다음 SQL의 결과는 몇 열인가요?", "columns",
                 "USING에 쓴 부서번호는 맨 앞에 한 번만 나와요. 그래서 8 + 3에서 겹치는 한 열을 뺀 10열이에요.",
                 [choice("A", "11열", rationale="11열은 ON으로 이어서 부서번호가 두 번 나올 때의 열 수예요."),
                  choice("B", "9열", rationale="공통 열은 하나라서 한 열만 빠져요."),
                  choice("C", "10열", True, "공통 열 부서번호가 한 번만 나와서 10열이에요."),
                  choice("D", "8열", rationale="부서 표의 부서명과 지역도 결과에 함께 나와요.")],
                 stem_sql=USING_SELECT_ALL_SQL),
        question(4, "아래 프로젝트 표에서 `이름`은 프로젝트 이름이에요. 본문의 사원 표와 이 표로 다음 SQL을 실행하면 결과는 무엇인가요? `COUNT(*)`는 결과 행의 개수를 세요.\n\n" + PROJECT_TABLE_MD, "confusing",
                 "사원 표와 프로젝트 표는 부서번호와 이름이 둘 다 같아서, NATURAL JOIN은 두 열을 모두 비교해요. 사원 이름과 프로젝트 이름이 같은 행이 없으니 0이에요.",
                 [choice("A", "0", True, "부서번호와 이름이 모두 같은 행이 없어요."),
                  choice("B", "6", rationale="부서번호만으로 이으면 6행이지만, NATURAL JOIN은 이름까지 비교해요."),
                  choice("C", "2", rationale="프로젝트 행 수를 세었어요. 결과는 짝이 맞는 행의 수예요."),
                  choice("D", "16", rationale="공통 열이 있으니 모든 행을 짝짓지 않아요.")],
                 stem_sql=PROJECT_NATURAL_COUNT_SQL),
        question(5, "본문의 사원 표(8행)와 급여등급 표(4행)에는 이름이 같은 열이 없어요. 다음 SQL의 결과는 무엇인가요?", "confusing",
                 "이름이 같은 열이 없으면 NATURAL JOIN은 비교할 조건 없이 모든 행을 짝지어요. 그래서 8 × 4 = 32예요.",
                 [choice("A", "0", rationale="같은 이름 열이 없다고 결과가 비지는 않고, 모든 행이 짝지어져요."),
                  choice("B", "8", rationale="급여 범위로 등급을 찾는 조건은 NATURAL JOIN이 만들지 않아요."),
                  choice("C", "32", True, "모든 행이 짝지어져 8 × 4행이 돼요."),
                  choice("D", "오류가 난다", rationale="공통 열이 없어도 오류 없이 실행돼요.")],
                 stem_sql=GRADE_NATURAL_COUNT_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 예시 2개 (sql_example: NATURAL JOIN, USING + 정렬)
        NATURAL_JOIN_EXAMPLE.check,
        USING_JOIN_EXAMPLE.check,
        # 본문: 열 개수·순서 (ON 11열, NATURAL 10열 + 첫 행 10, 1001, 김민수 ...)
        sql_check("SELECT * FROM 사원 NATURAL JOIN 부서", USING_SELECT_ALL_ROWS),
        sql_check("SELECT * FROM 사원 E JOIN 부서 D ON E.부서번호 = D.부서번호 WHERE E.사번 = 1001",
                  [[1001, "김민수", "사장", None, "2015-03-02", 3000, None, 10, 10, "기획부", "서울"]]),
        sql_check("SELECT * FROM 사원 NATURAL JOIN 부서 WHERE 사번 = 1001",
                  [[10, 1001, "김민수", "사장", None, "2015-03-02", 3000, None, "기획부", "서울"]]),
        # 본문: 함정 (두 열 비교, 타입 불일치)
        sql_check("SELECT COUNT(*) FROM 사원 JOIN 프로젝트 USING (부서번호, 이름)", [[0]], setup=PROJECT_SETUP_SQL),
        sql_error_check("SELECT 비고 FROM 사원 NATURAL JOIN 부서날짜", "ORA-00932",
                        setup="CREATE TABLE 부서날짜 (부서번호 DATE, 비고 VARCHAR2(10));\n"
                              "INSERT INTO 부서날짜 VALUES (DATE '2020-01-01', 'A');"),
        # 확인 문제: stemSql, 2번 보기 4개
        sql_check(USING_SELECT_ALL_SQL, USING_SELECT_ALL_ROWS),
        sql_check(PROJECT_NATURAL_COUNT_SQL, [[0]], setup=PROJECT_SETUP_SQL),
        sql_check("SELECT E.이름, P.이름 FROM 사원 E JOIN 프로젝트 P USING (부서번호)",
                  [["이지은", "신규 앱"], ["박서준", "신규 앱"], ["정하늘", "신규 앱"],
                   ["최유나", "판촉 행사"], ["한도윤", "판촉 행사"], ["오지민", "판촉 행사"]], setup=PROJECT_SETUP_SQL),
        sql_check(GRADE_NATURAL_COUNT_SQL, [[32]]),
        sql_check("SELECT 이름, 부서명 FROM 사원 NATURAL JOIN 부서", NAME_DEPARTMENT_ROWS),
        sql_check("SELECT 부서번호, 이름 FROM 사원 JOIN 부서 USING (부서번호)",
                  [[row[7], row[1]] for row in EMPLOYEE_ROWS if row[7] is not None]),
        sql_check("SELECT D.부서명 FROM 사원 NATURAL JOIN 부서 D", [[row[1]] for row in NAME_DEPARTMENT_ROWS]),
        sql_error_check(USING_QUALIFIER_SQL, "ORA-25154"),
    ],
}
