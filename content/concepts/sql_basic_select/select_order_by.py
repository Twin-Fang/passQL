"""개념: ORDER BY (2단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md, to_markdown_table

EMPLOYEE_SORT_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "커미션", "부서번호")
EMPLOYEE_COMMISSION_TABLE = to_employee_table_md("사번", "이름", "커미션")

# 기본 정렬 예시: 급여 내림차순, 동점이면 이름순 (sql_example 한 원본)
SALARY_DESC_EXAMPLE = sql_example("SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC, 이름;", ("이름", "급여"), [
    ["최유나", 3200], ["김민수", 3000], ["박서준", 2800], ["한도윤", 2700],
    ["이지은", 2500], ["정하늘", 2500], ["오지민", 2200], ["윤서연", 2000]])

MULTI_COLUMN_SORT_SQL = "SELECT 이름, 부서번호, 급여 FROM 사원 ORDER BY 부서번호, 급여 DESC, 이름;"
# 여러 열 정렬 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
MULTI_COLUMN_SORT_EXAMPLE = sql_example(MULTI_COLUMN_SORT_SQL, ("이름", "부서번호", "급여"), [
    ["김민수", 10, 3000], ["박서준", 20, 2800], ["이지은", 20, 2500], ["정하늘", 20, 2500],
    ["최유나", 30, 3200], ["한도윤", 30, 2700], ["오지민", 30, 2200], ["윤서연", None, 2000]])

# 커미션 NULL 정렬 예시 4개: (본문 SQL, Oracle 결과 행) > 본문 결과 표와 sqlChecks 가 같은 원본을 씀
COMMISSION_ASCENDING = ("SELECT 이름, 커미션 FROM 사원 ORDER BY 커미션, 이름;",
                        [["박서준", 0], ["오지민", 200], ["이지은", 300], ["한도윤", 500],
                         ["김민수", None], ["윤서연", None], ["정하늘", None], ["최유나", None]])
COMMISSION_DESCENDING = ("SELECT 이름, 커미션 FROM 사원 ORDER BY 커미션 DESC, 이름;",
                         [["김민수", None], ["윤서연", None], ["정하늘", None], ["최유나", None],
                          ["한도윤", 500], ["이지은", 300], ["오지민", 200], ["박서준", 0]])
COMMISSION_NULLS_FIRST = ("SELECT 이름, 커미션 FROM 사원 ORDER BY 커미션 NULLS FIRST, 이름;",
                          [["김민수", None], ["윤서연", None], ["정하늘", None], ["최유나", None],
                           ["박서준", 0], ["오지민", 200], ["이지은", 300], ["한도윤", 500]])
COMMISSION_DESCENDING_NULLS_LAST = ("SELECT 이름, 커미션 FROM 사원 ORDER BY 커미션 DESC NULLS LAST, 이름;",
                                    [["한도윤", 500], ["이지은", 300], ["오지민", 200], ["박서준", 0],
                                     ["김민수", None], ["윤서연", None], ["정하늘", None], ["최유나", None]])


def to_sort_result_table_md(*labeled_examples):
    """(열 제목, (SQL, 결과 행)) 여러 개 > 순서별로 나란히 놓은 결과 표 (칸 = 이름 커미션)"""
    def to_cell(row):
        return f"{row[0]} {'NULL' if row[1] is None else row[1]}"

    titles = [title for title, _ in labeled_examples]
    row_count = len(labeled_examples[0][1][1])
    rows = [[index + 1] + [to_cell(example[1][index]) for _, example in labeled_examples] for index in range(row_count)]
    return to_markdown_table(("순서", *titles), rows)


COMMISSION_DEFAULT_ORDER_TABLE = to_sort_result_table_md(("오름차순", COMMISSION_ASCENDING), ("내림차순", COMMISSION_DESCENDING))
COMMISSION_NULLS_OPTION_TABLE = to_sort_result_table_md(("NULLS FIRST", COMMISSION_NULLS_FIRST),
                                                        ("DESC NULLS LAST", COMMISSION_DESCENDING_NULLS_LAST))

CONCEPT = {
    "tagKey": "select-order-by",
    "topicCode": "sql_basic_select",
    "sortOrder": 7,
    "title": "ORDER BY",
    "summary": "결과 행의 순서를 정하는 절이고, 가장 마지막에 처리돼요",
    "coreMd": (
        "- ORDER BY가 없으면 결과 순서는 보장되지 않고, 방향을 적지 않으면 **오름차순(ASC)**이에요.\n"
        "- `ORDER BY 부서번호, 급여 DESC`의 DESC는 **바로 앞 급여에만** 걸리고, 부서번호는 오름차순 그대로예요.\n"
        "- ORDER BY는 SELECT보다 뒤에 처리되어서 SELECT의 별칭이나 위치 번호(1, 2, ...)로도 정렬해요.\n"
        "- Oracle은 NULL을 **가장 큰 값**으로 봐서 오름차순이면 맨 뒤에 두고, SQL Server는 그 반대예요.\n"
        "- NULL 위치는 **NULLS FIRST·NULLS LAST**로 바꾸고, DISTINCT가 있으면 SELECT에 없는 열로 정렬할 수 없어요."
    ),
    "detailMd": f"""## 왜 필요할까요 — 순서는 약속되지 않아서 {{#why}}

`SELECT 이름 FROM 사원`이 사번 순서로 나오는 것처럼 보여도, 데이터베이스는 이 순서를 약속하지 않아요. 데이터가 늘거나 저장 방식이 바뀌면 같은 SQL도 다른 순서로 나올 수 있어서, 순서가 의미 있을 때는 반드시 ORDER BY를 써요.

{EMPLOYEE_SORT_TABLE}

## 한 줄 정의 — ASC가 기본이에요 {{#definition}}

ORDER BY는 결과 행을 지정한 열의 값 순서대로 줄 세우는 절이고, SELECT 문의 맨 끝에 한 번만 써요. 저장된 데이터는 그대로 두고 보여 주는 순서만 바꿔요.

| 용어 | 뜻 |
|---|---|
| ASC (오름차순) | 작은 값부터예요. 방향을 적지 않으면 ASC예요 |
| DESC (내림차순) | 큰 값부터예요 |
| 오름차순의 뜻 | 숫자는 작은 수부터, 날짜는 이른 날짜부터, 문자는 가나다·ABC 순서예요 |

{SALARY_DESC_EXAMPLE.markdown}

## 여러 열로 정렬하기 — 앞 열이 같을 때만 다음 열 {{#multi-column}}

첫 번째 열로 줄을 세운 뒤, 그 값이 같은 행끼리만 두 번째 열로 다시 세워요. 최유나는 급여가 가장 높지만 30번 부서라서 다섯 번째에 있어요.

{MULTI_COLUMN_SORT_EXAMPLE.markdown}

| 단계 | 내용 |
|---|---|
| 부서번호 (ASC) | 10, 20, 30, NULL 순서로 무리를 나눠요 |
| 급여 DESC | 같은 부서 안에서 급여가 높은 순서로 세워요 |
| 이름 (ASC) | 급여까지 같은 이지은과 정하늘을 이름순으로 세워요 |

## 별칭과 위치 번호 — SELECT 뒤라서 쓸 수 있어요 {{#position-alias}}

ORDER BY는 가장 마지막에 처리되어서 SELECT의 별칭을 그대로 쓰고, SELECT 절의 열 순서를 숫자로 적어 정렬할 수도 있어요. 열 이름, 별칭, 위치 번호는 한 ORDER BY 안에서 섞어 써도 돼요.

```sql
SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 ORDER BY 연봉 DESC, 이름;   -- 별칭으로 정렬해요
SELECT 이름, 급여 FROM 사원 ORDER BY 2 DESC, 1;                     -- 2번째 열인 급여의 내림차순, 같으면 1번째 열인 이름순이에요
```

## NULL은 어디에 놓일까요 — Oracle은 가장 큰 값 {{#null-order}}

Oracle은 NULL을 어떤 값보다도 큰 값처럼 다뤄서, 오름차순이면 맨 뒤에, 내림차순이면 맨 앞에 둬요. NULL 행이 정렬 결과에서 빠지지는 않아요.

{EMPLOYEE_COMMISSION_TABLE}

```sql
{COMMISSION_ASCENDING[0]}
{COMMISSION_DESCENDING[0]}
```

{COMMISSION_DEFAULT_ORDER_TABLE}

방향 뒤에 NULLS FIRST(NULL을 맨 앞)나 NULLS LAST(NULL을 맨 뒤)를 붙이면 위치를 바꿀 수 있고, 이 옵션은 그 열의 정렬에만 적용돼요.

```sql
{COMMISSION_NULLS_FIRST[0]}
{COMMISSION_DESCENDING_NULLS_LAST[0]}
```

{COMMISSION_NULLS_OPTION_TABLE}

| DBMS | 오름차순에서 NULL | 내림차순에서 NULL |
|---|---|---|
| Oracle (NULL이 가장 큼) | 맨 뒤 | 맨 앞 |
| SQL Server (NULL이 가장 작음) | 맨 앞 | 맨 뒤 |

## 자주 헷갈리는 점 — DESC의 범위, 위치 번호, DISTINCT {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| `ORDER BY 부서번호, 급여 DESC`는 두 열 모두 내림차순이에요 | DESC는 바로 앞 급여에만 걸리고 부서번호는 ASC예요. 둘 다 내리려면 열마다 DESC를 적어요 |
| Oracle에서 오름차순으로 정렬하면 NULL이 맨 앞에 와요 | Oracle은 NULL을 가장 큰 값으로 봐서 맨 뒤예요. 맨 앞은 SQL Server의 동작이에요 |
| `ORDER BY 2`는 테이블의 두 번째 열로 정렬해요 | SELECT 절의 두 번째 열이에요. SELECT에 열이 두 개뿐인데 `ORDER BY 3`이면 오류(ORA-01785, 위치 번호가 열 수를 넘음)예요 |
| SELECT 절에 없는 열로는 정렬할 수 없어요 | 보통은 돼요. DISTINCT나 GROUP BY가 있을 때만 제한돼요 |
| DISTINCT를 써도 아무 열로나 정렬할 수 있어요 | 20번 부서 한 행 뒤에 급여 2500, 2800, 2500이 겹쳐 어느 값으로 세울지 정할 수 없어서 오류(ORA-01791, SELECT 목록에 없는 식)예요 |
| GROUP BY를 쓰면 원래 열 아무거나로 정렬해요 | GROUP BY에 적은 열이나 `MAX(급여)` 같은 그룹 함수로만 정렬해요 |

```sql
SELECT 이름, 급여 FROM 사원 ORDER BY 3;                                        -- 오류: SELECT 절에 3번째 열이 없어요
SELECT 이름 FROM 사원 ORDER BY 급여 DESC;                                       -- 정상으로 실행돼요
SELECT DISTINCT 부서번호 FROM 사원 ORDER BY 급여;                               -- 오류: DISTINCT가 있으면 SELECT에 없는 열로 못 세워요
SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 ORDER BY 급여;            -- 오류: 급여는 GROUP BY에 없는 열이에요
SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 ORDER BY MAX(급여) DESC;  -- 그룹 함수로는 정렬할 수 있어요
```

GROUP BY는 같은 값끼리 행을 묶는 절이고, MAX는 묶음에서 가장 큰 값을 돌려주는 그룹 함수예요(7단원). ORDER BY가 줄을 세우는 시점에는 WHERE가 고를 행이 이미 정해져 있어서, 다음 개념 ROWNUM에서는 "정렬보다 번호가 먼저 붙는" 문제가 생겨요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `ORDER BY 커미션 DESC NULLS LAST`는 NULL을 맨 뒤에 둬요 | O | NULLS LAST가 기본 위치인 맨 앞 대신 맨 뒤로 보내요 |
| 한 ORDER BY 안에 열 이름과 위치 번호를 섞어 쓰면 오류가 나요 | X | 열 이름, 별칭, 위치 번호는 섞어 써도 돼요 |
| ORDER BY를 쓰지 않으면 결과는 항상 사번 순서로 나와요 | X | 순서가 보장되지 않아서, 같은 SQL도 다른 순서로 나올 수 있어요 |

## 꼭 외울 것 — 방향의 범위와 NULL의 자리 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| 방향을 적지 않으면 | ASC (오름차순) |
| `부서번호, 급여 DESC`의 DESC | 급여에만 걸리고 부서번호는 ASC |
| Oracle의 NULL 정렬 위치 | 가장 큰 값: ASC면 맨 뒤, DESC면 맨 앞 |
| SQL Server의 NULL 위치 | 가장 작은 값: ASC면 맨 앞, DESC면 맨 뒤 |
| NULL 위치를 바꾸는 옵션 | NULLS FIRST, NULLS LAST (그 열에만 적용) |
| ORDER BY에 쓸 수 있는 것 | 열 이름, 별칭, 위치 번호 (섞어 써도 돼요) |
| 위치 번호가 열 수를 넘으면 | 오류 |
| DISTINCT와 SELECT에 없는 열 | 그 열로 정렬하면 오류 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

정렬 결과를 보고 알맞은 ORDER BY를 고르거나, 몇 번째 행이 누구인지 묻는 문제가 많아요. 열마다 ASC와 DESC를 따로 확인하고, NULL은 Oracle 기준으로 오름차순일 때 맨 뒤에 놓으면 되며, 위치 번호나 DISTINCT 때문에 오류가 나는 SQL을 고르는 문제도 나와요.""",
    "checkQuestions": [
        question(1, "ORDER BY에서 정렬 방향을 적지 않으면 어떻게 정렬되나요?", "definition",
                 "정렬 방향을 적지 않으면 기본값인 ASC, 즉 오름차순으로 정렬돼요. 내림차순을 원하면 DESC를 적어야 해요.",
                 [choice("A", "내림차순(DESC)으로 정렬된다", rationale="DESC는 직접 적어야 적용돼요."),
                  choice("B", "테이블에 저장된 순서대로 나온다", rationale="ORDER BY를 썼으면 그 열로 정렬돼요."),
                  choice("C", "오름차순(ASC)으로 정렬된다", True, "ASC가 기본 정렬 방향이에요."),
                  choice("D", "오류가 난다", rationale="방향을 생략해도 문법상 문제가 없어요.")]),
        question(2, "아래 커미션 표에 다음 SQL을 Oracle에서 실행하면 첫 번째 행의 이름은 무엇인가요?\n\n" + EMPLOYEE_COMMISSION_TABLE, "null-order",
                 "Oracle은 NULL을 가장 큰 값으로 보므로 내림차순이면 NULL 4명이 맨 앞에 와요. 그 4명은 이름순으로 정렬되어 김민수가 첫 번째예요.",
                 [choice("A", "김민수", True, "NULL이 맨 앞에 오고, 그중 이름순으로 가장 앞이에요."),
                  choice("B", "한도윤", rationale="NULL을 가장 작은 값으로 본 결과인데, Oracle은 반대예요."),
                  choice("C", "박서준", rationale="오름차순으로 정렬했을 때의 첫 번째 값이에요."),
                  choice("D", "윤서연", rationale="NULL 4명 사이에서는 이름순이라 김민수가 앞이에요.")],
                 stem_sql="SELECT 이름, 커미션 FROM 사원 ORDER BY 커미션 DESC, 이름;"),
        question(3, "`ORDER BY 부서번호, 급여 DESC`의 정렬 방식으로 알맞은 것은 무엇인가요?", "confusing",
                 "DESC는 바로 앞의 급여에만 걸려요. 방향을 적지 않은 부서번호는 기본값인 오름차순으로 정렬돼요.",
                 [choice("A", "부서번호와 급여 모두 내림차순", rationale="부서번호에는 DESC가 없어서 오름차순이에요."),
                  choice("B", "부서번호 내림차순, 급여 오름차순", rationale="방향이 반대로 적용됐어요."),
                  choice("C", "급여로만 내림차순 정렬하고 부서번호는 무시", rationale="부서번호가 첫 번째 정렬 기준이에요."),
                  choice("D", "부서번호 오름차순, 같은 부서 안에서 급여 내림차순", True, "DESC는 급여에만 걸려요.")]),
        question(4, "NULL의 정렬 위치에 대한 설명으로 알맞은 것은 무엇인가요?", "confusing",
                 "Oracle은 NULL을 가장 큰 값으로 보아 오름차순이면 맨 뒤에 둬요. SQL Server는 가장 작은 값으로 보아 오름차순이면 맨 앞에 둬요.",
                 [choice("A", "Oracle에서 오름차순으로 정렬하면 NULL이 맨 앞에 온다", rationale="Oracle은 오름차순일 때 NULL을 맨 뒤에 둬요."),
                  choice("B", "Oracle은 NULL을 가장 큰 값으로 보아 오름차순이면 맨 뒤에 둔다", True, "Oracle의 기본 동작이에요."),
                  choice("C", "Oracle과 SQL Server는 NULL을 같은 위치에 둔다", rationale="SQL Server는 Oracle과 반대 위치에 둬요."),
                  choice("D", "NULL인 행은 정렬 결과에서 빠진다", rationale="NULL인 행도 결과에 그대로 나와요.")]),
        question(5, "다음 중 Oracle에서 오류가 나는 SQL은 무엇인가요?", "confusing",
                 "DISTINCT를 쓰면 SELECT 절에 있는 열로만 정렬할 수 있어서 SELECT 목록에 없는 식이라는 오류(ORA-01791)가 나요. 나머지는 별칭, 위치 번호, SELECT에 없는 열로 정상 정렬돼요.",
                 [choice("A", "SELECT 이름 FROM 사원 ORDER BY 급여 DESC", rationale="DISTINCT가 없으면 SELECT에 없는 열로 정렬할 수 있어요."),
                  choice("B", "SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 ORDER BY 연봉", rationale="ORDER BY는 SELECT 뒤라서 별칭을 쓸 수 있어요."),
                  choice("C", "SELECT DISTINCT 부서번호 FROM 사원 ORDER BY 급여", True, "DISTINCT와 함께 SELECT에 없는 열로 정렬해서 오류가 나요."),
                  choice("D", "SELECT 이름, 급여 FROM 사원 ORDER BY 2 DESC, 1", rationale="두 열 모두 SELECT 절에 있는 위치 번호예요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        SALARY_DESC_EXAMPLE.check,
        MULTI_COLUMN_SORT_EXAMPLE.check,
        sql_check("SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 ORDER BY 연봉 DESC, 이름",
                  [["최유나", 38400], ["김민수", 36000], ["박서준", 33600], ["한도윤", 32400],
                   ["이지은", 30000], ["정하늘", 30000], ["오지민", 26400], ["윤서연", 24000]], is_ordered=True),
        sql_check("SELECT 이름, 급여 FROM 사원 ORDER BY 2 DESC, 1",
                  [["최유나", 3200], ["김민수", 3000], ["박서준", 2800], ["한도윤", 2700],
                   ["이지은", 2500], ["정하늘", 2500], ["오지민", 2200], ["윤서연", 2000]], is_ordered=True),
        *[sql_check(sql, rows, is_ordered=True) for sql, rows in (COMMISSION_ASCENDING, COMMISSION_DESCENDING,
                                                                  COMMISSION_NULLS_FIRST, COMMISSION_DESCENDING_NULLS_LAST)],
        sql_error_check("SELECT 이름, 급여 FROM 사원 ORDER BY 3", "ORA-01785"),
        sql_check("SELECT 이름 FROM 사원 ORDER BY 급여 DESC, 이름",
                  [["최유나"], ["김민수"], ["박서준"], ["한도윤"], ["이지은"], ["정하늘"], ["오지민"], ["윤서연"]], is_ordered=True),
        sql_error_check("SELECT DISTINCT 부서번호 FROM 사원 ORDER BY 급여", "ORA-01791"),
        sql_error_check("SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 ORDER BY 급여", "ORA-00979"),
        sql_check("SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 ORDER BY MAX(급여) DESC",
                  [[30, 3], [10, 1], [20, 3], [None, 1]], is_ordered=True),
        # 5번 문제 보기 (오류 없는 세 문장)
        sql_check("SELECT 이름 FROM 사원 ORDER BY 급여 DESC",
                  [["최유나"], ["김민수"], ["박서준"], ["한도윤"], ["이지은"], ["정하늘"], ["오지민"], ["윤서연"]]),
        sql_check("SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 ORDER BY 연봉",
                  [["윤서연", 24000], ["오지민", 26400], ["이지은", 30000], ["정하늘", 30000],
                   ["한도윤", 32400], ["박서준", 33600], ["김민수", 36000], ["최유나", 38400]]),
    ],
}
