"""개념: 날짜 함수 (4단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

EMPLOYEE_HIRE_DATE_TABLE = to_employee_table_md("사번", "이름", "입사일")

# 달 단위 함수 3개를 사원 3명에게: 수습 종료일, 입사한 달 말일, 2024년 말까지 개월 수
HIRE_DATE_MONTH_EXAMPLE = sql_example(
    "SELECT 이름, 입사일, ADD_MONTHS(입사일, 6), LAST_DAY(입사일),\n"
    "       TRUNC(MONTHS_BETWEEN(DATE '2024-12-31', 입사일))\n"
    "FROM 사원\n"
    "WHERE 사번 IN (1002, 1005, 1008)\n"
    "ORDER BY 사번;",
    ("이름", "입사일", "6개월 뒤", "입사한 달 말일", "2024년 말까지 개월 수"),
    [["이지은", "2018-07-16", "2019-01-16", "2018-07-31", 77],
     ["정하늘", "2022-03-14", "2022-09-14", "2022-03-31", 33],
     ["윤서연", "2024-05-20", "2024-11-20", "2024-05-31", 7]],
)

CONCEPT = {
    "tagKey": "function-date",
    "topicCode": "sql_function",
    "sortOrder": 3,
    "title": "날짜 함수",
    "summary": "날짜에 일과 달을 더하고 빼는 함수이고, 하루가 숫자 1이라는 규칙에서 시작해요",
    "coreMd": (
        "- 날짜 + 숫자는 날짜, 날짜 - 날짜는 일 수이고, 날짜 + 날짜는 오류이며 1시간은 1/24이에요.\n"
        "- `ADD_MONTHS`는 결과 달에 같은 날이 없거나 원래 날짜가 말일이면 결과 달의 말일을 돌려줘요.\n"
        "- `MONTHS_BETWEEN(날짜1, 날짜2)`는 날짜1에서 날짜2를 빼서, 앞 날짜가 더 이르면 음수예요.\n"
        "- `NEXT_DAY`는 그날을 빼고 다음에 오는 요일을, `LAST_DAY`는 그 달의 마지막 날을 돌려줘요.\n"
        "- `SYSDATE`에는 시각이 들어 있고, 날짜 `ROUND`는 정오·16일·7월 1일부터 올려요."
    ),
    "detailMd": f"""## 날짜 함수가 하는 일 — 달력 세기를 대신해 줘요 {{#why}}

입사한 지 몇 달인지, 수습 6개월이 끝나는 날이 언제인지를 달력으로 직접 세면 틀리기 쉬워요. 달마다 날 수가 다르고, 4년에 한 번은 2월이 29일까지 있는 윤년이 돌아오기 때문이에요.

## 날짜 값과 SYSDATE — 날짜 안에는 시각도 들어 있어요 {{#definition}}

| 용어 | 뜻 |
|---|---|
| DATE | Oracle의 날짜 타입이에요. 연·월·일과 함께 시·분·초까지 한 값에 담아서, 화면에 날짜만 보여도 시각이 들어 있을 수 있어요 |
| SYSDATE | 데이터베이스 서버 시계로 지금 날짜와 시각을 돌려줘요. 인자가 없어서 괄호 없이 써요 |
| 날짜 리터럴 | `DATE '2024-01-31'`처럼 날짜를 직접 적은 값이에요. 따옴표 안은 언제나 '연-월-일' 모양이에요 |
| 말일 | 그 달의 마지막 날이에요 |

SYSDATE는 실행할 때마다 값이 바뀌어서, 이 글의 예시는 날짜 리터럴이나 아래 사원 표의 입사일을 써요.

{EMPLOYEE_HIRE_DATE_TABLE}

```sql
-- 문법: 실행할 때마다 결과가 달라지는 예시예요
SELECT SYSDATE, SYSDATE + 1, TRUNC(SYSDATE) FROM DUAL;
```

## 날짜 계산 — 하루가 1이에요 {{#date-arithmetic}}

날짜에 숫자를 더하거나 빼면 Oracle은 그 숫자를 일 수로 봐요.

| 계산 | 결과의 종류 | 예 | 결과 |
|---|---|---|---|
| 날짜 + 숫자 | 날짜 | DATE '2024-01-31' + 1 | 2024-02-01 |
| 날짜 - 숫자 | 날짜 | DATE '2024-03-01' - 1 | 2024-02-29 |
| 날짜 - 날짜 | 숫자(일 수) | DATE '2024-03-01' - DATE '2024-02-01' | 29 |
| 날짜 + 날짜 | 오류 | DATE '2024-01-31' + DATE '2024-01-01' | ORA-00975(날짜끼리 더할 수 없음) |

| 더하는 값 | 뜻 |
|---|---|
| 1 | 하루 |
| 0.5 | 12시간 |
| 1/24 | 1시간 |
| 30/(24*60) | 30분 |
| 1/1440 | 1분 (1440은 24 × 60) |

```sql
SELECT DATE '2024-01-31' + 1, DATE '2024-03-01' - 1, DATE '2024-03-01' - DATE '2024-02-01' FROM DUAL;
-- 결과는 차례로 2024-02-01, 2024-02-29, 29예요
SELECT DATE '2024-01-31' + 1/24, DATE '2024-01-31' + 30/(24*60), DATE '2024-01-31' + 0.5 FROM DUAL;
-- 1시간, 30분, 12시간 뒤라서 차례로 2024-01-31 01:00:00, 00:30:00, 12:00:00이에요
-- 오류: 날짜끼리는 더할 수 없어요 (ORA-00975, 날짜 더하기 날짜는 허용되지 않음)
SELECT DATE '2024-01-31' + DATE '2024-01-01' FROM DUAL;
SELECT 이름, DATE '2024-12-31' - 입사일 FROM 사원 WHERE 사번 = 1008;   -- 윤서연의 입사일부터 2024-12-31까지 225일이에요
```

날짜끼리 뺄 때 시각이 섞여 있으면 18시간을 뜻하는 0.75처럼 소수가 나와요. 날짜끼리 더하는 것은 뜻이 없는 계산이라 Oracle이 막아요.

## 달 단위 함수 — 한 달은 일 수로 더하지 않아요 {{#month-functions}}

| 함수 | 하는 일 | 예 | 결과 |
|---|---|---|---|
| ADD_MONTHS(날짜, n) | n개월 뒤 날짜, n이 음수면 이전 날짜예요 | ADD_MONTHS(DATE '2024-01-15', 1) | 2024-02-15 |
| MONTHS_BETWEEN(날짜1, 날짜2) | 날짜1에서 날짜2를 뺀 개월 수예요 | MONTHS_BETWEEN(DATE '2024-03-15', DATE '2024-01-15') | 2 |
| LAST_DAY(날짜) | 그 달의 마지막 날이에요 | LAST_DAY(DATE '2024-02-10') | 2024-02-29 |
| NEXT_DAY(날짜, '요일') | 그 날짜 다음에 처음 오는 그 요일이에요 | NEXT_DAY(DATE '2024-01-31', 'MONDAY') | 2024-02-05 |

```sql
SELECT ADD_MONTHS(DATE '2024-01-15', 1), MONTHS_BETWEEN(DATE '2024-03-15', DATE '2024-01-15'), LAST_DAY(DATE '2024-02-10'), NEXT_DAY(DATE '2024-01-31', 'MONDAY') FROM DUAL;
-- 결과는 차례로 2024-02-15, 2, 2024-02-29, 2024-02-05예요
```

NEXT_DAY의 요일 이름은 데이터베이스 언어 설정을 따라서, 영어 설정이면 'MONDAY', 한국어 설정이면 '월요일'로 써요. 이 글은 영어 설정을 기준으로 했어요.

사원 표에 쓰면 수습이 끝나는 날, 입사한 달의 말일, 2024년 말까지 일한 개월 수를 한 번에 구할 수 있어요. 개월 수는 소수가 나와서 TRUNC로 소수 부분을 버렸어요.

{HIRE_DATE_MONTH_EXAMPLE.markdown}

## 일부 꺼내기와 날짜 다듬기 — EXTRACT, 날짜 ROUND·TRUNC {{#extract-round-trunc}}

`EXTRACT(YEAR FROM 날짜)`는 연도만 숫자로 꺼내고, YEAR 자리에 MONTH나 DAY를 쓰면 월이나 일을 꺼내요. HOUR 같은 시각 부분은 TIMESTAMP 타입에서만 꺼낼 수 있어서 DATE에 쓰면 오류가 나요.

| 용어 | 뜻 |
|---|---|
| TIMESTAMP | DATE처럼 날짜와 시각을 담되, 초 아래 소수까지 담는 또 다른 날짜 타입이에요 |
| 날짜 TRUNC | 두 번째 인자로 준 단위의 시작으로 내려요 |
| 날짜 ROUND | 단위의 절반을 넘으면 다음 단위의 시작으로 올려요 |

| 단위 | TRUNC 결과 | ROUND가 올라가는 기준 |
|---|---|---|
| 생략(일) | 그날 0시 | 정오(12시)부터 다음 날 0시 |
| 'MM'(월) | 그 달 1일 | 16일부터 다음 달 1일 |
| 'YYYY'(연) | 그해 1월 1일 | 7월 1일부터 다음 해 1월 1일 |

아래 마지막 예시의 `TO_DATE`는 문자를 날짜로 바꾸는 함수인데, 시각이 든 날짜를 만들려고 썼어요. 자세한 쓰임은 변환 함수에서 다뤄요.

```sql
SELECT EXTRACT(YEAR FROM 입사일), EXTRACT(MONTH FROM 입사일), EXTRACT(DAY FROM 입사일) FROM 사원 WHERE 사번 = 1002;
-- 결과는 차례로 2018, 7, 16이에요
-- 오류: DATE에서는 시각 부분을 꺼낼 수 없어요 (ORA-30076, 꺼낼 수 없는 부분)
SELECT EXTRACT(HOUR FROM DATE '2024-01-31') FROM DUAL;
SELECT TRUNC(DATE '2024-07-16', 'MM'), ROUND(DATE '2024-07-16', 'MM'), ROUND(DATE '2024-07-15', 'MM') FROM DUAL;
-- 결과는 차례로 2024-07-01, 2024-08-01, 2024-07-01이에요
SELECT TRUNC(DATE '2024-07-16', 'YYYY'), ROUND(DATE '2024-07-16', 'YYYY'), ROUND(DATE '2024-06-30', 'YYYY') FROM DUAL;
-- 결과는 차례로 2024-01-01, 2025-01-01, 2024-01-01이에요
SELECT TRUNC(TO_DATE('2024-01-31 23:59', 'YYYY-MM-DD HH24:MI')), ROUND(TO_DATE('2024-01-31 12:00', 'YYYY-MM-DD HH24:MI')) FROM DUAL;
-- 결과는 차례로 2024-01-31, 2024-02-01이에요
```

## 자주 헷갈리는 점 — 말일, 부호, 그날 빼기 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| 날짜에서 날짜를 빼면 날짜가 나와요 | 두 날짜 사이의 일 수인 숫자가 나와요 |
| 날짜 + 1은 1시간 뒤예요 | 하루 뒤예요. 1시간은 1/24, 한 달은 ADD_MONTHS로 더해요 |
| 한 달 뒤는 + 30과 같아요 | `DATE '2024-01-31' + 30`은 2월을 건너뛴 2024-03-01이고, `ADD_MONTHS(DATE '2024-01-31', 1)`은 2024-02-29예요 |
| ADD_MONTHS는 일(日)을 그대로 두어요 | 결과 달에 같은 날이 없으면 그 달의 말일로 맞춰서, 1월 31일 + 1개월은 2024년이면 2월 29일, 2023년이면 2월 28일이에요 |
| 2024-02-29 + 1개월은 3월 29일이에요 | 원래 날짜가 말일이면 결과도 말일로 맞춰서 3월 31일이에요 |
| MONTHS_BETWEEN은 늘 양수예요 | 앞 날짜에서 뒤 날짜를 빼서, 앞이 더 이르면 음수예요 |
| NEXT_DAY는 그날이 그 요일이면 그날을 돌려줘요 | 그날은 후보에서 빠져요. 월요일인 2024-01-29의 NEXT_DAY 'MONDAY'는 2024-02-05예요 |
| `WHERE 입사일 = SYSDATE`로 오늘 입사자를 찾아요 | SYSDATE에 시·분·초가 붙어 0시로 저장된 입사일과 같아지지 않아요. `TRUNC(SYSDATE)`로 시각을 버려요 |

```sql
SELECT DATE '2024-01-31' + 30, ADD_MONTHS(DATE '2024-01-31', 1), ADD_MONTHS(DATE '2023-01-31', 1) FROM DUAL;
-- 결과는 차례로 2024-03-01, 2024-02-29, 2023-02-28이에요
SELECT ADD_MONTHS(DATE '2024-02-29', 1), ADD_MONTHS(DATE '2024-04-30', 1), ADD_MONTHS(DATE '2024-03-31', -1) FROM DUAL;
-- 결과는 차례로 2024-03-31, 2024-05-31, 2024-02-29예요
SELECT MONTHS_BETWEEN(DATE '2024-01-15', DATE '2024-03-15'), ROUND(MONTHS_BETWEEN(DATE '2024-03-01', DATE '2024-01-15'), 2), MONTHS_BETWEEN(DATE '2024-02-29', DATE '2024-01-31') FROM DUAL;
-- 결과는 차례로 -2, 1.55, 1이에요
```

MONTHS_BETWEEN은 두 날짜의 일이 같거나 둘 다 말일이면 정수가 나와요. 그렇지 않으면 남는 날을 한 달 31일 기준으로 나눠 소수로 붙이는데, 가운데 1.55는 이렇게 나와요.

| 단계 | 내용 |
|---|---|
| 달 빼기 | 3월에서 1월을 빼서 2개월이에요 |
| 일 빼기 | 1일에서 15일을 빼서 -14일이에요 |
| 31로 나누기 | -14일을 31로 나누면 약 -0.4516개월이에요 |
| 더하기 | 2 - 0.4516 = 1.5484이고, 소수 둘째 자리로 반올림하면 1.55예요 |

```sql
SELECT ROUND(MONTHS_BETWEEN(DATE '2024-03-01', DATE '2024-01-15'), 4) FROM DUAL;   -- 소수 넷째 자리까지 남기면 1.5484예요
```

SQL Server에서는 SYSDATE 대신 `GETDATE()`, 달 더하기는 `DATEADD(MONTH, 1, 날짜)`, 두 날짜의 차이는 `DATEDIFF(DAY, 시작 날짜, 끝 날짜)`를 써요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| ADD_MONTHS(DATE '2023-02-28', 1)의 결과는 2023-03-31이에요 | O | 평년 2월 28일은 말일이라서 결과도 3월의 말일이에요 |
| DATE '2024-01-31' + 1/1440은 2024-01-31 01:00:00이에요 | X | 1/1440은 1분이라서 00:01:00이에요 |
| ROUND(DATE '2024-07-16', 'MM')은 2024-07-01이에요 | X | 16일부터는 다음 달 1일로 올려서 2024-08-01이에요 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

날짜 + 숫자, 날짜 - 날짜, 날짜 + 날짜 가운데 결과의 종류나 오류 여부를 고르는 문제가 기본이에요. SYSDATE가 나오면 결과 날짜보다 "시각이 들어 있다"는 성질을 묻는 경우가 많아요.

| 나오는 모양 | 푸는 법 |
|---|---|
| 1월 31일이나 2월 말일에 ADD_MONTHS | 결과 달의 말일인지부터 확인해요 |
| 날짜 순서를 바꾼 MONTHS_BETWEEN | 앞 날짜 - 뒤 날짜로 부호를 정해요 |
| 날짜 ROUND | 기준점 정오, 16일, 7월 1일만 떠올려요 |""",
    "checkQuestions": [
        question(1, "Oracle에서 오류가 나는 날짜 계산은 무엇인가요?", "date-arithmetic",
                 "날짜끼리 더하는 것은 뜻이 없는 계산이라 ORA-00975(날짜끼리 더할 수 없음) 오류가 나요. 날짜끼리 빼는 것은 일 수를 돌려줘요.",
                 [choice("A", "날짜 + 숫자", rationale="그 숫자만큼 일이 지난 날짜가 나와요."),
                  choice("B", "날짜 - 숫자", rationale="그 숫자만큼 이전 날짜가 나와요."),
                  choice("C", "날짜 - 날짜", rationale="두 날짜 사이의 일 수가 숫자로 나와요."),
                  choice("D", "날짜 + 날짜", True, "날짜끼리는 더할 수 없어서 오류가 나요.")]),
        question(2, "다음 SQL의 결과는 무엇인가요?", "confusing",
                 "2024년 2월에는 31일이 없으므로 ADD_MONTHS는 2월의 말일을 돌려줘요. 2024년은 윤년이라 말일이 29일이에요.",
                 [choice("A", "2024-03-02", rationale="1월 31일에 31일을 더한 결과예요."),
                  choice("B", "2024-02-29", True, "결과 달에 같은 날이 없어서 그 달의 말일이 돼요."),
                  choice("C", "2024-02-28", rationale="평년인 2023년이라면 맞지만, 2024년 2월은 29일까지 있어요."),
                  choice("D", "2024-03-01", rationale="한 달을 30일로 보고 더한 결과예요.")],
                 stem_sql="SELECT ADD_MONTHS(DATE '2024-01-31', 1) FROM DUAL;"),
        question(3, "다음 SQL의 결과는 무엇인가요?", "confusing",
                 "MONTHS_BETWEEN은 앞 날짜에서 뒤 날짜를 빼요. 앞 날짜가 두 달 이르므로 결과는 -2예요.",
                 [choice("A", "-2", True, "앞 날짜가 더 이르므로 음수가 나와요."),
                  choice("B", "2", rationale="날짜 순서를 바꾸었을 때의 결과예요."),
                  choice("C", "-60", rationale="날짜끼리 뺀 일 수이고, MONTHS_BETWEEN은 개월 수를 돌려줘요."),
                  choice("D", "오류가 난다", rationale="앞 날짜가 더 일러도 오류 없이 음수로 계산돼요.")],
                 stem_sql="SELECT MONTHS_BETWEEN(DATE '2024-01-15', DATE '2024-03-15') FROM DUAL;"),
        question(4, "2024년 1월 29일은 월요일이에요. 다음 SQL의 결과는 무엇인가요?", "confusing",
                 "NEXT_DAY는 기준 날짜를 빼고 그다음에 오는 요일을 찾아요. 그래서 그날이 아니라 일주일 뒤 월요일이 나와요.",
                 [choice("A", "2024-01-29", rationale="기준 날짜는 후보에 들지 않아요."),
                  choice("B", "2024-01-22", rationale="지난 월요일이고, NEXT_DAY는 앞으로 오는 요일을 찾아요."),
                  choice("C", "2024-02-05", True, "기준 날짜 다음에 처음 오는 월요일이에요."),
                  choice("D", "2024-01-30", rationale="하루 뒤인 화요일이에요.")],
                 stem_sql="SELECT NEXT_DAY(DATE '2024-01-29', 'MONDAY') FROM DUAL;"),
        question(5, "이지은(사번 1002)의 입사일은 2018-07-16이에요. 다음 SQL의 결과는 무엇인가요?", "month-functions",
                 "안쪽의 ADD_MONTHS가 한 달 뒤인 2018-08-16을 만들고, 바깥의 LAST_DAY가 그 달의 말일을 돌려줘요. 8월은 31일까지 있어요.",
                 [choice("A", "2018-08-16", rationale="안쪽 ADD_MONTHS만 계산한 결과예요."),
                  choice("B", "2018-08-31", True, "한 달 뒤인 8월의 말일이에요."),
                  choice("C", "2018-07-31", rationale="입사한 달의 말일인데, 안쪽에서 한 달을 먼저 더해요."),
                  choice("D", "2018-08-30", rationale="8월은 30일이 아니라 31일까지 있어요.")],
                 stem_sql="SELECT LAST_DAY(ADD_MONTHS(입사일, 1)) FROM 사원 WHERE 사번 = 1002;"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 예시
        sql_check("SELECT DATE '2024-01-31' + 1, DATE '2024-03-01' - 1, DATE '2024-03-01' - DATE '2024-02-01' FROM DUAL",
                  [["2024-02-01", "2024-02-29", 29]]),
        sql_check("SELECT DATE '2024-01-31' + 1/24, DATE '2024-01-31' + 30/(24*60), DATE '2024-01-31' + 0.5 FROM DUAL",
                  [["2024-01-31 01:00:00", "2024-01-31 00:30:00", "2024-01-31 12:00:00"]]),
        sql_error_check("SELECT DATE '2024-01-31' + DATE '2024-01-01' FROM DUAL", "ORA-00975"),
        sql_check("SELECT TO_DATE('2024-01-31 18:00', 'YYYY-MM-DD HH24:MI') - DATE '2024-01-31' FROM DUAL", [[0.75]]),
        sql_check("SELECT 이름, DATE '2024-12-31' - 입사일 FROM 사원 WHERE 사번 = 1008", [["윤서연", 225]]),
        sql_check("SELECT ADD_MONTHS(DATE '2024-01-15', 1), MONTHS_BETWEEN(DATE '2024-03-15', DATE '2024-01-15'), LAST_DAY(DATE '2024-02-10'), NEXT_DAY(DATE '2024-01-31', 'MONDAY') FROM DUAL",
                  [["2024-02-15", 2, "2024-02-29", "2024-02-05"]]),
        HIRE_DATE_MONTH_EXAMPLE.check,
        sql_check("SELECT EXTRACT(YEAR FROM 입사일), EXTRACT(MONTH FROM 입사일), EXTRACT(DAY FROM 입사일) FROM 사원 WHERE 사번 = 1002",
                  [[2018, 7, 16]]),
        sql_error_check("SELECT EXTRACT(HOUR FROM DATE '2024-01-31') FROM DUAL", "ORA-30076"),
        sql_check("SELECT TRUNC(DATE '2024-07-16', 'MM'), ROUND(DATE '2024-07-16', 'MM'), ROUND(DATE '2024-07-15', 'MM') FROM DUAL",
                  [["2024-07-01", "2024-08-01", "2024-07-01"]]),
        sql_check("SELECT TRUNC(DATE '2024-07-16', 'YYYY'), ROUND(DATE '2024-07-16', 'YYYY'), ROUND(DATE '2024-06-30', 'YYYY') FROM DUAL",
                  [["2024-01-01", "2025-01-01", "2024-01-01"]]),
        sql_check("SELECT TRUNC(TO_DATE('2024-01-31 23:59', 'YYYY-MM-DD HH24:MI')), ROUND(TO_DATE('2024-01-31 12:00', 'YYYY-MM-DD HH24:MI')) FROM DUAL",
                  [["2024-01-31", "2024-02-01"]]),
        sql_check("SELECT DATE '2024-01-31' + 30, ADD_MONTHS(DATE '2024-01-31', 1), ADD_MONTHS(DATE '2023-01-31', 1) FROM DUAL",
                  [["2024-03-01", "2024-02-29", "2023-02-28"]]),
        sql_check("SELECT ADD_MONTHS(DATE '2024-02-29', 1), ADD_MONTHS(DATE '2024-04-30', 1), ADD_MONTHS(DATE '2024-03-31', -1) FROM DUAL",
                  [["2024-03-31", "2024-05-31", "2024-02-29"]]),
        sql_check("SELECT MONTHS_BETWEEN(DATE '2024-01-15', DATE '2024-03-15'), ROUND(MONTHS_BETWEEN(DATE '2024-03-01', DATE '2024-01-15'), 2), MONTHS_BETWEEN(DATE '2024-02-29', DATE '2024-01-31') FROM DUAL",
                  [[-2, 1.55, 1]]),
        sql_check("SELECT NEXT_DAY(DATE '2024-01-29', 'MONDAY'), TO_CHAR(DATE '2024-01-29', 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') FROM DUAL",
                  [["2024-02-05", "MON"]]),
        sql_check("SELECT ROUND(MONTHS_BETWEEN(DATE '2024-03-01', DATE '2024-01-15'), 4) FROM DUAL", [[1.5484]]),
        sql_check("SELECT ADD_MONTHS(DATE '2023-02-28', 1), DATE '2024-01-31' + 1/1440 FROM DUAL",
                  [["2023-03-31", "2024-01-31 00:01:00"]]),
        # 확인 문제 (stemSql·보기)
        sql_check("SELECT ADD_MONTHS(DATE '2024-01-31', 1) FROM DUAL;", [["2024-02-29"]]),
        sql_check("SELECT DATE '2024-01-31' + 31, DATE '2024-01-31' + 30 FROM DUAL", [["2024-03-02", "2024-03-01"]]),
        sql_check("SELECT MONTHS_BETWEEN(DATE '2024-01-15', DATE '2024-03-15') FROM DUAL;", [[-2]]),
        sql_check("SELECT DATE '2024-01-15' - DATE '2024-03-15' FROM DUAL", [[-60]]),
        sql_check("SELECT NEXT_DAY(DATE '2024-01-29', 'MONDAY') FROM DUAL;", [["2024-02-05"]]),
        sql_check("SELECT LAST_DAY(ADD_MONTHS(입사일, 1)) FROM 사원 WHERE 사번 = 1002;", [["2018-08-31"]]),
        sql_check("SELECT ADD_MONTHS(입사일, 1) FROM 사원 WHERE 사번 = 1002", [["2018-08-16"]]),
    ],
}
