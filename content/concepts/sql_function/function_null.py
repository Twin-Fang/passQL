"""개념: NULL 관련 함수 (4단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

EMPLOYEE_COMMISSION_TABLE = to_employee_table_md("사번", "이름", "급여", "커미션", "부서번호")

# NVL(NULL 이면 바꾸기) <-> NVL2(NULL 여부로 고르기): 사원 8명
NVL_VERSUS_NVL2_EXAMPLE = sql_example(
    "SELECT 이름, 커미션, 급여 + NVL(커미션, 0), NVL2(커미션, '대상', '비대상')\n"
    "FROM 사원\n"
    "ORDER BY 사번;",
    ("이름", "커미션", "급여 + NVL(커미션, 0)", "NVL2(커미션, '대상', '비대상')"),
    [["김민수", None, 3000, "비대상"], ["이지은", 300, 2800, "대상"], ["박서준", 0, 2800, "대상"],
     ["최유나", None, 3200, "비대상"], ["정하늘", None, 2500, "비대상"], ["한도윤", 500, 3200, "대상"],
     ["오지민", 200, 2400, "대상"], ["윤서연", None, 2000, "비대상"]],
)

# NULLIF 로 0 나누기 피하기: 커미션 300, 0 두 사원
NULLIF_DIVISION_EXAMPLE = sql_example(
    "SELECT 이름, NULLIF(커미션, 0), ROUND(급여 / NULLIF(커미션, 0), 2)\n"
    "FROM 사원\n"
    "WHERE 사번 IN (1002, 1003)\n"
    "ORDER BY 사번;",
    ("이름", "NULLIF(커미션, 0)", "ROUND(급여 / NULLIF(커미션, 0), 2)"),
    [["이지은", 300, 8.33], ["박서준", None, None]],
)

# NVL, COALESCE(NULL 바꾸기) <-> NULLIF(같으면 NULL): 커미션 NULL, 300, 0 세 사원
NULL_REPLACE_VERSUS_NULLIF_EXAMPLE = sql_example(
    "SELECT 사번, 커미션, NVL(커미션, 0), COALESCE(커미션, 0), NULLIF(커미션, 0)\n"
    "FROM 사원\n"
    "WHERE 사번 IN (1001, 1002, 1003)\n"
    "ORDER BY 사번;",
    ("사번", "커미션", "NVL(커미션, 0)", "COALESCE(커미션, 0)", "NULLIF(커미션, 0)"),
    [[1001, None, 0, 0, None], [1002, 300, 300, 300, 300], [1003, 0, 0, 0, None]],
)

# NULL 을 0 으로 바꾼 뒤 비교: 원래 0(박서준) + NULL 4명 = 5명
NVL_ZERO_FILTER_EXAMPLE = sql_example(
    "SELECT 이름, 커미션\n"
    "FROM 사원\n"
    "WHERE NVL(커미션, 0) = 0\n"
    "ORDER BY 사번;",
    ("이름", "원래 커미션"),
    [["김민수", None], ["박서준", 0], ["최유나", None], ["정하늘", None], ["윤서연", None]],
)

# 숫자 커미션을 문자로 바꾼 뒤 NVL (타입 맞추기)
NVL_TO_CHAR_EXAMPLE = sql_example(
    "SELECT 이름, NVL(TO_CHAR(커미션), '없음')\n"
    "FROM 사원\n"
    "WHERE 사번 IN (1001, 1002)\n"
    "ORDER BY 사번;",
    ("이름", "NVL(TO_CHAR(커미션), '없음')"),
    [["김민수", "없음"], ["이지은", "300"]],
)

CONCEPT = {
    "tagKey": "function-null",
    "topicCode": "sql_function",
    "sortOrder": 6,
    "title": "NULL 관련 함수",
    "summary": "NULL을 다른 값으로 바꾸거나 값을 NULL로 만드는 함수이고, 인자 순서를 자주 물어요",
    "coreMd": (
        "- `NVL(값, 대신할 값)`은 NULL일 때만 바꾸고, `NVL2(값, NULL이 아닐 때, NULL일 때)`는 **NULL이 아닐 때 값을 먼저** 적어요.\n"
        "- `NULLIF(a, b)`는 **같으면 NULL**, 다르면 a이고, `COALESCE`는 처음으로 NULL이 아닌 값을 돌려줘요.\n"
        "- NVL의 두 인자는 **타입이 맞아야** 해서, 숫자 커미션은 `NVL(TO_CHAR(커미션), '없음')`처럼 바꿔 써요.\n"
        "- 행이 없으면 `NVL(열, 0)`은 **0행**이고, `NVL(MAX(열), 0)`은 0 한 행이에요.\n"
        "- SQL Server의 `ISNULL`과 MySQL의 `IFNULL`은 NVL과 같고, 이름이 비슷한 `NULLIF`는 전혀 다른 함수예요."
    ),
    "detailMd": f"""## NULL 관련 함수가 하는 일: NULL과 다른 값 사이를 바꿔요 {{#why}}

NULL이 섞인 계산은 결과도 NULL이 돼서, 김민수의 급여 3000에 커미션 NULL을 더하면 NULL이 나와요. 그래서 "NULL이면 0으로 보라"고 알려 주는 함수가 필요하고, 반대로 0처럼 계산을 방해하는 값을 NULL로 바꾸는 함수도 있어요.

아래 예시는 모두 이 사원 표로 설명해요.

{EMPLOYEE_COMMISSION_TABLE}

```sql
SELECT 급여 + 커미션 FROM 사원 WHERE 사번 = 1001;   -- 커미션이 NULL이라 결과도 NULL이에요
```

## 네 가지 함수 한눈에 보기: 바꾸는 쪽과 만드는 쪽 {{#definition}}

| 함수 | 돌려주는 값 | 예 | 결과 |
|---|---|---|---|
| NVL(a, b) | a가 NULL이면 b, 아니면 a | NVL(NULL, 0) | 0 |
| NVL2(a, b, c) | a가 NULL이 아니면 b, NULL이면 c | NVL2(NULL, '있음', '없음') | 없음 |
| NULLIF(a, b) | a와 b가 같으면 NULL, 다르면 a | NULLIF(10, 10) | NULL |
| COALESCE(a, b, ...) | 처음 만난 NULL 아닌 값 | COALESCE(NULL, NULL, 3, 4) | 3 |

| 함수 | 외우는 말 |
|---|---|
| NULLIF | "같이 놀자": 같으면 NULL이에요 |
| COALESCE | "널 아닌 첫 번째 값"을 돌려줘요 |

```sql
SELECT NVL(NULL, 0), NVL2(NULL, '있음', '없음'), NULLIF(10, 10), COALESCE(NULL, NULL, 3, 4) FROM DUAL;
-- 결과는 차례로 0, 없음, NULL, 3이에요
```

인자 순서가 헷갈리면 같은 뜻의 CASE 식을 떠올려요.

```sql
-- 문법: 네 함수를 같은 뜻의 CASE 식으로 바꾼 모양이에요
NVL(a, b)         = CASE WHEN a IS NULL THEN b ELSE a END
NVL2(a, b, c)     = CASE WHEN a IS NOT NULL THEN b ELSE c END
NULLIF(a, b)      = CASE WHEN a = b THEN NULL ELSE a END
COALESCE(a, b, c) = CASE WHEN a IS NOT NULL THEN a WHEN b IS NOT NULL THEN b ELSE c END
```

## NVL과 NVL2: 값을 바꾸나, 있는지로 고르나 {{#nvl-nvl2}}

NVL은 첫 번째 값이 NULL일 때만 두 번째 값으로 바꿔요. NVL2는 NULL인지만 보고, 아니면 두 번째 값을, NULL이면 세 번째 값을 돌려줘요.

{NVL_VERSUS_NVL2_EXAMPLE.markdown}

커미션이 0인 박서준은 NULL이 아니라서 NVL은 0을 그대로 두고, NVL2는 '대상'을 돌려줘요.

## NULLIF와 COALESCE: 같으면 NULL, 처음 만난 값 {{#nullif-coalesce}}

NULLIF는 NVL과 반대 방향으로 값을 NULL로 만들어요. 나누는 수를 `NULLIF(커미션, 0)`으로 감싸면 0이 NULL로 바뀌어 오류 대신 NULL이 나와요.

{NULLIF_DIVISION_EXAMPLE.markdown}

```sql
-- 오류: 박서준의 커미션 0으로는 나눌 수 없어요 (ORA-01476, 나누는 수가 0)
SELECT 급여 / 커미션 FROM 사원 WHERE 사번 = 1003;
SELECT COALESCE(NULL, NULL, 3, 4), COALESCE(NULL, 'B', 'C'), NULLIF(10, 20) FROM DUAL;   -- 결과는 차례로 3, B, 10이에요
```

COALESCE는 왼쪽부터 보아 처음으로 NULL이 아닌 값을 돌려줘요. 인자가 모두 NULL이면 NULL을 돌려주고, 인자를 두 개만 주면 NVL과 같은 일을 해요.

## 공집합과 NULL: 행이 없으면 NVL도 할 일이 없어요 {{#empty-set}}

| 용어 | 뜻 |
|---|---|
| 공집합 | 조건에 맞는 행이 하나도 없어서 결과가 0행인 상태예요 |
| NULL | 행은 있는데 그 칸에 값이 없는 상태예요 |
| 단일행 함수 | NVL, NVL2, NULLIF, COALESCE처럼 행마다 계산해요. 행이 없으면 결과도 0행이에요 |
| 집계 함수 | MAX, MIN, SUM, AVG처럼 여러 행을 묶어 값 하나를 만들어요. 행이 없어도 NULL 한 행을 돌려줘요 |

COUNT만은 예외로, 행이 없으면 NULL이 아니라 0을 돌려줘요. 사원이 없는 40번 인사부로 확인해 볼게요.

```sql
SELECT NVL(급여, 0) FROM 사원 WHERE 부서번호 = 40;        -- 바꿀 행이 없어서 0행이에요
SELECT MAX(급여) FROM 사원 WHERE 부서번호 = 40;           -- 행이 없어도 NULL 한 행이 나와요
SELECT NVL(MAX(급여), 0) FROM 사원 WHERE 부서번호 = 40;   -- 그 NULL을 0으로 바꿔 0 한 행이 나와요
SELECT COUNT(*) FROM 사원 WHERE 부서번호 = 40;           -- COUNT는 NULL이 아니라 0 한 행을 돌려줘요
```

"부서의 최고 급여를 구하되 사원이 없으면 0으로 보여 달라" 같은 요구에 이 방법을 써요. 집계 함수가 행을 묶는 방식은 그룹 함수 단원에서 자세히 다뤄요.

## 다른 DBMS의 NULL 함수: 이름은 달라도 뜻이 같은 것 {{#other-dbms}}

DBMS는 데이터베이스를 관리하는 프로그램이고, Oracle, SQL Server, MySQL이 그 예예요. 시험은 Oracle을 기준으로 하면서 다른 DBMS의 이름을 보기에 섞어 내요.

| DBMS | NULL이면 바꾸기 | 뜻 |
|---|---|---|
| Oracle | NVL(a, b) | a가 NULL이면 b, 아니면 a |
| SQL Server | ISNULL(a, b) | NVL과 같아요 |
| MySQL | IFNULL(a, b) | NVL과 같아요 |
| SQL 표준 (세 DBMS 모두) | COALESCE(a, b, ...) | 처음으로 NULL이 아닌 값 |

ISNULL과 IFNULL은 Oracle에 없어서 실행하면 ORA-00904(없는 이름) 오류가 나요. 그래서 아래 블록은 모양만 보여 주고, 세 줄 모두 커미션이 NULL이면 0을 돌려줘요.

```sql
-- 문법: 같은 뜻을 DBMS마다 다른 이름으로 써요
SELECT NVL(커미션, 0) FROM 사원;      -- Oracle
SELECT ISNULL(커미션, 0) FROM 사원;   -- SQL Server
SELECT IFNULL(커미션, 0) FROM 사원;   -- MySQL
```

| 함수 | 쓰는 곳 |
|---|---|
| NVL2 | Oracle에만 있어서, 다른 DBMS에서는 CASE 식으로 써요 |
| NULLIF | SQL 표준이라 세 DBMS에서 같은 이름, 같은 뜻으로 써요 |

IFNULL과 NULLIF는 글자 순서만 바뀐 이름이라 함정으로 나와요. 아래에서 NVL과 COALESCE는 같은 값을 돌려주지만, NULLIF만 다른 값을 돌려줘요.

{NULL_REPLACE_VERSUS_NULLIF_EXAMPLE.markdown}

김민수(1001)의 NULL은 NULLIF가 바꿔 주지 않아서 그대로 NULL이에요. 박서준(1003)의 0은 두 번째 값 0과 같아서 NULLIF가 NULL로 만들어요.

## 자주 헷갈리는 점: 인자 순서, 0, 타입 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| NVL2의 두 번째 인자는 NULL일 때의 값이에요 | NVL2의 두 번째는 NULL이 아닐 때, 세 번째가 NULL일 때의 값이에요 |
| 커미션 0은 NULL과 같아요 | 0은 값이 있는 상태라서 NVL은 0을 두고, NVL2는 '대상'을, `COALESCE(0, 7)`은 0을 돌려줘요 |
| NULLIF는 두 값이 다르면 두 번째 값을 돌려줘요 | 다르면 첫 번째 값을 돌려줘요. 급여 2700인 한도윤의 `NULLIF(급여, 2500)`은 2700이에요 |
| `NVL(커미션, '없음')`으로 숫자 NULL을 글자로 바꿔요 | 두 번째 인자를 첫 번째 타입으로 바꾸려다 ORA-01722(숫자로 바꿀 수 없음) 오류가 나요 |
| COALESCE도 NVL처럼 타입을 맞춰 줘요 | COALESCE는 더 엄격해서, `COALESCE(커미션, '0')`도 ORA-00932(인자의 타입이 서로 다름) 오류예요 |
| `MAX(NVL(급여, 0))`은 행이 없어도 0이에요 | 행이 없으면 안쪽 NVL은 할 일이 없고 MAX가 NULL을 돌려줘요. NVL을 바깥에 씌워야 해요 |
| `커미션 IS NULL`도 NULL을 바꾸는 함수예요 | IS NULL은 NULL인지 묻는 조건이라 값을 바꾸지 않아요 |
| MySQL의 ISNULL은 SQL Server의 ISNULL과 같아요 | MySQL의 ISNULL은 인자 하나를 받아 NULL이면 1, 아니면 0을 돌려줘요 |

NULL을 0으로 바꾼 뒤 비교하면, 원래 0인 박서준과 NULL인 네 명이 함께 나와 다섯 명이 돼요.

{NVL_ZERO_FILTER_EXAMPLE.markdown}

```sql
SELECT COALESCE(0, 7) FROM DUAL;   -- 0은 NULL이 아니라서 0이 나와요
-- 오류: '없음'을 숫자로 바꿀 수 없어요 (ORA-01722, 숫자로 바꿀 수 없음)
SELECT NVL(커미션, '없음') FROM 사원;
-- 오류: COALESCE는 숫자와 문자를 섞을 수 없어요 (ORA-00932, 인자의 타입이 서로 다름)
SELECT COALESCE(커미션, '없음') FROM 사원;
SELECT MAX(NVL(급여, 0)), NVL(MAX(급여), 0) FROM 사원 WHERE 부서번호 = 40;   -- 결과는 차례로 NULL, 0이에요
```

`NVL(커미션, '0')`은 '0'을 숫자 0으로 바꿔 동작해요. 커미션을 먼저 문자로 바꾸면 '없음'과도 섞을 수 있어요.

{NVL_TO_CHAR_EXAMPLE.markdown}

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| COALESCE(NULL, NULL)의 결과는 NULL이에요 | O | 인자가 모두 NULL이면 NULL을 돌려줘요 |
| 행이 없는 조건에서 COUNT(*)는 NULL을 돌려줘요 | X | COUNT는 예외로 0 한 행을 돌려줘요 |
| NVL(커미션, '0')은 커미션이 숫자라서 오류가 나요 | X | '0'은 숫자로 바꿀 수 있어서 NVL은 동작해요 |

## 꼭 외울 것: 인자 순서와 DBMS별 이름 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| NVL(a, b) | a가 NULL이면 b, 아니면 a |
| NVL2(a, b, c)의 b와 c | b는 NULL이 아닐 때, c는 NULL일 때 |
| NULLIF(a, b) | 같으면 NULL, 다르면 첫 번째 값 a |
| COALESCE(a, b, ...) | 왼쪽부터 처음 만난 NULL 아닌 값, 모두 NULL이면 NULL |
| 행이 없을 때 NVL과 집계 | NVL(열, 0)은 0행, NVL(MAX(열), 0)은 0 한 행 |
| 숫자와 문자 섞기 | NVL은 둘째 인자를 첫 인자 타입으로 바꿔 보고, COALESCE는 오류 |
| NVL과 같은 다른 이름 | SQL Server는 ISNULL(a, b), MySQL은 IFNULL(a, b) |
| 표준 함수와 Oracle 전용 | NULLIF, COALESCE는 표준, NVL, NVL2는 Oracle |

## 시험에서는 이렇게 나와요 {{#exam-point}}

예시 표에 NVL, NVL2, NULLIF, COALESCE를 쓴 SQL을 주고 결과를 고르는 문제가 가장 많아요. NVL2의 인자 순서, 커미션 0과 NULL의 구분, NULLIF가 다를 때 돌려주는 값이 단골 함정이에요.

| 나오는 모양 | 푸는 법 |
|---|---|
| 뜻이 다른 하나 고르기 (NVL, COALESCE, IFNULL, ISNULL, NULLIF) | NULLIF만 같으면 NULL을 만들고, 나머지는 NULL을 바꿔요 |
| 행이 없을 때 결과 행 수 | `NVL(열, 0)`은 0행, `NVL(MAX(열), 0)`은 한 행이에요 |
| NVL2 결과 | 두 번째가 NULL이 아닐 때, 세 번째가 NULL일 때예요 |""",
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
        NVL_VERSUS_NVL2_EXAMPLE.check,
        NULLIF_DIVISION_EXAMPLE.check,
        sql_error_check("SELECT 급여 / 커미션 FROM 사원 WHERE 사번 = 1003", "ORA-01476"),
        sql_check("SELECT COALESCE(NULL, NULL, 3, 4), COALESCE(NULL, 'B', 'C'), NULLIF(10, 20) FROM DUAL", [[3, "B", 10]]),
        sql_check("SELECT NVL(급여, 0) FROM 사원 WHERE 부서번호 = 40", []),
        sql_check("SELECT MAX(급여) FROM 사원 WHERE 부서번호 = 40", [[None]]),
        sql_check("SELECT NVL(MAX(급여), 0) FROM 사원 WHERE 부서번호 = 40", [[0]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 부서번호 = 40", [[0]]),
        NVL_ZERO_FILTER_EXAMPLE.check,
        sql_check("SELECT COALESCE(0, 7) FROM DUAL", [[0]]),
        sql_error_check("SELECT NVL(커미션, '없음') FROM 사원", "ORA-01722"),
        sql_error_check("SELECT COALESCE(커미션, '없음') FROM 사원", "ORA-00932"),
        sql_check("SELECT NVL(커미션, '0') FROM 사원 WHERE 사번 = 1001", [[0]]),
        sql_error_check("SELECT COALESCE(커미션, '0') FROM 사원 WHERE 사번 = 1001", "ORA-00932"),
        NVL_TO_CHAR_EXAMPLE.check,
        sql_check("SELECT COALESCE(NULL, NULL) FROM DUAL", [[None]]),
        sql_check("SELECT MAX(NVL(급여, 0)), NVL(MAX(급여), 0) FROM 사원 WHERE 부서번호 = 40", [[None, 0]]),
        sql_check("SELECT 급여 + 커미션 FROM 사원 WHERE 사번 = 1001", [[None]]),
        # 확인 문제 (stemSql, 보기)
        sql_check("SELECT NVL2(커미션, '대상', '비대상') FROM 사원 WHERE 사번 = 1003;", [["대상"]]),
        sql_check("SELECT NULLIF(급여, 2500) FROM 사원 WHERE 사번 = 1006;", [[2700]]),
        # 확인 문제 4 보기 (Oracle 에서 실행되는 NVL, COALESCE, NULLIF)
        NULL_REPLACE_VERSUS_NULLIF_EXAMPLE.check,
        sql_check("SELECT NVL(커미션, 0) FROM 사원 WHERE 부서번호 = 40", []),
        sql_check("SELECT MAX(NVL(커미션, 0)) FROM 사원 WHERE 부서번호 = 40", [[None]]),
        sql_check("SELECT NVL(MAX(커미션), 0) FROM 사원 WHERE 부서번호 = 40", [[0]]),
        sql_check("SELECT NVL2(커미션, 커미션, 0) FROM 사원 WHERE 부서번호 = 40", []),
    ],
}
