"""개념: ORDER BY (2단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

EMPLOYEE_SORT_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "커미션", "부서번호")
EMPLOYEE_COMMISSION_TABLE = to_employee_table_md("사번", "이름", "커미션")

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
    lines = ["| 순서 | " + " | ".join(titles) + " |", "|" + "---|" * (len(titles) + 1)]
    for index in range(len(labeled_examples[0][1][1])):
        cells = [to_cell(example[1][index]) for _, example in labeled_examples]
        lines.append(f"| {index + 1} | " + " | ".join(cells) + " |")
    return "\n".join(lines)


COMMISSION_DEFAULT_ORDER_TABLE = to_sort_result_table_md(("오름차순", COMMISSION_ASCENDING), ("내림차순", COMMISSION_DESCENDING))
COMMISSION_NULLS_OPTION_TABLE = to_sort_result_table_md(("NULLS FIRST", COMMISSION_NULLS_FIRST),
                                                        ("DESC NULLS LAST", COMMISSION_DESCENDING_NULLS_LAST))

CONCEPT = {
    "tagKey": "select-order-by",
    "topicCode": "sql_basic_select",
    "sortOrder": 6,
    "title": "ORDER BY",
    "summary": "결과 행의 순서를 정하는 절이고, SELECT 문에서 가장 마지막에 처리돼요",
    "coreMd": (
        "- ORDER BY를 쓰지 않으면 결과 행의 순서는 보장되지 않고, 정렬 방향을 적지 않으면 오름차순(ASC)으로 정렬돼요.\n"
        "- `ORDER BY 부서번호, 급여 DESC`에서 DESC는 바로 앞의 급여에만 걸리고, 부서번호는 오름차순 그대로예요.\n"
        "- 열 이름 대신 SELECT 절의 별칭이나 위치 번호(1, 2, ...)로 정렬할 수 있는데, 이는 ORDER BY가 SELECT보다 뒤에 처리되기 때문이에요.\n"
        "- Oracle은 NULL을 가장 큰 값으로 봐서 오름차순이면 맨 뒤, 내림차순이면 맨 앞에 두고, SQL Server는 그 반대예요. 위치를 바꾸려면 NULLS FIRST·NULLS LAST를 써요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

`SELECT 이름 FROM 사원`을 실행하면 결과가 사번 순서로 나오는 것처럼 보이지만, 데이터베이스는 이 순서를 약속하지 않아요. 데이터가 늘거나 내부 저장 방식이 바뀌면 같은 SQL도 다른 순서로 나올 수 있어요. "급여가 높은 순서", "입사일이 빠른 순서"처럼 순서가 의미 있을 때는 반드시 ORDER BY로 순서를 정해 줘야 해요. 예시는 아래 사원 표를 기준으로 해요.

{EMPLOYEE_SORT_TABLE}

## 한 줄 정의 {{#definition}}

ORDER BY는 결과 행을 지정한 열의 값 순서대로 줄 세우는 절이에요. 열 뒤에 **ASC**(오름차순, 작은 값부터)나 **DESC**(내림차순, 큰 값부터)를 적고, 아무것도 적지 않으면 ASC로 정렬해요. 숫자는 작은 수부터, 날짜는 이른 날짜부터, 문자는 가나다·ABC 순서가 오름차순이에요.

```sql
SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC, 이름;   -- 급여가 높은 순서로, 같으면 이름순으로 세워요
```

ORDER BY는 데이터를 저장된 상태 그대로 두고 보여 주는 순서만 바꿔요. 그리고 SELECT 문의 맨 끝에 한 번만 써요.

## 여러 열로 정렬하기 {{#multi-column}}

ORDER BY에 열을 여러 개 쓰면, 첫 번째 열로 줄을 세운 뒤 그 값이 같은 행끼리만 두 번째 열로 다시 줄을 세워요. 아래 SQL은 부서번호 오름차순으로 세우고, 같은 부서 안에서는 급여가 높은 순서로, 급여까지 같으면 이름순으로 세워요.

{MULTI_COLUMN_SORT_EXAMPLE.markdown}

최유나는 급여가 가장 높지만 30번 부서라서 다섯 번째에 있어요. 두 번째 열은 첫 번째 열의 값이 같을 때만 순서를 정하기 때문이에요. 부서번호가 NULL인 윤서연이 맨 뒤에 있는 이유는 아래 NULL 문단에서 설명해요.

## 별칭과 위치 번호로 정렬하기 {{#position-alias}}

ORDER BY는 SELECT 문에서 가장 마지막에 처리되기 때문에, SELECT 절에서 만든 별칭을 그대로 쓸 수 있어요. 또 SELECT 절에 적은 열의 순서를 숫자로 적어서, 1이면 첫 번째 열, 2면 두 번째 열로 정렬할 수도 있어요. 열 이름, 별칭, 위치 번호는 한 ORDER BY 안에서 섞어 써도 돼요.

```sql
SELECT 이름, 급여 * 12 AS 연봉 FROM 사원 ORDER BY 연봉 DESC, 이름;   -- 별칭으로 정렬해요
SELECT 이름, 급여 FROM 사원 ORDER BY 2 DESC, 1;                     -- 2번째 열인 급여의 내림차순, 같으면 1번째 열인 이름순이에요
```

## NULL은 어디에 놓일까요 {{#null-order}}

Oracle은 정렬할 때 NULL을 어떤 값보다도 큰 값처럼 다뤄요. 그래서 오름차순이면 NULL이 맨 뒤에, 내림차순이면 맨 앞에 와요. 커미션 열로 확인해 보면 이렇게 돼요.

{EMPLOYEE_COMMISSION_TABLE}

```sql
{COMMISSION_ASCENDING[0]}
{COMMISSION_DESCENDING[0]}
```

{COMMISSION_DEFAULT_ORDER_TABLE}

NULL을 원하는 쪽에 두고 싶으면 정렬 방향 뒤에 **NULLS FIRST**(NULL을 맨 앞)나 **NULLS LAST**(NULL을 맨 뒤)를 붙여요. 이 옵션은 그 열의 정렬에만 적용돼요.

```sql
{COMMISSION_NULLS_FIRST[0]}
{COMMISSION_DESCENDING_NULLS_LAST[0]}
```

{COMMISSION_NULLS_OPTION_TABLE}

## 자주 헷갈리는 점 {{#confusing}}

**DESC는 바로 앞의 열 하나에만 걸려요.** `ORDER BY 부서번호, 급여 DESC`를 "둘 다 내림차순"으로 읽기 쉬운데, 부서번호 뒤에는 방향이 없으니 기본값인 ASC가 적용돼요. 두 열 모두 내림차순으로 정렬하려면 `ORDER BY 부서번호 DESC, 급여 DESC`처럼 열마다 DESC를 적어야 해요.

**NULL의 위치는 데이터베이스마다 달라요.** Oracle은 NULL을 가장 큰 값으로 보지만, SQL Server는 NULL을 가장 작은 값으로 봐서 오름차순이면 NULL이 맨 앞에 와요. 시험에서 "Oracle에서 오름차순 정렬하면 NULL은 맨 앞에 온다" 같은 보기는 틀린 설명이에요. NULL 행이 정렬 결과에서 빠지는 것은 아니라는 점도 함께 기억해 두면 좋아요.

**위치 번호는 테이블이 아니라 SELECT 절의 순서예요.** `SELECT 이름, 급여 FROM 사원 ORDER BY 2`에서 2는 사원 테이블의 두 번째 열(이름)이 아니라 SELECT 절의 두 번째 열인 급여예요. SELECT 절에 열이 두 개뿐인데 `ORDER BY 3`이라고 쓰면 세 번째 열이 없어서 오류가 나요.

```sql
SELECT 이름, 급여 FROM 사원 ORDER BY 3;   -- 오류: SELECT 절에 3번째 열이 없어요
```

**SELECT 절에 없는 열로도 정렬할 수 있지만, 예외가 있어요.** `SELECT 이름 FROM 사원 ORDER BY 급여 DESC`처럼 보여 주지 않는 열로 정렬해도 문제가 없어요. 하지만 DISTINCT를 쓰면 SELECT 절에 있는 열로만 정렬할 수 있어요. `SELECT DISTINCT 부서번호`는 20번 부서를 한 행으로 줄이는데, 그 한 행 뒤에는 이지은 2500, 박서준 2800, 정하늘 2500 세 사람의 급여가 겹쳐 있어요. 이 행을 2500으로 보고 줄을 세울지 2800으로 보고 세울지 정할 수 없어서, Oracle은 SELECT 목록에 없는 식이라는 오류(ORA-01791)를 내요. GROUP BY(같은 값끼리 행을 묶는 절)를 쓴 경우도 같은 이유로, GROUP BY에 적은 열이나 `MAX(급여)`처럼 묶음마다 값 하나를 계산하는 그룹 함수로만 정렬할 수 있어요. MAX는 묶음에서 가장 큰 값을 돌려주는 함수이고, 7단원에서 다뤄요.

```sql
SELECT 이름 FROM 사원 ORDER BY 급여 DESC;                                       -- 정상으로 실행돼요
SELECT DISTINCT 부서번호 FROM 사원 ORDER BY 급여;                               -- 오류: DISTINCT가 있으면 SELECT에 없는 열로 못 세워요
SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 ORDER BY 급여;            -- 오류: 급여는 GROUP BY에 없는 열이에요
SELECT 부서번호, COUNT(*) FROM 사원 GROUP BY 부서번호 ORDER BY MAX(급여) DESC;  -- 그룹 함수로는 정렬할 수 있어요
```

**ORDER BY는 모든 절 가운데 가장 늦게 처리돼요.** 별칭을 쓸 수 있는 것도 이 때문이고, 다음 개념인 ROWNUM에서 "정렬하기 전에 번호가 먼저 붙는" 문제가 생기는 것도 이 때문이에요. ORDER BY가 결과를 줄 세우는 시점에는 WHERE에서 고를 행이 이미 모두 정해져 있어요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

정렬 결과를 보여 주고 알맞은 ORDER BY를 고르거나, ORDER BY를 주고 몇 번째 행이 누구인지 묻는 문제가 많아요. 이때는 열마다 ASC와 DESC를 따로 확인하고, NULL이 있는 열이면 Oracle 기준으로 오름차순일 때 맨 뒤에 놓으면 돼요. 그 밖에 위치 번호가 SELECT 절 열 수를 넘거나, DISTINCT와 함께 SELECT 절에 없는 열로 정렬해서 오류가 나는 SQL을 고르는 문제가 나와요.""",
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
        sql_check("SELECT 이름, 급여 FROM 사원 ORDER BY 급여 DESC, 이름",
                  [["최유나", 3200], ["김민수", 3000], ["박서준", 2800], ["한도윤", 2700],
                   ["이지은", 2500], ["정하늘", 2500], ["오지민", 2200], ["윤서연", 2000]], is_ordered=True),
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
