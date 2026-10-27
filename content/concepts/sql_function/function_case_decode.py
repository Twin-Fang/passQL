"""개념: CASE와 DECODE (4단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import to_employee_table_md

EMPLOYEE_COMMISSION_TABLE = to_employee_table_md("사번", "이름", "급여", "커미션", "부서번호")

CONCEPT = {
    "tagKey": "function-case-decode",
    "topicCode": "sql_function",
    "sortOrder": 5,
    "title": "CASE와 DECODE",
    "summary": "조건에 따라 다른 값을 고르는 식이고, 둘은 NULL을 비교하는 방식이 달라요",
    "coreMd": (
        "- CASE는 위에서부터 WHEN을 확인해 처음 맞는 하나의 THEN 값을 돌려주고, 맞는 것이 없는데 ELSE도 없으면 NULL을 돌려줘요.\n"
        "- 단순 CASE(`CASE 열 WHEN 값`)는 같은지(=)만 비교하므로 `WHEN NULL`은 절대 맞지 않고, NULL은 검색 CASE의 `WHEN 열 IS NULL`로 찾아요.\n"
        "- `DECODE(값, 비교1, 결과1, ..., 기본값)`는 단순 CASE와 같은 일을 하지만 NULL과 NULL을 같다고 봐서, NULL인 행을 찾아내요.\n"
        "- DECODE는 Oracle에만 있는 함수이고, CASE는 SQL 표준이라 SQL Server에서도 써요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

사원 표의 부서번호 10, 20, 30은 숫자라서 읽기 불편하니, 결과를 보여 줄 때 "기획", "개발"처럼 이름으로 바꾸고 싶을 때가 있어요. 급여에 따라 상·중·하 등급을 붙이거나, 커미션이 없는 사원에게 "없음"이라고 적고 싶을 때도 있어요. 이렇게 조건에 따라 다른 값을 고르는 일은 프로그래밍의 IF 문과 비슷한데, SQL에서는 CASE 식과 DECODE 함수가 이 일을 해요. 아래 예시는 모두 이 사원 표로 설명할게요.

{EMPLOYEE_COMMISSION_TABLE}

## CASE 식의 두 가지 모양 {{#definition}}

CASE 식은 CASE로 시작해 END로 끝나고, 그 사이에 'WHEN 조건 THEN 결과'를 여러 개 적어요. 조건에 맞는 WHEN을 찾으면 그 THEN 뒤의 값 하나를 돌려주고, 맞는 것이 하나도 없으면 ELSE 뒤의 값을 돌려줘요. ELSE를 생략했는데 맞는 조건도 없으면 NULL을 돌려줘요.

CASE 식은 두 가지 모양으로 써요. 단순 CASE는 CASE 바로 뒤에 비교할 열을 한 번 적고, WHEN 뒤에는 그 열과 같은지 볼 값만 적어요. 검색 CASE는 CASE 뒤를 비워 두고, WHEN 뒤에 `급여 >= 3000`처럼 조건식을 통째로 적어요.

```sql
-- 문법: 위는 단순 CASE, 아래는 검색 CASE예요
CASE 열 WHEN 값1 THEN 결과1 WHEN 값2 THEN 결과2 ELSE 기본값 END
CASE WHEN 조건1 THEN 결과1 WHEN 조건2 THEN 결과2 ELSE 기본값 END
```

단순 CASE는 같은지(=)만 비교할 수 있어요. 크기 비교, 범위, IS NULL처럼 같음이 아닌 조건은 검색 CASE로만 쓸 수 있어요.

## 예시로 보는 CASE {{#example}}

부서번호를 이름으로 바꾸는 일은 같은지만 보면 되므로 단순 CASE로 쓰고, 급여 등급은 크기를 비교해야 하므로 검색 CASE로 써요.

```sql
SELECT 이름, 부서번호, CASE 부서번호 WHEN 10 THEN '기획' WHEN 20 THEN '개발' ELSE '기타' END FROM 사원 WHERE 사번 IN (1001, 1002, 1004, 1008);
SELECT 이름, 급여, CASE WHEN 급여 >= 3000 THEN '상' WHEN 급여 >= 2500 THEN '중' ELSE '하' END FROM 사원 WHERE 사번 IN (1001, 1002, 1007);
```

| 이름 | 부서번호 | 단순 CASE 결과 |
|---|---|---|
| 김민수 | 10 | 기획 |
| 이지은 | 20 | 개발 |
| 최유나 | 30 | 기타 |
| 윤서연 | NULL | 기타 |

| 이름 | 급여 | 검색 CASE 결과 |
|---|---|---|
| 김민수 | 3000 | 상 |
| 이지은 | 2500 | 중 |
| 오지민 | 2200 | 하 |

부서가 없는 윤서연은 10과도 20과도 같지 않아서 ELSE의 '기타'가 나와요.

## 위에서부터 처음 맞는 하나만 골라요 {{#first-match}}

CASE는 WHEN을 위에서부터 차례로 확인하다가 처음 맞는 하나에서 멈추고, 뒤에 더 알맞은 조건이 있어도 보지 않아요. 그래서 범위가 겹치는 조건은 좁은 범위부터 적어야 해요. 위의 급여 등급에서 두 WHEN의 순서를 바꾸면, 급여가 3000 이상인 사원도 첫 조건인 `급여 >= 2500`에서 이미 맞아 버려 '상'이 하나도 나오지 않아요.

```sql
SELECT 이름, 급여, CASE WHEN 급여 >= 2500 THEN '중' WHEN 급여 >= 3000 THEN '상' ELSE '하' END FROM 사원 WHERE 사번 IN (1001, 1004);
```

| 이름 | 급여 | 결과 |
|---|---|---|
| 김민수 | 3000 | 중 |
| 최유나 | 3200 | 중 |

## DECODE {{#decode}}

`DECODE(값, 비교1, 결과1, 비교2, 결과2, ..., 기본값)`는 값이 비교1과 같으면 결과1을, 비교2와 같으면 결과2를 돌려줘요. 어느 것과도 같지 않으면 맨 끝의 기본값을 돌려주고, 기본값을 생략하면 NULL을 돌려줘요. 비교값과 결과가 짝을 이루고, 짝이 없이 남는 마지막 하나가 기본값이라고 보면 읽기 쉬워요.

DECODE는 단순 CASE와 비슷한 일을 하는 Oracle 전용 함수예요. SQL Server에는 DECODE가 없어서 같은 일을 CASE로 해요.

```sql
SELECT 이름, DECODE(부서번호, 10, '기획', 20, '개발', '기타') FROM 사원 WHERE 사번 IN (1001, 1002, 1004);
SELECT 이름, DECODE(부서번호, 10, '기획', 20, '개발') FROM 사원 WHERE 사번 = 1004;   -- 기본값을 빼서 최유나는 NULL이 나와요
```

첫 SQL의 결과는 아래와 같아요. 30번 부서인 최유나는 10과도 20과도 같지 않아서 기본값 '기타'가 나와요.

| 이름 | DECODE 결과 |
|---|---|
| 김민수 | 기획 |
| 이지은 | 개발 |
| 최유나 | 기타 |

## 자주 헷갈리는 점 {{#confusing}}

**단순 CASE의 WHEN NULL은 절대 맞지 않아요.** `CASE 커미션 WHEN NULL THEN '없음' ELSE '있음' END`는 안에서 `커미션 = NULL`을 비교하는데, WHEN은 비교 결과가 참일 때만 맞는데, NULL과의 비교는 참도 거짓도 아닌 UNKNOWN이라서 이 WHEN은 어떤 행에서도 맞지 않아요. 그래서 커미션이 NULL인 사원까지 8명 모두 '있음'이 돼요. NULL을 찾으려면 검색 CASE로 `CASE WHEN 커미션 IS NULL THEN '없음' ELSE '있음' END`처럼 써야 해요.

**DECODE는 NULL과 NULL을 같다고 봐요.** SQL에서 NULL끼리의 비교는 원래 UNKNOWN이지만, DECODE는 예외로 NULL과 NULL을 같은 값으로 처리해요. 그래서 `DECODE(커미션, NULL, '없음', '있음')`은 커미션이 NULL인 네 명을 정확히 '없음'으로 바꿔요. 세 가지 식을 사원 8명에게 한꺼번에 써 보면 차이가 뚜렷해요.

```sql
SELECT 사번, 이름, 커미션, CASE 커미션 WHEN NULL THEN '없음' ELSE '있음' END, CASE WHEN 커미션 IS NULL THEN '없음' ELSE '있음' END, DECODE(커미션, NULL, '없음', '있음') FROM 사원 ORDER BY 사번;
```

| 사번 | 이름 | 커미션 | 단순 CASE WHEN NULL | 검색 CASE IS NULL | DECODE NULL |
|---|---|---|---|---|---|
| 1001 | 김민수 | NULL | 있음 | 없음 | 없음 |
| 1002 | 이지은 | 300 | 있음 | 있음 | 있음 |
| 1003 | 박서준 | 0 | 있음 | 있음 | 있음 |
| 1004 | 최유나 | NULL | 있음 | 없음 | 없음 |
| 1005 | 정하늘 | NULL | 있음 | 없음 | 없음 |
| 1006 | 한도윤 | 500 | 있음 | 있음 | 있음 |
| 1007 | 오지민 | 200 | 있음 | 있음 | 있음 |
| 1008 | 윤서연 | NULL | 있음 | 없음 | 없음 |

같은 차이는 부서번호가 NULL인 윤서연에게서도 나타나요. 생김새가 거의 같은 두 식인데, 단순 CASE는 WHEN NULL을 건너뛰고 ELSE로 가서 '기타'가 되고, DECODE는 NULL끼리 같다고 보아 '미배정'이 돼요.

```sql
SELECT 이름, CASE 부서번호 WHEN 10 THEN '기획' WHEN NULL THEN '미배정' ELSE '기타' END, DECODE(부서번호, 10, '기획', NULL, '미배정', '기타') FROM 사원 WHERE 사번 = 1008;
-- 윤서연에게 단순 CASE는 기타를, DECODE는 미배정을 돌려줘요
```

**ELSE나 기본값을 빼면 결과는 NULL이에요.** 0이나 빈칸이 나온다고 생각하기 쉬운데, 맞는 조건이 없으면 값이 없다는 뜻의 NULL이 나와요. 위 예시에서 기본값을 뺀 DECODE가 30번 부서 최유나에게 NULL을 돌려준 것과 같아요.

**CASE는 결과의 타입이 모두 같아야 해요.** THEN과 ELSE 뒤에 문자와 숫자를 섞어 쓰면 CASE는 오류를 내요. DECODE는 첫 번째 결과의 타입에 맞춰 나머지 결과를 바꿔요. 아래 DECODE에서 첫 번째 결과는 문자 '미배정'이라서, 기본값 자리의 숫자 부서번호 10도 문자 '10'으로 바뀌어 나와요.

```sql
-- 오류: THEN은 문자이고 ELSE는 숫자예요 (ORA-00932, 결과의 타입이 서로 다름)
SELECT CASE 부서번호 WHEN 10 THEN '기획' ELSE 부서번호 END FROM 사원;
SELECT 이름, DECODE(부서번호, NULL, '미배정', 부서번호) FROM 사원 WHERE 사번 IN (1001, 1008);
```

| 이름 | DECODE 결과 | 결과의 타입 |
|---|---|---|
| 김민수 | 10 | 문자 |
| 윤서연 | 미배정 | 문자 |

**DECODE는 Oracle에서만 써요.** 보기에 "DECODE는 SQL 표준 함수이다"나 "SQL Server에서도 DECODE를 쓸 수 있다"가 나오면 틀린 설명이에요. 어느 데이터베이스에서나 쓰려면, 여러 데이터베이스가 함께 따르는 SQL 표준 문법인 CASE를 써요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

예시 표를 주고 CASE나 DECODE를 쓴 SQL의 결과를 고르는 문제가 가장 많아요. 이때는 NULL이 들어 있는 행부터 찾아서, 단순 CASE의 WHEN NULL이면 ELSE로, DECODE의 NULL 비교면 그 결과로 가는지 따져 보면 돼요. 범위 조건의 순서를 바꾼 검색 CASE, ELSE를 뺀 CASE의 결과도 자주 나오고, DECODE가 Oracle 전용이라는 설명도 보기로 나와요.""",
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
        sql_check("SELECT 이름, 부서번호, CASE 부서번호 WHEN 10 THEN '기획' WHEN 20 THEN '개발' ELSE '기타' END FROM 사원 WHERE 사번 IN (1001, 1002, 1004, 1008)",
                  [["김민수", 10, "기획"], ["이지은", 20, "개발"], ["최유나", 30, "기타"], ["윤서연", None, "기타"]]),
        sql_check("SELECT 이름, 급여, CASE WHEN 급여 >= 3000 THEN '상' WHEN 급여 >= 2500 THEN '중' ELSE '하' END FROM 사원 WHERE 사번 IN (1001, 1002, 1007)",
                  [["김민수", 3000, "상"], ["이지은", 2500, "중"], ["오지민", 2200, "하"]]),
        sql_check("SELECT 이름, 급여, CASE WHEN 급여 >= 2500 THEN '중' WHEN 급여 >= 3000 THEN '상' ELSE '하' END FROM 사원 WHERE 사번 IN (1001, 1004)",
                  [["김민수", 3000, "중"], ["최유나", 3200, "중"]]),
        sql_check("SELECT 이름, DECODE(부서번호, 10, '기획', 20, '개발', '기타') FROM 사원 WHERE 사번 IN (1001, 1002, 1004)",
                  [["김민수", "기획"], ["이지은", "개발"], ["최유나", "기타"]]),
        sql_check("SELECT 이름, DECODE(부서번호, 10, '기획', 20, '개발') FROM 사원 WHERE 사번 = 1004", [["최유나", None]]),
        sql_check("SELECT 사번, 이름, 커미션, CASE 커미션 WHEN NULL THEN '없음' ELSE '있음' END, CASE WHEN 커미션 IS NULL THEN '없음' ELSE '있음' END, DECODE(커미션, NULL, '없음', '있음') FROM 사원 ORDER BY 사번",
                  [[1001, "김민수", None, "있음", "없음", "없음"], [1002, "이지은", 300, "있음", "있음", "있음"],
                   [1003, "박서준", 0, "있음", "있음", "있음"], [1004, "최유나", None, "있음", "없음", "없음"],
                   [1005, "정하늘", None, "있음", "없음", "없음"], [1006, "한도윤", 500, "있음", "있음", "있음"],
                   [1007, "오지민", 200, "있음", "있음", "있음"], [1008, "윤서연", None, "있음", "없음", "없음"]],
                  is_ordered=True),
        sql_check("SELECT 이름, CASE 부서번호 WHEN 10 THEN '기획' WHEN NULL THEN '미배정' ELSE '기타' END, DECODE(부서번호, 10, '기획', NULL, '미배정', '기타') FROM 사원 WHERE 사번 = 1008",
                  [["윤서연", "기타", "미배정"]]),
        sql_error_check("SELECT CASE 부서번호 WHEN 10 THEN '기획' ELSE 부서번호 END FROM 사원", "ORA-00932"),
        sql_check("SELECT 이름, DECODE(부서번호, NULL, '미배정', 부서번호) FROM 사원 WHERE 사번 IN (1001, 1008)",
                  [["김민수", "10"], ["윤서연", "미배정"]]),
        # 확인 문제 (stemSql·보기)
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
