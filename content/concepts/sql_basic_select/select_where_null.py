"""개념: WHERE 절과 NULL (2단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_example
from concept_dataset import to_employee_table_md

EMPLOYEE_COMMISSION_TABLE = to_employee_table_md("사번", "이름", "급여", "커미션", "부서번호")

# NULL 섞인 덧셈 <-> NVL 로 0 보고 더하기 (김민수 커미션 NULL, 이지은 300, 박서준 0)
NULL_ARITHMETIC_EXAMPLE = sql_example(
    "SELECT 이름, 급여 + 커미션 AS 합계, 급여 + NVL(커미션, 0) AS 보정합계\n"
    "FROM 사원 WHERE 사번 IN (1001, 1002, 1003);",
    ("이름", "합계", "보정합계"),
    [["김민수", None, 3000], ["이지은", 2800, 2800], ["박서준", 2800, 2800]], is_ordered=False)

CONCEPT = {
    "tagKey": "select-where-null",
    "topicCode": "sql_basic_select",
    "sortOrder": 6,
    "title": "WHERE 절과 NULL",
    "summary": "NULL과 비교하면 참도 거짓도 아니라서, IS NULL로만 찾아요",
    "coreMd": (
        "- NULL은 값이 없거나 아직 모른다는 표시라서 숫자 0이나 빈칸 글자와 달라요.\n"
        "- NULL과 무엇을 비교해도 UNKNOWN이 되고, WHERE는 참인 행만 남기므로 그 행은 빠져요.\n"
        "- NULL을 찾을 때는 `= NULL`이 아니라 `IS NULL`, 아닌 행은 `IS NOT NULL`을 써요.\n"
        "- NULL이 섞인 계산은 결과도 NULL이고, Oracle은 빈 문자열(`''`)도 NULL로 다뤄요."
    ),
    "detailMd": f"""## 왜 헷갈릴까요 — 오류 없이 0행이 나와서 {{#why}}

"커미션이 없는 사원"을 찾으려고 `WHERE 커미션 = NULL`이라고 쓰면, 오류도 나지 않고 결과만 0행으로 나와요. 무엇이 잘못됐는지 알기 어려워서 시험에서도 자주 묻고, 아래 사원 표 하나로 모든 예시를 설명해요.

{EMPLOYEE_COMMISSION_TABLE}

## NULL은 값이 아니에요 — 0과도 빈칸과도 달라요 {{#definition}}

| 용어 | 뜻 |
|---|---|
| NULL | 값이 없음, 또는 아직 모름을 뜻하는 표시예요. 김민수의 커미션 NULL은 0원이 아니라 정해지지 않았다는 뜻이에요 |
| 0 | 숫자 값이에요. 커미션이 0인 박서준과 NULL인 김민수는 서로 다른 상태예요 |
| UNKNOWN | NULL이 들어간 비교의 결과예요. 참(TRUE)도 거짓(FALSE)도 아닌 "모름"이에요 |

NULL 규칙은 아래 두 줄로 외우고, 문제를 풀 때마다 NULL이 있는 칸부터 찾으면 몸에 붙어요.

| NULL이 섞이면 | 결과 |
|---|---|
| 계산 (`+`, `-`, `*`, `/`) | NULL |
| 비교 (`=`, `<>`, `>`, IN 등) | UNKNOWN, 그래서 WHERE에서 빠져요 |

## 비교하면 UNKNOWN — 그래서 IS NULL로 찾아요 {{#unknown}}

모르는 값과 무엇을 비교해도 맞는지 틀린지 알 수 없어서 결과가 UNKNOWN이 되고, WHERE 절은 참인 행만 남기니 그 행은 빠져요. NULL 여부를 확인하는 전용 연산자는 `IS NULL`과 `IS NOT NULL`이고, 이 둘은 UNKNOWN이 아니라 참이나 거짓으로 답해요.

```sql
SELECT 이름 FROM 사원 WHERE 커미션 = NULL;      -- 모든 행이 UNKNOWN이라 0행이에요
SELECT 이름 FROM 사원 WHERE 커미션 IS NULL;     -- 커미션이 NULL인 사람을 찾아요
SELECT 이름 FROM 사원 WHERE 커미션 IS NOT NULL; -- 커미션이 있는 사람을 찾아요
```

| 조건 | 결과 |
|---|---|
| `커미션 = NULL` | 0행 |
| `커미션 IS NULL` | 김민수, 최유나, 정하늘, 윤서연 |
| `커미션 IS NOT NULL` | 이지은, 박서준, 한도윤, 오지민 |

## NULL이 섞인 계산 — 결과도 NULL {{#null-arithmetic}}

김민수의 `급여 + 커미션`은 3000이 아니라 NULL이에요. 커미션이 없을 때 0으로 보고 더하려면 `NVL(커미션, 0)`을 쓰는데, NVL은 첫 값이 NULL이면 두 번째 값을 돌려주는 함수이고 4단원에서 자세히 다뤄요.

{NULL_ARITHMETIC_EXAMPLE.markdown}

## 자주 헷갈리는 점 — <>, NOT IN, AND·OR {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| `커미션 <> 300`이면 커미션이 NULL인 사원도 나와요 | NULL인 네 명은 비교가 UNKNOWN이라 빠지고 박서준, 한도윤, 오지민만 나와요. 포함하려면 `OR 커미션 IS NULL`을 따로 적어요 |
| `NOT IN (10, NULL)`은 10번이 아닌 사원을 찾아요 | `<> 10 AND <> NULL`인데 뒤쪽이 늘 UNKNOWN이라 0행이에요. `IN (10, NULL)`은 OR이라 김민수 한 명이 나와요 |
| 커미션이 NULL이면 0으로 보고 더해요 | 계산 결과가 NULL이에요. 0으로 보려면 NVL을 써요 |
| `NULL = NULL`은 참이에요 | NULL끼리 비교해도 UNKNOWN이에요 |
| `이름 = ''`로 빈 이름을 찾을 수 있어요 | Oracle은 빈 문자열을 NULL로 다뤄서 `= ''`는 `= NULL`과 같고 0행이에요. `커미션 = ''`처럼 숫자 열에 써도 0행이고, SQL Server는 빈 문자열과 NULL을 구분해요 |

UNKNOWN을 "참일 수도 거짓일 수도 있는 값"으로 보면, 어느 쪽이어도 결과가 같을 때만 그 결과가 정해져요.

| 조합 | 결과 | 이유 |
|---|---|---|
| 거짓 AND UNKNOWN | 거짓 | 한쪽이 거짓이면 AND는 늘 거짓 |
| 참 AND UNKNOWN | UNKNOWN | UNKNOWN 쪽에 따라 참도 거짓도 됨 |
| 참 OR UNKNOWN | 참 | 한쪽이 참이면 OR는 늘 참 |
| 거짓 OR UNKNOWN | UNKNOWN | UNKNOWN 쪽에 따라 참도 거짓도 됨 |
| NOT UNKNOWN | UNKNOWN | 모르는 값을 뒤집어도 모름 |

```sql
SELECT 이름 FROM 사원 WHERE 커미션 <> 300 OR 커미션 IS NULL;   -- 이지은을 뺀 7명이 나와요
SELECT 이름 FROM 사원 WHERE 부서번호 IN (10, NULL);             -- 김민수 한 명이 나와요
SELECT 이름 FROM 사원 WHERE 이름 = '';                          -- 빈 문자열이 NULL이라 0행이에요
```

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 거짓 AND UNKNOWN의 결과는 거짓이에요 | O | 한쪽이 거짓이면 다른 쪽과 상관없이 AND는 거짓이에요 |
| 커미션이 0인 박서준은 `커미션 IS NULL` 조건에 걸려요 | X | 0은 값이라서 박서준에게 IS NULL은 거짓이에요 |
| `IS NOT NULL`의 결과는 UNKNOWN이 될 수 없어요 | O | IS NULL과 IS NOT NULL은 참이나 거짓으로만 답해요 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

예시 표를 주고 `<>`나 `NOT IN`을 쓴 SQL의 결과 행 수를 묻는 문제가 가장 많고, 조건 칸에 NULL이 있는 행부터 빼고 세면 실수가 줄어요. NULL을 찾는 올바른 조건, NULL이 섞인 계산 결과, 참·거짓·UNKNOWN의 AND와 OR 결과도 자주 물어요.""",
    "checkQuestions": [
        question(1, "커미션이 NULL인 사원을 찾는 WHERE 조건으로 올바른 것은 무엇인가요?", "unknown",
                 "NULL과의 비교는 UNKNOWN이 되므로 = NULL로는 찾을 수 없어요. NULL 여부는 IS NULL로 확인해요.",
                 [choice("A", "WHERE 커미션 = NULL", rationale="비교 결과가 UNKNOWN이라 0행이 나와요."),
                  choice("B", "WHERE 커미션 IS NULL", True, "NULL을 확인하는 전용 연산자예요."),
                  choice("C", "WHERE 커미션 = ''", rationale="Oracle에서 ''는 NULL이라 이 비교도 UNKNOWN이에요."),
                  choice("D", "WHERE 커미션 = 0", rationale="0은 NULL과 다른 값이라 박서준만 나와요.")]),
        question(2, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_COMMISSION_TABLE, "confusing",
                 "커미션이 300이 아닌 행은 박서준(0), 한도윤(500), 오지민(200) 세 명이에요. 커미션이 NULL인 네 명은 비교 결과가 UNKNOWN이 되어 빠져요.",
                 [choice("A", "3행", True, "박서준, 한도윤, 오지민 세 명만 남아요."),
                  choice("B", "7행", rationale="NULL인 네 명까지 셌어요. NULL은 <> 비교에서도 빠져요."),
                  choice("C", "4행", rationale="커미션이 NULL인 사원 수를 셌어요."),
                  choice("D", "8행", rationale="이지은은 커미션이 300이라서 빠져요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE 커미션 <> 300;"),
        question(3, "사번 1001 김민수(급여 3000, 커미션 NULL)에 대해 다음 SQL의 결과는 무엇인가요?", "confusing",
                 "NULL이 섞인 계산은 결과도 NULL이에요. 0으로 보고 더하려면 NVL(커미션, 0)을 써야 해요.",
                 [choice("A", "3000", rationale="NULL을 0으로 보고 더한 결과인데, SQL은 그렇게 계산하지 않아요."),
                  choice("B", "0", rationale="NULL은 0이 아니에요."),
                  choice("C", "NULL", True, "NULL이 섞인 계산의 결과는 NULL이에요."),
                  choice("D", "오류가 난다", rationale="오류 없이 NULL이 나와요.")],
                 stem_sql="SELECT 급여 + 커미션 FROM 사원 WHERE 사번 = 1001;"),
        question(4, "다음 SQL의 결과로 알맞은 것은 무엇인가요?", "confusing",
                 "NOT IN (10, NULL)은 <> 10 AND <> NULL과 같은데, <> NULL이 항상 UNKNOWN이라서 어떤 행도 참이 될 수 없어요.",
                 [choice("A", "부서번호가 10이 아닌 사원이 모두 나온다", rationale="목록에 NULL이 있어서 그렇게 되지 않아요."),
                  choice("B", "0행이 나온다", True, "AND로 묶인 비교 하나가 항상 UNKNOWN이라 전체가 참이 될 수 없어요."),
                  choice("C", "모든 사원이 나온다", rationale="조건이 참이 되는 행이 없어요."),
                  choice("D", "오류가 난다", rationale="문법상 문제가 없어서 오류 없이 0행이 나와요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE 부서번호 NOT IN (10, NULL);"),
        question(5, "다음 중 결과가 참(TRUE)인 것은 무엇인가요?", "confusing",
                 "참 OR UNKNOWN은 UNKNOWN이 무엇이든 참이에요. 나머지는 모두 UNKNOWN이에요.",
                 [choice("A", "NULL = NULL", rationale="NULL끼리 비교해도 UNKNOWN이에요."),
                  choice("B", "참 AND UNKNOWN", rationale="UNKNOWN이 거짓이면 거짓이 되므로 UNKNOWN이에요."),
                  choice("C", "참 OR UNKNOWN", True, "한쪽이 참이면 OR는 참이에요."),
                  choice("D", "NOT UNKNOWN", rationale="UNKNOWN을 뒤집어도 UNKNOWN이에요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        sql_check("SELECT 이름 FROM 사원 WHERE 커미션 = NULL", []),
        sql_check("SELECT 이름 FROM 사원 WHERE 커미션 IS NULL", [["김민수"], ["최유나"], ["정하늘"], ["윤서연"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 커미션 IS NOT NULL", [["이지은"], ["박서준"], ["한도윤"], ["오지민"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 커미션 <> 300;", [["박서준"], ["한도윤"], ["오지민"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 커미션 <> 300 OR 커미션 IS NULL", [["김민수"], ["박서준"], ["최유나"], ["정하늘"], ["한도윤"], ["오지민"], ["윤서연"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 NOT IN (10, NULL);", []),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 IN (10, NULL)", [["김민수"]]),
        sql_check("SELECT 급여 + 커미션 FROM 사원 WHERE 사번 = 1001;", [[None]]),
        sql_check("SELECT 이름, 급여 + 커미션 FROM 사원 WHERE 사번 IN (1002, 1003)", [["이지은", 2800], ["박서준", 2800]]),
        NULL_ARITHMETIC_EXAMPLE.check,
        sql_check("SELECT 이름 FROM 사원 WHERE 이름 = ''", []),
        sql_check("SELECT 이름 FROM 사원 WHERE 커미션 = ''", []),
    ],
}
