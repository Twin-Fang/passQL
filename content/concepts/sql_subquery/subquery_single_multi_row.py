"""개념: 단일행·다중행 서브쿼리 (6단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import DEPARTMENT_TABLE_MD, to_employee_table_md

EMPLOYEE_SALARY_TABLE = to_employee_table_md("사번", "이름", "급여", "커미션", "부서번호")

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
AVERAGE_ABOVE_EXAMPLE = sql_example(
    """SELECT 이름, 급여
FROM 사원
WHERE 급여 > (SELECT AVG(급여) FROM 사원);""",
    ("이름", "급여"), [["김민수", 3000], ["박서준", 2800], ["최유나", 3200], ["한도윤", 2700]], is_ordered=False)
HAVING_AVERAGE_EXAMPLE = sql_example(
    """SELECT 부서번호, AVG(급여)
FROM 사원
GROUP BY 부서번호
HAVING AVG(급여) > (SELECT AVG(급여) FROM 사원);""",
    ("부서번호", "AVG(급여)"), [[10, 3000], [30, 2700]], is_ordered=False)
# 서브쿼리 0행 (40번 부서) > ALL 은 전원
EMPTY_ALL_EXAMPLE = sql_example(
    """SELECT 이름 FROM 사원
WHERE 급여 > ALL (SELECT 급여 FROM 사원 WHERE 부서번호 = 40);""",
    ("이름",), [["김민수"], ["이지은"], ["박서준"], ["최유나"], ["정하늘"], ["한도윤"], ["오지민"], ["윤서연"]],
    is_ordered=False)

CONCEPT = {
    "tagKey": "subquery-single-multi-row",
    "topicCode": "sql_subquery",
    "sortOrder": 1,
    "title": "단일행·다중행 서브쿼리",
    "summary": "서브쿼리가 돌려주는 행 수에 따라 함께 쓸 연산자가 달라져요",
    "coreMd": (
        "- 서브쿼리는 괄호 안에 넣은 SELECT 문이고, 놓인 자리에 따라 스칼라 서브쿼리, 인라인 뷰, 중첩 서브쿼리로 불러요.\n"
        "- 단일행 연산자(`=`, `>`, `<`) 뒤에 여러 행이 돌아오면 오류가 나요.\n"
        "- `> ANY`는 최솟값보다 크면 참이고, `> ALL`은 최댓값보다 커야 참이에요.\n"
        "- 서브쿼리가 0행이면 `=`와 `> ANY`는 0행, `> ALL`과 `NOT IN`은 모든 행을 남겨요.\n"
        "- WHERE 절 서브쿼리 안에는 ORDER BY를 쓸 수 없어요."
    ),
    "detailMd": f"""## 질문 안에 질문 넣기 — 평균보다 많이 받는 사람 {{#why}}

평균 급여보다 많이 받는 사원을 찾으려면 평균을 먼저 구해서 숫자로 옮겨 적어야 해요. 서브쿼리를 쓰면 "평균이 얼마인가"를 조건 안에 그대로 넣으니, 사원이 늘어도 SQL을 고칠 필요가 없어요.

아래 두 표가 이 개념의 모든 예시에 쓰여요. 인사부(40번)에는 사원이 없고, 윤서연(1008)은 부서번호가 NULL이에요.

{EMPLOYEE_SALARY_TABLE}

{DEPARTMENT_TABLE_MD}

`AVG(급여)`는 급여의 평균을 구하는 함수이고, 그룹 함수 단원에서 자세히 다뤄요. 괄호 안의 서브쿼리가 평균 2612.5를 돌려주면, 메인 쿼리는 그보다 급여가 많은 네 명을 남겨요.

{AVERAGE_ABOVE_EXAMPLE.markdown}

## 한 줄 정의 — 괄호 안의 SELECT 문 {{#definition}}

| 용어 | 뜻 |
|---|---|
| 서브쿼리 (Subquery) | SQL 문 안에 들어 있는 또 하나의 SELECT 문이에요. 어디에 쓰든 반드시 괄호로 감싸요 |
| 메인 쿼리 (Main Query) | 서브쿼리를 품고 있는 바깥쪽 SQL이에요 |

시험 보기에는 놓인 자리에 따른 이름과 결과 모양에 따른 이름이 섞여 나와요.

| 놓이는 자리 | 부르는 이름 | 하는 일 |
|---|---|---|
| SELECT 절 | 스칼라 서브쿼리 | 행마다 값 하나를 가져와 열처럼 보여 줘요 |
| FROM 절 | 인라인 뷰 | 서브쿼리 결과를 표 하나처럼 써요 |
| WHERE 절, HAVING 절 | 중첩 서브쿼리 | 조건에 쓸 값을 구해요 |

| 결과 모양 | 돌려주는 것 | 다루는 곳 |
|---|---|---|
| 단일행 서브쿼리 | 한 행 | 이 개념 |
| 다중행 서브쿼리 | 여러 행 | 이 개념 |
| 다중 컬럼 서브쿼리 | 여러 열 | 두 번째 개념 |

스칼라 서브쿼리와 인라인 뷰는 이 단원의 네 번째 개념에서 다루고, 여기서는 WHERE 절과 HAVING 절의 서브쿼리를 봐요. `GROUP BY 부서번호`는 부서번호가 같은 사원끼리 묶는 절이고, HAVING은 묶은 그룹에 조건을 거는 절이에요.

{HAVING_AVERAGE_EXAMPLE.markdown}

부서 평균이 전체 평균 2612.5보다 높은 10번(3000)과 30번(2700)만 남았어요. 20번은 평균이 2600이라 빠지고, 부서번호가 NULL인 윤서연은 혼자 한 그룹이 되지만 평균 2000이라 빠져요.

## 단일행 서브쿼리 — 등호 뒤에는 한 행만 {{#single-row}}

| 용어 | 뜻 |
|---|---|
| 단일행 서브쿼리 | 실행 결과가 딱 한 행인 서브쿼리예요 |
| 단일행 연산자 | 값 하나와 비교하는 `=`, `<>`, `>`, `>=`, `<`, `<=`예요. 오른쪽에는 단일행 서브쿼리만 올 수 있어요 |

```sql
SELECT 이름
FROM 사원
WHERE 부서번호 = (SELECT 부서번호 FROM 사원 WHERE 이름 = '박서준');  -- 서브쿼리가 20 하나만 돌려줘요

SELECT 이름
FROM 사원
WHERE 급여 = (SELECT 급여 FROM 사원 WHERE 부서번호 = 20);  -- 오류: 급여 세 개가 한꺼번에 돌아와요
```

첫 번째 SQL은 20번 부서의 이지은, 박서준, 정하늘을 돌려줘요. 두 번째 SQL은 2500, 2800, 2500 세 행이 돌아와서 ORA-01427(단일행 서브쿼리가 여러 행을 돌려줌) 오류가 나요.

| 헷갈리는 말 | 실제로는 |
|---|---|
| 단일행인지는 SQL 모양을 보면 알 수 있어요 | 실행했을 때 돌아온 행 수로 정해져요. `급여 = (SELECT 급여 FROM 사원 WHERE 부서번호 = 10)`은 10번 사원이 김민수 한 명이라 오류 없이 김민수를 돌려줘요 |
| 집계 함수를 쓴 서브쿼리도 `=` 뒤에 두면 위험해요 | GROUP BY 없이 `AVG`나 `MAX`(가장 큰 값) 같은 집계 함수만 쓴 서브쿼리는 언제나 한 행이라 이 오류가 나지 않아요 |

## 다중행 서브쿼리 — IN·ANY·ALL·EXISTS {{#multi-row}}

여러 행이 돌아올 수 있는 서브쿼리는 다중행 연산자 `IN`, `ANY`(같은 뜻으로 `SOME`), `ALL`, `EXISTS`와 함께 써요. 아래 표는 20번 부서 급여 2500, 2800, 2500을 돌려주는 `(SELECT 급여 FROM 사원 WHERE 부서번호 = 20)`을 연산자마다 붙인 결과예요.

| 조건 | 참이 되는 경우 | 바꿔 말하면 | 결과 |
|---|---|---|---|
| `급여 IN (서브쿼리)` | 어느 하나와 같을 때 | `= ANY` | 이지은, 박서준, 정하늘 |
| `급여 > ANY (서브쿼리)` | 어느 하나보다 클 때 | 최솟값 2500보다 크면 | 김민수, 박서준, 최유나, 한도윤 |
| `급여 > ALL (서브쿼리)` | 모두보다 클 때 | 최댓값 2800보다 커야 | 김민수, 최유나 |
| `급여 < ANY (서브쿼리)` | 어느 하나보다 작을 때 | 최댓값 2800보다 작으면 | 이지은, 정하늘, 한도윤, 오지민, 윤서연 |
| `급여 < ALL (서브쿼리)` | 모두보다 작을 때 | 최솟값 2500보다 작아야 | 오지민, 윤서연 |

| 연산자 | 한 줄 공식 |
|---|---|
| ANY | 하나만 이기면 참: `> ANY`는 최솟값보다 크면, `< ANY`는 최댓값보다 작으면 돼요 |
| ALL | 모두 이겨야 참: `> ALL`은 최댓값보다 커야, `< ALL`은 최솟값보다 작아야 해요 |

```sql
SELECT 이름 FROM 사원
WHERE 급여 > ANY (SELECT 급여 FROM 사원 WHERE 부서번호 = 20);  -- 2500보다 크면 남아요

SELECT 이름 FROM 사원
WHERE 급여 > ALL (SELECT 급여 FROM 사원 WHERE 부서번호 = 20);  -- 2800보다 커야 남아요
```

급여순으로 세우면 `> ANY`는 최솟값 2500에서 끊겨요.

| 행 | 처리 |
|---|---|
| 최유나 3200 | 남음 |
| 김민수 3000 | 남음 |
| 박서준 2800 | 남음 |
| 한도윤 2700 | 남음 |
| 이지은 2500 | 빠짐 |
| 정하늘 2500 | 빠짐 |
| 오지민 2200 | 빠짐 |
| 윤서연 2000 | 빠짐 |

`> ALL`은 최댓값 2800에서 끊겨서 박서준도 빠져요.

| 행 | 처리 |
|---|---|
| 최유나 3200 | 남음 |
| 김민수 3000 | 남음 |
| 박서준 2800 | 빠짐 |
| 한도윤 2700 | 빠짐 |
| 이지은 2500 | 빠짐 |
| 정하늘 2500 | 빠짐 |
| 오지민 2200 | 빠짐 |
| 윤서연 2000 | 빠짐 |

`NOT IN`은 어느 것과도 같지 않을 때 참이라서 `<> ALL`과 같아요. `EXISTS`는 값을 비교하지 않고 행이 있는지만 보는데, 세 번째 개념에서 연관 서브쿼리와 함께 다뤄요.

## 자주 헷갈리는 점 — 방향, 0행, NULL, 쓸 수 없는 문법 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| `> ANY`는 최댓값보다 커야 참이에요 | 어느 하나보다만 크면 되니 최솟값보다 크면 참이에요. 최댓값보다 커야 하는 것은 `> ALL`이에요 |
| `> ALL`을 통과한 행이 `> ANY`에서는 빠질 수 있어요 | 같은 서브쿼리라면 ALL을 통과한 행은 ANY도 통과해요. 위 표에서 김민수와 최유나가 양쪽에 다 있어요 |
| `=` 뒤 서브쿼리가 0행이면 오류가 나요 | 오류 없이 그 자리가 NULL이 돼요. 비교가 UNKNOWN이 되고 WHERE는 참인 행만 남기므로 0행이에요 |
| 서브쿼리 안에서 ORDER BY로 정렬해 둘 수 있어요 | WHERE 절 서브쿼리 안의 ORDER BY는 ORA-00907(오른쪽 괄호가 없음) 오류예요. 정렬은 메인 쿼리 맨 끝이나 인라인 뷰 안에서 해요 |
| 메인 쿼리에서 서브쿼리의 열을 꺼내 쓸 수 있어요 | WHERE 절 서브쿼리는 조건 판단에만 쓰여서 열을 밖으로 내보내지 않아요. ORA-00904(없는 열 이름) 오류가 나요 |
| 다중행 연산자는 결과가 두 행 이상일 때만 써요 | `IN`은 한 행과도 비교할 수 있어요. 행 수가 확실하지 않으면 `=` 대신 `IN`을 쓰면 오류가 나지 않아요 |

서브쿼리가 0행일 때는 연산자마다 결과가 갈라져요. 인사부(40번)에는 사원이 없어서 `(SELECT 급여 FROM 사원 WHERE 부서번호 = 40)`은 아무 행도 돌려주지 않아요.

| 조건 | 사원 8명 중 남는 사원 | 이유 |
|---|---|---|
| `급여 = (서브쿼리)` | 0명 | 그 자리가 NULL이라 UNKNOWN이에요 |
| `급여 > ANY (서브쿼리)` | 0명 | 이길 상대가 하나도 없어서 거짓이에요 |
| `급여 > ALL (서브쿼리)` | 8명 | 조건을 깨는 값도 하나도 없어서 참이에요 |
| `급여 > (SELECT MAX(급여) FROM 사원 WHERE 부서번호 = 40)` | 0명 | 빈 결과의 MAX는 NULL이에요 |
| `급여 NOT IN (서브쿼리)` | 8명 | 같은 값이 없으니 모두 참이에요 |

{EMPTY_ALL_EXAMPLE.markdown}

평소에는 `> ALL`과 `> MAX`가 같은 결과를 내지만, 서브쿼리가 0행일 때만 둘이 갈라져요.

서브쿼리 결과에 NULL이 섞이면 ALL과 NOT IN은 0행이 되기 쉬운데, NOT IN은 세 번째 개념에서 NOT EXISTS와 비교해요. `급여 > ALL (SELECT 커미션 FROM 사원)`은 숫자 커미션은 모두 넘지만 NULL과의 비교가 UNKNOWN이라 참이 확정되지 않아서 0행이에요.

```sql
SELECT 이름 FROM 사원
WHERE 급여 IN (SELECT 급여 FROM 사원 ORDER BY 급여);  -- 오류: 괄호 안에 ORDER BY가 있어요

SELECT e.이름, s.급여
FROM 사원 e
WHERE e.급여 > (SELECT AVG(s.급여) FROM 사원 s);  -- 오류: 바깥에서는 s를 알 수 없어요
```

반대로 서브쿼리 안에서 메인 쿼리의 열을 가져다 쓰는 것은 가능해요. 이런 서브쿼리를 연관 서브쿼리라고 하고, 세 번째 개념에서 다뤄요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `급여 < ALL (서브쿼리)`는 서브쿼리 최솟값보다 작아야 참이에요 | O | 모두보다 작아야 하니 가장 작은 값보다도 작아야 해요 |
| `SOME`은 `ALL`과 같은 뜻이에요 | X | `SOME`은 `ANY`와 같은 뜻이에요 |
| 서브쿼리가 0행이면 `급여 NOT IN (서브쿼리)`는 모든 행을 남겨요 | O | 비교할 값이 없어서 "어느 것과도 같지 않다"가 모든 행에서 참이에요 |

## 시험에서는 이렇게 나와요 — 최솟값·최댓값부터 적기 {{#exam-point}}

예시 표와 함께 `> ANY`, `> ALL`, `< ANY`, `< ALL`의 결과를 묻는 문제가 가장 많이 나와요. 아래 순서로 풀면 방향을 헷갈리지 않아요.

| 단계 | 내용 |
|---|---|
| 서브쿼리 결과 적기 | 서브쿼리만 따로 실행했다고 보고 값을 적어요. 0행인지, NULL이 있는지도 봐요 |
| 최솟값·최댓값 적기 | ANY와 ALL은 결국 최솟값이나 최댓값 하나와의 비교로 바뀌어요 |
| 조건 바꾸기 | 다중행 표대로 `> ANY`는 최솟값, `> ALL`은 최댓값과 비교하는 식으로 바꿔요 |
| 행 세기 | 메인 쿼리 표에서 바뀐 조건을 만족하는 행을 세요 |

그 밖에 `=` 뒤에 여러 행이 돌아오는 SQL이 오류인지, 서브쿼리 안의 ORDER BY처럼 쓸 수 없는 문법이 무엇인지 고르는 문제가 자주 나와요.""",
    "checkQuestions": [
        question(1, "서브쿼리에 대한 설명으로 알맞지 않은 것은 무엇인가요?", "confusing",
                 "WHERE 절 서브쿼리 안에 ORDER BY를 쓰면 ORA-00907(오른쪽 괄호가 없음) 오류가 나요. 정렬은 메인 쿼리 맨 끝이나 인라인 뷰 안에서 해요.",
                 [choice("A", "서브쿼리는 괄호로 감싸서 쓴다", rationale="서브쿼리는 어디에 쓰든 괄호로 감싸요."),
                  choice("B", "FROM 절에 쓴 서브쿼리는 인라인 뷰라고 부른다", rationale="놓인 자리에 따른 올바른 이름이에요."),
                  choice("C", "WHERE 절 서브쿼리 안에 ORDER BY를 써서 결과를 정렬할 수 있다", True,
                         "WHERE 절 서브쿼리 안의 ORDER BY는 문법 오류라서 틀린 설명이에요."),
                  choice("D", "단일행 연산자와 함께 쓴 서브쿼리는 한 행만 돌려줘야 한다", rationale="여러 행이 돌아오면 오류가 나므로 맞는 설명이에요.")]),
        question(2, "아래 사원 표에 다음 SQL을 실행하면 어떻게 되나요?\n\n" + EMPLOYEE_SALARY_TABLE, "single-row",
                 "20번 부서 사원은 세 명이라 서브쿼리가 세 행을 돌려줘요. `=`는 값 하나와만 비교할 수 있어서 ORA-01427(단일행 서브쿼리가 여러 행을 돌려줌) 오류가 나요.",
                 [choice("A", "이지은, 박서준, 정하늘이 나온다", rationale="IN을 썼을 때의 결과이고, 등호로는 여러 값과 비교할 수 없어요."),
                  choice("B", "오류가 난다", True, "단일행 연산자 자리에 세 행이 돌아와서 오류가 나요."),
                  choice("C", "0행이 나온다", rationale="0행이 아니라 실행 중에 오류가 나요."),
                  choice("D", "첫 번째 행의 급여 2500과 같은 이지은, 정하늘이 나온다", rationale="Oracle은 첫 행만 골라 비교하지 않고 오류를 내요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE 급여 = (SELECT 급여 FROM 사원 WHERE 부서번호 = 20);"),
        question(3, "아래 사원 표에 다음 SQL을 실행한 결과로 알맞은 것은 무엇인가요?\n\n" + EMPLOYEE_SALARY_TABLE, "multi-row",
                 "20번 부서 급여는 2500, 2800, 2500이고, `> ALL`은 최댓값 2800보다 커야 참이에요. 2800보다 급여가 많은 사원은 김민수(3000)와 최유나(3200)예요.",
                 [choice("A", "김민수, 최유나", True, "최댓값 2800보다 급여가 많은 두 명이에요."),
                  choice("B", "김민수, 박서준, 최유나, 한도윤", rationale="최솟값 2500보다 큰 사원을 고른 > ANY의 결과예요."),
                  choice("C", "최유나", rationale="김민수의 급여 3000도 2800보다 커요."),
                  choice("D", "0행", rationale="2800보다 급여가 많은 사원이 두 명 있어요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE 급여 > ALL (SELECT 급여 FROM 사원 WHERE 부서번호 = 20);"),
        question(4, "인사부(40번)에는 사원이 한 명도 없어요. 사원 8명이 있는 표에 다음 SQL을 실행하면 몇 행이 나오나요?", "confusing",
                 "서브쿼리가 0행이면 `> ALL`의 조건을 깨는 값이 하나도 없어서 모든 행에서 참이 돼요. 그래서 사원 8명이 모두 나와요.",
                 [choice("A", "0행", rationale="등호나 > ANY는 0행이 되지만, > ALL은 모든 행에서 참이 돼요."),
                  choice("B", "1행", rationale="한 행만 고르는 기준이 없어요."),
                  choice("C", "오류가 난다", rationale="서브쿼리가 0행이어도 오류는 나지 않아요."),
                  choice("D", "8행", True, "조건을 깨는 값이 없으니 모두보다 크다가 참이 되어 전부 나와요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE 급여 > ALL (SELECT 급여 FROM 사원 WHERE 부서번호 = 40);"),
        question(5, "`급여 < ANY (서브쿼리)`와 같은 뜻인 조건은 무엇인가요? (서브쿼리 결과는 1행 이상이고 NULL이 없어요)", "multi-row",
                 "`< ANY`는 급여가 결과 중 어느 하나보다 작으면 참이므로, 가장 큰 값보다만 작으면 돼요. 그래서 서브쿼리 최댓값보다 작다는 뜻이에요.",
                 [choice("A", "급여가 서브쿼리 결과의 최솟값보다 작다", rationale="최솟값보다 작아야 하는 것은 < ALL이에요."),
                  choice("B", "급여가 서브쿼리 결과의 최댓값보다 작다", True, "어느 하나보다 작으면 되니 최댓값보다만 작으면 돼요."),
                  choice("C", "급여가 서브쿼리 결과의 최솟값보다 크다", rationale="> ANY의 뜻이에요."),
                  choice("D", "급여가 서브쿼리 결과 중 하나와 같다", rationale="IN 또는 = ANY의 뜻이에요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 결과 표
        AVERAGE_ABOVE_EXAMPLE.check,
        HAVING_AVERAGE_EXAMPLE.check,
        EMPTY_ALL_EXAMPLE.check,
        sql_check("SELECT AVG(급여) FROM 사원", [[2612.5]]),
        sql_check("SELECT 부서번호, AVG(급여) FROM 사원 GROUP BY 부서번호",
                  [[10, 3000], [20, 2600], [30, 2700], [None, 2000]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 = (SELECT 부서번호 FROM 사원 WHERE 이름 = '박서준')",
                  [["이지은"], ["박서준"], ["정하늘"]]),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 급여 = (SELECT 급여 FROM 사원 WHERE 부서번호 = 20);", "ORA-01427"),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 = (SELECT 급여 FROM 사원 WHERE 부서번호 = 10)", [["김민수"]]),
        # 다중행 연산자 대응표 (20번 부서 급여 2500, 2800, 2500)
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 IN (SELECT 급여 FROM 사원 WHERE 부서번호 = 20)",
                  [["이지은"], ["박서준"], ["정하늘"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 = ANY (SELECT 급여 FROM 사원 WHERE 부서번호 = 20)",
                  [["이지은"], ["박서준"], ["정하늘"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 > ANY (SELECT 급여 FROM 사원 WHERE 부서번호 = 20)",
                  [["김민수"], ["박서준"], ["최유나"], ["한도윤"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 > SOME (SELECT 급여 FROM 사원 WHERE 부서번호 = 20)",
                  [["김민수"], ["박서준"], ["최유나"], ["한도윤"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 > ALL (SELECT 급여 FROM 사원 WHERE 부서번호 = 20);",
                  [["김민수"], ["최유나"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 < ANY (SELECT 급여 FROM 사원 WHERE 부서번호 = 20)",
                  [["이지은"], ["정하늘"], ["한도윤"], ["오지민"], ["윤서연"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 < ALL (SELECT 급여 FROM 사원 WHERE 부서번호 = 20)",
                  [["오지민"], ["윤서연"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 NOT IN (SELECT 급여 FROM 사원 WHERE 부서번호 = 20) "
                  "MINUS SELECT 이름 FROM 사원 WHERE 급여 <> ALL (SELECT 급여 FROM 사원 WHERE 부서번호 = 20)", []),
        # 서브쿼리 0행 (40번 부서)
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 급여 = (SELECT 급여 FROM 사원 WHERE 부서번호 = 40)", [[0]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 급여 > ANY (SELECT 급여 FROM 사원 WHERE 부서번호 = 40)", [[0]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 급여 > ALL (SELECT 급여 FROM 사원 WHERE 부서번호 = 40)", [[8]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 > ALL (SELECT 급여 FROM 사원 WHERE 부서번호 = 40);",
                  [["김민수"], ["이지은"], ["박서준"], ["최유나"], ["정하늘"], ["한도윤"], ["오지민"], ["윤서연"]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 급여 > (SELECT MAX(급여) FROM 사원 WHERE 부서번호 = 40)", [[0]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 급여 NOT IN (SELECT 급여 FROM 사원 WHERE 부서번호 = 40)", [[8]]),
        # NULL 섞인 ALL, 문법 오류 2개
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 > ALL (SELECT 커미션 FROM 사원)", []),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 > ALL (SELECT 커미션 FROM 사원 WHERE 커미션 IS NOT NULL)",
                  [["김민수"], ["이지은"], ["박서준"], ["최유나"], ["정하늘"], ["한도윤"], ["오지민"], ["윤서연"]]),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 급여 IN (SELECT 급여 FROM 사원 ORDER BY 급여)", "ORA-00907"),
        sql_error_check("SELECT e.이름, s.급여 FROM 사원 e WHERE e.급여 > (SELECT AVG(s.급여) FROM 사원 s)", "ORA-00904"),
        # 한 행만 돌아오면 IN 도 그대로 동작
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 IN (SELECT 부서번호 FROM 사원 WHERE 이름 = '박서준')",
                  [["이지은"], ["박서준"], ["정하늘"]]),
    ],
}
