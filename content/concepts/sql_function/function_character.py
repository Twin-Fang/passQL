"""개념: 문자 함수 (4단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import to_employee_table_md

EMPLOYEE_DEPARTMENT_TABLE = to_employee_table_md("사번", "이름", "부서번호")

CONCEPT = {
    "tagKey": "function-character",
    "topicCode": "sql_function",
    "sortOrder": 1,
    "title": "문자 함수",
    "summary": "문자를 자르고 찾고 바꾸는 함수이고, 비슷한 짝끼리의 차이를 자주 물어요",
    "coreMd": (
        "- 단일행 함수는 행마다 결과를 하나씩 돌려주고, 함수 안에 함수를 넣으면 가장 안쪽부터 계산해요.\n"
        "- `SUBSTR`는 잘라 낸 문자를, `INSTR`는 찾은 위치 숫자를 돌려주고, 위치는 1부터 세며 음수 위치는 뒤에서 세요.\n"
        "- `REPLACE`는 문자열 덩어리를 통째로 바꾸고, `TRANSLATE`는 글자 하나하나를 짝지어 바꿔요.\n"
        "- `LTRIM`과 `RTRIM`은 지울 글자를 여러 개 받을 수 있지만, `TRIM`은 한 글자만 받고 방향을 생략하면 양쪽을 지워요.\n"
        "- `CONCAT`은 인자를 두 개만 받으므로 셋 이상 이을 때는 `||`를 쓰고, Oracle에서는 NULL을 이어 붙여도 NULL이 되지 않아요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

사원 표에는 이름이 "김민수"처럼 그대로 저장되어 있지만, 화면에 보여 줄 때는 성만 남기고 "김**"처럼 가리거나 번호 앞에 0을 채워 자릿수를 맞추고 싶을 때가 있어요. 저장된 값은 그대로 두고 꺼내 보여 줄 때만 모양을 바꾸려면 함수를 써요. 함수는 괄호 안에 값을 넣으면 정해진 규칙대로 바꾼 값을 돌려주는 도구이고, 괄호 안에 넣는 값을 인자라고 불러요.

문자 함수는 그중에서 문자(글자로 된 값)를 다루는 함수예요. 종류는 많지만 이름이 하는 일을 거의 그대로 말해 주기 때문에, 시험에서는 함수 하나하나의 뜻보다 비슷하게 생긴 함수끼리 결과가 어떻게 다른지를 더 자주 물어요.

## 단일행 함수와 DUAL {{#definition}}

이 단원에서 배우는 문자·숫자·날짜·변환·NULL 함수는 모두 단일행 함수예요. 단일행 함수는 행 하나를 받을 때마다 결과를 하나씩 돌려주기 때문에, 사원 8명에게 쓰면 결과도 8개가 나와요. 여러 행을 묶어 결과 하나를 만드는 `SUM`, `MAX` 같은 함수는 다중행 함수(집계 함수)라고 부르고, 그룹 함수 단원에서 따로 다뤄요.

단일행 함수는 SELECT 절뿐 아니라 WHERE 절과 ORDER BY 절에도 쓸 수 있어요. 인자를 여러 개 받는 함수라도 결과는 하나이고, 함수 안에 다른 함수를 넣는 중첩도 할 수 있는데 이때는 가장 안쪽 함수부터 계산해요.

표 없이 함수 결과만 확인하고 싶을 때는 `DUAL`을 써요. DUAL은 Oracle이 준비해 둔 한 행짜리 테이블이라서, `FROM DUAL`이라고 쓰면 계산 결과가 한 줄로 나와요. 아래 둘째 SQL의 `||`는 문자를 이어 붙이는 연산자인데, 뒤에서 다시 설명해요. 둘째 SQL은 아래 사원 표에서 부서번호가 20인 세 명의 이름을 성만 남기고 가려요.

{EMPLOYEE_DEPARTMENT_TABLE}

```sql
SELECT LOWER(SUBSTR('SQL Developer', 5)) FROM DUAL;   -- SUBSTR가 먼저, LOWER가 나중에 계산돼서 developer가 나와요
SELECT 이름, SUBSTR(이름, 1, 1) || '**' FROM 사원 WHERE 부서번호 = 20;
```

둘째 SQL은 WHERE 절이 남긴 20번 부서 세 명에게 결과를 하나씩 돌려주므로, 결과도 세 행이에요.

| 이름 | 가린 이름 |
|---|---|
| 이지은 | `이**` |
| 박서준 | `박**` |
| 정하늘 | `정**` |

## 대소문자와 길이 {{#case-length}}

`LOWER`는 모든 글자를 소문자로, `UPPER`는 대문자로 바꿔요. `INITCAP`은 단어마다 첫 글자만 대문자로 바꾸고 나머지는 소문자로 바꾸기 때문에, 원래 대문자였던 글자도 소문자가 돼요. 단어는 공백처럼 영문자나 숫자가 아닌 문자를 기준으로 나뉘어요.

`LENGTH`는 글자 수를 세요. 공백도 한 글자로 세고, 한글도 영어와 똑같이 한 글자를 1로 세요.

```sql
SELECT LOWER('SQL Developer'), UPPER('sql developer'), INITCAP('sql DEVELOPER kim') FROM DUAL;
-- 결과는 차례로 sql developer, SQL DEVELOPER, Sql Developer Kim이에요
SELECT LENGTH('SQL 개발자') FROM DUAL;   -- 영어 3글자, 공백 1칸, 한글 3글자를 모두 세서 7이 나와요
```

## 자르고 위치 찾기: SUBSTR와 INSTR {{#substr-instr}}

`SUBSTR(문자, 시작 위치, 길이)`는 시작 위치부터 길이만큼 잘라 낸 문자를 돌려줘요. 위치는 0이 아니라 1부터 세고, 길이를 생략하면 끝까지 잘라요. 시작 위치에 음수를 주면 뒤에서부터 세어 시작점을 정하지만, 자르는 방향은 그대로 오른쪽이에요.

`INSTR(문자, 찾을 문자, 시작 위치, 몇 번째)`는 찾을 문자가 나오는 위치를 숫자로 돌려줘요. 시작 위치와 몇 번째를 생략하면 둘 다 1로 보고, 찾는 문자가 없으면 0을 돌려줘요.

```sql
SELECT SUBSTR('DATABASE', 3, 4), SUBSTR('DATABASE', 3), SUBSTR('DATABASE', -4, 2) FROM DUAL;
-- 결과는 차례로 TABA, TABASE, BA예요
SELECT INSTR('DATABASE', 'A'), INSTR('DATABASE', 'A', 1, 2), INSTR('DATABASE', 'A', 3), INSTR('DATABASE', 'Z') FROM DUAL;
-- 결과는 차례로 2, 4, 4, 0이에요
```

글자 위에 위치 번호를 적어 두면 결과를 따라가기 쉬워요.

| 앞에서 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| 글자 | D | A | T | A | B | A | S | E |
| 뒤에서 | -8 | -7 | -6 | -5 | -4 | -3 | -2 | -1 |

`SUBSTR('DATABASE', -4, 2)`는 뒤에서 네 번째인 B에서 시작해 오른쪽으로 두 글자를 잘라서 BA가 돼요. `INSTR('DATABASE', 'A', 3)`은 3번 위치인 T부터 찾기 시작하므로, 그 뒤에 처음 나오는 A의 위치인 4를 돌려줘요.

## 채우기와 지우기: LPAD·RPAD·TRIM {{#pad-trim}}

`LPAD(문자, 전체 길이, 채울 문자)`는 결과가 전체 길이가 될 때까지 왼쪽을 채우고, `RPAD`는 오른쪽을 채워요. 채울 문자를 생략하면 공백으로 채워요. 전체 길이가 원래 문자보다 짧으면 채우지 않고 앞에서부터 그 길이만큼만 남겨요.

`LTRIM(문자, 지울 문자)`는 왼쪽에서, `RTRIM`은 오른쪽에서 지울 문자를 없애요. 지울 문자를 여러 개 주면 끝에 있는 글자가 그중 하나인 동안 계속 지우다가, 다른 글자를 만나면 멈춰요. 지울 문자를 생략하면 공백을 지워요.

`TRIM`은 `TRIM(LEADING 'x' FROM 문자)`처럼 방향을 단어로 정해요. LEADING은 앞(왼쪽), TRAILING은 뒤(오른쪽), BOTH는 양쪽이고, 방향을 생략하면 BOTH로 봐요. 지울 문자까지 생략한 `TRIM(문자)`는 양쪽 공백을 지워요.

```sql
SELECT LPAD('SQL', 6, '*'), RPAD('SQL', 6, '*'), LPAD('7', 3, '0'), LPAD('SQL', 2) FROM DUAL;
-- 결과는 차례로 ***SQL, SQL***, 007, SQ예요
SELECT LTRIM('xxSQLxx', 'x'), RTRIM('xxSQLxx', 'x'), LTRIM('xyxSQL', 'xy') FROM DUAL;
-- 결과는 차례로 SQLxx, xxSQL, SQL이에요
SELECT TRIM('x' FROM 'xxSQLxx'), TRIM(LEADING 'x' FROM 'xxSQLxx'), TRIM(TRAILING 'x' FROM 'xxSQLxx') FROM DUAL;
-- 결과는 차례로 SQL, SQLxx, xxSQL이에요
-- 오류: TRIM은 지울 문자를 한 글자만 받아요 (ORA-30001, 지울 문자가 두 글자 이상)
SELECT TRIM('xy' FROM 'xySQL') FROM DUAL;
```

## 바꾸기와 잇기: REPLACE·TRANSLATE·CONCAT {{#replace-concat}}

`REPLACE(문자, 찾을 문자열, 바꿀 문자열)`는 찾을 문자열이 통째로 나온 자리만 바꿔요. 바꿀 문자열을 생략하면 찾은 부분을 지워요. `TRANSLATE(문자, 바꿀 글자들, 새 글자들)`는 글자를 하나씩 짝지어 바꿔서, 'AB'와 'XY'를 주면 A는 X로, B는 Y로 따로따로 바뀌어요. 새 글자 쪽에 짝이 없는 글자는 지워져요.

```sql
SELECT REPLACE('ABCBA', 'AB', 'XY'), TRANSLATE('ABCBA', 'AB', 'XY'), TRANSLATE('ABCBA', 'AB', 'X') FROM DUAL;
-- 결과는 차례로 XYCBA, XYCYX, XCX예요
SELECT REPLACE('A B C', ' '), REPLACE('ABCABC', 'AB') FROM DUAL;   -- 결과는 차례로 ABC, CC예요
```

`CONCAT(문자1, 문자2)`는 두 문자를 이어 붙이고, `||` 연산자도 같은 일을 해요. CONCAT은 인자를 정확히 두 개만 받아서, 셋 이상 이으려면 CONCAT을 겹쳐 쓰거나 `||`를 써요. `ASCII`는 글자를 그 글자의 번호(아스키 코드)로 바꾸고, `CHR`는 반대로 번호를 글자로 바꿔요.

```sql
SELECT CONCAT('SQL', 'D'), CONCAT(CONCAT('SQL', 'D'), ' 시험'), 'SQL' || 'D' || ' 시험' FROM DUAL;
-- 결과는 차례로 SQLD, SQLD 시험, SQLD 시험이에요
-- 오류: CONCAT은 인자를 두 개만 받아요 (ORA-00909, 인자 개수가 맞지 않음)
SELECT CONCAT('SQL', 'D', ' 시험') FROM DUAL;
SELECT ASCII('A'), CHR(65), ASCII('a') FROM DUAL;   -- 결과는 차례로 65, A, 97이에요
```

## 자주 헷갈리는 점 {{#confusing}}

**REPLACE는 덩어리로, TRANSLATE는 글자 하나씩 바꿔요.** 'ABCBA'에서 REPLACE로 'AB'를 'XY'로 바꾸면 A와 B가 붙어 있는 맨 앞만 바뀌어 XYCBA가 돼요. TRANSLATE는 뒤쪽에 떨어져 있는 B와 A까지 각각 Y와 X로 바꿔서 XYCYX가 돼요. 같은 인자를 넣은 두 함수의 결과를 고르는 문제라면, 바꿀 글자가 떨어져서 나오는 자리를 찾아보면 돼요.

**LTRIM은 여러 글자를, TRIM은 한 글자만 지울 문자로 받아요.** `LTRIM('xyxSQL', 'xy')`는 x와 y 중 하나인 동안 계속 지워서 SQL이 되지만, `TRIM('xy' FROM 'xySQL')`은 오류가 나요. TRIM은 양쪽 끝만 지우기 때문에 `TRIM(' S Q L ')`의 결과는 가운데 공백이 남은 'S Q L'이라는 점도 함께 알아 두면 좋아요. 가운데 공백까지 없애려면 `REPLACE(문자, ' ')`를 써요.

**SUBSTR는 문자를, INSTR는 숫자를 돌려줘요.** 이름이 비슷해서 섞이기 쉬운데, SUBSTR의 결과는 잘라 낸 조각이고 INSTR의 결과는 위치 번호예요. 둘을 함께 쓰면 "어떤 글자 앞까지"처럼 위치가 행마다 다른 부분을 자를 수 있어요.

```sql
SELECT SUBSTR('lee@sqld.kr', 1, INSTR('lee@sqld.kr', '@') - 1) FROM DUAL;   -- '@' 바로 앞까지 잘라서 lee가 나와요
```

**음수 위치는 두 함수에서 뜻이 조금 달라요.** SUBSTR에 음수를 주면 뒤에서 센 곳에서 시작해 오른쪽으로 잘라요. INSTR에 음수를 주면 뒤에서부터 앞쪽으로 찾아가지만, 돌려주는 위치는 여전히 앞에서 센 번호예요. 그래서 `INSTR('DATABASE', 'A', -1)`은 마지막 A의 위치인 6이에요.

**LPAD의 숫자는 채울 개수가 아니라 결과 전체의 길이예요.** `LPAD('SQL', 6, '*')`는 별 6개가 아니라 3개를 채워 6글자를 만들어요. 원래보다 짧은 길이를 주면 `LPAD('SQL', 2)`처럼 앞의 SQ만 남아요.

**INITCAP은 나머지 글자를 소문자로 바꿔요.** `INITCAP('sql DEVELOPER')`는 Sql Developer가 되므로, 원래 대문자였던 글자가 그대로 남는다고 생각하면 틀려요.

**Oracle에서는 NULL을 이어 붙여도 NULL이 되지 않아요.** 숫자 계산에 NULL이 섞이면 결과가 NULL이지만, `'SQL' || NULL`과 `CONCAT('SQL', NULL)`은 모두 SQL이에요. Oracle은 문자를 이을 때 NULL을 빈 문자처럼 다루기 때문이에요.

```sql
SELECT 'SQL' || NULL, CONCAT('SQL', NULL), TRIM(' S Q L '), INSTR('DATABASE', 'A', -1) FROM DUAL;
-- 결과는 차례로 SQL, SQL, S Q L, 6이에요
```

**SQL Server에서는 이름이 다른 함수가 있어요.** 보기에 SQL Server 문법이 섞여 나오면 아래 짝을 떠올리면 되고, 문자를 잇는 연산자도 Oracle의 `||` 대신 `+`를 써요.

| Oracle | SQL Server | 차이 |
|---|---|---|
| LENGTH | LEN | LEN은 끝에 붙은 공백을 세지 않아요 |
| SUBSTR | SUBSTRING | SUBSTRING은 길이를 생략할 수 없어요 |
| INSTR | CHARINDEX | CHARINDEX는 찾을 문자를 첫 번째 인자로 받아요 |
| CHR | CHAR | 번호를 글자로 바꾸는 같은 일을 해요 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

'DATABASE'처럼 짧은 문자에 SUBSTR, INSTR, LPAD, TRIM을 섞어 쓴 SQL을 주고 결과를 고르게 하는 문제가 가장 많아요. 글자 위에 위치 번호를 1부터 적고, 음수가 나오면 뒤에서 -1부터 적어 두면 계산이 빨라져요. 단일행 함수의 특징을 묻는 문제에서는 "여러 행을 받아 결과 하나를 돌려준다"는 집계 함수의 설명이 틀린 보기로 자주 나와요. REPLACE와 TRANSLATE, LTRIM과 TRIM처럼 짝을 이루는 함수는 같은 인자를 넣고 결과 차이를 묻는 식으로 나와요.""",
    "checkQuestions": [
        question(1, "아래 사원 표에 다음 SQL을 실행하면 결과는 몇 행인가요?\n\n" + EMPLOYEE_DEPARTMENT_TABLE, "definition",
                 "단일행 함수는 WHERE 절이 남긴 행마다 결과를 하나씩 돌려줘요. 부서번호가 20인 사원은 이지은, 박서준, 정하늘 세 명이라서 결과도 3행이에요.",
                 [choice("A", "1행", rationale="LENGTH는 단일행 함수라서 여러 행을 하나로 묶지 않아요."),
                  choice("B", "8행", rationale="WHERE 절이 부서번호 20인 세 명만 남긴 뒤에 함수가 계산돼요."),
                  choice("C", "3행", True, "20번 부서 세 명에게 결과가 하나씩 나와요."),
                  choice("D", "9행", rationale="글자 수만큼 행이 늘지 않고, 행마다 결과는 하나예요.")],
                 stem_sql="SELECT 이름, LENGTH(이름) FROM 사원 WHERE 부서번호 = 20;"),
        question(2, "다음 SQL의 결과는 무엇인가요?", "substr-instr",
                 "-4는 뒤에서 네 번째 글자인 B를 가리키고, 그 자리부터 오른쪽으로 두 글자를 잘라요. 그래서 결과는 BA예요.",
                 [choice("A", "BA", True, "B에서 시작해 오른쪽으로 두 글자를 잘라요."),
                  choice("B", "SE", rationale="끝의 두 글자인데, 시작 위치가 -4이므로 B부터 잘라야 해요."),
                  choice("C", "AB", rationale="음수 위치여도 자르는 방향은 왼쪽이 아니라 오른쪽이에요."),
                  choice("D", "BASE", rationale="길이 2를 주었으므로 끝까지 자르지 않아요.")],
                 stem_sql="SELECT SUBSTR('DATABASE', -4, 2) FROM DUAL;"),
        question(3, "다음 SQL의 결과는 무엇인가요?", "replace-concat",
                 "TRANSLATE는 글자를 하나씩 짝지어 바꾸므로 A는 O로 바뀌고, 짝이 없는 N은 지워져요. 그래서 BANANA는 BOOO가 돼요.",
                 [choice("A", "BOOA", rationale="'AN' 덩어리를 바꾼 REPLACE의 결과예요."),
                  choice("B", "BOOO", True, "A는 O로 바뀌고, 짝이 없는 N은 지워져요."),
                  choice("C", "BOOOOO", rationale="새 글자 쪽에 짝이 없는 N은 O가 되지 않고 지워져요."),
                  choice("D", "BANANA", rationale="A와 N이 들어 있으므로 문자가 바뀌어요.")],
                 stem_sql="SELECT TRANSLATE('BANANA', 'AN', 'O') FROM DUAL;"),
        question(4, "다음 중 결과가 'SQL'이 아닌 것은 무엇인가요?", "pad-trim",
                 "LPAD는 왼쪽을 채우는 함수라서 결과가 xxSQL이에요. 나머지 셋은 모두 x나 y를 지워 SQL을 돌려줘요.",
                 [choice("A", "LTRIM('xxSQL', 'x')", rationale="왼쪽의 x를 지워서 SQL이 돼요."),
                  choice("B", "TRIM(LEADING 'x' FROM 'xxSQL')", rationale="앞쪽의 x를 지워서 SQL이 돼요."),
                  choice("C", "RTRIM('SQLyx', 'xy')", rationale="오른쪽 끝의 x와 y를 차례로 지워서 SQL이 돼요."),
                  choice("D", "LPAD('SQL', 5, 'x')", True, "지우지 않고 왼쪽에 x를 채워서 xxSQL이 돼요.")]),
        question(5, "다음 SQL의 결과는 무엇인가요?", "confusing",
                 "INSTR가 '@'의 위치 4를 돌려주고, SUBSTR는 그다음인 5번 위치부터 끝까지 잘라요. 그래서 결과는 passql.com이에요.",
                 [choice("A", "kim", rationale="'@' 앞부분인데, 이 SQL은 '@' 다음부터 잘라요."),
                  choice("B", "@passql.com", rationale="+ 1을 했으므로 '@'는 결과에 들어가지 않아요."),
                  choice("C", "passql.com", True, "5번 위치부터 끝까지 잘라요."),
                  choice("D", "4", rationale="INSTR만 따로 실행한 결과이고, 바깥의 SUBSTR는 문자를 돌려줘요.")],
                 stem_sql="SELECT SUBSTR('kim@passql.com', INSTR('kim@passql.com', '@') + 1) FROM DUAL;"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 예시
        sql_check("SELECT LOWER(SUBSTR('SQL Developer', 5)) FROM DUAL", [["developer"]]),
        sql_check("SELECT 이름, SUBSTR(이름, 1, 1) || '**' FROM 사원 WHERE 부서번호 = 20",
                  [["이지은", "이**"], ["박서준", "박**"], ["정하늘", "정**"]]),
        sql_check("SELECT LOWER('SQL Developer'), UPPER('sql developer'), INITCAP('sql DEVELOPER kim') FROM DUAL",
                  [["sql developer", "SQL DEVELOPER", "Sql Developer Kim"]]),
        sql_check("SELECT LENGTH('SQL 개발자') FROM DUAL", [[7]]),
        sql_check("SELECT SUBSTR('DATABASE', 3, 4), SUBSTR('DATABASE', 3), SUBSTR('DATABASE', -4, 2) FROM DUAL",
                  [["TABA", "TABASE", "BA"]]),
        sql_check("SELECT INSTR('DATABASE', 'A'), INSTR('DATABASE', 'A', 1, 2), INSTR('DATABASE', 'A', 3), INSTR('DATABASE', 'Z') FROM DUAL",
                  [[2, 4, 4, 0]]),
        sql_check("SELECT LPAD('SQL', 6, '*'), RPAD('SQL', 6, '*'), LPAD('7', 3, '0'), LPAD('SQL', 2) FROM DUAL",
                  [["***SQL", "SQL***", "007", "SQ"]]),
        sql_check("SELECT LTRIM('xxSQLxx', 'x'), RTRIM('xxSQLxx', 'x'), LTRIM('xyxSQL', 'xy') FROM DUAL",
                  [["SQLxx", "xxSQL", "SQL"]]),
        sql_check("SELECT TRIM('x' FROM 'xxSQLxx'), TRIM(LEADING 'x' FROM 'xxSQLxx'), TRIM(TRAILING 'x' FROM 'xxSQLxx') FROM DUAL",
                  [["SQL", "SQLxx", "xxSQL"]]),
        sql_error_check("SELECT TRIM('xy' FROM 'xySQL') FROM DUAL", "ORA-30001"),
        sql_check("SELECT REPLACE('ABCBA', 'AB', 'XY'), TRANSLATE('ABCBA', 'AB', 'XY'), TRANSLATE('ABCBA', 'AB', 'X') FROM DUAL",
                  [["XYCBA", "XYCYX", "XCX"]]),
        sql_check("SELECT REPLACE('A B C', ' '), REPLACE('ABCABC', 'AB') FROM DUAL", [["ABC", "CC"]]),
        sql_check("SELECT CONCAT('SQL', 'D'), CONCAT(CONCAT('SQL', 'D'), ' 시험'), 'SQL' || 'D' || ' 시험' FROM DUAL",
                  [["SQLD", "SQLD 시험", "SQLD 시험"]]),
        sql_error_check("SELECT CONCAT('SQL', 'D', ' 시험') FROM DUAL", "ORA-00909"),
        sql_check("SELECT ASCII('A'), CHR(65), ASCII('a') FROM DUAL", [[65, "A", 97]]),
        sql_check("SELECT SUBSTR('lee@sqld.kr', 1, INSTR('lee@sqld.kr', '@') - 1) FROM DUAL", [["lee"]]),
        sql_check("SELECT 'SQL' || NULL, CONCAT('SQL', NULL), TRIM(' S Q L '), INSTR('DATABASE', 'A', -1) FROM DUAL",
                  [["SQL", "SQL", "S Q L", 6]]),
        # 확인 문제 (stemSql·보기)
        sql_check("SELECT 이름, LENGTH(이름) FROM 사원 WHERE 부서번호 = 20;", [["이지은", 3], ["박서준", 3], ["정하늘", 3]]),
        sql_check("SELECT SUBSTR('DATABASE', -4, 2) FROM DUAL;", [["BA"]]),
        sql_check("SELECT TRANSLATE('BANANA', 'AN', 'O') FROM DUAL;", [["BOOO"]]),
        sql_check("SELECT REPLACE('BANANA', 'AN', 'O') FROM DUAL", [["BOOA"]]),
        sql_check("SELECT LTRIM('xxSQL', 'x'), TRIM(LEADING 'x' FROM 'xxSQL'), RTRIM('SQLyx', 'xy'), LPAD('SQL', 5, 'x') FROM DUAL",
                  [["SQL", "SQL", "SQL", "xxSQL"]]),
        sql_check("SELECT SUBSTR('kim@passql.com', INSTR('kim@passql.com', '@') + 1) FROM DUAL;", [["passql.com"]]),
        sql_check("SELECT INSTR('kim@passql.com', '@') FROM DUAL", [[4]]),
    ],
}
