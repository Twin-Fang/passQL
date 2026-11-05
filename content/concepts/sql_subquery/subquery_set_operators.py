"""개념: 집합 연산자 (6단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import DEPARTMENT_TABLE_MD, to_employee_table_md

# 이 개념의 계산에 쓰는 열 전부 (직급·급여·커미션·부서번호)
EMPLOYEE_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "커미션", "부서번호")

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
FIRST_ALIAS_ORDER_EXAMPLE = sql_example(
    """SELECT 이름 AS 사원명, 급여 FROM 사원 WHERE 부서번호 = 10
UNION
SELECT 이름 AS 직원, 급여 FROM 사원 WHERE 부서번호 = 20
ORDER BY 급여 DESC, 사원명;""",
    ("사원명", "급여"), [["김민수", 3000], ["박서준", 2800], ["이지은", 2500], ["정하늘", 2500]])
MINUS_DISTINCT_EXAMPLE = sql_example(
    """SELECT 부서번호 FROM 사원
MINUS
SELECT 부서번호 FROM 부서 WHERE 부서번호 = 10;""",
    ("부서번호",), [[20], [30], [None]], is_ordered=False)
# 연산 순서: 위에서부터 <-> 괄호 (세 SELECT 결과 10·40 / 10·20·30 / 20·30·NULL)
TOP_DOWN_ORDER_EXAMPLE = sql_example(
    """SELECT 부서번호 FROM 부서 WHERE 지역 = '서울'
UNION
SELECT 부서번호 FROM 사원 WHERE 급여 >= 2800
INTERSECT
SELECT 부서번호 FROM 사원 WHERE 직급 = '사원';""",
    ("부서번호",), [[20], [30]], is_ordered=False)
PARENTHESIS_ORDER_EXAMPLE = sql_example(
    """SELECT 부서번호 FROM 부서 WHERE 지역 = '서울'
UNION
(SELECT 부서번호 FROM 사원 WHERE 급여 >= 2800
 INTERSECT
 SELECT 부서번호 FROM 사원 WHERE 직급 = '사원');""",
    ("부서번호",), [[10], [20], [30], [40]], is_ordered=False)

CONCEPT = {
    "tagKey": "subquery-set-operators",
    "topicCode": "sql_subquery",
    "sortOrder": 6,
    "title": "집합 연산자",
    "summary": "두 SELECT 결과를 위아래로 합치거나, 겹치는 행이나 빼고 남은 행을 구해요",
    "coreMd": (
        "- 중복을 남기는 것은 `UNION ALL`뿐이고, `UNION`·`INTERSECT`·`MINUS`는 중복을 없애요.\n"
        "- `MINUS`는 순서를 바꾸면 결과가 달라지고, SQL Server에서는 `EXCEPT`라고 불러요.\n"
        "- 열 개수와 타입이 맞아야 하고, 결과 열 이름은 첫 SELECT를 따르며, ORDER BY는 맨 끝에 한 번만 써요.\n"
        "- 집합 연산자는 NULL끼리 같은 값으로 보고 중복을 없애요.\n"
        "- Oracle은 집합 연산자의 우선순위가 모두 같아서 위에서부터 계산해요."
    ),
    "detailMd": f"""## 서로 다른 SELECT 결과 묶기 — 벤 다이어그램처럼 {{#why}}

같은 테이블 안의 조건은 OR나 AND로 묶으면 되지만, 서로 다른 SELECT 문이 만든 결과끼리는 WHERE 절로 묶을 수 없어요. 집합 연산자는 두 결과를 벤 다이어그램처럼 합치거나, 겹치는 부분만 보거나, 한쪽에서 겹치는 부분을 빼 줘요.

예시는 모두 아래 두 표로 계산해요. 개발부는 20번이고, 윤서연(1008)은 부서번호가 NULL이에요.

{EMPLOYEE_TABLE}

{DEPARTMENT_TABLE_MD}

## 한 줄 정의 — 결과 행을 아래로 붙여요 {{#definition}}

| 용어 | 뜻 |
|---|---|
| 집합 연산자 (Set Operator) | 두 SELECT 문의 결과를 위아래로 이어서 하나의 결과로 만드는 연산자예요 |

| 비교 | 조인 | 집합 연산자 |
|---|---|---|
| 붙이는 방향 | 다른 테이블의 열을 옆으로 | 같은 모양의 결과 행을 아래로 |

개발부 사원 A(이지은, 박서준, 정하늘)와 급여 2700 이상인 사원 B(김민수, 박서준, 최유나, 한도윤)로 비교해 봐요. 두 명단에 모두 있는 사람은 박서준 한 명이에요.

| 연산자 | 뜻 | 결과 |
|---|---|---|
| `UNION` | 합집합, 중복은 하나만 | 이지은, 박서준, 정하늘, 김민수, 최유나, 한도윤 (6행) |
| `UNION ALL` | 합집합, 중복도 그대로 | 위 여섯 명에 박서준이 한 번 더 (7행) |
| `INTERSECT` | 교집합 | 박서준 (1행) |
| `MINUS` | 차집합, A에서 B를 뺌 | 이지은, 정하늘 (2행) |

```sql
SELECT 이름 FROM 사원 WHERE 부서번호 = 20
UNION
SELECT 이름 FROM 사원 WHERE 급여 >= 2700;  -- 박서준은 한 번만 나와요

SELECT 이름 FROM 사원 WHERE 부서번호 = 20
UNION ALL
SELECT 이름 FROM 사원 WHERE 급여 >= 2700;  -- 박서준이 두 번 나와요

SELECT 이름 FROM 사원 WHERE 부서번호 = 20
INTERSECT
SELECT 이름 FROM 사원 WHERE 급여 >= 2700;  -- 양쪽에 다 있는 박서준만 나와요

SELECT 이름 FROM 사원 WHERE 부서번호 = 20
MINUS
SELECT 이름 FROM 사원 WHERE 급여 >= 2700;  -- A에서 박서준을 뺀 두 명이 나와요
```

UNION, UNION ALL, INTERSECT는 위아래를 바꿔도 결과 행이 같지만, MINUS는 순서가 바뀌면 결과가 달라져요. B MINUS A로 쓰면 개발부가 아닌 김민수, 최유나, 한도윤이 나오고, SQL Server에서는 MINUS를 EXCEPT라고 불러요.

## 쓰는 규칙 — 열 개수·타입·열 이름·ORDER BY {{#rules}}

| 규칙 | 어기면 |
|---|---|
| 위아래 SELECT의 열 개수가 같아야 해요 | ORA-01789(결과 열 개수가 맞지 않음) 오류예요 |
| 같은 위치의 열끼리 데이터 타입이 맞아야 해요 | 숫자 열과 날짜 열처럼 다르면 ORA-01790(같은 위치의 열 타입이 다름) 오류예요 |
| 결과 열 이름은 첫 번째 SELECT의 열 이름이나 별칭을 따라요 | ORDER BY에 두 번째 SELECT의 별칭을 쓰면 ORA-00904(없는 열 이름) 오류예요 |
| ORDER BY는 맨 마지막 SELECT 뒤에 한 번만 써요 | 중간에 쓰면 ORA-00933(SQL 문이 제대로 끝나지 않음) 오류예요 |

ORDER BY의 정렬 기준으로는 첫 번째 SELECT의 열 이름이나 별칭, 또는 열 위치 번호를 써요. 아래 결과의 열 이름도 두 번째 SELECT의 `직원`이 아니라 첫 번째의 `사원명`이에요.

{FIRST_ALIAS_ORDER_EXAMPLE.markdown}

```sql
SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 10
UNION
SELECT 이름 FROM 사원 WHERE 부서번호 = 20;  -- 오류: 위는 열이 두 개, 아래는 한 개예요

SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 10
UNION
SELECT 이름, 입사일 FROM 사원 WHERE 부서번호 = 20;  -- 오류: 급여는 숫자, 입사일은 날짜예요

SELECT 이름 AS 사원명, 급여 FROM 사원 WHERE 부서번호 = 10
UNION
SELECT 이름 AS 직원, 급여 FROM 사원 WHERE 부서번호 = 20
ORDER BY 직원;  -- 오류: 두 번째 SELECT의 별칭은 쓸 수 없어요

SELECT 이름 FROM 사원 WHERE 부서번호 = 10
ORDER BY 이름
UNION
SELECT 이름 FROM 사원 WHERE 부서번호 = 20;  -- 오류: ORDER BY는 맨 끝에만 올 수 있어요
```

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 집합 연산 결과의 열 이름은 마지막 SELECT를 따라요 | X | 첫 번째 SELECT의 열 이름이나 별칭을 따라요 |
| `ORDER BY 2`처럼 열 위치 번호로 정렬할 수 있어요 | O | 첫 번째 SELECT의 열 이름, 별칭, 위치 번호를 쓸 수 있어요 |

## 자주 헷갈리는 점 — 중복, NULL, 계산 순서 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| UNION만 중복을 없애요 | INTERSECT와 MINUS도 중복을 없애요. 중복을 남기는 것은 UNION ALL뿐이에요 |
| 집합 연산자에서도 NULL끼리는 같지 않아요 | WHERE 절의 `NULL = NULL`은 UNKNOWN이지만, 집합 연산자는 중복을 가릴 때 NULL끼리 같은 행으로 봐요 |
| 공통 값이 NULL뿐이면 INTERSECT는 0행이에요 | NULL끼리 같은 값으로 보니 NULL 한 행이 나와요 |
| INTERSECT를 다른 연산자보다 먼저 계산해요 | Oracle은 우선순위가 모두 같아서 괄호가 없으면 위에서부터 계산해요. INTERSECT를 먼저 하는 것은 SQL Server예요 |
| UNION하면 결과가 정렬돼요 | 중복을 찾느라 정렬된 것처럼 보일 때가 있지만 보장되지 않아요. 순서가 필요하면 맨 끝에 ORDER BY를 붙여요 |
| UNION과 UNION ALL은 속도가 같아요 | UNION은 중복을 찾아 없애는 작업을 한 번 더 해요. 처음부터 겹칠 수 없다면 UNION ALL이 더 빨라요 |
| Oracle에서는 EXCEPT를 쓸 수 없어요 | 시험은 "Oracle은 MINUS, SQL Server는 EXCEPT"로 구분해요. Oracle도 21c부터 EXCEPT를 함께 받아 주지만 보기는 MINUS 기준이에요 |

사원 8명의 부서번호(10, 20, 20, 30, 20, 30, 30, NULL)에서 10번만 빼면, 20과 30이 세 번씩 남지 않고 세 행만 나와요.

{MINUS_DISTINCT_EXAMPLE.markdown}

20번 부서의 커미션은 300, 0, NULL이고, 30번 부서의 커미션은 NULL, 500, 200이에요. 같은 두 결과에 세 연산자를 붙이면 NULL이 이렇게 다뤄져요.

```sql
SELECT 커미션 FROM 사원 WHERE 부서번호 = 20
UNION
SELECT 커미션 FROM 사원 WHERE 부서번호 = 30;

SELECT 커미션 FROM 사원 WHERE 부서번호 = 20
UNION ALL
SELECT 커미션 FROM 사원 WHERE 부서번호 = 30;

SELECT 커미션 FROM 사원 WHERE 부서번호 = 20
INTERSECT
SELECT 커미션 FROM 사원 WHERE 부서번호 = 30;
```

| 연산자 | 결과 | 행 수 |
|---|---|---|
| UNION | 300, 0, NULL, 500, 200 (NULL은 한 번) | 5 |
| UNION ALL | 300, 0, NULL, NULL, 500, 200 | 6 |
| INTERSECT | NULL | 1 |

연산자가 여러 개면 같은 세 SELECT라도 괄호에 따라 결과가 달라요. 세 SELECT는 차례로 (10, 40), (10, 20, 30), (20, 30, NULL)을 돌려줘요.

{TOP_DOWN_ORDER_EXAMPLE.markdown}

{PARENTHESIS_ORDER_EXAMPLE.markdown}

| 계산 순서 | 첫 계산 | 두 번째 계산 | 행 수 |
|---|---|---|---|
| 괄호 없음 (위에서부터) | UNION으로 10, 20, 30, 40 | (20, 30, NULL)과 겹치는 20, 30 | 2 |
| 괄호로 INTERSECT 먼저 | (10, 20, 30)과 (20, 30, NULL)이 겹치는 20, 30 | (10, 40)과 합쳐 10, 20, 30, 40 | 4 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `A MINUS B`와 `B MINUS A`는 결과가 같아요 | X | 차집합은 앞에서 뒤를 빼므로 순서가 바뀌면 결과가 달라져요 |
| INTERSECT의 결과에는 같은 행이 두 번 나오지 않아요 | O | UNION ALL을 뺀 집합 연산자는 모두 중복을 없애요 |

## 시험에서는 이렇게 나와요 — 값 목록으로 적고 세기 {{#exam-point}}

두 표를 주고 집합 연산 결과의 행 수를 묻는 문제가 가장 많이 나와요. 아래 순서로 세면 돼요.

| 단계 | 내용 |
|---|---|
| 값 목록 적기 | SELECT마다 결과를 값 목록으로 적어요 |
| 계산 순서 정하기 | 괄호가 없으면 위에서부터 하나씩 계산해요 |
| 중복 줄이기 | UNION ALL이 아니면 중복을 하나로 줄이고, NULL도 같은 값으로 묶어요 |

부서 표(부서번호 4개)와 사원 표(부서번호 8개)로 연습해 보면 아래와 같아요.

| SQL | 결과 | 행 수 |
|---|---|---|
| 부서의 부서번호 UNION ALL 사원의 부서번호 | 4행과 8행을 그대로 이어 붙임 | 12 |
| 부서의 부서번호 UNION 사원의 부서번호 | 10, 20, 30, 40, NULL | 5 |
| 부서의 부서번호 INTERSECT 사원의 부서번호 | 10, 20, 30 | 3 |
| 부서의 부서번호 MINUS 사원의 부서번호 | 40 | 1 |
| 사원의 부서번호 MINUS 부서의 부서번호 | NULL | 1 |

마지막 줄은 윤서연의 NULL이 부서 표에 없어서 남은 결과예요. 그 밖에 규칙으로 옳지 않은 것을 고르는 문제와 연산자가 여러 개 섞인 SQL의 결과를 묻는 문제도 자주 나와요.""",
    "checkQuestions": [
        question(1, "두 SELECT 결과를 합치면서 중복 행도 그대로 남기는 집합 연산자는 무엇인가요?", "definition",
                 "UNION ALL은 두 결과를 그대로 이어 붙이기만 해서 중복 행이 남아요. UNION, INTERSECT, MINUS는 결과에서 중복을 없애요.",
                 [choice("A", "UNION", rationale="UNION은 중복 행을 하나로 줄여요."),
                  choice("B", "INTERSECT", rationale="INTERSECT는 양쪽에 모두 있는 행만 중복 없이 돌려줘요."),
                  choice("C", "UNION ALL", True, "중복을 없애는 작업 없이 그대로 이어 붙여요."),
                  choice("D", "MINUS", rationale="MINUS는 앞 결과에서 뒤 결과를 뺀 행을 중복 없이 돌려줘요.")]),
        question(2, "집합 연산자의 규칙으로 알맞지 않은 것은 무엇인가요?", "rules",
                 "결과 열 이름은 첫 번째 SELECT의 열 이름이나 별칭을 따라요. 그래서 ORDER BY에서도 첫 번째 SELECT의 이름을 써야 해요.",
                 [choice("A", "위아래 SELECT의 열 개수가 같아야 한다", rationale="개수가 다르면 결과 열 개수가 맞지 않는다는 오류가 나므로 맞는 규칙이에요."),
                  choice("B", "결과 열 이름은 마지막 SELECT의 열 이름을 따른다", True, "결과 열 이름은 첫 번째 SELECT를 따라서 틀린 설명이에요."),
                  choice("C", "ORDER BY는 맨 마지막에 한 번만 쓴다", rationale="중간에 쓰면 문법 오류가 나므로 맞는 규칙이에요."),
                  choice("D", "같은 위치의 열끼리 데이터 타입이 맞아야 한다", rationale="타입이 맞지 않으면 열 타입이 다르다는 오류가 나므로 맞는 규칙이에요.")]),
        question(3, "급여가 2600보다 적은 사원의 부서번호는 20, 20, 30, NULL이고, 서울에 있는 부서의 부서번호는 10, 40이에요. 다음 SQL은 몇 행을 돌려주나요?", "confusing",
                 "UNION은 두 결과를 합친 뒤 중복을 하나로 줄이므로, 20이 두 번 있어도 한 행이 돼요. 그래서 20, 30, NULL, 10, 40의 5행이 나와요.",
                 [choice("A", "6행", rationale="중복을 그대로 남기는 UNION ALL의 행 수예요."),
                  choice("B", "4행", rationale="NULL도 한 행으로 남기 때문에 하나를 더 세야 해요."),
                  choice("C", "3행", rationale="서울 부서의 10과 40도 합쳐지므로 세 행보다 많아요."),
                  choice("D", "5행", True, "20, 30, NULL, 10, 40 다섯 행이에요.")],
                 stem_sql="SELECT 부서번호 FROM 사원 WHERE 급여 < 2600 UNION SELECT 부서번호 FROM 부서 WHERE 지역 = '서울';"),
        question(4, "20번 부서 사원의 커미션은 300, 0, NULL이고, 30번 부서 사원의 커미션은 NULL, 500, 200이에요. 다음 SQL의 결과는 무엇인가요?", "confusing",
                 "집합 연산자는 NULL끼리를 같은 값으로 봐요. 두 결과에 공통으로 있는 값은 NULL뿐이라서 NULL이 담긴 한 행이 나와요.",
                 [choice("A", "NULL이 담긴 1행", True, "양쪽의 NULL을 같은 값으로 보고 교집합에 남겨요."),
                  choice("B", "0행", rationale="WHERE 절 비교와 달리 집합 연산자는 NULL끼리 같다고 봐요."),
                  choice("C", "오류가 난다", rationale="위아래 열 개수와 타입이 같아서 오류가 나지 않아요."),
                  choice("D", "6행", rationale="중복을 남기고 이어 붙인 UNION ALL의 행 수예요.")],
                 stem_sql="SELECT 커미션 FROM 사원 WHERE 부서번호 = 20 INTERSECT SELECT 커미션 FROM 사원 WHERE 부서번호 = 30;"),
        question(5, "아래 SQL의 세 SELECT는 차례로 (10, 20, 30, 40), (20, 30, NULL), (30)을 돌려줘요. Oracle에서 이 SQL은 몇 행을 돌려주나요?", "confusing",
                 "Oracle은 괄호가 없으면 위에서부터 계산해서, MINUS로 (10, 40)을 먼저 만든 뒤 (30)과 UNION 해요. 그래서 10, 30, 40의 3행이 나와요.",
                 [choice("A", "2행", rationale="뒤의 UNION을 먼저 계산했을 때의 결과이고, Oracle은 위에서부터 계산해요."),
                  choice("B", "3행", True, "(10, 40)에 30을 합친 10, 30, 40이 남아요."),
                  choice("C", "4행", rationale="MINUS로 20과 30이 빠진 뒤 30만 다시 들어오므로 네 행이 되지 않아요."),
                  choice("D", "오류가 난다", rationale="집합 연산자는 여러 개를 이어 쓸 수 있어서 오류가 나지 않아요.")],
                 stem_sql="SELECT 부서번호 FROM 부서 MINUS SELECT 부서번호 FROM 사원 WHERE 직급 = '사원' "
                          "UNION SELECT 부서번호 FROM 사원 WHERE 급여 >= 3200;"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 결과 표
        FIRST_ALIAS_ORDER_EXAMPLE.check,
        MINUS_DISTINCT_EXAMPLE.check,
        TOP_DOWN_ORDER_EXAMPLE.check,
        PARENTHESIS_ORDER_EXAMPLE.check,
        # 네 연산자 (개발부 <-> 급여 2700 이상)
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 = 20 UNION SELECT 이름 FROM 사원 WHERE 급여 >= 2700",
                  [["이지은"], ["박서준"], ["정하늘"], ["김민수"], ["최유나"], ["한도윤"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 = 20 UNION ALL SELECT 이름 FROM 사원 WHERE 급여 >= 2700",
                  [["이지은"], ["박서준"], ["정하늘"], ["김민수"], ["박서준"], ["최유나"], ["한도윤"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 = 20 INTERSECT SELECT 이름 FROM 사원 WHERE 급여 >= 2700",
                  [["박서준"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 = 20 MINUS SELECT 이름 FROM 사원 WHERE 급여 >= 2700",
                  [["이지은"], ["정하늘"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 >= 2700 MINUS SELECT 이름 FROM 사원 WHERE 부서번호 = 20",
                  [["김민수"], ["최유나"], ["한도윤"]]),
        # 규칙 (열 개수·타입·열 이름·ORDER BY 위치·위치 번호)
        sql_error_check("SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 10 UNION SELECT 이름 FROM 사원 WHERE 부서번호 = 20",
                        "ORA-01789"),
        sql_error_check("SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 10 UNION SELECT 이름, 입사일 FROM 사원 WHERE 부서번호 = 20",
                        "ORA-01790"),
        sql_error_check("SELECT 이름 AS 사원명, 급여 FROM 사원 WHERE 부서번호 = 10 UNION "
                        "SELECT 이름 AS 직원, 급여 FROM 사원 WHERE 부서번호 = 20 ORDER BY 직원", "ORA-00904"),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 부서번호 = 10 ORDER BY 이름 UNION SELECT 이름 FROM 사원 WHERE 부서번호 = 20",
                        "ORA-00933"),
        sql_check("SELECT 이름 AS 사원명, 급여 FROM 사원 WHERE 부서번호 = 10 UNION "
                  "SELECT 이름 AS 직원, 급여 FROM 사원 WHERE 부서번호 = 20 ORDER BY 2 DESC, 1",
                  [["김민수", 3000], ["박서준", 2800], ["이지은", 2500], ["정하늘", 2500]], is_ordered=True),
        # 중복 제거·NULL (커미션: 20번 300·0·NULL, 30번 NULL·500·200)
        sql_check("SELECT 커미션 FROM 사원 WHERE 부서번호 = 20 UNION SELECT 커미션 FROM 사원 WHERE 부서번호 = 30",
                  [[300], [0], [None], [500], [200]]),
        sql_check("SELECT 커미션 FROM 사원 WHERE 부서번호 = 20 UNION ALL SELECT 커미션 FROM 사원 WHERE 부서번호 = 30",
                  [[300], [0], [None], [None], [500], [200]]),
        sql_check("SELECT 커미션 FROM 사원 WHERE 부서번호 = 20 INTERSECT SELECT 커미션 FROM 사원 WHERE 부서번호 = 30;",
                  [[None]]),
        # 연산 순서용 세 SELECT 각각의 결과
        sql_check("SELECT 부서번호 FROM 부서 WHERE 지역 = '서울'", [[10], [40]]),
        sql_check("SELECT 부서번호 FROM 사원 WHERE 급여 >= 2800", [[10], [20], [30]]),
        sql_check("SELECT 부서번호 FROM 사원 WHERE 직급 = '사원'", [[20], [30], [None]]),
        # 확인 문제 3 (급여 2600 미만 부서번호 20·20·30·NULL, 서울 부서 10·40)
        sql_check("SELECT 부서번호 FROM 사원 WHERE 급여 < 2600", [[20], [20], [30], [None]]),
        sql_check("SELECT 부서번호 FROM 사원 WHERE 급여 < 2600 UNION SELECT 부서번호 FROM 부서 WHERE 지역 = '서울';",
                  [[10], [20], [30], [40], [None]]),
        # 확인 문제 5 (세 SELECT: 10·20·30·40 / 20·30·NULL / 30): 위에서부터 3행 <-> 괄호 2행
        sql_check("SELECT 부서번호 FROM 사원 WHERE 급여 >= 3200", [[30]]),
        sql_check("SELECT 부서번호 FROM 부서 MINUS SELECT 부서번호 FROM 사원 WHERE 직급 = '사원' "
                  "UNION SELECT 부서번호 FROM 사원 WHERE 급여 >= 3200;", [[10], [30], [40]]),
        sql_check("SELECT 부서번호 FROM 부서 MINUS (SELECT 부서번호 FROM 사원 WHERE 직급 = '사원' "
                  "UNION SELECT 부서번호 FROM 사원 WHERE 급여 >= 3200)", [[10], [40]]),
        # 행 수 표 (부서 4행, 사원 8행)
        sql_check("SELECT COUNT(*) FROM (SELECT 부서번호 FROM 부서 UNION ALL SELECT 부서번호 FROM 사원)", [[12]]),
        sql_check("SELECT 부서번호 FROM 부서 UNION SELECT 부서번호 FROM 사원", [[10], [20], [30], [40], [None]]),
        sql_check("SELECT 부서번호 FROM 부서 INTERSECT SELECT 부서번호 FROM 사원", [[10], [20], [30]]),
        sql_check("SELECT 부서번호 FROM 부서 MINUS SELECT 부서번호 FROM 사원", [[40]]),
        sql_check("SELECT 부서번호 FROM 사원 MINUS SELECT 부서번호 FROM 부서", [[None]]),
        # Oracle 21c 는 EXCEPT 도 받음 (MINUS 와 같은 결과)
        sql_check("SELECT 부서번호 FROM 부서 EXCEPT SELECT 부서번호 FROM 사원", [[40]]),
    ],
}
