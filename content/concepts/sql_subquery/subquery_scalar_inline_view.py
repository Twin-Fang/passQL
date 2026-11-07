"""개념: 스칼라 서브쿼리와 인라인 뷰 (6단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import DEPARTMENT_TABLE_MD, to_employee_table_md

# 이 개념의 계산에 쓰는 열 전부 (직급, 급여, 부서번호)
EMPLOYEE_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
SCALAR_DEPARTMENT_NAME_EXAMPLE = sql_example(
    """SELECT e.이름,
       (SELECT d.부서명 FROM 부서 d WHERE d.부서번호 = e.부서번호) AS 부서명
FROM 사원 e;""",
    ("이름", "부서명"),
    [["김민수", "기획부"], ["이지은", "개발부"], ["박서준", "개발부"], ["최유나", "영업부"],
     ["정하늘", "개발부"], ["한도윤", "영업부"], ["오지민", "영업부"], ["윤서연", None]],
    is_ordered=False)
INLINE_VIEW_JOIN_EXAMPLE = sql_example(
    """SELECT e.이름, e.급여, a.평균급여
FROM 사원 e
JOIN (SELECT 부서번호, AVG(급여) AS 평균급여
      FROM 사원
      GROUP BY 부서번호) a
  ON e.부서번호 = a.부서번호
WHERE e.급여 > a.평균급여;""",
    ("이름", "급여", "평균급여"), [["박서준", 2800, 2600], ["최유나", 3200, 2700]], is_ordered=False)
INLINE_VIEW_TOP_EXAMPLE = sql_example(
    """SELECT 이름, 급여
FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC)
WHERE ROWNUM <= 3;""",
    ("이름", "급여"), [["최유나", 3200], ["김민수", 3000], ["박서준", 2800]])
WITH_CLAUSE_EXAMPLE = sql_example(
    """WITH 부서평균 AS (
  SELECT 부서번호, AVG(급여) AS 평균급여
  FROM 사원
  GROUP BY 부서번호
)
SELECT e.이름, e.급여, a.평균급여
FROM 사원 e
JOIN 부서평균 a ON e.부서번호 = a.부서번호
WHERE e.급여 > a.평균급여;""",
    ("이름", "급여", "평균급여"), [["박서준", 2800, 2600], ["최유나", 3200, 2700]], is_ordered=False)
# 집계 함수 스칼라 서브쿼리: 0행이어도 한 행 (COUNT 0, MAX NULL)
SCALAR_AGGREGATE_EXAMPLE = sql_example(
    """SELECT d.부서명,
       (SELECT COUNT(*) FROM 사원 e WHERE e.부서번호 = d.부서번호) AS 사원수,
       (SELECT MAX(e.급여) FROM 사원 e WHERE e.부서번호 = d.부서번호) AS 최고급여
FROM 부서 d;""",
    ("부서명", "사원수", "최고급여"),
    [["기획부", 1, 3000], ["개발부", 3, 2800], ["영업부", 3, 3200], ["인사부", 0, None]], is_ordered=False)
# 정렬 전 ROWNUM (읽힌 순서 = 넣은 순서)
ROWNUM_BEFORE_ORDER_EXAMPLE = sql_example(
    """SELECT 이름, 급여
FROM 사원
WHERE ROWNUM <= 3
ORDER BY 급여 DESC;""",
    ("이름", "급여"), [["김민수", 3000], ["박서준", 2800], ["이지은", 2500]])

CONCEPT = {
    "tagKey": "subquery-scalar-inline-view",
    "topicCode": "sql_subquery",
    "sortOrder": 4,
    "title": "스칼라 서브쿼리와 인라인 뷰",
    "summary": "SELECT 절에서 값 하나를 가져오는 서브쿼리와 FROM 절에서 표처럼 쓰는 서브쿼리예요",
    "coreMd": (
        "- 스칼라 서브쿼리는 **한 행 한 열**을 돌려주고, 0행이면 NULL, 2행 이상이면 오류예요.\n"
        "- 인라인 뷰는 FROM 절의 서브쿼리이고, 바깥에서는 인라인 뷰가 **내보낸 열만** 쓸 수 있어요.\n"
        "- 인라인 뷰 **안에서 정렬**하고 바깥에서 `ROWNUM <= N`으로 잘라야 TOP N이 맞아요.\n"
        "- `WITH 이름 AS (서브쿼리)`로 이름을 붙이면 본문에서 그 이름을 표처럼 써요.\n"
        "- Oracle은 인라인 뷰 별칭 앞에 **AS를 쓸 수 없어요**."
    ),
    "detailMd": f"""## 값 하나 붙이기와 결과 다시 가공하기: 두 가지 쓰임 {{#why}}

사원 이름 옆에 부서명 하나만 붙이고 싶을 때는 SELECT 절 안에서 바로 찾아오는 편이 읽기 쉬워요. 부서별 평균을 구한 뒤 다시 비교하거나 정렬한 뒤 세 명만 자를 때는, 한 번 만든 결과를 표처럼 놓고 SELECT를 한 번 더 해야 해요.

| 하고 싶은 일 | 쓰는 것 | 놓이는 자리 |
|---|---|---|
| 행마다 값 하나를 붙여요 | 스칼라 서브쿼리 | 주로 SELECT 절 |
| 결과를 표처럼 놓고 다시 가공해요 | 인라인 뷰 | FROM 절 |
| 조건에 쓸 값을 구해요 | 중첩 서브쿼리 | WHERE 절, HAVING 절 |

예시는 모두 아래 두 표로 계산해요. 윤서연(1008)은 부서번호가 NULL이고, 인사부(40번)에는 사원이 없어요.

{EMPLOYEE_TABLE}

{DEPARTMENT_TABLE_MD}

## 스칼라 서브쿼리: 한 행 한 열, 값 하나 {{#scalar}}

| 용어 | 뜻 |
|---|---|
| 스칼라 (Scalar) | "값 하나"라는 뜻이에요 |
| 스칼라 서브쿼리 | 한 행 한 열만 돌려주는 서브쿼리예요. 주로 SELECT 절에 놓여 열 하나처럼 쓰여요 |

{SCALAR_DEPARTMENT_NAME_EXAMPLE.markdown}

서브쿼리가 메인 쿼리의 `e.부서번호`를 쓰니 연관 서브쿼리이기도 해서, 사원마다 부서명을 하나씩 찾아와요. 윤서연은 짝이 되는 부서가 없어 서브쿼리가 0행인데, 스칼라 서브쿼리는 0행이면 NULL을 돌려주므로 행은 남고 부서명만 NULL이에요.

| 윤서연(부서번호 NULL)의 행 | 결과 |
|---|---|
| 스칼라 서브쿼리 | 남고 부서명은 NULL이에요 |
| 일반 조인 (INNER JOIN) | 짝이 없어서 빠져요 |
| 외부 조인 (OUTER JOIN) | 남고 부서명은 NULL이에요. 짝이 없는 행도 NULL을 채워 남기는 조인이에요 |

스칼라 서브쿼리는 SELECT 절 말고도 값 하나가 들어갈 자리라면 대부분 쓸 수 있어요. WHERE 절의 `급여 > (SELECT AVG(급여) FROM 사원)`도 값 하나를 돌려준다는 점에서 같은 성격이고, `AVG(급여)`는 급여의 평균을 구하는 함수예요.

## 인라인 뷰: FROM 절의 임시 표 {{#inline-view}}

| 용어 | 뜻 |
|---|---|
| 인라인 뷰 (Inline View) | FROM 절에 쓴 서브쿼리예요. 결과가 그 SQL 안에서만 쓰는 임시 표가 돼요 |
| 저장 여부 | 이름에 "뷰"가 들어가지만 데이터베이스에 저장되지 않고, SQL을 실행하는 동안에만 있어요 |
| 열 별칭 | `AVG(급여) AS 평균급여`처럼 붙여야 바깥에서 그 열을 이름으로 부를 수 있어요 |

`GROUP BY 부서번호`는 부서번호가 같은 사원끼리 묶는 절이에요. 괄호 안에서 부서별 평균 급여 표를 만들고, 바깥에서 `a`라는 별칭으로 사원 테이블과 조인해요.

{INLINE_VIEW_JOIN_EXAMPLE.markdown}

결과는 연관 서브쿼리로 "자기 부서 평균보다 급여가 많은 사원"을 찾았을 때와 같아요. 인라인 뷰는 TOP N에도 자주 쓰여서, 안에서 정렬을 끝낸 뒤 바깥에서 ROWNUM(조회된 행에 1부터 붙는 번호)으로 잘라요.

{INLINE_VIEW_TOP_EXAMPLE.markdown}

## WITH 절: 서브쿼리에 이름 붙여 앞으로 빼기 {{#with-clause}}

| 용어 | 뜻 |
|---|---|
| WITH 절 | 서브쿼리에 이름을 붙여 SQL 맨 앞에 따로 꺼내 두는 방법이에요 |
| 공통 테이블 식 (CTE) | Common Table Expression의 줄임말로, WITH 절로 이름 붙인 서브쿼리예요 |
| 서브쿼리 팩토링 (Subquery Factoring) | Oracle 문서에서 쓰는 이름이에요. 서브쿼리를 본문에서 떼어 앞으로 빼낸다는 뜻이에요 |

{WITH_CLAUSE_EXAMPLE.markdown}

인라인 뷰 예시와 같은 두 명이 나와요. `부서평균`은 이 SQL이 실행되는 동안에만 있는 이름이고, 서브쿼리가 길거나 여러 번 쓸 때 빼 두면 한 번 정의한 결과를 이름으로 여러 번 부를 수 있어요.

## 자주 헷갈리는 점: 행 수, 열 범위, TOP N 순서, AS {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| 스칼라 서브쿼리가 0행이면 오류가 나요 | 0행이면 NULL이 돼요. 오류는 2행 이상일 때 ORA-01427(단일행 서브쿼리가 여러 행을 돌려줌), 열이 2개 이상일 때 ORA-00913(값이 너무 많음)이에요 |
| 대상이 없으면 집계 스칼라 서브쿼리도 NULL이에요 | GROUP BY 없는 집계 함수는 대상 행이 없어도 한 행을 돌려줘요. 그 행에 COUNT는 0, MAX는 NULL을 담아요 |
| 인라인 뷰 바깥에서도 원래 테이블의 열을 쓸 수 있어요 | 바깥에게 인라인 뷰는 SELECT 목록의 열만 가진 표예요. 고르지 않은 열을 쓰면 ORA-00904(없는 열 이름) 오류예요 |
| 계산식은 별칭 없이도 바깥에서 별칭처럼 부를 수 있어요 | `AVG(급여)`에 열 별칭을 붙이지 않았으면 바깥에서 `평균급여`로 부를 때 ORA-00904 오류예요 |
| `WHERE ROWNUM <= 3 ORDER BY 급여 DESC`로 상위 3명을 구해요 | ROWNUM은 ORDER BY보다 먼저 붙어서, 정렬 전에 세 행이 먼저 골라져요 |
| 인라인 뷰 안에만 넣으면 ROWNUM과 ORDER BY를 같이 써도 돼요 | 한 SELECT 안에 둘이 있으면 인라인 뷰 안이라도 정렬 전에 잘려요. 정렬하는 SELECT와 자르는 SELECT를 따로 둬요 |
| WHERE 절 서브쿼리 안에서 정렬하면 돼요 | WHERE 절 서브쿼리 안의 ORDER BY는 ORA-00907(오른쪽 괄호가 없음) 오류예요 |
| 인라인 뷰 별칭 앞에도 AS를 쓸 수 있어요 | 열 별칭에는 AS를 써도 되지만, 테이블, 인라인 뷰 별칭 앞에 AS를 쓰면 ORA-00933(SQL 문이 제대로 끝나지 않음) 오류예요 |

```sql
SELECT 이름, (SELECT 이름 FROM 사원 WHERE 부서번호 = 20) FROM 사원;  -- 오류: 20번 부서는 3명이라 세 행이 돌아와요

SELECT e.이름, (SELECT d.부서명, d.지역 FROM 부서 d WHERE d.부서번호 = e.부서번호)
FROM 사원 e;  -- 오류: 서브쿼리가 열 두 개를 돌려줘요
```

COUNT(행 개수)와 MAX(가장 큰 값)처럼 여러 행을 모아 값 하나를 계산하는 함수를 집계 함수라고 해요. 같은 인사부인데 사원수는 0이고 최고급여는 NULL로 갈라져요.

{SCALAR_AGGREGATE_EXAMPLE.markdown}

```sql
SELECT 이름 FROM (SELECT 이름, 급여 FROM 사원) WHERE 직급 = '사원';  -- 오류: 인라인 뷰에 직급 열이 없어요

SELECT 평균급여
FROM (SELECT 부서번호, AVG(급여) FROM 사원 GROUP BY 부서번호);  -- 오류: 평균급여라는 열 별칭이 없어요
```

TOP N 순서는 2단원에서 본 실행 순서로 풀려요. ROWNUM은 WHERE 단계에서 행을 읽어 올 때 붙는 번호예요.

| 단계 | 내용 |
|---|---|
| FROM | 사원 테이블에서 행을 읽어요 |
| WHERE | 읽은 행에 ROWNUM 1, 2, 3을 붙이고 세 행까지만 남겨요 |
| GROUP BY, HAVING | 이 SQL에는 없어요 |
| SELECT | 이름과 급여를 골라요 |
| ORDER BY | 이미 골라 둔 세 행만 정렬해요 |

{ROWNUM_BEFORE_ORDER_EXAMPLE.markdown}

급여 1위 최유나가 빠졌어요. ORDER BY가 없을 때 읽는 순서는 Oracle이 정하므로 보장되지 않고, 이 예시는 표에 넣은 순서대로 읽혀서 김민수, 이지은, 박서준이 골라졌어요.

```sql
SELECT 이름
FROM (SELECT 이름, 급여 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC);  -- 정렬 전에 세 행이 잘려요

SELECT 이름 FROM 사원
WHERE 급여 IN (SELECT 급여 FROM 사원 ORDER BY 급여 DESC) AND ROWNUM <= 3;  -- 오류: WHERE 절 서브쿼리 안에는 ORDER BY를 쓸 수 없어요

SELECT a.이름 FROM (SELECT 이름 FROM 사원) AS a;  -- 오류: 인라인 뷰 별칭 앞에 AS를 썼어요
SELECT a.이름 FROM (SELECT 이름 FROM 사원) a WHERE ROWNUM <= 1;  -- AS 없이 쓰면 김민수가 나와요
```

별칭 자체는 Oracle에서 생략할 수 있지만, 다른 테이블과 조인할 때는 붙여 두는 편이 열을 구분하기 쉬워요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 사원이 없는 부서의 `(SELECT COUNT(*) ...)` 스칼라 서브쿼리는 0을 돌려줘요 | O | 집계 함수는 대상이 없어도 한 행을 만들고, COUNT는 그 행에 0을 담아요 |
| 인라인 뷰는 실행이 끝난 뒤에도 데이터베이스에 남아 다시 쓸 수 있어요 | X | 인라인 뷰는 그 SQL을 실행하는 동안에만 있어요 |
| 스칼라 서브쿼리는 짝이 없는 행을 결과에서 빼요 | X | 0행이면 NULL을 돌려주므로 행은 남아요. 외부 조인과 결과가 같아요 |

## 꼭 외울 것: 행 수와 바깥에서 쓰는 열 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| 스칼라 서브쿼리의 모양 | 한 행 한 열, 곧 값 하나 |
| 스칼라 서브쿼리가 0행 | 오류 없이 NULL이 되고 행은 남아요 |
| 스칼라 서브쿼리가 2행 이상 | ORA-01427(여러 행을 돌려줌) 오류 |
| 스칼라 서브쿼리의 열이 2개 | ORA-00913(값이 너무 많음) 오류 |
| 인라인 뷰 바깥에서 쓰는 열 | 인라인 뷰 SELECT 목록의 열만, 계산식은 열 별칭이 있어야 |
| 정렬 후 TOP N | 인라인 뷰 안에서 ORDER BY, 바깥에서 ROWNUM <= N |
| 인라인 뷰 별칭 앞의 AS | Oracle은 오류, AS는 열 별칭에만 |
| WITH 절 모양 | WITH 이름 AS (서브쿼리), 본문에서 그 이름을 표처럼 |

## 시험에서는 이렇게 나와요: 0행, 2행과 TOP N {{#exam-point}}

스칼라 서브쿼리가 0행이나 2행 이상을 돌려줄 때의 결과를 묻는 문제가 자주 나와요. 0행이면 NULL, 2행 이상이면 오류이고, 집계 함수를 쓰면 언제나 한 행이 나온다는 점까지 확인하면 돼요.

인라인 뷰에서는 TOP N을 구하는 올바른 SQL을 고르는 문제가 가장 흔하고, 바깥에서 쓸 수 없는 열이나 별칭을 찾는 문제도 나와요.""",
    "checkQuestions": [
        question(1, "스칼라 서브쿼리에 대한 설명으로 알맞지 않은 것은 무엇인가요?", "confusing",
                 "스칼라 서브쿼리가 2행 이상을 돌려주면 첫 행만 쓰는 것이 아니라 ORA-01427(단일행 서브쿼리가 여러 행을 돌려줌) 오류가 나요. 0행일 때만 오류 대신 NULL이 돼요.",
                 [choice("A", "한 행 한 열, 즉 값 하나만 돌려줘야 한다", rationale="스칼라 서브쿼리의 조건이라 맞는 설명이에요."),
                  choice("B", "결과가 0행이면 NULL을 돌려준다", rationale="0행이면 오류 없이 NULL이 되므로 맞는 설명이에요."),
                  choice("C", "결과가 2행 이상이면 첫 번째 행의 값을 쓴다", True, "2행 이상이면 오류가 나서 틀린 설명이에요."),
                  choice("D", "서브쿼리 안에서 메인 쿼리의 열을 참조할 수 있다", rationale="연관 서브쿼리로 쓸 수 있으므로 맞는 설명이에요.")]),
        question(2, "사원 윤서연(1008)은 부서번호가 NULL이에요. 다음 SQL의 결과로 알맞은 것은 무엇인가요?", "scalar",
                 "부서번호가 NULL이면 짝이 되는 부서가 없어서 스칼라 서브쿼리가 0행을 돌려주고, 0행인 스칼라 서브쿼리는 NULL이 돼요. 메인 쿼리의 행은 사라지지 않아요.",
                 [choice("A", "윤서연, NULL", True, "행은 남고 부서명만 NULL이 돼요."),
                  choice("B", "0행", rationale="스칼라 서브쿼리가 0행이어도 메인 쿼리의 행은 그대로 남아요."),
                  choice("C", "오류가 난다", rationale="0행은 오류가 아니라 NULL로 처리돼요."),
                  choice("D", "윤서연, 인사부", rationale="NULL은 40과 같지 않아서 인사부와 짝이 되지 않아요.")],
                 stem_sql="SELECT e.이름, (SELECT d.부서명 FROM 부서 d WHERE d.부서번호 = e.부서번호) AS 부서명 FROM 사원 e WHERE e.사번 = 1008;"),
        question(3, "인사부(40번)에는 사원이 없어요. 다음 SQL의 결과로 알맞은 것은 무엇인가요?", "confusing",
                 "GROUP BY 없이 COUNT(*)를 쓴 서브쿼리는 대상 행이 없어도 0이 담긴 한 행을 돌려줘요. 그래서 사원수는 NULL이 아니라 0이에요.",
                 [choice("A", "인사부, NULL", rationale="MAX 같은 함수라면 NULL이지만, COUNT(*)는 대상이 없으면 0이에요."),
                  choice("B", "0행", rationale="메인 쿼리에서 인사부 행이 조건을 만족하므로 한 행이 나와요."),
                  choice("C", "오류가 난다", rationale="서브쿼리가 한 행 한 열을 돌려주므로 오류가 나지 않아요."),
                  choice("D", "인사부, 0", True, "COUNT(*)는 대상 행이 없으면 0을 돌려줘요.")],
                 stem_sql="SELECT d.부서명, (SELECT COUNT(*) FROM 사원 e WHERE e.부서번호 = d.부서번호) AS 사원수 FROM 부서 d WHERE d.부서번호 = 40;"),
        question(4, "급여가 가장 많은 사원 세 명(최유나, 김민수, 박서준)을 구하는 SQL로 알맞은 것은 무엇인가요?", "confusing",
                 "ROWNUM은 ORDER BY보다 먼저 붙기 때문에, 인라인 뷰 안에서 정렬한 뒤 바깥에서 ROWNUM으로 잘라야 해요. 같은 SELECT 안에서 ROWNUM으로 자르면 정렬 전에 세 행이 먼저 골라져요.",
                 [choice("A", "SELECT 이름 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC",
                         rationale="처음 읽힌 세 행을 고른 뒤 정렬해서 김민수, 박서준, 이지은이 나와요."),
                  choice("B", "SELECT 이름 FROM (SELECT 이름 FROM 사원 ORDER BY 급여 DESC) WHERE ROWNUM <= 3", True,
                         "인라인 뷰 안에서 정렬한 결과에 번호를 붙여 세 행을 잘라요."),
                  choice("C", "SELECT 이름 FROM 사원 WHERE 급여 IN (SELECT 급여 FROM 사원 ORDER BY 급여 DESC) AND ROWNUM <= 3",
                         rationale="WHERE 절 서브쿼리 안에는 ORDER BY를 쓸 수 없어서 오류가 나요."),
                  choice("D", "SELECT 이름 FROM (SELECT 이름, 급여 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC)",
                         rationale="인라인 뷰 안에서도 같은 SELECT에서 정렬 전에 세 행을 잘라서 김민수, 박서준, 이지은이 나와요.")]),
        question(5, "다음 SQL을 실행하면 어떻게 되나요?", "confusing",
                 "인라인 뷰 안의 `AVG(급여)`에 열 별칭을 붙이지 않았으니, 바깥 쿼리는 `평균급여`라는 열을 찾지 못해요. 그래서 ORA-00904(없는 열 이름) 오류가 나요.",
                 [choice("A", "부서별 평균 급여 4행이 나온다", rationale="바깥에서 부른 평균급여라는 열이 인라인 뷰에 없어요."),
                  choice("B", "NULL 그룹을 뺀 3행이 나온다", rationale="행 수를 따지기 전에 열 이름을 찾지 못해 실행되지 않아요."),
                  choice("C", "오류가 난다", True, "인라인 뷰가 평균급여라는 열을 내보내지 않아서 없는 열 이름이라는 오류가 나요."),
                  choice("D", "전체 평균 급여 1행이 나온다", rationale="GROUP BY가 있어서 전체 평균이 되지도 않고, 그 전에 열 이름 오류가 나요.")],
                 stem_sql="SELECT 평균급여 FROM (SELECT 부서번호, AVG(급여) FROM 사원 GROUP BY 부서번호);"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 결과 표
        SCALAR_DEPARTMENT_NAME_EXAMPLE.check,
        INLINE_VIEW_JOIN_EXAMPLE.check,
        INLINE_VIEW_TOP_EXAMPLE.check,
        WITH_CLAUSE_EXAMPLE.check,
        SCALAR_AGGREGATE_EXAMPLE.check,
        ROWNUM_BEFORE_ORDER_EXAMPLE.check,
        sql_check("SELECT e.이름, (SELECT d.부서명 FROM 부서 d WHERE d.부서번호 = e.부서번호) AS 부서명 FROM 사원 e WHERE e.사번 = 1008;",
                  [["윤서연", None]]),
        sql_check("SELECT e.이름, d.부서명 FROM 사원 e JOIN 부서 d ON d.부서번호 = e.부서번호 WHERE e.사번 = 1008", []),
        sql_check("SELECT e.이름, d.부서명 FROM 사원 e LEFT OUTER JOIN 부서 d ON d.부서번호 = e.부서번호 WHERE e.사번 = 1008",
                  [["윤서연", None]]),
        # 확인 문제 4 보기
        sql_check("SELECT 이름 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC",
                  [["김민수"], ["박서준"], ["이지은"]], is_ordered=True),
        sql_check("SELECT 이름 FROM (SELECT 이름 FROM 사원 ORDER BY 급여 DESC) WHERE ROWNUM <= 3",
                  [["최유나"], ["김민수"], ["박서준"]], is_ordered=True),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 급여 IN (SELECT 급여 FROM 사원 ORDER BY 급여 DESC) AND ROWNUM <= 3",
                        "ORA-00907"),
        sql_check("SELECT 이름 FROM (SELECT 이름, 급여 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC)",
                  [["김민수"], ["박서준"], ["이지은"]], is_ordered=True),
        # 스칼라 서브쿼리 행, 열 개수 오류, 집계 함수 0행
        sql_error_check("SELECT 이름, (SELECT 이름 FROM 사원 WHERE 부서번호 = 20) FROM 사원", "ORA-01427"),
        sql_error_check("SELECT e.이름, (SELECT d.부서명, d.지역 FROM 부서 d WHERE d.부서번호 = e.부서번호) FROM 사원 e",
                        "ORA-00913"),
        sql_check("SELECT d.부서명, (SELECT COUNT(*) FROM 사원 e WHERE e.부서번호 = d.부서번호) AS 사원수 FROM 부서 d WHERE d.부서번호 = 40;",
                  [["인사부", 0]]),
        # 인라인 뷰 열 범위, 별칭
        sql_error_check("SELECT 이름 FROM (SELECT 이름, 급여 FROM 사원) WHERE 직급 = '사원'", "ORA-00904"),
        sql_error_check("SELECT 평균급여 FROM (SELECT 부서번호, AVG(급여) FROM 사원 GROUP BY 부서번호);", "ORA-00904"),
        sql_error_check("SELECT a.이름 FROM (SELECT 이름 FROM 사원) AS a", "ORA-00933"),
        sql_check("SELECT a.이름 FROM (SELECT 이름 FROM 사원) a WHERE ROWNUM <= 1", [["김민수"]]),
    ],
}
