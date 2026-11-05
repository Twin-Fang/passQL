"""개념: 문자 함수 (4단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

EMPLOYEE_DEPARTMENT_TABLE = to_employee_table_md("사번", "이름", "부서번호")

# 단일행 함수: WHERE 가 남긴 20번 부서 3명 > 결과도 3행
MASKED_NAME_EXAMPLE = sql_example(
    "SELECT 이름, SUBSTR(이름, 1, 1) || '**'\n"
    "FROM 사원\n"
    "WHERE 부서번호 = 20\n"
    "ORDER BY 사번;",
    ("이름", "가린 이름"),
    [["이지은", "이**"], ["박서준", "박**"], ["정하늘", "정**"]],
)

# SUBSTR(조각) <-> INSTR(위치 숫자): 같은 'DATABASE'
SUBSTR_EXAMPLE = sql_example(
    "SELECT SUBSTR('DATABASE', 3, 4), SUBSTR('DATABASE', 3), SUBSTR('DATABASE', -4, 2)\n"
    "FROM DUAL;",
    ("3, 4", "3 (길이 생략)", "-4, 2"),
    [["TABA", "TABASE", "BA"]],
)
INSTR_EXAMPLE = sql_example(
    "SELECT INSTR('DATABASE', 'A'), INSTR('DATABASE', 'A', 1, 2), INSTR('DATABASE', 'A', 3),\n"
    "       INSTR('DATABASE', 'Z'), INSTR('DATABASE', 'A', -1)\n"
    "FROM DUAL;",
    ("'A'", "'A', 1, 2", "'A', 3", "'Z'", "'A', -1"),
    [[2, 4, 4, 0, 6]],
)

# REPLACE(덩어리) <-> TRANSLATE(글자 하나씩): 같은 'ABCBA'
REPLACE_VERSUS_TRANSLATE_EXAMPLE = sql_example(
    "SELECT REPLACE('ABCBA', 'AB', 'XY'), TRANSLATE('ABCBA', 'AB', 'XY'), TRANSLATE('ABCBA', 'AB', 'X')\n"
    "FROM DUAL;",
    ("REPLACE", "TRANSLATE", "TRANSLATE (짝 모자람)"),
    [["XYCBA", "XYCYX", "XCX"]],
)

CONCEPT = {
    "tagKey": "function-character",
    "topicCode": "sql_function",
    "sortOrder": 1,
    "title": "문자 함수",
    "summary": "문자를 자르고 찾고 바꾸는 함수이고, 비슷한 짝끼리의 차이를 자주 물어요",
    "coreMd": (
        "- 단일행 함수는 행마다 결과를 하나씩 돌려주고, 중첩하면 가장 안쪽부터 계산해요.\n"
        "- `SUBSTR`는 잘라 낸 문자를, `INSTR`는 위치 숫자를 돌려주고, 위치는 1부터 세요.\n"
        "- `REPLACE`는 문자열 덩어리를, `TRANSLATE`는 글자 하나하나를 짝지어 바꿔요.\n"
        "- `LTRIM`과 `RTRIM`은 지울 글자를 여러 개 받지만, `TRIM`은 한 글자만 받아요.\n"
        "- `CONCAT`은 인자가 두 개뿐이고, Oracle에서는 NULL을 이어 붙여도 NULL이 되지 않아요."
    ),
    "detailMd": f"""## 문자 함수가 하는 일 — 저장된 값은 두고 보여 줄 모양만 바꿔요 {{#why}}

사원 이름은 "김민수"로 저장되어 있지만, 화면에는 "김**"처럼 가려서 보여 주고 싶을 때가 있어요. 저장된 값은 그대로 두고 꺼낼 때만 모양을 바꾸려면 함수를 써요.

| 용어 | 뜻 |
|---|---|
| 함수 | 괄호 안에 값을 넣으면 정해진 규칙대로 바꾼 값을 돌려주는 도구예요 |
| 인자 | 함수 괄호 안에 넣는 값이에요. `SUBSTR(이름, 1, 1)`에서는 이름, 1, 1이 인자예요 |
| 문자 함수 | 글자로 된 값을 자르고, 찾고, 채우고, 바꾸는 함수예요 |

함수 이름이 하는 일을 거의 그대로 말해 줘서, 시험은 뜻보다 비슷한 함수끼리 결과가 어떻게 다른지를 더 자주 물어요.

## 단일행 함수와 DUAL — 행마다 결과가 하나씩 나와요 {{#definition}}

| 용어 | 뜻 |
|---|---|
| 단일행 함수 | 행 하나를 받을 때마다 결과를 하나씩 돌려줘요. 이 단원의 문자·숫자·날짜·변환·NULL 함수가 모두 여기에 들어요 |
| 다중행 함수 | 여러 행을 묶어 결과 하나를 만들어요. `SUM`, `MAX` 같은 집계 함수이고, 그룹 함수 단원에서 다뤄요 |
| 중첩 | 함수 안에 함수를 넣는 것이에요. 가장 안쪽 함수부터 계산해요 |
| DUAL | Oracle이 준비해 둔 한 행짜리 테이블이에요. `FROM DUAL`로 쓰면 함수 결과만 한 줄로 볼 수 있어요 |

단일행 함수는 SELECT 절뿐 아니라 WHERE 절과 ORDER BY 절에도 쓸 수 있어요. 인자를 여러 개 받아도 결과는 하나예요.

```sql
SELECT LOWER(SUBSTR('SQL Developer', 5)) FROM DUAL;   -- SUBSTR가 먼저, LOWER가 나중에 계산돼서 developer가 나와요
```

아래 사원 표에서 20번 부서 세 명의 이름을 성만 남기고 가려 볼게요. `||`는 문자를 이어 붙이는 연산자이고, 뒤에서 다시 다뤄요.

{EMPLOYEE_DEPARTMENT_TABLE}

{MASKED_NAME_EXAMPLE.markdown}

WHERE 절이 남긴 세 명에게 결과가 하나씩 나와서 결과도 세 행이에요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 단일행 함수는 WHERE 절에도 쓸 수 있어요 | O | SELECT, WHERE, ORDER BY 절에 모두 쓸 수 있어요 |

## 대소문자와 길이 — INITCAP은 나머지를 소문자로 바꿔요 {{#case-length}}

| 함수 | 하는 일 | 예 | 결과 |
|---|---|---|---|
| LOWER | 모든 글자를 소문자로 바꿔요 | LOWER('SQL Developer') | sql developer |
| UPPER | 모든 글자를 대문자로 바꿔요 | UPPER('sql developer') | SQL DEVELOPER |
| INITCAP | 단어마다 첫 글자만 대문자, 나머지는 소문자로 바꿔요 | INITCAP('sql DEVELOPER kim') | Sql Developer Kim |
| LENGTH | 글자 수를 세요. 공백도 한 글자, 한글도 한 글자예요 | LENGTH('SQL 개발자') | 7 |

INITCAP은 공백처럼 영문자나 숫자가 아닌 문자를 기준으로 단어를 나눠요. 원래 대문자였던 글자도 단어의 첫 글자가 아니면 소문자가 돼요.

```sql
SELECT LOWER('SQL Developer'), UPPER('sql developer'), INITCAP('sql DEVELOPER kim') FROM DUAL;
SELECT LENGTH('SQL 개발자') FROM DUAL;   -- 영어 3글자, 공백 1칸, 한글 3글자를 세서 7이에요
```

## 자르고 찾기 — SUBSTR는 조각을, INSTR는 위치를 돌려줘요 {{#substr-instr}}

| 함수 | 모양 | 돌려주는 값 | 생략하면 |
|---|---|---|---|
| SUBSTR | SUBSTR(문자, 시작 위치, 길이) | 잘라 낸 문자 | 길이를 빼면 끝까지 잘라요 |
| INSTR | INSTR(문자, 찾을 문자, 시작 위치, 몇 번째) | 찾은 위치 숫자, 없으면 0 | 시작 위치와 몇 번째는 1로 봐요 |

위치는 0이 아니라 1부터 세요. 글자 위에 번호를 적어 두면 결과를 따라가기 쉬워요.

| 앞에서 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| 글자 | D | A | T | A | B | A | S | E |
| 뒤에서 | -8 | -7 | -6 | -5 | -4 | -3 | -2 | -1 |

{SUBSTR_EXAMPLE.markdown}

`SUBSTR('DATABASE', -4, 2)`는 뒤에서 네 번째인 B에서 시작해요. 음수 위치여도 자르는 방향은 그대로 오른쪽이라서 BA가 돼요.

{INSTR_EXAMPLE.markdown}

`INSTR('DATABASE', 'A', 3)`은 3번 T부터 찾기 시작해서 그 뒤의 첫 A인 4를 돌려줘요. 음수 시작 위치 -1은 뒤에서 앞쪽으로 찾지만, 돌려주는 번호는 앞에서 센 6이에요.

## 채우고 지우기 — LPAD의 숫자는 결과 전체 길이예요 {{#pad-trim}}

| 함수 | 하는 일 | 생략하면 |
|---|---|---|
| LPAD(문자, 전체 길이, 채울 문자) | 전체 길이가 될 때까지 왼쪽을 채워요. 원래보다 짧으면 앞에서부터 그 길이만 남겨요 | 공백으로 채워요 |
| RPAD(문자, 전체 길이, 채울 문자) | 오른쪽을 채워요 | 공백으로 채워요 |
| LTRIM(문자, 지울 문자들) | 왼쪽 끝 글자가 지울 문자 중 하나인 동안 계속 지우다가, 다른 글자를 만나면 멈춰요 | 공백을 지워요 |
| RTRIM(문자, 지울 문자들) | 오른쪽에서 똑같이 지워요 | 공백을 지워요 |
| TRIM(방향 '한 글자' FROM 문자) | 정한 방향에서 그 한 글자를 지워요 | 방향은 BOTH, 지울 문자는 공백이에요 |

TRIM의 방향은 LEADING(앞), TRAILING(뒤), BOTH(양쪽) 세 가지예요.

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

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| RPAD('AB', 5, '-')의 결과는 AB-----예요 | X | 5는 채울 개수가 아니라 전체 길이라서 AB---가 돼요 |
| TRIM('  S Q L  ')은 가운데 공백까지 지워요 | X | TRIM은 양쪽 끝만 지워서 'S Q L'이 남아요 |

## 바꾸고 잇기 — REPLACE는 덩어리, TRANSLATE는 글자 하나씩 {{#replace-concat}}

| 함수 | 하는 일 | 생략·부족할 때 |
|---|---|---|
| REPLACE(문자, 찾을 문자열, 바꿀 문자열) | 찾을 문자열이 통째로 나온 자리만 바꿔요 | 바꿀 문자열을 빼면 찾은 부분을 지워요 |
| TRANSLATE(문자, 바꿀 글자들, 새 글자들) | 글자를 하나씩 짝지어 바꿔요 | 새 글자 쪽에 짝이 없는 글자는 지워요 |
| CONCAT(문자1, 문자2) | 두 문자를 이어 붙여요 | 인자는 정확히 두 개예요 |
| ASCII(글자) | 글자를 아스키 코드 번호로 바꿔요 | 예: ASCII('A')는 65 |
| CHR(번호) | 번호를 글자로 바꿔요 | 예: CHR(65)는 A |

같은 'ABCBA'로 두 함수를 비교하면 차이가 바로 보여요.

{REPLACE_VERSUS_TRANSLATE_EXAMPLE.markdown}

REPLACE는 A와 B가 붙어 있는 맨 앞만 바꿔요. TRANSLATE는 떨어져 있는 B와 A까지 각각 바꾸고, 짝이 모자라면 B를 지워요.

```sql
SELECT REPLACE('A B C', ' '), REPLACE('ABCABC', 'AB') FROM DUAL;   -- 결과는 차례로 ABC, CC예요
SELECT CONCAT('SQL', 'D'), CONCAT(CONCAT('SQL', 'D'), ' 시험'), 'SQL' || 'D' || ' 시험' FROM DUAL;
-- 결과는 차례로 SQLD, SQLD 시험, SQLD 시험이에요
-- 오류: CONCAT은 인자를 두 개만 받아요 (ORA-00909, 인자 개수가 맞지 않음)
SELECT CONCAT('SQL', 'D', ' 시험') FROM DUAL;
SELECT ASCII('A'), CHR(65), ASCII('a') FROM DUAL;   -- 결과는 차례로 65, A, 97이에요
```

셋 이상 이으려면 CONCAT을 겹쳐 쓰거나 `||`를 써요.

## 자주 헷갈리는 점 — 짝을 이루는 함수의 한 칸 차이 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| REPLACE와 TRANSLATE는 같은 인자를 넣으면 결과가 같아요 | REPLACE는 덩어리로, TRANSLATE는 글자 하나씩 바꿔서 'ABCBA'에서 XYCBA와 XYCYX로 갈려요 |
| TRIM도 LTRIM처럼 지울 글자를 여러 개 받아요 | TRIM은 한 글자만 받아서 `TRIM('xy' FROM 'xySQL')`은 ORA-30001(지울 문자가 두 글자 이상) 오류가 나요 |
| SUBSTR와 INSTR는 둘 다 문자를 돌려줘요 | SUBSTR는 잘라 낸 문자를, INSTR는 위치 숫자를 돌려줘요 |
| SUBSTR에 음수 위치를 주면 왼쪽으로 잘라요 | 뒤에서 센 곳에서 시작하지만 자르는 방향은 오른쪽이에요 |
| INSTR에 음수 위치를 주면 뒤에서 센 번호를 돌려줘요 | 뒤에서 앞쪽으로 찾을 뿐, 번호는 앞에서 센 값이에요 |
| LPAD('SQL', 6, '*')는 별을 6개 채워요 | 6은 결과 전체 길이라서 별은 3개만 채워요 |
| INITCAP은 첫 글자만 대문자로 바꾸고 나머지는 그대로 둬요 | 나머지 글자는 소문자로 바꿔서 'sql DEVELOPER'는 Sql Developer가 돼요 |
| 문자에 NULL을 이어 붙이면 결과가 NULL이에요 | Oracle은 이을 때 NULL을 빈 문자처럼 다뤄서 `CONCAT('SQL', NULL)`도 SQL이에요 |

두 함수를 함께 쓰면 "어떤 글자 앞까지"처럼 행마다 위치가 다른 부분을 자를 수 있어요.

```sql
SELECT SUBSTR('lee@sqld.kr', 1, INSTR('lee@sqld.kr', '@') - 1) FROM DUAL;   -- '@' 바로 앞까지 잘라서 lee가 나와요
SELECT 'SQL' || NULL, CONCAT('SQL', NULL), TRIM(' S Q L ') FROM DUAL;   -- 결과는 차례로 SQL, SQL, S Q L이에요
```

가운데 공백까지 없애려면 TRIM 대신 `REPLACE(문자, ' ')`를 써요.

SQL Server 문법이 보기에 섞여 나오면 아래 짝을 떠올려요. 문자를 잇는 연산자도 `||` 대신 `+`를 써요.

| Oracle | SQL Server | 차이 |
|---|---|---|
| LENGTH | LEN | LEN은 끝에 붙은 공백을 세지 않아요 |
| SUBSTR | SUBSTRING | SUBSTRING은 길이를 생략할 수 없어요 |
| INSTR | CHARINDEX | CHARINDEX는 찾을 문자를 첫 번째 인자로 받아요 |
| CHR | CHAR | 번호를 글자로 바꾸는 같은 일을 해요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| REPLACE('ABCABC', 'AB')의 결과는 CC예요 | O | 세 번째 인자를 빼면 찾은 AB를 모두 지워요 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

'DATABASE'처럼 짧은 문자에 SUBSTR, INSTR, LPAD, TRIM을 섞어 쓰고 결과를 고르게 하는 문제가 가장 많아요. 글자 위에 1부터 번호를 적고, 음수가 나오면 뒤에서 -1부터 적어 두면 빨라져요.

| 나오는 모양 | 푸는 법 |
|---|---|
| 단일행 함수의 특징 고르기 | "여러 행을 받아 결과 하나를 돌려준다"는 집계 함수 설명이라 틀린 보기예요 |
| REPLACE와 TRANSLATE 결과 비교 | 바꿀 글자가 떨어져서 나오는 자리를 찾아요 |
| LTRIM과 TRIM 결과 비교 | TRIM에 두 글자를 주면 오류, LTRIM은 집합으로 지워요 |
| SUBSTR 안에 INSTR | 안쪽 INSTR의 위치 숫자를 먼저 구해요 |""",
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
        MASKED_NAME_EXAMPLE.check,
        sql_check("SELECT LOWER('SQL Developer'), UPPER('sql developer'), INITCAP('sql DEVELOPER kim') FROM DUAL",
                  [["sql developer", "SQL DEVELOPER", "Sql Developer Kim"]]),
        sql_check("SELECT LENGTH('SQL 개발자') FROM DUAL", [[7]]),
        SUBSTR_EXAMPLE.check,
        INSTR_EXAMPLE.check,
        sql_check("SELECT LPAD('SQL', 6, '*'), RPAD('SQL', 6, '*'), LPAD('7', 3, '0'), LPAD('SQL', 2) FROM DUAL",
                  [["***SQL", "SQL***", "007", "SQ"]]),
        sql_check("SELECT LTRIM('xxSQLxx', 'x'), RTRIM('xxSQLxx', 'x'), LTRIM('xyxSQL', 'xy') FROM DUAL",
                  [["SQLxx", "xxSQL", "SQL"]]),
        sql_check("SELECT TRIM('x' FROM 'xxSQLxx'), TRIM(LEADING 'x' FROM 'xxSQLxx'), TRIM(TRAILING 'x' FROM 'xxSQLxx') FROM DUAL",
                  [["SQL", "SQLxx", "xxSQL"]]),
        sql_error_check("SELECT TRIM('xy' FROM 'xySQL') FROM DUAL", "ORA-30001"),
        sql_check("SELECT RPAD('AB', 5, '-'), TRIM('  S Q L  ') FROM DUAL", [["AB---", "S Q L"]]),
        REPLACE_VERSUS_TRANSLATE_EXAMPLE.check,
        sql_check("SELECT REPLACE('A B C', ' '), REPLACE('ABCABC', 'AB') FROM DUAL", [["ABC", "CC"]]),
        sql_check("SELECT CONCAT('SQL', 'D'), CONCAT(CONCAT('SQL', 'D'), ' 시험'), 'SQL' || 'D' || ' 시험' FROM DUAL",
                  [["SQLD", "SQLD 시험", "SQLD 시험"]]),
        sql_error_check("SELECT CONCAT('SQL', 'D', ' 시험') FROM DUAL", "ORA-00909"),
        sql_check("SELECT ASCII('A'), CHR(65), ASCII('a') FROM DUAL", [[65, "A", 97]]),
        sql_check("SELECT SUBSTR('lee@sqld.kr', 1, INSTR('lee@sqld.kr', '@') - 1) FROM DUAL", [["lee"]]),
        sql_check("SELECT 'SQL' || NULL, CONCAT('SQL', NULL), TRIM(' S Q L ') FROM DUAL", [["SQL", "SQL", "S Q L"]]),
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
