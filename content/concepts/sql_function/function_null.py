"""개념: NULL 관련 함수 (4단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

EMPLOYEE_COMMISSION_TABLE = to_employee_table_md("사번", "이름", "급여", "커미션", "부서번호")

# NVL·COALESCE(NULL 바꾸기) <-> NULLIF(같으면 NULL): 커미션 NULL·300·0 세 사원
NULL_REPLACE_VERSUS_NULLIF_EXAMPLE = sql_example(
    "SELECT 사번, 커미션, NVL(커미션, 0), COALESCE(커미션, 0), NULLIF(커미션, 0)\n"
    "FROM 사원\n"
    "WHERE 사번 IN (1001, 1002, 1003)\n"
    "ORDER BY 사번;",
    ("사번", "커미션", "NVL(커미션, 0)", "COALESCE(커미션, 0)", "NULLIF(커미션, 0)"),
    [[1001, None, 0, 0, None], [1002, 300, 300, 300, 300], [1003, 0, 0, 0, None]],
)

CONCEPT = {
    "tagKey": "function-null",
    "topicCode": "sql_function",
    "sortOrder": 6,
    "title": "NULL 관련 함수",
    "summary": "NULL을 다른 값으로 바꾸거나 값을 NULL로 만드는 함수이고, 인자 순서를 자주 물어요",
    "coreMd": (
        "- `NVL(값, 대신할 값)`은 값이 NULL일 때만 바꾸고, `NVL2(값, NULL이 아닐 때, NULL일 때)`는 NULL이 아닐 때의 결과를 먼저 적어요.\n"
        "- `NULLIF(a, b)`는 두 값이 같으면 NULL을, 다르면 a를 돌려주고, `COALESCE(a, b, c, ...)`는 처음으로 NULL이 아닌 값을 돌려줘요.\n"
        "- NVL의 두 인자는 타입이 맞아야 해서, 숫자 커미션을 '없음'으로 바꾸려면 `NVL(TO_CHAR(커미션), '없음')`처럼 써요.\n"
        "- 조건에 맞는 행이 하나도 없는 결과를 공집합이라고 하고, 이때 NVL은 바꿀 행이 없어서 결과도 0행이에요. MAX 같은 집계 함수는 행이 없어도 NULL 한 행을 돌려주므로 `NVL(MAX(급여), 0)`은 0 한 행이 나와요.\n"
        "- SQL Server의 `ISNULL(값, 대신할 값)`과 MySQL의 `IFNULL(값, 대신할 값)`은 NVL과 같은 일을 하고, 이름이 비슷한 NULLIF는 두 값이 같으면 NULL을 돌려주는 전혀 다른 함수예요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

NULL이 섞인 계산은 결과도 NULL이 돼요. 김민수의 급여 3000에 커미션 NULL을 더하면 3000이 아니라 NULL이 나와서, 총급여를 구하려던 계산이 틀어져요. 이럴 때는 "NULL이면 0으로 보고 계산하라"고 알려 주는 함수가 필요하고, 반대로 0처럼 계산을 방해하는 값을 NULL로 바꿔야 할 때도 있어요. NULL 관련 함수는 이렇게 NULL과 다른 값 사이를 바꿔 주는 함수예요. 아래 예시는 모두 이 사원 표로 설명할게요.

{EMPLOYEE_COMMISSION_TABLE}

## 네 가지 함수 한눈에 보기 {{#definition}}

| 함수 | 돌려주는 값 | 예 | 결과 |
|---|---|---|---|
| NVL(a, b) | a가 NULL이면 b, 아니면 a | NVL(NULL, 0) | 0 |
| NVL2(a, b, c) | a가 NULL이 아니면 b, NULL이면 c | NVL2(NULL, '있음', '없음') | 없음 |
| NULLIF(a, b) | a와 b가 같으면 NULL, 다르면 a | NULLIF(10, 10) | NULL |
| COALESCE(a, b, ...) | 왼쪽부터 보아 처음으로 NULL이 아닌 값 | COALESCE(NULL, NULL, 3, 4) | 3 |

```sql
SELECT NVL(NULL, 0), NVL2(NULL, '있음', '없음'), NULLIF(10, 10), COALESCE(NULL, NULL, 3, 4) FROM DUAL;
-- 결과는 차례로 0, 없음, NULL, 3이에요
```

네 함수는 모두 CASE 식으로 바꿔 쓸 수 있어요. 함수의 뜻이 헷갈릴 때 아래 모양을 떠올리면 인자 순서를 다시 확인할 수 있어요.

```sql
-- 문법: 네 함수를 같은 뜻의 CASE 식으로 바꾼 모양이에요
NVL(a, b)         = CASE WHEN a IS NULL THEN b ELSE a END
NVL2(a, b, c)     = CASE WHEN a IS NOT NULL THEN b ELSE c END
NULLIF(a, b)      = CASE WHEN a = b THEN NULL ELSE a END
COALESCE(a, b, c) = CASE WHEN a IS NOT NULL THEN a WHEN b IS NOT NULL THEN b ELSE c END
```

## NVL과 NVL2 {{#nvl-nvl2}}

NVL은 첫 번째 값이 NULL일 때만 두 번째 값으로 바꾸고, NULL이 아니면 첫 번째 값을 그대로 둬요. NVL2는 첫 번째 값이 NULL인지 아닌지만 보고, NULL이 아니면 두 번째 값을, NULL이면 세 번째 값을 돌려줘요. 그래서 NVL2를 쓰면 커미션 자체가 아니라 "커미션이 있는지"에 따라 다른 값을 붙일 수 있어요.

```sql
SELECT 이름, 커미션, 급여 + NVL(커미션, 0), NVL2(커미션, '대상', '비대상') FROM 사원 ORDER BY 사번;
```

| 이름 | 커미션 | 급여 + NVL(커미션, 0) | NVL2(커미션, '대상', '비대상') |
|---|---|---|---|
| 김민수 | NULL | 3000 | 비대상 |
| 이지은 | 300 | 2800 | 대상 |
| 박서준 | 0 | 2800 | 대상 |
| 최유나 | NULL | 3200 | 비대상 |
| 정하늘 | NULL | 2500 | 비대상 |
| 한도윤 | 500 | 3200 | 대상 |
| 오지민 | 200 | 2400 | 대상 |
| 윤서연 | NULL | 2000 | 비대상 |

커미션이 0인 박서준은 NULL이 아니므로 NVL은 0을 그대로 두고, NVL2는 '대상'을 돌려줘요.

## NULLIF와 COALESCE {{#nullif-coalesce}}

NULLIF는 NVL과 반대 방향으로, 값을 NULL로 만드는 함수예요. 두 값이 같으면 NULL을 돌려주고, 다르면 첫 번째 값을 돌려줘요. 0으로 나누면 오류가 나는데, 나누는 수를 `NULLIF(커미션, 0)`으로 감싸면 0이 NULL로 바뀌어 오류 대신 NULL이 나와요.

```sql
SELECT 이름, NULLIF(커미션, 0), ROUND(급여 / NULLIF(커미션, 0), 2) FROM 사원 WHERE 사번 IN (1002, 1003);
-- 오류: 박서준의 커미션 0으로는 나눌 수 없어요 (ORA-01476, 나누는 수가 0)
SELECT 급여 / 커미션 FROM 사원 WHERE 사번 = 1003;
```

첫 SQL은 박서준의 커미션 0을 NULL로 바꿔서, 오류 대신 NULL을 돌려줘요.

| 이름 | NULLIF(커미션, 0) | ROUND(급여 / NULLIF(커미션, 0), 2) |
|---|---|---|
| 이지은 | 300 | 8.33 |
| 박서준 | NULL | NULL |

COALESCE는 인자를 여러 개 받아서 왼쪽부터 차례로 보다가 처음으로 NULL이 아닌 값을 돌려줘요. 모든 인자가 NULL이면 NULL을 돌려주고, 인자를 두 개만 주면 NVL과 같은 일을 해요.

```sql
SELECT COALESCE(NULL, NULL, 3, 4), COALESCE(NULL, 'B', 'C'), NULLIF(10, 20) FROM DUAL;   -- 결과는 차례로 3, B, 10이에요
```

## 공집합과 NULL {{#empty-set}}

공집합은 조건에 맞는 행이 하나도 없어서 결과가 0행인 상태예요. NULL은 행은 있는데 그 칸에 값이 없는 상태라서 둘은 서로 달라요. NVL은 행마다 칸의 NULL을 바꾸는 함수라서, 행이 하나도 없으면 바꿀 대상이 없고 결과도 그대로 0행이에요. NVL2, NULLIF, COALESCE도 행마다 계산하는 단일행 함수라서, 행이 없으면 똑같이 0행이 나와요.

반면 여러 행을 묶어 값 하나를 만드는 MAX, MIN, SUM, AVG 같은 집계 함수는 행이 하나도 없어도 NULL 한 행을 돌려줘요. 그래서 바깥에 NVL을 씌운 `NVL(MAX(급여), 0)`은 그 NULL을 0으로 바꿔 0 한 행을 돌려줘요. 행 수를 세는 COUNT만은 예외로, 행이 없으면 NULL이 아니라 0을 돌려줘요. 사원이 없는 40번 인사부로 확인해 보면 차이가 보여요.

```sql
SELECT NVL(급여, 0) FROM 사원 WHERE 부서번호 = 40;        -- 바꿀 행이 없어서 0행이에요
SELECT MAX(급여) FROM 사원 WHERE 부서번호 = 40;           -- 행이 없어도 NULL 한 행이 나와요
SELECT NVL(MAX(급여), 0) FROM 사원 WHERE 부서번호 = 40;   -- 그 NULL을 0으로 바꿔 0 한 행이 나와요
SELECT COUNT(*) FROM 사원 WHERE 부서번호 = 40;           -- COUNT는 NULL이 아니라 0 한 행을 돌려줘요
```

이 방법은 "부서의 최고 급여를 구하되 사원이 없으면 0으로 보여 달라" 같은 요구에 자주 써요. 집계 함수가 행을 묶는 방식은 그룹 함수 단원에서 자세히 다뤄요.

## 다른 DBMS의 NULL 함수 이름 {{#other-dbms}}

DBMS는 데이터베이스를 관리하는 프로그램이고, Oracle, SQL Server, MySQL이 그 예예요. "NULL이면 다른 값으로 바꾸기"는 어느 DBMS에나 있지만 함수 이름이 서로 달라요. 시험은 Oracle을 기준으로 하면서도 다른 DBMS의 이름을 보기에 섞어 내므로, 이름과 뜻을 함께 정리해 두면 좋아요.

| DBMS | NULL이면 바꾸기 | 뜻 |
|---|---|---|
| Oracle | NVL(a, b) | a가 NULL이면 b, 아니면 a |
| SQL Server | ISNULL(a, b) | NVL과 같아요 |
| MySQL | IFNULL(a, b) | NVL과 같아요 |
| SQL 표준 (세 DBMS 모두) | COALESCE(a, b, ...) | 처음으로 NULL이 아닌 값 |

ISNULL과 IFNULL은 Oracle에 없는 함수라서, Oracle에서 실행하면 ORA-00904(없는 이름) 오류가 나요. 그래서 아래 블록은 실행하지 않고 모양만 보여 줘요. 세 줄 모두 커미션이 NULL이면 0을, 아니면 커미션을 그대로 돌려줘요.

```sql
-- 문법: 같은 뜻을 DBMS마다 다른 이름으로 써요
SELECT NVL(커미션, 0) FROM 사원;      -- Oracle
SELECT ISNULL(커미션, 0) FROM 사원;   -- SQL Server
SELECT IFNULL(커미션, 0) FROM 사원;   -- MySQL
```

NVL2는 Oracle에만 있어서, 다른 DBMS에서는 같은 뜻을 CASE 식으로 써요. NULLIF는 SQL 표준이라 세 DBMS에서 모두 같은 이름과 같은 뜻으로 써요.

**NULLIF는 IFNULL과 이름만 비슷해요.** IFNULL은 NULL을 다른 값으로 바꾸는 함수이고, NULLIF는 두 값이 같으면 NULL을 만드는 함수라서 하는 일이 반대예요. 글자 순서만 바뀐 이름이라 시험에서 함정으로 나와요. 아래 결과에서 NVL과 COALESCE는 같은 값을 돌려주지만, NULLIF만 다른 값을 돌려줘요.

{NULL_REPLACE_VERSUS_NULLIF_EXAMPLE.markdown}

김민수(1001)의 커미션은 NULL인데, NULLIF는 NULL을 바꿔 주지 않아서 결과도 NULL이에요. 박서준(1003)의 커미션 0은 두 번째 값 0과 같아서 NULLIF가 NULL로 만들어요. 커미션이 300인 이지은(1002)은 세 함수 모두 커미션 그대로 300을 돌려줘요.

## 자주 헷갈리는 점 {{#confusing}}

**NVL2는 NULL이 아닐 때의 값을 먼저 적어요.** NVL에서는 두 번째 인자가 "NULL일 때의 값"이라서, NVL2의 두 번째 인자도 같은 뜻이라고 생각하기 쉬워요. NVL2(커미션, '대상', '비대상')에서 두 번째 '대상'은 커미션이 있을 때, 세 번째 '비대상'은 커미션이 NULL일 때의 값이에요.

**0은 NULL이 아니에요.** 박서준의 커미션 0은 값이 있는 상태라서 NVL은 0을 그대로 두고, NVL2는 '대상'으로, `COALESCE(0, 7)`은 0으로 처리해요. 그런데 `WHERE NVL(커미션, 0) = 0`처럼 NULL을 0으로 바꾼 뒤 비교하면, 원래 0인 박서준과 NULL인 네 명이 함께 나와 다섯 명이 돼요.

```sql
SELECT 이름 FROM 사원 WHERE NVL(커미션, 0) = 0;
SELECT COALESCE(0, 7) FROM DUAL;   -- 0은 NULL이 아니라서 0이 나와요
```

첫 SQL의 결과는 아래 다섯 명이에요.

| 이름 | 원래 커미션 |
|---|---|
| 김민수 | NULL |
| 박서준 | 0 |
| 최유나 | NULL |
| 정하늘 | NULL |
| 윤서연 | NULL |

**NULLIF는 다르면 첫 번째 값을 돌려줘요.** 같을 때 NULL이 된다는 점만 기억하고 다를 때의 결과를 두 번째 값이나 차이로 착각하는 경우가 많아요. 급여가 2700인 한도윤에게 `NULLIF(급여, 2500)`을 쓰면, 두 값이 다르므로 첫 번째 값인 2700이 나와요.

**NVL의 두 인자는 타입이 맞아야 해요.** Oracle은 두 번째 인자를 첫 번째 인자의 타입으로 바꾸려고 해요. 그래서 숫자인 커미션에 `NVL(커미션, '없음')`을 쓰면 '없음'을 숫자로 바꾸지 못해 오류가 나요. 커미션을 먼저 문자로 바꾼 `NVL(TO_CHAR(커미션), '없음')`은 잘 동작해요. COALESCE는 더 엄격해서 인자들의 타입이 다르면 바꿔 보지도 않고 오류를 내요. 그래서 `NVL(커미션, '0')`은 '0'을 숫자 0으로 바꿔 동작하지만, `COALESCE(커미션, '0')`은 오류가 나요.

```sql
-- 오류: '없음'을 숫자로 바꿀 수 없어요 (ORA-01722, 숫자로 바꿀 수 없음)
SELECT NVL(커미션, '없음') FROM 사원;
-- 오류: COALESCE는 숫자와 문자를 섞을 수 없어요 (ORA-00932, 인자의 타입이 서로 다름)
SELECT COALESCE(커미션, '없음') FROM 사원;
SELECT 이름, NVL(TO_CHAR(커미션), '없음') FROM 사원 WHERE 사번 IN (1001, 1002);
```

| 이름 | NVL(TO_CHAR(커미션), '없음') |
|---|---|
| 김민수 | 없음 |
| 이지은 | 300 |

**공집합에서는 집계 함수 안쪽의 NVL이 소용없어요.** `MAX(NVL(급여, 0))`은 행마다 NVL을 먼저 적용하는데, 행이 하나도 없으면 NVL이 할 일이 없고 MAX가 NULL을 돌려줘요. 0을 얻으려면 NVL을 집계 함수 바깥에 씌워야 해요.

```sql
SELECT MAX(NVL(급여, 0)), NVL(MAX(급여), 0) FROM 사원 WHERE 부서번호 = 40;   -- 결과는 차례로 NULL, 0이에요
```

**이름이 비슷한 ISNULL, IS NULL, IFNULL, NULLIF를 구분해요.** SQL Server의 `ISNULL(커미션, 0)`과 MySQL의 `IFNULL(커미션, 0)`은 Oracle의 `NVL(커미션, 0)`과 같은 일을 해요. 띄어 쓴 `커미션 IS NULL`은 NULL인지 묻는 조건이라서 값을 바꾸지 않아요. MySQL에도 ISNULL이라는 함수가 있지만 인자를 하나만 받아 NULL이면 1, 아니면 0을 돌려주므로, SQL Server의 ISNULL과는 쓰임이 달라요. NULLIF만은 NULL을 바꾸는 쪽이 아니라 같으면 NULL을 만드는 쪽이에요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

예시 표에 NVL, NVL2, NULLIF, COALESCE를 쓴 SQL을 주고 결과를 고르는 문제가 가장 많아요. NVL2의 인자 순서, 커미션 0과 NULL의 구분, NULLIF가 다를 때 돌려주는 값이 단골 함정이에요. NVL, COALESCE, IFNULL, NULLIF, NVL2를 한 보기에 섞어 뜻이 다른 하나를 고르게 하는 문제도 나오는데, NULLIF만 같으면 NULL을 만들고 IFNULL과 ISNULL은 NVL과 같은 뜻이라는 점으로 가르면 돼요. 조건에 맞는 행이 없을 때 `NVL(MAX(...), 0)`과 `NVL(열, 0)`의 결과 행 수를 비교하는 문제도 자주 나오는데, 집계 함수는 행이 없어도 한 행을 돌려준다는 점만 기억하면 풀려요.""",
    "checkQuestions": [
        question(1, "NVL2(커미션, '대상', '비대상')의 뜻으로 알맞은 것은 무엇인가요?", "definition",
                 "NVL2는 첫 번째 값이 NULL이 아니면 두 번째 값을, NULL이면 세 번째 값을 돌려줘요. 그래서 커미션이 있으면 '대상', 없으면 '비대상'이에요.",
                 [choice("A", "커미션이 NULL이 아니면 '대상', NULL이면 '비대상'", True, "두 번째 인자가 NULL이 아닐 때의 값이에요."),
                  choice("B", "커미션이 NULL이면 '대상', NULL이 아니면 '비대상'", rationale="NVL처럼 두 번째 인자를 NULL일 때의 값으로 거꾸로 읽었어요."),
                  choice("C", "커미션이 0이면 '비대상', 아니면 '대상'", rationale="NVL2는 0이 아니라 NULL인지를 봐요."),
                  choice("D", "커미션과 '대상'이 같으면 NULL", rationale="두 값이 같은지 보는 함수는 NULLIF예요.")]),
        question(2, "박서준(사번 1003)의 커미션은 0이에요. 다음 SQL의 결과는 무엇인가요?", "confusing",
                 "0은 NULL이 아닌 값이에요. 그래서 NVL2는 NULL이 아닐 때의 값인 '대상'을 돌려줘요.",
                 [choice("A", "비대상", rationale="0을 NULL로 보았는데, 0은 값이 있는 상태예요."),
                  choice("B", "대상", True, "커미션 0은 NULL이 아니므로 두 번째 값이 나와요."),
                  choice("C", "NULL", rationale="NVL2는 두 번째나 세 번째 값 중 하나를 돌려줘요."),
                  choice("D", "0", rationale="NVL2는 커미션 값이 아니라 '대상'이나 '비대상'을 돌려줘요.")],
                 stem_sql="SELECT NVL2(커미션, '대상', '비대상') FROM 사원 WHERE 사번 = 1003;"),
        question(3, "한도윤(사번 1006)의 급여는 2700이에요. 다음 SQL의 결과는 무엇인가요?", "confusing",
                 "NULLIF는 두 값이 같을 때만 NULL을 돌려주고, 다르면 첫 번째 값을 돌려줘요. 2700과 2500은 다르므로 2700이에요.",
                 [choice("A", "NULL", rationale="두 값이 같을 때의 결과이고, 2700과 2500은 달라요."),
                  choice("B", "2500", rationale="다를 때는 두 번째가 아니라 첫 번째 값을 돌려줘요."),
                  choice("C", "200", rationale="NULLIF는 두 값의 차이를 계산하지 않아요."),
                  choice("D", "2700", True, "두 값이 달라서 첫 번째 값이 나와요.")],
                 stem_sql="SELECT NULLIF(급여, 2500) FROM 사원 WHERE 사번 = 1006;"),
        question(4, "커미션이 NULL이면 0을, NULL이 아니면 커미션을 그대로 돌려준다는 뜻이 아닌 것은 무엇인가요?", "other-dbms",
                 "NVL, COALESCE, IFNULL은 모두 NULL을 0으로 바꾸는 같은 뜻이에요. NULLIF는 커미션이 0과 같으면 NULL을 돌려주는 함수라서 뜻이 달라요.",
                 [choice("A", "Oracle의 NVL(커미션, 0)", rationale="커미션이 NULL이면 0으로 바꾸는 함수예요."),
                  choice("B", "NULLIF(커미션, 0)", True, "커미션이 0이면 NULL을 돌려주고, NULL을 0으로 바꾸지 않아요."),
                  choice("C", "SQL 표준의 COALESCE(커미션, 0)", rationale="인자가 두 개면 NVL과 같은 일을 해요."),
                  choice("D", "MySQL의 IFNULL(커미션, 0)", rationale="MySQL에서 NVL과 같은 일을 하는 함수예요.")]),
        question(5, "40번 인사부에는 소속 사원이 없어요. 다음 중 결과가 숫자 0 한 행으로 나오는 SQL은 무엇인가요?", "empty-set",
                 "행이 없어도 집계 함수 MAX는 NULL 한 행을 돌려주고, 바깥의 NVL이 그 NULL을 0으로 바꿔요. 나머지는 0행이거나 NULL 한 행이에요.",
                 [choice("A", "SELECT NVL(커미션, 0) FROM 사원 WHERE 부서번호 = 40", rationale="바꿀 행이 없어서 0행이 나와요."),
                  choice("B", "SELECT MAX(NVL(커미션, 0)) FROM 사원 WHERE 부서번호 = 40", rationale="안쪽 NVL은 할 일이 없고 MAX가 NULL 한 행을 돌려줘요."),
                  choice("C", "SELECT NVL(MAX(커미션), 0) FROM 사원 WHERE 부서번호 = 40", True, "MAX의 NULL을 바깥 NVL이 0으로 바꿔요."),
                  choice("D", "SELECT NVL2(커미션, 커미션, 0) FROM 사원 WHERE 부서번호 = 40", rationale="NVL2도 행마다 적용되므로 0행이 나와요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 예시
        sql_check("SELECT NVL(NULL, 0), NVL2(NULL, '있음', '없음'), NULLIF(10, 10), COALESCE(NULL, NULL, 3, 4) FROM DUAL",
                  [[0, "없음", None, 3]]),
        sql_check("SELECT 이름, 커미션, 급여 + NVL(커미션, 0), NVL2(커미션, '대상', '비대상') FROM 사원 ORDER BY 사번",
                  [["김민수", None, 3000, "비대상"], ["이지은", 300, 2800, "대상"], ["박서준", 0, 2800, "대상"],
                   ["최유나", None, 3200, "비대상"], ["정하늘", None, 2500, "비대상"], ["한도윤", 500, 3200, "대상"],
                   ["오지민", 200, 2400, "대상"], ["윤서연", None, 2000, "비대상"]], is_ordered=True),
        sql_check("SELECT 이름, NULLIF(커미션, 0), ROUND(급여 / NULLIF(커미션, 0), 2) FROM 사원 WHERE 사번 IN (1002, 1003)",
                  [["이지은", 300, 8.33], ["박서준", None, None]]),
        sql_error_check("SELECT 급여 / 커미션 FROM 사원 WHERE 사번 = 1003", "ORA-01476"),
        sql_check("SELECT COALESCE(NULL, NULL, 3, 4), COALESCE(NULL, 'B', 'C'), NULLIF(10, 20) FROM DUAL", [[3, "B", 10]]),
        sql_check("SELECT NVL(급여, 0) FROM 사원 WHERE 부서번호 = 40", []),
        sql_check("SELECT MAX(급여) FROM 사원 WHERE 부서번호 = 40", [[None]]),
        sql_check("SELECT NVL(MAX(급여), 0) FROM 사원 WHERE 부서번호 = 40", [[0]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 부서번호 = 40", [[0]]),
        sql_check("SELECT 이름 FROM 사원 WHERE NVL(커미션, 0) = 0",
                  [["김민수"], ["박서준"], ["최유나"], ["정하늘"], ["윤서연"]]),
        sql_check("SELECT COALESCE(0, 7) FROM DUAL", [[0]]),
        sql_error_check("SELECT NVL(커미션, '없음') FROM 사원", "ORA-01722"),
        sql_error_check("SELECT COALESCE(커미션, '없음') FROM 사원", "ORA-00932"),
        sql_check("SELECT NVL(커미션, '0') FROM 사원 WHERE 사번 = 1001", [[0]]),
        sql_error_check("SELECT COALESCE(커미션, '0') FROM 사원 WHERE 사번 = 1001", "ORA-00932"),
        sql_check("SELECT 이름, NVL(TO_CHAR(커미션), '없음') FROM 사원 WHERE 사번 IN (1001, 1002)",
                  [["김민수", "없음"], ["이지은", "300"]]),
        sql_check("SELECT MAX(NVL(급여, 0)), NVL(MAX(급여), 0) FROM 사원 WHERE 부서번호 = 40", [[None, 0]]),
        sql_check("SELECT 급여 + 커미션 FROM 사원 WHERE 사번 = 1001", [[None]]),
        # 확인 문제 (stemSql·보기)
        sql_check("SELECT NVL2(커미션, '대상', '비대상') FROM 사원 WHERE 사번 = 1003;", [["대상"]]),
        sql_check("SELECT NULLIF(급여, 2500) FROM 사원 WHERE 사번 = 1006;", [[2700]]),
        # 확인 문제 4 보기 (Oracle 에서 실행되는 NVL·COALESCE·NULLIF)
        NULL_REPLACE_VERSUS_NULLIF_EXAMPLE.check,
        sql_check("SELECT NVL(커미션, 0) FROM 사원 WHERE 부서번호 = 40", []),
        sql_check("SELECT MAX(NVL(커미션, 0)) FROM 사원 WHERE 부서번호 = 40", [[None]]),
        sql_check("SELECT NVL(MAX(커미션), 0) FROM 사원 WHERE 부서번호 = 40", [[0]]),
        sql_check("SELECT NVL2(커미션, 커미션, 0) FROM 사원 WHERE 부서번호 = 40", []),
    ],
}
