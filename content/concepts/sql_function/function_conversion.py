"""개념: 변환 함수 (4단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

EMPLOYEE_TYPE_TABLE = to_employee_table_md("사번", "이름", "급여", "입사일")

# 같은 시각(14:05:09)에 형식만 바꿈: HH24 <-> HH, MI(분) <-> MM(월)
TIME_FORMAT_EXAMPLE = sql_example(
    "SELECT TO_CHAR(TO_DATE('2024-01-31 14:05:09', 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MI:SS'),\n"
    "       TO_CHAR(TO_DATE('2024-01-31 14:05:09', 'YYYY-MM-DD HH24:MI:SS'), 'HH:MI:SS'),\n"
    "       TO_CHAR(TO_DATE('2024-01-31 14:05:09', 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MM:SS')\n"
    "FROM DUAL;",
    ("HH24:MI:SS", "HH:MI:SS", "HH24:MM:SS"),
    [["14:05:09", "02:05:09", "14:01:09"]],
)

CONCEPT = {
    "tagKey": "function-conversion",
    "topicCode": "sql_function",
    "sortOrder": 4,
    "title": "변환 함수",
    "summary": "문자, 숫자, 날짜 사이에서 타입을 바꾸는 함수이고, 형식 문자를 정확히 써야 해요",
    "coreMd": (
        "- **명시적 변환**은 `TO_CHAR`, `TO_NUMBER`, `TO_DATE`, `CAST`로 직접 바꾸고, 암시적 변환은 Oracle이 알아서 바꿔요.\n"
        "- 날짜 형식에서 `MM`은 월, `MI`는 분이고, `HH24`는 **0~23시**, `HH`는 1~12시예요.\n"
        "- 숫자 형식의 `9`는 빈자리를 비우고 `0`은 **0으로 채우며**, 자리가 모자라면 `#`이 찍혀요.\n"
        "- 문자와 숫자를 비교하면 **문자 쪽을 숫자로** 바꾸고, 열 쪽이 바뀌면 그 열의 인덱스를 쓰지 못해요."
    ),
    "detailMd": f"""## 변환 함수가 하는 일: 값의 종류를 바꿔요 {{#why}}

데이터베이스의 값은 모두 종류가 정해져 있고, 이 종류를 데이터 타입이라고 불러요. 타입마다 할 수 있는 일이 달라서, 날짜를 '2024년 01월'처럼 보여 주려면 문자로 바꾸고 '20240131'이라는 글자로 날짜 계산을 하려면 날짜로 바꿔야 해요.

| 용어 | 뜻 |
|---|---|
| 데이터 타입 | 값의 종류예요. 사원 표의 이름은 문자(VARCHAR2), 급여는 숫자(NUMBER), 입사일은 날짜(DATE)예요 |
| 변환 함수 | 값의 타입을 다른 타입으로 바꾸는 함수예요 |
| 형식 | 값의 모양을 알려 주는 글자 틀이에요. 예: 'YYYY-MM-DD' |

아래 예시에서 쓰는 사원 표의 열은 다음과 같아요.

{EMPLOYEE_TYPE_TABLE}

## 명시적 변환과 암시적 변환: 사람이 바꾸나, Oracle이 바꾸나 {{#definition}}

| 용어 | 뜻 |
|---|---|
| 명시적 변환 | 함수를 써서 사람이 직접 타입을 바꿔요 |
| 암시적 변환 | 함수 없이 Oracle이 계산하면서 스스로 타입을 바꿔요 |

| 용어 | 뜻 |
|---|---|
| TO_CHAR(값, '형식') | 날짜나 숫자를 문자로 바꿔요. 형식은 결과를 어떤 모양으로 만들지 정해요. 예: TO_CHAR(입사일, 'YYYY-MM') |
| TO_NUMBER(문자, '형식') | 문자를 숫자로 바꿔요. 형식은 들어온 문자의 모양을 알려 줘요. 예: TO_NUMBER('1,234', '9,999') |
| TO_DATE(문자, '형식') | 문자를 날짜로 바꿔요. 형식은 들어온 문자의 모양을 알려 줘요. 예: TO_DATE('20240131', 'YYYYMMDD') |
| CAST(값 AS 타입) | 값을 지정한 타입으로 바꾸고, 형식은 받지 않아요. 예: CAST('123' AS NUMBER) |

## 날짜를 문자로: TO_CHAR 날짜 형식 {{#to-char-date}}

| 형식 | 뜻 | 2024-01-31 14:05:09의 결과 |
|---|---|---|
| YYYY | 네 자리 연도 | 2024 |
| MM | 두 자리 월 | 01 |
| DD | 두 자리 일 | 31 |
| HH24 | 0~23시 | 14 |
| HH 또는 HH12 | 1~12시 | 02 |
| MI | 분 | 05 |
| SS | 초 | 09 |
| DAY | 요일 이름 | 수요일 또는 WEDNESDAY |
| DY | 줄인 요일 이름 | 수 또는 WED |

형식 사이의 '-'나 ':' 같은 기호는 그대로 나오고, '년'처럼 다른 글자를 넣으려면 큰따옴표로 감싸요.

```sql
SELECT TO_CHAR(DATE '2024-01-31', 'YYYY-MM-DD'), TO_CHAR(DATE '2024-01-31', 'YYYY"년" MM"월" DD"일"') FROM DUAL;
-- 결과는 차례로 2024-01-31, 2024년 01월 31일이에요
```

요일 이름은 세션의 날짜 언어 설정(NLS_DATE_LANGUAGE)에 따라 '수요일'로도, 'WEDNESDAY'로도 나와요. 설정과 관계없이 같은 결과를 얻으려면 세 번째 인자로 언어를 정해요.

```sql
SELECT TO_CHAR(DATE '2024-01-31', 'DAY', 'NLS_DATE_LANGUAGE=KOREAN'), TO_CHAR(DATE '2024-01-31', 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') FROM DUAL;
-- 결과는 차례로 수요일, WED예요
```

## 숫자를 문자로: 9는 비우고 0은 채워요 {{#to-char-number}}

| 형식 | 뜻 |
|---|---|
| 9 | 숫자 한 자리이고, 앞쪽 빈자리는 빈칸으로 남겨요 |
| 0 | 숫자 한 자리이고, 앞쪽 빈자리를 0으로 채워요 |
| , | 천 단위 쉼표를 넣어요 |
| . | 소수점을 넣고, 소수 자리가 모자라면 반올림해요 |
| FM | 형식 맨 앞에 붙여 앞뒤 빈칸을 없애요 |

숫자를 TO_CHAR로 바꾸면 맨 앞에 부호(-)가 들어갈 빈칸 하나가 붙고, FM을 붙이면 사라져요. 형식의 자리 수가 모자라면 숫자를 잘라 보여 주지 않고 `#`만 찍어요.

```sql
SELECT TO_CHAR(1234567, '9,999,999'), TO_CHAR(1234567, 'FM9,999,999'), TO_CHAR(-1234, '9,999') FROM DUAL;
-- 결과는 차례로 ' 1,234,567', '1,234,567', '-1,234'예요
SELECT TO_CHAR(12, '999'), TO_CHAR(12, '000'), TO_CHAR(1234.567, '9999.9'), TO_CHAR(12345, '999') FROM DUAL;
-- 결과는 차례로 '  12', ' 012', ' 1234.6', '####'이에요
SELECT TO_CHAR(7, 'FM000'), TO_CHAR(7, 'FM999'), TO_CHAR(7, '000') FROM DUAL;
-- 결과는 차례로 '007', '7', ' 007'이에요
```

FM과 0을 함께 쓰면 0이 빈자리를 채우고, FM은 맨 앞의 부호 자리 빈칸만 없애요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| TO_CHAR(123, '99')의 결과는 12예요 | X | 자리가 모자라면 숫자를 자르지 않고 ###을 찍어요 |

## 문자를 숫자나 날짜로: TO_NUMBER, TO_DATE, CAST {{#to-number-to-date}}

| 함수 | 기억할 규칙 |
|---|---|
| TO_NUMBER | 쉼표처럼 숫자가 아닌 글자가 섞이면 형식으로 모양을 알려 줘야 해요. 안 알려 주면 ORA-01722(숫자로 바꿀 수 없음) 오류예요 |
| TO_DATE | 형식이 문자의 모양과 맞아야 하고, 2월 30일처럼 달력에 없는 날짜는 오류예요 |
| CAST | 여러 데이터베이스가 함께 따르는 SQL 표준 문법이라 Oracle과 SQL Server에서 모두 써요. 형식을 줄 수 없어서 날짜 모양 문자는 세션의 기본 날짜 형식을 따라요 |

```sql
SELECT TO_NUMBER('1,234', '9,999'), TO_NUMBER('123.45'), TO_DATE('20240131', 'YYYYMMDD') FROM DUAL;
-- 결과는 차례로 1234, 123.45, 2024-01-31이에요
-- 오류: 쉼표가 있는데 형식을 주지 않았어요 (ORA-01722, 숫자로 바꿀 수 없음)
SELECT TO_NUMBER('1,234') FROM DUAL;
-- 오류: 2월 30일은 없는 날짜예요 (ORA-01839, 그 달에 없는 날짜)
SELECT TO_DATE('2024-02-30', 'YYYY-MM-DD') FROM DUAL;
SELECT CAST('123' AS NUMBER) + 1, CAST(123 AS VARCHAR2(10)), CAST(1234.567 AS NUMBER(6,1)) FROM DUAL;
-- 결과는 차례로 124, 123, 1234.6이에요
```

`NUMBER(6,1)`은 전체 6자리 중 소수 1자리까지 담는 숫자 타입이라서, 넘치는 소수는 반올림돼요.

| Oracle | SQL Server | 차이 |
|---|---|---|
| CAST(값 AS 타입) | CAST(값 AS 타입) | 둘 다 같은 표준 문법이에요 |
| TO_CHAR, TO_DATE 등 | CONVERT(타입, 값, 스타일 번호) | SQL Server는 CONVERT로도 타입을 바꿔요 |
| CONVERT | 위 CONVERT와 다른 함수 | Oracle의 CONVERT는 문자 집합(인코딩)을 바꿔요 |

```sql
-- 문법: SQL Server의 CONVERT예요
SELECT CONVERT(VARCHAR(8), GETDATE(), 112);   -- 스타일 112는 20240131처럼 연월일 여덟 자리예요
```

## 암시적 변환: 시험에 나오는 규칙 세 가지 {{#implicit}}

| 상황 | Oracle이 바꾸는 쪽 | 예 |
|---|---|---|
| 문자와 숫자를 비교하거나 더하고 빼기 | 문자를 숫자로 | `'10' + 5`는 숫자 15 |
| 문자 잇기 연산자로 숫자를 이어 붙이기 | 숫자를 문자로 | '10'에 숫자 5를 이으면 문자 105 |
| 문자와 날짜를 비교하기 | 문자를 날짜로 | 문자가 기본 날짜 형식과 같은 모양일 때만 바뀌어요 |

기본 날짜 형식(NLS_DATE_FORMAT)은 세션이 날짜를 글자로 보여 주고 읽을 때 쓰는 모양 설정이에요.

```sql
SELECT '10' + 5, '10' || 5 FROM DUAL;          -- 결과는 차례로 숫자 15, 문자 105예요
SELECT 이름 FROM 사원 WHERE 사번 = '1001';      -- '1001'을 숫자 1001로 바꿔 비교해서 김민수가 나와요
-- 오류: '3,000'은 숫자로 바꿀 수 없어요 (ORA-01722, 숫자로 바꿀 수 없음)
SELECT 이름 FROM 사원 WHERE 급여 = '3,000';
```

## 자주 헷갈리는 점: 형식 글자와 바뀌는 쪽 {{#confusing}}

같은 시각을 형식만 바꿔 보이면, MM과 HH가 어디서 틀리는지 바로 보여요.

{TIME_FORMAT_EXAMPLE.markdown}

| 헷갈리는 말 | 실제로는 |
|---|---|
| 시각은 'HH:MM:SS'로 써요 | MM은 월이라서 분 자리에 1월의 01이 들어가요. 분은 MI예요 |
| HH는 24시간제예요 | HH는 12시간제라서 오후 2시도 오전 2시처럼 02로 나와요. 24시간제는 HH24예요 |
| 9와 0은 같은 숫자 자리 표시예요 | 9는 빈자리를 비워 두고, 0은 0으로 채워요 |
| 바꿀 수 없는 값은 NULL이 돼요 | 'ABC'나 '3,000'은 형식 없이 숫자로 바꿀 수 없어서 ORA-01722 오류가 나요 |
| 문자와 숫자를 비교하면 숫자를 문자로 바꿔요 | 문자를 숫자로 바꿔요. 그래서 문자 열인 이름을 1001과 비교하면 이름 값을 숫자로 바꾸다 오류가 나요 |
| 어느 쪽이 바뀌든 인덱스는 그대로 써요 | 열 값이 바뀌면 그 열의 인덱스를 쓰지 못해요 |
| '2'와 '10'을 비교하면 10이 더 커요 | 문자끼리는 글자 순서로 비교해서 '2' > '10'이 참이에요 |
| `WHERE 입사일 = '2015-03-02'`는 어디서나 동작해요 | 기본 날짜 형식이 다른 곳(예: DD-MON-RR)에서는 오류가 나요. `DATE '2015-03-02'`나 TO_DATE로 바꿔 비교해요 |

| 용어 | 뜻 |
|---|---|
| 인덱스 | 책 뒤의 찾아보기처럼 열 값을 미리 정렬해 둔 목록이에요 |
| 상수 | SQL에 직접 적은 값이에요. 예: '1001' |

숫자 열 사번을 '1001'과 비교하면 상수 쪽이 바뀌어 인덱스를 그대로 써요. 문자 열 이름을 1001과 비교하면 모든 행의 이름이 바뀌어 인덱스를 쓰지 못하고, 바꿀 수 없는 값이 있으면 오류까지 나요.

```sql
-- 문법: Oracle이 암시적 변환을 넣어 실제로 실행하는 모양이에요
WHERE 사번 = '1001'   -- WHERE 사번 = TO_NUMBER('1001')처럼 상수가 바뀌어 인덱스를 써요
WHERE 이름 = 1001     -- WHERE TO_NUMBER(이름) = 1001처럼 열이 바뀌어 인덱스를 못 써요
```

```sql
-- 오류: 이름 열 값을 숫자로 바꿀 수 없어요 (ORA-01722, 숫자로 바꿀 수 없음)
SELECT 이름 FROM 사원 WHERE 이름 = 1001;
SELECT '참' FROM DUAL WHERE '2' > '10';   -- 문자끼리 비교라서 참이 되어 한 행이 나와요
SELECT '참' FROM DUAL WHERE 2 > '10';     -- '10'을 숫자 10으로 바꿔 비교하면 거짓이라 0행이에요
```

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| WHERE 사번 = '1001'은 사번 열의 인덱스를 쓸 수 있어요 | O | 바뀌는 쪽이 열이 아니라 상수 '1001'이에요 |
| '10' + 5의 결과는 문자 105예요 | X | 더하기는 문자를 숫자로 바꿔서 숫자 15예요 |

## 꼭 외울 것: 형식 문자와 변환 방향 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| MM과 MI | MM은 월, MI는 분 |
| HH와 HH24 | HH(HH12)는 1~12시, HH24는 0~23시 |
| 숫자 형식 9와 0 | 9는 앞쪽 빈자리를 비우고, 0은 0으로 채워요 |
| 숫자 형식의 자리가 모자라면 | 숫자를 자르지 않고 #만 찍어요 |
| 형식 앞의 FM | 맨 앞 부호 자리 같은 앞뒤 빈칸을 없애요 |
| 문자와 숫자를 비교, 계산 | 문자를 숫자로 바꿔요 |
| 숫자로 못 바꾸는 문자 | NULL이 아니라 ORA-01722(숫자로 바꿀 수 없음) 오류 |
| CAST와 SQL Server CONVERT | CAST는 표준(형식 없음), CONVERT(타입, 값, 스타일 번호) |

## 시험에서는 이렇게 나와요 {{#exam-point}}

TO_CHAR에 날짜 형식을 준 결과를 고르는 문제가 가장 많고, MM과 MI, HH와 HH24를 바꿔 쓴 보기가 함정으로 나와요.

| 나오는 모양 | 푸는 법 |
|---|---|
| 날짜 형식 결과 | MM은 월, MI는 분, HH는 12시간제부터 확인해요 |
| 숫자 형식 결과 | 9와 0의 차이, 자리가 모자라면 # |
| 암시적 변환 | 문자와 숫자는 문자를 숫자로 바꿔요. 열이 바뀌면 인덱스를 못 쓰고, 못 바꾸면 오류예요 |""",
    "checkQuestions": [
        question(1, "문자 '20240131'을 날짜로 바꾸는 식으로 알맞은 것은 무엇인가요?", "definition",
                 "문자를 날짜로 바꾸는 함수는 TO_DATE이고, 형식으로 문자의 모양인 YYYYMMDD를 알려 줘요. TO_CHAR는 반대로 날짜나 숫자를 문자로 바꿔요.",
                 [choice("A", "TO_CHAR('20240131', 'YYYYMMDD')", rationale="TO_CHAR는 문자를 만드는 함수라서, 문자를 넣고 날짜 형식을 주면 오류가 나요."),
                  choice("B", "TO_NUMBER('20240131')", rationale="날짜가 아니라 숫자 20240131이 돼요."),
                  choice("C", "TO_DATE('20240131', 'YYYYMMDD')", True, "문자를 형식에 맞춰 날짜로 바꿔요."),
                  choice("D", "CAST('20240131' AS NUMBER)", rationale="날짜가 아니라 숫자 타입으로 바뀌어요.")]),
        question(2, "다음 SQL의 결과는 무엇인가요?", "confusing",
                 "MM은 분이 아니라 월을 뜻하므로 1월인 01이 나와요. 시는 HH24라서 14로 나와 결과는 14:01이에요.",
                 [choice("A", "14:01", True, "HH24는 14, MM은 월인 01이에요."),
                  choice("B", "14:05", rationale="분을 꺼내려면 MM이 아니라 MI를 써야 해요."),
                  choice("C", "02:01", rationale="12시간제 HH를 썼을 때의 모양이에요."),
                  choice("D", "02:05", rationale="HH:MI를 썼을 때의 결과예요.")],
                 stem_sql="SELECT TO_CHAR(TO_DATE('2024-01-31 14:05:09', 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MM') FROM DUAL;"),
        question(3, "숫자 7을 문자 '007'로 바꾸는 식은 무엇인가요?", "to-char-number",
                 "형식 0은 앞쪽 빈자리를 0으로 채우므로 FM000은 007이 돼요. 9는 빈자리를 비워 두고 FM이 빈칸을 없애서 7만 남아요.",
                 [choice("A", "TO_CHAR(7, 'FM999')", rationale="9는 빈자리를 0으로 채우지 않아서 7이 돼요."),
                  choice("B", "TO_CHAR(7, 'FM000')", True, "0이 빈자리를 채워 007이 돼요."),
                  choice("C", "TO_NUMBER('007')", rationale="문자가 아니라 숫자 7을 돌려줘요."),
                  choice("D", "TO_CHAR(7, '9.99')", rationale="소수 두 자리가 붙은 ' 7.00'이 돼요.")]),
        question(4, "사원 표의 이름 열은 문자 타입이에요. 다음 SQL을 실행하면 어떻게 되나요?", "confusing",
                 "문자 열과 숫자를 비교하면 Oracle은 이름 열 값을 숫자로 바꾸려고 해요. '김민수' 같은 값은 숫자로 바꿀 수 없어서 ORA-01722(숫자로 바꿀 수 없음) 오류가 나요.",
                 [choice("A", "김민수 1행이 나온다", rationale="사번이 아니라 이름 열을 비교하므로 김민수와 맞지 않아요."),
                  choice("B", "0행이 나온다", rationale="비교하기 전에 이름을 숫자로 바꾸다 실패해서 오류가 나요."),
                  choice("C", "모든 사원이 나온다", rationale="조건이 참이 되는 행이 없고, 그 전에 오류가 나요."),
                  choice("D", "ORA-01722(숫자로 바꿀 수 없음) 오류가 난다", True, "이름 값을 숫자로 바꿀 수 없어서 오류가 나요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE 이름 = 1001;"),
        question(5, "입사일이 2015-03-02인 김민수를 데이터베이스의 날짜 형식 설정과 관계없이 찾는 조건은 무엇인가요?", "confusing",
                 "TO_DATE로 형식을 직접 알려 주면 설정과 관계없이 같은 날짜로 바뀌어요. 문자 그대로 비교하면 기본 날짜 형식에 따라 결과가 달라져요.",
                 [choice("A", "WHERE 입사일 = '2015-03-02'", rationale="암시적 변환이라서 기본 날짜 형식이 YYYY-MM-DD가 아니면 오류가 나요."),
                  choice("B", "WHERE TO_CHAR(입사일, 'YYYY-MM') = '2015-03-02'", rationale="왼쪽이 '2015-03'이 되어 0행이 나와요."),
                  choice("C", "WHERE 입사일 = TO_DATE('2015-03-02', 'YYYY-MM-DD')", True, "형식을 직접 알려 주어 설정과 관계없이 김민수를 찾아요."),
                  choice("D", "WHERE TO_CHAR(입사일, 'YYYY-DD-MM') = '2015-03-02'", rationale="왼쪽이 '2015-02-03'이 되어 0행이 나와요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 예시
        sql_check("SELECT TO_CHAR(DATE '2024-01-31', 'YYYY-MM-DD'), TO_CHAR(DATE '2024-01-31', 'YYYY\"년\" MM\"월\" DD\"일\"') FROM DUAL",
                  [["2024-01-31", "2024년 01월 31일"]]),
        sql_check("SELECT TO_CHAR(TO_DATE('2024-01-31 14:05:09', 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MI:SS'), TO_CHAR(TO_DATE('2024-01-31 14:05:09', 'YYYY-MM-DD HH24:MI:SS'), 'HH:MI:SS') FROM DUAL",
                  [["14:05:09", "02:05:09"]]),
        sql_check("SELECT TO_CHAR(DATE '2024-01-31', 'DAY', 'NLS_DATE_LANGUAGE=KOREAN'), TO_CHAR(DATE '2024-01-31', 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') FROM DUAL",
                  [["수요일", "WED"]]),
        sql_check("SELECT TO_CHAR(DATE '2024-01-31', 'DY', 'NLS_DATE_LANGUAGE=KOREAN'), TO_CHAR(DATE '2024-01-31', 'DAY', 'NLS_DATE_LANGUAGE=AMERICAN') FROM DUAL",
                  [["수", "WEDNESDAY"]]),
        sql_check("SELECT TO_CHAR(1234567, '9,999,999'), TO_CHAR(1234567, 'FM9,999,999'), TO_CHAR(-1234, '9,999') FROM DUAL",
                  [[" 1,234,567", "1,234,567", "-1,234"]]),
        sql_check("SELECT TO_CHAR(12, '999'), TO_CHAR(12, '000'), TO_CHAR(1234.567, '9999.9'), TO_CHAR(12345, '999') FROM DUAL",
                  [["  12", " 012", " 1234.6", "####"]]),
        sql_check("SELECT TO_NUMBER('1,234', '9,999'), TO_NUMBER('123.45'), TO_DATE('20240131', 'YYYYMMDD') FROM DUAL",
                  [[1234, 123.45, "2024-01-31"]]),
        sql_error_check("SELECT TO_NUMBER('1,234') FROM DUAL", "ORA-01722"),
        sql_error_check("SELECT TO_DATE('2024-02-30', 'YYYY-MM-DD') FROM DUAL", "ORA-01839"),
        sql_check("SELECT CAST('123' AS NUMBER) + 1, CAST(123 AS VARCHAR2(10)), CAST(1234.567 AS NUMBER(6,1)) FROM DUAL",
                  [[124, "123", 1234.6]]),
        sql_check("SELECT '10' + 5, '10' || 5 FROM DUAL", [[15, "105"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 사번 = '1001'", [["김민수"]]),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 급여 = '3,000'", "ORA-01722"),
        sql_check("SELECT TO_CHAR(TO_DATE('2024-01-31 14:05:09', 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH:MM:SS') FROM DUAL",
                  [["2024-01-31 02:01:09"]]),
        sql_error_check("SELECT TO_NUMBER('ABC') FROM DUAL", "ORA-01722"),
        sql_check("SELECT '참' FROM DUAL WHERE '2' > '10'", [["참"]]),
        sql_check("SELECT '참' FROM DUAL WHERE 2 > '10'", []),
        sql_check("SELECT 이름 FROM 사원 WHERE 입사일 = DATE '2015-03-02'", [["김민수"]]),
        sql_check("SELECT TO_CHAR(7, 'FM000'), TO_CHAR(7, 'FM999'), TO_CHAR(7, '000') FROM DUAL", [["007", "7", " 007"]]),
        TIME_FORMAT_EXAMPLE.check,
        sql_check("SELECT TO_CHAR(123, '99') FROM DUAL", [["###"]]),
        # 확인 문제 (stemSql, 보기)
        sql_error_check("SELECT TO_CHAR('20240131', 'YYYYMMDD') FROM DUAL", "ORA-01481"),
        sql_check("SELECT TO_NUMBER('20240131'), CAST('20240131' AS NUMBER) FROM DUAL", [[20240131, 20240131]]),
        sql_check("SELECT TO_CHAR(TO_DATE('2024-01-31 14:05:09', 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MM') FROM DUAL;", [["14:01"]]),
        sql_check("SELECT TO_CHAR(7, 'FM999'), TO_CHAR(7, 'FM000'), TO_NUMBER('007'), TO_CHAR(7, '9.99') FROM DUAL",
                  [["7", "007", 7, " 7.00"]]),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 이름 = 1001;", "ORA-01722"),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 입사일 = '2015-03-02'", "ORA-01861"),
        sql_check("SELECT 이름 FROM 사원 WHERE TO_CHAR(입사일, 'YYYY-MM') = '2015-03-02'", []),
        sql_check("SELECT 이름 FROM 사원 WHERE 입사일 = TO_DATE('2015-03-02', 'YYYY-MM-DD')", [["김민수"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE TO_CHAR(입사일, 'YYYY-DD-MM') = '2015-03-02'", []),
    ],
}
