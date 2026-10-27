"""개념: 비율 함수 (8단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

# 계산에 쓰는 원본 열 (이 개념의 예시는 모두 이 표로 계산)
EMPLOYEE_BASE_TABLE = to_employee_table_md("사번", "이름", "급여", "커미션", "부서번호")

EMPLOYEE_COMMISSION_TABLE = to_employee_table_md("이름", "커미션")

# 본문 예시 SQL > 결과 행 (본문 표와 sqlChecks 가 같은 원본을 씀, 소수는 ROUND, NTILE 은 사번으로 동점 순서 고정)
RATIO_TO_REPORT_SQL = """SELECT 부서번호, 이름, 급여,
       ROUND(RATIO_TO_REPORT(급여) OVER (PARTITION BY 부서번호), 2) AS 비율
FROM 사원
WHERE 부서번호 IN (20, 30)
ORDER BY 부서번호, 사번;"""
RATIO_TO_REPORT_ROWS = [
    [20, "이지은", 2500, 0.32], [20, "박서준", 2800, 0.36], [20, "정하늘", 2500, 0.32],
    [30, "최유나", 3200, 0.4], [30, "한도윤", 2700, 0.33], [30, "오지민", 2200, 0.27],
]

SMALL_DISTRIBUTION_SQL = """SELECT 이름, 급여,
       RANK() OVER (ORDER BY 급여) AS 순위,
       PERCENT_RANK() OVER (ORDER BY 급여) AS 백분위순위,
       ROUND(CUME_DIST() OVER (ORDER BY 급여), 2) AS 누적비율
FROM 사원
WHERE 부서번호 = 20
ORDER BY 급여, 사번;"""
SMALL_DISTRIBUTION_ROWS = [["이지은", 2500, 1, 0, 0.67], ["정하늘", 2500, 1, 0, 0.67], ["박서준", 2800, 3, 1, 1]]

FULL_DISTRIBUTION_SQL = """SELECT 이름, 급여,
       RANK() OVER (ORDER BY 급여) AS 순위,
       ROUND(PERCENT_RANK() OVER (ORDER BY 급여), 3) AS 백분위순위,
       ROUND(CUME_DIST() OVER (ORDER BY 급여), 3) AS 누적비율
FROM 사원
ORDER BY 급여, 사번;"""
FULL_DISTRIBUTION_ROWS = [
    ["윤서연", 2000, 1, 0, 0.125], ["오지민", 2200, 2, 0.143, 0.25], ["이지은", 2500, 3, 0.286, 0.5],
    ["정하늘", 2500, 3, 0.286, 0.5], ["한도윤", 2700, 5, 0.571, 0.625], ["박서준", 2800, 6, 0.714, 0.75],
    ["김민수", 3000, 7, 0.857, 0.875], ["최유나", 3200, 8, 1, 1],
]

NTILE_SQL = """SELECT 이름, 급여,
       NTILE(3) OVER (ORDER BY 급여 DESC, 사번) AS 그룹
FROM 사원
ORDER BY 급여 DESC, 사번;"""
NTILE_ROWS = [
    ["최유나", 3200, 1], ["김민수", 3000, 1], ["박서준", 2800, 1], ["한도윤", 2700, 2],
    ["이지은", 2500, 2], ["정하늘", 2500, 2], ["오지민", 2200, 3], ["윤서연", 2000, 3],
]

# 확인 문제 stemSql
RATIO_STEM_SQL = "SELECT 이름, RATIO_TO_REPORT(커미션) OVER () AS 비율 FROM 사원;"
CUME_DIST_STEM_SQL = "SELECT 이름, ROUND(CUME_DIST() OVER (ORDER BY 급여), 2) AS 누적비율 FROM 사원 WHERE 부서번호 = 20;"
PERCENT_RANK_STEM_SQL = "SELECT 이름, PERCENT_RANK() OVER (ORDER BY 급여) AS 백분위순위 FROM 사원 WHERE 부서번호 = 30;"
NTILE_STEM_SQL = "SELECT 이름, NTILE(5) OVER (ORDER BY 급여 DESC, 사번) AS 그룹 FROM 사원;"

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
RATIO_TO_REPORT_EXAMPLE = sql_example(RATIO_TO_REPORT_SQL, ("부서번호", "이름", "급여", "비율"), RATIO_TO_REPORT_ROWS)
SMALL_DISTRIBUTION_EXAMPLE = sql_example(SMALL_DISTRIBUTION_SQL, ("이름", "급여", "순위", "백분위순위", "누적비율"), SMALL_DISTRIBUTION_ROWS)
FULL_DISTRIBUTION_EXAMPLE = sql_example(FULL_DISTRIBUTION_SQL, ("이름", "급여", "순위", "백분위순위", "누적비율"), FULL_DISTRIBUTION_ROWS)
NTILE_EXAMPLE = sql_example(NTILE_SQL, ("이름", "급여", "그룹"), NTILE_ROWS)

CONCEPT = {
    "tagKey": "window-ratio",
    "topicCode": "sql_window",
    "sortOrder": 5,
    "title": "비율 함수",
    "summary": "합계 대비 비율, 백분위 순위, 누적 비율, 그룹 번호를 구해요",
    "coreMd": (
        "- RATIO_TO_REPORT는 현재 값이 묶음 합계에서 차지하는 비율이고, OVER 안에 ORDER BY를 쓸 수 없어요.\n"
        "- PERCENT_RANK는 (순위 - 1) / (행 수 - 1)이라서 첫 행은 0, 마지막 행은 1이에요.\n"
        "- CUME_DIST는 현재 행까지(동점 행 포함) 몇 행이 쌓였는지를 전체 행 수로 나눈 값이라서, 0이 나오지 않아요.\n"
        "- NTILE(n)은 행을 n개 그룹으로 나누고, 남는 행은 앞 그룹부터 하나씩 더 줘요(8행을 3개로 나누면 3, 3, 2)."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

"내 급여가 부서 인건비의 몇 %를 차지하는가", "나는 회사에서 상위 몇 %인가", "급여 순서로 사원을 세 반으로 나누면 나는 몇 반인가" 같은 질문은 순위나 합계만으로는 바로 답하기 어려워요. 합계로 나누거나 순위를 행 수로 나누는 계산을 직접 해야 하는데, 비율 함수는 이 계산을 함수 하나로 해 줘요.

비율을 계산할 사원 여덟 명은 아래와 같아요. 부서번호 20은 개발부, 30은 영업부이고, 커미션이 NULL인 사원이 네 명 있어요.

{EMPLOYEE_BASE_TABLE}

## 한 줄 정의 {{#definition}}

비율 함수는 묶음 안에서 현재 행이 차지하는 비율이나 위치를 0과 1 사이의 값, 또는 그룹 번호로 돌려주는 윈도우 함수예요. 네 함수는 계산하는 방식과 OVER 안에 쓰는 내용이 서로 달라요.

| 함수 | 계산 | OVER 안의 ORDER BY |
|---|---|---|
| RATIO_TO_REPORT(열) | 현재 값 / 묶음 합계 | 쓸 수 없어요 |
| PERCENT_RANK() | (순위 - 1) / (행 수 - 1) | 꼭 있어야 해요 |
| CUME_DIST() | 현재 행까지 쌓인 행 수 / 행 수 | 꼭 있어야 해요 |
| NTILE(n) | 1부터 n까지 그룹 번호 | 꼭 있어야 해요 |

NTILE은 비율이 아니라 그룹 번호를 돌려주지만, SQLD에서는 비율 함수로 분류해요.

## RATIO_TO_REPORT {{#ratio-to-report}}

RATIO_TO_REPORT는 "보고서 합계에 대한 비율"이라는 뜻으로, 현재 행의 값을 묶음 전체의 합으로 나눈 값을 돌려줘요. 묶음마다 비율을 모두 더하면 1이 돼요.

{RATIO_TO_REPORT_EXAMPLE.markdown}

개발부 합계가 7800이라서 박서준의 비율은 2800 / 7800 = 0.358...이고, 반올림 함수 `ROUND(값, 2)`가 소수 둘째 자리까지 남겨서 0.36이 됐어요. `급여 / SUM(급여) OVER (PARTITION BY 부서번호)`라고 써도 같은 값이 나와요. 전체 합계 대비 비율이 필요하면 `OVER ()`처럼 괄호를 비워요.

## PERCENT_RANK와 CUME_DIST: 작은 예시 {{#small-example}}

PERCENT_RANK는 순위를 0부터 1 사이로 바꾼 값이에요. 첫 순위는 0, 마지막 순위는 1이 되도록 (순위 - 1)을 (행 수 - 1)로 나눠요. CUME_DIST는 누적 분포(Cumulative Distribution)라는 뜻이고, 정렬 순서에서 현재 행과 같거나 앞에 있는 행이 전체의 몇 분의 몇인지 돌려줘요. 개발부 세 명으로 먼저 계산해 보면 아래와 같아요.

{SMALL_DISTRIBUTION_EXAMPLE.markdown}

이지은과 정하늘은 함께 1위라서 PERCENT_RANK가 (1 - 1) / (3 - 1) = 0이에요. 박서준은 3위라서 (3 - 1) / (3 - 1) = 1이에요. CUME_DIST에서 급여가 2500 이하인 행은 이지은과 정하늘 두 명이라서, 두 사람 모두 2 / 3 = 0.67을 받아요.

## 전체 사원으로 보기 {{#full-example}}

사원 8명 전체로 넓혀도 계산 방법은 같아요. 소수가 길게 이어지는 값은 ROUND로 소수 셋째 자리까지 반올림했어요. PERCENT_RANK는 7(= 8 - 1)로 나누고, CUME_DIST는 8로 나눠요.

{FULL_DISTRIBUTION_EXAMPLE.markdown}

3위인 이지은과 정하늘의 PERCENT_RANK는 (3 - 1) / 7 = 0.286이에요. 두 사람의 CUME_DIST는 급여가 2500 이하인 네 명을 세어서 4 / 8 = 0.5예요. 윤서연처럼 정렬의 첫 행이라도 CUME_DIST는 자기 자신을 세므로 1 / 8 = 0.125이고, 0이 되지 않아요.

## NTILE {{#ntile}}

NTILE(n)은 정렬한 행을 n개의 그룹으로 최대한 고르게 나누고, 각 행에 1부터 n까지 그룹 번호를 붙여요. 행 수가 n으로 나누어떨어지지 않으면 남는 행을 앞 그룹부터 하나씩 더 줘요.

{NTILE_EXAMPLE.markdown}

8을 3으로 나누면 몫이 2이고 나머지가 2라서, 모든 그룹이 2명씩 받은 뒤 남은 2명이 1번과 2번 그룹에 한 명씩 더 들어가요. 그래서 그룹 인원은 3, 3, 2가 돼요. 같은 계산으로 NTILE(5)는 8명을 2, 2, 2, 1, 1로 나눠요.

## 자주 헷갈리는 점 {{#confusing}}

**PERCENT_RANK는 0에서 시작하고, CUME_DIST는 0이 나오지 않아요.** 두 함수 모두 마지막 행은 1이지만, 첫 행에서 PERCENT_RANK는 0, CUME_DIST는 1 / 행 수예요. PERCENT_RANK는 "나보다 앞선 행의 비율", CUME_DIST는 "나까지 포함해 쌓인 행의 비율"이라고 구분하면 돼요.

**동점 행에서 두 함수가 세는 자리가 달라요.** 사원 여덟 명을 급여 오름차순으로 세우면, 윤서연과 오지민 다음인 세 번째와 네 번째 자리에 급여 2500인 이지은과 정하늘이 서요. PERCENT_RANK는 RANK를 쓰므로 두 사람 모두 묶음의 첫 자리인 3위를 받아 (3 - 1) / 7 = 0.286이에요. CUME_DIST는 두 사람 모두 묶음의 마지막 자리인 네 번째까지 세어서 4 / 8 = 0.5를 받아요. 동점 묶음 안에서 PERCENT_RANK는 첫 자리를, CUME_DIST는 마지막 자리를 기준으로 삼는다고 기억하면 돼요.

**RATIO_TO_REPORT에는 ORDER BY를 쓸 수 없어요.** 비율은 묶음 합계만 있으면 계산되고 순서가 필요 없기 때문에, OVER 안에 ORDER BY를 넣으면 ORA-30487(여기에는 ORDER BY를 쓸 수 없음) 오류가 나요. 반대로 PERCENT_RANK, CUME_DIST, NTILE은 ORDER BY를 빼면 ORA-30485(OVER 안에 ORDER BY가 없음) 오류가 나요.

```sql
-- 오류: RATIO_TO_REPORT에는 ORDER BY를 쓸 수 없어요 (ORA-30487)
SELECT 이름, RATIO_TO_REPORT(급여) OVER (ORDER BY 급여) FROM 사원;
-- 오류: NTILE에 ORDER BY가 없어요 (ORA-30485)
SELECT 이름, NTILE(3) OVER () FROM 사원;
```

**RATIO_TO_REPORT는 NULL을 합계에서 빼요.** 커미션으로 비율을 구하면 NULL이 아닌 네 명의 합 1000이 분모가 되어, 이지은(300)의 비율은 0.3이에요. 커미션이 NULL인 행은 비율도 NULL이에요.

**NTILE은 남는 행을 앞 그룹에 줘요.** 뒤 그룹에 몰아주거나 마지막 그룹을 비우지 않아요. 행 수보다 n이 크면 행마다 그룹이 하나씩 생기고, 남는 번호의 그룹은 아예 나타나지 않아요. 8명에 NTILE(10)을 쓰면 그룹 번호는 1부터 8까지만 나와요.

**NTILE은 동점을 신경 쓰지 않아요.** 정해진 인원대로 자르기 때문에, 급여가 같아도 다른 그룹으로 나뉠 수 있어요. `NTILE(3) OVER (ORDER BY 급여, 사번)`처럼 급여가 낮은 순서로 나누면 윤서연, 오지민, 이지은이 1번 그룹이 되고, 이지은과 급여가 같은 정하늘은 2번 그룹으로 넘어가요. 사번을 두 번째 기준으로 넣어서 이지은이 앞에 섰고, 급여만 기준이었다면 두 사람 중 누가 1번 그룹에 들어갈지 정해지지 않아요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

예시 표에 PERCENT_RANK나 CUME_DIST를 적용한 결과 값을 묻는 문제가 많고, 동점 행이 있는 표가 자주 나와요. 이때는 PERCENT_RANK는 RANK로 순위를 먼저 구해 공식에 넣고, CUME_DIST는 동점까지 포함해 쌓인 행 수를 세면 돼요. NTILE은 그룹별 인원을 묻는 문제가 대부분이라서, 행 수를 n으로 나눈 몫과 나머지를 구해 나머지만큼 앞 그룹에 하나씩 더하면 풀려요.""",
    "checkQuestions": [
        question(1, "(순위 - 1) / (행 수 - 1)로 계산해서, 첫 행은 0이고 마지막 행은 1이 되는 함수는 무엇인가요?", "definition",
                 "PERCENT_RANK는 순위를 0부터 1 사이로 바꾼 값이에요. CUME_DIST는 쌓인 행 수를 전체 행 수로 나누므로 0이 나오지 않아요.",
                 [choice("A", "CUME_DIST", rationale="CUME_DIST는 현재 행까지 쌓인 행 수를 전체 행 수로 나눠서 첫 행도 0이 아니에요."),
                  choice("B", "PERCENT_RANK", True, "순위로 계산하는 백분위 순위예요."),
                  choice("C", "RATIO_TO_REPORT", rationale="RATIO_TO_REPORT는 현재 값을 묶음 합계로 나눈 비율이에요."),
                  choice("D", "NTILE", rationale="NTILE은 0과 1 사이 값이 아니라 그룹 번호를 돌려줘요.")]),
        question(2, "아래 사원 표에 다음 SQL을 실행하면 이지은(커미션 300) 행의 비율은 얼마인가요?\n\n" + EMPLOYEE_COMMISSION_TABLE, "confusing",
                 "RATIO_TO_REPORT는 NULL을 합계에서 빼므로 분모는 300 + 0 + 500 + 200 = 1000이에요. 그래서 이지은의 비율은 300 / 1000 = 0.3이에요.",
                 [choice("A", "0.3", True, "NULL이 아닌 커미션의 합 1000으로 나눈 값이에요."),
                  choice("B", "NULL", rationale="NULL은 합계에서 빠질 뿐이고, 커미션이 있는 이지은의 비율은 계산돼요."),
                  choice("C", "300", rationale="RATIO_TO_REPORT는 원래 값이 아니라 합계 대비 비율을 돌려줘요."),
                  choice("D", "1", rationale="1은 묶음에 값이 하나뿐일 때 나오고, 여기서는 합계 1000으로 나눠요.")],
                 stem_sql=RATIO_STEM_SQL),
        question(3, "20번 부서 사원은 이지은(급여 2500), 박서준(2800), 정하늘(2500) 세 명이에요. 다음 SQL을 실행하면 이지은 행의 누적비율은 얼마인가요?", "small-example",
                 "CUME_DIST는 동점 행까지 함께 세요. 급여가 2500 이하인 행은 이지은과 정하늘 두 명이라서 2 / 3 = 0.67이에요.",
                 [choice("A", "0.33", rationale="동점인 정하늘도 함께 세므로 1 / 3이 아니에요."),
                  choice("B", "0", rationale="0에서 시작하는 것은 PERCENT_RANK이고, CUME_DIST는 0이 나오지 않아요."),
                  choice("C", "1", rationale="1은 가장 마지막 값인 박서준의 누적비율이에요."),
                  choice("D", "0.67", True, "동점 두 명을 함께 세어 2 / 3이에요.")],
                 stem_sql=CUME_DIST_STEM_SQL),
        question(4, "30번 부서 사원은 오지민(급여 2200), 한도윤(2700), 최유나(3200) 세 명이에요. 다음 SQL의 결과로 옳은 것은 무엇인가요?", "small-example",
                 "순위는 오지민 1, 한도윤 2, 최유나 3이고, 행 수 - 1 = 2로 나눠요. 그래서 0 / 2, 1 / 2, 2 / 2가 되어 0, 0.5, 1이에요.",
                 [choice("A", "오지민 0.33, 한도윤 0.67, 최유나 1", rationale="쌓인 행 수를 3으로 나눈 CUME_DIST의 결과예요."),
                  choice("B", "오지민 1, 한도윤 2, 최유나 3", rationale="순위를 그대로 적은 것이고, PERCENT_RANK는 0과 1 사이 값이에요."),
                  choice("C", "오지민 0, 한도윤 0.5, 최유나 1", True, "(순위 - 1) / (3 - 1)로 계산한 값이에요."),
                  choice("D", "오지민 0, 한도윤 0.33, 최유나 0.67", rationale="행 수 3이 아니라 행 수 - 1인 2로 나눠야 해요.")],
                 stem_sql=PERCENT_RANK_STEM_SQL),
        question(5, "사원 8명에게 다음 SQL을 실행하면, 1번부터 5번까지 각 그룹의 인원은 어떻게 되나요?", "ntile",
                 "8을 5로 나누면 몫이 1, 나머지가 3이에요. 모든 그룹이 1명씩 받고 남은 3명이 1·2·3번 그룹에 하나씩 더 들어가서 2, 2, 2, 1, 1이 돼요.",
                 [choice("A", "2, 2, 2, 1, 1", True, "남는 3명을 앞 그룹부터 하나씩 더 줘요."),
                  choice("B", "1, 1, 2, 2, 2", rationale="남는 행은 뒤 그룹이 아니라 앞 그룹부터 받아요."),
                  choice("C", "2, 2, 2, 2, 0", rationale="NTILE은 빈 그룹을 만들지 않고 고르게 나눠요."),
                  choice("D", "1, 1, 1, 1, 4", rationale="나머지를 마지막 그룹에 몰아주지 않아요.")],
                 stem_sql=NTILE_STEM_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 결과 표
        RATIO_TO_REPORT_EXAMPLE.check,
        SMALL_DISTRIBUTION_EXAMPLE.check,
        FULL_DISTRIBUTION_EXAMPLE.check,
        NTILE_EXAMPLE.check,
        # 본문 설명: 급여 / SUM OVER 와 같음, 오류 2개, NTILE(5)·NTILE(10) 그룹 인원, 오름차순 NTILE(3) 동점 분리
        sql_check("SELECT 이름, ROUND(급여 / SUM(급여) OVER (PARTITION BY 부서번호), 2) FROM 사원 WHERE 부서번호 = 20",
                  [["이지은", 0.32], ["박서준", 0.36], ["정하늘", 0.32]]),
        sql_error_check("SELECT 이름, RATIO_TO_REPORT(급여) OVER (ORDER BY 급여) FROM 사원", "ORA-30487"),
        sql_error_check("SELECT 이름, NTILE(3) OVER () FROM 사원", "ORA-30485"),
        sql_error_check("SELECT 이름, PERCENT_RANK() OVER () FROM 사원", "ORA-30485"),
        sql_error_check("SELECT 이름, CUME_DIST() OVER () FROM 사원", "ORA-30485"),
        sql_check("SELECT 그룹, COUNT(*) FROM (SELECT NTILE(5) OVER (ORDER BY 급여 DESC, 사번) AS 그룹 FROM 사원) GROUP BY 그룹 ORDER BY 그룹",
                  [[1, 2], [2, 2], [3, 2], [4, 1], [5, 1]], is_ordered=True),
        sql_check("SELECT MIN(그룹), MAX(그룹), COUNT(DISTINCT 그룹) FROM (SELECT NTILE(10) OVER (ORDER BY 급여 DESC, 사번) AS 그룹 FROM 사원)",
                  [[1, 8, 8]]),
        sql_check("SELECT 이름, NTILE(3) OVER (ORDER BY 급여, 사번) FROM 사원 ORDER BY 급여, 사번",
                  [["윤서연", 1], ["오지민", 1], ["이지은", 1], ["정하늘", 2], ["한도윤", 2], ["박서준", 2], ["김민수", 3], ["최유나", 3]],
                  is_ordered=True),
        # 확인 문제 2·3·4·5번 stemSql
        sql_check(RATIO_STEM_SQL, [["김민수", None], ["이지은", 0.3], ["박서준", 0], ["최유나", None],
                                   ["정하늘", None], ["한도윤", 0.5], ["오지민", 0.2], ["윤서연", None]]),
        sql_check(CUME_DIST_STEM_SQL, [["이지은", 0.67], ["정하늘", 0.67], ["박서준", 1]]),
        sql_check(PERCENT_RANK_STEM_SQL, [["오지민", 0], ["한도윤", 0.5], ["최유나", 1]]),
        sql_check(NTILE_STEM_SQL, [["최유나", 1], ["김민수", 1], ["박서준", 2], ["한도윤", 2],
                                   ["이지은", 3], ["정하늘", 3], ["오지민", 4], ["윤서연", 5]]),
        # 확인 문제 4번 오답 보기 (CUME_DIST)
        sql_check("SELECT 이름, ROUND(CUME_DIST() OVER (ORDER BY 급여), 2) FROM 사원 WHERE 부서번호 = 30",
                  [["오지민", 0.33], ["한도윤", 0.67], ["최유나", 1]]),
    ],
}
