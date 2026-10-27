"""개념: 스칼라 서브쿼리와 인라인 뷰 (6단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import DEPARTMENT_TABLE_MD, to_employee_table_md

# 이 개념의 계산에 쓰는 열 전부 (직급·급여·부서번호)
EMPLOYEE_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")

CONCEPT = {
    "tagKey": "subquery-scalar-inline-view",
    "topicCode": "sql_subquery",
    "sortOrder": 4,
    "title": "스칼라 서브쿼리와 인라인 뷰",
    "summary": "SELECT 절에서 값 하나를 가져오는 서브쿼리와 FROM 절에서 표처럼 쓰는 서브쿼리예요",
    "coreMd": (
        "- 스칼라 서브쿼리는 주로 SELECT 절에 놓여 값 하나(한 행 한 열)를 돌려주고, 결과가 0행이면 NULL이 되며 2행 이상이면 오류가 나요.\n"
        "- 인라인 뷰는 FROM 절에 쓴 서브쿼리이고, 그 결과를 별칭을 붙인 표처럼 조인하거나 조건을 걸 수 있어요.\n"
        "- 인라인 뷰 안에서는 ORDER BY를 쓸 수 있어서, 안에서 정렬한 뒤 바깥에서 `ROWNUM <= N`을 걸면 TOP N을 구할 수 있어요.\n"
        "- `WITH 이름 AS (서브쿼리)`로 서브쿼리에 먼저 이름을 붙여 두면, 본문에서 그 이름을 표처럼 쓸 수 있어요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

사원 목록을 보여 주면서 이름 옆에 부서명을 함께 적고 싶을 때가 있어요. 부서명은 부서 테이블에 있으니 조인을 써도 되지만, 값 하나만 가져오면 되는 경우에는 SELECT 절 안에서 바로 찾아오는 편이 읽기 쉬워요.

부서별 평균 급여를 구해서 그 평균과 사원 급여를 비교하거나, 급여 순으로 정렬한 다음 위에서 세 명만 잘라 내고 싶을 때도 있어요. 이런 일은 한 번 만든 결과를 다시 가공해야 해서, 서브쿼리 결과를 표처럼 놓고 그 위에서 SELECT를 한 번 더 하는 방법이 필요해요. 앞의 일을 해 주는 것이 스칼라 서브쿼리이고, 뒤의 일을 해 주는 것이 인라인 뷰예요.

이 글의 예시는 모두 아래 사원 표와 부서 표로 계산해요. 윤서연(1008)은 부서가 정해지지 않아 부서번호가 NULL이고, 인사부(40번)에는 소속 사원이 없어요.

{EMPLOYEE_TABLE}

{DEPARTMENT_TABLE_MD}

## 스칼라 서브쿼리 {{#scalar}}

스칼라(Scalar)는 "값 하나"라는 뜻이에요. 스칼라 서브쿼리는 한 행 한 열, 즉 값 하나만 돌려주는 서브쿼리이고, 주로 SELECT 절에 놓여 열 하나처럼 쓰여요.

```sql
SELECT e.이름,
       (SELECT d.부서명 FROM 부서 d WHERE d.부서번호 = e.부서번호) AS 부서명
FROM 사원 e;
```

| 이름 | 부서명 |
|---|---|
| 김민수 | 기획부 |
| 이지은 | 개발부 |
| 박서준 | 개발부 |
| 최유나 | 영업부 |
| 정하늘 | 개발부 |
| 한도윤 | 영업부 |
| 오지민 | 영업부 |
| 윤서연 | NULL |

서브쿼리 안에서 메인 쿼리의 `e.부서번호`를 쓰고 있으니, 이 스칼라 서브쿼리는 연관 서브쿼리이기도 해요. 사원 한 명마다 그 사원의 부서번호로 부서명을 하나씩 찾아와요.

부서번호가 NULL인 윤서연은 짝이 되는 부서가 없어서 서브쿼리가 0행을 돌려주는데, 스칼라 서브쿼리는 0행이면 NULL을 돌려줘요. 그래서 윤서연의 행은 사라지지 않고 부서명만 NULL로 나와요. 사원과 부서를 일반 조인(INNER JOIN)으로 붙였다면 짝이 없는 윤서연은 결과에서 빠졌을 거예요. 스칼라 서브쿼리는 짝이 없는 행도 남겨 둔다는 점에서, 조인 단원에서 배운 외부 조인(OUTER JOIN, 짝이 없는 행도 버리지 않고 NULL을 채워 남기는 조인)과 결과가 같아요.

스칼라 서브쿼리는 SELECT 절 말고도 값 하나가 들어갈 자리라면 대부분 쓸 수 있어요. WHERE 절에서 `급여 > (SELECT AVG(급여) FROM 사원)`처럼 쓰는 단일행 서브쿼리도 값 하나를 돌려준다는 점에서 같은 성격이에요. 여기서 `AVG(급여)`는 급여의 평균을 구하는 함수예요.

## 인라인 뷰 {{#inline-view}}

인라인 뷰(Inline View)는 FROM 절에 쓴 서브쿼리예요. 서브쿼리 결과가 그 SQL 안에서만 쓰는 임시 표가 되고, 바깥 쿼리는 이 표에 조인하거나 조건을 걸 수 있어요. 이름에 "뷰"가 들어가지만 데이터베이스에 저장되지 않고 그 SQL을 실행하는 동안에만 있어요.

```sql
SELECT e.이름, e.급여, a.평균급여
FROM 사원 e
JOIN (SELECT 부서번호, AVG(급여) AS 평균급여
      FROM 사원
      GROUP BY 부서번호) a
  ON e.부서번호 = a.부서번호
WHERE e.급여 > a.평균급여;
```

`GROUP BY 부서번호`는 사원을 부서번호가 같은 사람끼리 묶는 절이고, 그룹 함수 단원에서 자세히 다뤄요. 괄호 안의 서브쿼리는 이렇게 부서별로 묶어 평균 급여 표를 만들고, 바깥 쿼리는 그 표에 `a`라는 별칭을 붙여 사원 테이블과 조인해요. 서브쿼리 안에서 `AVG(급여)`에 `평균급여`라는 열 별칭을 붙인 것은 바깥에서 이 열을 부를 이름이 필요하기 때문이에요.

| 이름 | 급여 | 평균급여 |
|---|---|---|
| 박서준 | 2800 | 2600 |
| 최유나 | 3200 | 2700 |

결과는 앞의 연관 서브쿼리로 "자기 부서 평균보다 급여가 많은 사원"을 찾았을 때와 같아요.

인라인 뷰가 자주 쓰이는 또 다른 곳은 TOP N이에요. 급여가 가장 많은 세 명을 구하려면 인라인 뷰 안에서 정렬을 끝내 두고, 바깥에서 ROWNUM(조회된 행에 1부터 붙는 번호)으로 세 행만 잘라요.

```sql
SELECT 이름, 급여
FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC)
WHERE ROWNUM <= 3;
```

| 이름 | 급여 |
|---|---|
| 최유나 | 3200 |
| 김민수 | 3000 |
| 박서준 | 2800 |

## WITH 절 {{#with-clause}}

WITH 절은 서브쿼리에 이름을 붙여 SQL 맨 앞에 따로 꺼내 두는 방법이에요. 이렇게 이름 붙인 서브쿼리를 공통 테이블 식(Common Table Expression, CTE)이라고 불러요. Oracle 문서에서는 서브쿼리를 본문에서 떼어 앞으로 빼낸다는 뜻으로 서브쿼리 팩토링(Subquery Factoring)이라고도 해요.

```sql
WITH 부서평균 AS (
  SELECT 부서번호, AVG(급여) AS 평균급여
  FROM 사원
  GROUP BY 부서번호
)
SELECT e.이름, e.급여, a.평균급여
FROM 사원 e
JOIN 부서평균 a ON e.부서번호 = a.부서번호
WHERE e.급여 > a.평균급여;
```

이 SQL은 앞의 인라인 뷰 예시와 같은 박서준, 최유나 두 명을 돌려줘요. `부서평균`은 이 SQL이 실행되는 동안에만 있는 이름이에요. 서브쿼리가 길거나 같은 서브쿼리를 여러 번 써야 할 때 WITH 절로 빼 두면, 본문이 짧아지고 한 번 정의한 결과를 이름으로 여러 번 부를 수 있어요.

## 자주 헷갈리는 점 {{#confusing}}

**스칼라 서브쿼리는 한 행 한 열만 돌려줘야 해요.** 행이 두 개 이상 나오면 ORA-01427(단일행 서브쿼리가 여러 행을 돌려줌) 오류가 나고, 열이 두 개 이상이면 ORA-00913(값이 너무 많음) 오류가 나요. 0행일 때만 오류 대신 NULL이 된다는 점을 함께 기억해 두면 좋아요.

```sql
SELECT 이름, (SELECT 이름 FROM 사원 WHERE 부서번호 = 20) FROM 사원;  -- 오류: 20번 부서는 3명이라 세 행이 돌아와요

SELECT e.이름, (SELECT d.부서명, d.지역 FROM 부서 d WHERE d.부서번호 = e.부서번호)
FROM 사원 e;  -- 오류: 서브쿼리가 열 두 개를 돌려줘요
```

**0행이면 NULL이지만, 집계 함수를 쓰면 0이 나오기도 해요.** COUNT(행 개수)와 MAX(가장 큰 값)처럼 여러 행을 모아 값 하나를 계산하는 함수를 집계 함수라고 해요. 부서마다 사원 수와 최고 급여를 스칼라 서브쿼리로 구하면 인사부의 두 값이 서로 달라요.

```sql
SELECT d.부서명,
       (SELECT COUNT(*) FROM 사원 e WHERE e.부서번호 = d.부서번호) AS 사원수,
       (SELECT MAX(e.급여) FROM 사원 e WHERE e.부서번호 = d.부서번호) AS 최고급여
FROM 부서 d;
```

| 부서명 | 사원수 | 최고급여 |
|---|---|---|
| 기획부 | 1 | 3000 |
| 개발부 | 3 | 2800 |
| 영업부 | 3 | 3200 |
| 인사부 | 0 | NULL |

GROUP BY 없이 집계 함수를 쓴 서브쿼리는 대상 행이 없어도 결과 한 행을 돌려줘요. 그 한 행에 COUNT는 0을 담고 MAX는 NULL을 담기 때문에, 인사부의 사원수는 0이고 최고급여는 NULL이에요.

**인라인 뷰 바깥에서는 인라인 뷰가 내보낸 열만 쓸 수 있어요.** 바깥 쿼리에게 인라인 뷰는 그 SELECT 목록의 열만 가진 표예요. 그래서 안에서 고르지 않은 열을 바깥에서 쓰거나, 계산식에 열 별칭을 붙이지 않고 바깥에서 별칭처럼 부르면 ORA-00904(없는 열 이름) 오류가 나요.

```sql
SELECT 이름 FROM (SELECT 이름, 급여 FROM 사원) WHERE 직급 = '사원';  -- 오류: 인라인 뷰에 직급 열이 없어요

SELECT 평균급여
FROM (SELECT 부서번호, AVG(급여) FROM 사원 GROUP BY 부서번호);  -- 오류: 평균급여라는 열 별칭이 없어요
```

**TOP N은 정렬을 끝낸 뒤에 ROWNUM으로 잘라야 해요.** 2단원에서 본 SELECT 문의 실행 순서는 FROM, WHERE, GROUP BY, HAVING, SELECT, ORDER BY 순이에요. ROWNUM은 WHERE 단계에서 행을 하나씩 읽어 올 때 붙는 번호라서, 맨 마지막인 ORDER BY보다 먼저 정해져요.

```sql
SELECT 이름, 급여
FROM 사원
WHERE ROWNUM <= 3
ORDER BY 급여 DESC;
```

| 이름 | 급여 |
|---|---|
| 김민수 | 3000 |
| 박서준 | 2800 |
| 이지은 | 2500 |

이 SQL은 읽어 온 처음 세 행에 번호 1, 2, 3을 붙여 고른 뒤에 정렬할 뿐이라서, 급여가 가장 많은 최유나가 빠져요. ORDER BY가 없을 때 행을 어떤 순서로 읽을지는 Oracle이 정하므로 보장되지 않아요. 이 예시에서 김민수, 이지은, 박서준이 골라진 것은 표에 넣은 순서대로 읽혔기 때문이고, 환경이 바뀌면 다른 세 명이 골라질 수도 있어요.

같은 실수는 인라인 뷰 안에서도 일어나요. 한 SELECT 안에 `WHERE ROWNUM <= 3`과 `ORDER BY`를 함께 쓰면, 인라인 뷰 안이라도 정렬 전에 세 행이 먼저 잘려요. 아래 SQL도 김민수, 박서준, 이지은을 돌려줄 뿐 최유나는 빠져요. 정렬하는 SELECT(안쪽)와 ROWNUM으로 자르는 SELECT(바깥쪽)를 따로 두어야 해요.

```sql
SELECT 이름
FROM (SELECT 이름, 급여 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC);  -- 정렬 전에 세 행이 잘려요
```

정렬을 인라인 뷰가 아닌 WHERE 절 서브쿼리 안으로 넣는 것도 안 돼요. WHERE 절 서브쿼리 안에는 ORDER BY를 쓸 수 없어서 ORA-00907(오른쪽 괄호가 없음) 오류가 나요.

```sql
SELECT 이름 FROM 사원
WHERE 급여 IN (SELECT 급여 FROM 사원 ORDER BY 급여 DESC) AND ROWNUM <= 3;  -- 오류: WHERE 절 서브쿼리 안에는 ORDER BY를 쓸 수 없어요
```

**Oracle에서는 인라인 뷰 별칭 앞에 AS를 쓸 수 없어요.** 열 별칭에는 `AVG(급여) AS 평균급여`처럼 AS를 써도 되지만, 테이블이나 인라인 뷰에 붙이는 별칭 앞에 AS를 쓰면 ORA-00933(SQL 문이 제대로 끝나지 않음) 오류가 나요. 별칭 자체는 Oracle에서 생략할 수 있지만, 다른 테이블과 조인할 때는 별칭을 붙여 두는 편이 열을 구분하기 쉬워요.

```sql
SELECT a.이름 FROM (SELECT 이름 FROM 사원) AS a;  -- 오류: 인라인 뷰 별칭 앞에 AS를 썼어요
SELECT a.이름 FROM (SELECT 이름 FROM 사원) a WHERE ROWNUM <= 1;  -- AS 없이 쓰면 김민수가 나와요
```

## 시험에서는 이렇게 나와요 {{#exam-point}}

스칼라 서브쿼리가 0행이나 2행 이상을 돌려줄 때의 결과를 묻는 문제가 자주 나와요. 0행이면 NULL, 2행 이상이면 오류라는 규칙에 더해, 집계 함수를 쓴 경우에는 언제나 한 행이 나온다는 점까지 확인하면 돼요. 인라인 뷰에서는 TOP N을 구하는 올바른 SQL을 고르는 문제가 가장 흔하고, 바깥에서 쓸 수 없는 열이나 별칭을 찾는 문제도 나와요.""",
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
        sql_check("SELECT e.이름, (SELECT d.부서명 FROM 부서 d WHERE d.부서번호 = e.부서번호) AS 부서명 FROM 사원 e",
                  [["김민수", "기획부"], ["이지은", "개발부"], ["박서준", "개발부"], ["최유나", "영업부"],
                   ["정하늘", "개발부"], ["한도윤", "영업부"], ["오지민", "영업부"], ["윤서연", None]]),
        sql_check("SELECT e.이름, (SELECT d.부서명 FROM 부서 d WHERE d.부서번호 = e.부서번호) AS 부서명 FROM 사원 e WHERE e.사번 = 1008;",
                  [["윤서연", None]]),
        sql_check("SELECT e.이름, d.부서명 FROM 사원 e JOIN 부서 d ON d.부서번호 = e.부서번호 WHERE e.사번 = 1008", []),
        # 인라인 뷰·WITH 절 (자기 부서 평균보다 많은 사원)
        sql_check("SELECT e.이름, e.급여, a.평균급여 FROM 사원 e JOIN (SELECT 부서번호, AVG(급여) AS 평균급여 "
                  "FROM 사원 GROUP BY 부서번호) a ON e.부서번호 = a.부서번호 WHERE e.급여 > a.평균급여",
                  [["박서준", 2800, 2600], ["최유나", 3200, 2700]]),
        sql_check("WITH 부서평균 AS (SELECT 부서번호, AVG(급여) AS 평균급여 FROM 사원 GROUP BY 부서번호) "
                  "SELECT e.이름, e.급여, a.평균급여 FROM 사원 e JOIN 부서평균 a ON e.부서번호 = a.부서번호 "
                  "WHERE e.급여 > a.평균급여",
                  [["박서준", 2800, 2600], ["최유나", 3200, 2700]]),
        # TOP N: 인라인 뷰 안 정렬 <-> 정렬 전 ROWNUM
        sql_check("SELECT 이름, 급여 FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC) WHERE ROWNUM <= 3",
                  [["최유나", 3200], ["김민수", 3000], ["박서준", 2800]], is_ordered=True),
        sql_check("SELECT 이름, 급여 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC",
                  [["김민수", 3000], ["박서준", 2800], ["이지은", 2500]], is_ordered=True),
        # 확인 문제 4 보기
        sql_check("SELECT 이름 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC",
                  [["김민수"], ["박서준"], ["이지은"]], is_ordered=True),
        sql_check("SELECT 이름 FROM (SELECT 이름 FROM 사원 ORDER BY 급여 DESC) WHERE ROWNUM <= 3",
                  [["최유나"], ["김민수"], ["박서준"]], is_ordered=True),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 급여 IN (SELECT 급여 FROM 사원 ORDER BY 급여 DESC) AND ROWNUM <= 3",
                        "ORA-00907"),
        sql_check("SELECT 이름 FROM (SELECT 이름, 급여 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC)",
                  [["김민수"], ["박서준"], ["이지은"]], is_ordered=True),
        # 스칼라 서브쿼리 행·열 개수 오류, 집계 함수 0행
        sql_error_check("SELECT 이름, (SELECT 이름 FROM 사원 WHERE 부서번호 = 20) FROM 사원", "ORA-01427"),
        sql_error_check("SELECT e.이름, (SELECT d.부서명, d.지역 FROM 부서 d WHERE d.부서번호 = e.부서번호) FROM 사원 e",
                        "ORA-00913"),
        sql_check("SELECT d.부서명, (SELECT COUNT(*) FROM 사원 e WHERE e.부서번호 = d.부서번호) AS 사원수, "
                  "(SELECT MAX(e.급여) FROM 사원 e WHERE e.부서번호 = d.부서번호) AS 최고급여 FROM 부서 d",
                  [["기획부", 1, 3000], ["개발부", 3, 2800], ["영업부", 3, 3200], ["인사부", 0, None]]),
        sql_check("SELECT d.부서명, (SELECT COUNT(*) FROM 사원 e WHERE e.부서번호 = d.부서번호) AS 사원수 FROM 부서 d WHERE d.부서번호 = 40;",
                  [["인사부", 0]]),
        # 인라인 뷰 열 범위·별칭
        sql_error_check("SELECT 이름 FROM (SELECT 이름, 급여 FROM 사원) WHERE 직급 = '사원'", "ORA-00904"),
        sql_error_check("SELECT 평균급여 FROM (SELECT 부서번호, AVG(급여) FROM 사원 GROUP BY 부서번호);", "ORA-00904"),
        sql_error_check("SELECT a.이름 FROM (SELECT 이름 FROM 사원) AS a", "ORA-00933"),
        sql_check("SELECT a.이름 FROM (SELECT 이름 FROM 사원) a WHERE ROWNUM <= 1", [["김민수"]]),
    ],
}
