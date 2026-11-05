"""개념: LIKE·BETWEEN·IN (2단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import to_employee_table_md

EMPLOYEE_RANGE_TABLE = to_employee_table_md("사번", "이름", "직급", "입사일", "급여", "부서번호")
EMPLOYEE_NAME_TABLE = to_employee_table_md("사번", "이름")
EMPLOYEE_DEPARTMENT_TABLE = to_employee_table_md("사번", "이름", "부서번호")

# ESCAPE 예시용 표 (% · _ 가 값 안에 든 할인 코드 4개)
DISCOUNT_CODE_SETUP = (
    "CREATE TABLE 할인코드 (코드 VARCHAR2(10));\n"
    "INSERT INTO 할인코드 VALUES ('10%');\n"
    "INSERT INTO 할인코드 VALUES ('100');\n"
    "INSERT INTO 할인코드 VALUES ('A_1');\n"
    "INSERT INTO 할인코드 VALUES ('AB1');"
)
# 대괄호 패턴 예시용 표 (SQL Server [KT] <-> Oracle REGEXP_LIKE 비교, 코드 4개)
PRODUCT_CODE_SETUP = (
    "CREATE TABLE 상품코드 (코드 VARCHAR2(10));\n"
    "INSERT INTO 상품코드 VALUES ('K100');\n"
    "INSERT INTO 상품코드 VALUES ('T200');\n"
    "INSERT INTO 상품코드 VALUES ('S300');\n"
    "INSERT INTO 상품코드 VALUES ('B400');"
)

CONCEPT = {
    "tagKey": "select-like-between-in",
    "topicCode": "sql_basic_select",
    "sortOrder": 5,
    "title": "LIKE·BETWEEN·IN",
    "summary": "글자 모양, 값의 범위, 값 목록으로 행을 고르는 세 조건이에요",
    "coreMd": (
        "- LIKE의 `%`는 0글자 이상, `_`는 정확히 한 글자이고, 이 글자 자체를 찾을 때는 ESCAPE로 표시 문자를 정해요.\n"
        "- `BETWEEN a AND b`는 양 끝을 포함하는 `>= a AND <= b`라서, a가 b보다 크면 오류 없이 0행이에요.\n"
        "- `IN`은 `=`를 OR로 이은 것이고, `NOT IN`은 `<>`를 AND로 이은 것이라 목록에 NULL이 있으면 0행이에요.\n"
        "- `(열1, 열2) IN ((값, 값), ...)`은 짝이 맞는 조합만 참이라, 열마다 따로 쓴 IN보다 결과가 좁아요.\n"
        "- SQL Server의 `'[KT]%'`는 K나 T로 시작하는 값이지만, Oracle LIKE에서는 대괄호가 보통 글자라 `REGEXP_LIKE(열, '^[KT]')`로 써요."
    ),
    "detailMd": f"""## 왜 필요할까요 — 모양, 범위, 목록으로 고르기 {{#why}}

"김씨 성", "급여 2500에서 2800 사이", "직급이 대리나 과장"은 `=`와 `>=`만으로 쓰면 길어지거나 아예 쓸 수 없어요. 그래서 WHERE 절에 쓰는 LIKE, BETWEEN, IN이 따로 있고, 셋 다 앞에 NOT을 붙여 반대 조건을 만들어요.

| 조건 | 고르는 기준 | 예 |
|---|---|---|
| LIKE | 글자 모양(패턴) | `이름 LIKE '김%'` |
| BETWEEN | 값의 범위 | `급여 BETWEEN 2500 AND 2800` |
| IN | 값의 목록 | `직급 IN ('대리', '과장')` |

{EMPLOYEE_RANGE_TABLE}

## LIKE — %는 0글자 이상, _는 딱 한 글자 {{#like}}

LIKE 패턴 안에서 특별한 뜻을 갖는 기호를 **와일드카드**라고 해요. 와일드카드가 하나도 없는 패턴은 `=`와 같은 뜻이에요.

| 용어 | 뜻 |
|---|---|
| `%` | 아무 글자나 0글자 이상이에요. `'%민%'`은 첫 글자가 민인 이름에도 맞아요 |
| `_` | 아무 글자나 정확히 한 글자예요. `'_민%'`은 두 번째 글자가 민인 이름이에요 |

```sql
SELECT 이름 FROM 사원 WHERE 이름 LIKE '%민%';      -- 어딘가에 민이 들어 있어요
SELECT 이름 FROM 사원 WHERE 이름 LIKE '_민%';      -- 두 번째 글자가 민이에요
SELECT 이름 FROM 사원 WHERE 이름 LIKE '%서';       -- 서로 끝나요
SELECT 이름 FROM 사원 WHERE 이름 NOT LIKE '%민%';  -- 민이 들어 있지 않아요
```

| 조건 | 결과 |
|---|---|
| `LIKE '김%'` | 김민수 |
| `LIKE '%민%'` | 김민수, 오지민 |
| `LIKE '_민%'` | 김민수 (오지민은 민이 세 번째 글자예요) |
| `LIKE '%서'` | 0행 (서로 끝나는 이름이 없어요) |
| `LIKE '_서_'` | 박서준, 윤서연 |
| `NOT LIKE '%민%'` | 이지은, 박서준, 최유나, 정하늘, 한도윤, 윤서연 |

## ESCAPE — %와 _ 글자 자체를 찾기 {{#escape}}

값 안에 `%`나 `_`가 실제 글자로 들어 있으면, 패턴의 `_`가 와일드카드로 읽혀서 밑줄이 없는 AB1까지 맞아요. ESCAPE로 표시 문자 하나를 정하면 그 바로 뒤의 `%`나 `_`는 보통 글자가 되고, 표시 문자는 `\\`나 `#`처럼 값에 잘 나오지 않는 글자로 골라요.

```sql
CREATE TABLE 할인코드 (코드 VARCHAR2(10));
INSERT INTO 할인코드 VALUES ('10%');
INSERT INTO 할인코드 VALUES ('100');
INSERT INTO 할인코드 VALUES ('A_1');
INSERT INTO 할인코드 VALUES ('AB1');
SELECT 코드 FROM 할인코드 WHERE 코드 LIKE 'A_%';               -- _가 와일드카드라서 AB1도 맞아요
SELECT 코드 FROM 할인코드 WHERE 코드 LIKE 'A\\_%' ESCAPE '\\';   -- \\ 뒤의 _는 보통 글자예요
SELECT 코드 FROM 할인코드 WHERE 코드 LIKE '%#%%' ESCAPE '#';    -- # 뒤의 %는 보통 글자예요
```

| 패턴 | 결과 |
|---|---|
| `'A_%'` | A_1, AB1 |
| `'A\\_%' ESCAPE '\\'` | A_1 (A_로 시작하는 값) |
| `'%#%%' ESCAPE '#'` | 10% (어딘가에 % 글자가 있는 값) |

패턴은 앞에서부터 조각으로 끊어 읽으면 헷갈리지 않아요.

| 단계 | 내용 |
|---|---|
| 앞의 `%` | 아무 글자나 0글자 이상이에요 |
| `#%` | 표시 문자 # 바로 뒤라서 보통 글자 % 하나예요 |
| 뒤의 `%` | 아무 글자나 0글자 이상이에요 |

## SQL Server의 대괄호 — Oracle에서는 REGEXP_LIKE로 {{#bracket}}

SQL Server는 LIKE에서 대괄호(`[ ]`)도 와일드카드로 써요. 대괄호 하나가 글자 한 자리를 차지하고, 그 자리에 안에 적은 글자 중 하나가 와야 맞아요.

| SQL Server 패턴 | 뜻 | 상품코드 표 결과 |
|---|---|---|
| `'[KT]%'` | K나 T로 시작해요 | K100, T200 |
| `'[^KT]%'` | K도 T도 아닌 글자로 시작해요 (안쪽 맨 앞 `^`는 아님) | S300, B400 |
| `'[A-C]%'` | A부터 C까지 중 한 글자로 시작해요 (하이픈은 범위) | B400 |

```sql
-- 문법: SQL Server에서만 대괄호가 와일드카드예요
SELECT 코드 FROM 상품코드 WHERE 코드 LIKE '[KT]%';    -- K나 T로 시작해요
SELECT 코드 FROM 상품코드 WHERE 코드 LIKE '[^KT]%';   -- K도 T도 아닌 글자로 시작해요
SELECT 코드 FROM 상품코드 WHERE 코드 LIKE '[A-C]%';   -- A, B, C 중 한 글자로 시작해요
```

Oracle LIKE에서 특별한 기호는 `%`와 `_` 두 개뿐이라, `LIKE '[KT]%'`는 "[KT]라는 네 글자로 시작하는 값"을 찾고 오류 없이 0행이 나와요. 같은 뜻은 정규 표현식(글자 모양을 기호로 적는 규칙, 9단원)으로 고르는 REGEXP_LIKE로 쓰고, 대괄호 밖 맨 앞의 `^`는 값의 맨 앞을 뜻해요.

```sql
CREATE TABLE 상품코드 (코드 VARCHAR2(10));
INSERT INTO 상품코드 VALUES ('K100');
INSERT INTO 상품코드 VALUES ('T200');
INSERT INTO 상품코드 VALUES ('S300');
INSERT INTO 상품코드 VALUES ('B400');
SELECT 코드 FROM 상품코드 WHERE 코드 LIKE '[KT]%';            -- Oracle에서는 0행이에요
SELECT 코드 FROM 상품코드 WHERE REGEXP_LIKE(코드, '^[KT]');    -- K나 T로 시작해요
SELECT 코드 FROM 상품코드 WHERE REGEXP_LIKE(코드, '^[^KT]');   -- K도 T도 아닌 글자로 시작해요
```

| 조건 (Oracle) | 결과 |
|---|---|
| `LIKE '[KT]%'` | 0행 |
| `REGEXP_LIKE(코드, '^[KT]')` | K100, T200 |
| `REGEXP_LIKE(코드, '^[^KT]')` | S300, B400 |

## BETWEEN — 양 끝을 포함하는 범위 {{#between}}

`BETWEEN a AND b`는 `>= a AND <= b`와 같아서 양 끝 값이 포함돼요. 숫자뿐 아니라 날짜와 문자에도 쓰고, `NOT BETWEEN a AND b`는 범위 바깥인 `< a OR > b`예요.

```sql
SELECT 이름 FROM 사원 WHERE 급여 BETWEEN 2500 AND 2800;       -- 2500과 2800도 포함해요
SELECT 이름 FROM 사원 WHERE 급여 NOT BETWEEN 2500 AND 2800;   -- 범위 바깥만 남아요
SELECT 이름 FROM 사원 WHERE 입사일 BETWEEN DATE '2019-01-01' AND DATE '2020-12-31';  -- 날짜에도 쓸 수 있어요
```

| 조건 | 결과 |
|---|---|
| `급여 BETWEEN 2500 AND 2800` | 이지은, 박서준, 정하늘, 한도윤 |
| `급여 NOT BETWEEN 2500 AND 2800` | 김민수, 최유나, 오지민, 윤서연 (경계 2500·2800은 빠져요) |
| `입사일 BETWEEN DATE '2019-01-01' AND DATE '2020-12-31'` | 박서준, 한도윤 |

## IN — 목록 중 하나와 같은 값 {{#in}}

`직급 IN ('대리', '과장')`은 `직급 = '대리' OR 직급 = '과장'`을 짧게 쓴 것이에요. `NOT IN (10, 20)`은 `<> 10 AND <> 20`이에요.

```sql
SELECT 이름 FROM 사원 WHERE 직급 IN ('대리', '과장');   -- 직급이 대리나 과장이에요
SELECT 이름 FROM 사원 WHERE 부서번호 NOT IN (10, 20);   -- 10번도 20번도 아닌 부서예요
```

| 조건 | 결과 |
|---|---|
| `직급 IN ('대리', '과장')` | 이지은, 박서준, 한도윤 |
| `부서번호 NOT IN (10, 20)` | 최유나, 한도윤, 오지민 (부서 없는 윤서연은 빠져요) |

## 자주 헷갈리는 점 — 경계, NULL, 짝 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| `BETWEEN 2800 AND 2500`도 2500~2800 사이를 찾아요 | `>= 2800 AND <= 2500`이 되어 오류 없이 0행이에요. 작은 값을 앞에 써요 |
| `BETWEEN 2700 AND 3000`은 `> 2700 AND < 3000`과 같아요 | BETWEEN은 양 끝을 포함해서 김민수, 박서준, 한도윤 3명이고, 부등호 두 개는 박서준 1명이에요 |
| 부서번호가 NULL인 윤서연은 `NOT IN (10, 20)`에 나와요 | NULL과 비교하면 참도 거짓도 아닌 UNKNOWN이라 빠져요 |
| `IN` 목록의 NULL처럼 `NOT IN` 목록의 NULL도 무시돼요 | `NOT IN (10, NULL)`은 `<> NULL`이 늘 UNKNOWN이라 0행이에요. `IN (10, 20, NULL)`은 OR이라 10번, 20번은 나와요 |
| `'_서_'`와 `'%서%'`는 같은 패턴이에요 | `'_서_'`는 정확히 세 글자, `'%서%'`는 길이와 상관없어요. 네 글자 이름이면 결과가 달라져요 |
| `LIKE '%'`는 모든 행에 맞아요 | LIKE도 비교라서 값이 NULL인 행은 걸리지 않아요. 커미션 `LIKE '%'`는 4명이에요 |
| ESCAPE를 빼도 #은 표시 문자로 읽혀요 | ESCAPE가 없으면 #은 보통 글자라서 `'%#%%'`는 # 글자가 든 값을 찾고, 오류 없이 0행이 나와요 |
| 표시 문자 뒤에는 아무 글자나 올 수 있어요 | %, _, 표시 문자 자신만 와요. `'%#a%' ESCAPE '#'`는 오류(ORA-01424, 표시 문자 뒤 글자가 잘못됨)예요 |

```sql
SELECT 이름 FROM 사원 WHERE 급여 BETWEEN 2800 AND 2500;   -- 0행이 나와요
SELECT 이름 FROM 사원 WHERE 부서번호 NOT IN (10, NULL);   -- 0행이 나와요
SELECT 이름 FROM 사원 WHERE 부서번호 IN (10, 20, NULL);   -- 10번과 20번 부서 사람이 나와요
```

여러 열을 괄호로 묶은 IN은 짝이 맞는 조합만 참이에요. 열마다 따로 쓴 IN은 20번의 '사원'(정하늘)과 30번의 '대리'(한도윤)까지 허용해요.

```sql
SELECT 이름 FROM 사원 WHERE (부서번호, 직급) IN ((20, '대리'), (30, '사원'));   -- 짝을 지은 조합만 맞아요
SELECT 이름 FROM 사원 WHERE 부서번호 IN (20, 30) AND 직급 IN ('대리', '사원');   -- 열마다 따로 비교해요
```

| 조건 | 결과 |
|---|---|
| 여러 열을 묶은 IN | 박서준, 오지민 |
| 열마다 따로 쓴 IN | 박서준, 정하늘, 한도윤, 오지민 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `'%A_'`는 끝에서 두 번째 글자가 A인 값을 찾아요 | O | 마지막 `_`가 한 글자 자리를 차지해서 A는 끝에서 두 번째예요 |
| ESCAPE에는 표시 문자를 두 글자까지 적을 수 있어요 | X | ESCAPE에는 한 글자만 적어요 |
| `NOT BETWEEN 2500 AND 2800`의 결과에는 급여 2500인 사원이 빠져요 | O | 경계 값은 범위 안이라서 NOT BETWEEN에서는 빠져요 |
| Oracle에서 `LIKE '[KT]%'`는 오류가 나요 | X | 대괄호를 보통 글자로 읽어서 오류 없이 0행이 나와요 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

이름 목록과 `'_A%'`, `'%A_'` 같은 패턴을 주고 맞는 행 수를 묻는 문제가 자주 나오고, `_`가 한 글자 자리를 정확히 차지한다는 점을 짚어 가며 세면 돼요. BETWEEN의 경계 포함과 a > b의 0행, NOT IN과 NULL, `%`를 찾는 ESCAPE 문장, SQL Server 기준 대괄호 패턴의 결과도 나와요.""",
    "checkQuestions": [
        question(1, "LIKE 패턴에서 `_`(밑줄)가 뜻하는 것은 무엇인가요?", "like",
                 "`_`는 아무 글자나 정확히 한 글자 자리를 뜻해요. 0글자 이상을 뜻하는 것은 `%`예요.",
                 [choice("A", "아무 글자나 0글자 이상", rationale="이것은 % 기호의 뜻이에요."),
                  choice("B", "아무 글자나 정확히 한 글자", True, "밑줄 하나가 글자 한 자리를 차지해요."),
                  choice("C", "공백 한 칸", rationale="공백만이 아니라 어떤 글자든 한 글자와 맞아요."),
                  choice("D", "밑줄 문자 그 자체", rationale="밑줄 자체를 찾으려면 ESCAPE가 필요해요.")]),
        question(2, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_NAME_TABLE, "like",
                 "`'_민%'`은 두 번째 글자가 민인 이름이라서 김민수 한 명만 맞아요. 오지민은 민이 세 번째 글자예요.",
                 [choice("A", "2행", rationale="오지민까지 셌는데, 오지민은 민이 세 번째 글자예요."),
                  choice("B", "0행", rationale="밑줄은 한 글자 자리라서 김민수가 맞아요."),
                  choice("C", "1행", True, "두 번째 글자가 민인 이름은 김민수뿐이에요."),
                  choice("D", "8행", rationale="패턴에 맞지 않는 이름은 빠져요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE 이름 LIKE '_민%';"),
        question(3, "아래 사원 표에 다음 SQL을 실행한 결과로 알맞은 것은 무엇인가요?\n\n" + EMPLOYEE_RANGE_TABLE, "confusing",
                 "BETWEEN 2800 AND 2500은 급여 >= 2800 AND 급여 <= 2500이 되는데, 이 둘을 동시에 만족하는 값은 없어요. 오류 없이 0행이 나와요.",
                 [choice("A", "0행이 나온다", True, "큰 값을 앞에 써서 범위가 비어 버려요."),
                  choice("B", "급여가 2500~2800인 4명이 나온다", rationale="BETWEEN은 앞뒤 값을 바꿔서 해석하지 않아요."),
                  choice("C", "오류가 난다", rationale="문법은 맞아서 오류 없이 실행돼요."),
                  choice("D", "경계 값인 이지은, 박서준, 정하늘만 나온다", rationale="범위 자체가 비어서 경계 값도 나오지 않아요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE 급여 BETWEEN 2800 AND 2500;"),
        question(4, "할인코드 열에서 `%` 글자가 들어 있는 값만 찾는 조건으로 알맞은 것은 무엇인가요?", "escape",
                 "ESCAPE로 정한 표시 문자 바로 뒤의 `%`는 보통 글자로 읽혀요. 그래서 '%#%%'는 앞뒤는 아무 글자, 가운데에 % 글자가 있는 값을 찾아요.",
                 [choice("A", "코드 LIKE '%%%'", rationale="% 세 개가 모두 와일드카드라서 모든 값이 맞아요."),
                  choice("B", "코드 LIKE '%_%'", rationale="한 글자 이상인 모든 값이 맞아요."),
                  choice("C", "코드 LIKE '%#%%'", rationale="ESCAPE가 없으면 #은 보통 글자라서 #이 든 값을 찾아요."),
                  choice("D", "코드 LIKE '%#%%' ESCAPE '#'", True, "# 뒤의 %가 보통 글자로 읽혀요.")]),
        question(5, "아래 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_DEPARTMENT_TABLE, "confusing",
                 "NOT IN (10, 20)은 <> 10 AND <> 20이라서 30번 부서 3명이 나와요. 부서번호가 NULL인 윤서연은 비교가 UNKNOWN이 되어 빠져요.",
                 [choice("A", "4행", rationale="윤서연까지 셌는데, NULL은 <> 비교에서 빠져요."),
                  choice("B", "3행", True, "30번 부서의 최유나, 한도윤, 오지민만 남아요."),
                  choice("C", "0행", rationale="0행이 되는 것은 목록 안에 NULL이 있을 때예요."),
                  choice("D", "오류가 난다", rationale="NULL이 있는 열에 NOT IN을 써도 오류는 나지 않아요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE 부서번호 NOT IN (10, 20);"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        sql_check("SELECT 이름 FROM 사원 WHERE 이름 LIKE '김%'", [["김민수"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 이름 LIKE '%민%'", [["김민수"], ["오지민"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 이름 LIKE '_민%';", [["김민수"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 이름 LIKE '_서_'", [["박서준"], ["윤서연"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 이름 LIKE '%서%'", [["박서준"], ["윤서연"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 이름 LIKE '%서'", []),
        sql_check("SELECT 이름 FROM 사원 WHERE 이름 NOT LIKE '%민%'",
                  [["이지은"], ["박서준"], ["최유나"], ["정하늘"], ["한도윤"], ["윤서연"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 커미션 LIKE '%'", [["이지은"], ["박서준"], ["한도윤"], ["오지민"]]),
        sql_check("SELECT 코드 FROM 할인코드 WHERE 코드 LIKE 'A_%'", [["A_1"], ["AB1"]], setup=DISCOUNT_CODE_SETUP),
        sql_check("SELECT 코드 FROM 할인코드 WHERE 코드 LIKE 'A\\_%' ESCAPE '\\'", [["A_1"]], setup=DISCOUNT_CODE_SETUP),
        # 4번 문제 보기
        sql_check("SELECT 코드 FROM 할인코드 WHERE 코드 LIKE '%%%'", [["10%"], ["100"], ["A_1"], ["AB1"]], setup=DISCOUNT_CODE_SETUP),
        sql_check("SELECT 코드 FROM 할인코드 WHERE 코드 LIKE '%_%'", [["10%"], ["100"], ["A_1"], ["AB1"]], setup=DISCOUNT_CODE_SETUP),
        sql_check("SELECT 코드 FROM 할인코드 WHERE 코드 LIKE '%#%%'", [], setup=DISCOUNT_CODE_SETUP),
        sql_check("SELECT 코드 FROM 할인코드 WHERE 코드 LIKE '%#%%' ESCAPE '#'", [["10%"]], setup=DISCOUNT_CODE_SETUP),
        sql_error_check("SELECT 코드 FROM 할인코드 WHERE 코드 LIKE '%#a%' ESCAPE '#'", "ORA-01424", setup=DISCOUNT_CODE_SETUP),
        # Oracle 대괄호는 보통 글자 > LIKE 0행, REGEXP_LIKE 로 같은 뜻
        sql_check("SELECT 코드 FROM 상품코드 WHERE 코드 LIKE '[KT]%'", [], setup=PRODUCT_CODE_SETUP),
        sql_check("SELECT 코드 FROM 상품코드 WHERE 코드 LIKE '[^KT]%'", [], setup=PRODUCT_CODE_SETUP),
        sql_check("SELECT 코드 FROM 상품코드 WHERE 코드 LIKE '[A-C]%'", [], setup=PRODUCT_CODE_SETUP),
        sql_check("SELECT 코드 FROM 상품코드 WHERE REGEXP_LIKE(코드, '^[KT]')", [["K100"], ["T200"]], setup=PRODUCT_CODE_SETUP),
        sql_check("SELECT 코드 FROM 상품코드 WHERE REGEXP_LIKE(코드, '^[^KT]')", [["S300"], ["B400"]], setup=PRODUCT_CODE_SETUP),
        sql_check("SELECT 코드 FROM 상품코드 WHERE REGEXP_LIKE(코드, '^[A-C]')", [["B400"]], setup=PRODUCT_CODE_SETUP),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 BETWEEN 2500 AND 2800", [["이지은"], ["박서준"], ["정하늘"], ["한도윤"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 NOT BETWEEN 2500 AND 2800", [["김민수"], ["최유나"], ["오지민"], ["윤서연"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 입사일 BETWEEN DATE '2019-01-01' AND DATE '2020-12-31'", [["박서준"], ["한도윤"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 BETWEEN 2800 AND 2500;", []),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 BETWEEN 2700 AND 3000", [["김민수"], ["박서준"], ["한도윤"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 > 2700 AND 급여 < 3000", [["박서준"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 직급 IN ('대리', '과장')", [["이지은"], ["박서준"], ["한도윤"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 NOT IN (10, 20);", [["최유나"], ["한도윤"], ["오지민"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 NOT IN (10, NULL)", []),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 IN (10, 20, NULL)", [["김민수"], ["이지은"], ["박서준"], ["정하늘"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE (부서번호, 직급) IN ((20, '대리'), (30, '사원'))", [["박서준"], ["오지민"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 IN (20, 30) AND 직급 IN ('대리', '사원')",
                  [["박서준"], ["정하늘"], ["한도윤"], ["오지민"]]),
    ],
}
