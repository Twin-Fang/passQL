"""개념: OUTER JOIN (5단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import DEPARTMENT_TABLE_MD, EMPLOYEE_TABLE_MD

# 본문·문제 공통 SQL
LEFT_JOIN_SQL = "SELECT E.이름, D.부서명 FROM 사원 E LEFT OUTER JOIN 부서 D ON E.부서번호 = D.부서번호"
FULL_JOIN_COUNT_SQL = "SELECT COUNT(*) FROM 사원 E FULL OUTER JOIN 부서 D ON E.부서번호 = D.부서번호;"
HIGH_SALARY_WHERE_SQL = ("SELECT D.부서명, E.이름 FROM 부서 D LEFT JOIN 사원 E "
                         "ON D.부서번호 = E.부서번호 WHERE E.급여 >= 3000;")
EMPTY_DEPARTMENT_SQL = ("SELECT D.부서명 FROM 부서 D LEFT JOIN 사원 E "
                        "ON D.부서번호 = E.부서번호 WHERE E.사번 IS NULL;")

# 짝이 맞는 7행 (이름, 부서명)
MATCHED_ROWS = [["김민수", "기획부"], ["이지은", "개발부"], ["박서준", "개발부"], ["정하늘", "개발부"],
                ["최유나", "영업부"], ["한도윤", "영업부"], ["오지민", "영업부"]]
LEFT_JOIN_ROWS = MATCHED_ROWS + [["윤서연", None]]
RIGHT_JOIN_ROWS = MATCHED_ROWS + [[None, "인사부"]]
FULL_JOIN_ROWS = MATCHED_ROWS + [["윤서연", None], [None, "인사부"]]
# 부서 기준, 급여 3000 이상 사원만 붙임 (조건을 ON 에 둔 결과 4행)
HIGH_SALARY_ON_ROWS = [["기획부", "김민수"], ["개발부", None], ["영업부", "최유나"], ["인사부", None]]

CONCEPT = {
    "tagKey": "join-outer",
    "topicCode": "sql_join",
    "sortOrder": 4,
    "title": "OUTER JOIN",
    "summary": "짝이 없는 행도 버리지 않고, 모자란 쪽 열을 NULL로 채워 남겨요",
    "coreMd": (
        "- OUTER JOIN은 기준이 되는 표의 행을 짝이 없어도 모두 남기고, 짝이 없는 상대 쪽 열은 NULL로 채워요.\n"
        "- LEFT는 왼쪽 표, RIGHT는 오른쪽 표, FULL은 양쪽 표의 행을 모두 남기고, `OUTER`라는 단어는 생략할 수 있어요.\n"
        "- Oracle의 `(+)`는 NULL이 채워질 쪽 표의 열에 붙여요. 사원이 기준이면 부서 쪽에 붙여 `E.부서번호 = D.부서번호(+)`로 쓰고, `(+)`로는 FULL OUTER JOIN을 쓸 수 없어요.\n"
        "- NULL이 채워지는 쪽 표의 조건을 WHERE 절에 두면 NULL 행이 걸러져 INNER JOIN처럼 되므로, 그 조건은 ON 절에 둬야 해요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

부서마다 사원이 몇 명인지 보고서를 만든다고 생각해 보세요. INNER JOIN으로 부서와 사원을 이으면 소속 사원이 없는 인사부는 짝이 없어서 결과에서 사라져요. 보고서에는 "인사부 0명"이 나와야 하는데, 부서 자체가 빠져 버리는 거예요. 부서가 아직 정해지지 않은 윤서연도 사원 명단에서 사라지기는 마찬가지예요.

이렇게 짝이 없는 행도 버리지 않고 결과에 남기고 싶을 때 쓰는 조인이 OUTER JOIN(외부 조인)이에요. 이 개념의 예시는 모두 아래 사원 표(8명)와 부서 표(4개)로 계산해요.

{EMPLOYEE_TABLE_MD}

{DEPARTMENT_TABLE_MD}

## 한 줄 정의 {{#definition}}

OUTER JOIN은 기준으로 정한 표의 행을 짝이 있든 없든 모두 남기고, 짝이 없는 행은 상대 표의 열을 NULL로 채워서 보여 주는 조인이에요. 어느 표를 기준으로 할지에 따라 세 가지로 나뉘어요.

| 종류 | 모두 남는 행 | 위 표로 계산한 결과 |
|---|---|---|
| `사원 E LEFT OUTER JOIN 부서 D` | 왼쪽 표(사원)의 모든 행 | 짝 7행 + 윤서연 = 8행 |
| `사원 E RIGHT OUTER JOIN 부서 D` | 오른쪽 표(부서)의 모든 행 | 짝 7행 + 인사부 = 8행 |
| `사원 E FULL OUTER JOIN 부서 D` | 양쪽 표의 모든 행 | 짝 7행 + 윤서연 + 인사부 = 9행 |

결과 행 수는 "짝이 맞는 행 수 + 기준 표에서 짝을 못 찾은 행 수"로 계산하면 돼요.

## LEFT OUTER JOIN {{#left}}

```sql
SELECT E.이름, D.부서명
FROM 사원 E LEFT OUTER JOIN 부서 D
  ON E.부서번호 = D.부서번호;
```

| 이름 | 부서명 |
|---|---|
| 김민수 | 기획부 |
| 이지은 | 개발부 |
| 박서준 | 개발부 |
| 정하늘 | 개발부 |
| 최유나 | 영업부 |
| 한도윤 | 영업부 |
| 오지민 | 영업부 |
| 윤서연 | NULL |

왼쪽에 쓴 사원 표가 기준이라서 사원 8명이 모두 나와요. 윤서연은 짝이 맞는 부서가 없으니 부서명 칸이 NULL로 채워져요. 오른쪽 표에만 있는 인사부는 기준 표가 아니라서 나오지 않아요.

## RIGHT와 FULL {{#right-full}}

RIGHT OUTER JOIN은 오른쪽 표를 기준으로 삼아요. 같은 조건으로 쓰면 이번에는 인사부가 남고, 이름 칸이 NULL로 채워져요.

```sql
SELECT E.이름, D.부서명
FROM 사원 E RIGHT OUTER JOIN 부서 D
  ON E.부서번호 = D.부서번호;
```

결과는 짝이 맞는 7행에 `NULL | 인사부` 한 행이 더해진 8행이에요. 표의 순서를 바꿔 `부서 D LEFT JOIN 사원 E`라고 써도 기준이 부서 표가 되므로 같은 결과가 나와요.

FULL OUTER JOIN은 양쪽 표를 모두 기준으로 삼아서, 윤서연과 인사부가 함께 남아요.

```sql
SELECT E.이름, D.부서명
FROM 사원 E FULL OUTER JOIN 부서 D
  ON E.부서번호 = D.부서번호;
```

| 이름 | 부서명 |
|---|---|
| 김민수 | 기획부 |
| 이지은 | 개발부 |
| 박서준 | 개발부 |
| 정하늘 | 개발부 |
| 최유나 | 영업부 |
| 한도윤 | 영업부 |
| 오지민 | 영업부 |
| 윤서연 | NULL |
| NULL | 인사부 |

LEFT 결과 8행과 RIGHT 결과 8행을 더한 16행이 아니라 9행이라는 점에 주의하세요. 짝이 맞는 7행은 양쪽 결과에 똑같이 들어 있어서 한 번만 세요.

## Oracle의 (+) 표기 {{#oracle-plus}}

Oracle 방식에서는 WHERE 절의 조인 조건에 `(+)`를 붙여 외부 조인을 표시해요. `(+)`를 붙이는 자리는 짝이 없을 때 NULL로 채워질 쪽 표의 열이에요.

`사원 E LEFT JOIN 부서 D`를 예로 들면, 기준은 왼쪽의 사원 표이고 윤서연처럼 짝이 없는 사원이 있으면 오른쪽 부서 표의 열이 NULL로 채워져요. 그래서 `(+)`는 부서 쪽 열인 `D.부서번호` 뒤에 붙여 `E.부서번호 = D.부서번호(+)`라고 써요. 모자란 쪽에 빈 행을 더해(+) 준다고 생각하면 위치를 기억하기 쉬워요.

```sql
SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호(+);    -- 사원이 기준이라 LEFT JOIN과 같은 8행이 나와요
SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호(+) = D.부서번호;    -- 부서가 기준이라 RIGHT JOIN과 같은 8행이 나와요
SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호(+) = D.부서번호(+); -- 오류: (+)는 양쪽에 붙일 수 없어요 (ORA-01468, 외부 조인 표시는 한쪽에만)
```

양쪽에 `(+)`를 붙일 수 없으니 `(+)`로는 FULL OUTER JOIN을 만들 수 없고, FULL은 ANSI 문법으로만 써요. `(+)`에는 이 밖에도 제약이 있어요. `(+)`를 붙인 조건은 OR로 다른 조건과 묶을 수 없고(ORA-01719, OR와 함께 쓸 수 없음), `JOIN ... ON` 같은 ANSI 조인과 한 문장에 섞어 쓸 수도 없어요(ORA-25156, ANSI 조인과 섞을 수 없음).

## 자주 헷갈리는 점 {{#confusing}}

**NULL이 채워지는 쪽의 조건을 WHERE에 두면 INNER JOIN처럼 돼요.** 아래 두 SQL은 모두 부서를 기준으로 급여 3000 이상인 사원을 붙이려는 것인데, 조건의 위치만 다를 뿐인데도 결과가 달라요.

```sql
SELECT D.부서명, E.이름
FROM 부서 D LEFT JOIN 사원 E
  ON D.부서번호 = E.부서번호 AND E.급여 >= 3000;
```

| 부서명 | 이름 |
|---|---|
| 기획부 | 김민수 |
| 개발부 | NULL |
| 영업부 | 최유나 |
| 인사부 | NULL |

```sql
SELECT D.부서명, E.이름
FROM 부서 D LEFT JOIN 사원 E
  ON D.부서번호 = E.부서번호
WHERE E.급여 >= 3000;
```

| 부서명 | 이름 |
|---|---|
| 기획부 | 김민수 |
| 영업부 | 최유나 |

차이는 조건이 언제 쓰이느냐에서 생겨요. ON 절에 둔 조건은 짝을 찾을 때 쓰여요. 그래서 급여 3000 이상인 사원이 없는 개발부와 인사부는 짝을 못 찾은 기준 행으로 남고, 이름 칸만 NULL이 돼요.

WHERE 절에 둔 조건은 조인이 끝난 뒤에 쓰여요. 조인 단계에서는 급여와 상관없이 짝 7행과 `인사부 | NULL` 1행, 모두 8행이 만들어져요. 그다음 WHERE 절이 급여 3000 미만인 사원 다섯 행을 거르고, 인사부 행도 급여가 NULL이라 함께 빠져요. NULL과 비교한 `E.급여 >= 3000`은 참도 거짓도 아닌 UNKNOWN(알 수 없음)이 되는데, WHERE 절은 참인 행만 남기기 때문이에요. 외부 조인으로 살려 둔 행이 WHERE 절에서 사라지니, 결과는 INNER JOIN에 같은 조건을 건 것과 같아져요.

**(+) 표기에서는 상대 표의 다른 조건에도 (+)를 붙여야 해요.** Oracle 방식에는 ON 절이 따로 없어서, WHERE 절 안에서 `(+)`가 붙은 조건은 ON 절처럼 짝을 찾는 데 쓰이고 `(+)`가 없는 조건은 WHERE 절처럼 결과를 거르는 데 쓰여요. 그래서 위의 ON 절 SQL을 옮길 때는 `E.급여(+) >= 3000`처럼 급여 조건에도 `(+)`를 붙여야 같은 4행이 나와요. `(+)`를 빼고 `E.급여 >= 3000`이라고 쓰면 WHERE 절에 둔 두 번째 SQL과 같아져서 2행만 남아요.

```sql
SELECT D.부서명, E.이름 FROM 부서 D, 사원 E WHERE D.부서번호 = E.부서번호(+) AND E.급여(+) >= 3000;  -- 4행이 나와요
SELECT D.부서명, E.이름 FROM 부서 D, 사원 E WHERE D.부서번호 = E.부서번호(+) AND E.급여 >= 3000;     -- 2행이 나와요
```

**기준 표의 조건을 ON에 두면 기준 행은 걸러지지 않아요.** 반대로 기준 표 쪽 조건을 ON 절에 두면, 조건에 맞지 않는 기준 행도 결과에 남고 상대 열만 NULL이 돼요. 예를 들어 `사원 E LEFT JOIN 부서 D ON E.부서번호 = D.부서번호 AND E.급여 >= 2800`은 사원 8명이 모두 나오고, 급여 2800 이상인 김민수, 박서준, 최유나만 부서명이 채워져요. 급여 2800 이상인 사원만 보고 싶다면 그 조건은 WHERE 절에 둬야 해요.

**짝이 없는 행만 찾을 때는 상대 표의 열을 IS NULL로 걸러요.** `IS NULL`은 값이 NULL인지 확인하는 조건이에요. 외부 조인으로 NULL이 채워진 행만 남기면 "짝이 없는 쪽"을 찾을 수 있어요. 아래 SQL은 사원이 한 명도 없는 부서인 인사부만 돌려줘요.

```sql
SELECT D.부서명
FROM 부서 D LEFT JOIN 사원 E
  ON D.부서번호 = E.부서번호
WHERE E.사번 IS NULL;
```

이때 확인할 열은 사번처럼 원래 NULL이 없는 열이어야 해요. 커미션처럼 원래 NULL이 들어 있는 열로 `E.커미션 IS NULL`을 확인하면, 짝이 있는 김민수(기획부), 최유나(영업부), 정하늘(개발부)도 커미션이 NULL이라서 함께 걸려 4행이 나와요.

**부서별 인원을 셀 때는 COUNT(*) 대신 COUNT(상대 열)을 써요.** 아래 SQL의 `GROUP BY D.부서명`은 부서명이 같은 행끼리 묶으라는 뜻이고, `COUNT(*)`는 묶음마다 행이 몇 개인지, `COUNT(E.사번)`은 사번이 NULL이 아닌 행이 몇 개인지 세요. 두 기능은 7단원 그룹 함수에서 자세히 다뤄요. 인사부는 NULL로 채워진 한 행이 있어서 `COUNT(*)`는 1이 나오지만, `COUNT(E.사번)`은 NULL을 세지 않으므로 0이 나와요.

```sql
SELECT D.부서명, COUNT(*), COUNT(E.사번)
FROM 부서 D LEFT JOIN 사원 E ON D.부서번호 = E.부서번호
GROUP BY D.부서명;
```

| 부서명 | COUNT(*) | COUNT(E.사번) |
|---|---|---|
| 기획부 | 1 | 1 |
| 개발부 | 3 | 3 |
| 영업부 | 3 | 3 |
| 인사부 | 1 | 0 |

**(+)가 붙은 쪽이 기준이 아니에요.** `(+)`는 NULL이 채워질 쪽에 붙으니, 모든 행이 남는 기준 표는 `(+)`가 없는 쪽이에요. `E.부서번호 = D.부서번호(+)`라면 `(+)`가 없는 사원 표가 기준이어서 LEFT JOIN과 같아요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

LEFT, RIGHT, FULL 결과의 행 수를 묻는 문제가 가장 많아요. 짝이 맞는 행 수를 먼저 세고, 기준 표에서 짝을 못 찾은 행을 더하면 돼요. ANSI 문법과 `(+)` 표기 중 같은 결과를 내는 것을 고르는 문제, NULL이 채워지는 쪽의 조건을 ON 절과 WHERE 절 중 어디에 두느냐에 따라 달라지는 결과를 묻는 문제도 자주 나와요.""",
    "checkQuestions": [
        question(1, "`사원 E LEFT OUTER JOIN 부서 D ON E.부서번호 = D.부서번호`의 결과에 짝이 없어도 반드시 모두 남는 행은 무엇인가요?", "definition",
                 "LEFT OUTER JOIN은 왼쪽에 쓴 표를 기준으로 삼아요. 그래서 사원 표의 행은 짝이 없어도 모두 남고, 짝이 없는 부서 열은 NULL로 채워져요.",
                 [choice("A", "부서 표의 모든 행", rationale="부서 표를 모두 남기는 것은 RIGHT OUTER JOIN이에요."),
                  choice("B", "양쪽 표에 짝이 있는 행만", rationale="짝이 있는 행만 남기는 것은 INNER JOIN이에요."),
                  choice("C", "사원 표의 모든 행", True, "왼쪽 표가 기준이라 사원 8명이 모두 남아요."),
                  choice("D", "양쪽 표의 모든 행", rationale="양쪽을 모두 남기는 것은 FULL OUTER JOIN이에요.")]),
        question(2, "`FROM 사원 E LEFT OUTER JOIN 부서 D ON E.부서번호 = D.부서번호`와 같은 결과를 내는 Oracle 방식의 조건은 무엇인가요?", "oracle-plus",
                 "`(+)`는 NULL이 채워질 쪽 표의 열에 붙여요. 사원이 기준이면 짝이 없을 때 부서 열이 NULL로 채워지므로 부서 쪽 열에 붙여요.",
                 [choice("A", "FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호(+)", True, "부서 쪽에 (+)가 붙어 사원이 기준이 돼요."),
                  choice("B", "FROM 사원 E, 부서 D WHERE E.부서번호(+) = D.부서번호", rationale="사원 쪽에 (+)를 붙이면 부서가 기준인 RIGHT JOIN이 돼요."),
                  choice("C", "FROM 사원 E, 부서 D WHERE E.부서번호(+) = D.부서번호(+)", rationale="(+)는 양쪽에 붙일 수 없어서 오류가 나요."),
                  choice("D", "FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호", rationale="(+)가 없으면 짝이 있는 7행만 남는 등가 조인이에요.")]),
        question(3, "본문의 사원 표와 부서 표에서 사원 1008 윤서연은 부서가 없고, 부서 40 인사부는 사원이 없어요. 다음 SQL의 결과는 무엇인가요? `COUNT(*)`는 결과 행의 개수를 세요.", "right-full",
                 "짝이 맞는 7행에 짝이 없는 윤서연과 인사부가 한 행씩 더해져요. LEFT 8행과 RIGHT 8행을 단순히 더하지 않도록 주의해요.",
                 [choice("A", "7", rationale="짝이 있는 행만 센 INNER JOIN의 결과예요."),
                  choice("B", "8", rationale="한쪽의 짝 없는 행만 더한 LEFT나 RIGHT의 결과예요."),
                  choice("C", "16", rationale="짝이 맞는 7행은 한 번만 세므로 LEFT와 RIGHT를 단순히 더하지 않아요."),
                  choice("D", "9", True, "짝 7행에 윤서연과 인사부가 더해져요.")],
                 stem_sql=FULL_JOIN_COUNT_SQL),
        question(4, "급여가 3000 이상인 사원은 기획부의 김민수(3000)와 영업부의 최유나(3200)뿐이에요. 다음 SQL은 몇 행을 돌려주나요?", "confusing",
                 "조인 단계에서 인사부는 이름과 급여가 NULL인 행으로 남지만, WHERE 절에서 급여 조건이 UNKNOWN이 되어 빠져요. 급여 3000 미만인 사원 행도 함께 걸러져 김민수와 최유나 2행만 남아요.",
                 [choice("A", "4행", rationale="4행은 급여 조건을 ON 절에 두었을 때의 결과예요."),
                  choice("B", "2행", True, "WHERE 절이 NULL 행을 걸러서 김민수와 최유나만 남아요."),
                  choice("C", "8행", rationale="급여 조건 때문에 사원 대부분이 걸러져요."),
                  choice("D", "0행", rationale="김민수와 최유나는 급여 조건을 만족해서 남아요.")],
                 stem_sql=HIGH_SALARY_WHERE_SQL),
        question(5, "다음 SQL의 결과로 알맞은 것은 무엇인가요? `IS NULL`은 값이 NULL인지 확인하는 조건이에요.", "confusing",
                 "부서를 기준으로 외부 조인하면 사원이 없는 인사부만 사번이 NULL로 채워져요. WHERE 절이 그 행만 남기므로 인사부 한 행이 나와요.",
                 [choice("A", "인사부 1행", True, "짝이 없는 부서는 인사부 하나뿐이에요."),
                  choice("B", "0행", rationale="외부 조인이라 짝 없는 인사부가 NULL로 채워져 남아 있어요."),
                  choice("C", "기획부, 개발부, 영업부 3행", rationale="이 세 부서는 사원과 짝이 있어 사번이 NULL이 아니에요."),
                  choice("D", "부서 4개 모두", rationale="WHERE 절이 사번이 NULL인 행만 남겨요.")],
                 stem_sql=EMPTY_DEPARTMENT_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문: LEFT·RIGHT·FULL, 표 순서 바꾸기
        sql_check(LEFT_JOIN_SQL, LEFT_JOIN_ROWS),
        sql_check("SELECT E.이름, D.부서명 FROM 사원 E RIGHT OUTER JOIN 부서 D ON E.부서번호 = D.부서번호", RIGHT_JOIN_ROWS),
        sql_check("SELECT E.이름, D.부서명 FROM 부서 D LEFT JOIN 사원 E ON E.부서번호 = D.부서번호", RIGHT_JOIN_ROWS),
        sql_check("SELECT E.이름, D.부서명 FROM 사원 E FULL OUTER JOIN 부서 D ON E.부서번호 = D.부서번호", FULL_JOIN_ROWS),
        # 본문: (+) 표기와 제약
        sql_check("SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호(+)", LEFT_JOIN_ROWS),
        sql_check("SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호(+) = D.부서번호", RIGHT_JOIN_ROWS),
        sql_error_check("SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호(+) = D.부서번호(+)", "ORA-01468"),
        sql_error_check("SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호(+) OR E.사번 = 1001", "ORA-01719"),
        sql_error_check("SELECT E.이름 FROM 사원 E JOIN 부서 D ON E.부서번호 = D.부서번호 WHERE D.지역(+) = '서울'", "ORA-25156"),
        # 본문: ON <-> WHERE 함정, IS NULL, COUNT
        sql_check("SELECT D.부서명, E.이름 FROM 부서 D LEFT JOIN 사원 E ON D.부서번호 = E.부서번호 AND E.급여 >= 3000",
                  HIGH_SALARY_ON_ROWS),
        sql_check("SELECT D.부서명, E.이름 FROM 부서 D, 사원 E WHERE D.부서번호 = E.부서번호(+) AND E.급여(+) >= 3000",
                  HIGH_SALARY_ON_ROWS),
        sql_check("SELECT D.부서명, E.이름 FROM 부서 D, 사원 E WHERE D.부서번호 = E.부서번호(+) AND E.급여 >= 3000",
                  [["기획부", "김민수"], ["영업부", "최유나"]]),
        sql_check("SELECT E.이름, D.부서명 FROM 사원 E LEFT JOIN 부서 D ON E.부서번호 = D.부서번호 AND E.급여 >= 2800",
                  [["김민수", "기획부"], ["박서준", "개발부"], ["최유나", "영업부"], ["이지은", None], ["정하늘", None],
                   ["한도윤", None], ["오지민", None], ["윤서연", None]]),
        sql_check("SELECT D.부서명 FROM 부서 D LEFT JOIN 사원 E ON D.부서번호 = E.부서번호 WHERE E.커미션 IS NULL",
                  [["기획부"], ["개발부"], ["영업부"], ["인사부"]]),
        sql_check("SELECT D.부서명, COUNT(*), COUNT(E.사번) FROM 부서 D LEFT JOIN 사원 E ON D.부서번호 = E.부서번호 GROUP BY D.부서명",
                  [["기획부", 1, 1], ["개발부", 3, 3], ["영업부", 3, 3], ["인사부", 1, 0]]),
        # 확인 문제: stemSql, 2번 보기 4개
        sql_check(FULL_JOIN_COUNT_SQL, [[9]]),
        sql_check(HIGH_SALARY_WHERE_SQL, [["기획부", "김민수"], ["영업부", "최유나"]]),
        sql_check(EMPTY_DEPARTMENT_SQL, [["인사부"]]),
        sql_check("SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호", MATCHED_ROWS),
    ],
}
