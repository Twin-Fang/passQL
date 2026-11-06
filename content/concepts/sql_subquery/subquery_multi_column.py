"""개념: 다중 컬럼 서브쿼리 (6단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import DEPARTMENT_TABLE_MD, to_employee_table_md

# 이 개념의 계산에 쓰는 열 전부 (직급·급여·부서번호)
EMPLOYEE_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
DEPARTMENT_MAX_EXAMPLE = sql_example(
    """SELECT 부서번호, MAX(급여)
FROM 사원
GROUP BY 부서번호;""",
    ("부서번호", "MAX(급여)"), [[10, 3000], [20, 2800], [30, 3200], [None, 2000]], is_ordered=False)
PAIR_IN_EXAMPLE = sql_example(
    """SELECT 이름, 부서번호, 급여
FROM 사원
WHERE (부서번호, 급여) IN (SELECT 부서번호, MAX(급여)
                          FROM 사원
                          GROUP BY 부서번호);""",
    ("이름", "부서번호", "급여"), [["김민수", 10, 3000], ["박서준", 20, 2800], ["최유나", 30, 3200]], is_ordered=False)
PAIR_EQUAL_EXAMPLE = sql_example(
    """SELECT 이름
FROM 사원
WHERE (부서번호, 급여) = (SELECT 부서번호, 급여 FROM 사원 WHERE 사번 = 1002);""",
    ("이름",), [["이지은"], ["정하늘"]], is_ordered=False)
PAIR_LIST_EXAMPLE = sql_example(
    """SELECT 이름
FROM 사원
WHERE (부서번호, 급여) IN ((20, 2500), (30, 2700));""",
    ("이름",), [["이지은"], ["정하늘"], ["한도윤"]], is_ordered=False)
# 짝 비교 <-> 열별 비교 (박서준 20 대리, 오지민 30 사원)
PAIR_POSITION_EXAMPLE = sql_example(
    """SELECT 이름 FROM 사원
WHERE (부서번호, 직급) IN (SELECT 부서번호, 직급 FROM 사원 WHERE 사번 IN (1003, 1007));""",
    ("이름",), [["박서준"], ["오지민"]], is_ordered=False)
SEPARATE_COLUMN_EXAMPLE = sql_example(
    """SELECT 이름 FROM 사원
WHERE 부서번호 IN (SELECT 부서번호 FROM 사원 WHERE 사번 IN (1003, 1007))
  AND 직급 IN (SELECT 직급 FROM 사원 WHERE 사번 IN (1003, 1007));""",
    ("이름",), [["박서준"], ["정하늘"], ["한도윤"], ["오지민"]], is_ordered=False)

CONCEPT = {
    "tagKey": "subquery-multi-column",
    "topicCode": "sql_subquery",
    "sortOrder": 2,
    "title": "다중 컬럼 서브쿼리",
    "summary": "열 두 개 이상을 괄호로 묶어 한 번에 비교하는 서브쿼리예요",
    "coreMd": (
        "- 다중 컬럼 서브쿼리는 열을 두 개 이상 돌려주고, 메인 쿼리는 `(부서번호, 급여)`처럼 묶어서 **짝으로** 비교해요.\n"
        "- 짝 비교는 같은 행의 값끼리 모두 맞아야 하고, 열마다 IN을 따로 쓰면 **섞인 조합**까지 통과해요.\n"
        "- 짝은 **위치로** 맞춰지므로 열의 개수와 순서가 서브쿼리 SELECT 목록과 같아야 해요.\n"
        "- 짝 안에 NULL이 있으면 그 짝은 맞지 않아요.\n"
        "- Oracle은 이 문법을 지원하지만 SQL Server는 **지원하지 않아요**."
    ),
    "detailMd": f"""## 자기 부서의 최고 급여 — 급여만 비교하면 생기는 구멍 {{#why}}

부서마다 급여를 가장 많이 받는 사원을 찾을 때 급여만 비교하면 "어느 부서든 최고 급여와 같은가"를 묻게 돼요. 영업부 사원이 개발부 최고 급여 2800을 받는다면 영업부 최고가 아닌데도 결과에 끼어드니, 부서번호와 급여를 함께 비교해야 해요.

| 용어 | 뜻 |
|---|---|
| `MAX(급여)` | 가장 큰 급여를 구하는 함수예요. 그룹 함수 단원에서 자세히 다뤄요 |
| `GROUP BY 부서번호` | 부서번호가 같은 사원끼리 묶는 절이에요. MAX와 함께 쓰면 부서별 최고 급여가 나와요 |

이 개념의 예시는 모두 아래 두 표로 계산해요.

{EMPLOYEE_TABLE}

{DEPARTMENT_TABLE_MD}

## 한 줄 정의 — 열을 짝으로 묶어 비교해요 {{#definition}}

| 용어 | 뜻 |
|---|---|
| 다중 컬럼 서브쿼리 (Multi-Column Subquery) | 결과로 열을 두 개 이상 돌려주는 서브쿼리예요. 메인 쿼리도 비교할 열을 괄호로 묶어 적어요 |
| 짝 | 한 행에서 함께 나온 값들을 괄호로 묶은 것이에요. 박서준의 (부서번호, 급여) 짝은 (20, 2800)이에요 |

서브쿼리만 실행하면 (부서번호, 최고 급여) 짝 네 개가 나와요.

{DEPARTMENT_MAX_EXAMPLE.markdown}

메인 쿼리는 사원마다 (부서번호, 급여) 짝을 만들어 이 목록에 같은 짝이 있는지 찾아요.

{PAIR_IN_EXAMPLE.markdown}

이지은의 (20, 2500)은 20번 부서의 짝이 (20, 2800)이라 빠지고, 다른 사원들도 같은 이유로 빠져요.

## 짝 비교의 세 가지 모양 — IN, 등호, 값 나열 {{#forms}}

| 모양 | 오른쪽에 오는 것 | 주의할 점 |
|---|---|---|
| `(열1, 열2) IN (서브쿼리)` | 여러 행의 짝 | 위 예시처럼 짝 목록 중 하나와 맞으면 돼요 |
| `(열1, 열2) = (서브쿼리)` | 한 행의 짝 | 두 행 이상이 오면 ORA-01427(단일행 서브쿼리가 여러 행을 돌려줌) 오류예요 |
| `(열1, 열2) IN ((값, 값), ...)` | 직접 적은 짝 | 서브쿼리 없이 짝을 나열해요 |

이지은(1002)과 부서도 같고 급여도 같은 사원을 찾으면 이지은과 정하늘이 나와요.

{PAIR_EQUAL_EXAMPLE.markdown}

짝 (20, 2500)인 이지은과 정하늘, 짝 (30, 2700)인 한도윤이 나와요.

{PAIR_LIST_EXAMPLE.markdown}

## 자주 헷갈리는 점 — 짝 비교와 열별 비교 {{#confusing}}

같은 입력으로 두 SQL을 비교해 봐요. 박서준(20번, 대리)이나 오지민(30번, 사원)과 부서도 직급도 같은 사원을 찾는 SQL이에요.

{PAIR_POSITION_EXAMPLE.markdown}

{SEPARATE_COLUMN_EXAMPLE.markdown}

짝으로 비교하면 (20, 대리)나 (30, 사원)과 그대로 맞는 두 명만 남아요. 열마다 따로 비교하면 정하늘의 (20, 사원)이나 한도윤의 (30, 대리)처럼 두 사람의 값이 섞인 조합도 통과해서 네 명이 돼요.

| 헷갈리는 말 | 실제로는 |
|---|---|
| 열마다 IN을 따로 써도 짝 비교와 결과가 같아요 | 열별 비교는 다른 행의 값끼리 섞여 맞아도 통과해서 결과가 더 많아질 수 있어요 |
| 열 이름이 같으면 순서를 바꿔 써도 돼요 | 짝은 이름이 아니라 위치로 맞춰져요. 순서를 바꾸면 부서번호를 급여와 비교하게 돼요 |
| 순서를 바꾸면 오류가 나요 | 두 열이 모두 숫자면 오류 없이 (10, 3000)과 (3000, 10)처럼 맞는 짝이 없어서 0행이 나와요 |
| 열 개수가 달라도 앞에서부터 맞춰 비교해요 | 서브쿼리 쪽 열이 많으면 ORA-00913(값이 너무 많음), 적으면 ORA-00947(값이 충분하지 않음) 오류예요 |
| (NULL, 2000) 짝끼리는 서로 같아요 | GROUP BY는 NULL끼리 한 그룹으로 묶지만, 비교에서 NULL = NULL은 UNKNOWN이라 윤서연은 결과에 나오지 않아요 |
| 다중 컬럼 서브쿼리는 SQL Server에서도 쓸 수 있어요 | Oracle만 되고 SQL Server는 지원하지 않아요. SQL Server는 EXISTS 안에 열마다 조건을 적거나 조인으로 바꿔 써요 |

```sql
SELECT 이름 FROM 사원
WHERE (부서번호, 급여) IN (SELECT MAX(급여), 부서번호 FROM 사원 GROUP BY 부서번호);  -- 순서가 바뀌어 0행이 나와요

SELECT 이름 FROM 사원
WHERE (부서번호, 급여) IN (SELECT 부서번호, 급여, 사번 FROM 사원);  -- 오류: 서브쿼리 쪽 열이 하나 더 많아요

SELECT 이름 FROM 사원
WHERE (부서번호, 급여) IN (SELECT 부서번호 FROM 사원);  -- 오류: 서브쿼리 쪽 열이 하나 모자라요
```

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 짝 비교는 짝 안의 값이 하나하나 모두 같아야 참이에요 | O | 값 하나라도 다르거나 UNKNOWN이면 그 짝은 맞지 않아요 |
| 부서번호가 NULL인 윤서연은 부서별 최고 급여 짝 비교에서 결과에 나와요 | X | 짝 안의 NULL 비교가 UNKNOWN이라 빠져요 |
| `(부서번호, 급여) = (서브쿼리)`의 서브쿼리가 두 행을 돌려주면 오류가 나요 | O | 등호는 짝 하나와만 비교할 수 있어요 |

## 꼭 외울 것 — 짝의 위치와 열 개수 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| 다중 컬럼 비교 모양 | (열1, 열2) IN (서브쿼리)처럼 비교할 열을 괄호로 묶어요 |
| 짝 비교와 열별 IN | 짝은 같은 행 값끼리 모두 맞아야, 열별 IN은 섞인 조합도 통과 |
| 짝을 맞추는 기준 | 열 이름이 아니라 위치(순서) |
| 서브쿼리 쪽 열이 많으면 | ORA-00913(값이 너무 많음) 오류 |
| 서브쿼리 쪽 열이 적으면 | ORA-00947(값이 충분하지 않음) 오류 |
| = 뒤 서브쿼리가 두 행 | ORA-01427(여러 행을 돌려줌) 오류, 여러 짝은 IN으로 |
| 짝 안에 NULL이 있으면 | 비교가 UNKNOWN이라 그 짝은 맞지 않아요 |
| SQL Server 지원 | 지원하지 않아 EXISTS나 조인으로 바꿔 써요 |

## 시험에서는 이렇게 나와요 — 짝 목록을 먼저 적기 {{#exam-point}}

부서별 최고 급여처럼 GROUP BY 결과와 짝을 비교하는 SQL의 결과를 묻는 문제가 가장 흔해요. 짝 비교와 열별 비교의 차이, 열 순서를 바꿨을 때의 결과, SQL Server 지원 여부도 보기로 자주 나와요.

| 단계 | 내용 |
|---|---|
| 짝 목록 적기 | 서브쿼리 결과를 (값, 값) 짝으로 적어요. NULL이 든 짝에 표시해 둬요 |
| 위치 맞추기 | 괄호 안 열 순서와 서브쿼리 SELECT 순서가 같은지 봐요 |
| 한 명씩 대 보기 | 사원마다 짝을 만들어 목록에 똑같은 짝이 있는지 확인해요 |""",
    "checkQuestions": [
        question(1, "다중 컬럼 서브쿼리를 가장 알맞게 설명한 것은 무엇인가요?", "definition",
                 "다중 컬럼 서브쿼리는 열 두 개 이상을 돌려주고, 메인 쿼리는 괄호로 묶은 열과 짝으로 비교해요. 여러 행을 돌려주는 것은 다중행 서브쿼리예요.",
                 [choice("A", "결과로 여러 행을 돌려주는 서브쿼리", rationale="행 수로 나눈 다중행 서브쿼리의 설명이에요."),
                  choice("B", "결과로 열 두 개 이상을 돌려주고, 메인 쿼리가 그 열들과 짝으로 비교하는 서브쿼리", True,
                         "다중 컬럼 서브쿼리의 정의예요."),
                  choice("C", "서브쿼리 안에서 메인 쿼리의 열을 참조하는 서브쿼리", rationale="연관 서브쿼리의 설명이에요."),
                  choice("D", "FROM 절에 놓여 표처럼 쓰이는 서브쿼리", rationale="인라인 뷰의 설명이에요.")]),
        question(2, "아래 사원 표에 다음 SQL을 실행한 결과로 알맞은 것은 무엇인가요?\n\n" + EMPLOYEE_TABLE, "definition",
                 "서브쿼리는 (10, 3000), (20, 2800), (30, 3200), (NULL, 2000) 짝을 돌려줘요. 같은 짝을 가진 사원은 김민수, 박서준, 최유나이고, 윤서연은 NULL 비교가 UNKNOWN이라 빠져요.",
                 [choice("A", "김민수, 박서준, 최유나", True, "자기 부서 최고 급여와 짝이 맞는 세 명이에요."),
                  choice("B", "김민수, 박서준, 최유나, 윤서연", rationale="윤서연의 짝 (NULL, 2000)은 NULL 비교가 UNKNOWN이라 맞지 않아요."),
                  choice("C", "최유나", rationale="전체 최고 급여만 구한 결과이고, 이 서브쿼리는 부서마다 최고 급여를 구해요."),
                  choice("D", "오류가 난다", rationale="괄호 안 열 개수와 서브쿼리 열 개수가 같아서 오류가 나지 않아요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE (부서번호, 급여) IN (SELECT 부서번호, MAX(급여) FROM 사원 GROUP BY 부서번호);"),
        question(3, "다음 SQL처럼 서브쿼리 SELECT 목록의 순서를 바꿔 쓰면 어떻게 되나요?", "confusing",
                 "짝은 위치로 맞춰지므로 부서번호를 최고 급여와, 급여를 부서번호와 비교하게 돼요. 둘 다 숫자라 오류는 나지 않고, 맞는 짝이 없어서 0행이 나와요.",
                 [choice("A", "오류가 난다", rationale="열 개수가 같고 둘 다 숫자라서 오류가 나지 않아요."),
                  choice("B", "순서와 상관없이 김민수, 박서준, 최유나가 나온다", rationale="Oracle은 열 이름이 아니라 위치로 짝을 맞춰요."),
                  choice("C", "0행이 나온다", True, "(10, 3000)과 (3000, 10)처럼 맞는 짝이 하나도 없어요."),
                  choice("D", "사원 8명이 모두 나온다", rationale="짝이 맞아야 남는 조건이라 모두 나올 수 없어요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE (부서번호, 급여) IN (SELECT MAX(급여), 부서번호 FROM 사원 GROUP BY 부서번호);"),
        question(4, "아래 사원 표에서 이지은(1002)은 (20, 과장), 한도윤(1006)은 (30, 대리)예요. 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + EMPLOYEE_TABLE, "confusing",
                 "열마다 IN을 따로 쓰면 부서번호가 20이나 30이고 직급이 과장이나 대리이기만 하면 통과해요. 그래서 이지은, 한도윤에 박서준 (20, 대리)까지 세 명이 나와요.",
                 [choice("A", "2행", rationale="짝으로 비교했을 때의 결과이고, 이 SQL은 열을 따로 비교해서 섞인 조합도 통과시켜요."),
                  choice("B", "3행", True, "이지은, 박서준, 한도윤 세 명이 나와요."),
                  choice("C", "4행", rationale="30번 부서에 과장이 없어서 섞인 조합으로 들어오는 사람은 박서준 한 명뿐이에요."),
                  choice("D", "1행", rationale="두 사번 본인도 조건을 통과하므로 한 명보다 많아요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE 부서번호 IN (SELECT 부서번호 FROM 사원 WHERE 사번 IN (1002, 1006)) AND 직급 IN (SELECT 직급 FROM 사원 WHERE 사번 IN (1002, 1006));"),
        question(5, "다중 컬럼 서브쿼리에 대한 설명으로 알맞지 않은 것은 무엇인가요?", "confusing",
                 "여러 열을 괄호로 묶어 서브쿼리와 비교하는 문법은 SQL Server가 지원하지 않아요. SQL Server에서는 EXISTS나 조인으로 바꿔 써야 해요.",
                 [choice("A", "괄호 안 열의 개수는 서브쿼리 SELECT 목록의 열 개수와 같아야 한다", rationale="개수가 다르면 값이 너무 많거나 모자란다는 오류가 나므로 맞는 설명이에요."),
                  choice("B", "괄호 안 열의 순서와 서브쿼리 SELECT 목록의 순서를 맞춰야 한다", rationale="짝은 위치로 맞춰지므로 맞는 설명이에요."),
                  choice("C", "SQL Server에서도 같은 문법으로 쓸 수 있다", True, "SQL Server는 이 문법을 지원하지 않아서 틀린 설명이에요."),
                  choice("D", "서브쿼리가 한 행만 돌려주면 등호로도 짝을 비교할 수 있다", rationale="(부서번호, 급여) = (서브쿼리)처럼 쓸 수 있으므로 맞는 설명이에요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 결과 표
        DEPARTMENT_MAX_EXAMPLE.check,
        PAIR_IN_EXAMPLE.check,
        PAIR_EQUAL_EXAMPLE.check,
        PAIR_LIST_EXAMPLE.check,
        PAIR_POSITION_EXAMPLE.check,
        SEPARATE_COLUMN_EXAMPLE.check,
        sql_check("SELECT 이름 FROM 사원 WHERE (부서번호, 급여) IN (SELECT 부서번호, MAX(급여) FROM 사원 GROUP BY 부서번호);",
                  [["김민수"], ["박서준"], ["최유나"]]),
        sql_error_check("SELECT 이름 FROM 사원 WHERE (부서번호, 급여) = (SELECT 부서번호, MAX(급여) FROM 사원 GROUP BY 부서번호)",
                        "ORA-01427"),
        # 확인 문제 4 (이지은 20 과장, 한도윤 30 대리): 열별 3행 <-> 짝 2행
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 IN (SELECT 부서번호 FROM 사원 WHERE 사번 IN (1002, 1006)) "
                  "AND 직급 IN (SELECT 직급 FROM 사원 WHERE 사번 IN (1002, 1006));",
                  [["이지은"], ["박서준"], ["한도윤"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE (부서번호, 직급) IN (SELECT 부서번호, 직급 FROM 사원 WHERE 사번 IN (1002, 1006))",
                  [["이지은"], ["한도윤"]]),
        # 열 순서·개수
        sql_check("SELECT 이름 FROM 사원 WHERE (부서번호, 급여) IN (SELECT MAX(급여), 부서번호 FROM 사원 GROUP BY 부서번호);", []),
        sql_error_check("SELECT 이름 FROM 사원 WHERE (부서번호, 급여) IN (SELECT 부서번호, 급여, 사번 FROM 사원)", "ORA-00913"),
        sql_error_check("SELECT 이름 FROM 사원 WHERE (부서번호, 급여) IN (SELECT 부서번호 FROM 사원)", "ORA-00947"),
    ],
}
