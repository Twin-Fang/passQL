"""개념: 정규 표현식 (9단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md, to_markdown_table

EMPLOYEE_NAME_TABLE = to_employee_table_md("사번", "이름", "직급")

# 메타 문자 표 원본: (기호, 뜻, 패턴, REGEXP_LIKE 참인 문자열, 거짓인 문자열) > 본문 표 + 검증 항목
METACHARACTER_EXAMPLES = (
    (".", "아무 글자 하나 (줄바꿈 제외)", "a.c", ("abc", "a1c"), ("ac",)),
    ("*", "바로 앞 글자가 0번 이상", "ab*c", ("ac", "abbc"), ("adc",)),
    ("+", "바로 앞 글자가 1번 이상", "ab+c", ("abc", "abbc"), ("ac",)),
    ("?", "바로 앞 글자가 0번 또는 1번", "colou?r", ("color", "colour"), ("colouur",)),
    ("^", "문자열의 시작", "^ab", ("abc",), ("cab",)),
    ("$", "문자열의 끝", "ab$", ("cab",), ("abc",)),
    ("[ ]", "괄호 안 글자 중 하나", "a[0-9]c", ("a1c", "a9c"), ("abc",)),
    ("[^ ]", "괄호 안 글자가 아닌 글자 하나", "a[^0-9]c", ("abc",), ("a1c",)),
    ("{n}", "바로 앞 글자가 정확히 n번", "[0-9]{3}", ("123",), ("12",)),
    ("{n,}", "바로 앞 글자가 n번 이상", "[0-9]{2,}", ("12", "12345"), ("1",)),
    ("{n,m}", "바로 앞 글자가 n번 이상 m번 이하", "x[0-9]{2,3}x", ("x12x", "x123x"), ("x1x", "x1234x")),
)

# 짧은 표기 원본: (표기, 뜻) > REGEXP_COUNT('a1 b_2', 표기) 결과와 함께 표로
CLASS_SAMPLE_TEXT = "a1 b_2"
CHARACTER_CLASS_EXAMPLES = (
    ("\\d", "숫자 하나, [0-9]와 같아요", 2),
    ("\\w", "글자·숫자·밑줄(_) 하나", 5),
    ("\\s", "공백 하나 (스페이스, 탭, 줄바꿈)", 1),
    ("[[:digit:]]", "POSIX 표기의 숫자 하나", 2),
    ("[[:alpha:]]", "POSIX 표기의 글자 하나", 2),
    ("[[:space:]]", "POSIX 표기의 공백 하나", 1),
)

# 함수 결과 표 원본: (식, 결과) > 본문 표 + SELECT 식 FROM DUAL 검증
FUNCTION_SAMPLE_TEXT = "a1b22c333"
FUNCTION_EXAMPLES = (
    ("REGEXP_SUBSTR('a1b22c333', '[0-9]+')", "1"),
    ("REGEXP_SUBSTR('a1b22c333', '[0-9]+', 1, 2)", "22"),
    ("REGEXP_SUBSTR('a1b22c333', '[0-9]+', 4)", "22"),
    ("REGEXP_INSTR('a1b22c333', '[0-9]+', 1, 3)", 7),
    ("REGEXP_INSTR('a1b22c333', '[0-9]+', 1, 2, 1)", 6),
    ("REGEXP_COUNT('a1b22c333', '[0-9]')", 6),
    ("REGEXP_COUNT('a1b22c333', '[0-9]+')", 3),
    ("REGEXP_REPLACE('a1b22c333', '[0-9]+', '#')", "a#b#c#"),
    ("REGEXP_REPLACE('a1b22c333', '[0-9]+', '#', 1, 2)", "a1b#c333"),
)

# 일치 옵션 표 원본: (옵션, 뜻, 식, 결과)
MATCH_OPTION_EXAMPLES = (
    ("'i'", "대소문자를 구분하지 않아요", "REGEXP_COUNT('ABC abc', 'abc', 1, 'i')", 2),
    ("'c'", "대소문자를 구분해요 (기본)", "REGEXP_COUNT('ABC abc', 'abc', 1, 'c')", 1),
    ("'n'", "`.`이 줄바꿈 문자와도 맞아요", "REGEXP_COUNT('a' || CHR(10) || 'b', 'a.b', 1, 'n')", 1),
    ("'m'", "`^`와 `$`가 줄마다 시작과 끝에 맞아요", "REGEXP_COUNT('a' || CHR(10) || 'b', '^b', 1, 'm')", 1),
)


def to_regexp_like_check(pattern, matching_texts, other_texts):
    """패턴 1개 > 후보 문자열 중 REGEXP_LIKE 참인 것만 남는지 검증"""
    candidates = " UNION ALL ".join(f"SELECT '{text}' AS 값 FROM DUAL" for text in matching_texts + other_texts)
    return sql_check(f"SELECT 값 FROM ({candidates}) WHERE REGEXP_LIKE(값, '{pattern}')",
                     [[text] for text in matching_texts])


def to_code_list(texts):
    return ", ".join(f"`{text}`" for text in texts)


METACHARACTER_TABLE = to_markdown_table(
    ("기호", "뜻", "패턴 예", "참이 되는 문자열", "거짓이 되는 문자열"),
    [(f"`{symbol}`", meaning, f"`{pattern}`", to_code_list(matching), to_code_list(other))
     for symbol, meaning, pattern, matching, other in METACHARACTER_EXAMPLES])
CHARACTER_CLASS_TABLE = to_markdown_table(
    ("표기", "뜻", f"REGEXP_COUNT('{CLASS_SAMPLE_TEXT}', 표기)"),
    [(f"`{notation}`", meaning, count) for notation, meaning, count in CHARACTER_CLASS_EXAMPLES])
FUNCTION_TABLE = to_markdown_table(
    ("식", "결과"), [(f"`{expression}`", result) for expression, result in FUNCTION_EXAMPLES])
# 일치 옵션 식에 || 가 있어 표 대신 SQL 블록으로 결과를 보임 (표 칸 구분자와 겹침)
MATCH_OPTION_TABLE = to_markdown_table(
    ("옵션", "뜻"), [(option, meaning) for option, meaning, _, _ in MATCH_OPTION_EXAMPLES])
MATCH_OPTION_BLOCK_SQL = "\n".join(
    f"SELECT {expression} FROM DUAL;  -- {result}번 맞아요" for _, _, expression, result in MATCH_OPTION_EXAMPLES)

# 본문 SQL·결과와 검증 항목의 원본
REGEXP_LIKE_PARTIAL_SQL = "SELECT 이름 FROM 사원 WHERE REGEXP_LIKE(이름, '민');"
LIKE_WHOLE_SQL = "SELECT 이름 FROM 사원 WHERE 이름 LIKE '민';"
LIKE_PERCENT_SQL = "SELECT 이름 FROM 사원 WHERE 이름 LIKE '%민%';"
POSITION_ALTERNATION_SQL = "SELECT 이름, 직급 FROM 사원 WHERE REGEXP_LIKE(직급, '^(사원|대리)$');"
POSITION_ALTERNATION_ROWS = [["박서준", "대리"], ["정하늘", "사원"], ["한도윤", "대리"], ["오지민", "사원"], ["윤서연", "사원"]]
NAME_START_SQL = "SELECT 이름 FROM 사원 WHERE REGEXP_LIKE(이름, '^[김이박]');"
NAME_NOT_START_SQL = "SELECT 이름 FROM 사원 WHERE REGEXP_LIKE(이름, '^[^김이박]');"
GREEDY_SQL = "SELECT REGEXP_SUBSTR('abcabc', 'a.+c') AS 탐욕, REGEXP_SUBSTR('abcabc', 'a.+?c') AS 최소 FROM DUAL;"
GREEDY_RANGE_SQL = "SELECT REGEXP_SUBSTR('aaaaa', 'a{2,3}') AS 탐욕, REGEXP_SUBSTR('aaaaa', 'a{2,3}?') AS 최소 FROM DUAL;"
ZERO_TIMES_SQL = "SELECT COUNT(*) FROM DUAL WHERE REGEXP_LIKE('bbb', 'a*');"
DOT_ESCAPE_SQL = "SELECT REGEXP_INSTR('a.b', '.') AS 아무글자, REGEXP_INSTR('a.b', '\\.') AS 점 FROM DUAL;"
POSIX_BRACKET_SQL = "SELECT REGEXP_COUNT('digit 1', '[[:digit:]]') AS 두겹, REGEXP_COUNT('digit 1', '[:digit:]') AS 한겹 FROM DUAL;"
NO_MATCH_SQL = ("SELECT REGEXP_SUBSTR('abc', '[0-9]') AS 꺼내기, REGEXP_INSTR('abc', '[0-9]') AS 위치,"
                " REGEXP_COUNT('abc', '[0-9]') AS 개수, REGEXP_REPLACE('abc', '[0-9]', '#') AS 바꾸기 FROM DUAL;")
REMOVE_SQL = "SELECT REGEXP_REPLACE('010-1234-5678', '[^0-9]') AS 숫자만 FROM DUAL;"
GROUP_REFERENCE_SQL = "SELECT REGEXP_REPLACE('010-1234-5678', '([0-9]{3})-([0-9]{4})-([0-9]{4})', '\\1-****-\\3') AS 가림 FROM DUAL;"
GROUP_SUBSTR_SQL = "SELECT REGEXP_SUBSTR('kim@pass.ql', '@(.+)$', 1, 1, NULL, 1) AS 도메인 FROM DUAL;"
# REGEXP_REPLACE 일치 옵션은 6번째 인자 (원본, 패턴, 바꿀 문자열, 시작 위치, n번째, 옵션)
REPLACE_OPTION_SQL = "SELECT REGEXP_REPLACE('ABC abc', 'abc', '#', 1, 0, 'i') FROM DUAL;"
OPTION_CONFLICT_SQL = "SELECT REGEXP_COUNT('ABC abc', 'abc', 1, 'ic') AS 뒤가c, REGEXP_COUNT('ABC abc', 'abc', 1, 'ci') AS 뒤가i FROM DUAL;"
REGEXP_LIKE_IN_SELECT_SQL = "SELECT REGEXP_LIKE('abc', 'b') FROM DUAL;"

# 확인 문제는 본문 예시와 값을 바꾼 응용 (본문: '민', 'a1b22c333' SUBSTR, 'abcabc')
NAME_PARTIAL_STEM_SQL = "SELECT 이름 FROM 사원 WHERE REGEXP_LIKE(이름, '서');"
NTH_POSITION_STEM_SQL = "SELECT REGEXP_INSTR('x12y345z6', '[0-9]+', 1, 2) FROM DUAL;"
LAZY_STEM_SQL = "SELECT REGEXP_SUBSTR('x1y2x3y', 'x.*?y') FROM DUAL;"
DIGITS_ONLY_CANDIDATES = ("123", "a1", "abc")

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
GREEDY_EXAMPLE = sql_example(GREEDY_SQL, ("탐욕", "최소"), [["abcabc", "abc"]], is_ordered=False)
POSITION_ALTERNATION_EXAMPLE = sql_example(POSITION_ALTERNATION_SQL, ("이름", "직급"), POSITION_ALTERNATION_ROWS, is_ordered=False)

CONCEPT = {
    "tagKey": "regular-expression",
    "topicCode": "sql_hierarchy_pivot",
    "sortOrder": 5,
    "title": "정규 표현식",
    "summary": "문자열의 모양을 기호로 적어서 찾고, 꺼내고, 바꾸는 방법이에요",
    "coreMd": (
        "- 정규 표현식은 \"숫자 4개\", \"김으로 시작\" 같은 문자열의 모양을 `.`, `*`, `[0-9]`, `^` 같은 기호로 적은 패턴이에요.\n"
        "- `REGEXP_LIKE`는 WHERE 절에서 패턴과 맞는지를 판단하는 조건이고, 나머지 넷은 값을 돌려주는 함수예요. `REGEXP_SUBSTR`는 맞는 부분을 꺼내고, `REGEXP_REPLACE`는 맞는 부분을 바꾸고, `REGEXP_INSTR`는 그 위치를, `REGEXP_COUNT`는 맞는 횟수를 알려 줘요.\n"
        "- LIKE는 문자열 전체가 패턴과 맞아야 하지만 정규 표현식은 일부만 맞아도 참이라서, 처음과 끝을 고정하려면 `^`와 `$`를 붙여요.\n"
        "- `*`, `+`, `{n,m}`은 기본으로 가능한 한 길게 맞추고(탐욕적 일치), 뒤에 `?`를 붙이면 가능한 한 짧게 맞춰요(최소 일치)."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

LIKE로는 `%`(아무 글자 여러 개)와 `_`(아무 글자 하나) 두 가지만 쓸 수 있어요. 그래서 "숫자로만 된 값", "숫자가 3개나 4개 이어진 부분", "문자열에서 두 번째로 나오는 숫자 덩어리" 같은 조건은 LIKE로 적을 수 없어요. 정규 표현식(regular expression)은 이런 문자열의 모양을 기호 몇 개로 적을 수 있게 해 주고, Oracle은 정규 표현식을 쓰는 함수 다섯 개를 제공해요.

## 한 줄 정의 {{#definition}}

정규 표현식은 찾고 싶은 문자열의 모양을 글자와 특별한 기호(메타 문자)로 적은 패턴이에요. 패턴 안의 일반 글자는 그 글자 자체와 맞고, 메타 문자는 "아무 글자", "여러 번 반복", "문자열의 시작"처럼 정해진 뜻을 가져요. 아래 예시는 공통 사원 표의 이름과 직급, 그리고 FROM DUAL로 만든 짧은 문자열을 써요. DUAL은 Oracle이 기본으로 가진 한 행짜리 표라서 값 하나를 계산해 볼 때 써요.

{EMPLOYEE_NAME_TABLE}

## 메타 문자 {{#metacharacters}}

아래 표의 "참이 되는 문자열"은 `REGEXP_LIKE(문자열, 패턴)`이 참이 되는 예예요. 정규 표현식은 문자열의 일부만 패턴과 맞아도 참이라는 점을 기억하고 보면 돼요.

{METACHARACTER_TABLE}

`*`, `+`, `?`, `{{n,m}}`처럼 횟수를 정하는 기호는 바로 앞 글자 하나에만 걸려요. 여러 글자를 묶어서 반복하려면 괄호 `( )`로 묶어서 `(ab)+`처럼 써요. 세로 막대 `|`는 "또는"이라는 뜻이라서 `사원|대리`는 사원이나 대리와 맞아요. 괄호와 `|`를 `^`, `$`와 함께 쓰면 직급이 정확히 사원이거나 대리인 행을 고를 수 있어요.

{POSITION_ALTERNATION_EXAMPLE.markdown}

자주 쓰는 글자 묶음은 짧은 표기로 적을 수 있어요. 역슬래시 표기(`\\d`, `\\w`, `\\s`)와 POSIX 표기(`[[:digit:]]`처럼 대괄호 안에 다시 대괄호를 쓰는 표기)가 있는데, 둘 다 글자 하나와 맞아요. 아래 표는 `'{CLASS_SAMPLE_TEXT}'`에서 각 표기와 맞는 글자 수를 센 결과예요.

{CHARACTER_CLASS_TABLE}

## 함수 다섯 개 {{#functions}}

```sql
-- 문법 (대괄호 안은 생략 가능)
REGEXP_LIKE(원본, 패턴 [, 일치 옵션])                                       -- WHERE 절에 쓰는 조건이에요
REGEXP_SUBSTR(원본, 패턴 [, 시작 위치 [, n번째 [, 일치 옵션 [, 묶음 번호]]]])     -- 맞는 부분을 꺼내요
REGEXP_INSTR(원본, 패턴 [, 시작 위치 [, n번째 [, 반환 옵션 [, 일치 옵션]]]])      -- 맞는 부분의 위치를 알려 줘요
REGEXP_REPLACE(원본, 패턴 [, 바꿀 문자열 [, 시작 위치 [, n번째 [, 일치 옵션]]]])  -- 맞는 부분을 바꿔요
REGEXP_COUNT(원본, 패턴 [, 시작 위치 [, 일치 옵션]])                          -- 맞는 횟수를 세요
```

시작 위치는 몇 번째 글자부터 찾을지를 정하고(기본 1), n번째는 맞는 부분 중 몇 번째 것을 쓸지를 정해요(기본 1). REGEXP_INSTR의 반환 옵션이 0(기본)이면 맞는 부분이 시작하는 위치를, 1이면 맞는 부분이 끝난 바로 다음 위치를 돌려줘요. 아래는 `'{FUNCTION_SAMPLE_TEXT}'`에서 숫자 덩어리 `[0-9]+`를 찾은 결과예요. 이 문자열의 숫자 덩어리는 2번째 글자의 1, 4~5번째 글자의 22, 7~9번째 글자의 333 세 개예요.

{FUNCTION_TABLE}

REGEXP_REPLACE는 n번째를 생략하면(또는 0을 주면) 맞는 부분을 모두 바꾸고, 숫자를 주면 그 번째 것 하나만 바꿔요. 바꿀 문자열을 생략하면 맞는 부분을 지워 버려요.

```sql
{REMOVE_SQL}  -- 01012345678이 나와요
```

패턴 안에서 괄호로 묶은 부분은 묶음(하위 표현식)이 되어 앞에서부터 1, 2, 3번이 붙어요. REGEXP_REPLACE의 바꿀 문자열에서 `\\1`, `\\2`처럼 그 묶음을 다시 쓸 수 있고, REGEXP_SUBSTR는 마지막 인자로 묶음 번호를 주면 그 묶음만 꺼내요.

```sql
{GROUP_REFERENCE_SQL}  -- 010-****-5678이 나와요
{GROUP_SUBSTR_SQL}  -- pass.ql이 나와요
```

## 일치 옵션 {{#match-options}}

일치 옵션은 패턴을 맞추는 방식을 바꾸는 문자예요. 넣는 자리는 함수마다 달라서 REGEXP_LIKE는 세 번째, REGEXP_COUNT는 네 번째, REGEXP_SUBSTR는 다섯 번째, REGEXP_INSTR와 REGEXP_REPLACE는 여섯 번째 인자예요. 아래 예시의 `CHR(10)`은 줄바꿈 문자이고, `||`는 두 문자열을 하나로 이어 붙이는 연산자예요.

{MATCH_OPTION_TABLE}

```sql
{MATCH_OPTION_BLOCK_SQL}
{REPLACE_OPTION_SQL}  -- 대소문자와 상관없이 둘 다 바뀌어서 # #이 돼요
```

## 탐욕적 일치와 최소 일치 {{#greedy}}

횟수를 정하는 `*`, `+`, `?`, `{{n,m}}`은 기본으로 맞출 수 있는 가장 긴 부분을 고르는데, 이것을 탐욕적 일치(greedy)라고 불러요. 기호 뒤에 `?`를 하나 더 붙이면 가장 짧은 부분을 고르는 최소 일치(non-greedy)가 돼요.

`?`는 놓인 자리에 따라 뜻이 둘이라서 헷갈리기 쉬워요. 글자 바로 뒤에 오면 그 글자가 0번 또는 1번이라는 횟수 기호이고, 다른 횟수 기호 바로 뒤에 오면 최소 일치 표시예요.

| `?`가 놓인 자리 | 뜻 | 예 |
|---|---|---|
| 글자 바로 뒤 | 그 글자가 0번 또는 1번 | `colou?r`는 color와 colour에 맞아요 |
| 횟수 기호(`*`, `+`, `?`, `{{n,m}}`) 바로 뒤 | 가장 짧게 맞추는 최소 일치 | `a.+?c`는 abcabc에서 abc만 꺼내요 |

{GREEDY_EXAMPLE.markdown}

`a.+c`는 첫 a에서 출발해 `.+`가 갈 수 있는 데까지 간 뒤 마지막 c에서 멈추므로 문자열 전체를 꺼내요. `a.+?c`는 a 뒤에 글자를 하나씩만 늘려 가다가 c를 처음 만나는 곳에서 바로 멈춰서 abc만 꺼내요. 범위 반복도 같아서, `'aaaaa'`에서 `a{{2,3}}`은 `aaa`를, `a{{2,3}}?`은 `aa`를 꺼내요.

```sql
{GREEDY_RANGE_SQL}  -- aaa와 aa가 나와요
```

## 자주 헷갈리는 점 {{#confusing}}

**LIKE는 전체가 맞아야 하고, 정규 표현식은 일부만 맞아도 돼요.** `LIKE '민'`은 이름이 정확히 "민" 한 글자인 행만 찾으므로 0행이에요. `REGEXP_LIKE(이름, '민')`은 이름 어딘가에 "민"이 들어 있으면 참이라서 김민수와 오지민이 나와요. LIKE로 같은 결과를 얻으려면 `LIKE '%민%'`처럼 앞뒤에 `%`를 붙여야 해요.

```sql
{LIKE_WHOLE_SQL}
{REGEXP_LIKE_PARTIAL_SQL}
{LIKE_PERCENT_SQL}
```

| 조건 | 결과 |
|---|---|
| `이름 LIKE '민'` | 0행 |
| `REGEXP_LIKE(이름, '민')` | 김민수, 오지민 |
| `이름 LIKE '%민%'` | 김민수, 오지민 |

그래서 "숫자로만 된 문자열"을 찾을 때 `[0-9]+`만 쓰면 `a1`처럼 숫자가 하나라도 섞인 값이 모두 참이 돼요. 전체를 고정하려면 `^[0-9]+$`처럼 시작과 끝을 붙여야 해요.

**`^`는 대괄호 안과 밖에서 뜻이 달라요.** 대괄호 밖의 `^`는 문자열의 시작이고, 대괄호 맨 앞의 `^`는 "괄호 안 글자가 아님"이에요. `^[김이박]`은 김, 이, 박으로 시작하는 이름이고, `^[^김이박]`은 그 세 글자가 아닌 글자로 시작하는 이름이에요.

```sql
{NAME_START_SQL}
{NAME_NOT_START_SQL}
```

| 조건 | 결과 |
|---|---|
| `REGEXP_LIKE(이름, '^[김이박]')` | 김민수, 이지은, 박서준 |
| `REGEXP_LIKE(이름, '^[^김이박]')` | 최유나, 정하늘, 한도윤, 오지민, 윤서연 |

**`*`는 0번도 포함해요.** `a*`는 a가 하나도 없는 빈 부분과도 맞으므로, `'bbb'`처럼 a가 없는 문자열에도 REGEXP_LIKE가 참이 돼요. 아래 SQL의 `COUNT(*)`는 조건을 통과한 행 수를 세는 함수라서, 1이 나오면 참이라는 뜻이에요. "a가 하나 이상"을 뜻하려면 `a+`를 써야 해요.

```sql
{ZERO_TIMES_SQL}  -- 1이 나와서 참이에요
```

**점 `.`은 마침표가 아니라 아무 글자예요.** 진짜 마침표를 찾으려면 앞에 역슬래시를 붙여 `\\.`으로 써요. `'a.b'`에서 `.`은 첫 글자 a와 바로 맞아서 위치가 1이고, `\\.`은 마침표가 있는 2를 돌려줘요.

```sql
{DOT_ESCAPE_SQL}  -- 1과 2가 나와요
```

**POSIX 표기는 대괄호를 두 겹으로 써야 해요.** `[[:digit:]]`가 숫자 하나이고, 바깥 대괄호를 빼고 `[:digit:]`라고 쓰면 `:`, `d`, `i`, `g`, `t` 중 한 글자라는 뜻이 돼요. 그래서 `'digit 1'`에서 `[:digit:]`는 숫자 1이 아니라 d, i, g, i, t 다섯 글자와 맞아요.

```sql
{POSIX_BRACKET_SQL}  -- 1과 5가 나와요
```

**맞는 부분이 없을 때 돌려주는 값이 함수마다 달라요.** REGEXP_SUBSTR는 NULL, REGEXP_INSTR와 REGEXP_COUNT는 0을 돌려주고, REGEXP_REPLACE는 바꿀 것이 없으므로 원본을 그대로 돌려줘요.

```sql
{NO_MATCH_SQL}  -- NULL, 0, 0, abc가 나와요
```

**REGEXP_LIKE는 SELECT 절에 값처럼 쓸 수 없어요.** Oracle 19c와 21c에서는 참·거짓을 값으로 꺼낼 수 없어서, REGEXP_LIKE는 WHERE 절이나 CASE WHEN(조건에 따라 다른 값을 고르는 식)의 조건 자리에만 써요. SELECT 절에 쓰면 Oracle이 REGEXP_LIKE를 열 이름으로 읽어서 ORA-00904(없는 열 이름) 오류가 나요.

```sql
-- 오류: REGEXP_LIKE는 조건이라 SELECT 절에 쓸 수 없어요 (ORA-00904, 없는 열 이름)
{REGEXP_LIKE_IN_SELECT_SQL}
```

**일치 옵션이 서로 부딪치면 뒤에 쓴 것이 이겨요.** `'ic'`는 마지막 c 때문에 대소문자를 구분하고, `'ci'`는 마지막 i 때문에 구분하지 않아요.

```sql
{OPTION_CONFLICT_SQL}  -- 1과 2가 나와요
```

## 시험에서는 이렇게 나와요 {{#exam-point}}

REGEXP_SUBSTR, REGEXP_INSTR, REGEXP_REPLACE, REGEXP_COUNT의 결과를 직접 계산하게 하는 문제가 가장 많아요. 이때는 패턴과 맞는 부분을 원본 문자열에서 앞에서부터 하나씩 표시해 두고, 시작 위치와 n번째 인자를 차례로 적용하면 실수가 줄어요. 그 밖에 메타 문자의 뜻, 탐욕적 일치와 `?`를 붙인 최소 일치의 차이, LIKE와 REGEXP_LIKE의 차이가 자주 나와요.""",
    "checkQuestions": [
        question(1, "Oracle 정규 표현식 중 값을 돌려주지 않고 WHERE 절에서 참·거짓을 판단하는 조건으로 쓰는 것은 무엇인가요?", "functions",
                 "REGEXP_LIKE는 패턴과 맞는지를 판단하는 조건이라서 WHERE 절에 써요. 나머지 넷은 문자열이나 숫자를 돌려주는 함수예요.",
                 [choice("A", "REGEXP_LIKE", True, "패턴과 맞으면 참이 되는 조건이에요."),
                  choice("B", "REGEXP_SUBSTR", rationale="맞는 부분을 문자열로 꺼내 주는 함수예요."),
                  choice("C", "REGEXP_INSTR", rationale="맞는 부분의 위치를 숫자로 돌려주는 함수예요."),
                  choice("D", "REGEXP_COUNT", rationale="맞는 횟수를 숫자로 돌려주는 함수예요.")]),
        question(2, "공통 예시의 사원 표에 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_NAME_TABLE, "confusing",
                 "정규 표현식은 문자열의 일부만 패턴과 맞아도 참이에요. 이름 가운데에 \"서\"가 들어 있는 박서준과 윤서연 두 명이 나와요.",
                 [choice("A", "0행", rationale="LIKE '서'처럼 이름 전체가 서와 같아야 한다고 본 답이에요."),
                  choice("B", "2행", True, "이름 어딘가에 서가 있는 박서준, 윤서연이 나와요."),
                  choice("C", "1행", rationale="박서준과 윤서연 둘 다 이름에 서가 들어 있어요."),
                  choice("D", "8행", rationale="이름에 서가 없는 여섯 명은 빠져요.")],
                 stem_sql=NAME_PARTIAL_STEM_SQL),
        question(3, "문자열 전체가 숫자로만 이루어져 있을 때만 REGEXP_LIKE가 참이 되는 패턴은 무엇인가요?", "confusing",
                 "^와 $로 시작과 끝을 고정해야 문자열 전체가 숫자인지 확인할 수 있어요. 고정하지 않으면 숫자가 하나만 섞여도 참이 돼요.",
                 [choice("A", "'[0-9]+'", rationale="일부만 맞아도 되므로 'a1'도 참이 돼요."),
                  choice("B", "'[:digit:]+'", rationale="대괄호가 한 겹이라 :, d, i, g, t 중 한 글자라는 뜻이에요."),
                  choice("C", "'^[0-9]+$'", True, "시작부터 끝까지 숫자만 1개 이상 이어져야 참이에요."),
                  choice("D", "'^[^0-9]+$'", rationale="대괄호 안의 ^는 부정이라서 숫자가 하나도 없는 문자열을 찾아요.")]),
        question(4, "다음 SQL의 결과는 무엇인가요?", "functions",
                 "'x12y345z6'에서 [0-9]+와 맞는 덩어리는 2번째 글자의 12, 5번째 글자의 345, 9번째 글자의 6이에요. 두 번째 덩어리 345가 시작하는 위치이므로 5예요.",
                 [choice("A", "2", rationale="첫 번째 덩어리 12가 시작하는 위치예요."),
                  choice("B", "5", True, "두 번째 덩어리 345가 5번째 글자에서 시작해요."),
                  choice("C", "345", rationale="덩어리 자체를 꺼내는 것은 REGEXP_SUBSTR이고, REGEXP_INSTR는 위치를 돌려줘요."),
                  choice("D", "8", rationale="반환 옵션을 1로 줬을 때 나오는, 덩어리가 끝난 바로 다음 위치예요.")],
                 stem_sql=NTH_POSITION_STEM_SQL),
        question(5, "다음 SQL의 결과는 무엇인가요?", "greedy",
                 "* 뒤에 붙은 ?는 최소 일치 표시라서, 첫 x에서 출발해 y를 처음 만나는 곳에서 멈춰요. 그래서 x1y만 꺼내요.",
                 [choice("A", "x1y2x3y", rationale="?가 없는 x.*y, 즉 탐욕적 일치의 결과예요."),
                  choice("B", "xy", rationale="원본에 x 바로 뒤에 y가 오는 곳이 없어서 xy는 꺼낼 수 없어요."),
                  choice("C", "x3y", rationale="REGEXP_SUBSTR는 앞에서부터 처음 맞는 부분을 꺼내요."),
                  choice("D", "x1y", True, "첫 x부터 가장 가까운 y까지 가장 짧게 맞춘 결과예요.")],
                 stem_sql=LAZY_STEM_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 메타 문자 표 (행마다 참·거짓 문자열 확인)
        *[to_regexp_like_check(pattern, list(matching), list(other))
          for _, _, pattern, matching, other in METACHARACTER_EXAMPLES],
        # 짧은 표기 표
        *[sql_check(f"SELECT REGEXP_COUNT('{CLASS_SAMPLE_TEXT}', '{notation}') FROM DUAL", [[count]])
          for notation, _, count in CHARACTER_CLASS_EXAMPLES],
        # 함수 결과 표, 일치 옵션 표
        *[sql_check(f"SELECT {expression} FROM DUAL", [[result]]) for expression, result in FUNCTION_EXAMPLES],
        *[sql_check(f"SELECT {expression} FROM DUAL", [[result]]) for _, _, expression, result in MATCH_OPTION_EXAMPLES],
        POSITION_ALTERNATION_EXAMPLE.check,
        sql_check(REMOVE_SQL, [["01012345678"]]),
        sql_check(GROUP_REFERENCE_SQL, [["010-****-5678"]]),
        sql_check(GROUP_SUBSTR_SQL, [["pass.ql"]]),
        GREEDY_EXAMPLE.check,
        sql_check(GREEDY_RANGE_SQL, [["aaa", "aa"]]),
        sql_check(LIKE_WHOLE_SQL, []),
        sql_check(REGEXP_LIKE_PARTIAL_SQL, [["김민수"], ["오지민"]]),
        sql_check(LIKE_PERCENT_SQL, [["김민수"], ["오지민"]]),
        sql_check(NAME_START_SQL, [["김민수"], ["이지은"], ["박서준"]]),
        sql_check(NAME_NOT_START_SQL, [["최유나"], ["정하늘"], ["한도윤"], ["오지민"], ["윤서연"]]),
        sql_check(ZERO_TIMES_SQL, [[1]]),
        sql_check(DOT_ESCAPE_SQL, [[1, 2]]),
        sql_check(POSIX_BRACKET_SQL, [[1, 5]]),
        sql_check(NO_MATCH_SQL, [[None, 0, 0, "abc"]]),
        sql_error_check(REGEXP_LIKE_IN_SELECT_SQL, "ORA-00904"),
        sql_check(OPTION_CONFLICT_SQL, [[1, 2]]),
        sql_check(REPLACE_OPTION_SQL, [["# #"]]),
        # 확인 문제 3 보기 4개: 후보 '123', 'a1', 'abc' 중 참인 문자열
        to_regexp_like_check("[0-9]+", ["123", "a1"], ["abc"]),
        to_regexp_like_check("[:digit:]+", [], list(DIGITS_ONLY_CANDIDATES)),
        to_regexp_like_check("^[0-9]+$", ["123"], ["a1", "abc"]),
        to_regexp_like_check("^[^0-9]+$", ["abc"], ["123", "a1"]),
        sql_check(NAME_PARTIAL_STEM_SQL, [["박서준"], ["윤서연"]]),
        sql_check(NTH_POSITION_STEM_SQL, [[5]]),
        sql_check(LAZY_STEM_SQL, [["x1y"]]),
        # 확인 문제 4·5 오답 보기: 첫 덩어리 위치, 반환 옵션 1, 덩어리 값, 탐욕적 일치
        sql_check("SELECT REGEXP_INSTR('x12y345z6', '[0-9]+'), REGEXP_INSTR('x12y345z6', '[0-9]+', 1, 2, 1),"
                  " REGEXP_SUBSTR('x12y345z6', '[0-9]+', 1, 2) FROM DUAL", [[2, 8, "345"]]),
        sql_check("SELECT REGEXP_SUBSTR('x1y2x3y', 'x.*y') FROM DUAL", [["x1y2x3y"]]),
    ],
}
