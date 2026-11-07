"""개념: GROUPING 함수 (7단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md, to_markdown_table

# 사원 8명 전체 (1008 부서번호 NULL, 두 열 예시용 직급까지)
EMPLOYEE_DEPARTMENT_SALARY_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")

# ROLLUP(부서번호) 전체 사원 결과 5행: 1008 그룹(원래 NULL) + 총계(소계 NULL) (본문 표 = 검증 기대값)
ROLLUP_DEPARTMENT_COLUMNS = ("부서번호", "급여합계")
ROLLUP_DEPARTMENT_ROWS = [[10, 3000], [20, 7800], [30, 8100], [None, 2000], [None, 20900]]
ROLLUP_DEPARTMENT_EXAMPLE = sql_example(
    "SELECT 부서번호, SUM(급여) AS 급여합계 FROM 사원 GROUP BY ROLLUP(부서번호) ORDER BY 부서번호;",
    ROLLUP_DEPARTMENT_COLUMNS,
    ROLLUP_DEPARTMENT_ROWS,
)
ROLLUP_DEPARTMENT_GROUPING_COLUMNS = ("부서번호", "급여합계", "GROUPING(부서번호)")
ROLLUP_DEPARTMENT_GROUPING_ROWS = [[10, 3000, 0], [20, 7800, 0], [30, 8100, 0], [None, 2000, 0], [None, 20900, 1]]
ROLLUP_DEPARTMENT_GROUPING_EXAMPLE = sql_example(
    "SELECT 부서번호, SUM(급여) AS 급여합계, GROUPING(부서번호)\n"
    "FROM 사원\n"
    "GROUP BY ROLLUP(부서번호)\n"
    "ORDER BY 부서번호;",
    ROLLUP_DEPARTMENT_GROUPING_COLUMNS,
    ROLLUP_DEPARTMENT_GROUPING_ROWS,
)
# CASE 로 이름 붙인 결과 (원래 NULL > '미배정', 총계 > '전체')
CASE_LABEL_COLUMNS = ("부서", "급여합계")
CASE_LABEL_ROWS = [["10", 3000], ["20", 7800], ["30", 8100], ["미배정", 2000], ["전체", 20900]]
CASE_LABEL_EXAMPLE = sql_example(
    "SELECT CASE WHEN GROUPING(부서번호) = 1 THEN '전체'\n"
    "            WHEN 부서번호 IS NULL THEN '미배정'\n"
    "            ELSE TO_CHAR(부서번호) END AS 부서,\n"
    "       SUM(급여) AS 급여합계\n"
    "FROM 사원\n"
    "GROUP BY ROLLUP(부서번호)\n"
    "ORDER BY GROUPING(부서번호), 부서번호;",
    CASE_LABEL_COLUMNS,
    CASE_LABEL_ROWS,
)
# DECODE 로 이름 붙인 결과 (원래 NULL 은 그대로 NULL, ORDER BY 없음 > 순서 무관 비교)
DECODE_LABEL_ROWS = [["10", 3000], ["20", 7800], ["30", 8100], [None, 2000], ["전체", 20900]]
DECODE_LABEL_EXAMPLE = sql_example(
    "SELECT DECODE(GROUPING(부서번호), 1, '전체', 부서번호) AS 부서, SUM(급여) AS 급여합계\n"
    "FROM 사원\n"
    "GROUP BY ROLLUP(부서번호);",
    CASE_LABEL_COLUMNS,
    DECODE_LABEL_ROWS,
    is_ordered=False,
)
# 두 열 ROLLUP 에 '소계', '전체' 붙인 결과 (20, 30번 부서)
TWO_COLUMN_LABEL_COLUMNS = ("부서", "직급구분", "급여합계")
TWO_COLUMN_LABEL_ROWS = [
    ["20", "과장", 2500], ["20", "대리", 2800], ["20", "사원", 2500], ["20", "소계", 7800],
    ["30", "대리", 2700], ["30", "부장", 3200], ["30", "사원", 2200], ["30", "소계", 8100],
    ["전체", "소계", 15900],
]
TWO_COLUMN_LABEL_EXAMPLE = sql_example(
    "SELECT DECODE(GROUPING(부서번호), 1, '전체', 부서번호) AS 부서,\n"
    "       DECODE(GROUPING(직급), 1, '소계', 직급) AS 직급구분,\n"
    "       SUM(급여) AS 급여합계\n"
    "FROM 사원\n"
    "WHERE 부서번호 IN (20, 30)\n"
    "GROUP BY ROLLUP(부서번호, 직급)\n"
    "ORDER BY 부서번호, 직급;",
    TWO_COLUMN_LABEL_COLUMNS,
    TWO_COLUMN_LABEL_ROWS,
)
# HAVING GROUPING = 0 > 총계만 빠짐 (윤서연 그룹은 남음)
HAVING_GROUPING_EXAMPLE = sql_example(
    "SELECT 부서번호, SUM(급여) FROM 사원 GROUP BY ROLLUP(부서번호) HAVING GROUPING(부서번호) = 0;",
    ("부서번호", "SUM(급여)"),
    ROLLUP_DEPARTMENT_ROWS[:4],
    is_ordered=False,
)
# CUBE(부서번호, 직급) 묶음별 GROUPING_ID 값
GROUPING_ID_ROWS = [["(부서번호, 직급)", 0, 0, 0], ["(부서번호)", 0, 1, 1], ["(직급)", 1, 0, 2], ["()", 1, 1, 3]]
# 화면 표: 두 GROUPING 값을 이진수 두 자리처럼 한 칸에 (390pt 폭, 값은 GROUPING_ID_ROWS 그대로)
GROUPING_ID_TABLE = to_markdown_table(
    ("묶음", "GROUPING(부서번호), GROUPING(직급)", "GROUPING_ID(부서번호, 직급)"),
    [[group, f"{department_grouping}, {position_grouping}", grouping_id]
     for group, department_grouping, position_grouping, grouping_id in GROUPING_ID_ROWS])

CONCEPT = {
    "tagKey": "group-grouping-function",
    "topicCode": "sql_group_aggregate",
    "sortOrder": 6,
    "title": "GROUPING 함수",
    "summary": "소계와 총계 때문에 생긴 NULL이면 1, 아니면 0을 돌려줘요",
    "coreMd": (
        "- `GROUPING(열)`은 그 열이 소계나 총계를 만들려고 묶음에서 **빠졌으면 1**, 실제 값으로 묶였으면 0이에요.\n"
        "- 결과의 NULL이 **원래 데이터**인지 소계 표시인지 GROUPING으로 구분해요.\n"
        "- CASE나 DECODE와 함께 써서 소계와 총계 행에 '소계', '전체' 같은 이름을 붙여요.\n"
        "- 괄호 안에는 GROUP BY 열만 넣고, 다른 열은 ORA-00979(GROUP BY에 없는 열) 오류예요.\n"
        "- `GROUPING_ID(A, B)`는 GROUPING(A) × 2 + GROUPING(B)라서 **0, 1, 2, 3** 가운데 하나예요."
    ),
    "detailMd": f"""## 같은 NULL, 다른 뜻: GROUPING이 필요한 이유 {{#why}}

윤서연(사번 1008)은 아직 부서가 정해지지 않아서 부서번호가 NULL이에요. 이 표 전체에 `ROLLUP(부서번호)`를 쓰면 부서번호가 NULL인 행이 두 개 나와요.

{EMPLOYEE_DEPARTMENT_SALARY_TABLE}

{ROLLUP_DEPARTMENT_EXAMPLE.markdown}

`(NULL, 2000)`은 부서가 없는 윤서연 한 명의 그룹이고, `(NULL, 20900)`은 부서번호를 묶음에서 뺀 총계예요. 둘 다 칸이 NULL이라 눈으로는 구분할 수 없어서 GROUPING 함수가 있어요.

## 한 줄 정의: 빠졌으면 1, 남았으면 0 {{#definition}}

| 용어 | 뜻 |
|---|---|
| 확장 문법 | 앞 개념들에서 배운 ROLLUP, CUBE, GROUPING SETS예요. 소계와 총계를 함께 만드는 GROUP BY의 확장이에요 |
| `GROUPING(열)` | 확장 문법 결과의 각 행에서 그 열이 묶음에서 빠졌는지 알려 줘요. 빠져서 NULL로 채워졌으면 1, 실제 값으로 묶였으면 0이에요 |

| 한 줄 공식 | 뜻 |
|---|---|
| 빠졌으면 1, 남았으면 0 | 1은 소계나 총계 행, 0은 그 열의 실제 값으로 묶은 일반 행이에요 |
| NULL인지가 아니라 빠졌는지 | 칸이 NULL이어도 원래 데이터의 NULL이면 0이에요 |
| GROUP BY 열만 | 괄호 안에 다른 열을 넣으면 ORA-00979(GROUP BY에 없는 열) 오류예요 |

## 원래 NULL과 소계 NULL: 결과로 구분하기 {{#distinguish}}

{ROLLUP_DEPARTMENT_GROUPING_EXAMPLE.markdown}

윤서연 그룹은 원래 NULL인 값으로 묶인 것이라 **0**이고, 총계 행은 부서번호를 빼고 묶었으므로 1이에요. 헷갈리면 "이 칸의 NULL은 소계 때문에 생겼나요?"라고 묻고, 그렇다면 1, 아니라면 0이라고 답하면 돼요.

## 소계 행에 이름 붙이기: CASE와 DECODE {{#label}}

보고서에 NULL 대신 '전체'나 '소계'를 보이려면 GROUPING을 CASE나 DECODE의 조건으로 써요. CASE는 조건에 따라 다른 값을 돌려주는 식이고, 아래는 총계에 '전체', 원래 부서가 없는 행에 '미배정'을 붙여요.

{CASE_LABEL_EXAMPLE.markdown}

| 단계 | 내용 |
|---|---|
| 자료형 맞추기 | CASE의 결과값들은 숫자인지 문자인지 같은 자료형이 같아야 해서, TO_CHAR로 부서번호를 문자로 바꿨어요. 변환 함수는 4단원에서 다뤄요 |
| 빼먹으면 | `ELSE 부서번호`라고 쓰면 문자 '전체'와 숫자가 섞여 ORA-00932(자료형이 서로 맞지 않음) 오류가 나요 |
| 총계를 맨 뒤로 | ORDER BY에 `GROUPING(부서번호)`를 먼저 적어 0인 일반 행을 앞에, 1인 총계를 뒤에 뒀어요 |

DECODE는 첫 번째 값이 두 번째 값과 같으면 세 번째 값을, 다르면 네 번째 값을 돌려주는 Oracle 함수예요. 결과 자료형을 첫 결과값 '전체'에 맞춰 바꿔 주므로 숫자인 부서번호를 넣어도 문자로 나오고, 열이 두 개면 열마다 GROUPING을 따로 확인해요.

{TWO_COLUMN_LABEL_EXAMPLE.markdown}

총계 행은 부서번호와 직급이 모두 묶음에서 빠졌으므로, 두 칸에 각각 '전체'와 '소계'가 찍혀요.

## 자주 헷갈리는 점: 1과 0, DECODE의 빈틈 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| GROUPING은 그 열로 묶였으면 1이에요 | 반대예요. 1은 그 열을 빼고 만든 소계, 총계 행, 0은 실제 값으로 묶은 일반 행이에요 |
| 칸이 NULL이면 GROUPING은 1이에요 | 윤서연 그룹처럼 원래 데이터의 NULL은 0이에요 |
| DECODE로 '전체'를 붙이면 NULL이 모두 사라져요 | 윤서연 그룹은 GROUPING이 0이라 원래 값 NULL이 그대로 나와요. 이름을 붙이려면 CASE처럼 `부서번호 IS NULL` 조건을 따로 적어요 |
| GROUP BY에 없는 열을 넣으면 GROUPING이 1을 돌려줘요 | 묶음 기준이 아닌 열은 빠졌는지 따질 수 없어서 ORA-00979(GROUP BY에 없는 열) 오류가 나요 |

{DECODE_LABEL_EXAMPLE.markdown}

```sql
-- 오류: 직급이 GROUP BY에 없어요 (ORA-00979, GROUP BY에 없는 열)
SELECT 부서번호, GROUPING(직급) FROM 사원 GROUP BY ROLLUP(부서번호);
```

## HAVING과 ORDER BY에서도: 총계만 빼기 {{#filter-sort}}

GROUPING은 그룹마다 값이 하나라서 집계 함수처럼 HAVING과 ORDER BY에 쓸 수 있어요. `HAVING GROUPING(부서번호) = 0`을 붙이면 총계 행만 빠지고, 윤서연 그룹은 0이라서 남아요.

{HAVING_GROUPING_EXAMPLE.markdown}

## GROUPING_ID: 여러 열의 GROUPING을 숫자 하나로 {{#grouping-id}}

이진수는 0과 1만으로 수를 나타내는 방법이고, 두 자리 이진수에서 왼쪽 자리는 2를, 오른쪽 자리는 1을 뜻해요. `GROUPING_ID(부서번호, 직급)`은 GROUPING(부서번호)를 왼쪽에, GROUPING(직급)을 오른쪽에 둔 이진수를 보통 숫자로 바꾼 값이라서, GROUPING(부서번호) × 2 + GROUPING(직급)으로 계산해요.

{GROUPING_ID_TABLE}

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `CUBE(부서번호, 직급)`의 총계 행은 `GROUPING_ID(부서번호, 직급)`이 3이에요 | O | 두 열이 모두 빠져서 1 × 2 + 1 = 3이에요 |
| `HAVING GROUPING(부서번호) = 0`을 붙이면 윤서연 그룹도 빠져요 | X | 윤서연 그룹은 원래 NULL로 묶여서 0이라 남아요 |
| CASE로 이름을 붙일 때 `ELSE 부서번호`처럼 숫자를 그대로 써도 돼요 | X | 문자 '전체'와 자료형이 달라 ORA-00932(자료형이 서로 맞지 않음) 오류가 나요 |

## 꼭 외울 것: 1과 0이 뜻하는 것 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| `GROUPING(열)`이 1인 행 | 그 열이 묶음에서 빠진 소계, 총계 행 |
| `GROUPING(열)`이 0인 행 | 실제 값으로 묶은 행 (원래 NULL도 0) |
| 괄호 안에 넣는 열 | GROUP BY 열만 (아니면 ORA-00979) |
| `GROUPING_ID(A, B)` 계산 | GROUPING(A) × 2 + GROUPING(B) |
| 총계 행의 `GROUPING_ID(A, B)` | 3 (두 열 모두 빠짐) |
| 소계에 '전체' 붙이기 | CASE나 DECODE 조건에 GROUPING을 써요 |
| 총계 행만 빼는 HAVING | `GROUPING(열) = 0` (원래 NULL 그룹은 남음) |

## 시험에서는 이렇게 나와요 {{#exam-point}}

ROLLUP이나 CUBE 결과 표를 주고 특정 행의 GROUPING 값을 묻거나, CASE, DECODE로 '소계'와 '전체'를 붙인 결과 표를 고르게 하는 문제가 많아요. 행마다 어떤 열이 묶음에서 빠졌는지 먼저 따지면 되고, 원래 데이터의 NULL은 GROUPING이 0이라는 점을 함정으로 자주 써요.""",
    "checkQuestions": [
        question(1, "`GROUPING(부서번호)`가 1을 돌려주는 경우는 언제인가요?", "definition",
                 "GROUPING은 그 열이 소계나 총계를 만들려고 묶음에서 빠졌을 때 1을 돌려줘요. 칸이 NULL인지를 묻는 함수가 아니에요.",
                 [choice("A", "그 행의 부서번호 값이 NULL일 때", rationale="원래 데이터의 NULL로 묶인 행은 0이 나와요."),
                  choice("B", "부서번호 그룹에 속한 사원이 한 명뿐일 때", rationale="GROUPING은 인원 수와 관계가 없어요."),
                  choice("C", "그 행이 부서번호를 묶음에서 빼고 만든 소계나 총계 행일 때", True, "열이 묶음에서 빠졌다는 표시가 1이에요."),
                  choice("D", "부서번호가 GROUP BY에 없을 때", rationale="GROUP BY에 없는 열을 넣으면 1이 아니라 오류가 나요.")]),
        question(2, "아래 사원 표에서 윤서연(1008)은 부서번호가 NULL이에요. 다음 SQL 결과에는 부서번호가 NULL인 행이 두 개 나오는데, 두 행의 GROUPING(부서번호) 값은 무엇인가요?\n\n" + EMPLOYEE_DEPARTMENT_SALARY_TABLE, "distinguish",
                 "급여 합계 2000인 행은 원래 NULL인 윤서연 그룹이라서 0이고, 20900인 행은 부서번호를 뺀 총계라서 1이에요.",
                 [choice("A", "둘 다 1", rationale="윤서연 그룹은 실제 값(NULL)으로 묶였으므로 0이에요."),
                  choice("B", "둘 다 0", rationale="총계 행은 부서번호를 묶음에서 뺐으므로 1이에요."),
                  choice("C", "둘 다 NULL", rationale="GROUPING은 언제나 0이나 1을 돌려줘요."),
                  choice("D", "윤서연 그룹은 0, 총계 행은 1", True, "원래 NULL은 0, 소계로 생긴 NULL은 1이에요.")],
                 stem_sql="SELECT 부서번호, SUM(급여), GROUPING(부서번호) FROM 사원 GROUP BY ROLLUP(부서번호);"),
        question(3, "다음 SQL을 사원 표 전체에 실행했을 때, 급여 합계가 2000인 윤서연 그룹 행의 부서 칸에는 무엇이 나오나요?", "confusing",
                 "윤서연 그룹은 GROUPING(부서번호)가 0이라서 DECODE가 원래 값인 부서번호를 돌려줘요. 부서번호가 NULL이므로 결과도 NULL이에요.",
                 [choice("A", "'전체'", rationale="'전체'는 GROUPING이 1인 총계 행에만 나와요."),
                  choice("B", "NULL", True, "GROUPING이 0이라 원래 값인 NULL이 그대로 나와요."),
                  choice("C", "'0'", rationale="GROUPING 값이 아니라 부서번호 값을 돌려줘요."),
                  choice("D", "오류가 나서 실행되지 않는다", rationale="DECODE는 부서번호를 첫 결과값에 맞춰 문자로 바꾸므로 오류가 나지 않아요.")],
                 stem_sql="SELECT DECODE(GROUPING(부서번호), 1, '전체', 부서번호) AS 부서, SUM(급여) FROM 사원 GROUP BY ROLLUP(부서번호);"),
        question(4, "다음 SQL을 실행한 결과로 알맞은 것은 무엇인가요?", "confusing",
                 "GROUPING 괄호 안에는 GROUP BY에 적은 열만 넣을 수 있어요. 직급은 묶음 기준이 아니라서 ORA-00979(GROUP BY에 없는 열) 오류가 나요.",
                 [choice("A", "오류가 난다", True, "직급이 GROUP BY에 없어서 오류가 나요."),
                  choice("B", "GROUPING(직급)이 모든 행에서 1로 나온다", rationale="묶음 기준이 아닌 열은 GROUPING에 넣을 수 없어요."),
                  choice("C", "GROUPING(직급)이 모든 행에서 0으로 나온다", rationale="값을 돌려주지 않고 오류가 나요."),
                  choice("D", "GROUPING(직급)이 모든 행에서 NULL로 나온다", rationale="값을 돌려주지 않고 오류가 나요.")],
                 stem_sql="SELECT 부서번호, GROUPING(직급) FROM 사원 GROUP BY ROLLUP(부서번호);"),
        question(5, "`GROUP BY CUBE(부서번호, 직급)` 결과에서 대리 전체의 급여 합계를 보여 주는 행은 부서번호를 묶음에서 빼고 직급으로만 묶은 행이에요. 이 행의 `GROUPING_ID(부서번호, 직급)` 값은 무엇인가요?", "confusing",
                 "GROUPING(부서번호)는 1, GROUPING(직급)은 0이에요. 그래서 1 × 2 + 0 = 2예요.",
                 [choice("A", "1", rationale="1은 직급만 빠진 부서별 소계 행의 값이에요."),
                  choice("B", "3", rationale="3은 두 열이 모두 빠진 총계 행의 값이에요."),
                  choice("C", "2", True, "1 × 2 + 0 = 2예요."),
                  choice("D", "0", rationale="0은 두 열로 모두 묶은 일반 행의 값이에요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 원래 NULL 과 총계 NULL (ROLLUP 결과, GROUPING 값)
        ROLLUP_DEPARTMENT_EXAMPLE.check,
        ROLLUP_DEPARTMENT_GROUPING_EXAMPLE.check,
        sql_check("SELECT 부서번호, SUM(급여) AS 급여합계 FROM 사원 GROUP BY ROLLUP(부서번호) ORDER BY 부서번호",
                  ROLLUP_DEPARTMENT_ROWS, is_ordered=True),
        sql_check("SELECT 부서번호, SUM(급여) AS 급여합계, GROUPING(부서번호) FROM 사원 GROUP BY ROLLUP(부서번호) ORDER BY 부서번호",
                  ROLLUP_DEPARTMENT_GROUPING_ROWS, is_ordered=True),
        # 이름 붙이기 (CASE, TO_CHAR 없으면 오류, 두 열 DECODE)
        CASE_LABEL_EXAMPLE.check,
        TWO_COLUMN_LABEL_EXAMPLE.check,
        sql_check("SELECT CASE WHEN GROUPING(부서번호) = 1 THEN '전체' WHEN 부서번호 IS NULL THEN '미배정' "
                  "ELSE TO_CHAR(부서번호) END AS 부서, SUM(급여) AS 급여합계 FROM 사원 "
                  "GROUP BY ROLLUP(부서번호) ORDER BY GROUPING(부서번호), 부서번호",
                  CASE_LABEL_ROWS, is_ordered=True),
        sql_error_check("SELECT CASE WHEN GROUPING(부서번호) = 1 THEN '전체' ELSE 부서번호 END, SUM(급여) "
                        "FROM 사원 GROUP BY ROLLUP(부서번호)", "ORA-00932"),
        sql_check("SELECT DECODE(GROUPING(부서번호), 1, '전체', 부서번호) AS 부서, DECODE(GROUPING(직급), 1, '소계', 직급) AS 직급구분, "
                  "SUM(급여) AS 급여합계 FROM 사원 WHERE 부서번호 IN (20, 30) GROUP BY ROLLUP(부서번호, 직급) ORDER BY 부서번호, 직급",
                  TWO_COLUMN_LABEL_ROWS, is_ordered=True),
        # DECODE 만 쓰면 원래 NULL 유지
        DECODE_LABEL_EXAMPLE.check,
        sql_check("SELECT DECODE(GROUPING(부서번호), 1, '전체', 부서번호) AS 부서, SUM(급여) AS 급여합계 FROM 사원 GROUP BY ROLLUP(부서번호)",
                  DECODE_LABEL_ROWS),
        # HAVING 에서 총계만 제외
        HAVING_GROUPING_EXAMPLE.check,
        sql_check("SELECT 부서번호, SUM(급여) FROM 사원 GROUP BY ROLLUP(부서번호) HAVING GROUPING(부서번호) = 0",
                  ROLLUP_DEPARTMENT_ROWS[:4]),
        # GROUPING_ID (CUBE 묶음별 값, 대리 직급 소계 = 2)
        sql_check("SELECT DISTINCT GROUPING(부서번호), GROUPING(직급), GROUPING_ID(부서번호, 직급) FROM 사원 "
                  "WHERE 부서번호 IN (20, 30) GROUP BY CUBE(부서번호, 직급)",
                  [row[1:] for row in GROUPING_ID_ROWS]),
        sql_check("SELECT 부서번호, 직급, SUM(급여), GROUPING_ID(부서번호, 직급) FROM 사원 "
                  "WHERE 부서번호 IN (20, 30) GROUP BY CUBE(부서번호, 직급) HAVING GROUPING(부서번호) = 1 AND 직급 = '대리'",
                  [[None, "대리", 5500, 2]]),
        # 확인 문제 stemSql
        sql_check("SELECT 부서번호, SUM(급여), GROUPING(부서번호) FROM 사원 GROUP BY ROLLUP(부서번호);", ROLLUP_DEPARTMENT_GROUPING_ROWS),
        sql_check("SELECT DECODE(GROUPING(부서번호), 1, '전체', 부서번호) AS 부서, SUM(급여) FROM 사원 GROUP BY ROLLUP(부서번호);",
                  DECODE_LABEL_ROWS),
        sql_error_check("SELECT 부서번호, GROUPING(직급) FROM 사원 GROUP BY ROLLUP(부서번호);", "ORA-00979"),
    ],
}
