"""개념: 윈도우 함수 문법 (8단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

# 계산에 쓰는 원본 열 (이 개념의 예시는 모두 이 표로 계산)
EMPLOYEE_BASE_TABLE = to_employee_table_md("사번", "이름", "급여", "부서번호")

# 본문 예시 SQL > 결과 행 (본문 표와 sqlChecks 가 같은 원본을 씀)
GROUP_BY_SUM_SQL = """SELECT 부서번호, SUM(급여) AS 합계
FROM 사원
GROUP BY 부서번호
ORDER BY 부서번호;"""
GROUP_BY_SUM_ROWS = [[10, 3000], [20, 7800], [30, 8100], [None, 2000]]

PARTITION_SUM_SQL = """SELECT 이름, 부서번호, 급여,
       SUM(급여) OVER (PARTITION BY 부서번호) AS 부서합계
FROM 사원
ORDER BY 부서번호, 사번;"""
PARTITION_SUM_ROWS = [
    ["김민수", 10, 3000, 3000], ["이지은", 20, 2500, 7800], ["박서준", 20, 2800, 7800], ["정하늘", 20, 2500, 7800],
    ["최유나", 30, 3200, 8100], ["한도윤", 30, 2700, 8100], ["오지민", 30, 2200, 8100], ["윤서연", None, 2000, 2000],
]

PARTITION_COUNT_SQL = """SELECT 이름, 부서번호,
       COUNT(*) OVER () AS 전체인원,
       COUNT(*) OVER (PARTITION BY 부서번호) AS 부서인원
FROM 사원
ORDER BY 부서번호, 사번;"""
PARTITION_COUNT_ROWS = [
    ["김민수", 10, 8, 1], ["이지은", 20, 8, 3], ["박서준", 20, 8, 3], ["정하늘", 20, 8, 3],
    ["최유나", 30, 8, 3], ["한도윤", 30, 8, 3], ["오지민", 30, 8, 3], ["윤서연", None, 8, 1],
]

# 영업부(30) 3명: 기본 범위 · 앞 1행 · 끝까지 비교
WINDOW_RANGE_SQL = """SELECT 이름, 급여,
       SUM(급여) OVER (ORDER BY 급여) AS 기본,
       SUM(급여) OVER (ORDER BY 급여 ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS 앞한행,
       SUM(급여) OVER (ORDER BY 급여 ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS 끝까지
FROM 사원
WHERE 부서번호 = 30
ORDER BY 급여;"""
WINDOW_RANGE_ROWS = [["오지민", 2200, 2200, 2200, 8100], ["한도윤", 2700, 4900, 4900, 5900], ["최유나", 3200, 8100, 5900, 3200]]

# 개발부(20) 급여 2500 동점 2명: 기본 범위(RANGE)라 누적이 같음
DEFAULT_TIE_SQL = """SELECT 이름, 급여, SUM(급여) OVER (ORDER BY 급여) AS 누적
FROM 사원
WHERE 부서번호 = 20
ORDER BY 급여, 사번;"""
DEFAULT_TIE_ROWS = [["이지은", 2500, 5000], ["정하늘", 2500, 5000], ["박서준", 2800, 7800]]

INLINE_VIEW_SQL = """SELECT 이름, 급여, 순위
FROM (SELECT 이름, 급여, RANK() OVER (ORDER BY 급여 DESC) AS 순위
      FROM 사원)
WHERE 순위 <= 3
ORDER BY 순위;"""
INLINE_VIEW_ROWS = [["최유나", 3200, 1], ["김민수", 3000, 2], ["박서준", 2800, 3]]

GROUP_RANK_SQL = """SELECT 부서번호, SUM(급여) AS 합계,
       RANK() OVER (ORDER BY SUM(급여) DESC) AS 순위
FROM 사원
GROUP BY 부서번호
ORDER BY 순위;"""
GROUP_RANK_ROWS = [[30, 8100, 1], [20, 7800, 2], [10, 3000, 3], [None, 2000, 4]]

# 확인 문제 5번 보기 (오류 1개, 정상 3개)
CHOICE_INLINE_VIEW_SQL = "SELECT 이름 FROM (SELECT 이름, RANK() OVER (ORDER BY 급여 DESC) AS 순위 FROM 사원) WHERE 순위 = 1"
CHOICE_WHERE_SQL = "SELECT 이름 FROM 사원 WHERE RANK() OVER (ORDER BY 급여 DESC) = 1"
CHOICE_GROUP_BY_SQL = "SELECT 부서번호, RANK() OVER (ORDER BY SUM(급여) DESC) FROM 사원 GROUP BY 부서번호"
CHOICE_ORDER_BY_SQL = "SELECT 이름 FROM 사원 ORDER BY RANK() OVER (ORDER BY 급여 DESC), 사번"

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
GROUP_BY_SUM_EXAMPLE = sql_example(GROUP_BY_SUM_SQL, ("부서번호", "합계"), GROUP_BY_SUM_ROWS)
PARTITION_SUM_EXAMPLE = sql_example(PARTITION_SUM_SQL, ("이름", "부서번호", "급여", "부서합계"), PARTITION_SUM_ROWS)
PARTITION_COUNT_EXAMPLE = sql_example(PARTITION_COUNT_SQL, ("이름", "부서번호", "전체인원", "부서인원"), PARTITION_COUNT_ROWS)
WINDOW_RANGE_EXAMPLE = sql_example(WINDOW_RANGE_SQL, ("이름", "급여", "기본", "앞한행", "끝까지"), WINDOW_RANGE_ROWS)
DEFAULT_TIE_EXAMPLE = sql_example(DEFAULT_TIE_SQL, ("이름", "급여", "누적"), DEFAULT_TIE_ROWS)
INLINE_VIEW_EXAMPLE = sql_example(INLINE_VIEW_SQL, ("이름", "급여", "순위"), INLINE_VIEW_ROWS)
GROUP_RANK_EXAMPLE = sql_example(GROUP_RANK_SQL, ("부서번호", "합계", "순위"), GROUP_RANK_ROWS)

CONCEPT = {
    "tagKey": "window-syntax",
    "topicCode": "sql_window",
    "sortOrder": 1,
    "title": "윈도우 함수 문법",
    "summary": "행을 줄이지 않고, 각 행 옆에 묶음별 계산값을 붙이는 함수예요",
    "coreMd": (
        "- 윈도우 함수는 GROUP BY와 달리 **행을 줄이지 않고**, 각 행 옆에 계산한 값을 붙여요.\n"
        "- 모양은 `함수() OVER (PARTITION BY 열 ORDER BY 열 윈도우 절)`이고, 세 부분은 문법상 생략할 수 있어요.\n"
        "- 다만 순위 함수처럼 OVER 안에 ORDER BY가 꼭 있어야 하는 함수도 있어요.\n"
        "- ORDER BY만 쓰고 윈도우 절을 빼면 `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`가 기본이라 **누적값**이 나와요.\n"
        "- 윈도우 함수는 WHERE 절에 쓸 수 없어서, **인라인 뷰**로 감싼 뒤 바깥 WHERE에서 걸러요."
    ),
    "detailMd": f"""## GROUP BY로는 안 되는 일 — 행을 남긴 채 합계 붙이기 {{#why}}

사원마다 자기 급여와 부서의 급여 합계를 한 줄에 나란히 보고 싶다고 해 봐요. GROUP BY는 같은 부서의 행을 한 행으로 합쳐 버려서, 합계는 나와도 그 안에 누가 있었는지는 사라져요.

예시는 사원 여덟 명의 네 열로 계산해요. 부서번호 10은 기획부, 20은 개발부, 30은 영업부이고, 부서번호가 NULL인 윤서연은 아직 부서가 없어요.

{EMPLOYEE_BASE_TABLE}

{GROUP_BY_SUM_EXAMPLE.markdown}

사원 8명이 4행으로 줄었고, GROUP BY에 없는 이름 열은 SELECT 절에 넣을 수도 없어요. 윈도우 함수를 쓰면 8명이 그대로 남고, 각 행 옆에 그 행이 속한 부서의 합계가 붙어요.

{PARTITION_SUM_EXAMPLE.markdown}

같은 개발부인 이지은, 박서준, 정하늘은 모두 7800을 받았어요. 부서가 없는 윤서연은 NULL끼리 한 묶음이 되어 자기 급여 2000을 받았어요.

## 한 줄 정의 — OVER 괄호 안의 세 부분 {{#definition}}

| 용어 | 뜻 |
|---|---|
| 윈도우 함수 (Window Function) | 여러 행을 함께 보고 계산한 값을, 행을 줄이지 않은 채 각 행에 하나씩 붙이는 함수예요 |
| 윈도우 | 계산할 때 들여다보는 행의 범위예요. 창문이라는 뜻이에요 |
| 분석 함수 (Analytic Function) | Oracle 문서에서 윈도우 함수를 부르는 이름이에요 |

함수 뒤에 `OVER`를 붙이고, 괄호 안에 세 부분을 적어요.

```sql
-- 문법
SELECT 열, 함수(인자) OVER (PARTITION BY 묶을 열
                           ORDER BY 정렬할 열
                           윈도우 절)
FROM 테이블;
```

| 부분 | 하는 일 | 생략하면 |
|---|---|---|
| PARTITION BY | 행을 묶음(파티션)으로 나눠요 | 전체 행이 한 묶음이 돼요 |
| ORDER BY | 묶음 안에서 행의 순서를 정해요 | 순위 함수처럼 순서가 필요한 함수는 오류가 나요 |
| 윈도우 절 | 계산에 넣을 행의 범위를 정해요 | ORDER BY가 있으면 RANGE 기준 첫 행~현재 행, 없으면 묶음 전체예요 |

## 네 종류 — 순위·집계·행 순서·비율 {{#kinds}}

SQLD는 윈도우 함수를 **네 종류**로 나눠서 물어요. 이 단원의 다음 개념들이 한 종류씩 다뤄요.

| 종류 | 함수 |
|---|---|
| 순위 함수 | RANK, DENSE_RANK, ROW_NUMBER |
| 집계 함수 | SUM, AVG, COUNT, MAX, MIN |
| 행 순서 함수 | FIRST_VALUE, LAST_VALUE, LAG, LEAD |
| 비율 함수 | RATIO_TO_REPORT, PERCENT_RANK, CUME_DIST, NTILE |

## PARTITION BY와 GROUP BY — 묶는 방식은 같고 행 수가 달라요 {{#partition}}

| 비교 | GROUP BY | PARTITION BY |
|---|---|---|
| 쓰는 자리 | GROUP BY 절 | OVER 괄호 안 |
| 결과 행 수 | 묶음마다 한 행 | 원래 행 수 그대로 |
| SELECT에 넣을 수 있는 열 | 묶음 기준 열과 집계 결과 | 어떤 열이든 |
| NULL 값 | NULL끼리 한 그룹 | NULL끼리 한 묶음 |

PARTITION BY를 아예 빼면 테이블 전체가 한 묶음이 돼요. 같은 `COUNT(*)`에 PARTITION BY를 빼거나 넣으면 아래처럼 달라져요.

{PARTITION_COUNT_EXAMPLE.markdown}

`OVER ()`처럼 괄호를 비우면 모든 행에 전체 인원 8이 붙어요. `PARTITION BY 부서번호`를 넣으면 자기 부서의 인원이 붙고, 윤서연은 혼자 한 묶음이 돼요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| PARTITION BY를 쓰면 GROUP BY처럼 결과 행 수가 줄어요 | X | PARTITION BY는 계산 범위만 나누고 행은 모두 남겨요 |
| SUM(급여) OVER ()는 모든 행에 테이블 전체 합을 붙여요 | O | 괄호를 비우면 전체 행이 한 묶음이고, 범위도 묶음 전체예요 |

## 윈도우 절 — 계산에 넣을 행의 범위 {{#window-clause}}

OVER 안의 ORDER BY가 묶음 안에서 행을 줄 세우면, 윈도우 절은 현재 행을 기준으로 어디부터 어디까지 계산할지 정해요. 모양은 `ROWS BETWEEN 시작 AND 끝`이나 `RANGE BETWEEN 시작 AND 끝`이에요.

| 용어 | 뜻 |
|---|---|
| ROWS | 행을 한 줄씩 세어서 범위를 정해요 |
| RANGE | ORDER BY 열의 값을 기준으로 범위를 정해서, 값이 같은 행을 한꺼번에 넣어요 |
| UNBOUNDED PRECEDING | 묶음의 첫 행이에요. UNBOUNDED는 "끝없이", PRECEDING은 "앞선"이라는 뜻이고, 시작 자리에만 써요 |
| n PRECEDING | 현재 행보다 n만큼 앞이에요 |
| CURRENT ROW | 현재 행이에요 |
| n FOLLOWING | 현재 행보다 n만큼 뒤예요. FOLLOWING은 "뒤따르는"이라는 뜻이에요 |
| UNBOUNDED FOLLOWING | 묶음의 마지막 행이고, 끝 자리에만 써요 |

영업부 세 명으로 범위만 바꿔 봤어요. 세 열 모두 급여 합계인데, 계산에 넣는 행이 서로 달라요.

{WINDOW_RANGE_EXAMPLE.markdown}

| 열 | 계산 범위 | 그래서 나온 값 |
|---|---|---|
| 기본 | 윈도우 절 없음, 곧 RANGE 첫 행~현재 행 | 누적 합 |
| 앞한행 | ROWS 바로 앞 행~현재 행 | 두 행의 합 |
| 끝까지 | ROWS 현재 행~마지막 행 | 남은 행의 합 |

BETWEEN을 빼고 `ROWS 1 PRECEDING`처럼 시작만 적으면 끝은 CURRENT ROW로 정해져요. 그래서 `앞한행`과 같은 결과가 나와요.

## 쓸 수 있는 자리 — SELECT 절과 ORDER BY 절뿐 {{#position}}

| 단계 | 내용 |
|---|---|
| FROM | 테이블에서 행을 가져와요 |
| WHERE | 조건으로 행을 걸러요 |
| GROUP BY | 행을 그룹으로 묶어요 |
| HAVING | 그룹을 조건으로 걸러요 |
| 윈도우 함수 | 남은 행으로 SELECT 절의 윈도우 함수를 계산해요 |
| ORDER BY | 결과를 정렬해요 |

윈도우 함수는 행을 고르고 묶는 일이 다 끝난 뒤에 계산돼요. 그래서 WHERE·GROUP BY·HAVING 절에 쓰면 ORA-30483(윈도우 함수를 쓸 수 없는 자리) 오류가 나요.

```sql
-- 오류: 윈도우 함수는 WHERE 절에 쓸 수 없어요 (ORA-30483)
SELECT 이름, 급여 FROM 사원 WHERE RANK() OVER (ORDER BY 급여 DESC) <= 3;
```

결과로 거르려면 윈도우 함수를 계산한 SELECT 문을 인라인 뷰(FROM 절 안에 넣은 서브쿼리)로 감싸고, 바깥 WHERE에서 걸러요. RANK는 순위를 매기는 함수로 다음 개념에서 다루고, 거르는 방법은 윈도우 함수로 TOP N 개념에서 더 다뤄요.

{INLINE_VIEW_EXAMPLE.markdown}

반대로 GROUP BY보다 나중에 계산되기 때문에, 집계 결과를 OVER 안에서 쓸 수 있어요. 아래는 부서별 합계에 순위를 매긴 예시예요.

{GROUP_RANK_EXAMPLE.markdown}

## 자주 헷갈리는 점 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| OVER 안에 ORDER BY를 더해도 SUM은 묶음 전체 합이에요 | ORDER BY를 넣는 순간 기본 범위가 첫 행~현재 행이 되어 누적 합이 나와요. 전체 합이 필요하면 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING을 직접 적어요 |
| ORDER BY만 쓸 때 기본 범위는 ROWS예요 | 기본은 RANGE예요. 그래서 ORDER BY 값이 같은 행은 누적값도 같아요 |
| 윈도우 함수는 WHERE 절의 조건으로 쓸 수 있어요 | WHERE보다 나중에 계산돼서 ORA-30483 오류가 나요. 인라인 뷰로 감싼 뒤 바깥에서 걸러요 |
| PARTITION BY를 빼면 오류가 나요 | 전체 행이 한 묶음이 될 뿐이에요 |
| 순위 함수도 OVER 안의 ORDER BY를 생략할 수 있어요 | 순위 함수, LAG·LEAD, PERCENT_RANK·CUME_DIST·NTILE은 ORDER BY가 없으면 ORA-30485(OVER 안에 ORDER BY가 없음) 오류가 나요 |
| 윈도우 절은 어떤 윈도우 함수에나 붙일 수 있어요 | 집계 함수와 FIRST_VALUE·LAST_VALUE에만 써요. RANK 같은 순위 함수에 붙이면 문법 오류가 나요 |
| 범위의 시작과 끝은 순서를 바꿔 적어도 돼요 | 시작이 끝보다 앞이어야 해요. 거꾸로 적으면 ORA-30486(윈도우 범위가 잘못됨) 오류가 나요 |

급여가 2500으로 같은 이지은과 정하늘은 기본 범위에서 누적 합도 똑같이 5000이에요. 한 줄씩 더했다면 2500, 5000, 7800이 되었을 텐데, RANGE는 값이 같은 행을 한 덩어리로 봐요.

{DEFAULT_TIE_EXAMPLE.markdown}

```sql
-- 오류: 순위 함수에 ORDER BY가 없어요 (ORA-30485)
SELECT 이름, RANK() OVER () FROM 사원;
-- 오류: 순위 함수에는 윈도우 절을 쓸 수 없어요
SELECT 이름, RANK() OVER (ORDER BY 급여 ROWS UNBOUNDED PRECEDING) FROM 사원;
-- 오류: 범위의 끝이 시작보다 앞이에요 (ORA-30486)
SELECT 이름, SUM(급여) OVER (ORDER BY 급여 ROWS BETWEEN CURRENT ROW AND UNBOUNDED PRECEDING) FROM 사원;
```

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| ROWS 1 PRECEDING은 앞 한 행부터 마지막 행까지를 뜻해요 | X | 시작만 적으면 끝은 CURRENT ROW라서, 앞 한 행과 현재 행이에요 |
| 윈도우 함수는 GROUP BY로 만든 합계에 순위를 매길 수 있어요 | O | 윈도우 함수는 GROUP BY가 끝난 결과에 적용돼요 |

## 꼭 외울 것 — OVER 괄호의 기본값 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| 윈도우 함수 결과 행 수 | 원래 행 수 그대로, 줄지 않아요 |
| OVER 안 세 부분 | PARTITION BY, ORDER BY, 윈도우 절 |
| ORDER BY만 쓴 기본 범위 | RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW |
| OVER 안에 ORDER BY 없음 | 묶음 전체가 범위 |
| ROWS와 RANGE | ROWS는 행 개수, RANGE는 값 기준 (동점 함께) |
| 시작만 적은 `ROWS 1 PRECEDING` | 끝은 CURRENT ROW |
| 윈도우 함수를 쓰는 절 | SELECT와 ORDER BY만 (WHERE는 ORA-30483) |
| 네 종류 | 순위, 집계, 행 순서, 비율 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

| 나오는 문제 | 푸는 법 |
|---|---|
| GROUP BY와 윈도우 함수의 결과 행 수 비교 | 윈도우 함수는 행을 줄이지 않아요 |
| ORDER BY만 쓴 SUM의 결과 표 채우기 | 누적 합이고, 동점 행끼리는 값이 같아요 |
| 오류가 나는 SQL 고르기 | WHERE 절의 윈도우 함수, ORDER BY 없는 순위 함수를 찾아요 |
| 바른 윈도우 절 고르기 | ROWS·RANGE 뒤에 시작이 끝보다 앞인지 봐요 |
| 함수를 네 종류로 나누기 | 순위, 집계, 행 순서, 비율 표를 떠올려요 |""",
    "checkQuestions": [
        question(1, "윈도우 함수에 대한 설명으로 옳은 것은 무엇인가요?", "definition",
                 "윈도우 함수는 행 수를 그대로 두고 계산값을 각 행에 붙여요. PARTITION BY는 생략할 수 있고, WHERE 절에는 쓸 수 없어요.",
                 [choice("A", "GROUP BY처럼 묶음마다 한 행으로 줄여서 보여 준다", rationale="윈도우 함수는 행을 줄이지 않고 모두 남겨요."),
                  choice("B", "행을 줄이지 않고, 각 행 옆에 여러 행을 보고 계산한 값을 붙인다", True, "윈도우 함수의 정의예요."),
                  choice("C", "WHERE 절의 조건으로 쓸 수 있다", rationale="윈도우 함수는 WHERE보다 나중에 계산되어 WHERE 절에 쓰면 오류가 나요."),
                  choice("D", "OVER 안에 PARTITION BY를 반드시 적어야 한다", rationale="PARTITION BY를 빼면 전체 행이 한 묶음이 될 뿐 오류가 나지 않아요.")]),
        question(2, "회사 사원 여덟 명의 표(부서번호는 10·20·30·NULL)에 다음 SQL을 실행하면 몇 행이 나오나요?", "partition",
                 "PARTITION BY는 묶음을 계산 범위로만 쓰고 행을 줄이지 않아요. 그래서 사원 8명이 모두 남고, 각 행에 자기 부서의 합계가 붙어요.",
                 [choice("A", "4행", rationale="묶음마다 한 행이 남는 것은 GROUP BY이고, PARTITION BY는 행을 줄이지 않아요."),
                  choice("B", "3행", rationale="부서번호가 NULL인 행도 한 묶음이 되어 결과에 남아요."),
                  choice("C", "1행", rationale="OVER가 붙은 SUM은 전체 합계 한 행이 아니라 행마다 값을 붙여요."),
                  choice("D", "8행", True, "사원 8명이 모두 남고 각 행에 부서 합계가 붙어요.")],
                 stem_sql="SELECT 이름, SUM(급여) OVER (PARTITION BY 부서번호) AS 부서합계 FROM 사원;"),
        question(3, "`SUM(급여) OVER (ORDER BY 급여)`처럼 OVER 안에 ORDER BY만 쓰고 윈도우 절을 생략하면, 계산 범위는 무엇이 되나요?", "window-clause",
                 "ORDER BY가 있고 윈도우 절이 없으면 첫 행부터 현재 행까지가 기본 범위예요. 이때 기준은 ROWS가 아니라 RANGE라서 값이 같은 행도 함께 들어가요.",
                 [choice("A", "RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW", True, "ORDER BY만 썼을 때의 기본 범위예요."),
                  choice("B", "ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW", rationale="기본 범위는 ROWS가 아니라 RANGE예요."),
                  choice("C", "RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING", rationale="묶음 전체는 ORDER BY까지 생략했을 때의 범위예요."),
                  choice("D", "ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING", rationale="기본 범위는 현재 행부터 끝까지가 아니라 처음부터 현재 행까지예요.")]),
        question(4, "20번 부서 사원은 이지은(급여 2500), 박서준(2800), 정하늘(2500) 세 명이에요. 다음 SQL을 실행했을 때 이지은과 정하늘의 누적 값으로 옳은 것은 무엇인가요?", "confusing",
                 "ORDER BY만 쓰면 기본 범위가 RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW예요. RANGE는 급여가 같은 행을 한꺼번에 넣으므로 두 사람 모두 2500 + 2500 = 5000이에요.",
                 [choice("A", "이지은 2500, 정하늘 5000", rationale="한 줄씩 더하는 ROWS 방식의 결과이고, 기본 범위는 RANGE예요."),
                  choice("B", "두 사람 모두 2500", rationale="값이 같은 상대 행도 범위에 들어가서 자기 급여만 남지 않아요."),
                  choice("C", "두 사람 모두 5000", True, "값이 같은 두 행이 한꺼번에 범위에 들어가요."),
                  choice("D", "두 사람 모두 7800", rationale="7800은 박서준까지 더한 부서 전체 합이에요.")],
                 stem_sql="SELECT 이름, SUM(급여) OVER (ORDER BY 급여) AS 누적 FROM 사원 WHERE 부서번호 = 20;"),
        question(5, "다음 중 실행하면 오류가 나는 SQL은 무엇인가요?", "confusing",
                 "윈도우 함수는 WHERE, GROUP BY, HAVING이 끝난 뒤에 계산되므로 WHERE 절에 쓸 수 없어요. 결과로 거르려면 인라인 뷰로 감싼 뒤 바깥 WHERE에서 걸러요.",
                 [choice("A", CHOICE_INLINE_VIEW_SQL, rationale="인라인 뷰에서 순위를 계산하고 바깥에서 거르는 올바른 방법이에요."),
                  choice("B", CHOICE_WHERE_SQL, True, "윈도우 함수를 WHERE 절에 써서 ORA-30483(윈도우 함수를 쓸 수 없는 자리) 오류가 나요."),
                  choice("C", CHOICE_GROUP_BY_SQL, rationale="윈도우 함수는 GROUP BY 뒤에 계산되므로 집계 결과로 순위를 매길 수 있어요."),
                  choice("D", CHOICE_ORDER_BY_SQL, rationale="윈도우 함수는 ORDER BY 절에 쓸 수 있어요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 결과 표
        GROUP_BY_SUM_EXAMPLE.check,
        PARTITION_SUM_EXAMPLE.check,
        PARTITION_COUNT_EXAMPLE.check,
        WINDOW_RANGE_EXAMPLE.check,
        DEFAULT_TIE_EXAMPLE.check,
        INLINE_VIEW_EXAMPLE.check,
        GROUP_RANK_EXAMPLE.check,
        # 본문 설명 (ROWS 1 PRECEDING = BETWEEN 1 PRECEDING AND CURRENT ROW, ORDER BY 후 전체 합은 UNBOUNDED FOLLOWING)
        sql_check("SELECT 이름, SUM(급여) OVER (ORDER BY 급여 ROWS 1 PRECEDING) FROM 사원 WHERE 부서번호 = 30 ORDER BY 급여",
                  [["오지민", 2200], ["한도윤", 4900], ["최유나", 5900]], is_ordered=True),
        sql_check("SELECT 이름, SUM(급여) OVER (PARTITION BY 부서번호 ORDER BY 급여 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "
                  "FROM 사원 WHERE 부서번호 = 30 ORDER BY 급여",
                  [["오지민", 8100], ["한도윤", 8100], ["최유나", 8100]], is_ordered=True),
        sql_error_check("SELECT 이름, 급여 FROM 사원 WHERE RANK() OVER (ORDER BY 급여 DESC) <= 3", "ORA-30483"),
        sql_error_check("SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 HAVING RANK() OVER (ORDER BY COUNT(*)) = 1", "ORA-30483"),
        sql_error_check("SELECT 이름, RANK() OVER () FROM 사원", "ORA-30485"),
        sql_error_check("SELECT 이름, RANK() OVER (ORDER BY 급여 ROWS UNBOUNDED PRECEDING) FROM 사원", "ORA-00907"),
        sql_error_check("SELECT 이름, SUM(급여) OVER (ORDER BY 급여 ROWS BETWEEN CURRENT ROW AND UNBOUNDED PRECEDING) FROM 사원", "ORA-30486"),
        # 본문 용어 카드: UNBOUNDED FOLLOWING 은 끝 자리에만 (시작 자리면 범위 오류)
        sql_error_check("SELECT 이름, SUM(급여) OVER (ORDER BY 급여 ROWS BETWEEN UNBOUNDED FOLLOWING AND CURRENT ROW) FROM 사원", "ORA-30486"),
        # 확인 문제 2·4번 stemSql
        sql_check("SELECT 이름, SUM(급여) OVER (PARTITION BY 부서번호) AS 부서합계 FROM 사원;",
                  [[name, total] for name, _, _, total in PARTITION_SUM_ROWS]),
        sql_check("SELECT 이름, SUM(급여) OVER (ORDER BY 급여) AS 누적 FROM 사원 WHERE 부서번호 = 20;",
                  [["이지은", 5000], ["정하늘", 5000], ["박서준", 7800]]),
        # 확인 문제 3번: 기본 범위 = RANGE 처음~현재 (ROWS 와는 동점에서 다름, ORDER BY 없으면 전체)
        sql_check("SELECT 이름, SUM(급여) OVER (ORDER BY 급여) AS 기본, "
                  "SUM(급여) OVER (ORDER BY 급여 RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 범위 "
                  "FROM 사원 WHERE 부서번호 = 20 ORDER BY 급여, 사번",
                  [["이지은", 5000, 5000], ["정하늘", 5000, 5000], ["박서준", 7800, 7800]], is_ordered=True),
        sql_check("SELECT 급여, SUM(급여) OVER (ORDER BY 급여, 사번 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) "
                  "FROM 사원 WHERE 부서번호 = 20 ORDER BY 급여, 사번",
                  [[2500, 2500], [2500, 5000], [2800, 7800]], is_ordered=True),
        sql_check("SELECT 이름, SUM(급여) OVER () FROM 사원 WHERE 부서번호 = 20",
                  [["이지은", 7800], ["정하늘", 7800], ["박서준", 7800]]),
        # 확인 문제 5번 보기
        sql_check(CHOICE_INLINE_VIEW_SQL, [["최유나"]]),
        sql_error_check(CHOICE_WHERE_SQL, "ORA-30483"),
        sql_check(CHOICE_GROUP_BY_SQL, [[30, 1], [20, 2], [10, 3], [None, 4]]),
        sql_check(CHOICE_ORDER_BY_SQL, [["최유나"], ["김민수"], ["박서준"], ["한도윤"], ["이지은"], ["정하늘"], ["오지민"], ["윤서연"]],
                  is_ordered=True),
    ],
}
