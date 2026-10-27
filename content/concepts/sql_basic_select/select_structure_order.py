"""개념: SELECT 문의 구조와 실행 순서 (2단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import to_employee_table_md

EMPLOYEE_SALARY_TABLE = to_employee_table_md("사번", "이름", "급여", "부서번호")

# 본문 단계 설명 예시 (결과 2행: 20번 3명, 30번 2명)
GROUPED_EXAMPLE_SQL = (
    "SELECT 부서번호, COUNT(*) AS 인원\n"
    "FROM 사원\n"
    "WHERE 급여 >= 2500\n"
    "GROUP BY 부서번호\n"
    "HAVING COUNT(*) >= 2\n"
    "ORDER BY 인원 DESC;"
)

CONCEPT = {
    "tagKey": "select-structure-order",
    "topicCode": "sql_basic_select",
    "sortOrder": 2,
    "title": "SELECT 문의 구조와 실행 순서",
    "summary": "SELECT 문은 쓰는 순서와 실행되는 순서가 달라서, 별칭을 쓸 수 있는 곳이 갈려요",
    "coreMd": (
        "- SELECT 문은 SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY 순서로 쓰지만, 실제로는 FROM, WHERE, GROUP BY, HAVING, SELECT, ORDER BY 순서로 처리돼요.\n"
        "- SELECT 절이 끝에서 두 번째로 처리되기 때문에, SELECT에서 붙인 별칭은 WHERE·GROUP BY·HAVING에서는 쓸 수 없고 ORDER BY에서만 쓸 수 있어요.\n"
        "- Oracle은 FROM 절을 꼭 써야 해서, 표 없이 계산만 할 때는 한 행짜리 표 `DUAL`을 FROM에 적어요."
    ),
    "detailMd": f"""## 왜 실행 순서를 알아야 하나요 {{#why}}

테이블, 행, 열이 무엇인지와 SQL이 어떤 언어인지는 바로 앞 개념 "관계형 데이터베이스와 SQL의 특징"에서 다뤘어요. 이 개념은 SQL 문장 중 가장 많이 쓰는 SELECT 문이 어떤 절로 이루어지고, 그 절들이 어떤 순서로 처리되는지를 다뤄요. 처리 순서를 알아야 SELECT에서 붙인 이름을 어디에 쓸 수 있는지, 어떤 SQL이 오류가 나는지를 판단할 수 있어요.

SQL로 쓴 명령 하나를 SQL 문장이라고 하고, 문장 끝에는 세미콜론(`;`)을 붙여요. `SELECT`, `select`처럼 명령어는 대문자와 소문자를 구분하지 않지만, 작은따옴표 안에 쓴 값(`'김민수'`)은 글자 그대로 비교해요.

## SELECT 문의 생김새 {{#definition}}

SELECT 문은 테이블에서 원하는 행과 열을 골라 보여 달라는 문장이에요. 문장은 몇 개의 **절**로 이루어지는데, 절은 `WHERE 급여 >= 2500`처럼 키워드 하나로 시작하는 문장의 한 부분을 말해요. 절은 정해진 순서대로만 쓸 수 있어요.

| 쓰는 순서 | 절 | 하는 일 | 꼭 써야 하나요 |
|---|---|---|---|
| 1 | SELECT | 보여 줄 열을 정해요 | 필수 |
| 2 | FROM | 읽을 테이블을 정해요 | Oracle에서는 필수 |
| 3 | WHERE | 조건에 맞는 행만 남겨요 | 선택 |
| 4 | GROUP BY | 같은 값끼리 행을 묶어요 | 선택 |
| 5 | HAVING | 묶은 결과 중 조건에 맞는 묶음만 남겨요 | 선택 |
| 6 | ORDER BY | 결과 행의 순서를 정해요 | 선택 |

가장 짧은 SELECT 문은 SELECT와 FROM만으로 이루어져요. `*`는 "모든 열"을 뜻해요.

```sql
SELECT * FROM 사원;              -- 사원 테이블의 모든 열을 보여 줘요
SELECT 이름, 급여 FROM 사원;     -- 이름과 급여 열만 보여 줘요
```

## 쓰는 순서와 실행 순서 {{#execution-order}}

SELECT 문은 위에서 아래로 쓴 순서대로 처리되지 않아요. 데이터베이스는 "어느 테이블을 읽을지"를 알아야 일을 시작할 수 있기 때문에 FROM부터 처리하고, 보여 줄 열을 정하는 SELECT는 거의 끝에 처리해요. 이 순서를 논리적 실행 순서라고 불러요.

1. FROM: 읽을 테이블을 정해요.
2. WHERE: 조건에 맞는 행만 남겨요.
3. GROUP BY: 남은 행을 같은 값끼리 묶어요.
4. HAVING: 묶음 중 조건에 맞는 묶음만 남겨요.
5. SELECT: 보여 줄 열과 계산식을 만들고, 별칭(열에 새로 붙이는 이름)을 붙여요.
6. ORDER BY: 결과 행의 순서를 정해요.

아래 SQL을 이 순서대로 따라가 볼게요. `COUNT(*)`는 묶음마다 행이 몇 개인지 세는 함수예요. 이렇게 여러 행을 묶어 값 하나를 계산하는 함수를 **그룹 함수**라고 부르고, 7단원에서 자세히 다뤄요. `AS 인원`은 계산한 열에 "인원"이라는 새 이름을 붙인다는 뜻이고, 이런 이름을 **별칭**이라고 불러요.

{EMPLOYEE_SALARY_TABLE}

```sql
{GROUPED_EXAMPLE_SQL}
```

| 순서 | 절 | 이 단계가 끝난 뒤 남는 것 |
|---|---|---|
| 1 | FROM 사원 | 8명 전부 |
| 2 | WHERE 급여 >= 2500 | 급여가 2500 미만인 오지민, 윤서연이 빠지고 6명 |
| 3 | GROUP BY 부서번호 | 10번 1명, 20번 3명, 30번 2명의 세 묶음 |
| 4 | HAVING COUNT(*) >= 2 | 한 명뿐인 10번이 빠지고 20번, 30번 두 묶음 |
| 5 | SELECT 부서번호, COUNT(*) AS 인원 | 묶음마다 부서번호와 인원 열이 만들어져요 |
| 6 | ORDER BY 인원 DESC | 인원이 많은 순서로 줄을 세워요 |

| 부서번호 | 인원 |
|---|---|
| 20 | 3 |
| 30 | 2 |

## 자주 헷갈리는 점 {{#confusing}}

**WHERE에서는 SELECT의 별칭을 쓸 수 없어요.** 연봉이 30000보다 많은 사람을 찾으려고 아래 첫 문장처럼 쓰면 오류가 나요. WHERE는 2번째로 처리되는데, "연봉"이라는 이름은 5번째 단계인 SELECT에서야 생기기 때문이에요. WHERE가 일하는 시점에는 사원 테이블에 연봉이라는 열이 없으니, 계산식을 그대로 다시 적어야 해요.

```sql
SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 WHERE 연봉 > 30000;    -- 오류: WHERE 시점에는 연봉이라는 열이 없어요
SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 WHERE 급여 * 12 > 30000; -- 계산식을 다시 적으면 정상이에요
```

| 이름 | 연봉 |
|---|---|
| 김민수 | 36000 |
| 박서준 | 33600 |
| 최유나 | 38400 |
| 한도윤 | 32400 |

**ORDER BY에서는 별칭을 쓸 수 있어요.** ORDER BY는 SELECT보다 뒤인 6번째로 처리되므로, 그때는 연봉이라는 이름이 이미 만들어져 있어요. 그래서 `ORDER BY 연봉 DESC`는 정상으로 실행돼요. 별칭을 쓸 수 있는 곳은 SELECT 뒤에 처리되는 ORDER BY 하나뿐이라고 기억하면 돼요.

```sql
SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 ORDER BY 연봉 DESC;
```

**GROUP BY와 HAVING도 SELECT보다 먼저라서 별칭을 못 써요.** `HAVING 인원 >= 3`처럼 별칭을 쓰면 WHERE와 같은 이유로 오류가 나요. HAVING에는 `COUNT(*) >= 3`처럼 식을 다시 적고, ORDER BY에서는 `인원`을 그대로 써도 돼요.

```sql
SELECT 부서번호, COUNT(*) AS 인원 FROM 사원 GROUP BY 부서번호 HAVING 인원 >= 3;       -- 오류: 별칭은 HAVING에서 못 써요
SELECT 부서번호, COUNT(*) AS 인원 FROM 사원 GROUP BY 부서번호 HAVING COUNT(*) >= 3; -- 식을 다시 적으면 정상이에요
```

| 부서번호 | 인원 |
|---|---|
| 20 | 3 |
| 30 | 3 |

**WHERE에는 COUNT 같은 그룹 함수를 쓸 수 없어요.** 그룹 함수는 묶음마다 값을 계산하는 함수인데, WHERE는 행을 묶기 전(GROUP BY보다 먼저)에 처리되므로, 아직 묶음이 없어서 묶음의 개수나 평균을 계산할 수 없어요. 묶음에 거는 조건은 HAVING에 적어요. 자세한 내용은 그룹 함수 단원에서 다뤄요.

**Oracle은 FROM 절이 없으면 오류가 나요.** 테이블과 상관없이 `3 * 4` 같은 계산만 하고 싶을 때도 Oracle은 FROM을 요구해요. 이럴 때 쓰는 테이블이 **DUAL**인데, Oracle이 처음부터 만들어 두는 한 행, 한 열(DUMMY 열, 값 `X`)짜리 테이블이에요. 행이 하나뿐이라 계산 결과도 한 번만 나와요. SQL Server는 FROM 없이 `SELECT 3 * 4`만 써도 실행된다는 점이 다르고, 시험에서는 이 차이를 보기로 내기도 해요.

```sql
SELECT 3 * 4 FROM DUAL;   -- 결과는 12예요
SELECT * FROM DUAL;       -- X 한 행이 나와요
SELECT 3 * 4;             -- 오류: Oracle은 FROM을 꼭 써야 해요
```

**실행 순서는 결과를 정하는 규칙이지, 실제 작업 순서가 아니에요.** 데이터베이스는 더 빨리 끝내려고 내부에서 작업 순서를 바꾸기도 해요. 하지만 결과는 항상 위 여섯 단계 순서대로 처리한 것과 같아서, 별칭이나 그룹 함수를 어디에 쓸 수 있는지는 이 순서로 판단하면 돼요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

절들을 섞어 놓고 논리적 실행 순서대로 고르는 문제가 가장 많이 나와요. FROM에서 시작하고 SELECT가 끝에서 두 번째, ORDER BY가 맨 끝이라는 것만 확실히 하면 풀 수 있어요. 그다음으로 SELECT에서 붙인 별칭을 WHERE나 HAVING에 써서 오류가 나는 SQL을 고르는 문제가 자주 나와요. TRUNCATE·COMMIT·GRANT 같은 명령어의 분류를 묻는 문제는 앞 개념 "관계형 데이터베이스와 SQL의 특징"에서 다뤄요.""",
    "checkQuestions": [
        question(1, "SELECT 문의 논리적 실행 순서로 알맞은 것은 무엇인가요?", "execution-order",
                 "읽을 테이블을 정하는 FROM이 가장 먼저 처리되고, 보여 줄 열을 정하는 SELECT는 ORDER BY 바로 앞에 처리돼요.",
                 [choice("A", "SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY", rationale="이것은 쓰는 순서이고, 실행 순서가 아니에요."),
                  choice("B", "FROM → SELECT → WHERE → GROUP BY → HAVING → ORDER BY", rationale="SELECT는 HAVING 다음에 처리돼요."),
                  choice("C", "FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY", True, "FROM에서 시작해 SELECT가 끝에서 두 번째로 처리돼요."),
                  choice("D", "FROM → WHERE → HAVING → GROUP BY → SELECT → ORDER BY", rationale="HAVING은 묶은 뒤에 거르므로 GROUP BY 다음이에요.")]),
        question(2, "SELECT 문의 논리적 실행 순서에서 GROUP BY 바로 다음에 처리되는 절은 무엇인가요?", "execution-order",
                 "GROUP BY로 행을 묶은 뒤에는 묶음에 조건을 거는 HAVING이 처리되고, 그다음에 SELECT와 ORDER BY가 이어져요.",
                 [choice("A", "WHERE", rationale="WHERE는 행을 묶기 전에 처리되어서 GROUP BY보다 앞이에요."),
                  choice("B", "SELECT", rationale="SELECT는 HAVING까지 끝난 뒤에 처리돼요."),
                  choice("C", "ORDER BY", rationale="ORDER BY는 가장 마지막에 처리돼요."),
                  choice("D", "HAVING", True, "묶은 결과에 조건을 거는 절이라 GROUP BY 바로 다음이에요.")]),
        question(3, "다음 SQL을 Oracle에서 실행하면 어떻게 되나요?", "confusing",
                 "WHERE는 SELECT보다 먼저 처리되므로, SELECT에서 붙인 별칭 연봉을 아직 알지 못해요. 그래서 없는 열 이름이라는 오류(ORA-00904)가 나요.",
                 [choice("A", "오류가 난다", True, "WHERE 시점에는 연봉이라는 이름이 아직 없어요."),
                  choice("B", "연봉이 30000보다 많은 4명이 나온다", rationale="WHERE에 별칭을 쓰면 실행되지 않아요."),
                  choice("C", "조건이 무시되고 8명이 모두 나온다", rationale="Oracle은 알 수 없는 이름을 무시하지 않고 오류를 내요."),
                  choice("D", "0행이 나온다", rationale="0행이 아니라 실행 자체가 실패해요.")],
                 stem_sql="SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 WHERE 연봉 > 30000;"),
        question(4, "SELECT 절에서 붙인 열 별칭을 그대로 쓸 수 있는 절은 어디인가요?", "confusing",
                 "별칭은 SELECT 단계에서 만들어지므로, 그보다 뒤에 처리되는 ORDER BY에서만 쓸 수 있어요.",
                 [choice("A", "WHERE", rationale="WHERE는 SELECT보다 먼저 처리돼요."),
                  choice("B", "ORDER BY", True, "SELECT 다음에 처리되는 유일한 절이에요."),
                  choice("C", "GROUP BY", rationale="GROUP BY도 SELECT보다 먼저 처리돼요."),
                  choice("D", "HAVING", rationale="HAVING도 SELECT보다 먼저 처리돼요.")]),
        question(5, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_SALARY_TABLE, "execution-order",
                 "WHERE가 급여 3000 이상인 김민수, 최유나를 빼서 20번 3명, 30번 2명, 부서 없음 1명이 남아요. HAVING이 한 명뿐인 묶음을 빼므로 20번과 30번 두 행이 나오고, ORDER BY의 별칭 인원은 정상으로 쓰여요.",
                 [choice("A", "3행", rationale="부서번호가 NULL인 윤서연의 묶음은 1명이라 HAVING에서 빠져요."),
                  choice("B", "6행", rationale="WHERE만 적용한 행 수이고, 묶은 뒤에는 묶음 수만큼 나와요."),
                  choice("C", "오류가 난다", rationale="ORDER BY는 SELECT 뒤라서 별칭을 써도 돼요."),
                  choice("D", "2행", True, "20번(3명)과 30번(2명) 두 묶음만 남아요.")],
                 stem_sql="SELECT 부서번호, COUNT(*) AS 인원 FROM 사원 WHERE 급여 < 3000 GROUP BY 부서번호 HAVING COUNT(*) >= 2 ORDER BY 인원;"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        sql_check(GROUPED_EXAMPLE_SQL, [[20, 3], [30, 2]], is_ordered=True),
        sql_error_check("SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 WHERE 연봉 > 30000;", "ORA-00904"),
        sql_check("SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 WHERE 급여 * 12 > 30000",
                  [["김민수", 36000], ["박서준", 33600], ["최유나", 38400], ["한도윤", 32400]]),
        sql_check("SELECT 부서번호, COUNT(*) AS 인원 FROM 사원 GROUP BY 부서번호 HAVING COUNT(*) >= 3", [[20, 3], [30, 3]]),
        sql_error_check("SELECT 부서번호, COUNT(*) AS 인원 FROM 사원 GROUP BY 부서번호 HAVING 인원 >= 3", "ORA-00904"),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 급여 > AVG(급여)", "ORA-00934"),
        sql_check("SELECT 3 * 4 FROM DUAL", [[12]]),
        sql_check("SELECT * FROM DUAL", [["X"]]),
        sql_error_check("SELECT 3 * 4", "ORA-00923"),
        sql_check("SELECT 부서번호, COUNT(*) AS 인원 FROM 사원 WHERE 급여 < 3000 GROUP BY 부서번호 HAVING COUNT(*) >= 2 ORDER BY 인원;",
                  [[30, 2], [20, 3]], is_ordered=True),
    ],
}
