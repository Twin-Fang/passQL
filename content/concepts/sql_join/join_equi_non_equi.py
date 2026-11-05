"""개념: 등가 조인과 비등가 조인 (5단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import (DEPARTMENT_ROWS, DEPARTMENT_TABLE_MD, EMPLOYEE_ROWS, EMPLOYEE_TABLE_MD, SALARY_GRADE_ROWS,
                             SALARY_GRADE_TABLE_MD, to_markdown_table)

# 본문·문제 공통 SQL (sqlChecks 와 글이 같은 문장을 쓰도록 한 곳에 둠)
EQUI_JOIN_SQL = "SELECT E.이름, D.부서명 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호;"
GRADE_AT_LEAST_THREE_SQL = ("SELECT E.이름 FROM 사원 E, 급여등급 G "
                            "WHERE E.급여 BETWEEN G.최저급여 AND G.최고급여 AND G.등급 >= 3;")
THREE_TABLES_ONE_CONDITION_SQL = ("SELECT COUNT(*) FROM 사원 E, 부서 D, 급여등급 G "
                                  "WHERE E.부서번호 = D.부서번호;")

# 사원·부서 등가 조인 결과 7행 (윤서연·인사부 제외)
EQUI_JOIN_ROWS = [["김민수", "기획부"], ["이지은", "개발부"], ["박서준", "개발부"], ["정하늘", "개발부"],
                  ["최유나", "영업부"], ["한도윤", "영업부"], ["오지민", "영업부"]]
# 비등가 조인 결과 8행 (이름, 급여, 등급), 급여 > 사번 순
NON_EQUI_ROWS = [["윤서연", 2000, 1], ["오지민", 2200, 1], ["이지은", 2500, 2], ["정하늘", 2500, 2],
                 ["한도윤", 2700, 3], ["박서준", 2800, 3], ["김민수", 3000, 4], ["최유나", 3200, 4]]

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본, 조인 결과 순서는 보장 안 됨 > 정렬 없는 예시는 순서 무시)
ORACLE_EQUI_EXAMPLE = sql_example(
    "SELECT 사원.이름, 부서.부서명\nFROM 사원, 부서\nWHERE 사원.부서번호 = 부서.부서번호;",
    ("이름", "부서명"), EQUI_JOIN_ROWS, is_ordered=False)
# 급여 동점(이지은·정하늘 2500)은 사번으로 순서 고정
NON_EQUI_EXAMPLE = sql_example(
    "SELECT E.이름, E.급여, G.등급\nFROM 사원 E, 급여등급 G\nWHERE E.급여 BETWEEN G.최저급여 AND G.최고급여\n"
    "ORDER BY E.급여, E.사번;",
    ("이름", "급여", "등급"), NON_EQUI_ROWS)
THREE_TABLES_EXAMPLE = sql_example(
    "SELECT E.이름, D.부서명, G.등급\nFROM 사원 E, 부서 D, 급여등급 G\nWHERE E.부서번호 = D.부서번호\n"
    "  AND E.급여 BETWEEN G.최저급여 AND G.최고급여;",
    ("이름", "부서명", "등급"),
    [["김민수", "기획부", 4], ["이지은", "개발부", 2], ["박서준", "개발부", 3], ["정하늘", "개발부", 2],
     ["최유나", "영업부", 4], ["한도윤", "영업부", 3], ["오지민", "영업부", 1]], is_ordered=False)
EXTRA_FILTER_EXAMPLE = sql_example(
    "SELECT E.이름, D.부서명\nFROM 사원 E, 부서 D\nWHERE E.부서번호 = D.부서번호\n  AND E.급여 >= 2800;",
    ("이름", "부서명"), [["김민수", "기획부"], ["박서준", "개발부"], ["최유나", "영업부"]], is_ordered=False)

# 조인 연결 그림 (#853): 위 검증된 결과 행 > 잇는 값이 보이는 행 글 (부서번호, 급여·등급 범위)
JOIN_DIAGRAM_COLUMNS = ("왼쪽 행", "오른쪽 행")
_EMPLOYEE_BY_NAME = {row[1]: row for row in EMPLOYEE_ROWS}
_DEPARTMENT_BY_NAME = {row[1]: row for row in DEPARTMENT_ROWS}
_GRADE_BY_NUMBER = {row[0]: row for row in SALARY_GRADE_ROWS}
# "김민수 (10)" | "기획부 (10)"
EQUI_JOIN_DIAGRAM_MD = to_markdown_table(JOIN_DIAGRAM_COLUMNS, [
    [f"{name} ({_EMPLOYEE_BY_NAME[name][7]})", f"{department} ({_DEPARTMENT_BY_NAME[department][0]})"]
    for name, department in EQUI_JOIN_ROWS])
# "윤서연 2000" | "1등급 0~2299"
NON_EQUI_DIAGRAM_MD = to_markdown_table(JOIN_DIAGRAM_COLUMNS, [
    [f"{name} {salary}", f"{grade}등급 {_GRADE_BY_NUMBER[grade][1]}~{_GRADE_BY_NUMBER[grade][2]}"]
    for name, salary, grade in NON_EQUI_ROWS])

CONCEPT = {
    "tagKey": "join-equi-non-equi",
    "topicCode": "sql_join",
    "sortOrder": 1,
    "title": "등가 조인과 비등가 조인",
    "summary": "같은 값끼리 잇는 것이 등가 조인, 범위로 잇는 것이 비등가 조인이에요",
    "coreMd": (
        "- 조인은 정규화로 나뉜 표를 공통된 값으로 다시 이어서 한 번에 조회하는 방법이에요.\n"
        "- 등가 조인은 `=`로 같은 값을 잇고, 비등가 조인은 `BETWEEN`이나 `>=`처럼 `=`가 아닌 조건으로 이어요.\n"
        "- 두 표에 같은 이름의 열이 있으면 `E.부서번호`처럼 접두사를 붙이고, 별칭을 정했으면 별칭만 써요.\n"
        "- 표 N개를 이으려면 조인 조건이 최소 N-1개 필요하고, 하나가 빠지면 결과가 몇 배로 불어나요."
    ),
    "detailMd": f"""## 왜 조인이 필요한가요 — 나뉜 표를 다시 잇기 {{#why}}

1단원의 정규화는 같은 사실을 한 곳에만 적으려고 표를 나눠요. 그래서 사원 표에는 부서번호만 있고, 부서 이름과 지역은 부서 표에 따로 있어요.

{EMPLOYEE_TABLE_MD}

{DEPARTMENT_TABLE_MD}

사원 이름과 부서 이름을 함께 보려면 두 표에서 부서번호가 같은 행끼리 짝지어 한 줄로 붙여야 해요. 이 일을 조인(JOIN)이라고 하고, 이 개념의 예시는 모두 위 두 표로 계산해요.

## 한 줄 정의 — 같은 값이면 등가, 범위면 비등가 {{#definition}}

| 용어 | 뜻 |
|---|---|
| 조인 | 두 개 이상의 표에서 조건에 맞는 행끼리 짝지어 하나의 결과로 만드는 거예요 |
| 조인 조건 | 어떤 행끼리 짝지을지 정하는 조건이에요. 예: `E.부서번호 = D.부서번호` |
| 등가 조인 (EQUI JOIN) | 조인 조건에 `=`를 써서 값이 같은 행끼리 이어요 |
| 비등가 조인 (NON-EQUI JOIN) | `BETWEEN`, `>`, `<=`처럼 `=`가 아닌 연산자로 이어요. 예: 급여가 등급 범위 안에 드는지 |

## Oracle 방식으로 쓰기 — FROM에 쉼표, WHERE에 조건 {{#oracle-syntax}}

Oracle에서 오래 써 온 방식은 FROM 절에 표를 쉼표로 나열하고 WHERE 절에 조인 조건을 적는 거예요. 다음 개념의 `JOIN ... ON`은 ANSI 표준 문법인데, 결과는 같아요.

{ORACLE_EQUI_EXAMPLE.markdown}

괄호 안의 부서번호가 같은 행끼리 선으로 이어져요.

{EQUI_JOIN_DIAGRAM_MD}

데이터베이스는 사원 한 행마다 부서 네 행과 차례로 비교해서, 조건이 참인 짝만 남겨요. 사원은 8명인데 결과가 7행인 까닭은 아래 두 행이 짝을 찾지 못했기 때문이에요.

| 빠진 행 | 이유 |
|---|---|
| 윤서연 (1008) | 부서번호가 NULL이에요. NULL과 비교하면 참도 거짓도 아닌 UNKNOWN(알 수 없음)이 되고, WHERE 절은 참인 짝만 남겨요 |
| 인사부 (40) | 부서번호가 40인 사원이 없어요 |

## 열 이름이 겹칠 때 — 접두사와 별칭 {{#qualifier}}

| 용어 | 뜻 |
|---|---|
| 접두사 | 열 이름 앞에 붙여 어느 표의 열인지 밝히는 표시예요. 예: `사원.부서번호`, `E.부서번호` |
| 테이블 별칭 | FROM 절에서 표에 붙이는 짧은 별명이에요. `FROM 사원 E`는 이 문장 안에서 사원 표를 E라고 부르겠다는 뜻이에요 |

사원 표와 부서 표에는 둘 다 `부서번호`가 있어서, 접두사 없이 쓰면 어느 표의 열인지 알 수 없어요. 한쪽 표에만 있는 `이름`과 `부서명`은 접두사 없이 써도 되지만, 붙여 두면 읽기가 쉬워요.

```sql
SELECT 이름, 부서명, 부서번호 FROM 사원, 부서 WHERE 사원.부서번호 = 부서.부서번호;  -- 오류: 부서번호가 두 표에 다 있어요 (ORA-00918, 열 이름이 모호함)
SELECT E.이름, D.부서명, E.부서번호 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호;  -- 접두사를 붙이면 실행돼요
SELECT 사원.이름 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호;  -- 오류: 별칭을 정했으면 별칭만 써요 (ORA-00904, 없는 열 이름)
SELECT E.이름 FROM 사원 AS E, 부서 D WHERE E.부서번호 = D.부서번호;  -- 오류: 테이블 별칭 앞에는 AS를 못 써요 (ORA-00933, 문법에 맞지 않는 단어)
```

## 비등가 조인 — 급여가 범위 안에 들면 짝 {{#non-equi}}

급여등급 표에는 사원 표와 같은 값을 가진 열이 없어요. 대신 급여가 최저급여와 최고급여 사이에 들면 그 등급이 되므로, `=` 대신 `BETWEEN`으로 이어요.

{SALARY_GRADE_TABLE_MD}

{NON_EQUI_EXAMPLE.markdown}

급여가 최저급여와 최고급여 사이에 드는 등급으로 선이 이어져요.

{NON_EQUI_DIAGRAM_MD}

등급 범위가 겹치지도 비지도 않아서 사원마다 등급이 하나씩 붙고, 부서번호는 비교하지 않으니 부서가 없는 윤서연도 들어가요. 맨 끝의 `ORDER BY`는 결과를 급여가 낮은 순서로, 같으면 사번 순서로 정렬해요.

비등가 조인에도 행을 거르는 조건을 `AND`로 더 붙일 수 있는데, 두 단계로 나눠 세면 쉬워요.

| 단계 | 내용 |
|---|---|
| 짝짓기 | BETWEEN 조건으로 사원마다 등급 하나를 붙여 8행을 만들어요 |
| 거르기 | `AND G.등급 = 2`처럼 더 붙인 조건에 맞는 행만 남겨요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 위 비등가 조인에 `AND G.등급 = 2`를 더 붙이면 이지은과 정하늘 2행이 남아요 | O | 8행 가운데 등급이 2인 행은 급여 2500인 두 사람뿐이에요 |

## 표 세 개를 이을 때 — 조인 조건은 최소 N-1개 {{#n-minus-one}}

표 N개를 빠짐없이 이으려면 조인 조건이 최소 N-1개 필요해요. 사원, 부서, 급여등급 세 표라면 사원과 부서를 잇는 조건, 사원과 급여등급을 잇는 조건이 하나씩 있어야 해요.

{THREE_TABLES_EXAMPLE.markdown}

부서 조건에서 윤서연이 빠지고, 남은 일곱 명이 등급 하나씩과 짝지어져 7행이 돼요. 여기서 BETWEEN 조건을 빠뜨리면 이 7행 하나하나가 급여등급 4행과 모두 짝지어져서 네 배로 불어나요.

```sql
SELECT COUNT(*)
FROM 사원 E, 부서 D, 급여등급 G
WHERE E.부서번호 = D.부서번호;  -- BETWEEN 조건이 빠져서 28이 나와요
```

`COUNT(*)`는 결과 행이 몇 개인지 세어 숫자 하나로 돌려주는 함수예요(7단원에서 자세히 다뤄요).

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 표 4개를 이을 때 조인 조건이 2개면 충분해요 | X | 표 N개에는 조건이 최소 N-1개, 곧 3개가 필요해요 |

## 자주 헷갈리는 점 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| 등가 조인은 기본키와 외래키로만 해요 | 값을 비교할 수 있는 열이면 무엇이든 `=`로 이을 수 있어요. 기본키(행을 하나씩 구별하는 열)와 외래키(다른 표의 기본키를 가리키는 열)를 잇는 경우가 많을 뿐이에요 |
| 비등가 조인은 조인 조건이 없는 조인이에요 | 조건은 있고, 그 연산자가 `=`가 아닐 뿐이에요. 조건이 아예 없으면 모든 행이 서로 짝지어지는 카티션 곱이 되고, CROSS JOIN 개념에서 다뤄요 |
| 사원이 8명이니 등가 조인 결과도 8행이에요 | 조인 열이 NULL인 윤서연과 짝이 없는 인사부가 빠져서 7행이에요. 짝이 없는 행까지 남기는 방법은 OUTER JOIN에서 배워요 |
| 별칭을 정해도 테이블 이름으로 열을 부를 수 있어요 | `FROM 사원 E`라고 썼다면 그 문장 안에서는 `E.이름`으로만 불러요 |
| AS는 열 별칭에도 테이블 별칭에도 붙여요 | Oracle에서 AS는 `SELECT 이름 AS 사원명`처럼 열 별칭에만 붙여요. `FROM 사원 AS E`는 오류예요 |
| 조인 조건은 정확히 N-1개여야 해요 | N-1은 최소 개수예요. 행을 거르는 조건은 몇 개를 더 붙여도 되고, 그만큼 결과 행이 줄어요 |
| 비등가 조인은 사원마다 늘 한 행이에요 | 범위가 겹치면 행이 늘어요. `E.급여 >= G.최저급여` 하나만 쓰면 최유나(3200)는 1~4등급과 모두 짝지어지고, 전체 결과는 20행이 돼요 |

아래 SQL은 조인 조건 하나에 거르는 조건 하나를 더 붙였어요. 조인한 7행 가운데 급여가 2800 이상인 세 명만 남아요.

{EXTRA_FILTER_EXAMPLE.markdown}

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| `SELECT 이름 AS 사원명`처럼 열 별칭 앞에는 AS를 붙일 수 있어요 | O | AS를 붙일 수 없는 쪽은 FROM 절의 테이블 별칭이에요 |
| 범위가 겹치는 표로 비등가 조인을 하면 오류가 나요 | X | 오류 없이 한 행이 여러 등급과 짝지어져서 결과 행이 늘어나요 |

## 시험에서는 이렇게 나와요 {{#exam-point}}

| 나오는 문제 | 푸는 법 |
|---|---|
| 등가 조인 결과가 몇 행인가 | 조인 열이 NULL인 행과 상대 표에 짝이 없는 행을 지우고 세요 |
| 급여등급 같은 범위 표의 비등가 조인 결과 | 사원마다 범위에 드는 등급을 붙인 뒤, 더 붙은 조건으로 걸러요 |
| 오류가 나는 SQL 고르기 | 겹치는 열의 접두사, 별칭 대신 쓴 테이블 이름, 테이블 별칭 앞의 AS를 찾아요 |
| 표 N개에 필요한 조인 조건 수 | 최소 N-1개이고, 조건이 빠진 표는 그 행 수만큼 결과를 곱해요 |""",
    "checkQuestions": [
        question(1, "조인 조건에 `=`가 아닌 `BETWEEN`이나 `>=`를 써서 범위로 행을 짝짓는 조인은 무엇인가요?", "definition",
                 "조인 조건에 `=`가 아닌 연산자를 쓰면 비등가 조인이에요. 급여가 범위 안에 드는 급여등급을 찾는 것이 대표적인 예예요.",
                 [choice("A", "등가 조인", rationale="등가 조인은 = 연산자로 같은 값끼리 짝지어요."),
                  choice("B", "비등가 조인", True, "= 가 아닌 조건으로 짝지으면 비등가 조인이에요."),
                  choice("C", "조인 조건이 없는 조인", rationale="비등가 조인에도 BETWEEN 같은 조인 조건이 있어요."),
                  choice("D", "자기 자신과 잇는 조인", rationale="같은 표끼리 잇는 것은 셀프 조인이고, 연산자 종류와는 상관없어요.")]),
        question(2, "본문의 사원 표(8명)와 부서 표(4개)에 다음 SQL을 실행하면 몇 행이 나오나요?", "oracle-syntax",
                 "부서번호가 NULL인 윤서연은 어느 부서와도 짝이 맞지 않고, 인사부(40)는 소속 사원이 없어요. 그래서 짝이 맞는 7행만 나와요.",
                 [choice("A", "8행", rationale="부서번호가 NULL인 윤서연은 짝이 맞지 않아 빠져요."),
                  choice("B", "9행", rationale="짝이 없는 윤서연과 인사부는 등가 조인 결과에 들어가지 않아요."),
                  choice("C", "7행", True, "짝이 맞는 사원 7명만 남아요."),
                  choice("D", "32행", rationale="32행은 조인 조건이 없을 때 생기는 카티션 곱의 행 수예요.")],
                 stem_sql=EQUI_JOIN_SQL),
        question(3, "다음 중 실행하면 오류가 나는 SQL은 무엇인가요?", "qualifier",
                 "FROM 절에서 사원 표에 별칭 E를 정했다면 그 문장 안에서는 `사원.이름`이 아니라 `E.이름`으로 써야 해요. 나머지는 모두 정상 실행돼요.",
                 [choice("A", "SELECT 사원.이름 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호", True,
                         "별칭 E를 정했는데 테이블 이름으로 열을 불러서 없는 열 이름이라는 오류가 나요."),
                  choice("B", "SELECT 이름, 부서명 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호",
                         rationale="이름과 부서명은 한쪽 표에만 있어서 접두사가 없어도 실행돼요."),
                  choice("C", "SELECT 사원.이름 FROM 사원, 부서 WHERE 사원.부서번호 = 부서.부서번호",
                         rationale="별칭을 정하지 않았으니 테이블 이름을 접두사로 써도 돼요."),
                  choice("D", "SELECT E.이름 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호",
                         rationale="정한 별칭을 그대로 썼으니 정상 실행돼요.")]),
        question(4, "본문의 사원 표와 아래 급여등급 표로 다음 SQL을 실행하면 몇 행이 나오나요?\n\n" + SALARY_GRADE_TABLE_MD, "non-equi",
                 "사원마다 급여가 드는 등급 하나와 짝이 지어진 8행에서, 3등급 이상(급여 2700 이상)만 남겨요. 한도윤, 박서준, 김민수, 최유나 네 명이에요.",
                 [choice("A", "2행", rationale="4등급(김민수, 최유나)만 세었어요. 3등급인 한도윤과 박서준도 들어가요."),
                  choice("B", "8행", rationale="등급이 3 이상이라는 조건 때문에 1, 2등급 사원은 빠져요."),
                  choice("C", "16행", rationale="BETWEEN 조건이 있어서 사원마다 등급은 하나씩만 짝이 지어져요."),
                  choice("D", "4행", True, "급여 2700 이상인 사원 네 명이 남아요.")],
                 stem_sql=GRADE_AT_LEAST_THREE_SQL),
        question(5, "사원(8행), 부서(4행), 급여등급(4행) 세 표를 조인하면서 조건을 하나만 적었어요. `COUNT(*)`는 결과 행의 개수를 세요. 다음 SQL의 결과는 무엇인가요?", "n-minus-one",
                 "표가 세 개면 조인 조건이 최소 두 개 필요한데 급여등급과 잇는 조건이 빠졌어요. 사원과 부서를 이은 7행이 등급 4행과 모두 짝지어져 7 × 4 = 28이 돼요.",
                 [choice("A", "7", rationale="급여등급 표가 조건 없이 붙어서 7행이 네 배로 늘어나요."),
                  choice("B", "28", True, "사원과 부서를 이은 7행 × 급여등급 4행이에요."),
                  choice("C", "32", rationale="사원과 부서 사이에는 조건이 있어서 7행에서 시작해요."),
                  choice("D", "128", rationale="8 × 4 × 4는 조건이 하나도 없을 때의 행 수예요.")],
                 stem_sql=THREE_TABLES_ONE_CONDITION_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문 예시 4개 (sql_example: Oracle 방식 등가 조인, 비등가 조인, 표 세 개, 거르는 조건 추가)
        ORACLE_EQUI_EXAMPLE.check,
        NON_EQUI_EXAMPLE.check,
        THREE_TABLES_EXAMPLE.check,
        EXTRA_FILTER_EXAMPLE.check,
        # 본문: 별칭·접두사, 등급 2 거르기, 겹치는 범위
        sql_check(EQUI_JOIN_SQL, EQUI_JOIN_ROWS),
        sql_error_check("SELECT 이름, 부서명, 부서번호 FROM 사원, 부서 WHERE 사원.부서번호 = 부서.부서번호", "ORA-00918"),
        sql_error_check("SELECT E.이름 FROM 사원 AS E, 부서 D WHERE E.부서번호 = D.부서번호", "ORA-00933"),
        sql_check("SELECT 이름 AS 사원명 FROM 사원 WHERE 사번 = 1001", [["김민수"]]),
        sql_check("SELECT E.이름, E.급여, G.등급 FROM 사원 E, 급여등급 G "
                  "WHERE E.급여 BETWEEN G.최저급여 AND G.최고급여 AND G.등급 = 2",
                  [["이지은", 2500, 2], ["정하늘", 2500, 2]]),
        sql_check("SELECT COUNT(*) FROM 사원 E, 급여등급 G WHERE E.급여 >= G.최저급여", [[20]]),
        sql_check("SELECT G.등급 FROM 사원 E, 급여등급 G WHERE E.급여 >= G.최저급여 AND E.사번 = 1004",
                  [[1], [2], [3], [4]]),
        # 확인 문제: stemSql, 3번 보기 4개
        sql_check(GRADE_AT_LEAST_THREE_SQL, [["한도윤"], ["박서준"], ["김민수"], ["최유나"]]),
        sql_check(THREE_TABLES_ONE_CONDITION_SQL, [[28]]),
        sql_error_check("SELECT 사원.이름 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호", "ORA-00904"),
        sql_check("SELECT 이름, 부서명 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호", EQUI_JOIN_ROWS),
        sql_check("SELECT 사원.이름 FROM 사원, 부서 WHERE 사원.부서번호 = 부서.부서번호", [[row[0]] for row in EQUI_JOIN_ROWS]),
        sql_check("SELECT E.이름 FROM 사원 E, 부서 D WHERE E.부서번호 = D.부서번호", [[row[0]] for row in EQUI_JOIN_ROWS]),
    ],
}
