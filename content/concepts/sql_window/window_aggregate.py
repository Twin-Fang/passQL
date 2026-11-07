"""개념: 집계 윈도우 함수 (8단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

# 계산에 쓰는 원본 열 (이 개념의 예시는 모두 이 표로 계산)
EMPLOYEE_BASE_TABLE = to_employee_table_md("사번", "이름", "입사일", "급여", "커미션", "부서번호")

SALES_DEPARTMENT_TABLE = to_employee_table_md("이름", "입사일", "급여", employee_numbers=(1004, 1006, 1007))
EMPLOYEE_COMMISSION_TABLE = to_employee_table_md("이름", "커미션")

# 본문 예시 SQL > 결과 행 (본문 표와 sqlChecks 가 같은 원본을 씀)
PARTITION_AVERAGE_SQL = """SELECT 이름, 부서번호, 급여,
       AVG(급여) OVER (PARTITION BY 부서번호) AS 부서평균,
       급여 - AVG(급여) OVER (PARTITION BY 부서번호) AS 차이
FROM 사원
ORDER BY 부서번호, 사번;"""
PARTITION_AVERAGE_ROWS = [
    ["김민수", 10, 3000, 3000, 0], ["이지은", 20, 2500, 2600, -100], ["박서준", 20, 2800, 2600, 200],
    ["정하늘", 20, 2500, 2600, -100], ["최유나", 30, 3200, 2700, 500], ["한도윤", 30, 2700, 2700, 0],
    ["오지민", 30, 2200, 2700, -500], ["윤서연", None, 2000, 2000, 0],
]

RUNNING_TOTAL_SQL = """SELECT 부서번호, 이름, 입사일, 급여,
       SUM(급여) OVER (PARTITION BY 부서번호 ORDER BY 입사일) AS 누적
FROM 사원
WHERE 부서번호 IN (20, 30)
ORDER BY 부서번호, 입사일;"""
RUNNING_TOTAL_ROWS = [
    [20, "이지은", "2018-07-16", 2500, 2500], [20, "박서준", "2020-01-06", 2800, 5300],
    [20, "정하늘", "2022-03-14", 2500, 7800], [30, "최유나", "2016-11-21", 3200, 3200],
    [30, "한도윤", "2019-09-02", 2700, 5900], [30, "오지민", "2023-02-01", 2200, 8100],
]

# 개발부 급여 2500 동점 2명: ROWS 는 한 줄씩(사번으로 동점 순서 고정), RANGE 는 같은 값을 한꺼번에
ROWS_RANGE_SQL = """SELECT 이름, 급여,
       SUM(급여) OVER (ORDER BY 급여, 사번
                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 행기준,
       SUM(급여) OVER (ORDER BY 급여
                       RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 값기준
FROM 사원
WHERE 부서번호 = 20
ORDER BY 급여, 사번;"""
ROWS_RANGE_ROWS = [["이지은", 2500, 2500, 5000], ["정하늘", 2500, 5000, 5000], ["박서준", 2800, 7800, 7800]]

RANGE_VALUE_SQL = """SELECT 이름, 급여,
       COUNT(*) OVER (ORDER BY 급여
                      RANGE BETWEEN 200 PRECEDING AND 200 FOLLOWING) AS 비슷한급여
FROM 사원
ORDER BY 급여, 사번;"""
RANGE_VALUE_ROWS = [
    ["윤서연", 2000, 2], ["오지민", 2200, 2], ["이지은", 2500, 3], ["정하늘", 2500, 3],
    ["한도윤", 2700, 4], ["박서준", 2800, 3], ["김민수", 3000, 3], ["최유나", 3200, 2],
]

MOVING_AVERAGE_SQL = """SELECT 이름, 입사일, 급여,
       ROUND(AVG(급여) OVER (ORDER BY 입사일
                             ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)) AS 이동평균
FROM 사원
ORDER BY 입사일;"""
MOVING_AVERAGE_ROWS = [
    ["김민수", "2015-03-02", 3000, 3100], ["최유나", "2016-11-21", 3200, 2900], ["이지은", "2018-07-16", 2500, 2800],
    ["한도윤", "2019-09-02", 2700, 2667], ["박서준", "2020-01-06", 2800, 2667], ["정하늘", "2022-03-14", 2500, 2500],
    ["오지민", "2023-02-01", 2200, 2233], ["윤서연", "2024-05-20", 2000, 2100],
]

NULL_AGGREGATE_SQL = """SELECT DISTINCT COUNT(*) OVER () AS 전체행,
       COUNT(커미션) OVER () AS 커미션인원,
       SUM(커미션) OVER () AS 커미션합계,
       AVG(커미션) OVER () AS 커미션평균
FROM 사원;"""
NULL_AGGREGATE_ROWS = [[8, 4, 1000, 250]]

# 확인 문제 stemSql
RUNNING_STEM_SQL = "SELECT 이름, SUM(급여) OVER (ORDER BY 입사일) AS 누적 FROM 사원 WHERE 부서번호 = 30;"
ROWS_STEM_SQL = ("SELECT 이름, SUM(급여) OVER (ORDER BY 급여, 사번 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 누적 "
                 "FROM 사원 WHERE 부서번호 = 20;")
COUNT_STEM_SQL = "SELECT 이름, COUNT(커미션) OVER () AS 커미션인원 FROM 사원;"

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
PARTITION_AVERAGE_EXAMPLE = sql_example(PARTITION_AVERAGE_SQL, ("이름", "부서번호", "급여", "부서평균", "차이"), PARTITION_AVERAGE_ROWS)
RUNNING_TOTAL_EXAMPLE = sql_example(RUNNING_TOTAL_SQL, ("부서번호", "이름", "입사일", "급여", "누적"), RUNNING_TOTAL_ROWS)
ROWS_RANGE_EXAMPLE = sql_example(ROWS_RANGE_SQL, ("이름", "급여", "행기준", "값기준"), ROWS_RANGE_ROWS)
RANGE_VALUE_EXAMPLE = sql_example(RANGE_VALUE_SQL, ("이름", "급여", "비슷한급여"), RANGE_VALUE_ROWS)
MOVING_AVERAGE_EXAMPLE = sql_example(MOVING_AVERAGE_SQL, ("이름", "입사일", "급여", "이동평균"), MOVING_AVERAGE_ROWS)
NULL_AGGREGATE_EXAMPLE = sql_example(NULL_AGGREGATE_SQL, ("전체행", "커미션인원", "커미션합계", "커미션평균"), NULL_AGGREGATE_ROWS, is_ordered=False)

CONCEPT = {
    "tagKey": "window-aggregate",
    "topicCode": "sql_window",
    "sortOrder": 3,
    "title": "집계 윈도우 함수",
    "summary": "SUM, AVG 같은 집계 함수에 OVER를 붙여 합계, 누적, 이동 평균을 구해요",
    "coreMd": (
        "- SUM, AVG, COUNT, MAX, MIN 뒤에 OVER를 붙이면, 행을 줄이지 않고 각 행에 집계값을 붙여요.\n"
        "- OVER 안에 PARTITION BY만 쓰면 묶음 전체 값이, ORDER BY까지 쓰면 첫 행부터 현재 행까지의 **누적값**이 나와요.\n"
        "- ROWS는 행을 한 줄씩 세고, RANGE는 ORDER BY 값이 같은 행을 한꺼번에 넣어요. 기본은 **RANGE**라서 동점 행의 누적값이 같아요.\n"
        "- `ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING`처럼 앞뒤 행만 넣으면 이동 평균을 구해요.\n"
        "- **NULL**은 일반 집계처럼 빠지고, `COUNT(*)`만 NULL이 있는 행까지 세요."
    ),
    "detailMd": f"""## 한 사람 값과 집계값을 한 줄에: 왜 필요할까요 {{#why}}

"각 사원의 급여가 부서 평균보다 얼마나 높은가" 같은 질문은 사원 한 명의 값과 여러 사원의 집계값을 한 줄에 놓아야 답할 수 있어요. GROUP BY로 집계하면 사원 한 명 한 명의 행이 사라지고, 서브쿼리로 집계값을 다시 붙이면 SQL이 길어져요.

집계 함수에 OVER를 붙이면 이 일을 한 번에 할 수 있어요. 아래는 합계와 평균을 구할 사원 여덟 명이고, 부서번호 20은 개발부, 30은 영업부, 커미션이 NULL인 사원은 네 명이에요.

{EMPLOYEE_BASE_TABLE}

## 한 줄 정의: OVER 안에 무엇을 썼는지가 범위를 정해요 {{#definition}}

| 용어 | 뜻 |
|---|---|
| 집계 윈도우 함수 | SUM, AVG, COUNT, MAX, MIN 뒤에 OVER를 붙여, 윈도우 범위 안의 행으로 집계한 값을 각 행에 붙이는 함수예요 |
| NULL 처리 | 일반 집계 함수와 같아요. NULL은 계산에서 빠지고, COUNT(*)만 NULL이 있는 행까지 세요 |

일반 집계와 다른 점은 행을 줄이지 않는다는 것과, OVER 안의 내용에 따라 계산 범위가 바뀐다는 것이에요.

| OVER 안에 쓴 것 | 계산 범위 | SUM의 결과 |
|---|---|---|
| 비어 있음 | WHERE를 통과한 행 전체 | 전체 합 |
| PARTITION BY만 | 같은 묶음의 모든 행 | 묶음 합 |
| ORDER BY까지 | 묶음의 첫 행~현재 행 (RANGE) | 누적 합 |
| ROWS, RANGE 윈도우 절 | 적은 범위 그대로 | 범위 합, 이동 합 |

## 묶음 전체로 집계하기: 부서 평균과의 차이 {{#partition}}

PARTITION BY만 쓰면 같은 묶음의 모든 행이 계산 범위가 돼요. 윈도우 함수의 결과는 일반 열처럼 계산식에 쓸 수 있어서, 부서 평균과의 차이를 바로 구할 수 있어요.

{PARTITION_AVERAGE_EXAMPLE.markdown}

개발부 평균은 (2500 + 2800 + 2500) / 3 = 2600이라서, 박서준은 평균보다 200 높고 이지은과 정하늘은 100 낮아요. MAX, MIN, COUNT도 같은 방식으로 쓰면 부서 최고 급여, 최저 급여, 인원이 각 행에 붙어요.

## 누적 합: ORDER BY를 넣으면 쌓여요 {{#running-total}}

OVER 안에 ORDER BY를 더하면 계산 범위가 묶음의 첫 행부터 현재 행까지로 바뀌어서, 같은 SUM이 누적 합을 돌려줘요. 아래는 개발부와 영업부의 급여를 입사일 순서로 쌓은 결과예요.

{RUNNING_TOTAL_EXAMPLE.markdown}

| 단계 | 내용 |
|---|---|
| 묶기 | PARTITION BY 부서번호로 개발부와 영업부를 따로 나눠요 |
| 줄 세우기 | 묶음 안에서 입사일 순서로 놓아요 |
| 쌓기 | 첫 행부터 현재 행까지 더해요. 박서준은 이지은 2500 + 자기 2800 = 5300이에요 |
| 다시 시작 | 부서번호가 30으로 바뀌는 최유나 행에서 누적이 처음부터 다시 시작돼요 |

## ROWS와 RANGE: 동점 행에서 갈려요 {{#rows-range}}

| 비교 | ROWS | RANGE |
|---|---|---|
| 범위를 세는 기준 | 행을 한 줄씩 | ORDER BY 열의 값 |
| CURRENT ROW의 뜻 | 현재 행 하나 | 현재 행과 ORDER BY 값이 같은 행 전부 |
| 숫자를 쓰면 (2 PRECEDING) | 두 행 앞까지 | 값이 2 작은 행까지 |
| 윈도우 절을 생략하면 | 쓰이지 않음 | 기본으로 쓰임 |

개발부의 이지은과 정하늘은 급여가 2500으로 같아서 차이를 보기 좋아요.

{ROWS_RANGE_EXAMPLE.markdown}

ROWS는 이지은 행에서 한 명, 정하늘 행에서 두 명을 더해 2500과 5000이 나와요. RANGE는 값이 같은 두 사람을 한꺼번에 넣어서 둘 다 **5000**을 받아요.

행기준 쪽에 `사번`을 두 번째 정렬 기준으로 넣은 것은 동점끼리 순서를 고정하기 위해서예요. 사번을 빼도 한 명은 2500, 다른 한 명은 5000인 것은 같지만, 누가 어느 값을 받을지는 정해지지 않아요.

RANGE에 숫자를 쓰면 행 개수가 아니라 값의 차이를 뜻해요. 아래 `RANGE BETWEEN 200 PRECEDING AND 200 FOLLOWING`은 현재 급여보다 200 작은 값부터 200 큰 값까지를 범위로 잡아요.

{RANGE_VALUE_EXAMPLE.markdown}

한도윤(2700)의 범위는 2500부터 2900까지라서 이지은, 정하늘, 한도윤, 박서준 네 명이 들어가요. 같은 자리에 ROWS를 썼다면 앞뒤로 200개의 행을 뜻해요.

## 이동 평균: 앞뒤 몇 행만 보고 평균 내기 {{#moving-average}}

| 용어 | 뜻 |
|---|---|
| 이동 평균 | 현재 행과 그 주변 몇 행만 골라 낸 평균이에요. 범위가 행마다 한 칸씩 옮겨 가서 붙은 이름이고, 값이 들쭉날쭉할 때 흐름을 보는 데 써요 |
| ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING | 바로 앞 행, 현재 행, 바로 뒤 행 세 개가 범위예요 |

{MOVING_AVERAGE_EXAMPLE.markdown}

최유나의 이동평균 2900은 김민수, 최유나, 이지은 세 사람의 급여 평균이에요. 첫 행인 김민수는 앞 행이 없어서 두 사람의 평균 3100이 나오고, 마지막 행인 윤서연도 같은 이유로 두 사람의 평균이 나와요.

평균이 2666.66...처럼 길게 나와서, 반올림 함수 ROUND로 정수로 만들었어요.

## 자주 헷갈리는 점 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| OVER 안에 ORDER BY를 넣어도 SUM은 묶음 전체 합이에요 | 윈도우 절을 적지 않아도 RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW가 범위가 되어 누적 합이 나와요. 전체 합이 필요하면 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING을 적어요 |
| 동점인 두 행의 누적 합은 서로 달라요 | 윈도우 절을 적지 않았다면 기본이 RANGE라서 두 행의 누적값은 같아요. 달라지는 것은 ROWS를 직접 적었을 때예요 |
| RANGE 2 PRECEDING은 두 행 앞까지예요 | RANGE의 숫자는 값의 차이예요. 그래서 급여나 입사일처럼 숫자, 날짜 열 하나로만 정렬할 때 써요 |
| 앞뒤 한 행씩 넣는 이동 평균은 늘 세 행으로 나눠요 | 첫 행과 마지막 행에서는 범위가 짧아져서 두 행의 평균이 나와요. 없는 행을 0으로 채우지 않아요 |
| AVG(커미션) OVER ()는 커미션 합을 8명으로 나눠요 | NULL은 빠지므로 커미션이 있는 네 명의 합 1000을 4로 나눠 250이에요. 125가 아니에요 |
| OVER ()는 테이블 전체 행을 봐요 | 윈도우 함수는 WHERE가 끝난 뒤에 계산돼서, WHERE를 통과한 행 전체만 봐요 |

커미션이 NULL인 사원이 네 명이라서, `COUNT(*)`는 8이지만 `COUNT(커미션)`은 4예요. 모든 행에 같은 값이 붙기 때문에, DISTINCT(같은 행을 하나만 남기는 키워드)로 한 행만 남겼어요.

{NULL_AGGREGATE_EXAMPLE.markdown}

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| WHERE 부서번호 IN (20, 30)을 쓰면 SUM(급여) OVER ()는 여섯 명의 합이에요 | O | WHERE가 먼저 행을 거른 뒤 남은 행으로 집계해요 |
| ORDER BY 급여에서 ROWS 2 PRECEDING은 급여가 2 작은 행까지예요 | X | ROWS의 숫자는 행 개수라서 두 행 앞까지예요 |
| MAX(급여) OVER (PARTITION BY 부서번호)는 부서마다 최고 급여 한 행만 남겨요 | X | 행은 줄지 않고, 부서의 모든 행에 최고 급여가 붙어요 |

## 꼭 외울 것: 전체 합, 누적 합, 이동 합 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| `OVER ()` | WHERE를 통과한 행 전체로 집계 |
| PARTITION BY만 | 같은 묶음 전체로 집계 |
| ORDER BY까지 | 첫 행~현재 행 누적값 (RANGE) |
| 기본 범위에서 동점 행 | 누적값이 같아요 |
| `RANGE 2 PRECEDING`의 2 | 값의 차이 (ROWS라면 행 개수) |
| 앞뒤 한 행 이동 평균 | ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING |
| 첫 행, 끝 행의 이동 평균 | 범위가 짧아져 두 행으로 나눠요 |
| `AVG(커미션) OVER ()` | 250 (NULL 행은 분모에서 빠짐) |

## 시험에서는 이렇게 나와요 {{#exam-point}}

결과 표를 주고 빈칸이나 틀린 값을 찾는 문제가 가장 많아요. 아래 순서로 보면 대부분 풀려요.

| 단계 | 내용 |
|---|---|
| ORDER BY 확인 | OVER 안에 없으면 묶음 전체, 있으면 누적이에요 |
| 윈도우 절 확인 | ROWS면 한 줄씩, RANGE나 생략이면 값 기준이에요 |
| 동점 확인 | RANGE에서는 동점 행끼리 같은 값을 받아요 |
| NULL 확인 | COUNT(열)과 AVG는 NULL을 빼고 계산해요 |

그 밖에 이동 평균이나 "앞뒤 한 행"에 맞는 윈도우 절을 고르는 문제도 나와요.""",
    "checkQuestions": [
        question(1, "`SUM(급여) OVER (PARTITION BY 부서번호)`의 결과에 대한 설명으로 옳은 것은 무엇인가요?", "partition",
                 "PARTITION BY만 쓰면 같은 부서의 모든 행이 계산 범위가 돼요. 행은 줄지 않고, 각 행에 자기 부서의 급여 합계가 붙어요.",
                 [choice("A", "각 행에 그 행이 속한 부서의 급여 합계가 붙는다", True, "묶음 전체가 계산 범위예요."),
                  choice("B", "부서마다 한 행씩 급여 합계가 나온다", rationale="묶음마다 한 행이 남는 것은 GROUP BY예요."),
                  choice("C", "부서 안에서 첫 행부터 현재 행까지의 누적 합이 붙는다", rationale="누적 합은 OVER 안에 ORDER BY가 있어야 나와요."),
                  choice("D", "모든 행에 회사 전체 급여 합계가 붙는다", rationale="PARTITION BY 부서번호가 있어서 부서별로 따로 더해요.")]),
        question(2, "아래 영업부(30번) 사원 표에 다음 SQL을 실행하면 한도윤 행의 누적 값은 얼마인가요?\n\n" + SALES_DEPARTMENT_TABLE, "running-total",
                 "입사일 순서는 최유나, 한도윤, 오지민이에요. 한도윤 행은 최유나 3200과 자기 급여 2700을 더해 5900이에요.",
                 [choice("A", "2700", rationale="누적 합이라서 앞서 입사한 최유나의 급여도 더해요."),
                  choice("B", "8100", rationale="8100은 오지민까지 더한 값이고, 마지막 행인 오지민의 누적이에요."),
                  choice("C", "5900", True, "최유나 3200과 한도윤 2700을 더한 값이에요."),
                  choice("D", "4900", rationale="급여 순서가 아니라 입사일 순서로 쌓으므로 오지민의 급여는 아직 들어가지 않아요.")],
                 stem_sql=RUNNING_STEM_SQL),
        question(3, "20번 부서 사원은 이지은(사번 1002, 급여 2500), 박서준(1003, 2800), 정하늘(1005, 2500) 세 명이에요. 다음 SQL의 결과로 옳은 것은 무엇인가요?", "rows-range",
                 "ROWS는 행을 한 줄씩 세므로 동점이어도 누적값이 달라요. 급여와 사번 순서로 이지은, 정하늘, 박서준이 되어 2500, 5000, 7800이 나와요.",
                 [choice("A", "이지은 5000, 정하늘 5000, 박서준 7800", rationale="값이 같은 행을 한꺼번에 더하는 RANGE의 결과예요."),
                  choice("B", "이지은 2500, 정하늘 5000, 박서준 7800", True, "ROWS는 한 줄씩 더해요."),
                  choice("C", "세 사람 모두 7800", rationale="범위가 현재 행까지라서 부서 전체 합이 붙지 않아요."),
                  choice("D", "이지은 2500, 정하늘 2500, 박서준 2800", rationale="UNBOUNDED PRECEDING부터 더하므로 앞 행의 급여도 들어가요.")],
                 stem_sql=ROWS_STEM_SQL),
        question(4, "입사일 순서로 정렬했을 때 바로 앞 사원, 현재 사원, 바로 뒤 사원 세 명의 급여 평균을 구하려고 해요. `AVG(급여) OVER (ORDER BY 입사일 ...)`의 빈칸에 알맞은 윈도우 절은 무엇인가요?", "moving-average",
                 "앞뒤 한 행씩은 행 개수로 세야 하므로 ROWS를 써요. 1 PRECEDING이 바로 앞 행, 1 FOLLOWING이 바로 뒤 행이에요.",
                 [choice("A", "RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING", rationale="RANGE의 1은 행이 아니라 값 차이 1이라서, 입사일 기준으로 앞뒤 하루 안에 있는 행만 들어가요."),
                  choice("B", "ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW", rationale="첫 행부터 현재 행까지의 누적 평균이에요."),
                  choice("C", "ROWS BETWEEN 1 PRECEDING AND CURRENT ROW", rationale="바로 뒤 행이 빠져서 두 행의 평균이에요."),
                  choice("D", "ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING", True, "앞 행, 현재 행, 뒤 행 세 개가 범위예요.")]),
        question(5, "아래 사원 표에 다음 SQL을 실행하면 김민수 행의 커미션인원 값은 얼마인가요?\n\n" + EMPLOYEE_COMMISSION_TABLE, "confusing",
                 "COUNT(커미션)은 NULL을 세지 않아서 커미션이 있는 네 명(300, 0, 500, 200)만 세요. OVER ()라서 모든 행에 같은 값 4가 붙어요.",
                 [choice("A", "8", rationale="NULL까지 세는 것은 COUNT(*)이고, COUNT(커미션)은 NULL을 빼요."),
                  choice("B", "0", rationale="OVER ()는 김민수 한 행이 아니라 전체 행을 보고 세요."),
                  choice("C", "4", True, "커미션이 NULL이 아닌 네 명을 세요."),
                  choice("D", "NULL", rationale="COUNT는 NULL을 돌려주지 않고 개수를 돌려줘요.")],
                 stem_sql=COUNT_STEM_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 결과 표
        PARTITION_AVERAGE_EXAMPLE.check,
        RUNNING_TOTAL_EXAMPLE.check,
        ROWS_RANGE_EXAMPLE.check,
        RANGE_VALUE_EXAMPLE.check,
        MOVING_AVERAGE_EXAMPLE.check,
        NULL_AGGREGATE_EXAMPLE.check,
        # 본문 설명: MAX, MIN, COUNT 부서별, 사번을 빼도 ROWS 누적값 묶음은 2500, 5000, 7800, ORDER BY 후 전체 범위
        sql_check("SELECT 이름, MAX(급여) OVER (PARTITION BY 부서번호), MIN(급여) OVER (PARTITION BY 부서번호), "
                  "COUNT(*) OVER (PARTITION BY 부서번호) FROM 사원 WHERE 부서번호 = 20",
                  [["이지은", 2800, 2500, 3], ["박서준", 2800, 2500, 3], ["정하늘", 2800, 2500, 3]]),
        sql_check("SELECT 누적 FROM (SELECT SUM(급여) OVER (ORDER BY 급여 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 누적 "
                  "FROM 사원 WHERE 부서번호 = 20) ORDER BY 누적",
                  [[2500], [5000], [7800]], is_ordered=True),
        sql_check("SELECT 이름, SUM(급여) OVER (ORDER BY 입사일 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "
                  "FROM 사원 WHERE 부서번호 = 30",
                  [["최유나", 8100], ["한도윤", 8100], ["오지민", 8100]]),
        sql_error_check("SELECT 이름, COUNT(*) OVER (ORDER BY 급여, 사번 RANGE 1 PRECEDING) FROM 사원", "ORA-30486"),
        sql_error_check("SELECT 이름, COUNT(*) OVER (ORDER BY 이름 RANGE 1 PRECEDING) FROM 사원", "ORA-00902"),
        # 본문 바로 확인: WHERE 로 거른 6명만 OVER () 범위
        sql_check("SELECT DISTINCT SUM(급여) OVER () FROM 사원 WHERE 부서번호 IN (20, 30)", [[15900]]),
        # 확인 문제 2, 3, 5번 stemSql
        sql_check(RUNNING_STEM_SQL, [["최유나", 3200], ["한도윤", 5900], ["오지민", 8100]]),
        sql_check(ROWS_STEM_SQL, [["이지은", 2500], ["정하늘", 5000], ["박서준", 7800]]),
        sql_check(COUNT_STEM_SQL, [[name, 4] for name in ("김민수", "이지은", "박서준", "최유나", "정하늘", "한도윤", "오지민", "윤서연")]),
        # 확인 문제 2번 오답 4900 (급여 순 앞 1행), 4번 보기 (영업부 3명)
        sql_check("SELECT 이름, SUM(급여) OVER (ORDER BY 급여 ROWS 1 PRECEDING) FROM 사원 WHERE 부서번호 = 30",
                  [["오지민", 2200], ["한도윤", 4900], ["최유나", 5900]]),
        sql_check("SELECT 이름, AVG(급여) OVER (ORDER BY 입사일 ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) FROM 사원 WHERE 부서번호 = 30",
                  [["최유나", 2950], ["한도윤", 2700], ["오지민", 2450]]),
        sql_check("SELECT 이름, AVG(급여) OVER (ORDER BY 입사일 RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING) FROM 사원 WHERE 부서번호 = 30",
                  [["최유나", 3200], ["한도윤", 2700], ["오지민", 2200]]),
        sql_check("SELECT 이름, AVG(급여) OVER (ORDER BY 입사일 ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) FROM 사원 WHERE 부서번호 = 30",
                  [["최유나", 3200], ["한도윤", 2950], ["오지민", 2450]]),
    ],
}
