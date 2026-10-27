"""개념: 집계 함수와 NULL (7단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import to_employee_table_md

EMPLOYEE_COMMISSION_TABLE = to_employee_table_md("사번", "이름", "입사일", "급여", "커미션", "부서번호")

CONCEPT = {
    "tagKey": "group-aggregate-null",
    "topicCode": "sql_group_aggregate",
    "sortOrder": 1,
    "title": "집계 함수와 NULL",
    "summary": "여러 행을 값 하나로 줄이는 함수이고, NULL인 행은 빼고 계산해요",
    "coreMd": (
        "- 집계 함수(COUNT, SUM, AVG, MAX, MIN)는 여러 행을 받아 값 하나를 돌려주고, 같은 값끼리 묶는 GROUP BY 절 없이 쓰면 결과는 늘 1행이에요.\n"
        "- `COUNT(*)`는 행 수를 그대로 세지만, `COUNT(열)`과 SUM, AVG, MAX, MIN은 그 열이 NULL인 행을 빼고 계산해요.\n"
        "- 그래서 `AVG(커미션)`은 커미션이 있는 네 명의 평균인 250이고, NULL을 다른 값으로 바꾸는 NVL 함수로 0을 넣은 `AVG(NVL(커미션, 0))`은 여덟 명의 평균인 125예요.\n"
        "- 조건에 맞는 행이 하나도 없으면 COUNT는 0을, SUM, AVG, MAX, MIN은 NULL을 돌려줘요.\n"
        "- GROUP BY 없이 집계 함수와 일반 열을 함께 SELECT 하면, 결과를 한 행으로 만들 수 없어서 ORA-00937(한 행으로 묶을 수 없는 그룹 함수) 오류가 나요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

"사원은 모두 몇 명인가요?", "급여를 다 더하면 얼마인가요?" 같은 질문에는 행을 하나씩 보여 주는 SELECT로 답하기 어려워요. 여덟 개의 행을 숫자 하나로 줄여 주는 도구가 필요한데, 그 도구가 집계 함수예요. 이 글의 예시는 모두 아래 사원 표로 설명해요.

{EMPLOYEE_COMMISSION_TABLE}

## 한 줄 정의 {{#definition}}

집계 함수는 여러 행의 값을 모아서 결과 값 하나를 만드는 함수이고, 시험에서는 그룹 함수(aggregate function)라고도 불러요. 이름의 글자 수를 세는 `LENGTH(이름)`처럼 행 하나를 받아 결과 하나를 돌려주는 함수를 단일행 함수라고 해요. 단일행 함수는 행마다 결과가 하나씩 나오지만, 집계 함수는 행이 몇 개든 결과가 하나로 줄어든다는 점이 달라요. 자주 쓰는 집계 함수는 다섯 개예요.

| 함수 | 하는 일 | 사원 표 급여에 쓴 결과 |
|---|---|---|
| COUNT | 개수를 세요 | `COUNT(*)` = 8 |
| SUM | 합계를 구해요 | 20900 |
| AVG | 평균을 구해요 | 2612.5 |
| MAX | 가장 큰 값을 골라요 | 3200 |
| MIN | 가장 작은 값을 골라요 | 2000 |

```sql
SELECT COUNT(*), SUM(급여), AVG(급여), MAX(급여), MIN(급여) FROM 사원;  -- 8, 20900, 2612.5, 3200, 2000이 나와요
SELECT MAX(입사일), MIN(입사일) FROM 사원;                               -- 2024-05-20, 2015-03-02가 나와요
```

SUM과 AVG는 숫자에만 쓸 수 있어서 `SUM(이름)`처럼 문자로 된 열을 넣으면 ORA-01722(숫자가 아닌 값) 오류가 나요. 반면에 MAX, MIN, COUNT는 문자와 날짜에도 쓸 수 있고, `MAX(입사일)`은 가장 늦게 입사한 날짜를 돌려줘요. 같은 값을 가진 행끼리 묶어 주는 GROUP BY 절은 다음 개념에서 배우는데, 이 절 없이 집계 함수를 쓰면 테이블 전체를 한 묶음으로 보기 때문에 결과는 언제나 1행이에요.

## NULL은 빼고 계산해요 {{#null}}

COUNT에는 두 가지 쓰는 법이 있어요. `COUNT(*)`는 행 자체를 세므로 어떤 칸이 NULL이든 상관없이 8을 돌려줘요. `COUNT(커미션)`처럼 괄호 안에 열을 적으면 그 열 값이 NULL이 아닌 행만 세요.

```sql
SELECT COUNT(*), COUNT(커미션), COUNT(부서번호) FROM 사원;  -- 8, 4, 7이 나와요
SELECT SUM(커미션), AVG(커미션) FROM 사원;                    -- 1000, 250이 나와요
```

커미션이 있는 사원은 이지은(300), 박서준(0), 한도윤(500), 오지민(200) 네 명이라서 `COUNT(커미션)`은 4예요. 박서준의 0은 값이 있는 것이므로 세는 데 들어가고, 커미션이 NULL인 김민수, 최유나, 정하늘, 윤서연은 빠져요. 같은 이유로 부서번호가 NULL인 윤서연이 빠져서 `COUNT(부서번호)`는 7이에요.

SUM, AVG, MAX, MIN도 NULL인 행을 건너뛰어요. 그래서 `SUM(커미션)`은 네 명의 커미션을 더한 1000이고, `AVG(커미션)`은 1000을 8이 아니라 4로 나눈 250이에요.

## 자주 헷갈리는 점 {{#confusing}}

**평균을 낼 때 나누는 수는 전체 행 수가 아니에요.** `AVG(커미션)`은 커미션 합계를 커미션이 있는 사원 수로 나누기 때문에 250이에요. 합계를 전체 사원 수로 나눈 `SUM(커미션) / COUNT(*)`는 1000을 8로 나눈 125라서 값이 달라요. 시험 보기에 두 값이 함께 나오면, AVG의 분모가 `COUNT(커미션)`이라는 점을 떠올리면 돼요.

**NVL을 어디에 넣느냐에 따라 평균이 달라져요.** NVL은 NULL을 지정한 값으로 바꿔 주는 함수이고, `NVL(커미션, 0)`은 커미션이 NULL이면 0을 돌려줘요. 집계 함수 안에 넣은 `AVG(NVL(커미션, 0))`은 NULL을 미리 0으로 바꾼 뒤 여덟 명 모두의 평균을 구하므로 125예요. 반대로 바깥에 넣은 `NVL(AVG(커미션), 0)`은 평균 결과가 NULL일 때만 0으로 바꾸므로 그대로 250이에요.

```sql
SELECT SUM(커미션) / COUNT(*), AVG(NVL(커미션, 0)), NVL(AVG(커미션), 0) FROM 사원;  -- 125, 125, 250이 나와요
```

**행 안의 계산과 집계는 NULL을 다르게 다뤄요.** `급여 + 커미션`처럼 한 행 안에서 계산할 때는 NULL이 하나라도 섞이면 결과가 NULL이 돼요. 하지만 집계 함수는 NULL을 만나면 그 행을 건너뛸 뿐이라서, 커미션 칸에 NULL이 넷이나 있어도 `SUM(커미션)`은 NULL이 아니라 1000이에요. 이 차이 때문에 `SUM(급여 + 커미션)`과 `SUM(급여) + SUM(커미션)`의 결과가 달라져요.

```sql
SELECT SUM(급여 + 커미션), SUM(급여) + SUM(커미션) FROM 사원;  -- 11200, 21900이 나와요
```

`SUM(급여 + 커미션)`은 먼저 행마다 더하는데, 커미션이 NULL인 네 명은 더한 값이 NULL이 되어 합계에서 빠져요. 그래서 남은 네 명의 값(2800, 2800, 3200, 2400)만 더한 11200이 나와요. `SUM(급여) + SUM(커미션)`은 급여 합계 20900과 커미션 합계 1000을 따로 구한 뒤 더하므로 21900이에요.

**DISTINCT를 넣으면 같은 값을 한 번만 계산해요.** 집계 함수 괄호 안에 DISTINCT를 쓰면 중복된 값을 하나로 줄인 뒤 집계해요. `COUNT(DISTINCT 부서번호)`는 10, 20, 30 세 가지 값만 세므로 3이고, 이때도 NULL은 세지 않아요. `SUM(DISTINCT 급여)`는 2500이 두 번 나와도 한 번만 더하므로 전체 합계 20900보다 2500 적은 18400이에요.

```sql
SELECT COUNT(DISTINCT 부서번호), SUM(DISTINCT 급여) FROM 사원;  -- 3, 18400이 나와요
```

**조건에 맞는 행이 없어도 결과는 1행이에요.** 40번 부서에는 사원이 없어서 `WHERE 부서번호 = 40`에 맞는 행이 하나도 없어요. 그래도 GROUP BY가 없으면 결과는 1행으로 나오고, COUNT는 0을, SUM과 MAX는 NULL을 돌려줘요. 셀 것이 없으면 개수는 0이지만, 더하거나 고를 값이 없으면 결과 자체를 알 수 없기 때문이에요. 합계를 0으로 보이고 싶다면 `NVL(SUM(급여), 0)`처럼 바깥에서 NVL로 감싸요.

```sql
SELECT COUNT(*), SUM(급여), MAX(급여) FROM 사원 WHERE 부서번호 = 40;  -- 0, NULL, NULL이 나와요
```

**집계 함수와 일반 열은 그대로 함께 쓸 수 없어요.** 급여가 가장 많은 사람의 이름을 보려고 `SELECT 이름, MAX(급여) FROM 사원`이라고 쓰면 ORA-00937(한 행으로 묶을 수 없는 그룹 함수) 오류가 나요. `MAX(급여)`는 값이 하나뿐인데 이름은 여덟 개라서, 결과를 한 행으로 만들 수 없기 때문이에요. 일반 열을 함께 보려면 다음 개념인 GROUP BY로 그 열을 묶어 주거나, 서브쿼리로 최댓값을 따로 구해서 비교해야 해요. 서브쿼리는 쿼리 안에 넣은 또 다른 쿼리이고, 6단원에서 자세히 다뤄요.

```sql
-- 오류: 이름은 여러 값인데 MAX(급여)는 한 값이에요 (ORA-00937, 한 행으로 묶을 수 없는 그룹 함수)
SELECT 이름, MAX(급여) FROM 사원;
```

## 시험에서는 이렇게 나와요 {{#exam-point}}

표를 주고 `COUNT(*)`, `COUNT(열)`, `AVG(열)`의 결과를 묻는 문제가 가장 많아요. 이때는 그 열에서 NULL인 행에 먼저 표시해 두고, COUNT와 AVG의 분모에서 그 행을 빼면 실수가 줄어요. 0은 값이라서 세는 데 들어간다는 점도 자주 노리는 함정이에요. 그 밖에 `SUM(A + B)`와 `SUM(A) + SUM(B)`의 차이, 조건에 맞는 행이 없을 때의 결과, 일반 열과 집계 함수를 함께 쓴 SQL이 오류인지 묻는 문제가 나와요.""",
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
        sql_check("SELECT COUNT(*), SUM(급여), AVG(급여), MAX(급여), MIN(급여) FROM 사원", [[8, 20900, 2612.5, 3200, 2000]]),
        sql_check("SELECT MAX(입사일), MIN(입사일) FROM 사원", [["2024-05-20", "2015-03-02"]]),
        sql_error_check("SELECT SUM(이름) FROM 사원", "ORA-01722"),
        # NULL 제외 (COUNT 두 형태, SUM·AVG)
        sql_check("SELECT COUNT(*), COUNT(커미션), COUNT(부서번호) FROM 사원", [[8, 4, 7]]),
        sql_check("SELECT SUM(커미션), AVG(커미션) FROM 사원", [[1000, 250]]),
        # 헷갈리는 점 (분모, NVL 위치, 행 계산 <-> 집계, DISTINCT, 빈 결과, 일반 열 오류)
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
