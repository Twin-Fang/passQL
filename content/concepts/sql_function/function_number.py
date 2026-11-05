"""개념: 숫자 함수 (4단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

EMPLOYEE_SALARY_TABLE = to_employee_table_md("사번", "이름", "급여")

# 월급 다듬기: ROUND(반올림)·CEIL(올림)·TRUNC(10 단위 버림), 사원 2명
MONTHLY_SALARY_EXAMPLE = sql_example(
    "SELECT 이름, 급여, ROUND(급여 / 12, 1), CEIL(급여 / 12), TRUNC(급여 / 12, -1)\n"
    "FROM 사원\n"
    "WHERE 사번 IN (1002, 1007)\n"
    "ORDER BY 사번;",
    ("이름", "급여", "ROUND(급여 / 12, 1)", "CEIL(급여 / 12)", "TRUNC(급여 / 12, -1)"),
    [["이지은", 2500, 208.3, 209, 200], ["오지민", 2200, 183.3, 184, 180]],
)

# 같은 1.5 <-> -1.5 에 네 함수: 음수에서 결과가 갈라짐
POSITIVE_VERSUS_NEGATIVE_EXAMPLE = sql_example(
    "SELECT 1.5 AS 값, ROUND(1.5), CEIL(1.5), FLOOR(1.5), TRUNC(1.5) FROM DUAL\n"
    "UNION ALL\n"
    "SELECT -1.5, ROUND(-1.5), CEIL(-1.5), FLOOR(-1.5), TRUNC(-1.5) FROM DUAL;",
    ("값", "ROUND", "CEIL", "FLOOR", "TRUNC"),
    [[1.5, 2, 2, 1, 1], [-1.5, -2, -1, -2, -1]],
    is_ordered=False,
)

# MOD 로 짝수 사번 고르기 (8명 중 4명)
EVEN_EMPLOYEE_NUMBER_EXAMPLE = sql_example(
    "SELECT 사번, 이름\n"
    "FROM 사원\n"
    "WHERE MOD(사번, 2) = 0\n"
    "ORDER BY 사번;",
    ("사번", "이름"),
    [[1002, "이지은"], [1004, "최유나"], [1006, "한도윤"], [1008, "윤서연"]],
)

CONCEPT = {
    "tagKey": "function-number",
    "topicCode": "sql_function",
    "sortOrder": 2,
    "title": "숫자 함수",
    "summary": "숫자를 반올림·버림·올림하고 나머지를 구하는 함수이고, 음수일 때 결과가 갈라져요",
    "coreMd": (
        "- `ROUND`는 반올림, `TRUNC`는 버림이고, 자리 수가 음수면 10 단위, 100 단위로 다듬어요.\n"
        "- `CEIL`은 더 큰 정수 쪽으로, `FLOOR`는 더 작은 정수 쪽으로, `TRUNC`는 0 쪽으로 가요.\n"
        "- 그래서 -1.5에서 `ROUND`와 `FLOOR`는 -2, `CEIL`과 `TRUNC`는 -1이에요.\n"
        "- `MOD`의 나머지는 앞의 수 부호를 따라서 `MOD(-10, 3)`은 -1이고, `MOD(10, 0)`은 오류 없이 10이에요."
    ),
    "detailMd": f"""## 숫자 함수가 하는 일 — 어디서 다듬느냐에 따라 금액이 달라져요 {{#why}}

급여 2500을 12로 나누면 208.333...처럼 소수가 끝없이 이어져요. 반올림할지, 버릴지, 올릴지에 따라 금액이 달라지니 숫자 함수로 원하는 자리에서 다듬어요.

## 숫자 함수 한눈에 보기 — 아홉 개, 헷갈리는 건 다섯 개 {{#definition}}

숫자 함수는 숫자를 받아 숫자를 돌려주는 단일행 함수예요. 시험이 결과를 헷갈리게 묻는 함수는 주로 ROUND, TRUNC, CEIL, FLOOR, MOD예요.

| 함수 | 하는 일 | 예 | 결과 |
|---|---|---|---|
| ROUND(숫자, 자리 수) | 지정한 자리까지 반올림해요 | ROUND(1234.567, 2) | 1234.57 |
| TRUNC(숫자, 자리 수) | 지정한 자리 아래를 버려요 | TRUNC(1234.567, 2) | 1234.56 |
| CEIL(숫자) | 그 수보다 크거나 같은 정수 중 가장 작은 정수예요 | CEIL(1.1) | 2 |
| FLOOR(숫자) | 그 수보다 작거나 같은 정수 중 가장 큰 정수예요 | FLOOR(1.9) | 1 |
| MOD(숫자1, 숫자2) | 숫자1을 숫자2로 나눈 나머지예요 | MOD(10, 3) | 1 |
| ABS(숫자) | 부호를 뗀 절댓값이에요 | ABS(-15) | 15 |
| SIGN(숫자) | 음수면 -1, 0이면 0, 양수면 1이에요 | SIGN(-15) | -1 |
| POWER(숫자1, 숫자2) | 숫자1을 숫자2번 곱한 거듭제곱이에요 | POWER(2, 10) | 1024 |
| SQRT(숫자) | 제곱근이에요 | SQRT(16) | 4 |

```sql
SELECT ROUND(1234.567, 2), TRUNC(1234.567, 2), CEIL(1.1), FLOOR(1.9), MOD(10, 3) FROM DUAL;
-- 결과는 차례로 1234.57, 1234.56, 2, 1, 1이에요
SELECT ABS(-15), SIGN(-15), POWER(2, 10), SQRT(16) FROM DUAL;
-- 결과는 차례로 15, -1, 1024, 4예요
```

## ROUND와 TRUNC — 자리 수가 음수면 소수점 왼쪽을 다듬어요 {{#round-trunc}}

두 번째 인자인 자리 수가 어디까지 남길지를 정해요. ROUND는 남길 자리 바로 오른쪽 한 자리가 5 이상이면 올리고, TRUNC는 그 자리를 보지 않고 버려요.

| 자리 수 | 남기는 자리 | ROUND가 보는 자리 | ROUND | TRUNC |
|---|---|---|---|---|
| 2 | 소수 둘째 자리까지 | 소수 셋째 자리(7) | 1234.57 | 1234.56 |
| 1 | 소수 첫째 자리까지 | 소수 둘째 자리(6) | 1234.6 | 1234.5 |
| 0 또는 생략 | 일의 자리까지(정수) | 소수 첫째 자리(5) | 1235 | 1234 |
| -1 | 십의 자리까지(10 단위) | 일의 자리(4) | 1230 | 1230 |
| -2 | 백의 자리까지(100 단위) | 십의 자리(3) | 1200 | 1200 |

```sql
SELECT ROUND(1234.567, 1), TRUNC(1234.567, 1), ROUND(1234.567), TRUNC(1234.567) FROM DUAL;
-- 결과는 차례로 1234.6, 1234.5, 1235, 1234예요
SELECT ROUND(1234.567, -1), TRUNC(1234.567, -1), ROUND(1234.567, -2), TRUNC(1234.567, -2) FROM DUAL;
-- 결과는 차례로 1230, 1230, 1200, 1200이에요
```

사원 표로 월급을 세 가지 방식으로 다듬어 볼게요. 이 사번과 급여는 뒤의 MOD 예시에서도 써요.

{EMPLOYEE_SALARY_TABLE}

{MONTHLY_SALARY_EXAMPLE.markdown}

CEIL은 바로 아래에서 다루는데, 소수 부분이 있으면 다음 정수로 올리는 함수예요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| ROUND(1250, -2)의 결과는 1300이에요 | O | 십의 자리가 5라서 백의 자리로 올라가요 |
| TRUNC(1299, -2)는 십의 자리 9를 보고 1300으로 올려요 | X | TRUNC는 보지 않고 버려서 1200이에요 |

## CEIL과 FLOOR — 천장과 바닥은 숫자 크기로 정해요 {{#ceil-floor}}

| 용어 | 뜻 |
|---|---|
| CEIL (천장) | 수직선에서 오른쪽, 곧 더 큰 쪽의 가장 가까운 정수로 가요 |
| FLOOR (바닥) | 수직선에서 왼쪽, 곧 더 작은 쪽의 가장 가까운 정수로 가요 |

양수에서는 CEIL이 올림, FLOOR가 버림처럼 보여요. 음수에서는 CEIL(-1.1)이 -1, FLOOR(-1.9)가 -2가 돼요.

```sql
SELECT CEIL(1.1), FLOOR(1.9), CEIL(-1.1), FLOOR(-1.9), CEIL(3) FROM DUAL;   -- 결과는 차례로 2, 1, -1, -2, 3이에요
-- 오류: CEIL은 자리 수 인자를 받지 않아요 (ORA-00909, 인자 개수가 맞지 않음)
SELECT CEIL(1.5, 1) FROM DUAL;
```

이미 정수인 값은 두 함수 모두 그대로 돌려줘요. ROUND와 달리 자리 수를 받지 않고 언제나 정수로 맞춰요.

## 나머지와 부호 — MOD·ABS·SIGN·POWER·SQRT {{#mod-etc}}

| 함수 | 기억할 규칙 | 예 |
|---|---|---|
| MOD | 나머지의 부호는 앞의 수(나눠지는 수)를 따라요 | MOD(-10, 3)은 -1, MOD(10, -3)은 1 |
| MOD | 나누는 수가 0이면 오류 없이 앞의 수를 돌려줘요 | MOD(10, 0)은 10 |
| 나눗셈 / | 0으로 나누면 오류가 나요 | 10 / 0은 ORA-01476(나누는 수가 0) |
| ABS | 부호를 떼고 크기만 남겨요 | ABS(-15)와 ABS(15)는 15 |
| SIGN | 크기를 버리고 부호만 남겨요. 0은 0이에요 | SIGN(0)은 0 |
| POWER | 지수가 음수면 분수가 돼요 | POWER(2, -1)은 0.5 |
| SQRT | 음수는 제곱근을 구할 수 없어서 오류가 나요 | SQRT(-1)은 ORA-01428(인자가 허용 범위 밖) |

```sql
SELECT MOD(10, 3), MOD(-10, 3), MOD(10, -3), MOD(10, 0) FROM DUAL;   -- 결과는 차례로 1, -1, 1, 10이에요
-- 오류: 0으로는 나눌 수 없어요 (ORA-01476, 나누는 수가 0)
SELECT 10 / 0 FROM DUAL;
SELECT ABS(-15), ABS(15), SIGN(-15), SIGN(0), SIGN(15), POWER(2, -1) FROM DUAL;   -- 결과는 차례로 15, 15, -1, 0, 1, 0.5예요
-- 오류: 음수의 제곱근은 구할 수 없어요 (ORA-01428, 인자가 허용 범위 밖)
SELECT SQRT(-1) FROM DUAL;
```

MOD는 짝수와 홀수를 가를 때 자주 써요. 2로 나눈 나머지가 0이면 짝수라서, 위 사원 표에서 네 명이 나와요.

{EVEN_EMPLOYEE_NUMBER_EXAMPLE.markdown}

## 자주 헷갈리는 점 — 음수에서는 네 함수가 갈라져요 {{#confusing}}

같은 1.5와 -1.5에 네 함수를 써 보면 차이가 바로 보여요.

{POSITIVE_VERSUS_NEGATIVE_EXAMPLE.markdown}

| 함수 | 움직이는 방향 |
|---|---|
| ROUND | 가장 가까운 정수로 가고, 딱 절반(.5)이면 0에서 먼 쪽으로 가요 |
| CEIL | 더 큰 정수 쪽으로 가요 |
| FLOOR | 더 작은 정수 쪽으로 가요 |
| TRUNC | 소수 부분을 버려서 0 쪽으로 가요 |

| 헷갈리는 말 | 실제로는 |
|---|---|
| ROUND(-1.5)는 -1이에요 | Oracle의 ROUND는 .5를 0에서 먼 쪽으로 보내서 -2예요 |
| TRUNC와 FLOOR는 같은 함수예요 | 양수에서만 같고, 음수에서는 TRUNC(-1.5)가 -1, FLOOR(-1.5)가 -2로 갈려요 |
| ROUND와 CEIL은 .5에서 결과가 같아요 | 1.5에서는 둘 다 2지만, -1.5에서는 ROUND가 -2, CEIL이 -1이에요 |
| CEIL은 반올림이에요 | CEIL은 올림이라서 CEIL(1.1)은 2이고, ROUND(1.1)은 1이에요 |
| 자리 수 -2는 소수 둘째 자리예요 | 음수 자리 수는 소수점 왼쪽이라서 -2는 백의 자리까지 남겨요 |
| MOD(-10, 3)은 수학처럼 2예요 | Oracle의 MOD는 앞의 수 부호를 따라서 -1이에요. 뒤의 수 부호는 영향을 주지 않아요 |

```sql
SELECT ROUND(1.1), CEIL(1.1) FROM DUAL;   -- 결과는 차례로 1, 2예요
SELECT ROUND(1234.567, -2), ROUND(1250, -2), TRUNC(1299, -2) FROM DUAL;   -- 결과는 차례로 1200, 1300, 1200이에요
```

SQL Server에서는 CEIL 대신 CEILING을 쓰고, MOD 함수 대신 `%` 연산자로 나머지를 구해요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| FLOOR(-2.5)의 결과는 -3이에요 | O | -2.5보다 작은 쪽의 가장 가까운 정수는 -3이에요 |
| MOD(10, -3)의 결과는 -1이에요 | X | 부호는 앞의 수 10을 따라서 1이에요 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

-1.5나 -2.5 같은 음수 하나에 ROUND, CEIL, FLOOR, TRUNC를 함께 쓰고 결과를 고르는 문제가 가장 자주 나와요. 수직선을 떠올려 CEIL은 오른쪽, FLOOR는 왼쪽, TRUNC는 0 쪽으로 옮기면 실수가 줄어요.

| 나오는 모양 | 푸는 법 |
|---|---|
| ROUND(1234.567, -2) | 남길 자리 바로 오른쪽(십의 자리)만 봐요 |
| MOD에 음수 | 앞의 수 부호를 그대로 붙여요 |
| WHERE MOD(사번, 2) = 0 | 나머지 0이면 짝수 행이에요 |""",
    "checkQuestions": [
        question(1, "숫자 함수와 하는 일을 짝지은 것으로 알맞지 않은 것은 무엇인가요?", "definition",
                 "TRUNC는 지정한 자리 아래를 버리는 함수예요. 다음 정수로 올리는 함수는 CEIL이에요.",
                 [choice("A", "ROUND: 지정한 자리까지 반올림한다", rationale="ROUND가 하는 일이 맞아요."),
                  choice("B", "TRUNC: 지정한 자리에서 올림한다", True, "TRUNC는 올리지 않고 버리므로 알맞지 않아요."),
                  choice("C", "MOD: 나눈 나머지를 돌려준다", rationale="MOD가 하는 일이 맞아요."),
                  choice("D", "SIGN: 부호에 따라 -1, 0, 1을 돌려준다", rationale="SIGN이 하는 일이 맞아요.")]),
        question(2, "다음 SQL의 결과는 무엇인가요?", "round-trunc",
                 "자리 수 -2는 100 단위로 맞추라는 뜻이에요. 십의 자리가 3이라서 반올림해도 올라가지 않아 1200이 돼요.",
                 [choice("A", "1234.57", rationale="자리 수 2를 주었을 때의 결과예요."),
                  choice("B", "1300", rationale="십의 자리가 3이라서 백의 자리로 올라가지 않아요."),
                  choice("C", "1235", rationale="자리 수를 생략했을 때의 결과예요."),
                  choice("D", "1200", True, "100 단위로 반올림한 결과예요.")],
                 stem_sql="SELECT ROUND(1234.567, -2) FROM DUAL;"),
        question(3, "다음 중 결과가 -2인 것은 무엇인가요?", "confusing",
                 "FLOOR는 더 작은 정수 쪽으로 가므로 -1.5는 -2가 돼요. CEIL과 TRUNC는 -1, ABS는 1.5예요.",
                 [choice("A", "CEIL(-1.5)", rationale="더 큰 정수 쪽인 -1이 돼요."),
                  choice("B", "TRUNC(-1.5)", rationale="소수 부분만 버려서 -1이 돼요."),
                  choice("C", "FLOOR(-1.5)", True, "더 작은 정수 쪽인 -2가 돼요."),
                  choice("D", "ABS(-1.5)", rationale="부호를 떼어 1.5가 돼요.")]),
        question(4, "다음 SQL의 결과는 무엇인가요?", "confusing",
                 "Oracle의 MOD는 나머지에 앞의 수 부호를 붙여요. -10을 3으로 나누면 몫이 -3이고 나머지는 -1이에요.",
                 [choice("A", "-1", True, "앞의 수가 음수라서 나머지도 음수예요."),
                  choice("B", "2", rationale="0 이상으로 맞춘 수학식 나머지인데, Oracle의 MOD는 앞의 수 부호를 따라요."),
                  choice("C", "1", rationale="부호를 뗀 값이에요. 앞의 수가 음수이므로 나머지도 음수예요."),
                  choice("D", "-3", rationale="나머지가 아니라 몫이에요.")],
                 stem_sql="SELECT MOD(-10, 3) FROM DUAL;"),
        question(5, "박서준(사번 1003, 급여 2800)의 세금을 급여의 3.3%로 계산하고 소수 부분은 올림한다고 할 때, 다음 SQL의 결과는 무엇인가요?",
                 "ceil-floor",
                 "2800 × 0.033은 92.4이고, CEIL은 소수 부분이 있으면 다음 정수로 올려요. 그래서 결과는 93이에요.",
                 [choice("A", "92", rationale="ROUND나 TRUNC를 썼을 때의 결과예요."),
                  choice("B", "93", True, "92.4를 다음 정수로 올린 결과예요."),
                  choice("C", "92.4", rationale="다듬기 전의 계산 결과예요."),
                  choice("D", "100", rationale="CEIL은 10 단위가 아니라 정수 단위로 올려요.")],
                 stem_sql="SELECT CEIL(급여 * 0.033) FROM 사원 WHERE 사번 = 1003;"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 예시
        sql_check("SELECT ROUND(1234.567, 2), TRUNC(1234.567, 2), CEIL(1.1), FLOOR(1.9), MOD(10, 3) FROM DUAL",
                  [[1234.57, 1234.56, 2, 1, 1]]),
        sql_check("SELECT ABS(-15), SIGN(-15), POWER(2, 10), SQRT(16) FROM DUAL", [[15, -1, 1024, 4]]),
        sql_check("SELECT ROUND(1234.567, 1), TRUNC(1234.567, 1), ROUND(1234.567), TRUNC(1234.567) FROM DUAL",
                  [[1234.6, 1234.5, 1235, 1234]]),
        sql_check("SELECT ROUND(1234.567, -1), TRUNC(1234.567, -1), ROUND(1234.567, -2), TRUNC(1234.567, -2) FROM DUAL",
                  [[1230, 1230, 1200, 1200]]),
        MONTHLY_SALARY_EXAMPLE.check,
        sql_check("SELECT CEIL(1.1), FLOOR(1.9), CEIL(-1.1), FLOOR(-1.9), CEIL(3) FROM DUAL", [[2, 1, -1, -2, 3]]),
        sql_error_check("SELECT CEIL(1.5, 1) FROM DUAL", "ORA-00909"),
        sql_check("SELECT MOD(10, 3), MOD(-10, 3), MOD(10, -3), MOD(10, 0) FROM DUAL", [[1, -1, 1, 10]]),
        sql_error_check("SELECT 10 / 0 FROM DUAL", "ORA-01476"),
        EVEN_EMPLOYEE_NUMBER_EXAMPLE.check,
        sql_check("SELECT ABS(-15), ABS(15), SIGN(-15), SIGN(0), SIGN(15), POWER(2, -1) FROM DUAL", [[15, 15, -1, 0, 1, 0.5]]),
        sql_error_check("SELECT SQRT(-1) FROM DUAL", "ORA-01428"),
        POSITIVE_VERSUS_NEGATIVE_EXAMPLE.check,
        sql_check("SELECT FLOOR(-2.5), MOD(10, -3) FROM DUAL", [[-3, 1]]),
        sql_check("SELECT ROUND(1.1), CEIL(1.1) FROM DUAL", [[1, 2]]),
        sql_check("SELECT ROUND(1234.567, -2), ROUND(1250, -2), TRUNC(1299, -2) FROM DUAL", [[1200, 1300, 1200]]),
        # 확인 문제 (stemSql·보기)
        sql_check("SELECT ROUND(1234.567, -2) FROM DUAL;", [[1200]]),
        sql_check("SELECT CEIL(-1.5), TRUNC(-1.5), FLOOR(-1.5), ABS(-1.5) FROM DUAL", [[-1, -1, -2, 1.5]]),
        sql_check("SELECT MOD(-10, 3) FROM DUAL;", [[-1]]),
        sql_check("SELECT CEIL(급여 * 0.033) FROM 사원 WHERE 사번 = 1003;", [[93]]),
        sql_check("SELECT 급여 * 0.033, ROUND(급여 * 0.033), TRUNC(급여 * 0.033) FROM 사원 WHERE 사번 = 1003", [[92.4, 92, 92]]),
    ],
}
