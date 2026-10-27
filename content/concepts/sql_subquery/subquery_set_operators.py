"""개념: 집합 연산자 (6단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import DEPARTMENT_TABLE_MD, to_employee_table_md

# 이 개념의 계산에 쓰는 열 전부 (직급·급여·커미션·부서번호)
EMPLOYEE_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "커미션", "부서번호")

CONCEPT = {
    "tagKey": "subquery-set-operators",
    "topicCode": "sql_subquery",
    "sortOrder": 6,
    "title": "집합 연산자",
    "summary": "두 SELECT 결과를 위아래로 합치거나, 겹치는 행이나 빼고 남은 행을 구해요",
    "coreMd": (
        "- `UNION`은 두 결과를 합치면서 중복 행을 하나로 줄이고, `UNION ALL`은 중복을 그대로 둬서 중복을 찾는 작업이 없는 만큼 가장 빨라요.\n"
        "- `INTERSECT`는 양쪽에 모두 있는 행을, `MINUS`는 앞 결과에서 뒤 결과에 있는 행을 뺀 나머지를 돌려주고, SQL Server에서는 MINUS 대신 `EXCEPT`를 써요.\n"
        "- 위아래 SELECT의 열 개수와 데이터 타입이 맞아야 하고, 결과 열 이름은 첫 번째 SELECT를 따르며, ORDER BY는 맨 끝에 한 번만 써요.\n"
        "- 시험 기준인 Oracle은 연산자 여러 개를 위에서부터 차례로 계산하고, 집합 연산자는 NULL끼리도 같은 값으로 보고 중복을 없애요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

"개발부 사원 명단"과 "급여가 2700 이상인 사원 명단"이 따로 있을 때, 두 명단을 하나로 합치거나 두 명단에 모두 있는 사람만 고르고 싶을 때가 있어요. 조건이 같은 테이블 안에 있으면 OR나 AND로도 되지만, 서로 다른 SELECT 문이 만든 결과끼리는 WHERE 절로 묶을 수가 없어요.

집합 연산자는 이렇게 이미 만들어진 두 결과를 합집합, 교집합, 차집합으로 묶어 줘요. 학교에서 배운 벤 다이어그램처럼 두 원을 합치거나, 겹치는 부분만 보거나, 한쪽 원에서 겹치는 부분을 빼는 셈이에요.

이 글의 예시는 모두 아래 사원 표와 부서 표로 계산해요. 개발부는 20번 부서이고, 윤서연(1008)은 부서가 정해지지 않아 부서번호가 NULL이에요.

{EMPLOYEE_TABLE}

{DEPARTMENT_TABLE_MD}

## 한 줄 정의 {{#definition}}

집합 연산자(Set Operator)는 두 SELECT 문의 결과를 위아래로 이어서 하나의 결과로 만드는 연산자예요. 조인이 다른 테이블의 열을 옆으로 붙인다면, 집합 연산자는 같은 모양의 결과 행을 아래로 붙인다는 점이 달라요.

개발부 사원 A(이지은, 박서준, 정하늘)와 급여 2700 이상인 사원 B(김민수, 박서준, 최유나, 한도윤)로 네 연산자를 비교하면 이렇게 나와요. 두 명단에 모두 있는 사람은 박서준 한 명이에요.

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

UNION, UNION ALL, INTERSECT는 위아래를 바꿔도 결과 행이 같지만, MINUS는 순서가 바뀌면 결과가 달라져요. B MINUS A로 쓰면 급여 2700 이상인 사원 중 개발부가 아닌 김민수, 최유나, 한도윤이 나와요. SQL Server에서는 MINUS와 같은 일을 하는 연산자를 EXCEPT라고 불러요.

## 쓰는 규칙 {{#rules}}

집합 연산자로 묶는 SELECT 문은 결과의 모양이 같아야 해요. 위아래 SELECT의 열 개수가 같아야 하고, 같은 위치의 열끼리 데이터 타입이 맞아야 해요. 열 개수가 다르면 ORA-01789(결과 열 개수가 맞지 않음) 오류가 나고, 숫자 열과 날짜 열처럼 타입이 맞지 않으면 ORA-01790(같은 위치의 열 타입이 다름) 오류가 나요.

```sql
SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 10
UNION
SELECT 이름 FROM 사원 WHERE 부서번호 = 20;  -- 오류: 위는 열이 두 개, 아래는 한 개예요

SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 10
UNION
SELECT 이름, 입사일 FROM 사원 WHERE 부서번호 = 20;  -- 오류: 급여는 숫자, 입사일은 날짜예요
```

결과의 열 이름은 첫 번째 SELECT의 열 이름이나 별칭을 따라요. ORDER BY는 맨 마지막 SELECT 뒤에 한 번만 쓸 수 있고, 이때 정렬 기준으로는 첫 번째 SELECT의 열 이름이나 별칭, 또는 열 위치 번호를 써요.

```sql
SELECT 이름 AS 사원명, 급여 FROM 사원 WHERE 부서번호 = 10
UNION
SELECT 이름 AS 직원, 급여 FROM 사원 WHERE 부서번호 = 20
ORDER BY 급여 DESC, 사원명;
```

| 사원명 | 급여 |
|---|---|
| 김민수 | 3000 |
| 박서준 | 2800 |
| 이지은 | 2500 |
| 정하늘 | 2500 |

결과 열 이름이 두 번째 SELECT의 `직원`이 아니라 첫 번째 SELECT의 `사원명`으로 나와요. 그래서 ORDER BY에 두 번째 SELECT의 별칭을 쓰면 ORA-00904(없는 열 이름) 오류가 나고, ORDER BY를 중간에 쓰면 ORA-00933(SQL 문이 제대로 끝나지 않음) 오류가 나요.

```sql
SELECT 이름 AS 사원명, 급여 FROM 사원 WHERE 부서번호 = 10
UNION
SELECT 이름 AS 직원, 급여 FROM 사원 WHERE 부서번호 = 20
ORDER BY 직원;  -- 오류: 두 번째 SELECT의 별칭은 쓸 수 없어요

SELECT 이름 FROM 사원 WHERE 부서번호 = 10
ORDER BY 이름
UNION
SELECT 이름 FROM 사원 WHERE 부서번호 = 20;  -- 오류: ORDER BY는 맨 끝에만 올 수 있어요
```

## 자주 헷갈리는 점 {{#confusing}}

**UNION ALL만 중복을 남기고, 나머지 셋은 중복을 없애요.** UNION만 중복을 없앤다고 생각하기 쉬운데, INTERSECT와 MINUS의 결과도 중복 없이 나와요. 사원 8명의 부서번호(10, 20, 20, 30, 20, 30, 30, NULL)에서 10번만 빼면, 20과 30이 세 번씩 남는 것이 아니라 20, 30, NULL 세 행만 나와요.

```sql
SELECT 부서번호 FROM 사원
MINUS
SELECT 부서번호 FROM 부서 WHERE 부서번호 = 10;  -- 중복 없이 세 행만 나와요
```

**집합 연산자는 NULL끼리 같은 값으로 봐요.** WHERE 절에서 `NULL = NULL`은 UNKNOWN이지만, 집합 연산자는 중복을 가릴 때 NULL과 NULL을 같은 행으로 취급해요. 사원 표에서 20번 부서의 커미션은 300, 0, NULL이고, 30번 부서의 커미션은 NULL, 500, 200이에요.

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

INTERSECT 결과가 0행이 아니라 NULL 한 행이라는 점이 특히 헷갈려요. 두 결과에 공통으로 있는 값은 NULL뿐인데, 집합 연산자는 이 NULL들을 같은 값으로 보기 때문이에요.

**연산자가 여러 개면 위에서부터 차례로 계산해요.** 시험은 Oracle 기준으로 풀고, Oracle에서는 집합 연산자의 우선순위가 모두 같아요. 그래서 괄호가 없으면 위에 있는 연산부터 하나씩 처리해요. 아래 세 SELECT는 각각 (10, 40), (10, 20, 30), (20, 30, NULL)을 돌려줘요.

```sql
SELECT 부서번호 FROM 부서 WHERE 지역 = '서울'
UNION
SELECT 부서번호 FROM 사원 WHERE 급여 >= 2800
INTERSECT
SELECT 부서번호 FROM 사원 WHERE 직급 = '사원';  -- 2행이 나와요

SELECT 부서번호 FROM 부서 WHERE 지역 = '서울'
UNION
(SELECT 부서번호 FROM 사원 WHERE 급여 >= 2800
 INTERSECT
 SELECT 부서번호 FROM 사원 WHERE 직급 = '사원');  -- 4행이 나와요
```

괄호가 없으면 UNION으로 10, 20, 30, 40을 만든 뒤, 그중 (20, 30, NULL)과 겹치는 20과 30만 남겨서 2행이 나와요. 괄호로 INTERSECT를 먼저 하게 하면 (10, 20, 30)과 (20, 30, NULL)이 겹치는 20, 30을 구한 뒤 (10, 40)과 합치므로 10, 20, 30, 40의 4행이 나와요. 참고로 SQL Server는 INTERSECT를 다른 연산자보다 먼저 계산하지만, 시험 문제는 Oracle처럼 위에서부터 계산해서 풀면 돼요.

**UNION은 결과를 정렬해 주지 않아요.** 중복을 찾는 과정에서 정렬처럼 보이는 결과가 나올 때도 있지만, 순서가 보장되지는 않아요. 순서가 필요하면 맨 끝에 ORDER BY를 붙여야 해요.

**중복이 없다는 것을 알면 UNION ALL이 더 빨라요.** UNION은 두 결과를 합친 뒤 중복을 찾아 없애는 작업을 한 번 더 하지만, UNION ALL은 그냥 이어 붙이기만 해요. 두 결과가 처음부터 겹칠 수 없다면 결과가 같으니 UNION ALL을 쓰는 편이 나아요.

**EXCEPT는 SQL Server의 이름이에요.** 시험에서는 "Oracle은 MINUS, SQL Server는 EXCEPT"로 구분해요. Oracle도 21c부터는 EXCEPT라는 이름을 함께 받아 주지만, 시험 보기는 MINUS를 기준으로 나와요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

두 표를 주고 집합 연산 결과의 행 수를 묻는 문제가 가장 많이 나와요. 이때는 각 SELECT의 결과를 값 목록으로 적은 다음, UNION ALL이 아니면 중복을 하나로 줄이고 NULL도 같은 값으로 묶어서 세면 돼요. 위의 부서 표(부서번호 4개)와 사원 표(부서번호 8개)로 연습해 보면 아래와 같아요.

| SQL | 결과 | 행 수 |
|---|---|---|
| 부서의 부서번호 UNION ALL 사원의 부서번호 | 4행과 8행을 그대로 이어 붙임 | 12 |
| 부서의 부서번호 UNION 사원의 부서번호 | 10, 20, 30, 40, NULL | 5 |
| 부서의 부서번호 INTERSECT 사원의 부서번호 | 10, 20, 30 | 3 |
| 부서의 부서번호 MINUS 사원의 부서번호 | 40 | 1 |
| 사원의 부서번호 MINUS 부서의 부서번호 | NULL | 1 |

마지막 줄은 부서가 없는 윤서연의 NULL이 부서 표에 없어서 남은 결과예요. 그 밖에 집합 연산자의 규칙으로 옳지 않은 것을 고르는 문제, 연산자가 여러 개 섞인 SQL의 결과를 묻는 문제도 자주 나와요.""",
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
        # 규칙 (열 개수·타입·열 이름·ORDER BY 위치)
        sql_error_check("SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 10 UNION SELECT 이름 FROM 사원 WHERE 부서번호 = 20",
                        "ORA-01789"),
        sql_error_check("SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 10 UNION SELECT 이름, 입사일 FROM 사원 WHERE 부서번호 = 20",
                        "ORA-01790"),
        sql_check("SELECT 이름 AS 사원명, 급여 FROM 사원 WHERE 부서번호 = 10 UNION "
                  "SELECT 이름 AS 직원, 급여 FROM 사원 WHERE 부서번호 = 20 ORDER BY 급여 DESC, 사원명",
                  [["김민수", 3000], ["박서준", 2800], ["이지은", 2500], ["정하늘", 2500]], is_ordered=True),
        sql_error_check("SELECT 이름 AS 사원명, 급여 FROM 사원 WHERE 부서번호 = 10 UNION "
                        "SELECT 이름 AS 직원, 급여 FROM 사원 WHERE 부서번호 = 20 ORDER BY 직원", "ORA-00904"),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 부서번호 = 10 ORDER BY 이름 UNION SELECT 이름 FROM 사원 WHERE 부서번호 = 20",
                        "ORA-00933"),
        # 중복 제거·NULL (커미션: 20번 300·0·NULL, 30번 NULL·500·200)
        sql_check("SELECT 부서번호 FROM 사원 MINUS SELECT 부서번호 FROM 부서 WHERE 부서번호 = 10",
                  [[20], [30], [None]]),
        sql_check("SELECT 커미션 FROM 사원 WHERE 부서번호 = 20 UNION SELECT 커미션 FROM 사원 WHERE 부서번호 = 30",
                  [[300], [0], [None], [500], [200]]),
        sql_check("SELECT 커미션 FROM 사원 WHERE 부서번호 = 20 UNION ALL SELECT 커미션 FROM 사원 WHERE 부서번호 = 30",
                  [[300], [0], [None], [None], [500], [200]]),
        sql_check("SELECT 커미션 FROM 사원 WHERE 부서번호 = 20 INTERSECT SELECT 커미션 FROM 사원 WHERE 부서번호 = 30;",
                  [[None]]),
        # 연산 순서 (위에서부터 <-> 괄호), 세 SELECT 각각의 결과
        sql_check("SELECT 부서번호 FROM 부서 WHERE 지역 = '서울' UNION SELECT 부서번호 FROM 사원 WHERE 급여 >= 2800 "
                  "INTERSECT SELECT 부서번호 FROM 사원 WHERE 직급 = '사원'", [[20], [30]]),
        sql_check("SELECT 부서번호 FROM 부서 WHERE 지역 = '서울' UNION (SELECT 부서번호 FROM 사원 WHERE 급여 >= 2800 "
                  "INTERSECT SELECT 부서번호 FROM 사원 WHERE 직급 = '사원')", [[10], [20], [30], [40]]),
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
    ],
}
