"""개념: 별칭과 DISTINCT (2단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import to_employee_table_md

EMPLOYEE_GRADE_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "커미션", "부서번호")

CONCEPT = {
    "tagKey": "select-alias-distinct",
    "topicCode": "sql_basic_select",
    "sortOrder": 2,
    "title": "별칭과 DISTINCT",
    "summary": "열과 테이블에 짧은 이름을 붙이고, 겹치는 결과 행을 하나로 줄여요",
    "coreMd": (
        "- 열 별칭은 `급여 * 12 AS 연봉`처럼 붙이고 AS는 생략해도 되며, 공백·특수문자가 있거나 대소문자를 그대로 두려면 큰따옴표로 감싸요.\n"
        "- 테이블 별칭은 `FROM 사원 e`처럼 붙이는데, Oracle에서는 테이블 별칭 앞에 AS를 쓰면 오류가 나요.\n"
        "- 숫자와 NULL을 계산하면 NULL이 되지만, Oracle에서 `||`로 문자를 이을 때는 NULL을 빈 글자처럼 보고 이어 붙여요.\n"
        "- DISTINCT는 SELECT 바로 뒤에 한 번만 쓰고, 나열한 열 전체의 조합이 같은 행을 하나로 줄이며, NULL끼리도 하나로 묶어요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

SELECT 절에 `급여 * 12`처럼 계산식을 쓰면, 결과 표의 열 이름도 `급여*12`처럼 식 모양 그대로 나와요. 식이 길어질수록 결과를 읽기 어려워서, 열에 "연봉" 같은 알기 쉬운 이름을 따로 붙이는 기능이 있는데 이것을 **별칭**(alias)이라고 불러요.

또 사원 테이블에서 직급 열만 조회하면 8행이 나오지만, 실제로 어떤 직급이 있는지 알고 싶을 때는 '사원' 직급이 세 번 나올 필요가 없어요. 이렇게 겹치는 결과 행을 하나로 줄여 주는 키워드가 **DISTINCT**예요. 이 개념의 예시는 모두 아래 사원 표를 기준으로 해요.

{EMPLOYEE_GRADE_TABLE}

## 열 별칭 {{#column-alias}}

열 별칭은 열이나 계산식 뒤에 `AS 별칭`을 붙여서 만들어요. AS는 생략할 수 있어서, 열 뒤에 한 칸 띄우고 바로 이름을 적어도 같은 뜻이에요.

```sql
SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 WHERE 사번 = 1001;   -- 김민수, 36000이 나오고 열 이름은 연봉이에요
SELECT 이름, 급여 * 12 연봉 FROM 사원 WHERE 사번 = 1001;      -- AS를 빼도 결과가 같아요
```

별칭을 큰따옴표로 감싸야 하는 경우는 아래 네 가지예요.

1. 별칭 안에 공백이 들어 있을 때예요. (`"연 봉"`)
2. 괄호나 하이픈 같은 특수문자가 있거나, 숫자로 시작할 때예요. (`"1년급여"`)
3. SELECT, FROM처럼 SQL이 이미 명령어로 쓰는 단어를 별칭으로 쓸 때예요. 이런 단어를 **예약어**라고 불러요. (`"SELECT"`)
4. 영문 대소문자를 쓴 그대로 보여 주고 싶을 때예요. (`"Salary"`)

따옴표 없이 쓴 영문 별칭은 Oracle이 모두 대문자로 바꿔 저장하므로, `AS salary`라고 써도 결과 열 이름은 `SALARY`가 돼요.

```sql
SELECT 급여 * 12 AS "연 봉" FROM 사원 WHERE 사번 = 1001;       -- 공백이 있어서 큰따옴표가 필요해요
SELECT 급여 * 12 AS 연 봉 FROM 사원;                         -- 오류: 공백 뒤의 봉을 해석하지 못해요
SELECT 급여 AS "1년급여" FROM 사원 WHERE 사번 = 1001;          -- 숫자로 시작해서 큰따옴표가 필요해요
SELECT 급여 AS select FROM 사원;                             -- 오류: 예약어를 따옴표 없이 썼어요
SELECT 급여 AS "SELECT" FROM 사원 WHERE 사번 = 1001;          -- 큰따옴표로 감싸면 예약어도 별칭이 돼요
```

## 테이블 별칭 {{#table-alias}}

테이블에도 FROM 절에서 짧은 별칭을 붙일 수 있어요. `FROM 사원 e`라고 쓰면 이 문장 안에서는 사원 테이블을 `e`라고 부를 수 있고, 열 앞에 `e.이름`처럼 붙여서 어느 테이블의 열인지 밝혀요. 테이블 별칭은 조인에서 특히 많이 써요. **조인**은 두 테이블의 행을 같은 값끼리 짝지어 한 결과로 이어 붙이는 조회이고, 5단원에서 자세히 다뤄요. 아래 SQL은 FROM 절에 사원과 부서 두 테이블을 쉼표로 나열해서 함께 읽고, WHERE의 `e.부서번호 = d.부서번호`로 부서번호가 같은 행끼리 짝지어요. 두 테이블에 모두 부서번호 열이 있어서, `e.`과 `d.`을 붙여 어느 쪽 열인지 밝혀야 해요.

```sql
SELECT e.이름, d.부서명 FROM 사원 e, 부서 d WHERE e.부서번호 = d.부서번호 AND e.사번 = 1001;  -- 김민수, 기획부 한 행이 나와요
```

## 산술 연산과 문자 잇기 {{#operators}}

SELECT 절에서는 숫자 열에 `+`, `-`, `*`, `/`로 계산을 할 수 있어요. 수학처럼 곱셈과 나눗셈이 덧셈과 뺄셈보다 먼저 계산되고, 순서를 바꾸고 싶으면 괄호를 써요.

```sql
SELECT 급여 + 100 * 2 FROM 사원 WHERE 사번 = 1001;     -- 100 * 2를 먼저 계산해서 3200이에요
SELECT (급여 + 100) * 2 FROM 사원 WHERE 사번 = 1001;   -- 괄호 안을 먼저 계산해서 6200이에요
```

문자를 이어 붙이는 기호를 **합성 연산자**(연결 연산자)라고 하고, Oracle에서는 `||`를 써요. 열과 열, 열과 작은따옴표로 감싼 글자를 자유롭게 이을 수 있고, 숫자 열도 글자로 바뀌어 이어져요. `CONCAT(이름, 직급)`은 괄호 안의 두 값을 이어 주는 함수라서, 두 개만 이을 때는 `||` 대신 써도 돼요. CONCAT은 값을 두 개까지만 받으므로 셋 이상은 `||`로 잇는 편이 편해요.

```sql
SELECT 이름 || '의 급여는 ' || 급여 || '원' AS 안내 FROM 사원 WHERE 사번 = 1002;   -- 결과는 '이지은의 급여는 2500원'이에요
SELECT CONCAT(이름, 직급) FROM 사원 WHERE 사번 = 1001;                            -- 결과는 김민수사장이에요
```

## DISTINCT와 ALL {{#distinct}}

DISTINCT는 SELECT 바로 뒤에 써서, 결과에서 완전히 같은 행을 하나만 남겨요. 아무것도 쓰지 않으면 겹치는 행도 모두 보여 주는 **ALL**이 기본으로 적용돼서, `SELECT ALL 직급`과 `SELECT 직급`은 같은 결과가 나와요.

```sql
SELECT ALL 직급 FROM 사원;          -- 겹치는 값도 모두 나와요
SELECT DISTINCT 직급 FROM 사원;     -- 겹치는 값은 한 번만 나와요
```

| SQL | 결과 |
|---|---|
| `SELECT ALL 직급` | 8행: 사장, 과장, 대리, 부장, 사원, 대리, 사원, 사원 |
| `SELECT DISTINCT 직급` | 5행: 사장, 과장, 대리, 부장, 사원 |

## 자주 헷갈리는 점 {{#confusing}}

**DISTINCT는 열 하나가 아니라 나열한 열 전체의 조합을 봐요.** `SELECT DISTINCT 부서번호, 직급`은 "부서번호가 겹치지 않는 행"이 아니라 "부서번호와 직급이 둘 다 같은 행"을 하나로 줄여요. 그래서 직급만 보면 5행이던 결과가, 부서번호를 함께 쓰면 8행으로 늘어나요. '대리' 직급은 20번(박서준)과 30번(한도윤)에 한 명씩 있고, '사원' 직급은 20번, 30번, 부서 없음에 한 명씩 있어서, 조합으로 보면 겹치는 행이 하나도 없기 때문이에요.

```sql
SELECT DISTINCT 부서번호, 직급 FROM 사원;   -- 조합이 모두 달라서 8행이 나와요
SELECT 부서번호, DISTINCT 직급 FROM 사원;   -- 오류: DISTINCT는 SELECT 바로 뒤에만 와요
```

**DISTINCT는 NULL도 하나의 값처럼 묶어요.** `SELECT DISTINCT 부서번호`를 실행하면 10, 20, 30과 함께 윤서연의 NULL(값이 비어 있다는 표시)도 한 행으로 나와서 결과는 4행이에요. WHERE 절에서는 NULL끼리 비교해도 같다고 보지 않는데(WHERE 절과 NULL 개념에서 다뤄요), DISTINCT는 비교가 아니라 "겹치는 값을 하나로 줄이는 일"이라서 NULL을 한 묶음으로 다뤄요. 반대로 `COUNT(DISTINCT 부서번호)`처럼 개수를 세면 NULL은 빼고 3이 나오는데, 이 차이는 그룹 함수 단원에서 다시 다뤄요.

```sql
SELECT DISTINCT 부서번호 FROM 사원;   -- NULL도 한 행으로 나와요
```

| 부서번호 |
|---|
| 10 |
| 20 |
| 30 |
| NULL |

**테이블 별칭 앞에는 AS를 쓸 수 없어요.** 열 별칭에는 AS를 써도 되고 빼도 되지만, Oracle에서 `FROM 사원 AS e`라고 쓰면 오류가 나요. SQL Server는 테이블 별칭에도 AS를 허용하기 때문에, 시험에서 이 차이를 자주 물어요. 또 테이블에 별칭을 붙인 뒤에는 그 문장 안에서 원래 이름으로 열을 가리킬 수 없어서, `사원.이름`이 아니라 `e.이름`으로 써야 해요.

```sql
SELECT 이름 FROM 사원 AS e;                       -- 오류: Oracle은 테이블 별칭에 AS를 못 써요
SELECT 사원.이름 FROM 사원 e WHERE e.사번 = 1001;   -- 오류: 별칭을 붙였으면 별칭으로 불러야 해요
SELECT e.이름 FROM 사원 e WHERE e.사번 = 1001;      -- 김민수 한 명이 나와요
```

**별칭은 큰따옴표, 값은 작은따옴표예요.** `AS '연봉'`처럼 별칭을 작은따옴표로 감싸면 Oracle은 이를 별칭이 아니라 글자 값으로 읽어서 오류를 내요. 작은따옴표는 `'김민수'`처럼 데이터 값에만 쓰고, 이름(별칭)을 감쌀 때는 큰따옴표를 써요.

**큰따옴표로 만든 별칭은 대소문자까지 똑같이 불러야 해요.** `AS "Name"`으로 붙인 별칭을 ORDER BY에서 따옴표 없이 `Name`이라고 쓰면, Oracle은 이를 대문자 `NAME`으로 바꿔 찾기 때문에 오류가 나요. 큰따옴표로 만든 별칭은 쓸 때도 `"Name"`처럼 같은 모양으로 감싸야 해요.

```sql
SELECT 이름 AS "Name" FROM 사원 ORDER BY Name;     -- 오류: NAME이라는 이름은 없어요
SELECT 이름 AS "Name" FROM 사원 ORDER BY "Name";   -- 정상으로 실행돼요
```

**NULL이 섞이면 계산은 NULL이 되지만, 문자 잇기는 그렇지 않아요.** 김민수는 커미션이 NULL이라서 `급여 + 커미션`은 NULL이 돼요. 모르는 값에 무엇을 더해도 모르는 값이기 때문이에요. 하지만 Oracle에서 `이름 || 커미션`은 NULL을 빈 글자처럼 보고 이어 붙여서 `김민수`가 나와요. 같은 NULL인데 연산자에 따라 결과가 달라지니, 보기에 `||`와 NULL이 함께 나오면 이 점을 떠올리면 돼요.

```sql
SELECT 급여 + 커미션 FROM 사원 WHERE 사번 = 1001;          -- 결과는 NULL이에요
SELECT 이름 || '-' || 커미션 FROM 사원 WHERE 사번 = 1001;   -- 결과는 '김민수-'예요
```

## 시험에서는 이렇게 나와요 {{#exam-point}}

여러 SQL을 보여 주고 Oracle에서 오류가 나는 것을 고르는 문제가 많아요. 이때는 테이블 별칭 앞의 AS, 작은따옴표로 감싼 별칭, 공백이 있는데 큰따옴표가 없는 별칭, SELECT 중간에 들어간 DISTINCT를 차례로 확인하면 돼요. 그 밖에 DISTINCT를 쓴 SQL의 결과 행 수를 묻는 문제가 자주 나오는데, 나열한 열의 조합으로 세고 NULL도 한 행으로 센다는 점을 놓치지 않으면 돼요.""",
    "checkQuestions": [
        question(1, "다음 중 열 별칭을 큰따옴표로 감싸야 하는 경우는 무엇인가요?", "column-alias",
                 "공백이 있으면 데이터베이스가 별칭이 어디서 끝나는지 알 수 없어서 큰따옴표로 감싸야 해요. 한글 별칭이나 AS를 생략한 별칭은 따옴표 없이도 돼요.",
                 [choice("A", "별칭을 한글로 지을 때", rationale="한글 별칭은 따옴표 없이 써도 돼요."),
                  choice("B", "AS를 생략할 때", rationale="AS를 빼도 별칭은 따옴표 없이 쓸 수 있어요."),
                  choice("C", "별칭 안에 공백이 들어갈 때", True, "공백이 있으면 큰따옴표로 감싸야 별칭 하나로 읽혀요."),
                  choice("D", "계산식에 별칭을 붙일 때", rationale="계산식 뒤에도 따옴표 없는 별칭을 붙일 수 있어요.")]),
        question(2, "다음 중 Oracle에서 오류가 나는 SQL은 무엇인가요?", "confusing",
                 "Oracle은 테이블 별칭 앞에 AS를 쓰지 못하게 해요. 열 별칭은 AS를 써도 되고 빼도 돼요.",
                 [choice("A", "SELECT e.이름 FROM 사원 e", rationale="테이블 별칭을 AS 없이 붙인 올바른 문장이에요."),
                  choice("B", "SELECT 이름 FROM 사원 AS e", True, "테이블 별칭 앞의 AS 때문에 오류가 나요."),
                  choice("C", "SELECT 이름 AS 사원명 FROM 사원", rationale="열 별칭에는 AS를 쓸 수 있어요."),
                  choice("D", "SELECT 이름 사원명 FROM 사원", rationale="열 별칭은 AS를 생략해도 돼요.")]),
        question(3, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_GRADE_TABLE, "confusing",
                 "부서번호 값은 10, 20, 30과 윤서연의 NULL이에요. DISTINCT는 NULL도 한 값으로 묶어서 4행이 나와요.",
                 [choice("A", "3행", rationale="NULL을 뺐는데, DISTINCT는 NULL도 한 행으로 남겨요."),
                  choice("B", "8행", rationale="겹치는 부서번호가 하나로 줄어들어요."),
                  choice("C", "오류가 난다", rationale="DISTINCT를 SELECT 바로 뒤에 써서 문법상 문제가 없어요."),
                  choice("D", "4행", True, "10, 20, 30, NULL 네 값이 한 번씩 나와요.")],
                 stem_sql="SELECT DISTINCT 부서번호 FROM 사원;"),
        question(4, "`SELECT DISTINCT 부서번호, 직급 FROM 사원`에서 겹치는 행을 판단하는 기준은 무엇인가요?", "confusing",
                 "DISTINCT는 나열한 열 전체의 조합으로 겹침을 판단해요. 그래서 부서번호와 직급이 둘 다 같은 행만 하나로 줄어요.",
                 [choice("A", "부서번호와 직급의 조합", True, "두 열이 모두 같은 행만 하나로 줄여요."),
                  choice("B", "DISTINCT 바로 뒤의 부서번호만", rationale="DISTINCT는 바로 뒤 열 하나가 아니라 나열한 모든 열에 적용돼요."),
                  choice("C", "마지막에 쓴 직급만", rationale="열 하나만 기준으로 삼지 않아요."),
                  choice("D", "부서번호와 직급을 각각 따로", rationale="열마다 따로 줄이는 것이 아니라 행 전체를 비교해요.")]),
        question(5, "사번 1001 김민수(커미션 NULL)에 대해 다음 SQL을 Oracle에서 실행한 결과는 무엇인가요?", "confusing",
                 "Oracle의 `||`는 NULL을 빈 글자처럼 보고 이어 붙여요. 그래서 산술 연산과 달리 결과가 NULL이 되지 않아요.",
                 [choice("A", "NULL", rationale="NULL이 되는 것은 산술 연산이고, 문자 잇기는 NULL을 건너뛰어요."),
                  choice("B", "김민수-", True, "커미션 자리가 빈 글자처럼 이어져요."),
                  choice("C", "김민수-0", rationale="NULL을 0으로 바꾸지는 않아요."),
                  choice("D", "오류가 난다", rationale="숫자 열과 NULL도 오류 없이 이어 붙일 수 있어요.")],
                 stem_sql="SELECT 이름 || '-' || 커미션 FROM 사원 WHERE 사번 = 1001;"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        sql_check("SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 WHERE 사번 = 1001", [["김민수", 36000]]),
        sql_check("SELECT 이름, 급여 * 12 연봉 FROM 사원 WHERE 사번 = 1001", [["김민수", 36000]]),
        # 따옴표 없는 영문 별칭은 대문자로 저장 (바깥에서 "salary" 로 부르면 오류)
        sql_check("SELECT SALARY FROM (SELECT 급여 AS salary FROM 사원 WHERE 사번 = 1001)", [[3000]]),
        sql_error_check('SELECT "salary" FROM (SELECT 급여 AS salary FROM 사원 WHERE 사번 = 1001)', "ORA-00904"),
        sql_check('SELECT 급여 * 12 AS "연 봉" FROM 사원 WHERE 사번 = 1001', [[36000]]),
        sql_check('SELECT 급여 AS "1년급여" FROM 사원 WHERE 사번 = 1001', [[3000]]),
        sql_error_check("SELECT 급여 AS select FROM 사원", "ORA-00923"),
        sql_check('SELECT 급여 AS "SELECT" FROM 사원 WHERE 사번 = 1001', [[3000]]),
        sql_error_check("SELECT 급여 AS 1년급여 FROM 사원", "ORA-00923"),
        sql_error_check("SELECT 급여 AS '연봉' FROM 사원", "ORA-00923"),
        sql_check("SELECT e.이름, d.부서명 FROM 사원 e, 부서 d WHERE e.부서번호 = d.부서번호 AND e.사번 = 1001", [["김민수", "기획부"]]),
        sql_check("SELECT 급여 + 100 * 2 FROM 사원 WHERE 사번 = 1001", [[3200]]),
        sql_check("SELECT (급여 + 100) * 2 FROM 사원 WHERE 사번 = 1001", [[6200]]),
        sql_check("SELECT 이름 || '의 급여는 ' || 급여 || '원' AS 안내 FROM 사원 WHERE 사번 = 1002", [["이지은의 급여는 2500원"]]),
        sql_check("SELECT CONCAT(이름, 직급) FROM 사원 WHERE 사번 = 1001", [["김민수사장"]]),
        sql_check("SELECT ALL 직급 FROM 사원", [["사장"], ["과장"], ["대리"], ["부장"], ["사원"], ["대리"], ["사원"], ["사원"]]),
        sql_check("SELECT DISTINCT 직급 FROM 사원", [["사장"], ["과장"], ["대리"], ["부장"], ["사원"]]),
        sql_check("SELECT DISTINCT 부서번호, 직급 FROM 사원",
                  [[10, "사장"], [20, "과장"], [20, "대리"], [30, "부장"], [20, "사원"], [30, "대리"], [30, "사원"], [None, "사원"]]),
        sql_check("SELECT DISTINCT 부서번호 FROM 사원;", [[10], [20], [30], [None]]),
        sql_check("SELECT COUNT(DISTINCT 부서번호) FROM 사원", [[3]]),
        # 2번 문제 보기
        sql_check("SELECT e.이름 FROM 사원 e WHERE e.사번 = 1001", [["김민수"]]),
        sql_error_check("SELECT 이름 FROM 사원 AS e", "ORA-00933"),
        sql_error_check("SELECT 사원.이름 FROM 사원 e WHERE e.사번 = 1001", "ORA-00904"),
        sql_check("SELECT 이름 AS 사원명 FROM 사원 WHERE 사번 = 1001", [["김민수"]]),
        sql_check("SELECT 이름 사원명 FROM 사원 WHERE 사번 = 1001", [["김민수"]]),
        sql_error_check("SELECT 이름 AS \"Name\" FROM 사원 ORDER BY Name", "ORA-00904"),
        sql_check("SELECT 급여 + 커미션 FROM 사원 WHERE 사번 = 1001", [[None]]),
        sql_check("SELECT 이름 || '-' || 커미션 FROM 사원 WHERE 사번 = 1001;", [["김민수-"]]),
    ],
}
