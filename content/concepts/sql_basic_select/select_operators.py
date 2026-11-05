"""개념: 비교·논리 연산자와 우선순위 (2단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

EMPLOYEE_CONDITION_TABLE = to_employee_table_md("사번", "이름", "직급", "입사일", "급여", "부서번호")

# 날짜 비교 예시 (DATE 리터럴, 2022년 이후 입사 3명)
HIRE_DATE_EXAMPLE = sql_example(
    "SELECT 이름, 입사일 FROM 사원 WHERE 입사일 >= DATE '2022-01-01';", ("이름", "입사일"),
    [["정하늘", "2022-03-14"], ["오지민", "2023-02-01"], ["윤서연", "2024-05-20"]], is_ordered=False)

CONCEPT = {
    "tagKey": "select-operators",
    "topicCode": "sql_basic_select",
    "sortOrder": 4,
    "title": "비교·논리 연산자와 우선순위",
    "summary": "조건을 비교로 만들고 AND·OR·NOT으로 묶되, AND가 OR보다 먼저예요",
    "coreMd": (
        "- 같지 않다는 `<>`, `!=`, `^=` 세 가지로 쓰고, `NOT 열 = 값`으로 써도 결과가 같아요.\n"
        "- 문자와 날짜 값은 작은따옴표로 감싸고, 큰따옴표는 값이 아니라 이름을 감싸요.\n"
        "- 괄호가 없으면 비교, NOT, AND, OR 순서로 계산해서 `A OR B AND C`는 `A OR (B AND C)`예요.\n"
        "- NOT은 바로 뒤의 조건 하나에만 걸려서, 여러 조건을 뒤집으려면 괄호로 묶어요."
    ),
    "detailMd": f"""## 왜 필요할까요 — 조건 여러 개를 정확히 묶으려고 {{#why}}

WHERE 절은 조건에 맞는 행만 남기는데, 실제로는 "20번이나 30번 부서이면서 급여가 2700 이상"처럼 조건 여러 개를 묶을 때가 많아요. 괄호를 빼먹으면 어떤 순서로 계산되는지 알아야 원하는 행을 정확히 골라요.

{EMPLOYEE_CONDITION_TABLE}

## 비교 연산자 — 같지 않다는 세 가지로 써요 {{#comparison}}

**비교 연산자**는 두 값을 비교해 조건이 참인지 거짓인지 알려 주는 기호이고, WHERE 절은 참인 행만 남겨요.

| 연산자 | 뜻 | 예 |
|---|---|---|
| `=` | 같다 | `부서번호 = 20` |
| `>`, `>=` | 크다, 크거나 같다 | `급여 >= 2700` |
| `<`, `<=` | 작다, 작거나 같다 | `급여 < 2500` |
| `<>` | 같지 않다 (SQL 표준) | `부서번호 <> 20` |
| `!=`, `^=` | 같지 않다 (Oracle도 받아들여요) | `부서번호 ^= 20` |

비교 앞에 NOT을 붙여도 같은 뜻이라, 아래 네 문장은 모두 20번 부서가 아닌 김민수, 최유나, 한도윤, 오지민을 돌려줘요. 부서가 없는 윤서연이 빠지는 이유는 "WHERE 절과 NULL" 개념에서 다뤄요.

```sql
SELECT 이름 FROM 사원 WHERE 부서번호 <> 20;
SELECT 이름 FROM 사원 WHERE 부서번호 != 20;
SELECT 이름 FROM 사원 WHERE 부서번호 ^= 20;
SELECT 이름 FROM 사원 WHERE NOT 부서번호 = 20;
```

## 값의 따옴표 — 문자와 날짜는 작은따옴표 {{#literal}}

숫자는 `급여 >= 2700`처럼 그대로 쓰지만, 문자 값은 `'김민수'`처럼 작은따옴표로 감싸요. 따옴표가 없거나 큰따옴표를 쓰면 Oracle은 김민수를 열 이름으로 읽고, 그런 열이 없어서 오류를 내요.

```sql
SELECT 이름 FROM 사원 WHERE 이름 = '김민수';   -- 김민수 한 명이 나와요
SELECT 이름 FROM 사원 WHERE 이름 = 김민수;     -- 오류: 김민수라는 열을 찾아요 (ORA-00904, 없는 열 이름)
SELECT 이름 FROM 사원 WHERE 이름 = "김민수";   -- 오류: 큰따옴표도 이름으로 읽어요 (ORA-00904, 없는 열 이름)
```

| 쓰는 법 | 뜻 |
|---|---|
| `'2022-01-01'` | 글자예요. 날짜로 바꿀 때 데이터베이스의 날짜 형식 설정을 따라서, 설정에 따라 오류가 날 수 있어요 |
| `DATE '2022-01-01'` | 연-월-일 형식의 날짜라고 밝힌 값이라 어느 환경에서나 같은 뜻이에요 |

{HIRE_DATE_EXAMPLE.markdown}

날짜를 바꾸는 함수는 4단원 SQL 함수에서 다뤄요.

## 논리 연산자 — AND, OR, NOT {{#logical}}

| 연산자 | 결과가 참이 되는 경우 | 예 |
|---|---|---|
| AND | 양쪽 조건이 모두 참일 때 | `부서번호 = 20 AND 급여 >= 2700` → 박서준 |
| OR | 양쪽 중 하나라도 참일 때 | `직급 = '부장' OR 급여 >= 3000` → 김민수, 최유나 |
| NOT | 뒤의 조건이 거짓일 때 | `NOT 직급 = '사원'` → '사원' 직급이 아닌 5명 |

## 계산 순서 — 괄호, 비교, NOT, AND, OR {{#precedence}}

| 단계 | 내용 |
|---|---|
| 1 괄호 | `( )` 안을 가장 먼저 계산해요 |
| 2 비교 연산자 | `=`, `<>`, `>`, `>=`, `<`, `<=`예요. 다음 개념의 LIKE·BETWEEN·IN과 IS NULL도 같은 순위예요 |
| 3 NOT | 바로 뒤의 조건 하나를 뒤집어요 |
| 4 AND | 양쪽이 모두 참인지 봐요 |
| 5 OR | 한쪽이라도 참인지 봐요 |

| 외우기 | 뜻 |
|---|---|
| N | NOT: 논리 연산자 중 가장 먼저 |
| A | AND: 그다음 |
| O | OR: 가장 나중 |

곱셈을 덧셈보다 먼저 하듯이 AND를 OR보다 먼저 계산해요. 그래서 아래 두 문장은 괄호 하나 때문에 결과가 달라요.

```sql
SELECT 이름 FROM 사원 WHERE 부서번호 = 20 OR 부서번호 = 30 AND 급여 >= 2700;     -- 20번 전부, 또는 30번 중 2700 이상이에요
SELECT 이름 FROM 사원 WHERE (부서번호 = 20 OR 부서번호 = 30) AND 급여 >= 2700;   -- 20번이나 30번 중 2700 이상이에요
```

| SQL | 결과 |
|---|---|
| 괄호 없음 | 이지은, 박서준, 정하늘, 최유나, 한도윤 (5명) |
| 괄호 있음 | 박서준, 최유나, 한도윤 (3명) |

## 자주 헷갈리는 점 — AND부터 괄호로 묶어 보기 {{#confusing}}

`A OR B AND C`를 왼쪽부터 읽으면 틀려요. AND 쪽을 먼저 괄호로 묶어 `A OR (B AND C)`로 다시 쓰면 "'대리' 직급 전부, 또는 30번 부서의 '사원' 직급"이라는 뜻이 보여요.

```sql
SELECT 이름 FROM 사원 WHERE 직급 = '대리' OR 직급 = '사원' AND 부서번호 = 30;     -- AND를 먼저 계산해요
SELECT 이름 FROM 사원 WHERE (직급 = '대리' OR 직급 = '사원') AND 부서번호 = 30;   -- 괄호 안의 OR을 먼저 계산해요
SELECT 이름 FROM 사원 WHERE NOT 직급 = '사원' AND 급여 >= 2700;                  -- NOT은 직급 조건에만 걸려요
SELECT 이름 FROM 사원 WHERE NOT (직급 = '사원' AND 급여 >= 2700);                -- NOT이 괄호 전체에 걸려요
```

| SQL | 결과 |
|---|---|
| 대리 OR 사원 AND 30번 (괄호 없음) | 박서준, 한도윤, 오지민 (3명) |
| (대리 OR 사원) AND 30번 | 한도윤, 오지민 (2명) |
| NOT 사원 AND 급여 2700 이상 (괄호 없음) | 김민수, 박서준, 최유나, 한도윤 (4명) |
| NOT (사원 AND 급여 2700 이상) | 8명 전부. '사원' 직급 중 2700 이상인 사람이 없어요 |

| 헷갈리는 말 | 실제로는 |
|---|---|
| 조건은 쓴 순서대로 왼쪽부터 계산해요 | 괄호가 없으면 NOT, AND, OR 순서예요. AND가 OR보다 먼저예요 |
| NOT은 뒤에 이어진 조건 전체를 뒤집어요 | NOT은 AND보다 먼저라 바로 뒤 조건 하나만 뒤집어요. 전체를 뒤집으려면 괄호로 묶어요 |
| `부서번호 NOT = 20`도 같지 않다는 뜻이에요 | NOT은 조건 앞이나 NOT IN, NOT BETWEEN, NOT LIKE, IS NOT NULL 모양으로만 써요. 열과 `=` 사이에 넣으면 오류예요 |
| NOT이 비교보다 먼저라서 `NOT 부서번호 = 20`의 결과가 달라져요 | 수험서마다 표의 순서가 다르지만 NOT 뒤에는 조건이 통째로 와서 결과는 늘 `NOT (부서번호 = 20)`이에요 |
| 큰따옴표로 감싸도 문자 값이 돼요 | 큰따옴표는 이름을 감싸는 기호예요. 값은 작은따옴표로 감싸요 |

```sql
SELECT 이름 FROM 사원 WHERE 부서번호 NOT = 20;   -- 오류: NOT은 열과 = 사이에 올 수 없어요
```

끝에 붙은 공백까지 같은 글자로 볼지는 길이가 고정된 CHAR와 길이가 바뀌는 VARCHAR2에 따라 달라요. 이 규칙은 3단원 데이터 타입 개념에서 다뤄요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `^=`는 Oracle에서 같지 않다는 뜻으로 쓸 수 있어요 | O | `<>`, `!=`, `^=` 모두 같지 않다는 뜻이에요 |
| `A AND B OR C`는 `A AND (B OR C)`와 같아요 | X | AND가 먼저라서 `(A AND B) OR C`예요 |
| `DATE '2022-01-01'`은 날짜 형식 설정과 상관없이 같은 날짜예요 | O | DATE를 붙이면 연-월-일 형식의 날짜라고 밝힌 값이 돼요 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

괄호 없이 AND와 OR을 섞은 WHERE 절을 주고 결과 행 수를 묻는 문제가 가장 많고, AND로 이어진 조건을 먼저 괄호로 묶어 보면 실수가 줄어요. 같지 않다는 연산자가 아닌 것을 고르거나, 문자 값에 따옴표를 빠뜨리거나 큰따옴표를 쓴 SQL을 고르는 문제도 나와요.""",
    "checkQuestions": [
        question(1, "부서번호가 20이 아닌 사원을 찾는 조건 중 Oracle에서 오류가 나는 것은 무엇인가요?", "confusing",
                 "NOT은 조건 앞에 붙이거나 NOT IN 같은 정해진 모양으로만 써요. 열과 = 사이에 NOT을 끼워 넣으면 잘못된 비교 연산자라는 오류(ORA-00920)가 나요.",
                 [choice("A", "WHERE 부서번호 <> 20", rationale="SQL 표준의 같지 않다 연산자예요."),
                  choice("B", "WHERE 부서번호 ^= 20", rationale="Oracle이 같지 않다는 뜻으로 받아들이는 기호예요."),
                  choice("C", "WHERE NOT 부서번호 = 20", rationale="같다는 조건을 NOT으로 뒤집은 올바른 문장이에요."),
                  choice("D", "WHERE 부서번호 NOT = 20", True, "NOT의 자리가 잘못되어 오류가 나요.")]),
        question(2, "괄호가 없는 WHERE 절에서 논리 연산자가 계산되는 순서로 알맞은 것은 무엇인가요?", "precedence",
                 "논리 연산자는 NOT, AND, OR 순서로 계산돼요. 그래서 AND와 OR이 섞이면 AND로 이어진 쪽이 먼저 묶여요.",
                 [choice("A", "NOT → AND → OR", True, "NOT이 가장 먼저이고 OR이 가장 나중이에요."),
                  choice("B", "AND → OR → NOT", rationale="NOT은 AND보다 먼저 계산돼요."),
                  choice("C", "OR → AND → NOT", rationale="OR은 가장 나중에 계산돼요."),
                  choice("D", "쓴 순서대로 왼쪽부터", rationale="논리 연산자에는 정해진 우선순위가 있어요.")]),
        question(3, "문자 값 '김민수'와 같은 이름을 찾는 조건으로 올바른 것은 무엇인가요?", "literal",
                 "문자 값은 작은따옴표로 감싸야 해요. 따옴표가 없거나 큰따옴표로 감싸면 Oracle은 값이 아니라 열 이름으로 읽어서 오류를 내요.",
                 [choice("A", "WHERE 이름 = \"김민수\"", rationale="큰따옴표는 이름을 감싸는 기호라서 김민수라는 열을 찾다가 오류가 나요."),
                  choice("B", "WHERE 이름 = 김민수", rationale="따옴표가 없으면 열 이름으로 읽어서 오류가 나요."),
                  choice("C", "WHERE 이름 = '김민수'", True, "문자 값을 작은따옴표로 감싼 올바른 조건이에요."),
                  choice("D", "WHERE 이름 == '김민수'", rationale="SQL에서 같다는 기호는 = 하나뿐이라서 오류가 나요.")]),
        question(4, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_CONDITION_TABLE, "confusing",
                 "AND를 먼저 계산하므로 '대리' 직급 전부, 또는 30번 부서의 '사원' 직급이 돼요. 대리 박서준, 한도윤과 30번 부서의 사원 직급 오지민을 합쳐 3행이에요.",
                 [choice("A", "2행", rationale="앞의 두 조건을 괄호로 묶었을 때의 결과예요."),
                  choice("B", "3행", True, "대리 직급 2명과 30번 부서의 사원 직급 1명이에요."),
                  choice("C", "5행", rationale="대리 직급과 사원 직급을 모두 센 결과이고, 사원 직급에는 30번 부서 조건이 붙어요."),
                  choice("D", "0행", rationale="OR로 이어진 대리 직급 조건만으로도 행이 나와요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE 직급 = '대리' OR 직급 = '사원' AND 부서번호 = 30;"),
        question(5, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_CONDITION_TABLE, "confusing",
                 "NOT은 바로 뒤의 직급 = '사원'만 뒤집어요. 사원 직급이 아니면서 급여가 2700 이상인 김민수, 박서준, 최유나, 한도윤 4행이 나와요.",
                 [choice("A", "8행", rationale="NOT이 두 조건 전체에 걸린다고 본 결과인데, 그러려면 괄호가 필요해요."),
                  choice("B", "0행", rationale="사원 직급이 아니면서 급여가 2700 이상인 사람이 4명 있어요."),
                  choice("C", "3행", rationale="한도윤의 급여는 2700이라서 >= 조건을 만족해요."),
                  choice("D", "4행", True, "NOT이 직급 조건에만 걸린 결과예요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE NOT 직급 = '사원' AND 급여 >= 2700;"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 <> 20", [["김민수"], ["최유나"], ["한도윤"], ["오지민"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 ^= 20", [["김민수"], ["최유나"], ["한도윤"], ["오지민"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE NOT 부서번호 = 20", [["김민수"], ["최유나"], ["한도윤"], ["오지민"]]),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 부서번호 NOT = 20", "ORA-00920"),
        sql_check("SELECT 이름 FROM 사원 WHERE 이름 = '김민수'", [["김민수"]]),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 이름 = 김민수", "ORA-00904"),
        sql_error_check('SELECT 이름 FROM 사원 WHERE 이름 = "김민수"', "ORA-00904"),
        sql_error_check("SELECT 이름 FROM 사원 WHERE 이름 == '김민수'", "ORA-00936"),
        sql_check("SELECT 이름 FROM 사원 WHERE 입사일 >= DATE '2022-01-01'", [["정하늘"], ["오지민"], ["윤서연"]]),
        HIRE_DATE_EXAMPLE.check,
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 = 20 AND 급여 >= 2700", [["박서준"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 직급 = '부장' OR 급여 >= 3000", [["김민수"], ["최유나"]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE NOT 직급 = '사원'", [[5]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 = 20 OR 부서번호 = 30 AND 급여 >= 2700",
                  [["이지은"], ["박서준"], ["최유나"], ["정하늘"], ["한도윤"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE (부서번호 = 20 OR 부서번호 = 30) AND 급여 >= 2700",
                  [["박서준"], ["최유나"], ["한도윤"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 직급 = '대리' OR 직급 = '사원' AND 부서번호 = 30;",
                  [["박서준"], ["한도윤"], ["오지민"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE (직급 = '대리' OR 직급 = '사원') AND 부서번호 = 30", [["한도윤"], ["오지민"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE NOT 직급 = '사원' AND 급여 >= 2700;",
                  [["김민수"], ["박서준"], ["최유나"], ["한도윤"]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE NOT (직급 = '사원' AND 급여 >= 2700)", [[8]]),
    ],
}
