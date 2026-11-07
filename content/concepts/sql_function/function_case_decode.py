"""개념: CASE와 DECODE (4단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

EMPLOYEE_COMMISSION_TABLE = to_employee_table_md("사번", "이름", "급여", "커미션", "부서번호")

# 단순 CASE: 같은지(=)만 비교, 부서 없는 윤서연은 ELSE
SIMPLE_CASE_EXAMPLE = sql_example(
    "SELECT 이름, 부서번호,\n"
    "       CASE 부서번호 WHEN 10 THEN '기획' WHEN 20 THEN '개발' ELSE '기타' END\n"
    "FROM 사원\n"
    "WHERE 사번 IN (1001, 1002, 1004, 1008)\n"
    "ORDER BY 사번;",
    ("이름", "부서번호", "단순 CASE 결과"),
    [["김민수", 10, "기획"], ["이지은", 20, "개발"], ["최유나", 30, "기타"], ["윤서연", None, "기타"]],
)

# 검색 CASE: 크기 비교, 좁은 범위(3000 이상)부터
SEARCHED_CASE_EXAMPLE = sql_example(
    "SELECT 이름, 급여,\n"
    "       CASE WHEN 급여 >= 3000 THEN '상' WHEN 급여 >= 2500 THEN '중' ELSE '하' END\n"
    "FROM 사원\n"
    "WHERE 사번 IN (1001, 1002, 1007)\n"
    "ORDER BY 사번;",
    ("이름", "급여", "검색 CASE 결과"),
    [["김민수", 3000, "상"], ["이지은", 2500, "중"], ["오지민", 2200, "하"]],
)

# WHEN 순서를 바꾼 검색 CASE: 처음 맞는 2500 이상에서 멈춤
SWAPPED_ORDER_CASE_EXAMPLE = sql_example(
    "SELECT 이름, 급여,\n"
    "       CASE WHEN 급여 >= 2500 THEN '중' WHEN 급여 >= 3000 THEN '상' ELSE '하' END\n"
    "FROM 사원\n"
    "WHERE 사번 IN (1001, 1004)\n"
    "ORDER BY 사번;",
    ("이름", "급여", "결과"),
    [["김민수", 3000, "중"], ["최유나", 3200, "중"]],
)

DECODE_EXAMPLE = sql_example(
    "SELECT 이름, DECODE(부서번호, 10, '기획', 20, '개발', '기타')\n"
    "FROM 사원\n"
    "WHERE 사번 IN (1001, 1002, 1004)\n"
    "ORDER BY 사번;",
    ("이름", "DECODE 결과"),
    [["김민수", "기획"], ["이지은", "개발"], ["최유나", "기타"]],
)

# 같은 커미션 8명에 세 식: 단순 CASE WHEN NULL <-> 검색 CASE IS NULL <-> DECODE NULL
NULL_MATCH_COMPARISON_EXAMPLE = sql_example(
    "SELECT 사번, 이름, 커미션,\n"
    "       CASE 커미션 WHEN NULL THEN '없음' ELSE '있음' END,\n"
    "       CASE WHEN 커미션 IS NULL THEN '없음' ELSE '있음' END,\n"
    "       DECODE(커미션, NULL, '없음', '있음')\n"
    "FROM 사원\n"
    "ORDER BY 사번;",
    ("사번", "이름", "커미션", "단순 CASE WHEN NULL", "검색 CASE IS NULL", "DECODE NULL"),
    [[1001, "김민수", None, "있음", "없음", "없음"], [1002, "이지은", 300, "있음", "있음", "있음"],
     [1003, "박서준", 0, "있음", "있음", "있음"], [1004, "최유나", None, "있음", "없음", "없음"],
     [1005, "정하늘", None, "있음", "없음", "없음"], [1006, "한도윤", 500, "있음", "있음", "있음"],
     [1007, "오지민", 200, "있음", "있음", "있음"], [1008, "윤서연", None, "있음", "없음", "없음"]],
)

# DECODE 결과 타입 = 첫 번째 결과(문자) > 숫자 부서번호 10 도 문자 '10'
DECODE_RESULT_TYPE_EXAMPLE = sql_example(
    "SELECT 이름, DECODE(부서번호, NULL, '미배정', 부서번호)\n"
    "FROM 사원\n"
    "WHERE 사번 IN (1001, 1008)\n"
    "ORDER BY 사번;",
    ("이름", "DECODE 결과 (문자)"),
    [["김민수", "10"], ["윤서연", "미배정"]],
)

CONCEPT = {
    "tagKey": "function-case-decode",
    "topicCode": "sql_function",
    "sortOrder": 5,
    "title": "CASE와 DECODE",
    "summary": "조건에 따라 다른 값을 고르는 식이고, 둘은 NULL을 비교하는 방식이 달라요",
    "coreMd": (
        "- CASE는 위에서부터 처음 맞는 WHEN 하나의 값을 돌려주고, 맞는 것도 ELSE도 없으면 **NULL**이에요.\n"
        "- 단순 CASE는 **같은지(=)만** 비교해서 `WHEN NULL`은 절대 맞지 않고, NULL은 `WHEN 열 IS NULL`로 찾아요.\n"
        "- `DECODE`는 단순 CASE와 같은 일을 하지만 **NULL과 NULL을 같다고** 봐요.\n"
        "- DECODE는 **Oracle에만** 있고, CASE는 SQL 표준이라 SQL Server에서도 써요."
    ),
    "detailMd": f"""## CASE와 DECODE가 하는 일: SQL 안의 IF 문 {{#why}}

부서번호 10, 20을 "기획", "개발"로 바꾸거나, 급여에 따라 상, 중, 하 등급을 붙이고 싶을 때가 있어요. 조건에 따라 다른 값을 고르는 이 일을 SQL에서는 CASE 식과 DECODE 함수가 맡아요.

아래 예시는 모두 이 사원 표로 설명해요.

{EMPLOYEE_COMMISSION_TABLE}

## CASE 식의 두 가지 모양: 단순 CASE와 검색 CASE {{#definition}}

| 용어 | 뜻 |
|---|---|
| CASE 식 | CASE로 시작해 END로 끝나요. 사이에 'WHEN 조건 THEN 결과'를 여러 개 적어요 |
| THEN | 맞는 WHEN을 찾으면 그 뒤의 값 하나를 돌려줘요 |
| ELSE | 맞는 WHEN이 하나도 없을 때의 값이에요. 생략했는데 맞는 것도 없으면 NULL이에요 |

| 구분 | 단순 CASE | 검색 CASE |
|---|---|---|
| 모양 | CASE 열 WHEN 값 THEN 결과 | CASE WHEN 조건식 THEN 결과 |
| CASE 바로 뒤 | 비교할 열을 한 번 적어요 | 비워 둬요 |
| 할 수 있는 비교 | 같은지(=)만 | 크기, 범위, IS NULL까지 모두 |

```sql
-- 문법: 위는 단순 CASE, 아래는 검색 CASE예요
CASE 열 WHEN 값1 THEN 결과1 WHEN 값2 THEN 결과2 ELSE 기본값 END
CASE WHEN 조건1 THEN 결과1 WHEN 조건2 THEN 결과2 ELSE 기본값 END
```

## 예시로 보는 CASE: 같음은 단순, 크기는 검색 {{#example}}

부서번호를 이름으로 바꾸는 일은 같은지만 보면 되므로 단순 CASE로 써요.

{SIMPLE_CASE_EXAMPLE.markdown}

부서가 없는 윤서연은 10과도 20과도 같지 않아서 ELSE의 '기타'가 나와요. 급여 등급은 크기를 비교해야 하므로 검색 CASE로 써요.

{SEARCHED_CASE_EXAMPLE.markdown}

## 처음 맞는 하나만: WHEN은 위에서부터 확인해요 {{#first-match}}

CASE는 **처음 맞는 WHEN**에서 멈추고, 뒤에 더 알맞은 조건이 있어도 보지 않아요. 그래서 범위가 겹치는 조건은 좁은 범위부터 적어야 해요.

위 급여 등급에서 두 WHEN의 순서만 바꾸면, 급여가 3000 이상인 사원도 첫 조건 `급여 >= 2500`에서 걸려 '상'이 하나도 나오지 않아요.

{SWAPPED_ORDER_CASE_EXAMPLE.markdown}

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 범위가 겹치는 검색 CASE는 좁은 범위의 WHEN을 위에 적어야 해요 | O | 넓은 범위가 위에 있으면 좁은 범위의 행도 거기서 먼저 걸려요 |

## DECODE: 비교값과 결과를 짝지어 적는 Oracle 함수 {{#decode}}

`DECODE(값, 비교1, 결과1, 비교2, 결과2, ..., 기본값)`는 값이 비교1과 같으면 결과1을, 비교2와 같으면 결과2를 돌려줘요. 짝을 이루고 남는 마지막 하나가 기본값이고, 기본값을 생략하면 NULL이에요.

{DECODE_EXAMPLE.markdown}

```sql
SELECT 이름, DECODE(부서번호, 10, '기획', 20, '개발') FROM 사원 WHERE 사번 = 1004;   -- 기본값을 빼서 최유나는 NULL이 나와요
```

| 구분 | CASE | DECODE |
|---|---|---|
| 정체 | SQL 표준 식 | Oracle 전용 함수 |
| SQL Server | 써요 | 없어서 CASE로 바꿔 써요 |
| 비교 방식 | 단순 CASE는 =, 검색 CASE는 모든 조건 | 같은지만 |
| NULL과 NULL | 같지 않아요 (UNKNOWN) | 같다고 봐요 |
| 맞는 것이 없고 기본값도 없을 때 | NULL | NULL |

## 자주 헷갈리는 점: NULL을 비교하는 방식이 달라요 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| `CASE 커미션 WHEN NULL`로 NULL인 행을 찾아요 | 안에서 `커미션 = NULL`을 비교하는데, NULL과의 비교는 UNKNOWN이라서 어떤 행에서도 맞지 않아요 |
| DECODE도 NULL끼리는 같지 않다고 봐요 | DECODE는 예외로 NULL과 NULL을 같은 값으로 처리해요 |
| ELSE를 빼면 0이나 빈칸이 나와요 | 값이 없다는 뜻의 NULL이 나와요 |
| CASE의 THEN과 ELSE에 문자와 숫자를 섞어도 돼요 | 결과 타입이 다르면 ORA-00932(결과의 타입이 서로 다름) 오류가 나요 |
| DECODE의 결과는 행마다 타입이 달라요 | 첫 번째 결과의 타입에 맞춰 나머지를 바꿔요 |
| DECODE는 SQL 표준이라 SQL Server에서도 써요 | Oracle에만 있어요. 어디서나 쓰려면 CASE를 써요 |

같은 사원 8명에게 세 식을 한꺼번에 써 보면 차이가 뚜렷해요.

{NULL_MATCH_COMPARISON_EXAMPLE.markdown}

단순 CASE의 WHEN NULL은 커미션이 NULL인 네 명도 '있음'으로 보내요. 검색 CASE의 IS NULL과 DECODE만 네 명을 정확히 '없음'으로 바꿔요.

부서번호가 NULL인 윤서연에게서도 같은 차이가 나요. 생김새가 거의 같은 두 식인데 단순 CASE는 ELSE로 가고, DECODE는 NULL끼리 같다고 봐요.

```sql
SELECT 이름, CASE 부서번호 WHEN 10 THEN '기획' WHEN NULL THEN '미배정' ELSE '기타' END, DECODE(부서번호, 10, '기획', NULL, '미배정', '기타') FROM 사원 WHERE 사번 = 1008;
-- 윤서연에게 단순 CASE는 기타를, DECODE는 미배정을 돌려줘요
-- 오류: THEN은 문자이고 ELSE는 숫자예요 (ORA-00932, 결과의 타입이 서로 다름)
SELECT CASE 부서번호 WHEN 10 THEN '기획' ELSE 부서번호 END FROM 사원;
```

같은 섞기를 DECODE로 하면 오류 대신 타입이 맞춰져요. 첫 번째 결과 '미배정'이 문자라서, 기본값 자리의 숫자 부서번호 10도 문자 '10'으로 나와요.

{DECODE_RESULT_TYPE_EXAMPLE.markdown}

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 단순 CASE로도 `WHEN >= 3000` 같은 크기 비교를 쓸 수 있어요 | X | 단순 CASE는 같은지만 비교해서, 크기 비교는 검색 CASE로 써요 |
| DECODE(커미션, NULL, '없음', '있음')은 커미션이 0인 박서준에게 '없음'을 돌려줘요 | X | 0은 NULL이 아니라서 기본값 '있음'이 나와요 |

## 꼭 외울 것: NULL 비교와 결과 타입 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| CASE가 고르는 WHEN | 위에서부터 처음 맞는 하나, 그 뒤는 보지 않아요 |
| 맞는 WHEN도 ELSE도 없으면 | NULL |
| 단순 CASE와 검색 CASE | 단순은 같은지(=)만, 검색은 크기, 범위, IS NULL까지 |
| 단순 CASE의 WHEN NULL | 어떤 행에도 맞지 않아요 (NULL과의 = 비교는 UNKNOWN) |
| DECODE의 NULL 비교 | NULL과 NULL을 같은 값으로 봐요 |
| DECODE의 기본값 | 짝을 짓고 남는 마지막 인자, 없으면 NULL |
| 결과 타입이 섞이면 | CASE는 ORA-00932(타입이 다름) 오류, DECODE는 첫 결과 타입으로 맞춤 |
| 쓸 수 있는 DBMS | CASE는 표준이라 SQL Server도, DECODE는 Oracle 전용 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

예시 표에 CASE나 DECODE를 쓴 SQL을 주고 결과를 고르는 문제가 가장 많아요. NULL이 든 행부터 찾아서, 단순 CASE의 WHEN NULL이면 ELSE로, DECODE의 NULL 비교면 그 결과로 가는지 따져 봐요.

| 나오는 모양 | 푸는 법 |
|---|---|
| 범위 조건 순서를 바꾼 검색 CASE | 위에서 처음 맞는 WHEN에서 멈춰요 |
| ELSE를 뺀 CASE | 맞는 것이 없으면 NULL |
| DECODE 설명 고르기 | Oracle 전용이고, NULL끼리 같다고 봐요 |""",
    "checkQuestions": [
        question(1, "CASE 식에서 어떤 WHEN 조건에도 맞지 않고 ELSE도 없으면 결과는 무엇인가요?", "definition",
                 "맞는 조건이 없고 ELSE도 없으면 CASE는 NULL을 돌려줘요. 0이나 오류가 나오지 않아요.",
                 [choice("A", "0", rationale="0은 값이고, 맞는 조건이 없으면 값이 없다는 뜻의 NULL이 나와요."),
                  choice("B", "NULL", True, "ELSE를 생략하면 맞는 조건이 없을 때 NULL이 돼요."),
                  choice("C", "오류가 난다", rationale="ELSE는 생략할 수 있어서 오류가 나지 않아요."),
                  choice("D", "첫 번째 THEN의 값", rationale="조건에 맞지 않은 WHEN의 THEN 값은 쓰지 않아요.")]),
        question(2, "최유나(사번 1004)의 급여는 3200이에요. 다음 SQL의 결과는 무엇인가요?", "first-match",
                 "CASE는 위에서부터 처음 맞는 WHEN 하나만 골라요. 3200은 첫 조건인 2500 이상에서 이미 맞으므로 '중'이 나와요.",
                 [choice("A", "상", rationale="두 번째 WHEN에 도달하기 전에 첫 WHEN에서 멈춰요."),
                  choice("B", "하", rationale="첫 WHEN이 맞으므로 ELSE까지 가지 않아요."),
                  choice("C", "중", True, "처음 맞는 WHEN이 급여 >= 2500이에요."),
                  choice("D", "중과 상 두 값", rationale="CASE는 언제나 값 하나만 돌려줘요.")],
                 stem_sql="SELECT CASE WHEN 급여 >= 2500 THEN '중' WHEN 급여 >= 3000 THEN '상' ELSE '하' END FROM 사원 WHERE 사번 = 1004;"),
        question(3, "윤서연(사번 1008)은 부서번호가 NULL이에요. 다음 SQL의 결과는 무엇인가요?", "confusing",
                 "단순 CASE의 WHEN NULL은 부서번호 = NULL을 비교하므로 UNKNOWN이 되어 맞지 않아요. 그래서 ELSE의 '기타'가 나와요.",
                 [choice("A", "미배정", rationale="DECODE라면 맞지만, 단순 CASE의 WHEN NULL은 맞지 않아요."),
                  choice("B", "NULL", rationale="ELSE가 있으므로 NULL이 아니라 ELSE 값이 나와요."),
                  choice("C", "기획", rationale="부서번호가 10이 아니에요."),
                  choice("D", "기타", True, "어떤 WHEN도 맞지 않아 ELSE로 가요.")],
                 stem_sql="SELECT CASE 부서번호 WHEN 10 THEN '기획' WHEN NULL THEN '미배정' ELSE '기타' END FROM 사원 WHERE 사번 = 1008;"),
        question(4, "윤서연(사번 1008)은 부서번호가 NULL이에요. 다음 SQL의 결과는 무엇인가요?", "confusing",
                 "DECODE는 NULL과 NULL을 같다고 봐요. 그래서 비교값 NULL과 맞아 '미배정'이 나와요.",
                 [choice("A", "미배정", True, "DECODE는 NULL끼리 같다고 처리해요."),
                  choice("B", "기타", rationale="단순 CASE의 결과이고, DECODE는 NULL 비교가 맞아요."),
                  choice("C", "NULL", rationale="비교값 NULL과 맞았으므로 그 결과인 '미배정'이 나와요."),
                  choice("D", "오류가 난다", rationale="DECODE의 비교값에 NULL을 써도 오류가 나지 않아요.")],
                 stem_sql="SELECT DECODE(부서번호, 10, '기획', NULL, '미배정', '기타') FROM 사원 WHERE 사번 = 1008;"),
        question(5, "아래 사원 표에서 커미션이 NULL인 네 명에게만 '없음'을, 나머지 네 명에게 '있음'을 붙이는 식은 무엇인가요?\n\n"
                 + EMPLOYEE_COMMISSION_TABLE, "confusing",
                 "DECODE는 NULL끼리 같다고 보므로 커미션이 NULL인 네 명만 '없음'이 돼요. 단순 CASE의 WHEN NULL과 = NULL 비교는 어떤 행에서도 맞지 않아요.",
                 [choice("A", "CASE 커미션 WHEN NULL THEN '없음' ELSE '있음' END", rationale="WHEN NULL이 맞지 않아 8명 모두 '있음'이 돼요."),
                  choice("B", "CASE WHEN 커미션 = NULL THEN '없음' ELSE '있음' END", rationale="= NULL은 UNKNOWN이라 8명 모두 '있음'이 돼요."),
                  choice("C", "DECODE(커미션, NULL, '없음', '있음')", True, "NULL인 네 명만 '없음'이 돼요."),
                  choice("D", "DECODE(커미션, 0, '없음', '있음')", rationale="커미션이 0인 박서준만 '없음'이 되고 NULL인 네 명은 '있음'이 돼요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 예시
        SIMPLE_CASE_EXAMPLE.check,
        SEARCHED_CASE_EXAMPLE.check,
        SWAPPED_ORDER_CASE_EXAMPLE.check,
        DECODE_EXAMPLE.check,
        sql_check("SELECT 이름, DECODE(부서번호, 10, '기획', 20, '개발') FROM 사원 WHERE 사번 = 1004", [["최유나", None]]),
        NULL_MATCH_COMPARISON_EXAMPLE.check,
        sql_check("SELECT 이름, CASE 부서번호 WHEN 10 THEN '기획' WHEN NULL THEN '미배정' ELSE '기타' END, DECODE(부서번호, 10, '기획', NULL, '미배정', '기타') FROM 사원 WHERE 사번 = 1008",
                  [["윤서연", "기타", "미배정"]]),
        sql_error_check("SELECT CASE 부서번호 WHEN 10 THEN '기획' ELSE 부서번호 END FROM 사원", "ORA-00932"),
        DECODE_RESULT_TYPE_EXAMPLE.check,
        # 확인 문제 (stemSql, 보기)
        sql_check("SELECT CASE WHEN 1 = 2 THEN 'A' END FROM DUAL", [[None]]),
        sql_check("SELECT CASE WHEN 급여 >= 2500 THEN '중' WHEN 급여 >= 3000 THEN '상' ELSE '하' END FROM 사원 WHERE 사번 = 1004;", [["중"]]),
        sql_check("SELECT CASE 부서번호 WHEN 10 THEN '기획' WHEN NULL THEN '미배정' ELSE '기타' END FROM 사원 WHERE 사번 = 1008;", [["기타"]]),
        sql_check("SELECT DECODE(부서번호, 10, '기획', NULL, '미배정', '기타') FROM 사원 WHERE 사번 = 1008;", [["미배정"]]),
        sql_check("SELECT 이름, CASE 커미션 WHEN NULL THEN '없음' ELSE '있음' END, CASE WHEN 커미션 = NULL THEN '없음' ELSE '있음' END, DECODE(커미션, NULL, '없음', '있음'), DECODE(커미션, 0, '없음', '있음') FROM 사원 ORDER BY 사번",
                  [["김민수", "있음", "있음", "없음", "있음"], ["이지은", "있음", "있음", "있음", "있음"],
                   ["박서준", "있음", "있음", "있음", "없음"], ["최유나", "있음", "있음", "없음", "있음"],
                   ["정하늘", "있음", "있음", "없음", "있음"], ["한도윤", "있음", "있음", "있음", "있음"],
                   ["오지민", "있음", "있음", "있음", "있음"], ["윤서연", "있음", "있음", "없음", "있음"]],
                  is_ordered=True),
    ],
}
