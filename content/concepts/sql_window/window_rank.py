"""개념: 순위 함수 (8단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

# 계산에 쓰는 원본 열 (이 개념의 예시는 모두 이 표로 계산)
EMPLOYEE_BASE_TABLE = to_employee_table_md("사번", "이름", "급여", "커미션", "부서번호")

EMPLOYEE_SALARY_TABLE = to_employee_table_md("사번", "이름", "급여")

# 본문 예시 SQL > 결과 행 (본문 표와 sqlChecks 가 같은 원본을 씀, ROW_NUMBER 는 사번으로 동점 순서 고정)
SMALL_RANK_SQL = """SELECT 이름, 급여,
       RANK() OVER (ORDER BY 급여 DESC) AS 랭크,
       DENSE_RANK() OVER (ORDER BY 급여 DESC) AS 덴스랭크,
       ROW_NUMBER() OVER (ORDER BY 급여 DESC, 사번) AS 행번호
FROM 사원
WHERE 부서번호 = 20
ORDER BY 급여 DESC, 사번;"""
SMALL_RANK_ROWS = [["박서준", 2800, 1, 1, 1], ["이지은", 2500, 2, 2, 2], ["정하늘", 2500, 2, 2, 3]]

FULL_RANK_SQL = """SELECT 이름, 급여,
       RANK() OVER (ORDER BY 급여 DESC) AS 랭크,
       DENSE_RANK() OVER (ORDER BY 급여 DESC) AS 덴스랭크,
       ROW_NUMBER() OVER (ORDER BY 급여 DESC, 사번) AS 행번호
FROM 사원
ORDER BY 급여 DESC, 사번;"""
FULL_RANK_ROWS = [
    ["최유나", 3200, 1, 1, 1], ["김민수", 3000, 2, 2, 2], ["박서준", 2800, 3, 3, 3], ["한도윤", 2700, 4, 4, 4],
    ["이지은", 2500, 5, 5, 5], ["정하늘", 2500, 5, 5, 6], ["오지민", 2200, 7, 6, 7], ["윤서연", 2000, 8, 7, 8],
]

PARTITION_RANK_SQL = """SELECT 부서번호, 이름, 급여,
       RANK() OVER (PARTITION BY 부서번호 ORDER BY 급여 DESC) AS 부서순위
FROM 사원
ORDER BY 부서번호, 부서순위, 사번;"""
PARTITION_RANK_ROWS = [
    [10, "김민수", 3000, 1], [20, "박서준", 2800, 1], [20, "이지은", 2500, 2], [20, "정하늘", 2500, 2],
    [30, "최유나", 3200, 1], [30, "한도윤", 2700, 2], [30, "오지민", 2200, 3], [None, "윤서연", 2000, 1],
]

# 커미션 NULL 4명: 내림차순이면 NULL 이 맨 앞(1위)
NULL_RANK_SQL = """SELECT 이름, 커미션,
       RANK() OVER (ORDER BY 커미션 DESC) AS 기본,
       RANK() OVER (ORDER BY 커미션 DESC NULLS LAST) AS 널뒤로
FROM 사원
ORDER BY 기본, 사번;"""
NULL_RANK_ROWS = [
    ["김민수", None, 1, 5], ["최유나", None, 1, 5], ["정하늘", None, 1, 5], ["윤서연", None, 1, 5],
    ["한도윤", 500, 5, 1], ["이지은", 300, 6, 2], ["오지민", 200, 7, 3], ["박서준", 0, 8, 4],
]

# 확인 문제 stemSql
RANK_STEM_SQL = "SELECT 이름, RANK() OVER (ORDER BY 급여 DESC) AS 순위 FROM 사원;"
DENSE_RANK_STEM_SQL = "SELECT 이름, DENSE_RANK() OVER (PARTITION BY 부서번호 ORDER BY 급여) AS 순위 FROM 사원 WHERE 부서번호 = 20;"

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
SMALL_RANK_EXAMPLE = sql_example(SMALL_RANK_SQL, ("이름", "급여", "랭크", "덴스랭크", "행번호"), SMALL_RANK_ROWS)
FULL_RANK_EXAMPLE = sql_example(FULL_RANK_SQL, ("이름", "급여", "랭크", "덴스랭크", "행번호"), FULL_RANK_ROWS)
PARTITION_RANK_EXAMPLE = sql_example(PARTITION_RANK_SQL, ("부서번호", "이름", "급여", "부서순위"), PARTITION_RANK_ROWS)
NULL_RANK_EXAMPLE = sql_example(NULL_RANK_SQL, ("이름", "커미션", "기본", "널뒤로"), NULL_RANK_ROWS)

CONCEPT = {
    "tagKey": "window-rank",
    "topicCode": "sql_window",
    "sortOrder": 2,
    "title": "순위 함수",
    "summary": "RANK·DENSE_RANK·ROW_NUMBER는 동점을 다루는 방식이 달라요",
    "coreMd": (
        "- RANK는 동점에 같은 순위를 주고, 동점인 행 수만큼 다음 순위를 건너뛰어요(1, 1, 3).\n"
        "- DENSE_RANK는 동점에 같은 순위를 주되, 다음 순위를 건너뛰지 않아요(1, 1, 2).\n"
        "- ROW_NUMBER는 동점이어도 1, 2, 3처럼 서로 다른 번호를 주고, 동점끼리 누가 앞설지는 ORDER BY에 기준을 더 넣어야 정해져요.\n"
        "- 세 함수 모두 OVER 안에 ORDER BY가 꼭 있어야 하고, PARTITION BY를 넣으면 묶음마다 1부터 다시 매겨요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

급여가 높은 순서로 사원을 줄 세우는 일은 ORDER BY로 충분하지만, 각 사원이 몇 등인지 숫자로 붙이려면 순위 함수가 필요해요. 이때 곧바로 부딪히는 문제가 동점이에요. 20번 부서의 이지은과 정하늘은 급여가 2500으로 같은데, 둘에게 같은 등수를 줄지, 그다음 사람은 몇 등으로 할지에 따라 쓰는 함수가 달라져요.

순위를 매길 사원 여덟 명은 아래와 같아요. 부서번호 10은 기획부, 20은 개발부, 30은 영업부이고, 윤서연은 부서번호가 NULL이라 부서가 없어요.

{EMPLOYEE_BASE_TABLE}

## 한 줄 정의 {{#definition}}

순위 함수는 OVER 안의 ORDER BY 순서대로 각 행에 순위 번호를 붙이는 윈도우 함수예요. RANK, DENSE_RANK, ROW_NUMBER 세 가지가 있고, 동점이 없으면 셋의 결과는 똑같아요. 셋은 동점을 처리하는 방식만 달라요.

| 함수 | 동점의 순위 | 동점 다음 순위 | 급여 3000, 2500, 2500, 2000 |
|---|---|---|---|
| RANK | 같은 순위 | 동점 수만큼 건너뜀 | 1, 2, 2, 4 |
| DENSE_RANK | 같은 순위 | 건너뛰지 않음 | 1, 2, 2, 3 |
| ROW_NUMBER | 서로 다른 번호 | 이어서 매김 | 1, 2, 3, 4 |

DENSE는 "빽빽한"이라는 뜻이라서, DENSE_RANK는 빈 번호 없이 촘촘하게 순위를 매긴다고 기억하면 돼요.

## 작은 예시: 개발부 세 명 {{#small-example}}

개발부 세 명에게 세 함수를 함께 적용하면 아래와 같아요. 급여가 높은 사람이 1등이 되도록 `ORDER BY 급여 DESC`로 정렬했어요.

{SMALL_RANK_EXAMPLE.markdown}

이지은과 정하늘은 RANK와 DENSE_RANK에서 똑같이 2등이에요. ROW_NUMBER만 두 사람에게 2와 3을 나눠 줬는데, 누가 2번이 될지는 급여만으로 정할 수 없어서 `사번`을 두 번째 정렬 기준으로 넣었어요. 이 예시에서는 동점 뒤에 다른 사람이 없어서 RANK와 DENSE_RANK의 차이가 드러나지 않아요.

## 전체 사원으로 보기 {{#full-example}}

사원 8명 전체로 넓히면, 동점 다음에 오는 사람의 순위에서 RANK와 DENSE_RANK가 갈라져요.

{FULL_RANK_EXAMPLE.markdown}

이지은과 정하늘이 함께 5등을 차지했기 때문에, RANK는 6등을 비워 두고 오지민에게 7등을 줘요. DENSE_RANK는 빈 번호 없이 오지민에게 6등을 줘요. 이 표에서 RANK의 가장 큰 값은 8로, 전체 행 수와 같아요. 맨 끝에 동점이 없으면 RANK는 늘 행 수로 끝나요. DENSE_RANK의 가장 큰 값은 7인데, 서로 다른 급여가 일곱 가지이기 때문이에요.

## 부서별 순위 {{#partition}}

OVER 안에 PARTITION BY를 넣으면 묶음마다 순위를 따로 매기고, 묶음이 바뀌면 다시 1부터 시작해요.

{PARTITION_RANK_EXAMPLE.markdown}

개발부에서는 박서준이 1등이고 이지은과 정하늘이 함께 2등이에요. 부서가 없는 윤서연은 NULL끼리 한 묶음이 되어 혼자 1등이 돼요. 바깥의 `ORDER BY`는 결과를 보기 좋게 정렬할 뿐이고, 순위 값은 OVER 안의 ORDER BY로 이미 정해져 있어요.

## 자주 헷갈리는 점 {{#confusing}}

**건너뛰는 쪽은 RANK이고, 건너뛰지 않는 쪽은 DENSE_RANK예요.** 시험 보기에서는 두 함수의 결과를 바꿔 놓는 경우가 많아요. 동점 바로 다음 사람의 순위를 확인해서, 동점인 사람 수만큼 번호가 비어 있으면 RANK, 비어 있지 않으면 DENSE_RANK라고 판단하면 돼요.

**ROW_NUMBER는 동점끼리의 순서를 보장하지 않아요.** `ROW_NUMBER() OVER (ORDER BY 급여 DESC)`처럼 급여만 기준으로 주면, 이지은과 정하늘 중 누가 5번이 될지는 Oracle이 정해요. 실행할 때마다 바뀔 수도 있으니, 번호를 고정하고 싶으면 `ORDER BY 급여 DESC, 사번`처럼 동점을 가를 기준을 하나 더 넣어야 해요.

**순위 함수에는 ORDER BY가 꼭 있어야 해요.** 무엇을 기준으로 줄 세울지 모르면 순위를 매길 수 없어서, `RANK() OVER ()`처럼 ORDER BY를 빼면 ORA-30485(OVER 안에 ORDER BY가 없음) 오류가 나요. 반대로 PARTITION BY는 생략할 수 있고, 생략하면 전체 행이 한 묶음이 돼요.

```sql
-- 오류: 순위 함수에 ORDER BY가 없어요 (ORA-30485)
SELECT 이름, RANK() OVER () FROM 사원;
```

**높은 값이 1등이 되려면 DESC를 써야 해요.** OVER 안의 ORDER BY도 기본이 오름차순(ASC)이라서, `RANK() OVER (ORDER BY 급여)`라고 쓰면 급여가 가장 낮은 윤서연이 1등이 돼요.

**Oracle은 정렬할 때 NULL을 가장 큰 값으로 봐요.** 그래서 오름차순에서는 NULL이 맨 뒤에, 내림차순에서는 맨 앞에 와요. 커미션으로 내림차순 순위를 매기면 커미션이 NULL인 네 명이 함께 1등이 되고, 커미션이 가장 많은 한도윤은 5등이 돼요. NULL을 뒤로 보내려면 정렬 기준 뒤에 `NULLS LAST`(NULL을 맨 뒤에 두라는 표시)를 붙여요.

{NULL_RANK_EXAMPLE.markdown}

## 시험에서는 이렇게 나와요 {{#exam-point}}

예시 표에 RANK, DENSE_RANK, ROW_NUMBER를 함께 적용한 SQL을 주고, 결과 표에서 틀린 값을 찾거나 특정 사원의 순위를 묻는 문제가 가장 많아요. 이때는 동점인 행부터 찾아서 그 행과 바로 다음 행의 번호만 확인하면 대부분 풀려요. PARTITION BY가 있으면 묶음마다 1부터 다시 센다는 점과, OVER 안의 ORDER BY 방향(ASC·DESC)을 함께 확인해요.""",
    "checkQuestions": [
        question(1, "동점인 행에 같은 순위를 주고, 그다음 순위를 동점인 행 수만큼 건너뛰는 함수는 무엇인가요?", "definition",
                 "RANK는 동점에 같은 순위를 준 뒤 그 수만큼 번호를 비워요. DENSE_RANK는 비우지 않고, ROW_NUMBER는 동점에도 다른 번호를 줘요.",
                 [choice("A", "ROW_NUMBER", rationale="ROW_NUMBER는 동점이어도 서로 다른 번호를 줘요."),
                  choice("B", "DENSE_RANK", rationale="DENSE_RANK는 동점 다음 순위를 건너뛰지 않아요."),
                  choice("C", "RANK", True, "동점에 같은 순위를 주고 다음 순위를 건너뛰어요."),
                  choice("D", "세 함수 모두 같다", rationale="세 함수는 동점을 처리하는 방식이 서로 달라요.")]),
        question(2, "급여가 3000, 2500, 2500, 2000인 네 행에 `DENSE_RANK() OVER (ORDER BY 급여 DESC)`를 적용하면 순위는 어떻게 되나요?", "definition",
                 "DENSE_RANK는 2500 두 행에 같은 2등을 주고, 다음 행에 빈 번호 없이 3등을 줘요.",
                 [choice("A", "1, 2, 2, 4", rationale="다음 순위를 건너뛴 RANK의 결과예요."),
                  choice("B", "1, 2, 2, 3", True, "동점 다음 순위를 건너뛰지 않아요."),
                  choice("C", "1, 2, 3, 4", rationale="동점에도 다른 번호를 준 ROW_NUMBER의 결과예요."),
                  choice("D", "1, 1, 2, 3", rationale="3000과 2500은 값이 달라서 같은 순위가 아니에요.")]),
        question(3, "아래 사원 표에 다음 SQL을 실행하면 오지민(급여 2200)의 순위는 얼마인가요?\n\n" + EMPLOYEE_SALARY_TABLE, "full-example",
                 "이지은과 정하늘이 함께 5등이라서 RANK는 6등을 비워 둬요. 그래서 그다음인 오지민은 7등이에요.",
                 [choice("A", "6", rationale="번호를 건너뛰지 않는 DENSE_RANK의 결과예요."),
                  choice("B", "8", rationale="오지민보다 급여가 낮은 윤서연이 8등이에요."),
                  choice("C", "5", rationale="5등은 급여 2500인 이지은과 정하늘이에요."),
                  choice("D", "7", True, "동점 2명이 5등을 차지해서 6등이 비고, 오지민은 7등이에요.")],
                 stem_sql=RANK_STEM_SQL),
        question(4, "`ROW_NUMBER() OVER (ORDER BY 급여 DESC)`로 번호를 매길 때, 급여가 2500으로 같은 이지은과 정하늘에 대한 설명으로 옳은 것은 무엇인가요?", "confusing",
                 "ROW_NUMBER는 동점이어도 서로 다른 번호를 줘요. 다만 급여만 기준이라서 둘 중 누가 앞 번호를 받을지는 정해져 있지 않아요.",
                 [choice("A", "두 사람 모두 5번을 받는다", rationale="같은 번호를 주는 것은 RANK와 DENSE_RANK예요."),
                  choice("B", "사번이 빠른 이지은이 항상 5번을 받는다", rationale="ORDER BY에 사번이 없어서 사번 순서는 보장되지 않아요."),
                  choice("C", "한 명은 5번, 다른 한 명은 6번이고, 누가 5번일지는 정해져 있지 않다", True,
                         "동점끼리의 순서는 ORDER BY에 기준을 더 넣어야 정해져요."),
                  choice("D", "두 사람 모두 6번을 받는다", rationale="ROW_NUMBER는 같은 번호를 두 번 주지 않아요.")]),
        question(5, "20번 부서 사원은 이지은(급여 2500), 박서준(2800), 정하늘(2500) 세 명이에요. 다음 SQL의 결과로 옳은 것은 무엇인가요?", "partition",
                 "오름차순이라 급여가 낮은 2500 두 명이 함께 1등이에요. DENSE_RANK는 번호를 건너뛰지 않으므로 박서준은 2등이에요.",
                 [choice("A", "이지은 1, 정하늘 1, 박서준 2", True, "오름차순 DENSE_RANK의 결과예요."),
                  choice("B", "이지은 1, 정하늘 1, 박서준 3", rationale="다음 순위를 건너뛴 RANK의 결과예요."),
                  choice("C", "박서준 1, 이지은 2, 정하늘 2", rationale="DESC가 없으므로 급여가 낮은 쪽이 1등이에요."),
                  choice("D", "이지은 1, 정하늘 2, 박서준 3", rationale="동점에 다른 번호를 준 ROW_NUMBER의 결과예요.")],
                 stem_sql=DENSE_RANK_STEM_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 결과 표
        SMALL_RANK_EXAMPLE.check,
        FULL_RANK_EXAMPLE.check,
        PARTITION_RANK_EXAMPLE.check,
        NULL_RANK_EXAMPLE.check,
        sql_error_check("SELECT 이름, RANK() OVER () FROM 사원", "ORA-30485"),
        sql_error_check("SELECT 이름, ROW_NUMBER() OVER () FROM 사원", "ORA-30485"),
        # 본문 설명: 오름차순이면 가장 낮은 급여(윤서연)가 1등
        sql_check("SELECT 이름 FROM (SELECT 이름, RANK() OVER (ORDER BY 급여) AS 순위 FROM 사원) WHERE 순위 = 1", [["윤서연"]]),
        # 정의 표 · 확인 문제 2번 (급여 3000, 2500, 2500, 2000 = 김민수·이지은·정하늘·윤서연)
        sql_check("SELECT 급여, RANK() OVER (ORDER BY 급여 DESC), DENSE_RANK() OVER (ORDER BY 급여 DESC), "
                  "ROW_NUMBER() OVER (ORDER BY 급여 DESC, 사번) FROM 사원 WHERE 사번 IN (1001, 1002, 1005, 1008) ORDER BY 급여 DESC, 사번",
                  [[3000, 1, 1, 1], [2500, 2, 2, 2], [2500, 2, 2, 3], [2000, 4, 3, 4]], is_ordered=True),
        # 확인 문제 3·5번 stemSql
        sql_check(RANK_STEM_SQL, [[name, rank] for name, _, rank, _, _ in FULL_RANK_ROWS]),
        sql_check(DENSE_RANK_STEM_SQL, [["이지은", 1], ["정하늘", 1], ["박서준", 2]]),
        # 확인 문제 5번 오답 보기 (RANK, ROW_NUMBER 오름차순)
        sql_check("SELECT 이름, RANK() OVER (PARTITION BY 부서번호 ORDER BY 급여) FROM 사원 WHERE 부서번호 = 20",
                  [["이지은", 1], ["정하늘", 1], ["박서준", 3]]),
        sql_check("SELECT 이름, ROW_NUMBER() OVER (PARTITION BY 부서번호 ORDER BY 급여, 사번) FROM 사원 WHERE 부서번호 = 20",
                  [["이지은", 1], ["정하늘", 2], ["박서준", 3]]),
    ],
}
