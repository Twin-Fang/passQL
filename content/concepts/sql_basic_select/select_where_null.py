"""개념: WHERE 절과 NULL (2단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check
from concept_dataset import to_employee_table_md

EMPLOYEE_COMMISSION_TABLE = to_employee_table_md("사번", "이름", "급여", "커미션", "부서번호")

CONCEPT = {
    "tagKey": "select-where-null",
    "topicCode": "sql_basic_select",
    "sortOrder": 5,
    "title": "WHERE 절과 NULL",
    "summary": "NULL과 비교하면 참도 거짓도 아니어서, IS NULL로만 찾을 수 있어요",
    "coreMd": (
        "- NULL은 값이 없거나 아직 모른다는 표시라서, 숫자 0이나 빈칸 문자와는 달라요.\n"
        "- NULL과 무엇을 비교해도(=, <>, >) 결과는 참도 거짓도 아닌 UNKNOWN이 되고, WHERE 절은 참인 행만 남기므로 그 행은 빠져요.\n"
        "- 그래서 NULL을 찾을 때는 `= NULL`이 아니라 `IS NULL`을, NULL이 아닌 행을 찾을 때는 `IS NOT NULL`을 써요.\n"
        "- NULL이 섞인 계산은 결과도 NULL이 되고, Oracle에서는 빈 문자열(`''`)도 NULL로 처리해요."
    ),
    "detailMd": f"""## 왜 헷갈리나요 {{#why}}

SQL을 처음 배우면 "커미션이 없는 사원"을 찾으려고 `WHERE 커미션 = NULL`이라고 쓰기 쉬운데, 이렇게 쓰면 오류도 나지 않고 결과가 0행으로 나와요. 오류가 나지 않으니 무엇이 잘못됐는지 알기 어렵고, 그래서 시험에서도 이 부분을 자주 물어요. 아래에서는 모든 예시를 이 사원 표 하나로 설명할게요.

{EMPLOYEE_COMMISSION_TABLE}

## NULL은 값이 아니에요 {{#definition}}

NULL은 "값이 없음" 또는 "아직 모름"을 뜻하는 표시예요. 김민수의 커미션이 NULL이라는 것은 커미션이 0원이라는 뜻이 아니라, 커미션이 정해지지 않았거나 알 수 없다는 뜻이에요. 그래서 박서준처럼 커미션이 0인 사원과 김민수처럼 커미션이 NULL인 사원은 서로 다른 상태예요.

## 비교하면 UNKNOWN이 돼요 {{#unknown}}

모르는 값과 무엇을 비교해도 맞는지 틀린지 알 수 없어요. 그래서 SQL은 NULL이 들어간 비교의 결과를 참(TRUE)도 거짓(FALSE)도 아닌 **UNKNOWN**으로 처리해요. 그런데 WHERE 절은 조건이 참인 행만 남기기 때문에, UNKNOWN이 나온 행은 결과에서 빠져요.

```sql
SELECT 이름 FROM 사원 WHERE 커미션 = NULL;      -- 0행 (모든 행이 UNKNOWN)
SELECT 이름 FROM 사원 WHERE 커미션 IS NULL;     -- 김민수, 최유나, 정하늘, 윤서연
SELECT 이름 FROM 사원 WHERE 커미션 IS NOT NULL; -- 이지은, 박서준, 한도윤, 오지민
```

NULL 자체를 확인하는 전용 연산자가 `IS NULL`과 `IS NOT NULL`이고, 이 둘은 UNKNOWN이 아니라 참이나 거짓으로 답해요.

## 자주 헷갈리는 점 {{#confusing}}

**같지 않다(`<>`)로 걸러도 NULL은 따라 나오지 않아요.** "커미션이 300이 아닌 사원"을 `WHERE 커미션 <> 300`으로 찾으면 박서준, 한도윤, 오지민 세 명만 나와요. 커미션이 NULL인 네 명은 커미션이 300이 아닌데도, 비교 결과가 UNKNOWN이라서 빠지기 때문이에요. NULL인 사원까지 포함하려면 `WHERE 커미션 <> 300 OR 커미션 IS NULL`처럼 따로 적어야 해요.

**NOT IN 목록에 NULL이 하나라도 있으면 결과가 0행이 돼요.** `WHERE 부서번호 NOT IN (10, NULL)`은 `부서번호 <> 10 AND 부서번호 <> NULL`과 같은데, 뒤쪽 비교가 항상 UNKNOWN이라서 전체가 참이 될 수 없어요. 반대로 `IN (10, NULL)`은 `= 10 OR = NULL`이라서, 부서번호가 10인 김민수 한 명은 정상적으로 나와요.

**NULL이 섞인 계산은 결과도 NULL이에요.** `급여 + 커미션`을 계산하면 이지은과 박서준은 2800이 나오지만, 김민수는 3000이 아니라 NULL이 나와요. 커미션이 NULL인 나머지 세 명도 마찬가지예요. 커미션이 없을 때 0으로 보고 더하려면 `급여 + NVL(커미션, 0)`처럼 NULL을 다른 값으로 바꿔 주는 함수를 써야 하는데, 이 함수들은 SQL 함수 단원에서 자세히 다뤄요.

**AND와 OR에 UNKNOWN이 섞이면 결과가 달라져요.** 거짓 AND UNKNOWN은 어느 쪽이든 거짓이라서 거짓이고, 참 OR UNKNOWN은 어느 쪽이든 참이라서 참이에요. 하지만 참 AND UNKNOWN, 거짓 OR UNKNOWN, NOT UNKNOWN은 여전히 UNKNOWN이에요. `NULL = NULL`도 참이 아니라 UNKNOWN이라는 점을 함께 기억해 두면 좋아요.

**Oracle에서는 빈 문자열이 곧 NULL이에요.** Oracle은 빈 문자열 `''`를 NULL로 저장하기 때문에 `WHERE 이름 = ''`는 아무 행도 돌려주지 않아요. SQL Server처럼 빈 문자열과 NULL을 구분하는 데이터베이스도 있어서, 시험 보기에서 이 차이를 묻기도 해요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

예시 표를 주고 `<>`나 `NOT IN`을 쓴 SQL의 결과 행 수를 묻는 문제가 가장 많아요. 이때는 조건 칸에 NULL이 있는 행부터 찾아서 결과에서 빼고 세면 실수가 줄어요. 그 밖에 NULL을 찾는 올바른 조건을 고르는 문제, NULL이 섞인 계산 결과를 묻는 문제, 참·거짓·UNKNOWN의 AND와 OR 결과를 묻는 문제가 자주 나와요.""",
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
        sql_check("SELECT 이름 FROM 사원 WHERE 이름 = ''", []),
    ],
}
