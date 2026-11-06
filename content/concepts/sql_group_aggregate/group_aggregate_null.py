"""개념: 집계 함수와 NULL (7단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

EMPLOYEE_COMMISSION_TABLE = to_employee_table_md("사번", "이름", "입사일", "급여", "커미션", "부서번호")

# 다섯 함수를 급여에 쓴 결과 (본문 결과 표 = 검증 기대값)
FIVE_FUNCTIONS_EXAMPLE = sql_example(
    "SELECT COUNT(*), SUM(급여), AVG(급여), MAX(급여), MIN(급여) FROM 사원;",
    ("COUNT(*)", "SUM(급여)", "AVG(급여)", "MAX(급여)", "MIN(급여)"),
    [[8, 20900, 2612.5, 3200, 2000]],
)
# COUNT 두 형태 (NULL 행 포함 <-> 제외)
COUNT_EXAMPLE = sql_example(
    "SELECT COUNT(*), COUNT(커미션), COUNT(부서번호) FROM 사원;",
    ("COUNT(*)", "COUNT(커미션)", "COUNT(부서번호)"),
    [[8, 4, 7]],
)
# SUM·AVG 도 NULL 행 건너뜀 (분모 4)
SUM_AVG_EXAMPLE = sql_example(
    "SELECT SUM(커미션), AVG(커미션) FROM 사원;",
    ("SUM(커미션)", "AVG(커미션)"),
    [[1000, 250]],
)
# 분모·NVL 위치 비교 (같은 입력, 세 식)
DENOMINATOR_EXAMPLE = sql_example(
    "SELECT SUM(커미션) / COUNT(*), AVG(NVL(커미션, 0)), NVL(AVG(커미션), 0) FROM 사원;",
    ("SUM(커미션)/COUNT(*)", "AVG(NVL(커미션, 0))", "NVL(AVG(커미션), 0)"),
    [[125, 125, 250]],
)
# 행 안 계산 <-> 열별 집계 후 더하기
ROW_SUM_EXAMPLE = sql_example(
    "SELECT SUM(급여 + 커미션), SUM(급여) + SUM(커미션) FROM 사원;",
    ("SUM(급여 + 커미션)", "SUM(급여) + SUM(커미션)"),
    [[11200, 21900]],
)
# DISTINCT 집계 (NULL 제외, 동점 2500 한 번만)
DISTINCT_EXAMPLE = sql_example(
    "SELECT COUNT(DISTINCT 부서번호), SUM(DISTINCT 급여) FROM 사원;",
    ("COUNT(DISTINCT 부서번호)", "SUM(DISTINCT 급여)"),
    [[3, 18400]],
)
# 맞는 행 0건 (40번 부서) > 1행, COUNT 0·나머지 NULL
EMPTY_GROUP_EXAMPLE = sql_example(
    "SELECT COUNT(*), SUM(급여), MAX(급여), NVL(SUM(급여), 0) FROM 사원 WHERE 부서번호 = 40;",
    ("COUNT(*)", "SUM(급여)", "MAX(급여)", "NVL(SUM(급여), 0)"),
    [[0, None, None, 0]],
)

CONCEPT = {
    "tagKey": "group-aggregate-null",
    "topicCode": "sql_group_aggregate",
    "sortOrder": 1,
    "title": "집계 함수와 NULL",
    "summary": "여러 행을 값 하나로 줄이는 함수이고, NULL인 행은 빼고 계산해요",
    "coreMd": (
        "- 집계 함수는 여러 행을 값 하나로 줄이고, GROUP BY 없이 쓰면 결과는 늘 **1행**이에요.\n"
        "- `COUNT(*)`만 **NULL 행까지** 세고, `COUNT(열)`과 SUM, AVG, MAX, MIN은 NULL 행을 빼요.\n"
        "- `AVG(커미션)`은 네 명으로 나눠 250이고, `AVG(NVL(커미션, 0))`은 여덟 명으로 나눠 **125**예요.\n"
        "- 맞는 행이 없으면 COUNT는 **0**을, SUM, AVG, MAX, MIN은 NULL을 돌려줘요.\n"
        "- GROUP BY 없이 일반 열과 집계 함수를 함께 쓰면 ORA-00937(한 행으로 묶을 수 없는 그룹 함수) 오류가 나요."
    ),
    "detailMd": f"""## 여러 행을 값 하나로 — 집계 함수가 하는 일 {{#why}}

"사원은 모두 몇 명인가요?"라는 질문에는 행을 하나씩 보여 주는 SELECT로 답하기 어려워요. 여덟 행을 숫자 하나로 줄여 주는 도구가 집계 함수이고, 이 글은 아래 사원 표로 설명해요.

{EMPLOYEE_COMMISSION_TABLE}

## 한 줄 정의 — 다섯 가지 집계 함수 {{#definition}}

| 용어 | 뜻 |
|---|---|
| 집계 함수 | 여러 행의 값을 모아 결과 값 하나를 만드는 함수예요. 시험에서는 그룹 함수(aggregate function)라고도 불러요 |
| 단일행 함수 | `LENGTH(이름)`처럼 행 하나를 받아 결과 하나를 돌려줘요. 행마다 결과가 하나씩 나와요 |

| 함수 | 하는 일 | 쓸 수 있는 자료 |
|---|---|---|
| COUNT | 개수를 세요 | 숫자, 문자, 날짜 |
| SUM | 합계를 구해요 | 숫자만 |
| AVG | 평균을 구해요 | 숫자만 |
| MAX | 가장 큰 값을 골라요 | 숫자, 문자, 날짜 |
| MIN | 가장 작은 값을 골라요 | 숫자, 문자, 날짜 |

{FIVE_FUNCTIONS_EXAMPLE.markdown}

SUM과 AVG에 `SUM(이름)`처럼 문자 열을 넣으면 ORA-01722(숫자가 아닌 값) 오류가 나요. 날짜 열에 쓴 `MAX(입사일)`은 가장 늦은 입사일 2024-05-20을, `MIN(입사일)`은 가장 이른 2015-03-02를 돌려줘요.

같은 값끼리 묶는 GROUP BY 절은 다음 개념에서 배워요. 이 절 없이 집계 함수를 쓰면 테이블 전체가 한 묶음이라서 결과는 언제나 1행이에요.

## NULL은 빼고 계산해요 — COUNT(*)와 COUNT(열) {{#null}}

`COUNT(*)`는 행 자체를 세므로 어떤 칸이 NULL이든 8을 돌려줘요. `COUNT(커미션)`처럼 괄호 안에 열을 적으면 그 열이 NULL이 아닌 행만 세요.

{COUNT_EXAMPLE.markdown}

`COUNT(커미션)`은 커미션이 NULL인 행을 빼고 세요.

| 행 | 처리 |
|---|---|
| 김민수 NULL | 빠짐 |
| 이지은 300 | 남음 |
| 박서준 0 | 남음 |
| 최유나 NULL | 빠짐 |
| 정하늘 NULL | 빠짐 |
| 한도윤 500 | 남음 |
| 오지민 200 | 남음 |
| 윤서연 NULL | 빠짐 |

박서준의 0은 값이라서 세는 데 들어가고, 부서번호가 NULL인 윤서연이 빠져서 `COUNT(부서번호)`는 7이에요.

{SUM_AVG_EXAMPLE.markdown}

SUM, AVG, MAX, MIN도 NULL 행을 건너뛰어요. 그래서 `AVG(커미션)`은 1000을 8이 아니라 **4로 나눈 250**이에요.

| 함수 | NULL인 행 | 맞는 행이 하나도 없을 때 |
|---|---|---|
| `COUNT(*)` | 세요 | 0 |
| `COUNT(열)` | 빼요 | 0 |
| SUM, AVG, MAX, MIN | 빼요 | NULL |

## 자주 헷갈리는 점 — 분모, NVL 위치, 행 안 계산 {{#confusing}}

시험은 NULL이 섞인 열의 평균과 합계에서 함정을 만들어요. 아래 표의 NVL은 NULL을 지정한 값으로 바꾸는 함수이고, `NVL(커미션, 0)`은 커미션이 NULL이면 0을 돌려줘요.

| 헷갈리는 말 | 실제로는 |
|---|---|
| `AVG(커미션)`은 합계를 전체 행 수 8로 나눠요 | NULL 행은 분모에서도 빠져요. 1000을 4로 나눠 250이에요 |
| 커미션 0도 NULL처럼 세지 않아요 | 0은 값이라서 `COUNT(커미션)`에 들어가요 |
| NVL을 안에 넣든 밖에 넣든 평균은 같아요 | 안쪽 NVL은 NULL을 0으로 바꾼 뒤 8명 평균 125, 바깥 NVL은 평균이 NULL일 때만 바꿔서 250이에요 |
| NULL이 섞인 열을 SUM하면 결과도 NULL이에요 | 집계 함수는 NULL 행을 건너뛰어 1000이에요. NULL이 되는 것은 `급여 + 커미션` 같은 행 안 계산이에요 |
| `SUM(급여 + 커미션)`과 `SUM(급여) + SUM(커미션)`은 같아요 | 앞쪽은 커미션 NULL인 행이 통째로 빠져 11200, 뒤쪽은 따로 더해 21900이에요 |
| `COUNT(DISTINCT 부서번호)`는 NULL도 값 하나로 세요 | DISTINCT를 써도 NULL은 세지 않아서 10, 20, 30 세 개예요 |
| 맞는 행이 없으면 결과도 0행이에요 | GROUP BY가 없으면 1행이 나와요. COUNT는 0이고 SUM과 MAX는 NULL이에요 |

아래는 같은 사원 표에 분모와 NVL 위치만 바꾼 세 식이에요. `SUM(커미션) / COUNT(*)`는 1000을 8로 나눠서, AVG와 값이 달라요.

{DENOMINATOR_EXAMPLE.markdown}

`SUM(급여 + 커미션)`은 행마다 먼저 더하므로, 커미션이 NULL인 네 명은 더한 값이 NULL이 되어 빠져요. 남은 네 명의 값 2800, 2800, 3200, 2400만 더해서 11200이 나와요.

{ROW_SUM_EXAMPLE.markdown}

## DISTINCT와 빈 결과 — 한 번만 세기, 그래도 1행 {{#distinct-empty}}

집계 함수 괄호 안에 DISTINCT를 쓰면 중복된 값을 하나로 줄인 뒤 집계해요. `SUM(DISTINCT 급여)`는 두 번 나오는 2500을 한 번만 더해서 20900보다 2500 적은 18400이에요.

{DISTINCT_EXAMPLE.markdown}

40번 부서에는 사원이 없어서 아래 조건에 맞는 행이 하나도 없어요. 셀 것이 없으면 개수는 0이지만 더하거나 고를 값이 없으면 NULL이 되고, 합계를 0으로 보이려면 바깥에서 `NVL(SUM(급여), 0)`으로 감싸요.

{EMPTY_GROUP_EXAMPLE.markdown}

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `SUM(DISTINCT 급여)`는 같은 급여 2500을 한 번만 더해요 | O | 중복 값을 하나로 줄인 뒤 더해서 18400이에요 |
| 40번 부서 조건으로 `SUM(급여)`를 구하면 0이 나와요 | X | 더할 값이 없으면 SUM은 NULL을 돌려줘요 |

## 일반 열과 함께 쓰면 — ORA-00937 {{#mixed-column}}

`MAX(급여)`는 값이 하나인데 이름은 여덟 개라서, 둘을 함께 SELECT 하면 한 행으로 만들 수 없어요. 그래서 급여가 가장 많은 사람의 이름이 나오지 않고 오류가 나요.

```sql
-- 오류: 이름은 여러 값인데 MAX(급여)는 한 값이에요 (ORA-00937, 한 행으로 묶을 수 없는 그룹 함수)
SELECT 이름, MAX(급여) FROM 사원;
```

| 하고 싶은 것 | 쓰는 방법 |
|---|---|
| 일반 열별로 집계하기 | 다음 개념인 GROUP BY로 그 열을 묶어요 |
| 최댓값을 가진 사원 찾기 | 서브쿼리로 최댓값을 따로 구해 비교해요. 서브쿼리는 쿼리 안에 넣은 또 다른 쿼리이고 6단원에서 다뤄요 |

## 꼭 외울 것 — NULL 행은 누가 세고 누가 빼나 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| `COUNT(*)` | NULL 행까지 모든 행을 세요 |
| `COUNT(열)`·SUM·AVG·MAX·MIN | 그 열이 NULL인 행을 빼고 계산해요 |
| `AVG(열)`의 분모 | NULL이 아닌 행 수 (커미션은 8이 아니라 4) |
| 맞는 행이 0건일 때 | 1행, COUNT는 0, 나머지는 NULL |
| GROUP BY 없는 집계 결과 | 언제나 1행 |
| SUM·AVG에 넣는 자료 | 숫자만, MAX·MIN·COUNT는 문자·날짜도 돼요 |
| 일반 열 + 집계, GROUP BY 없음 | 오류 (ORA-00937, 한 행으로 묶을 수 없음) |

## 시험에서는 이렇게 나와요 {{#exam-point}}

표를 주고 `COUNT(*)`, `COUNT(열)`, `AVG(열)`의 결과를 묻는 문제가 가장 많아요. 그 열의 NULL 행에 먼저 표시하고 COUNT와 AVG의 분모에서 빼면 되는데, 0은 값이라서 세는 데 들어간다는 점을 자주 노려요.

| 자주 나오는 문제 | 푸는 기준 |
|---|---|
| `SUM(A + B)`와 `SUM(A) + SUM(B)` | 행 안 계산은 NULL이 하나라도 있으면 그 행이 빠져요 |
| 조건에 맞는 행이 없을 때 | 1행이 나오고 COUNT는 0, 나머지는 NULL이에요 |
| 일반 열과 집계 함수를 함께 쓴 SQL | GROUP BY가 없으면 오류예요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `COUNT(부서번호)`는 8이에요 | X | 부서번호가 NULL인 윤서연이 빠져서 7이에요 |
| `MAX(입사일)`처럼 날짜 열에도 MAX를 쓸 수 있어요 | O | MAX, MIN, COUNT는 문자와 날짜에도 쓸 수 있어요 |""",
    "checkQuestions": [
        question(1, "집계 함수에 대한 설명으로 알맞은 것은 무엇인가요?", "definition",
                 "집계 함수는 여러 행을 모아 결과 값 하나를 만들어요. GROUP BY 없이 쓰면 테이블 전체가 한 묶음이 되어 1행이 나와요.",
                 [choice("A", "행마다 결과가 하나씩 나온다", rationale="행마다 결과가 나오는 것은 UPPER 같은 단일행 함수예요."),
                  choice("B", "여러 행의 값을 모아 결과 값 하나를 만든다", True, "집계 함수의 정의예요."),
                  choice("C", "SUM과 AVG는 문자 열에도 쓸 수 있다", rationale="SUM과 AVG는 숫자에만 쓸 수 있어요."),
                  choice("D", "GROUP BY 절이 없으면 쓸 수 없다", rationale="GROUP BY 없이 쓰면 테이블 전체를 한 묶음으로 계산해요.")]),
        question(2, "아래 사원 표에 다음 SQL을 실행한 결과로 알맞은 것은 무엇인가요?\n\n" + EMPLOYEE_COMMISSION_TABLE, "null",
                 "COUNT(*)는 모든 행을 세서 8이고, COUNT(커미션)은 커미션이 NULL인 네 명을 빼고 세서 4예요. 박서준의 0은 값이라서 세는 데 들어가요.",
                 [choice("A", "4, 4", rationale="COUNT(*)는 NULL과 상관없이 모든 행을 세요."),
                  choice("B", "8, 8", rationale="COUNT(커미션)은 커미션이 NULL인 행을 세지 않아요."),
                  choice("C", "8, 3", rationale="박서준의 커미션 0은 NULL이 아니라서 세는 데 들어가요."),
                  choice("D", "8, 4", True, "전체 행은 8개이고, 커미션이 있는 행은 4개예요.")],
                 stem_sql="SELECT COUNT(*), COUNT(커미션) FROM 사원;"),
        question(3, "사원 표의 커미션 합계는 1000이고, 커미션이 NULL인 사원은 4명이에요. 다음 SQL의 결과는 무엇인가요?", "confusing",
                 "AVG는 NULL인 행을 빼고 평균을 내므로 1000을 커미션이 있는 4명으로 나눠요. 그래서 결과는 250이에요.",
                 [choice("A", "250", True, "1000을 커미션이 있는 4명으로 나눈 값이에요."),
                  choice("B", "125", rationale="1000을 전체 8명으로 나눈 값인데, AVG는 NULL인 행을 분모에서 빼요."),
                  choice("C", "NULL", rationale="집계 함수는 NULL인 행을 건너뛸 뿐이라 결과가 NULL이 되지 않아요."),
                  choice("D", "1000", rationale="1000은 SUM(커미션)의 결과예요.")],
                 stem_sql="SELECT AVG(커미션) FROM 사원;"),
        question(4, "40번 부서에는 사원이 한 명도 없어요. 다음 SQL의 결과로 알맞은 것은 무엇인가요?", "confusing",
                 "GROUP BY가 없으면 맞는 행이 없어도 결과는 1행이에요. 셀 것이 없는 COUNT는 0을, 더할 값이 없는 SUM은 NULL을 돌려줘요.",
                 [choice("A", "결과가 0행이다", rationale="GROUP BY가 없으면 집계 결과는 항상 1행이에요."),
                  choice("B", "0, 0", rationale="SUM은 더할 값이 없으면 0이 아니라 NULL을 돌려줘요."),
                  choice("C", "0, NULL", True, "COUNT는 0, SUM은 NULL인 1행이 나와요."),
                  choice("D", "NULL, NULL", rationale="COUNT는 셀 행이 없으면 NULL이 아니라 0을 돌려줘요.")],
                 stem_sql="SELECT COUNT(*), SUM(급여) FROM 사원 WHERE 부서번호 = 40;"),
        question(5, "급여가 가장 많은 사원의 이름과 급여를 보려고 다음 SQL을 실행했어요. 결과는 어떻게 되나요?", "confusing",
                 "GROUP BY 없이 집계 함수와 일반 열을 함께 쓰면 ORA-00937(한 행으로 묶을 수 없는 그룹 함수) 오류가 나요. MAX(급여)는 한 값인데 이름은 여덟 값이라 한 행으로 만들 수 없어요.",
                 [choice("A", "최유나, 3200 한 행이 나온다", rationale="MAX(급여)는 그 값을 가진 행의 이름을 함께 찾아 주지 않아요."),
                  choice("B", "오류가 난다", True, "집계 함수와 일반 열을 GROUP BY 없이 함께 써서 결과를 한 행으로 만들 수 없어요."),
                  choice("C", "사원마다 이름과 3200이 한 행씩, 모두 8행 나온다", rationale="집계 결과를 행마다 붙여 주는 동작은 하지 않아요."),
                  choice("D", "이름은 NULL, 급여는 3200인 한 행이 나온다", rationale="이름을 NULL로 바꿔 주지 않고 오류를 내요.")],
                 stem_sql="SELECT 이름, MAX(급여) FROM 사원;"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 정의 (다섯 함수, 날짜 MAX·MIN, SUM 문자 열 오류)
        FIVE_FUNCTIONS_EXAMPLE.check,
        sql_check("SELECT COUNT(*), SUM(급여), AVG(급여), MAX(급여), MIN(급여) FROM 사원", [[8, 20900, 2612.5, 3200, 2000]]),
        sql_check("SELECT MAX(입사일), MIN(입사일) FROM 사원", [["2024-05-20", "2015-03-02"]]),
        sql_error_check("SELECT SUM(이름) FROM 사원", "ORA-01722"),
        # NULL 제외 (COUNT 두 형태, SUM·AVG)
        COUNT_EXAMPLE.check,
        # COUNT(커미션) 그림: 세는 4명
        sql_check("SELECT 이름 FROM 사원 WHERE 커미션 IS NOT NULL", [["이지은"], ["박서준"], ["한도윤"], ["오지민"]]),
        SUM_AVG_EXAMPLE.check,
        sql_check("SELECT COUNT(*), COUNT(커미션), COUNT(부서번호) FROM 사원", [[8, 4, 7]]),
        sql_check("SELECT SUM(커미션), AVG(커미션) FROM 사원", [[1000, 250]]),
        # 헷갈리는 점 (분모, NVL 위치, 행 계산 <-> 집계, DISTINCT, 빈 결과, 일반 열 오류)
        DENOMINATOR_EXAMPLE.check,
        ROW_SUM_EXAMPLE.check,
        DISTINCT_EXAMPLE.check,
        EMPTY_GROUP_EXAMPLE.check,
        sql_check("SELECT SUM(커미션) / COUNT(*), AVG(NVL(커미션, 0)), NVL(AVG(커미션), 0) FROM 사원", [[125, 125, 250]]),
        sql_check("SELECT SUM(급여 + 커미션), SUM(급여) + SUM(커미션) FROM 사원", [[11200, 21900]]),
        sql_check("SELECT COUNT(DISTINCT 부서번호), SUM(DISTINCT 급여) FROM 사원", [[3, 18400]]),
        sql_check("SELECT COUNT(*), SUM(급여), MAX(급여) FROM 사원 WHERE 부서번호 = 40", [[0, None, None]]),
        sql_check("SELECT NVL(SUM(급여), 0) FROM 사원 WHERE 부서번호 = 40", [[0]]),
        # 확인 문제 stemSql
        sql_check("SELECT COUNT(*), COUNT(커미션) FROM 사원;", [[8, 4]]),
        sql_check("SELECT AVG(커미션) FROM 사원;", [[250]]),
        sql_check("SELECT COUNT(*), SUM(급여) FROM 사원 WHERE 부서번호 = 40;", [[0, None]]),
        sql_error_check("SELECT 이름, MAX(급여) FROM 사원;", "ORA-00937"),
    ],
}
