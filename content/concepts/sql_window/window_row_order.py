"""개념: 행 순서 함수 (8단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

# 계산에 쓰는 원본 열 (이 개념의 예시는 모두 이 표로 계산)
EMPLOYEE_BASE_TABLE = to_employee_table_md("사번", "이름", "입사일", "급여", "커미션", "부서번호")

SALES_DEPARTMENT_TABLE = to_employee_table_md("이름", "입사일", "급여", employee_numbers=(1004, 1006, 1007))

# 본문 예시 SQL > 결과 행 (본문 표와 sqlChecks 가 같은 원본을 씀)
FIRST_LAST_SQL = """SELECT 이름, 급여,
       FIRST_VALUE(이름) OVER (ORDER BY 급여 DESC) AS 첫값,
       LAST_VALUE(이름) OVER (ORDER BY 급여 DESC) AS 끝값기본,
       LAST_VALUE(이름) OVER (ORDER BY 급여 DESC
                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 끝값전체
FROM 사원
WHERE 부서번호 = 30
ORDER BY 급여 DESC;"""
FIRST_LAST_ROWS = [
    ["최유나", 3200, "최유나", "최유나", "오지민"], ["한도윤", 2700, "최유나", "한도윤", "오지민"],
    ["오지민", 2200, "최유나", "오지민", "오지민"],
]

LAG_LEAD_SMALL_SQL = """SELECT 이름, 입사일,
       LAG(이름) OVER (ORDER BY 입사일) AS 앞사람,
       LEAD(이름) OVER (ORDER BY 입사일) AS 뒷사람
FROM 사원
WHERE 부서번호 = 30
ORDER BY 입사일;"""
LAG_LEAD_SMALL_ROWS = [
    ["최유나", "2016-11-21", None, "한도윤"], ["한도윤", "2019-09-02", "최유나", "오지민"],
    ["오지민", "2023-02-01", "한도윤", None],
]

LAG_DIFFERENCE_SQL = """SELECT 이름, 입사일, 급여,
       LAG(급여) OVER (ORDER BY 입사일) AS 앞사람급여,
       급여 - LAG(급여) OVER (ORDER BY 입사일) AS 차이
FROM 사원
ORDER BY 입사일;"""
LAG_DIFFERENCE_ROWS = [
    ["김민수", "2015-03-02", 3000, None, None], ["최유나", "2016-11-21", 3200, 3000, 200],
    ["이지은", "2018-07-16", 2500, 3200, -700], ["한도윤", "2019-09-02", 2700, 2500, 200],
    ["박서준", "2020-01-06", 2800, 2700, 100], ["정하늘", "2022-03-14", 2500, 2800, -300],
    ["오지민", "2023-02-01", 2200, 2500, -300], ["윤서연", "2024-05-20", 2000, 2200, -200],
]

# 두 번째 인자(칸 수) · 세 번째 인자(없을 때 기본값)
LAG_ARGUMENT_SQL = """SELECT 이름,
       LAG(급여, 2) OVER (ORDER BY 입사일) AS 두칸앞,
       LAG(급여, 1, 0) OVER (ORDER BY 입사일) AS 기본값0
FROM 사원
WHERE 사번 IN (1001, 1004, 1002)
ORDER BY 입사일;"""
LAG_ARGUMENT_ROWS = [["김민수", None, 0], ["최유나", None, 3000], ["이지은", 3000, 3200]]

IGNORE_NULLS_SQL = """SELECT 이름, 커미션,
       LAG(커미션) OVER (ORDER BY 입사일) AS 앞커미션,
       LAG(커미션) IGNORE NULLS OVER (ORDER BY 입사일) AS 널건너뜀
FROM 사원
ORDER BY 입사일;"""
IGNORE_NULLS_ROWS = [
    ["김민수", None, None, None], ["최유나", None, None, None], ["이지은", 300, None, None],
    ["한도윤", 500, 300, 300], ["박서준", 0, 500, 500], ["정하늘", None, 0, 0],
    ["오지민", 200, None, 0], ["윤서연", None, 200, 200],
]

# 확인 문제 stemSql
LEAD_STEM_SQL = "SELECT 이름, LEAD(급여) OVER (ORDER BY 입사일) AS 다음급여 FROM 사원 WHERE 부서번호 = 30;"
LAST_VALUE_STEM_SQL = "SELECT 이름, LAST_VALUE(이름) OVER (ORDER BY 입사일) AS 마지막 FROM 사원 WHERE 부서번호 = 30;"
LAG_DEFAULT_STEM_SQL = "SELECT 이름, LAG(급여, 2, 0) OVER (ORDER BY 입사일) AS 값 FROM 사원 WHERE 부서번호 = 30;"

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
FIRST_LAST_EXAMPLE = sql_example(FIRST_LAST_SQL, ("이름", "급여", "첫값", "끝값기본", "끝값전체"), FIRST_LAST_ROWS)
LAG_LEAD_SMALL_EXAMPLE = sql_example(LAG_LEAD_SMALL_SQL, ("이름", "입사일", "앞사람", "뒷사람"), LAG_LEAD_SMALL_ROWS)
LAG_DIFFERENCE_EXAMPLE = sql_example(LAG_DIFFERENCE_SQL, ("이름", "입사일", "급여", "앞사람급여", "차이"), LAG_DIFFERENCE_ROWS)
LAG_ARGUMENT_EXAMPLE = sql_example(LAG_ARGUMENT_SQL, ("이름", "두칸앞", "기본값0"), LAG_ARGUMENT_ROWS)
IGNORE_NULLS_EXAMPLE = sql_example(IGNORE_NULLS_SQL, ("이름", "커미션", "앞커미션", "널건너뜀"), IGNORE_NULLS_ROWS)

CONCEPT = {
    "tagKey": "window-row-order",
    "topicCode": "sql_window",
    "sortOrder": 4,
    "title": "행 순서 함수",
    "summary": "범위의 첫 값·끝 값이나, 몇 칸 앞뒤 행의 값을 가져와요",
    "coreMd": (
        "- FIRST_VALUE와 LAST_VALUE는 윈도우 범위 안에서 첫 행과 마지막 행의 값을 가져와요.\n"
        "- ORDER BY만 쓴 LAST_VALUE는 기본 범위가 현재 행까지라서 현재 행 값이 나오므로, 끝까지 보려면 `UNBOUNDED FOLLOWING`까지 범위를 넓혀요.\n"
        "- LAG는 앞 행, LEAD는 뒤 행의 값을 가져와요. 괄호 안의 두 번째 값은 몇 칸 떨어진 행인지, 세 번째 값은 가져올 행이 없을 때 쓸 기본값이에요.\n"
        "- 가져올 행이 없으면 기본값을 주지 않는 한 NULL이 나와요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

"바로 앞에 입사한 사람보다 급여가 얼마나 많은가", "우리 부서에서 급여가 가장 높은 사람은 누구인가" 같은 질문은 현재 행 옆에 다른 행의 값을 가져다 놓아야 답할 수 있어요. 일반 SQL에서는 같은 테이블을 한 번 더 조인해야 하지만, 행 순서 함수를 쓰면 정렬한 순서에서 원하는 위치의 값을 바로 꺼내 올 수 있어요.

앞뒤 행의 값을 가져올 대상은 아래 사원 여덟 명이에요. 부서번호 20은 개발부, 30은 영업부이고, 예시는 주로 입사일 순서로 줄을 세워요.

{EMPLOYEE_BASE_TABLE}

## 한 줄 정의 {{#definition}}

행 순서 함수는 OVER 안의 ORDER BY로 정한 순서에서, 특정 위치에 있는 행의 값을 현재 행으로 가져오는 함수예요. 네 함수는 가져오는 위치가 서로 달라요.

| 함수 | 가져오는 값 |
|---|---|
| FIRST_VALUE(열) | 윈도우 범위의 첫 행 값 |
| LAST_VALUE(열) | 윈도우 범위의 마지막 행 값 |
| LAG(열, 칸 수, 기본값) | 현재 행보다 앞에 있는 행의 값 |
| LEAD(열, 칸 수, 기본값) | 현재 행보다 뒤에 있는 행의 값 |

LAG는 앞 행(이미 지나온 행), LEAD는 뒤 행(다음 행)의 값을 가져와요. 입사일 순서로 줄을 세웠다면, LAG는 나보다 바로 먼저 입사한 사람을, LEAD는 나보다 바로 나중에 입사한 사람을 본다고 기억하면 쉬워요.

## FIRST_VALUE와 LAST_VALUE {{#first-last}}

영업부 세 명을 급여가 높은 순서로 세우고 첫 값과 끝 값을 가져오면 아래와 같아요. 끝 값은 기본 범위로 한 번, 범위를 끝까지 넓혀서 한 번 구했어요.

{FIRST_LAST_EXAMPLE.markdown}

`첫값`은 모든 행에서 급여가 가장 높은 최유나예요. 기본 범위는 첫 행부터 현재 행까지이고, 범위가 늘 첫 행에서 시작하므로 FIRST_VALUE는 기대한 대로 동작해요.

`끝값기본`은 기대와 달리 행마다 자기 이름이 나왔어요. ORDER BY만 쓰면 범위가 현재 행에서 끝나기 때문에, 범위의 마지막 행이 곧 현재 행이 되는 거예요. 부서에서 급여가 가장 낮은 오지민을 모든 행에 붙이려면 `끝값전체`처럼 `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`으로 범위를 끝까지 넓혀야 해요. 시작은 상관없고 끝만 UNBOUNDED FOLLOWING이면 되므로, `ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING`도 같은 결과를 내요.

## LAG와 LEAD {{#lag-lead}}

LAG와 LEAD는 윈도우 범위가 아니라 현재 행에서 몇 칸 떨어졌는지로 위치를 정해요. 영업부 세 명을 입사일 순서로 세워 앞사람과 뒷사람의 이름을 가져오면 아래와 같아요.

{LAG_LEAD_SMALL_EXAMPLE.markdown}

가장 먼저 입사한 최유나는 앞사람이 없어서 LAG가 NULL이고, 가장 나중에 입사한 오지민은 뒷사람이 없어서 LEAD가 NULL이에요.

LAG는 바로 앞 행과의 차이를 구할 때 자주 써요. 아래 SQL은 사원 8명 전체를 입사일 순서로 세우고, 각 사원이 앞사람보다 급여를 얼마나 더 받는지 구해요.

{LAG_DIFFERENCE_EXAMPLE.markdown}

김민수는 앞사람이 없어서 앞사람급여가 NULL이고, NULL이 섞인 뺄셈이라 차이도 NULL이에요.

함수 괄호 안에 넣는 값을 인자라고 불러요. LAG와 LEAD의 두 번째 인자는 몇 칸 떨어진 행을 볼지 정하고, 생략하면 1이에요. 세 번째 인자는 가져올 행이 없을 때 NULL 대신 쓸 값이에요. 아래 SQL은 입사일이 가장 빠른 세 명(김민수, 최유나, 이지은)만 남겨서 두 인자의 효과를 보여 줘요.

{LAG_ARGUMENT_EXAMPLE.markdown}

`LAG(급여, 2)`는 두 칸 앞을 보기 때문에 세 번째인 이지은에게서 처음으로 김민수의 3000이 나와요. `LAG(급여, 1, 0)`은 앞 행이 없는 김민수에게 NULL 대신 0을 줘요.

## IGNORE NULLS {{#ignore-nulls}}

Oracle에서는 LAG, LEAD, FIRST_VALUE, LAST_VALUE 뒤에 `IGNORE NULLS`를 붙여서 값이 NULL인 행을 건너뛰고 가져올 수 있어요. 아래에서 오지민의 바로 앞인 정하늘은 커미션이 NULL이에요. 그래서 `LAG(커미션)`은 NULL을 돌려주지만, IGNORE NULLS를 붙이면 정하늘을 건너뛰고 그 앞인 박서준의 커미션 0을 돌려줘요.

{IGNORE_NULLS_EXAMPLE.markdown}

## 자주 헷갈리는 점 {{#confusing}}

**ORDER BY만 쓴 LAST_VALUE는 현재 행 값을 돌려줘요.** 시험에서 가장 자주 나오는 함정이에요. 범위를 적지 않으면 `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`가 쓰이고, 그 범위의 마지막 행은 현재 행이에요. 묶음 전체의 마지막 값을 원하면 범위의 끝을 UNBOUNDED FOLLOWING으로 바꿔야 해요.

**동점 행이 있으면 LAST_VALUE의 기본 결과는 동점 묶음의 마지막 행 값이에요.** 기본 범위는 RANGE라서, 범위의 끝은 현재 행이 아니라 현재 행과 ORDER BY 값이 같은 행들의 끝이에요. 개발부를 `ORDER BY 급여`로만 정렬하면 급여 2500인 이지은과 정하늘은 한 묶음이라서, 두 행 모두 같은 이름을 받아요. 동점끼리 누가 뒤에 서는지는 정해지지 않으므로, 그 이름이 이지은일지 정하늘일지만 알 수 없어요.

**LAG는 앞 행, LEAD는 뒤 행이에요.** 시험에서는 두 함수를 바꿔 고르는 실수가 많아요. 여기서 앞과 뒤는 OVER 안의 ORDER BY로 줄 세운 순서를 기준으로 해요. 그래서 `ORDER BY 급여 DESC`라면 LAG는 나보다 급여가 바로 위인 사람의 값을 가져와요.

**가져올 행이 없으면 NULL이고, 0이 아니에요.** 묶음의 첫 행에서 LAG, 마지막 행에서 LEAD를 쓰면 NULL이 나와요. NULL 대신 다른 값을 원하면 세 번째 인자로 기본값을 주는데, 이때는 칸 수를 뜻하는 두 번째 인자도 함께 적어야 해요.

**PARTITION BY를 넣으면 묶음마다 처음부터 다시 봐요.** `LAG(이름) OVER (PARTITION BY 부서번호 ORDER BY 입사일)`에서는 다른 부서 사람이 앞사람이 되지 않아요. 부서마다 가장 먼저 입사한 사람은 앞사람이 NULL이에요.

**LAG와 LEAD에는 윈도우 절을 쓸 수 없고, ORDER BY는 꼭 있어야 해요.** 위치를 칸 수로 정하기 때문에 ROWS나 RANGE를 적으면 문법 오류가 나요. 순서를 모르면 앞뒤를 정할 수 없어서, ORDER BY를 빼면 ORA-30485(OVER 안에 ORDER BY가 없음) 오류가 나요.

```sql
-- 오류: LAG에 ORDER BY가 없어요 (ORA-30485)
SELECT 이름, LAG(급여) OVER () FROM 사원;
-- 오류: LAG에는 윈도우 절을 쓸 수 없어요
SELECT 이름, LAG(급여) OVER (ORDER BY 입사일 ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) FROM 사원;
```

## 시험에서는 이렇게 나와요 {{#exam-point}}

예시 표에 LAG나 LEAD를 적용한 결과를 묻는 문제가 가장 많고, 첫 행이나 마지막 행에서 NULL이 나오는지, 세 번째 인자의 기본값이 쓰이는지를 함께 확인해요. LAST_VALUE는 ORDER BY만 쓴 SQL의 결과를 주고 "왜 현재 행 값이 나오는가"를 묻거나, 마지막 값을 제대로 가져오는 윈도우 절을 고르게 해요. 결과 표를 채울 때는 OVER 안의 ORDER BY 순서대로 행을 다시 줄 세운 다음에 앞뒤를 세면 실수가 줄어요.""",
    "checkQuestions": [
        question(1, "정렬한 순서에서 현재 행보다 앞에 있는 행의 값을 가져오는 함수는 무엇인가요?", "definition",
                 "LAG는 앞 행, LEAD는 뒤 행의 값을 가져와요. FIRST_VALUE와 LAST_VALUE는 윈도우 범위의 첫 행과 마지막 행 값을 가져와요.",
                 [choice("A", "LEAD", rationale="LEAD는 현재 행보다 뒤에 있는 행의 값을 가져와요."),
                  choice("B", "FIRST_VALUE", rationale="FIRST_VALUE는 바로 앞 행이 아니라 범위의 첫 행 값을 가져와요."),
                  choice("C", "LAST_VALUE", rationale="LAST_VALUE는 범위의 마지막 행 값을 가져와요."),
                  choice("D", "LAG", True, "현재 행보다 앞 행의 값을 가져와요.")]),
        question(2, "아래 영업부(30번) 사원 표에 다음 SQL을 실행하면 오지민 행의 다음급여는 무엇인가요?\n\n" + SALES_DEPARTMENT_TABLE, "lag-lead",
                 "입사일 순서는 최유나, 한도윤, 오지민이라서 오지민 뒤에는 행이 없어요. 기본값을 주지 않았으므로 LEAD는 NULL을 돌려줘요.",
                 [choice("A", "NULL", True, "가장 나중에 입사한 오지민은 뒤 행이 없어요."),
                  choice("B", "2700", rationale="한도윤은 오지민보다 먼저 입사한 앞 행이고, LEAD는 뒤 행을 봐요."),
                  choice("C", "2200", rationale="LEAD는 자기 급여가 아니라 다음 행의 값을 가져와요."),
                  choice("D", "0", rationale="세 번째 인자로 기본값을 주지 않아서 0이 아니라 NULL이 나와요.")],
                 stem_sql=LEAD_STEM_SQL),
        question(3, "영업부(30번) 사원은 입사일 순서로 최유나, 한도윤, 오지민이에요. 다음 SQL을 실행하면 최유나 행의 마지막 값은 무엇인가요?", "first-last",
                 "ORDER BY만 쓰면 범위가 첫 행부터 현재 행까지라서, 범위의 마지막 행은 현재 행이에요. 그래서 최유나 행에는 최유나가 나와요.",
                 [choice("A", "오지민", rationale="오지민이 나오려면 범위의 끝을 UNBOUNDED FOLLOWING으로 넓혀야 해요."),
                  choice("B", "최유나", True, "기본 범위의 마지막 행은 현재 행이에요."),
                  choice("C", "NULL", rationale="범위 안에 현재 행이 있으므로 NULL이 나오지 않아요."),
                  choice("D", "한도윤", rationale="한도윤은 최유나 다음 행이라서 기본 범위에 들어가지 않아요.")],
                 stem_sql=LAST_VALUE_STEM_SQL),
        question(4, "`LAST_VALUE(이름) OVER (ORDER BY 입사일 ...)`가 모든 행에서 가장 나중에 입사한 사람의 이름을 돌려주게 하려면, 빈칸에 어떤 윈도우 절을 넣어야 하나요?", "confusing",
                 "LAST_VALUE는 범위의 마지막 행 값을 가져오므로, 범위의 끝이 묶음의 마지막 행(UNBOUNDED FOLLOWING)이어야 해요. 끝이 CURRENT ROW인 범위는 모두 현재 행 값을 돌려줘요.",
                 [choice("A", "ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW", rationale="범위가 현재 행에서 끝나서 현재 행 값이 그대로 나와요."),
                  choice("B", "RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW", rationale="이것이 기본 범위라서 결과가 바뀌지 않아요."),
                  choice("C", "ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING", True, "범위가 묶음의 마지막 행까지 넓어져요."),
                  choice("D", "ROWS BETWEEN 1 PRECEDING AND CURRENT ROW", rationale="바로 앞 행과 현재 행만 보므로 마지막 행에 닿지 않아요.")]),
        question(5, "영업부(30번) 사원은 입사일 순서로 최유나(급여 3200), 한도윤(2700), 오지민(2200)이에요. 다음 SQL의 결과로 옳은 것은 무엇인가요?", "lag-lead",
                 "LAG(급여, 2, 0)은 두 칸 앞의 급여를 가져오고, 두 칸 앞이 없으면 0을 줘요. 최유나와 한도윤은 두 칸 앞이 없어서 0이고, 오지민은 최유나의 3200을 받아요.",
                 [choice("A", "최유나 0, 한도윤 3200, 오지민 2700", rationale="한 칸 앞의 값이고, 두 번째 인자 2는 두 칸 앞을 뜻해요."),
                  choice("B", "최유나 NULL, 한도윤 NULL, 오지민 3200", rationale="세 번째 인자 0이 있어서 NULL 대신 0이 나와요."),
                  choice("C", "최유나 2200, 한도윤 0, 오지민 0", rationale="두 칸 뒤를 본 LEAD의 결과예요."),
                  choice("D", "최유나 0, 한도윤 0, 오지민 3200", True, "두 칸 앞이 없는 두 행에는 기본값 0이 들어가요.")],
                 stem_sql=LAG_DEFAULT_STEM_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 결과 표
        FIRST_LAST_EXAMPLE.check,
        LAG_LEAD_SMALL_EXAMPLE.check,
        LAG_DIFFERENCE_EXAMPLE.check,
        LAG_ARGUMENT_EXAMPLE.check,
        IGNORE_NULLS_EXAMPLE.check,
        # 본문 설명: CURRENT ROW ~ UNBOUNDED FOLLOWING 도 같은 끝 값, PARTITION BY 첫 행은 NULL, 오류 2개
        sql_check("SELECT 이름, LAST_VALUE(이름) OVER (ORDER BY 급여 DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) "
                  "FROM 사원 WHERE 부서번호 = 30",
                  [["최유나", "오지민"], ["한도윤", "오지민"], ["오지민", "오지민"]]),
        sql_check("SELECT 이름, LAG(이름) OVER (PARTITION BY 부서번호 ORDER BY 입사일) FROM 사원 WHERE 부서번호 IN (20, 30)",
                  [["이지은", None], ["박서준", "이지은"], ["정하늘", "박서준"], ["최유나", None], ["한도윤", "최유나"], ["오지민", "한도윤"]]),
        sql_check("SELECT COUNT(DISTINCT 끝값) FROM (SELECT 급여, LAST_VALUE(이름) OVER (ORDER BY 급여) AS 끝값 "
                  "FROM 사원 WHERE 부서번호 = 20) WHERE 급여 = 2500", [[1]]),
        sql_check("SELECT 이름, LAG(이름) OVER (ORDER BY 급여 DESC) FROM 사원 WHERE 부서번호 = 30",
                  [["최유나", None], ["한도윤", "최유나"], ["오지민", "한도윤"]]),
        sql_error_check("SELECT 이름, LAG(급여) OVER () FROM 사원", "ORA-30485"),
        sql_error_check("SELECT 이름, LAG(급여) OVER (ORDER BY 입사일 ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) FROM 사원", "ORA-00907"),
        # 확인 문제 2·3·5번 stemSql
        sql_check(LEAD_STEM_SQL, [["최유나", 2700], ["한도윤", 2200], ["오지민", None]]),
        sql_check(LAST_VALUE_STEM_SQL, [["최유나", "최유나"], ["한도윤", "한도윤"], ["오지민", "오지민"]]),
        sql_check(LAG_DEFAULT_STEM_SQL, [["최유나", 0], ["한도윤", 0], ["오지민", 3200]]),
        # 확인 문제 4번 보기 (영업부 3명)
        sql_check("SELECT 이름, LAST_VALUE(이름) OVER (ORDER BY 입사일 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) FROM 사원 WHERE 부서번호 = 30",
                  [["최유나", "최유나"], ["한도윤", "한도윤"], ["오지민", "오지민"]]),
        sql_check("SELECT 이름, LAST_VALUE(이름) OVER (ORDER BY 입사일 RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) FROM 사원 WHERE 부서번호 = 30",
                  [["최유나", "최유나"], ["한도윤", "한도윤"], ["오지민", "오지민"]]),
        sql_check("SELECT 이름, LAST_VALUE(이름) OVER (ORDER BY 입사일 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) FROM 사원 WHERE 부서번호 = 30",
                  [["최유나", "오지민"], ["한도윤", "오지민"], ["오지민", "오지민"]]),
        sql_check("SELECT 이름, LAST_VALUE(이름) OVER (ORDER BY 입사일 ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) FROM 사원 WHERE 부서번호 = 30",
                  [["최유나", "최유나"], ["한도윤", "한도윤"], ["오지민", "오지민"]]),
        # 확인 문제 5번 오답 보기 (한 칸 앞, 두 칸 뒤)
        sql_check("SELECT 이름, LAG(급여, 1, 0) OVER (ORDER BY 입사일) FROM 사원 WHERE 부서번호 = 30",
                  [["최유나", 0], ["한도윤", 3200], ["오지민", 2700]]),
        sql_check("SELECT 이름, LEAD(급여, 2, 0) OVER (ORDER BY 입사일) FROM 사원 WHERE 부서번호 = 30",
                  [["최유나", 2200], ["한도윤", 0], ["오지민", 0]]),
    ],
}
