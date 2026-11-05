"""개념: 데이터 타입 (3단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example

# 고정·가변 길이 비교용 작은 표 (블록·검증 항목마다 새로 만듦)
CHAR_COMPARE_SETUP = (
    "CREATE TABLE 문자비교 (고정 CHAR(5), 가변 VARCHAR2(5));\n"
    "INSERT INTO 문자비교 VALUES ('AB', 'AB');"
)

# 본문 예시 2개 (SQL 블록 + 결과 표 = 검증 항목)
CHAR_LENGTH_EXAMPLE = sql_example(CHAR_COMPARE_SETUP + "\nSELECT LENGTH(고정), LENGTH(가변) FROM 문자비교;",
                                  ("LENGTH(고정)", "LENGTH(가변)"), [(5, 2)])
DATE_TIMESTAMP_EXAMPLE = sql_example(
    "CREATE TABLE 날짜비교 (일시 DATE, 정밀일시 TIMESTAMP);\n"
    "INSERT INTO 날짜비교 VALUES (TIMESTAMP '2026-10-27 13:45:30.123456', TIMESTAMP '2026-10-27 13:45:30.123456');\n"
    "SELECT TO_CHAR(일시, 'HH24:MI:SS') AS 일시, TO_CHAR(정밀일시, 'HH24:MI:SS.FF6') AS 정밀일시 FROM 날짜비교;",
    ("일시", "정밀일시"), [("13:45:30", "13:45:30.123456")])

CONCEPT = {
    "tagKey": "ddl-data-types",
    "topicCode": "sql_ddl_dml_tcl",
    "sortOrder": 1,
    "title": "데이터 타입",
    "summary": "열마다 담을 값의 종류와 크기를 정하는 약속이에요",
    "coreMd": (
        "- `CHAR(n)`은 남는 자리를 공백으로 채우고, `VARCHAR2(n)`은 넣은 길이만큼만 저장해요.\n"
        "- CHAR끼리나 CHAR와 리터럴은 공백을 채워 비교하고, 한쪽이 VARCHAR2면 끝 공백까지 그대로 비교해요.\n"
        "- `NUMBER(p, s)`는 넘친 소수를 반올림하지만, 넘친 정수는 오류(ORA-01438, 자릿수 초과)를 내요.\n"
        "- `DATE`는 초까지, `TIMESTAMP`는 초보다 작은 단위까지 시각을 저장해요.\n"
        "- 아주 긴 문자는 `CLOB`, 파일 같은 이진 데이터는 `BLOB`에 담아요."
    ),
    "detailMd": """## 왜 타입을 정할까요 — 열마다 담을 값을 미리 약속해요 {#why}

엑셀은 한 칸에 숫자를 적든 글자를 적든 막지 않아요. 데이터베이스는 테이블을 만들 때 열마다 담을 값의 종류와 크기를 먼저 정해 둬요.

| 용어 | 뜻 |
|---|---|
| 테이블 | 데이터를 담는 표예요 |
| 열 (컬럼) | 표의 세로 칸이에요. 사번, 이름, 급여가 각각 열이에요 |
| 데이터 타입 (자료형) | 열마다 정해 둔 값의 종류와 크기예요. 급여 칸에 '많음' 같은 글자가 들어가는 일을 막아 줘요 |
| 제약조건 | PRIMARY KEY, NOT NULL, REFERENCES처럼 들어갈 값을 막는 규칙이에요. 제약조건 개념에서 다뤄요 |

타입에 따라 비교와 정렬 방법도 달라져요. 숫자로는 10이 9보다 크지만, 문자로 비교하면 첫 글자 '1'이 '9'보다 앞이라서 '10'이 '9'보다 작다고 판단해요.

`CREATE TABLE`은 테이블을 만드는 명령어예요. 공통 예시 데이터의 사원 표에서 열 이름 뒤에 붙은 `NUMBER(4)`, `VARCHAR2(20)`, `DATE`가 데이터 타입이에요.

```sql
-- 문법: 공통 예시 데이터의 사원 표는 이렇게 만들어져 있어요
CREATE TABLE 사원 (
  사번       NUMBER(4) PRIMARY KEY,
  이름       VARCHAR2(20) NOT NULL,
  직급       VARCHAR2(10),
  관리자사번 NUMBER(4),
  입사일     DATE,
  급여       NUMBER(5),
  커미션     NUMBER(5),
  부서번호   NUMBER(2) REFERENCES 부서(부서번호)
);
```

## 자주 쓰는 타입 일곱 가지 — 문자·숫자·날짜·큰 데이터 {#definition}

시험에 나오는 Oracle 타입은 아래 일곱 가지가 거의 전부예요.

| 분류 | 타입 | 담는 값 | 쓰는 곳 예 |
|---|---|---|---|
| 문자 | `CHAR(n)` | 길이가 정해진 문자, 모자라면 뒤를 공백으로 채움 | 성별 코드, 우편번호 |
| 문자 | `VARCHAR2(n)` | 최대 n까지, 넣은 만큼만 저장 | 이름, 주소 |
| 숫자 | `NUMBER(p, s)` | 정수와 소수 | 급여, 평점 |
| 날짜 | `DATE` | 날짜와 시각, 초 단위까지 | 입사일 |
| 날짜 | `TIMESTAMP` | 날짜와 시각, 초보다 작은 단위까지 | 결제 시각 |
| 큰 데이터 | `CLOB` | 아주 긴 문자 | 게시글 본문 |
| 큰 데이터 | `BLOB` | 이미지·파일 같은 이진 데이터 | 사진, 첨부 파일 |

| 용어 | 뜻 |
|---|---|
| CLOB (Character Large Object) | VARCHAR2에 다 못 담는 긴 문자를 담아요. VARCHAR2는 기본 설정에서 4000바이트까지만 들어가요 |
| BLOB (Binary Large Object) | 사진이나 PDF처럼 글자가 아닌 이진 데이터를 담아요. CLOB와 함께 기가바이트 단위까지 저장할 수 있어요 |

## CHAR와 VARCHAR2 — 남는 자리를 채우느냐의 차이 {#char-varchar2}

| 구분 | `CHAR(n)` | `VARCHAR2(n)` |
|---|---|---|
| 길이 | 고정 길이 | 가변 길이 |
| n의 뜻 | 늘 저장하는 길이 | 넣을 수 있는 최대 길이 |
| 짧은 값을 넣으면 | 남는 자리를 공백으로 채움 | 넣은 길이만큼만 저장 |
| 길이를 빼고 쓰면 | `CHAR(1)`이 됨 | 오류(ORA-00906, 괄호 누락) |
| 최대 길이 (기본 설정) | 2000바이트 | 4000바이트 |
| 어울리는 값 | 코드처럼 길이가 늘 같은 값 | 이름, 주소처럼 길이가 제각각인 값 |

`INSERT`는 테이블에 행을 넣는 명령어로 INSERT·UPDATE·DELETE 개념에서 다뤄요. `LENGTH`는 글자 수를 세는 함수인데, 같은 'AB'를 넣어도 CHAR 열은 공백 세 칸이 붙어서 5가 나와요.

""" + CHAR_LENGTH_EXAMPLE.markdown + """

어느 쪽이든 정해 둔 길이보다 긴 값은 잘라서 넣어 주지 않아요. 오류(ORA-12899, 값이 열 크기보다 큼)를 내고 그 행을 넣지 않아요.

```sql
CREATE TABLE 문자비교 (고정 CHAR(5), 가변 VARCHAR2(5));
INSERT INTO 문자비교 VALUES ('ABCDEF', 'A');   -- 오류: 고정 열에는 5글자까지만 들어가요 (ORA-12899)
```

## NUMBER(p, s) — 넘친 소수는 반올림, 넘친 정수는 오류 {#number}

| 용어 | 뜻 |
|---|---|
| p, 정밀도 (precision) | 전체 자릿수예요 |
| s, 스케일 (scale) | 소수점 아래 자릿수예요. 정수 부분에는 p - s자리까지 쓸 수 있어요 |
| `NUMBER(5)` | s를 뺀 것이라 `NUMBER(5, 0)`과 같아요. 소수 첫째 자리에서 반올림한 정수만 저장해요 |
| `NUMBER` | p와 s를 모두 빼면 38자리까지 넣은 값을 그대로 저장해요 |

`NUMBER(5, 2)`는 정수 세 자리와 소수 두 자리를 쓸 수 있어서 가장 큰 값이 999.99예요. 공통 예시 데이터의 급여 열은 `NUMBER(5)`라서 99999까지 들어가요.

| 넣은 값 | 열 타입 | 결과 | 이유 |
|---|---|---|---|
| 123.456 | NUMBER(5, 2) | 123.46 | 넘친 소수는 s자리로 반올림해요 |
| 1234.5 | NUMBER(5, 2) | 오류 (ORA-01438, 자릿수 초과) | 정수 부분이 네 자리예요 |
| 999.995 | NUMBER(5, 2) | 오류 (ORA-01438) | 반올림하면 1000.00이 되어 정수가 네 자리예요 |
| -999.99 | NUMBER(5, 2) | -999.99 | 마이너스 부호는 자릿수에 들어가지 않아요 |
| 12345.6 | NUMBER(5) | 12346 | 정수로 반올림해요 |

```sql
CREATE TABLE 숫자 (값 NUMBER(5, 2));
INSERT INTO 숫자 VALUES (123.456);   -- 123.46으로 반올림해서 들어가요
INSERT INTO 숫자 VALUES (1234.5);    -- 오류: 정수 부분이 네 자리라서 들어가지 않아요 (ORA-01438)
SELECT 값 FROM 숫자;                 -- 123.46 한 행만 나와요
```

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| NUMBER(5, 2)에서 소수가 넘치든 정수가 넘치든 반올림해서 넣어 줘요 | X | 소수만 반올림하고, 정수 부분이 세 자리를 넘으면 오류가 나요 |

## DATE와 TIMESTAMP — 둘 다 시각까지 들어 있어요 {#date}

이름만 보면 `DATE`는 날짜만 담을 것 같지만 시, 분, 초까지 저장해요. `DATE '2026-10-27'`처럼 날짜만 적어 넣으면 시각은 자정(00:00:00)으로 채워져요.

| 구분 | `DATE` | `TIMESTAMP` |
|---|---|---|
| 저장 단위 | 연, 월, 일, 시, 분, 초 | DATE에 소수 초를 더함 |
| 소수 초 | 저장하지 않음 | 따로 정하지 않으면 소수점 아래 여섯 자리 |

`TO_CHAR`는 날짜를 원하는 모양의 문자로 바꿔 보여 주는 함수로 SQL 함수 단원에서 다뤄요. `AS` 뒤의 이름은 결과 열에 붙인 별칭이에요.

""" + DATE_TIMESTAMP_EXAMPLE.markdown + """

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 같은 시각을 넣어도 DATE 열에서는 소수 초가 사라져요 | O | DATE는 초까지만 저장해서 13:45:30만 남아요 |

## 자주 헷갈리는 점 — 공백 비교, 바이트 길이, 자정 {#confusing}

CHAR(5) 열에 'AB'를 넣으면 실제로는 'AB   '처럼 뒤에 공백 세 칸이 붙어 저장돼요. 이 값을 무엇과 비교하느냐에 따라 공백을 채워 주는지가 달라져요.

| 비교하는 두 값 | 비교 방식 |
|---|---|
| CHAR끼리, 또는 CHAR와 문자 리터럴 | 짧은 쪽 뒤에 공백을 붙여 길이를 맞춘 뒤 비교해요 |
| 한쪽이라도 VARCHAR2 | 공백을 채우지 않고 처음부터 그대로 비교해요. 끝 공백도 한 글자로 쳐요 |

문자 리터럴은 SQL에 작은따옴표로 직접 적은 문자이고, `COUNT(*)`는 조건을 만족한 행이 몇 개인지 세는 함수예요. 세 번째 결과가 가장 헷갈리는데, VARCHAR2 열과 비교할 때는 공백을 채워 주지 않아서 'AB   '와 'AB'가 달라요.

```sql
CREATE TABLE 문자비교 (고정 CHAR(5), 가변 VARCHAR2(5));
INSERT INTO 문자비교 VALUES ('AB', 'AB');
SELECT COUNT(*) FROM 문자비교 WHERE 고정 = 'AB';    -- 1이 나와요 (공백을 채워서 비교해요)
SELECT COUNT(*) FROM 문자비교 WHERE 가변 = 'AB ';   -- 0이 나와요 (끝 공백도 한 글자로 쳐요)
SELECT COUNT(*) FROM 문자비교 WHERE 고정 = 가변;    -- 0이 나와요 ('AB   '와 'AB'를 그대로 비교해요)
```

| 헷갈리는 말 | 실제로는 |
|---|---|
| CHAR 열의 'AB'와 VARCHAR2 열의 'AB'는 같은 값이에요 | CHAR 쪽은 'AB   '로 저장되고, 한쪽이 VARCHAR2면 공백을 채우지 않아서 달라요 |
| VARCHAR2(6)에는 한글 여섯 글자가 들어가요 | n은 기본적으로 글자 수가 아니라 바이트(저장 공간 단위) 수예요. 이 예시 데이터베이스의 문자 집합 AL32UTF8에서 한글은 한 글자에 3바이트라서 '서울'(6바이트)은 들어가고 '기획부'(9바이트)는 들어가지 않아요 |
| 글자 수로 길이를 정하는 방법은 없어요 | `VARCHAR2(3 CHAR)`처럼 숫자 뒤에 CHAR를 붙이면 글자 수로 정해져요 |
| DATE 열을 `= DATE '2026-10-27'`로 찾으면 그날의 행이 모두 나와요 | 오른쪽은 자정이라서, 시각까지 저장된 값과는 같지 않아요. 날짜 비교에서 0행이 나오는 흔한 이유예요 |
| CLOB 열도 일반 문자처럼 `=`로 비교할 수 있어요 | `=`로 바로 비교하면 오류(ORA-00932, 데이터 타입 불일치)가 나요 |
| Oracle의 VARCHAR와 VARCHAR2는 다르게 동작해요 | 지금은 똑같이 동작하고, Oracle은 VARCHAR2를 쓰도록 권해요 |

## SQL Server와 이름이 달라요 — 같은 용도, 다른 이름 {#sql-server}

| 용도 | Oracle | SQL Server |
|---|---|---|
| 가변 길이 문자 | `VARCHAR2(n)` | `VARCHAR(n)` |
| 고정 길이 문자 | `CHAR(n)` | `CHAR(n)` |
| 숫자 | `NUMBER(p, s)` | `NUMERIC(p, s)`, `DECIMAL(p, s)`, `INT` |
| 날짜와 시각 | `DATE` | `DATETIME` |
| 소수 초까지 | `TIMESTAMP` | `DATETIME2` |
| 아주 긴 문자 | `CLOB` | `VARCHAR(MAX)` |
| 이진 데이터 | `BLOB` | `VARBINARY(MAX)` |

| 헷갈리는 말 | 실제로는 |
|---|---|
| SQL Server의 DATE도 Oracle처럼 시각을 담아요 | SQL Server의 DATE는 날짜만 저장해요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| SQL Server의 TIMESTAMP는 소수 초까지 담는 날짜 타입이에요 | X | 날짜가 아니라 행이 바뀔 때마다 자동으로 바뀌는 버전 번호예요 |

## 시험에서는 이렇게 나와요 {#exam-point}

CHAR와 VARCHAR2의 차이가 가장 자주 나오고, 고정·가변 길이와 비교 방식을 함께 물어요. 비교 문제는 두 값이 모두 CHAR나 리터럴인지, 한쪽이 VARCHAR2인지부터 확인하면 풀려요.

`NUMBER(p, s)`는 넣을 수 있는 가장 큰 값이나 저장된 결과를 물어요. 정수 부분이 p - s자리를 넘는지부터 세어 보면 실수가 줄어요.""",
    "checkQuestions": [
        question(1, "넣은 길이만큼만 저장하는 가변 길이 문자 타입은 무엇인가요?", "char-varchar2",
                 "VARCHAR2(n)의 n은 최대 길이이고, 실제로는 넣은 길이만큼만 저장해요. CHAR(n)은 모자란 자리를 공백으로 채워 늘 n 길이로 저장해요.",
                 [choice("A", "CHAR(n)", rationale="CHAR는 모자란 자리를 공백으로 채우는 고정 길이 타입이에요."),
                  choice("B", "VARCHAR2(n)", True, "넣은 길이만큼만 저장하는 가변 길이 타입이에요."),
                  choice("C", "NUMBER(p, s)", rationale="NUMBER는 문자가 아니라 숫자를 담는 타입이에요."),
                  choice("D", "DATE", rationale="DATE는 날짜와 시각을 담는 타입이에요.")]),
        question(2, "결제 시각을 0.123456초처럼 초보다 작은 단위까지 저장하려고 해요. Oracle에서 알맞은 타입은 무엇인가요?", "date",
                 "DATE는 초까지만 저장하고, TIMESTAMP는 소수 초까지 저장해요. 따로 정하지 않으면 소수점 아래 여섯 자리까지 담아요.",
                 [choice("A", "DATE", rationale="DATE는 초까지만 저장해서 소수 초가 사라져요."),
                  choice("B", "CLOB", rationale="CLOB는 아주 긴 문자를 담는 타입이에요."),
                  choice("C", "TIMESTAMP", True, "초보다 작은 단위까지 시각을 저장해요."),
                  choice("D", "CHAR(n)", rationale="CHAR는 고정 길이 문자 타입이라 시각 계산과 비교에 맞지 않아요.")]),
        question(3, "다음 SQL을 실행한 결과로 알맞은 것은 무엇인가요?", "char-varchar2",
                 "CHAR(5)는 'AB' 뒤에 공백 세 칸을 채워 5 길이로 저장하고, VARCHAR2(5)는 넣은 2 길이만 저장해요.",
                 [choice("A", "5, 2", True, "CHAR 열은 공백까지 5글자, VARCHAR2 열은 2글자예요."),
                  choice("B", "2, 2", rationale="CHAR 열은 남는 자리를 공백으로 채워서 길이가 5예요."),
                  choice("C", "5, 5", rationale="VARCHAR2 열은 넣은 길이만큼만 저장해서 길이가 2예요."),
                  choice("D", "2, 5", rationale="고정 길이와 가변 길이를 거꾸로 생각한 결과예요.")],
                 stem_sql=CHAR_COMPARE_SETUP + "\nSELECT LENGTH(고정), LENGTH(가변) FROM 문자비교;"),
        question(4, "`NUMBER(5, 2)`로 만든 열에 넣었을 때 오류가 나는 값은 무엇인가요?", "number",
                 "NUMBER(5, 2)는 정수 부분에 세 자리까지만 쓸 수 있어요. 1234.5는 정수 부분이 네 자리라서 ORA-01438(자릿수 초과) 오류가 나요.",
                 [choice("A", "999.99", rationale="정수 세 자리, 소수 두 자리라서 그대로 들어가요."),
                  choice("B", "123.456", rationale="넘친 소수는 반올림되어 123.46으로 들어가요."),
                  choice("C", "-999.99", rationale="마이너스 부호는 자릿수에 들어가지 않아서 그대로 들어가요."),
                  choice("D", "1234.5", True, "정수 부분이 네 자리라서 저장할 수 없어요.")]),
        question(5, "`고정 CHAR(5)` 열과 `가변 VARCHAR2(5)` 열에 모두 'AB'를 넣었어요. 다음 중 행이 나오는 조건은 무엇인가요?", "confusing",
                 "CHAR 열과 문자 리터럴은 공백을 채워 비교하므로 'AB   '와 'AB'가 같아요. 한쪽이 VARCHAR2이면 끝 공백까지 그대로 비교해요.",
                 [choice("A", "WHERE 고정 = 가변", rationale="한쪽이 VARCHAR2라서 'AB   '와 'AB'를 그대로 비교하므로 달라요."),
                  choice("B", "WHERE 가변 = 'AB '", rationale="VARCHAR2 비교에서는 끝 공백도 한 글자라서 'AB'와 'AB '는 달라요."),
                  choice("C", "WHERE 고정 = 'AB'", True, "CHAR와 리터럴은 공백을 채워 비교하므로 같아요."),
                  choice("D", "WHERE LENGTH(고정) = 2", rationale="CHAR(5) 열은 공백까지 저장해서 길이가 5예요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 문자와 숫자의 비교 방식 차이
        sql_check("SELECT CASE WHEN '10' < '9' THEN '작음' ELSE '큼' END FROM DUAL", [["작음"]]),
        sql_check("SELECT CASE WHEN 10 < 9 THEN '작음' ELSE '큼' END FROM DUAL", [["큼"]]),
        # CHAR·VARCHAR2 길이, 길이 초과
        CHAR_LENGTH_EXAMPLE.check,
        sql_error_check("INSERT INTO 문자비교 VALUES ('ABCDEF', 'A')", "ORA-12899",
                        setup="CREATE TABLE 문자비교 (고정 CHAR(5), 가변 VARCHAR2(5));"),
        # NUMBER 반올림·자리 초과
        sql_check("SELECT 값 FROM 숫자", [[123.46]],
                  setup="CREATE TABLE 숫자 (값 NUMBER(5, 2));\nINSERT INTO 숫자 VALUES (123.456);"),
        sql_error_check("INSERT INTO 숫자 VALUES (1234.5)", "ORA-01438", setup="CREATE TABLE 숫자 (값 NUMBER(5, 2));"),
        sql_error_check("INSERT INTO 숫자 VALUES (999.995)", "ORA-01438", setup="CREATE TABLE 숫자 (값 NUMBER(5, 2));"),
        sql_check("SELECT 값 FROM 숫자", [[-999.99], [999.99]],
                  setup="CREATE TABLE 숫자 (값 NUMBER(5, 2));\nINSERT INTO 숫자 VALUES (-999.99);\nINSERT INTO 숫자 VALUES (999.99);"),
        sql_check("SELECT 값 FROM 숫자", [[12346]],
                  setup="CREATE TABLE 숫자 (값 NUMBER(5));\nINSERT INTO 숫자 VALUES (12345.6);"),
        # DATE·TIMESTAMP 소수 초, DATE 자정 비교
        DATE_TIMESTAMP_EXAMPLE.check,
        sql_check("SELECT TO_CHAR(DATE '2026-10-27', 'HH24:MI:SS') FROM DUAL", [["00:00:00"]]),
        sql_check("SELECT COUNT(*) FROM 날짜비교 WHERE 일시 = DATE '2026-10-27'", [[0]],
                  setup="CREATE TABLE 날짜비교 (일시 DATE);\nINSERT INTO 날짜비교 VALUES (TIMESTAMP '2026-10-27 13:45:30');"),
        # CLOB 은 = 비교 불가
        sql_error_check("SELECT COUNT(*) FROM 문서 WHERE 본문 = '긴 글'", "ORA-00932",
                        setup="CREATE TABLE 문서 (본문 CLOB);\nINSERT INTO 문서 VALUES ('긴 글');"),
        # CHAR 비교 규칙 (공백 채움 vs 그대로)
        sql_check("SELECT COUNT(*) FROM 문자비교 WHERE 고정 = 'AB'", [[1]], setup=CHAR_COMPARE_SETUP),
        sql_check("SELECT COUNT(*) FROM 문자비교 WHERE 고정 = 'AB   '", [[1]], setup=CHAR_COMPARE_SETUP),
        sql_check("SELECT COUNT(*) FROM 문자비교 WHERE 가변 = 'AB '", [[0]], setup=CHAR_COMPARE_SETUP),
        sql_check("SELECT COUNT(*) FROM 문자비교 WHERE 고정 = 가변", [[0]], setup=CHAR_COMPARE_SETUP),
        sql_check("SELECT COUNT(*) FROM 문자비교 WHERE LENGTH(고정) = 2", [[0]], setup=CHAR_COMPARE_SETUP),
        # 길이 단위 바이트 (한글 3바이트), CHAR 단위 지정
        sql_check("SELECT LENGTHB('서울'), LENGTHB('기획부') FROM DUAL", [[6, 9]]),
        sql_check("SELECT COUNT(*) FROM 한글", [[1]],
                  setup="CREATE TABLE 한글 (값 VARCHAR2(6));\nINSERT INTO 한글 VALUES ('서울');"),
        sql_error_check("INSERT INTO 한글 VALUES ('기획부')", "ORA-12899", setup="CREATE TABLE 한글 (값 VARCHAR2(6));"),
        sql_check("SELECT 값 FROM 한글", [["기획부"]],
                  setup="CREATE TABLE 한글 (값 VARCHAR2(3 CHAR));\nINSERT INTO 한글 VALUES ('기획부');"),
        # 길이 생략 (CHAR 는 1, VARCHAR2 는 오류), 최대 길이
        sql_check("SELECT LENGTH(값) FROM 생략", [[1]],
                  setup="CREATE TABLE 생략 (값 CHAR);\nINSERT INTO 생략 VALUES ('A');"),
        sql_error_check("INSERT INTO 생략 VALUES ('AB')", "ORA-12899", setup="CREATE TABLE 생략 (값 CHAR);"),
        sql_error_check("CREATE TABLE 생략 (값 VARCHAR2)", "ORA-00906"),
        sql_error_check("CREATE TABLE 최대 (값 VARCHAR2(4001))", "ORA-00910"),
        sql_error_check("CREATE TABLE 최대 (값 CHAR(2001))", "ORA-00910"),
    ],
}
