"""개념: ROWNUM과 TOP N (2단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import to_employee_table_md

EMPLOYEE_SALARY_TABLE = to_employee_table_md("사번", "이름", "급여", "부서번호")

# 급여 내림차순 정렬 결과를 인라인 뷰로 감싼 상위 3명 (본문·3번 문제 정답)
TOP_THREE_SALARY_SQL = "SELECT 이름, 급여 FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC) WHERE ROWNUM <= 3;"

CONCEPT = {
    "tagKey": "select-rownum-top-n",
    "topicCode": "sql_basic_select",
    "sortOrder": 8,
    "title": "ROWNUM과 TOP N",
    "summary": "ROWNUM은 정렬 전에 붙는 번호라서, 정렬한 뒤에 잘라야 해요",
    "coreMd": (
        "- ROWNUM은 WHERE 조건을 통과한 행에 1부터 붙는 가상 열이고, **ORDER BY보다 먼저** 붙어요.\n"
        "- `ROWNUM = 1`, `ROWNUM <= N`은 되지만 `ROWNUM = 2`, `ROWNUM > 1`은 **늘 0행**이에요.\n"
        "- 정렬한 상위 N개는 정렬한 SELECT를 **인라인 뷰**에 넣고 바깥에서 ROWNUM으로 잘라요.\n"
        "- Oracle 12c의 `FETCH FIRST N ROWS ONLY`와 SQL Server의 `TOP(N)`은 정렬한 뒤에 잘라요.\n"
        "- `WITH TIES`는 N번째와 같은 값도 함께 가져오고, **ORDER BY가 꼭** 있어야 해요."
    ),
    "detailMd": f"""## 왜 필요할까요 — 앞쪽 몇 행만 필요할 때 {{#why}}

"급여가 가장 높은 3명"처럼 결과의 앞쪽 몇 행만 필요한 조회를 상위 N개, 곧 **TOP N** 조회라고 해요. Oracle은 오래전부터 ROWNUM으로 TOP N을 구했는데, 번호가 붙는 시점을 모르면 엉뚱한 결과가 나와요.

{EMPLOYEE_SALARY_TABLE}

## ROWNUM이란 — WHERE를 통과한 행에 붙는 번호 {{#definition}}

| 용어 | 뜻 |
|---|---|
| ROWNUM | Oracle이 조회 결과의 행마다 1, 2, 3 차례로 붙이는 번호예요 |
| 가상 열 (의사 컬럼, pseudo column) | 테이블에 저장되지 않고 조회할 때만 생기는 열이에요. SELECT 절과 WHERE 절에서 열처럼 써요 |
| 번호가 붙는 시점 | WHERE를 처리하는 동안이에요. 나머지 조건을 통과한 행에만 다음 번호를 줘요 |

```sql
SELECT ROWNUM, 이름 FROM 사원 WHERE ROWNUM <= 3;   -- 앞에서 3행만 나와요
```

| ROWNUM | 이름 |
|---|---|
| 1 | 김민수 |
| 2 | 이지은 |
| 3 | 박서준 |

이 결과는 테이블이 사번 순서로 저장되어 나온 것이고, ORDER BY 없이 어떤 행이 먼저 읽힐지는 보장되지 않아요. 다른 조건과 함께 쓰면 그 조건을 통과한 행끼리 1번부터 받아요.

```sql
SELECT ROWNUM, 이름 FROM 사원 WHERE 부서번호 = 30 AND ROWNUM <= 2;   -- 30번 부서 사람끼리 1번부터 받아요
```

| ROWNUM | 이름 |
|---|---|
| 1 | 최유나 |
| 2 | 한도윤 |

## 정렬한 뒤 자르기 — ROWNUM은 정렬보다 먼저 {{#inline-view}}

한 SELECT 안에 ROWNUM과 ORDER BY를 함께 쓰면, 먼저 읽힌 3명을 자른 뒤에 급여순으로 세워요. 번호가 1, 3, 2로 뒤섞인 것이 정렬보다 번호가 먼저 붙었다는 증거예요.

```sql
SELECT ROWNUM, 이름, 급여 FROM 사원 WHERE ROWNUM <= 3 ORDER BY 급여 DESC;   -- 3명을 자른 뒤에 정렬해요
```

| ROWNUM | 이름 | 급여 |
|---|---|---|
| 1 | 김민수 | 3000 |
| 3 | 박서준 | 2800 |
| 2 | 이지은 | 2500 |

읽힌 순서대로 보면 급여가 가장 높은 최유나는 번호를 받기 전에 잘려 나가요.

| 행 | 처리 |
|---|---|
| 김민수 3000 | 남음 |
| 이지은 2500 | 남음 |
| 박서준 2800 | 남음 |
| 최유나 3200 | 빠짐 |
| 정하늘 2500 | 빠짐 |
| 한도윤 2700 | 빠짐 |
| 오지민 2200 | 빠짐 |
| 윤서연 2000 | 빠짐 |

FROM 절 안에 괄호로 넣은 SELECT 문은 하나의 테이블처럼 쓸 수 있고, 이것을 **인라인 뷰**라고 해요(6단원). 올바른 상위 N개는 아래 순서로 구해요.

| 단계 | 내용 |
|---|---|
| 1 안쪽 SELECT | 인라인 뷰 안에서 급여 내림차순으로 정렬해요 |
| 2 바깥 WHERE | 정렬이 끝난 결과에 ROWNUM을 붙이고 `ROWNUM <= 3`으로 잘라요 |

```sql
{TOP_THREE_SALARY_SQL}   -- 정렬한 뒤에 3명을 잘라요
```

| 이름 | 급여 |
|---|---|
| 최유나 | 3200 |
| 김민수 | 3000 |
| 박서준 | 2800 |

인라인 뷰에서 먼저 줄을 세웠으니, 앞의 세 명이 곧 급여 상위 세 명이에요.

| 행 | 처리 |
|---|---|
| 최유나 3200 | 남음 |
| 김민수 3000 | 남음 |
| 박서준 2800 | 남음 |
| 한도윤 2700 | 빠짐 |
| 이지은 2500 | 빠짐 |
| 정하늘 2500 | 빠짐 |
| 오지민 2200 | 빠짐 |
| 윤서연 2000 | 빠짐 |

3위부터 4위처럼 중간 구간은 인라인 뷰를 한 번 더 감싸요. 안쪽 ROWNUM에 `rn` 같은 별칭을 주면 바깥에서는 값이 정해진 보통 열이 되어 `rn >= 3`도 쓸 수 있어요.

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

## FETCH FIRST — 정렬한 뒤 바로 잘라요 {{#fetch-first}}

Oracle 12c부터는 ORDER BY 뒤에 **FETCH FIRST N ROWS ONLY**를 붙여 인라인 뷰 없이 앞쪽 N행을 가져와요. FETCH는 ORDER BY 다음에 처리되어 ROWNUM 같은 함정이 없어요.

| 용어 | 뜻 |
|---|---|
| FETCH FIRST N ROWS ONLY | 정렬한 결과에서 앞쪽 N행만 가져와요 |
| OFFSET M ROWS | 앞쪽 M행을 건너뛰어요. 이때 FIRST 대신 NEXT로 쓰는 경우가 많고 뜻은 같아요 |
| WITH TIES | ONLY 대신 쓰면 N번째 행과 정렬 값이 같은 행까지 함께 가져와요 |

```sql
SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC FETCH FIRST 3 ROWS ONLY;              -- 상위 3명이에요
SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY;  -- 2명을 건너뛰고 다음 2명이에요
```

| SQL | 결과 |
|---|---|
| `FETCH FIRST 3 ROWS ONLY` | 최유나 3200, 김민수 3000, 박서준 2800 |
| `OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY` | 박서준 2800, 한도윤 2700 |

급여 상위 5명의 5번째는 2500인데, 2500인 사원이 이지은과 정하늘 두 명이라 WITH TIES는 6행을 돌려줘요. ONLY로 쓰면 5행에서 끊겨서 두 사람 중 한 명만 나오고, 어느 쪽이 나올지는 정해지지 않아요.

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

## SQL Server의 TOP — SELECT 바로 뒤에 {{#top}}

SQL Server는 SELECT 바로 뒤에 `TOP(N)`을 쓰고, ORDER BY로 정렬한 결과에서 앞쪽 N행을 골라서 인라인 뷰가 필요 없어요. `TOP(N) WITH TIES`는 같은 값을 판단할 기준이 있어야 해서 반드시 ORDER BY와 함께 쓰고, 아래 문장은 Oracle에서는 실행되지 않아요.

```sql
-- 문법: SQL Server
SELECT TOP(3) 이름, 급여 FROM 사원 ORDER BY 급여 DESC;
SELECT TOP(5) WITH TIES 이름, 급여 FROM 사원 ORDER BY 급여 DESC;
```

| 방법 | 자르는 시점 | 동점 포함 |
|---|---|---|
| ROWNUM (Oracle) | WHERE 단계, 정렬 전 | 없음 |
| FETCH FIRST (Oracle 12c) | ORDER BY 다음 | WITH TIES |
| TOP(N) (SQL Server) | ORDER BY 다음 | WITH TIES (ORDER BY 필수) |

## 자주 헷갈리는 점 — ROWNUM = 2가 0행인 이유 {{#confusing}}

Oracle은 행을 읽을 때마다 "통과하면 받을 번호"를 후보로 들고 조건을 검사하고, 통과한 행만 번호를 받아 후보가 1 늘어나요. `ROWNUM <= 3`과 `ROWNUM = 2`를 사번 순서대로 따라가면 차이가 보여요.

| 읽은 행 | 후보 번호 | ROWNUM <= 3 |
|---|---|---|
| 김민수 | 1 | 참, 1번을 받아요 |
| 이지은 | 2 | 참, 2번을 받아요 |
| 박서준 | 3 | 참, 3번을 받아요 |
| 최유나부터 윤서연까지 | 4 | 거짓, 후보는 4 그대로라 모두 버려져요 |

| 읽은 행 | 후보 번호 | ROWNUM = 2 |
|---|---|---|
| 김민수 | 1 | 거짓, 후보는 1 그대로예요 |
| 이지은 | 1 | 거짓, 후보는 1 그대로예요 |
| 박서준부터 윤서연까지 | 1 | 거짓, 모두 버려져요 |

아무도 1번을 받지 못하면 후보가 2가 되는 순간이 오지 않아서 `ROWNUM = 2`는 0행이에요.

```sql
SELECT 이름 FROM 사원 WHERE ROWNUM = 1;   -- 김민수 한 명이 나와요
SELECT 이름 FROM 사원 WHERE ROWNUM = 2;   -- 0행이 나와요
SELECT 이름 FROM 사원 WHERE ROWNUM > 1;   -- 0행이 나와요
SELECT 이름 FROM (SELECT ROWNUM AS rn, 이름 FROM (SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC)) WHERE rn = 2;   -- 김민수 한 명이 나와요
```

| 헷갈리는 말 | 실제로는 |
|---|---|
| `ROWNUM = 2`는 두 번째 행을 돌려줘요 | 첫 행부터 탈락해서 늘 0행이에요. `ROWNUM > 1`도 0행이에요 |
| 1번이 없는 조건도 ROWNUM에 쓸 수 있어요 | `ROWNUM = 1`, `<= 3`, `< 4`처럼 1번이 통과할 수 있는 조건만 정상으로 동작해요 |
| 인라인 뷰 밖에서 `rn = 2`를 써도 0행이에요 | 안쪽에서 붙인 rn은 숫자로 굳은 보통 열이라 2번째 행이 정상으로 나와요. 0행은 같은 SELECT의 WHERE에서 ROWNUM을 바로 비교할 때뿐이에요 |
| `WHERE ROWNUM <= 3 ORDER BY 급여 DESC`는 상위 3명이에요 | 먼저 읽힌 3명을 자른 뒤 정렬해요. 정렬은 안쪽, ROWNUM은 바깥이에요 |
| 인라인 뷰 안에서 `ORDER BY 급여`로 정렬해도 상위 3명이에요 | 오름차순이라 하위 3명이 나와요. 정렬 방향도 확인해요 |
| ROWNUM과 ROW_NUMBER는 같은 것이에요 | ROWNUM은 가상 열이고, `ROW_NUMBER() OVER (ORDER BY 급여 DESC)`는 정렬 기준을 직접 정하는 윈도우 함수예요(8단원) |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `ROWNUM < 4`는 앞에서 3행을 돌려줘요 | O | 1번이 통과할 수 있는 조건이라 1, 2, 3번이 붙어요 |
| FETCH FIRST는 ROWNUM처럼 정렬보다 먼저 행을 잘라요 | X | FETCH는 ORDER BY 다음에 처리되어 정렬한 결과를 잘라요 |
| SQL Server에서 `TOP(5) WITH TIES`는 ORDER BY 없이도 쓸 수 있어요 | X | 같은 값을 판단할 정렬 기준이 필요해서 ORDER BY가 꼭 있어야 해요 |

## 꼭 외울 것 — 번호가 붙는 시점과 자르는 방법 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| ROWNUM이 붙는 시점 | WHERE 단계, ORDER BY보다 먼저 |
| 제대로 동작하는 ROWNUM 조건 | `= 1`, `<= N`, `< N` (1번이 통과하는 조건) |
| `ROWNUM = 2`, `ROWNUM > 1` | 오류 없이 늘 0행 |
| 정렬한 상위 N개 (ROWNUM) | 인라인 뷰 안에서 정렬, 바깥에서 ROWNUM으로 자름 |
| 인라인 뷰 밖의 별칭 rn | 보통 열이라 `rn = 2`, `rn >= 3`도 돼요 |
| Oracle 12c의 상위 N개 | `ORDER BY ... FETCH FIRST N ROWS ONLY` |
| SQL Server의 상위 N개 | `SELECT TOP(N) ...`, ORDER BY 다음에 잘라요 |
| WITH TIES | N번째와 같은 값도 포함, ORDER BY 필수 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

여러 SQL 중 급여 상위 N명을 올바르게 구하는 것을 고르는 문제가 가장 많고, 정렬이 인라인 뷰 안에 있는지와 정렬 방향이 맞는지를 확인하면 돼요. `ROWNUM = 2`나 `ROWNUM > 1`의 행 수, WITH TIES의 동점자 행 수, SQL Server의 TOP 문법을 묻는 문제도 나와요.""",
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
