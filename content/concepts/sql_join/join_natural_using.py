"""개념: NATURAL JOIN과 USING (5단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
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

CONCEPT = {
    "tagKey": "join-natural-using",
    "topicCode": "sql_join",
    "sortOrder": 3,
    "title": "NATURAL JOIN과 USING",
    "summary": "이름이 같은 열로 알아서 잇는 NATURAL JOIN, 잇는 열을 고르는 USING이에요",
    "coreMd": (
        "- NATURAL JOIN은 두 표에서 이름이 같은 모든 열을 찾아, 그 값이 모두 같은 행끼리 등가 조인해요.\n"
        "- USING은 이름이 같은 열 가운데 조인에 쓸 열만 `USING (부서번호)`처럼 괄호 안에 적어요.\n"
        "- 두 방식 모두 조인에 쓴 공통 열에는 `E.부서번호`처럼 테이블 이름이나 별칭을 붙일 수 없고, 붙이면 오류가 나요.\n"
        "- `SELECT *`로 보면 공통 열은 결과 맨 앞에 한 번만 나와서, 사원과 부서를 ON으로 이을 때(11열)보다 하나 적은 10열이 돼요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

사원과 부서를 이을 때마다 `ON E.부서번호 = D.부서번호`라고 쓰는데, 두 표에서 잇는 열의 이름이 똑같은 경우가 많아요. 이렇게 열 이름이 같을 때 조건을 짧게 쓰도록 만든 문법이 NATURAL JOIN과 USING이에요. 둘 다 `=`로 잇는 등가 조인만 할 수 있고, BETWEEN 같은 비등가 조건은 ON 절로 써야 해요.

이 개념은 열 이름과 열 개수가 중요해서, 사원 표(8열)와 부서 표(3열)를 열까지 모두 보여 줄게요. 두 표에 똑같이 있는 열 이름은 부서번호 하나뿐이에요.

{EMPLOYEE_TABLE_MD}

{DEPARTMENT_TABLE_MD}

## NATURAL JOIN {{#natural}}

NATURAL JOIN은 ON 절 없이 쓰고, 데이터베이스가 두 표에서 이름이 같은 열을 스스로 찾아 그 값이 같은 행끼리 이어요. 사원 표와 부서 표에서 이름이 같은 열은 부서번호 하나뿐이라서, 아래 SQL은 부서번호로 등가 조인한 것과 같아요.

```sql
SELECT 사번, 이름, 부서번호, 부서명
FROM 사원 NATURAL JOIN 부서;
```

| 사번 | 이름 | 부서번호 | 부서명 |
|---|---|---|---|
| 1001 | 김민수 | 10 | 기획부 |
| 1002 | 이지은 | 20 | 개발부 |
| 1003 | 박서준 | 20 | 개발부 |
| 1004 | 최유나 | 30 | 영업부 |
| 1005 | 정하늘 | 20 | 개발부 |
| 1006 | 한도윤 | 30 | 영업부 |
| 1007 | 오지민 | 30 | 영업부 |

등가 조인이므로 부서번호가 NULL인 윤서연과 사원이 없는 인사부는 빠지고 7행이 나와요. SELECT 절에 `부서번호`를 `E.`나 `사원.` 같은 접두사 없이 썼는데도 오류가 나지 않는 점을 눈여겨봐 두세요. NATURAL JOIN에서는 두 표의 부서번호가 하나의 열로 합쳐지기 때문이에요.

## USING {{#using}}

USING은 이름이 같은 열 가운데 조인에 쓸 열을 직접 골라 괄호 안에 적어요. `JOIN` 앞에 `INNER`를 붙여도 되고, 열이 여러 개면 `USING (열1, 열2)`처럼 쉼표로 나열해요. 아래 SQL의 `ORDER BY 부서번호, 이름`은 결과를 부서번호 순으로, 같은 부서 안에서는 이름 순으로 정렬하라는 뜻이에요.

```sql
SELECT 이름, 부서명
FROM 사원 JOIN 부서 USING (부서번호)
ORDER BY 부서번호, 이름;
```

| 이름 | 부서명 |
|---|---|
| 김민수 | 기획부 |
| 박서준 | 개발부 |
| 이지은 | 개발부 |
| 정하늘 | 개발부 |
| 오지민 | 영업부 |
| 최유나 | 영업부 |
| 한도윤 | 영업부 |

USING에 적은 부서번호도 NATURAL JOIN처럼 하나의 열로 합쳐지므로, ORDER BY 절에서 접두사 없이 `부서번호`라고 쓸 수 있어요.

## 결과 열이 몇 개인가요 {{#columns}}

`SELECT *`의 `*`는 모든 열을 보여 달라는 뜻이에요. 위 표에서 본 것처럼 사원 표는 8열(사번, 이름, 직급, 관리자사번, 입사일, 급여, 커미션, 부서번호), 부서 표는 3열(부서번호, 부서명, 지역)이에요. 같은 조인을 세 가지 방식으로 쓰고 `SELECT *`로 보면, 부서번호가 나오는 모양이 달라요.

| 방식 | SELECT * 열 수 | 부서번호 열 |
|---|---|---|
| `ON E.부서번호 = D.부서번호` | 8 + 3 = 11열 | 사원 쪽과 부서 쪽에 한 번씩, 두 번 나와요 |
| `USING (부서번호)` | 8 + 3 - 1 = 10열 | 맨 앞에 한 번만 나와요 |
| `NATURAL JOIN` | 8 + 3 - 1 = 10열 | 맨 앞에 한 번만 나와요 |

USING과 NATURAL JOIN의 열 순서는 공통 열이 맨 앞에 오고, 그다음 왼쪽 표의 나머지 열, 오른쪽 표의 나머지 열 순서예요. 그래서 `사원 NATURAL JOIN 부서`의 첫 행은 부서번호 10, 그 뒤로 사원 열(1001, 김민수, 사장, ...), 마지막에 부서 열(기획부, 서울) 순서로 나와요. ON으로 이으면 열을 합치지 않고 두 표의 열을 원래 순서대로 모두 이어 붙여요.

## 자주 헷갈리는 점 {{#confusing}}

**공통 열에 접두사를 붙이면 오류가 나요.** NATURAL JOIN과 USING에서 조인에 쓴 열은 어느 한 표의 열이 아니라 합쳐진 하나의 열이에요. 그래서 SELECT 절이든 WHERE 절이든 `E.부서번호`나 `사원.부서번호`처럼 쓰면 오류가 나요. USING 괄호 안에 접두사를 붙여도 오류예요. 반대로 공통 열이 아닌 `D.부서명` 같은 열에는 접두사를 붙여도 괜찮아요.

```sql
SELECT E.부서번호 FROM 사원 E NATURAL JOIN 부서 D;                -- 오류: NATURAL JOIN의 공통 열에는 접두사를 붙일 수 없어요 (ORA-25155, 공통 열에 붙인 접두사)
SELECT 이름 FROM 사원 NATURAL JOIN 부서 WHERE 사원.부서번호 = 20;  -- 오류: WHERE 절에서도 공통 열에 접두사를 붙일 수 없어요 (ORA-25155, 공통 열에 붙인 접두사)
SELECT E.부서번호 FROM 사원 E JOIN 부서 D USING (부서번호);        -- 오류: USING에 쓴 열에도 접두사를 붙일 수 없어요 (ORA-25154, USING 열에 붙인 접두사)
SELECT 이름 FROM 사원 E JOIN 부서 D USING (E.부서번호);            -- 오류: USING 괄호 안에는 열 이름만 써요 (ORA-01748, 열 이름만 쓸 수 있음)
SELECT D.부서명 FROM 사원 NATURAL JOIN 부서 D;                     -- 공통 열이 아니라서 실행돼요
```

**NATURAL JOIN에는 ON 절도, USING도 함께 쓸 수 없어요.** NATURAL JOIN은 조인할 열을 데이터베이스가 정하므로 조건을 따로 적을 자리가 없어요. ON이나 USING을 덧붙이면 ORA-00933 오류가 나는데, 문법에 없는 단어가 문장 뒤에 붙었다는 뜻이에요.

```sql
SELECT 이름 FROM 사원 NATURAL JOIN 부서 ON 사원.부서번호 = 부서.부서번호;  -- 오류: NATURAL JOIN에는 ON을 함께 쓸 수 없어요 (ORA-00933, 문법에 없는 단어)
SELECT 이름 FROM 사원 NATURAL JOIN 부서 USING (부서번호);                  -- 오류: USING도 함께 쓸 수 없어요 (ORA-00933, 문법에 없는 단어)
```

**이름만 같고 뜻이 다른 열이 있으면 NATURAL JOIN은 엉뚱한 결과를 내요.** 프로젝트 이름을 `이름`이라는 열에 담은 프로젝트 표를 예로 들면 다음과 같아요.

{PROJECT_TABLE_MD}

이 표와 사원 표에는 이름이 같은 열이 부서번호와 이름, 두 개 있어요. 그래서 이 경우는 세 단계로 나눠 보면 이해하기 쉬워요.

1. NATURAL JOIN은 두 열을 모두 비교해서, 부서번호도 같고 이름도 같은 행만 이어요. 사원 이름과 프로젝트 이름이 같은 행은 없으니 결과는 0행이에요.
2. 부서번호로만 잇고 싶다면 `USING (부서번호)`처럼 잇는 열을 하나로 정해 줘요. 그러면 부서번호만 하나의 열로 합쳐지고, 20번과 30번 부서 사원 6명이 프로젝트와 짝지어져요.
3. USING에 적지 않은 `이름`은 합쳐지지 않고 사원 쪽과 프로젝트 쪽에 따로 남아요. 두 표에 같은 이름의 열이 따로 있으니, 이 열을 쓸 때는 보통의 조인처럼 `E.이름`, `P.이름`으로 접두사를 붙여야 해요.

정리하면 접두사 규칙은 하나예요. USING이나 NATURAL JOIN으로 합쳐진 열에는 접두사를 붙이지 않고, 합쳐지지 않았는데 두 표에 같은 이름으로 있는 열에는 접두사를 붙여요.

```sql
CREATE TABLE 프로젝트 (프로젝트번호 NUMBER(3), 이름 VARCHAR2(20), 부서번호 NUMBER(2));
INSERT INTO 프로젝트 VALUES (101, '신규 앱', 20);
INSERT INTO 프로젝트 VALUES (102, '판촉 행사', 30);
SELECT COUNT(*) FROM 사원 NATURAL JOIN 프로젝트;                                -- 부서번호와 이름을 함께 비교해서 0이 나와요
SELECT E.이름, P.이름 AS 프로젝트명 FROM 사원 E JOIN 프로젝트 P USING (부서번호);  -- 20번과 30번 부서 사원 6행이 나와요
SELECT 이름 FROM 사원 E JOIN 프로젝트 P USING (부서번호);                       -- 오류: 이름 열이 두 표에 다 있어요 (ORA-00918, 열 이름이 모호함)
```

위에서 `COUNT(*)`는 결과 행이 몇 개인지 세어 주는 함수(7단원)이고, `AS 프로젝트명`은 결과 열에 보여 줄 이름을 바꾸는 별칭이에요.

**이름이 같은 열이 하나도 없으면 NATURAL JOIN은 모든 행을 짝지어요.** 급여등급 표의 열은 등급, 최저급여, 최고급여라서 사원 표와 이름이 같은 열이 하나도 없어요.

{SALARY_GRADE_TABLE_MD}

그래서 `사원 NATURAL JOIN 급여등급`은 비교할 조건 없이 사원 8행 하나하나를 등급 4행과 모두 짝지어 8 × 4 = 32행을 만들어요. 오류가 나지 않으니 결과 행 수를 보고서야 알아채게 돼요. 반대로 이름이 같은 열이 있는데 데이터 타입이 숫자와 날짜처럼 서로 비교할 수 없으면 ORA-00932(데이터 타입이 맞지 않음) 오류가 나요.

**SQL Server에서는 두 문법을 쓸 수 없어요.** NATURAL JOIN과 USING은 ANSI 표준에 있고 Oracle은 지원하지만, SQL Server는 지원하지 않아요. SQL Server에서는 ON 절로 조건을 적어야 해요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

공통 열에 접두사를 붙인 SQL을 보여 주고 오류가 나는 것을 고르는 문제가 가장 자주 나와요. `SELECT *` 결과의 열 개수나 첫 번째 열을 묻는 문제도 흔한데, ON이면 두 표 열 수의 합이고 USING과 NATURAL JOIN이면 공통 열 수만큼 빼면 돼요. 이름이 같은 열이 두 개 이상인 표에 NATURAL JOIN을 써서 결과 행 수를 묻는 문제도 나와요.""",
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
        # 본문: NATURAL JOIN, USING, 열 개수·순서
        sql_check("SELECT 사번, 이름, 부서번호, 부서명 FROM 사원 NATURAL JOIN 부서",
                  [[1001, "김민수", 10, "기획부"], [1002, "이지은", 20, "개발부"], [1003, "박서준", 20, "개발부"],
                   [1004, "최유나", 30, "영업부"], [1005, "정하늘", 20, "개발부"], [1006, "한도윤", 30, "영업부"],
                   [1007, "오지민", 30, "영업부"]]),
        sql_check("SELECT 이름, 부서명 FROM 사원 JOIN 부서 USING (부서번호) ORDER BY 부서번호, 이름",
                  [["김민수", "기획부"], ["박서준", "개발부"], ["이지은", "개발부"], ["정하늘", "개발부"],
                   ["오지민", "영업부"], ["최유나", "영업부"], ["한도윤", "영업부"]], is_ordered=True),
        sql_check("SELECT * FROM 사원 NATURAL JOIN 부서", USING_SELECT_ALL_ROWS),
        sql_check("SELECT * FROM 사원 E JOIN 부서 D ON E.부서번호 = D.부서번호 WHERE E.사번 = 1001",
                  [[1001, "김민수", "사장", None, "2015-03-02", 3000, None, 10, 10, "기획부", "서울"]]),
        sql_check("SELECT * FROM 사원 NATURAL JOIN 부서 WHERE 사번 = 1001",
                  [[10, 1001, "김민수", "사장", None, "2015-03-02", 3000, None, "기획부", "서울"]]),
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
