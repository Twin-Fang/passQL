"""개념: ROWNUM과 TOP N (2단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import to_employee_table_md

EMPLOYEE_SALARY_TABLE = to_employee_table_md("사번", "이름", "급여", "부서번호")

# 급여 내림차순 정렬 결과를 인라인 뷰로 감싼 상위 3명 (본문·3번 문제 정답)
TOP_THREE_SALARY_SQL = "SELECT 이름, 급여 FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC) WHERE ROWNUM <= 3;"

CONCEPT = {
    "tagKey": "select-rownum-top-n",
    "topicCode": "sql_basic_select",
    "sortOrder": 7,
    "title": "ROWNUM과 TOP N",
    "summary": "ROWNUM은 정렬 전에 붙는 번호라서, 상위 N개는 먼저 정렬한 뒤에 잘라야 해요",
    "coreMd": (
        "- ROWNUM은 WHERE 조건을 통과한 행에 1부터 차례로 붙는 번호(가상 열)이고, ORDER BY보다 먼저 붙어요.\n"
        "- `ROWNUM = 1`, `ROWNUM <= N`은 되지만 `ROWNUM = 2`, `ROWNUM > 1`은 첫 행부터 탈락해서 항상 0행이에요.\n"
        "- 급여 상위 N명처럼 정렬한 뒤 자르려면, 정렬한 SELECT를 FROM 절 괄호 안(인라인 뷰)에 넣고 바깥에서 ROWNUM으로 잘라요.\n"
        "- Oracle 12c부터는 `ORDER BY ... FETCH FIRST N ROWS ONLY`로, SQL Server는 `TOP(N)`으로 정렬 후 상위 N개를 바로 구하고, `WITH TIES`를 붙이면 N번째와 같은 값도 함께 나와요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

"급여가 가장 높은 사원 3명"이나 "가장 최근에 입사한 2명"처럼, 결과 중 앞쪽 몇 행만 필요할 때가 많아요. 이런 조회를 상위 N개, 영어로 **TOP N** 조회라고 불러요. Oracle에서는 오래전부터 ROWNUM으로 TOP N을 구해 왔는데, ROWNUM이 번호를 붙이는 시점을 모르면 엉뚱한 결과가 나와요. 예시는 아래 사원 표를 기준으로 해요.

{EMPLOYEE_SALARY_TABLE}

## ROWNUM이란 {{#definition}}

ROWNUM은 Oracle이 조회 결과의 행마다 1, 2, 3 하고 차례로 붙여 주는 번호예요. 테이블에 저장된 열이 아니라 조회할 때만 생기는 열이라서 **가상 열**(의사 컬럼, pseudo column)이라고 불러요. 사원 테이블에는 ROWNUM이라는 열이 없지만, SELECT 절이나 WHERE 절에서 열처럼 쓸 수 있어요.

```sql
SELECT ROWNUM, 이름 FROM 사원 WHERE ROWNUM <= 3;   -- 앞에서 3행만 나와요
```

| ROWNUM | 이름 |
|---|---|
| 1 | 김민수 |
| 2 | 이지은 |
| 3 | 박서준 |

이 결과는 사원 테이블이 사번 순서대로 저장되어 있어서 이렇게 나온 것이고, ORDER BY 없이 어떤 행이 먼저 읽힐지는 보장되지 않아요.

번호는 WHERE 절을 처리하는 동안 붙어요. Oracle은 행을 하나 읽을 때마다 나머지 WHERE 조건을 확인하고, 통과한 행에만 다음 번호를 줘요. 그래서 다른 조건과 함께 쓰면 그 조건을 통과한 행끼리 1번부터 번호를 받아요.

```sql
SELECT ROWNUM, 이름 FROM 사원 WHERE 부서번호 = 30 AND ROWNUM <= 2;   -- 30번 부서 사람끼리 1번부터 받아요
```

| ROWNUM | 이름 |
|---|---|
| 1 | 최유나 |
| 2 | 한도윤 |

## 정렬한 뒤 상위 N개 구하기 {{#inline-view}}

ROWNUM은 WHERE 단계에서 붙고 ORDER BY는 가장 마지막에 처리되므로, 한 SELECT 안에서 함께 쓰면 "번호를 붙여 3명을 자른 뒤에 정렬"하게 돼요. 급여 상위 3명을 원했는데, 테이블에서 먼저 읽힌 3명을 급여순으로 줄 세운 결과가 나와요. 번호가 1, 3, 2로 뒤섞인 것을 보면 정렬보다 번호가 먼저 붙었다는 것을 알 수 있어요.

```sql
SELECT ROWNUM, 이름, 급여 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC;   -- 3명을 자른 뒤에 정렬해요
```

| ROWNUM | 이름 | 급여 |
|---|---|---|
| 1 | 김민수 | 3000 |
| 3 | 박서준 | 2800 |
| 2 | 이지은 | 2500 |

올바르게 구하려면 정렬을 먼저 끝낸 결과에 번호를 붙여야 해요. FROM 절 안에 괄호로 SELECT 문을 넣으면 그 결과를 하나의 테이블처럼 쓸 수 있는데, 이것을 **인라인 뷰**라고 불러요. 안쪽 SELECT에서 급여순으로 정렬하고, 바깥 SELECT에서 ROWNUM으로 3명을 자르면 돼요. 인라인 뷰는 서브쿼리 단원에서 자세히 다뤄요.

```sql
{TOP_THREE_SALARY_SQL}   -- 정렬한 뒤에 3명을 잘라요
```

| 이름 | 급여 |
|---|---|
| 최유나 | 3200 |
| 김민수 | 3000 |
| 박서준 | 2800 |

3위부터 4위까지처럼 중간 구간이 필요하면 인라인 뷰를 한 번 더 감싸요. 안쪽에서 붙인 ROWNUM에 `rn` 같은 별칭을 주면, 바깥 쿼리에서는 rn이 이미 값이 정해진 보통 열이 되어서 `rn >= 3`도 쓸 수 있어요.

```sql
SELECT 이름, 급여
FROM (SELECT ROWNUM AS rn, 이름, 급여
      FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC)
      WHERE ROWNUM <= 4)
WHERE rn >= 3;   -- 3위와 4위만 남아요
```

| 이름 | 급여 |
|---|---|
| 박서준 | 2800 |
| 한도윤 | 2700 |

## FETCH FIRST로 바로 자르기 {{#fetch-first}}

Oracle 12c부터는 ORDER BY 뒤에 **FETCH FIRST N ROWS ONLY**를 붙여서, 인라인 뷰 없이 정렬한 결과의 앞쪽 N행만 가져올 수 있어요. FETCH는 ORDER BY 다음에 처리되므로 ROWNUM 같은 함정이 없어요. 앞쪽 몇 행을 건너뛰고 싶으면 `OFFSET 건너뛸 행 수 ROWS`를 앞에 붙이는데, 이때는 FIRST 대신 NEXT라고 쓰는 경우가 많고 뜻은 같아요.

```sql
SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC FETCH FIRST 3 ROWS ONLY;              -- 상위 3명이에요
SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY;  -- 2명을 건너뛰고 다음 2명이에요
```

| SQL | 결과 |
|---|---|
| `FETCH FIRST 3 ROWS ONLY` | 최유나 3200, 김민수 3000, 박서준 2800 |
| `OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY` | 박서준 2800, 한도윤 2700 |

ONLY 대신 **WITH TIES**를 쓰면, N번째 행과 정렬 값이 같은 행까지 함께 가져와요. 급여 상위 5명을 구하면 5번째가 2500인데, 2500인 사원이 이지은과 정하늘 두 명이라서 WITH TIES는 6행을 돌려줘요. ONLY로 쓰면 5행에서 끊기기 때문에 두 사람 중 한 명만 나오고, 어느 쪽이 나올지는 정해지지 않아요.

```sql
SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC FETCH FIRST 5 ROWS WITH TIES;   -- 동점자까지 6행이 나와요
```

| 이름 | 급여 |
|---|---|
| 최유나 | 3200 |
| 김민수 | 3000 |
| 박서준 | 2800 |
| 한도윤 | 2700 |
| 이지은 | 2500 |
| 정하늘 | 2500 |

## SQL Server의 TOP {{#top}}

SQL Server는 ROWNUM 대신 SELECT 바로 뒤에 `TOP(N)`을 써요. TOP은 ORDER BY로 정렬한 결과에서 앞쪽 N행을 고르기 때문에, 인라인 뷰 없이도 올바른 상위 N개가 나와요. `TOP(N) WITH TIES`는 Oracle의 WITH TIES처럼 N번째와 같은 값을 함께 가져오고, 무엇이 같은지 판단할 정렬 기준이 필요해서 반드시 ORDER BY와 함께 써야 해요. 아래 문장은 SQL Server 문법이라 Oracle에서는 실행되지 않아요.

```sql
-- 문법: SQL Server
SELECT TOP(3) 이름, 급여 FROM 사원 ORDER BY 급여 DESC;
SELECT TOP(5) WITH TIES 이름, 급여 FROM 사원 ORDER BY 급여 DESC;
```

## 자주 헷갈리는 점 {{#confusing}}

**`ROWNUM = 2`와 `ROWNUM > 1`은 항상 0행이에요.** Oracle은 행을 하나씩 읽으면서 "이 행이 통과하면 받을 번호"를 후보로 들고 조건을 검사해요. 행이 조건을 통과해야 그 번호를 받고 후보가 1 늘어나며, 탈락하면 번호를 받지 못하고 후보도 그대로예요. 사원 표가 사번 순서로 읽힌다고 하고 `ROWNUM <= 3`부터 따라가 볼게요.

| 읽은 행 | 지금 ROWNUM 후보 | ROWNUM <= 3 결과 | 번호 부여 |
|---|---|---|---|
| 김민수 | 1 | 참 | 1번을 받고 결과에 남아요 |
| 이지은 | 2 | 참 | 2번을 받아요 |
| 박서준 | 3 | 참 | 3번을 받아요 |
| 최유나 | 4 | 거짓 | 버려지고 후보는 4 그대로예요 |
| 정하늘부터 윤서연까지 | 4 | 거짓 | 모두 버려져요 |

같은 과정을 `ROWNUM = 2`로 따라가면, 첫 행이 후보 1번으로 검사받는 순간부터 막혀요.

| 읽은 행 | 지금 ROWNUM 후보 | ROWNUM = 2 결과 | 번호 부여 |
|---|---|---|---|
| 김민수 | 1 | 거짓 | 버려지고 후보는 1 그대로예요 |
| 이지은 | 1 | 거짓 | 버려지고 후보는 1 그대로예요 |
| 박서준부터 윤서연까지 | 1 | 거짓 | 모두 버려져요 |

아무도 1번을 받지 못하니 후보가 2가 되는 순간이 오지 않아서 결과는 0행이에요. `ROWNUM > 1`도 후보 1에서 모두 거짓이 되어 0행이고, `ROWNUM = 1`, `ROWNUM <= 3`, `ROWNUM < 4`처럼 1번이 통과할 수 있는 조건만 정상으로 동작해요.

```sql
SELECT 이름 FROM 사원 WHERE ROWNUM = 1;   -- 김민수 한 명이 나와요
SELECT 이름 FROM 사원 WHERE ROWNUM = 2;   -- 0행이 나와요
SELECT 이름 FROM 사원 WHERE ROWNUM > 1;   -- 0행이 나와요
```

**인라인 뷰 밖에서는 rn을 자유롭게 비교할 수 있어요.** 앞에서 본 것처럼 안쪽 쿼리에서 ROWNUM에 붙인 별칭 rn은, 바깥 쿼리 입장에서는 숫자가 이미 들어 있는 보통 열이에요. 안쪽 쿼리가 끝나는 순간 rn 값은 결과 표에 적힌 숫자로 굳어지고, 바깥 WHERE는 번호를 새로 붙이지 않고 그 숫자를 읽기만 하기 때문이에요. 그래서 바깥에서 `rn = 2`라고 쓰면 0행이 아니라 2번째 행이 정상으로 나와요. 0행이 되는 것은 ROWNUM을 같은 SELECT의 WHERE에서 바로 비교할 때뿐이에요.

```sql
SELECT 이름 FROM (SELECT ROWNUM AS rn, 이름 FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC)) WHERE rn = 2;   -- 김민수 한 명이 나와요
```

**ORDER BY를 인라인 뷰 바깥에 두면 소용이 없어요.** 상위 N개 문제의 오답 보기는 대부분 `WHERE ROWNUM <= 3 ORDER BY 급여 DESC`처럼 같은 SELECT 안에 둘을 함께 쓴 모양이에요. 정렬 방향을 반대로 쓴 인라인 뷰(`ORDER BY 급여`)도 하위 3명이 나오는 오답이에요. 정렬은 안쪽에서, ROWNUM은 바깥에서라는 순서를 보기마다 확인하면 돼요.

**FETCH FIRST와 TOP은 ORDER BY 뒤에 적용돼요.** ROWNUM만 정렬보다 먼저 붙고, Oracle의 FETCH FIRST와 SQL Server의 TOP은 정렬이 끝난 결과에서 자르기 때문에 인라인 뷰가 필요 없어요. 두 방법 모두 WITH TIES를 쓸 때는 ORDER BY가 있어야 같은 값을 판단할 수 있어요.

**ROWNUM과 ROW_NUMBER는 다른 것이에요.** ROWNUM은 Oracle의 가상 열이고, `ROW_NUMBER() OVER (ORDER BY 급여 DESC)`는 정렬 기준을 직접 정해서 번호를 매기는 윈도우 함수예요. ROW_NUMBER로 TOP N을 구하는 방법은 윈도우 함수 단원에서 다뤄요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

여러 SQL 중 급여 상위 N명을 올바르게 구하는 것을 고르는 문제가 가장 많아요. 정렬이 인라인 뷰 안에 있고 ROWNUM이 바깥에 있는지, 정렬 방향이 맞는지를 확인하면 돼요. 그 밖에 `ROWNUM = 2`나 `ROWNUM > 1`의 결과 행 수를 묻는 문제, WITH TIES를 붙였을 때 동점자까지 나오는 행 수를 묻는 문제, SQL Server의 TOP 문법을 묻는 문제가 나와요.""",
    "checkQuestions": [
        question(1, "Oracle의 ROWNUM에 대한 설명으로 알맞은 것은 무엇인가요?", "definition",
                 "ROWNUM은 테이블에 저장된 열이 아니라, 조회할 때 WHERE 조건을 통과한 행에 1부터 붙는 가상 열이에요. ORDER BY보다 먼저 붙어요.",
                 [choice("A", "테이블을 만들 때 자동으로 저장되는 열이다", rationale="ROWNUM은 저장되지 않고 조회할 때만 생겨요."),
                  choice("B", "ORDER BY로 정렬한 다음에 번호가 붙는다", rationale="ROWNUM은 WHERE 단계에서 붙어서 정렬보다 먼저예요."),
                  choice("C", "행마다 바뀌지 않는 고정된 번호다", rationale="조회할 때마다 조건과 읽는 순서에 따라 새로 붙어요."),
                  choice("D", "조회 결과 행에 1부터 차례로 붙는 가상 열이다", True, "ROWNUM의 정의예요.")]),
        question(2, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_SALARY_TABLE, "confusing",
                 "읽히는 행마다 1번 후보로 검사받는데 1은 2가 아니라서 모두 탈락해요. 2번까지 가는 행이 없어서 0행이에요.",
                 [choice("A", "1행", rationale="두 번째 행이 나올 것 같지만, 번호가 2까지 올라가지 못해요."),
                  choice("B", "8행", rationale="조건이 참이 되는 행이 없어요."),
                  choice("C", "0행", True, "모든 행이 1번 후보에서 탈락해요."),
                  choice("D", "오류가 난다", rationale="문법상 문제가 없어서 오류 없이 0행이 나와요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE ROWNUM = 2;"),
        question(3, "Oracle에서 급여가 가장 높은 사원 3명을 올바르게 구하는 SQL은 무엇인가요?", "inline-view",
                 "ROWNUM은 정렬보다 먼저 붙으므로, 인라인 뷰 안에서 급여 내림차순으로 정렬한 뒤 바깥에서 ROWNUM으로 잘라야 해요.",
                 [choice("A", "SELECT 이름 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC",
                         rationale="먼저 읽힌 3명을 자른 뒤 정렬해서 상위 3명이 아니에요."),
                  choice("B", "SELECT 이름 FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC) WHERE ROWNUM <= 3", True,
                         "정렬을 끝낸 결과에 번호를 붙여 3명을 잘라요."),
                  choice("C", "SELECT 이름 FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여) WHERE ROWNUM <= 3",
                         rationale="오름차순이라 급여가 가장 낮은 3명이 나와요."),
                  choice("D", "SELECT 이름 FROM 사원 ORDER BY 급여 DESC WHERE ROWNUM <= 3",
                         rationale="WHERE는 ORDER BY 앞에 써야 해서 오류가 나요.")]),
        question(4, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_SALARY_TABLE, "fetch-first",
                 "급여 내림차순 5번째는 2500인 이지은인데, 같은 2500인 정하늘도 WITH TIES로 함께 나와요. 그래서 6행이에요.",
                 [choice("A", "5행", rationale="ONLY일 때의 행 수이고, WITH TIES는 동점자를 더 가져와요."),
                  choice("B", "6행", True, "5번째와 급여가 같은 정하늘까지 나와요."),
                  choice("C", "8행", rationale="급여가 2500보다 낮은 오지민, 윤서연은 빠져요."),
                  choice("D", "오류가 난다", rationale="ORDER BY가 있어서 WITH TIES를 쓸 수 있어요.")],
                 stem_sql="SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC FETCH FIRST 5 ROWS WITH TIES;"),
        question(5, "아래 사원 표에 다음 SQL을 실행한 결과로 알맞은 것은 무엇인가요?\n\n" + EMPLOYEE_SALARY_TABLE, "confusing",
                 "30번 부서 세 명을 급여 오름차순으로 세우면 오지민 2200, 한도윤 2700, 최유나 3200이에요. rn은 안쪽에서 이미 정해진 번호라서 바깥의 rn = 3이 정상으로 비교되고, 세 번째인 최유나가 나와요.",
                 [choice("A", "오지민", rationale="오지민은 급여가 가장 낮아서 rn이 1이에요."),
                  choice("B", "0행이 나온다", rationale="0행이 되는 것은 같은 SELECT의 WHERE에서 ROWNUM = 3을 쓸 때예요."),
                  choice("C", "최유나", True, "30번 부서를 급여 오름차순으로 세웠을 때 세 번째 행이에요."),
                  choice("D", "한도윤", rationale="한도윤은 rn이 2인 행이에요.")],
                 stem_sql="SELECT 이름 FROM (SELECT ROWNUM AS rn, 이름 FROM (SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 30 ORDER BY 급여)) WHERE rn = 3;"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        sql_check("SELECT ROWNUM, 이름 FROM 사원 WHERE ROWNUM <= 3", [[1, "김민수"], [2, "이지은"], [3, "박서준"]]),
        sql_check("SELECT ROWNUM, 이름 FROM 사원 WHERE 부서번호 = 30 AND ROWNUM <= 2", [[1, "최유나"], [2, "한도윤"]]),
        sql_check("SELECT ROWNUM, 이름, 급여 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC",
                  [[1, "김민수", 3000], [3, "박서준", 2800], [2, "이지은", 2500]], is_ordered=True),
        sql_check(TOP_THREE_SALARY_SQL, [["최유나", 3200], ["김민수", 3000], ["박서준", 2800]], is_ordered=True),
        sql_check("SELECT 이름, 급여 FROM (SELECT ROWNUM AS rn, 이름, 급여 FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC)"
                  " WHERE ROWNUM <= 4) WHERE rn >= 3", [["박서준", 2800], ["한도윤", 2700]]),
        sql_check("SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC FETCH FIRST 3 ROWS ONLY",
                  [["최유나", 3200], ["김민수", 3000], ["박서준", 2800]], is_ordered=True),
        sql_check("SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY",
                  [["박서준", 2800], ["한도윤", 2700]], is_ordered=True),
        sql_check("SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC FETCH FIRST 5 ROWS WITH TIES;",
                  [["최유나", 3200], ["김민수", 3000], ["박서준", 2800], ["한도윤", 2700], ["이지은", 2500], ["정하늘", 2500]]),
        # ONLY 는 5행에서 끊김 (2500 동점 2명 중 1명만)
        sql_check("SELECT COUNT(*), SUM(CASE WHEN 급여 = 2500 THEN 1 ELSE 0 END) FROM"
                  " (SELECT 급여 FROM 사원 ORDER BY 급여 DESC FETCH FIRST 5 ROWS ONLY)", [[5, 1]]),
        sql_check("SELECT 이름 FROM 사원 WHERE ROWNUM = 1", [["김민수"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE ROWNUM = 2;", []),
        sql_check("SELECT 이름 FROM 사원 WHERE ROWNUM > 1", []),
        sql_check("SELECT 이름 FROM 사원 WHERE ROWNUM < 4", [["김민수"], ["이지은"], ["박서준"]]),
        sql_check("SELECT 이름 FROM (SELECT ROWNUM AS rn, 이름 FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC)) WHERE rn = 2;",
                  [["김민수"]]),
        sql_check("SELECT 이름 FROM (SELECT ROWNUM AS rn, 이름 FROM (SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 30 ORDER BY 급여)) WHERE rn = 3;", [["최유나"]]),
        # 3번 문제 보기
        sql_check("SELECT 이름 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC", [["김민수"], ["박서준"], ["이지은"]], is_ordered=True),
        sql_check("SELECT 이름 FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC) WHERE ROWNUM <= 3",
                  [["최유나"], ["김민수"], ["박서준"]], is_ordered=True),
        # 오름차순 인라인 뷰 = 하위 3명 (3번째는 2500 동점 중 1명이라 최저 2명만 확인)
        sql_check("SELECT COUNT(*) FROM (SELECT 이름 FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여) WHERE ROWNUM <= 3)"
                  " WHERE 이름 IN ('윤서연', '오지민')", [[2]]),
        sql_error_check("SELECT 이름 FROM 사원 ORDER BY 급여 DESC WHERE ROWNUM <= 3", "ORA-00933"),
    ],
}
