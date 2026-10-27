"""개념: LIKE·BETWEEN·IN (2단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import to_employee_table_md

EMPLOYEE_RANGE_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")
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
    "summary": "글자 모양, 값의 범위, 값 목록으로 행을 고르는 세 가지 조건이에요",
    "coreMd": (
        "- LIKE에서 `%`는 0글자 이상의 아무 글자, `_`는 정확히 한 글자를 뜻하고, `%`나 `_` 자체를 찾을 때는 ESCAPE로 표시 문자를 정해요.\n"
        "- `BETWEEN a AND b`는 a와 b를 모두 포함하는 `>= a AND <= b`와 같아서, 작은 값을 앞에 써야 하고 a가 b보다 크면 0행이 나와요.\n"
        "- `IN (값1, 값2)`는 `= 값1 OR = 값2`와 같고, `NOT IN`은 `<> 값1 AND <> 값2`라서 목록에 NULL이 있으면 0행이 나와요.\n"
        "- `(열1, 열2) IN ((값, 값), (값, 값))`처럼 여러 열을 짝지어 비교하면, 열마다 따로 IN을 쓴 것보다 결과가 좁아져요.\n"
        "- SQL Server LIKE의 `'[KT]%'`는 K나 T로 시작하는 값이지만, Oracle LIKE에서 대괄호는 보통 글자라서 같은 뜻은 `REGEXP_LIKE(열, '^[KT]')`로 써요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

`=`나 `>=` 같은 비교 연산자만으로도 대부분의 조건을 만들 수 있지만, "김씨 성을 가진 사람"이나 "급여가 2500에서 2800 사이인 사람", "직급이 대리나 과장인 사람"을 찾으려면 조건이 길어지거나 아예 쓸 수 없어요. SQL은 이런 조건을 짧게 쓰도록 LIKE, BETWEEN, IN을 따로 마련해 두었어요. 셋 다 WHERE 절에서 쓰고, 앞에 NOT을 붙여 반대 조건을 만들 수 있어요. 예시는 아래 사원 표를 기준으로 해요.

{EMPLOYEE_RANGE_TABLE}

## LIKE: 글자 모양으로 찾기 {{#like}}

LIKE는 값이 정해진 글자 모양(패턴)과 맞는지 비교해요. 패턴 안에서는 두 가지 특수 기호를 쓸 수 있는데, 이것을 **와일드카드**라고 불러요.

| 기호 | 뜻 | 패턴 예 | 맞는 이름 |
|---|---|---|---|
| `%` | 아무 글자나 0글자 이상 | `'김%'` | 김민수 |
| `%` | 아무 글자나 0글자 이상 | `'%민%'` | 김민수, 오지민 |
| `_` | 아무 글자나 정확히 한 글자 | `'_민%'` | 김민수 |
| `_` | 아무 글자나 정확히 한 글자 | `'_서_'` | 박서준, 윤서연 |

`'%민%'`은 "어딘가에 민이 들어 있는 이름"이라서 첫 글자가 민인 이름도 맞아요. `%`는 0글자도 포함하기 때문이에요. 반면 `'_민%'`은 "두 번째 글자가 민인 이름"이라서 오지민은 맞지 않아요. 와일드카드가 하나도 없는 패턴은 `=`와 같은 뜻이 돼요.

```sql
SELECT 이름 FROM 사원 WHERE 이름 LIKE '%민%';      -- 어딘가에 민이 들어 있어요
SELECT 이름 FROM 사원 WHERE 이름 LIKE '_민%';      -- 두 번째 글자가 민이에요
SELECT 이름 FROM 사원 WHERE 이름 LIKE '%서';       -- 서로 끝나요
SELECT 이름 FROM 사원 WHERE 이름 NOT LIKE '%민%';  -- 민이 들어 있지 않아요
```

| 조건 | 결과 |
|---|---|
| `LIKE '%민%'` | 김민수, 오지민 |
| `LIKE '_민%'` | 김민수 |
| `LIKE '%서'` | 0행 (서로 끝나는 이름이 없어요) |
| `NOT LIKE '%민%'` | 이지은, 박서준, 최유나, 정하늘, 한도윤, 윤서연 |

## ESCAPE: %와 _ 글자 자체를 찾기 {{#escape}}

할인 코드처럼 값 안에 `%`나 `_`가 실제 글자로 들어 있을 때는 문제가 생겨요. `'A_%'`라고 쓰면 `_`도 와일드카드로 읽혀서 "A로 시작하고 두 글자 이상인 값"을 찾게 되고, 밑줄이 없는 AB1까지 나와요. 이럴 때는 ESCAPE로 표시 문자 하나를 정하고, 그 문자 바로 뒤의 `%`나 `_`는 와일드카드가 아닌 보통 글자로 읽게 해요. 표시 문자는 `\\`나 `#`처럼 값에 잘 나오지 않는 글자를 골라요.

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
| `'A\\_%' ESCAPE '\\'` | A_1 |
| `'%#%%' ESCAPE '#'` | 10% |

패턴은 앞에서부터 조각으로 끊어 읽으면 헷갈리지 않아요. `'%#%%'`는 아래처럼 세 조각이에요.

| 조각 | 뜻 |
|---|---|
| 앞의 `%` | 아무 글자나 0글자 이상 |
| `#%` | 표시 문자 # 바로 뒤라서, 와일드카드가 아닌 보통 글자 % 하나 |
| 뒤의 `%` | 아무 글자나 0글자 이상 |

그래서 이 패턴은 "어딘가에 % 글자가 들어 있는 값"이 되고, 10%만 맞아요. 같은 방법으로 `'A\\_%'`는 A, 보통 글자 _, 아무 글자 0개 이상으로 끊겨서 "A_로 시작하는 값"이 돼요.

## SQL Server의 대괄호 패턴 {{#bracket}}

SQL Server는 LIKE에서 `%`와 `_` 말고도 대괄호(`[ ]`)를 와일드카드로 써요. 대괄호는 글자 한 자리를 차지하고, 그 자리에 대괄호 안에 적은 글자 중 하나가 와야 맞아요. 대괄호 안 맨 앞에 `^`를 쓰면 반대로 적은 글자가 아닌 글자 하나를 뜻하고, `A-C`처럼 하이픈을 쓰면 A부터 C까지의 범위를 뜻해요. 아래는 상품코드 표에 SQL Server로 실행했을 때의 결과예요.

```sql
-- 문법: SQL Server에서만 대괄호가 와일드카드예요
SELECT 코드 FROM 상품코드 WHERE 코드 LIKE '[KT]%';    -- K나 T로 시작해요
SELECT 코드 FROM 상품코드 WHERE 코드 LIKE '[^KT]%';   -- K도 T도 아닌 글자로 시작해요
SELECT 코드 FROM 상품코드 WHERE 코드 LIKE '[A-C]%';   -- A, B, C 중 한 글자로 시작해요
```

| 조건 (SQL Server) | 결과 |
|---|---|
| `LIKE '[KT]%'` | K100, T200 |
| `LIKE '[^KT]%'` | S300, B400 |
| `LIKE '[A-C]%'` | B400 |

Oracle의 LIKE에서 특별한 뜻이 있는 기호는 `%`와 `_` 두 개뿐이라서, 대괄호와 `^`는 보통 글자로 읽혀요. 그래서 Oracle에서 `LIKE '[KT]%'`는 "[KT]라는 네 글자로 시작하는 값"을 찾고, 그런 값이 없으니 오류 없이 0행이 나와요. Oracle에서 같은 뜻을 쓰려면 REGEXP_LIKE를 써요. REGEXP_LIKE는 정규 표현식(글자 모양을 기호로 적는 규칙)에 맞는 행을 고르는 조건이고, 패턴 맨 앞의 `^`는 "값의 맨 앞"을 뜻해요. 정규 표현식은 9단원에서 자세히 다뤄요.

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

`'^[^KT]'`에는 `^`가 두 번 나오는데, 대괄호 밖의 `^`는 값의 맨 앞을, 대괄호 안 맨 앞의 `^`는 "적은 글자가 아님"을 뜻해요.

## BETWEEN: 범위로 찾기 {{#between}}

`BETWEEN a AND b`는 a 이상 b 이하인 값을 찾아요. 양 끝 값이 모두 포함되므로 `급여 >= 2500 AND 급여 <= 2800`과 같은 조건이에요. 숫자뿐 아니라 날짜나 문자에도 쓸 수 있어요.

```sql
SELECT 이름 FROM 사원 WHERE 급여 BETWEEN 2500 AND 2800;       -- 2500과 2800도 포함해요
SELECT 이름 FROM 사원 WHERE 급여 NOT BETWEEN 2500 AND 2800;   -- 범위 바깥만 남아요
SELECT 이름 FROM 사원 WHERE 입사일 BETWEEN DATE '2019-01-01' AND DATE '2020-12-31';  -- 날짜에도 쓸 수 있어요
```

| 조건 | 결과 |
|---|---|
| `급여 BETWEEN 2500 AND 2800` | 이지은, 박서준, 정하늘, 한도윤 |
| `급여 NOT BETWEEN 2500 AND 2800` | 김민수, 최유나, 오지민, 윤서연 |
| `입사일 BETWEEN DATE '2019-01-01' AND DATE '2020-12-31'` | 박서준, 한도윤 |

`NOT BETWEEN a AND b`는 범위 바깥, 즉 `< a OR > b`를 뜻해요. 경계 값인 2500과 2800은 범위 안에 들어가므로 NOT BETWEEN 결과에서는 빠져요.

## IN: 목록 중 하나와 같은 값 찾기 {{#in}}

`IN (값1, 값2, ...)`은 목록에 적은 값 중 하나와 같으면 참이에요. `직급 IN ('대리', '과장')`은 `직급 = '대리' OR 직급 = '과장'`을 짧게 쓴 것이라서, 목록이 길어질수록 OR을 여러 번 쓰는 것보다 읽기 쉬워요.

```sql
SELECT 이름 FROM 사원 WHERE 직급 IN ('대리', '과장');   -- 직급이 대리나 과장이에요
SELECT 이름 FROM 사원 WHERE 부서번호 NOT IN (10, 20);   -- 10번도 20번도 아닌 부서예요
```

| 조건 | 결과 |
|---|---|
| `직급 IN ('대리', '과장')` | 이지은, 박서준, 한도윤 |
| `부서번호 NOT IN (10, 20)` | 최유나, 한도윤, 오지민 |

## 자주 헷갈리는 점 {{#confusing}}

**BETWEEN은 작은 값을 앞에 써야 해요.** `급여 BETWEEN 2800 AND 2500`은 오류가 나지 않고 0행이 나와요. 이 조건은 `급여 >= 2800 AND 급여 <= 2500`으로 바뀌는데, 2800 이상이면서 동시에 2500 이하인 값은 없기 때문이에요. 시험에서는 이 SQL을 보여 주고 결과가 "2500~2800 사이 4명"인지 "0행"인지를 물어요.

```sql
SELECT 이름 FROM 사원 WHERE 급여 BETWEEN 2800 AND 2500;   -- 0행이 나와요
```

**BETWEEN의 양 끝은 포함되고, 부등호 두 개와는 다를 수 있어요.** `급여 BETWEEN 2700 AND 3000`은 2700인 한도윤과 3000인 김민수까지 포함해 3명이에요. 같은 범위를 `급여 > 2700 AND 급여 < 3000`으로 쓰면 양 끝이 빠져서 박서준 1명만 남아요.

**NOT IN은 NULL을 만나면 행이 빠지거나 0행이 돼요.** `NOT IN (10, 20)`은 `<> 10 AND <> 20`과 같아요. 부서번호가 NULL(값이 비어 있다는 표시)인 윤서연은 NULL과 비교한 결과가 참도 거짓도 아닌 UNKNOWN이 되어서, 10번도 20번도 아닌데 결과에 나오지 않아요. 목록 안에 NULL이 들어가면 `<> NULL`이 항상 UNKNOWN이라서 어떤 행도 남지 않아요. 반대로 `IN (10, 20, NULL)`은 OR로 이어지므로 10번과 20번 부서 사람은 정상으로 나와요. 자세한 이유는 WHERE 절과 NULL 개념에서 다뤄요.

```sql
SELECT 이름 FROM 사원 WHERE 부서번호 NOT IN (10, NULL);   -- 0행이 나와요
SELECT 이름 FROM 사원 WHERE 부서번호 IN (10, 20, NULL);   -- 10번과 20번 부서 사람이 나와요
```

| 조건 | 결과 |
|---|---|
| `부서번호 NOT IN (10, NULL)` | 0행 |
| `부서번호 IN (10, 20, NULL)` | 김민수, 이지은, 박서준, 정하늘 |

**여러 열을 묶은 IN은 짝이 맞아야 참이에요.** `(부서번호, 직급) IN ((20, '대리'), (30, '사원'))`은 "20번 부서의 '대리' 직급" 또는 "30번 부서의 '사원' 직급"만 찾아서 박서준과 오지민 2명이 나와요. 열마다 IN을 따로 쓴 `부서번호 IN (20, 30) AND 직급 IN ('대리', '사원')`은 20번 부서의 '사원' 직급(정하늘)과 30번 부서의 '대리' 직급(한도윤)까지 허용해서 4명이 나와요. 묶어서 쓰면 짝을 지은 조합만 맞는다는 점이 차이예요.

```sql
SELECT 이름 FROM 사원 WHERE (부서번호, 직급) IN ((20, '대리'), (30, '사원'));   -- 짝을 지은 조합만 맞아요
SELECT 이름 FROM 사원 WHERE 부서번호 IN (20, 30) AND 직급 IN ('대리', '사원');   -- 열마다 따로 비교해요
```

| 조건 | 결과 |
|---|---|
| 여러 열을 묶은 IN | 박서준, 오지민 |
| 열마다 따로 쓴 IN | 박서준, 정하늘, 한도윤, 오지민 |

**%와 _가 차지하는 글자 수는 달라요.** `'_서_'`은 정확히 세 글자이면서 가운데가 서인 이름이고, `'%서%'`은 길이와 상관없이 서가 들어 있는 이름이에요. 이 표에서는 둘 다 박서준, 윤서연으로 결과가 같지만, 네 글자 이름이 있다면 `'_서_'`에는 맞지 않아요. 또 LIKE도 비교라서 값이 NULL인 행은 `LIKE '%'`처럼 모든 글자에 맞는 패턴에도 걸리지 않아요.

**ESCAPE를 빼면 표시 문자는 보통 글자가 돼요.** `'%#%%'`에서 `ESCAPE '#'`를 빼면 조각이 `%`, `#`, `%`, `%` 네 개로 바뀌어서 "# 글자가 들어 있는 값"을 찾게 돼요. 할인코드 표에는 #이 든 값이 없어서 오류 없이 0행이 나오니, % 글자를 찾으려던 실수를 알아채기 어려워요. 표시 문자는 패턴 뒤에 ESCAPE로 알려 줘야만 효과가 있어요.

**표시 문자는 바로 뒤의 한 글자에만 걸려요.** ESCAPE에는 한 글자만 적을 수 있고, 표시 문자 바로 뒤에는 %, _, 또는 표시 문자 자신만 올 수 있어요. `'%#a%' ESCAPE '#'`처럼 다른 글자가 오면 표시 문자 뒤의 글자가 잘못됐다는 오류(ORA-01424)가 나요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

이름 목록을 주고 `'_A%'`나 `'%A_'` 같은 LIKE 패턴에 맞는 행 수를 묻는 문제가 자주 나와요. `_`는 한 글자 자리를 정확히 차지한다는 점을 손가락으로 짚어 가며 세면 실수가 줄어요. BETWEEN은 경계 값 포함 여부와 a > b일 때 0행이 되는 점을, IN은 NOT IN과 NULL이 만났을 때의 결과를 주로 물어요. `%`가 들어간 값을 찾는 올바른 ESCAPE 문장을 고르는 문제도 가끔 나와요. SQL Server 기준이라고 밝히고 `'[KT]%'` 같은 대괄호 패턴의 결과를 묻는 문제도 나왔는데, 이때는 대괄호 하나가 글자 한 자리라는 점과 Oracle에서는 같은 뜻이 아니라는 점을 함께 떠올리면 돼요.""",
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
