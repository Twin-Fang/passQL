"""개념: 셀프 조인 (5단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import EMPLOYEE_TABLE_MD

# 본문·문제 공통 SQL
EMPLOYEE_MANAGER_SQL = "SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E, 사원 M WHERE E.관리자사번 = M.사번;"
MANAGER_NAME_SQL = "SELECT M.이름 AS 관리자 FROM 사원 E JOIN 사원 M ON E.관리자사번 = M.사번;"
EARNS_MORE_THAN_MANAGER_SQL = ("SELECT E.이름 FROM 사원 E JOIN 사원 M "
                               "ON E.관리자사번 = M.사번 WHERE E.급여 > M.급여;")

# 사원-관리자 짝 7행 (김민수는 관리자 없음)
EMPLOYEE_MANAGER_ROWS = [["이지은", "김민수"], ["최유나", "김민수"], ["윤서연", "김민수"], ["박서준", "이지은"],
                         ["정하늘", "이지은"], ["한도윤", "최유나"], ["오지민", "최유나"]]
# 관리자 쪽(M)을 기준으로 남긴 12행: 짝 7행 + 부하가 없는 사원 5명
MANAGER_SIDE_OUTER_ROWS = EMPLOYEE_MANAGER_ROWS + [[None, name] for name in ("박서준", "정하늘", "한도윤", "오지민", "윤서연")]

CONCEPT = {
    "tagKey": "join-self",
    "topicCode": "sql_join",
    "sortOrder": 6,
    "title": "셀프 조인",
    "summary": "같은 표를 별칭 두 개로 두 번 읽어, 사원과 관리자를 짝지어요",
    "coreMd": (
        "- 셀프 조인은 한 표를 자기 자신과 조인하는 것이고, 같은 표를 두 번 읽으므로 `사원 E, 사원 M`처럼 서로 다른 별칭을 꼭 붙여요.\n"
        "- 사원과 관리자를 짝지을 때는 \"사원 쪽의 관리자사번 = 관리자 쪽의 사번\"으로 이어요.\n"
        "- 관리자사번이 NULL인 김민수는 짝이 없어 빠지므로 결과는 7행이고, 김민수까지 보려면 사원 쪽을 기준으로 외부 조인해 8행을 만들어요.\n"
        "- 관리자의 관리자는 같은 표를 세 번 읽어 찾고, 단계 수가 정해지지 않은 위아래 관계는 9단원의 계층 쿼리로 다뤄요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

사원 표에는 관리자사번이라는 열이 있어요. 관리자도 회사의 사원이라서, 관리자의 정보는 다른 표가 아니라 같은 사원 표 안에 들어 있어요. 이 개념의 예시는 모두 아래 사원 표(8명)로 계산해요.

{EMPLOYEE_TABLE_MD}

이지은의 관리자사번은 1001이에요. 그런데 1001이 누구인지 알려면 같은 사원 표에서 사번이 1001인 행을 다시 찾아야 해요. 표 하나 안에서 행과 행을 짝지어야 하는 셈인데, 이럴 때 쓰는 방법이 셀프 조인이에요.

## 한 줄 정의 {{#definition}}

셀프 조인(SELF JOIN)은 같은 표를 두 번 읽어서 자기 자신과 조인하는 것이에요. `SELF JOIN`이라는 키워드가 따로 있는 것은 아니고, FROM 절에 같은 표를 두 번 쓰고 별칭을 다르게 붙이면 돼요. 사원 표를 두 장 복사해서, 한 장(E)은 사원 역할로, 다른 한 장(M)은 관리자 역할로 본다고 생각하면 이해하기 쉬워요.

## 사원과 관리자 짝짓기 {{#example}}

사원 쪽(E)의 관리자사번과 관리자 쪽(M)의 사번이 같은 행끼리 이으면, 사원 이름 옆에 관리자 이름이 붙어요. SELECT 절의 `AS 사원`, `AS 관리자`는 결과 열에 보여 줄 이름을 정하는 별칭이에요. 두 열이 모두 `이름`이라서, 별칭이 없으면 결과에서 어느 쪽이 사원이고 어느 쪽이 관리자인지 구분하기 어려워요.

```sql
SELECT E.이름 AS 사원, M.이름 AS 관리자
FROM 사원 E, 사원 M
WHERE E.관리자사번 = M.사번;
```

| 사원 | 관리자 |
|---|---|
| 이지은 | 김민수 |
| 최유나 | 김민수 |
| 윤서연 | 김민수 |
| 박서준 | 이지은 |
| 정하늘 | 이지은 |
| 한도윤 | 최유나 |
| 오지민 | 최유나 |

ANSI 문법으로는 `FROM 사원 E JOIN 사원 M ON E.관리자사번 = M.사번`이라고 쓰고, 결과는 같아요. 결과는 7행인데, 관리자 수(3명)가 아니라 관리자가 있는 사원 수(7명)만큼 나와요. 김민수처럼 부하가 여러 명인 관리자는 부하 수만큼 반복해서 나와요.

## 김민수가 빠지는 이유 {{#outer}}

사장인 김민수는 관리자사번이 NULL이에요. NULL과 `=`로 비교하면 결과가 참도 거짓도 아닌 UNKNOWN(알 수 없음)이 되고 조인은 참인 짝만 남기므로, 김민수는 관리자 쪽의 어느 행과도 짝이 맞지 않아 결과에서 빠져요. 김민수도 사원 명단에 남기려면, 사원 쪽(E)을 기준으로 LEFT OUTER JOIN을 하면 돼요.

```sql
SELECT E.이름 AS 사원, M.이름 AS 관리자
FROM 사원 E LEFT JOIN 사원 M
  ON E.관리자사번 = M.사번;
```

이 SQL은 앞의 7행에 `김민수 | NULL` 한 행이 더해져 8행을 돌려줘요.

Oracle 방식으로 쓸 때는 짝이 없을 때 NULL로 채워질 쪽, 즉 관리자 쪽(M)의 열에 `(+)`를 붙여 `WHERE E.관리자사번 = M.사번(+)`라고 써요. `(+)`를 사원 쪽에 붙여 `WHERE E.관리자사번(+) = M.사번`이라고 쓰면 반대로 관리자 쪽이 기준이 되어, 아래 헷갈리는 점에서 볼 RIGHT JOIN과 같은 결과가 나와요.

## 관리자의 관리자 {{#two-levels}}

관리자의 관리자를 찾으려면 사원 표를 한 번 더 읽어서, 관리자 쪽(M)의 관리자사번을 세 번째 별칭(T)의 사번과 이어요.

```sql
SELECT E.이름 AS 사원, M.이름 AS 관리자, T.이름 AS 윗관리자
FROM 사원 E
  JOIN 사원 M ON E.관리자사번 = M.사번
  JOIN 사원 T ON M.관리자사번 = T.사번;
```

| 사원 | 관리자 | 윗관리자 |
|---|---|---|
| 박서준 | 이지은 | 김민수 |
| 정하늘 | 이지은 | 김민수 |
| 한도윤 | 최유나 | 김민수 |
| 오지민 | 최유나 | 김민수 |

결과는 4행이에요. 이지은, 최유나, 윤서연의 관리자는 김민수예요. 그런데 김민수의 관리자사번이 NULL이라서, 세 번째로 읽은 표(T)에서 김민수의 관리자를 찾지 못해요. 그래서 이 세 명은 두 번째 조인에서 빠져요. 김민수 자신은 관리자사번이 NULL이라 첫 번째 조인에서 이미 빠졌어요. 남는 사람은 관리자의 관리자까지 있는 박서준, 정하늘, 한도윤, 오지민 네 명이에요.

이렇게 단계가 하나 늘 때마다 같은 표를 한 번씩 더 읽어야 해요. 조직도처럼 몇 단계까지 이어지는지 모르는 위아래 관계를 한 번에 따라가려면 `START WITH`와 `CONNECT BY`를 쓰는 계층 쿼리가 필요한데, 이 문법은 9단원에서 배워요.

## 자주 헷갈리는 점 {{#confusing}}

**별칭이 없으면 어느 쪽 표인지 구분할 수 없어요.** 같은 표를 두 번 쓰면서 별칭을 붙이지 않으면, 테이블 이름을 접두사로 붙여도 두 표의 이름이 같아서 구분이 되지 않아요. 그래서 ORA-00918(열 이름이 모호함) 오류가 나요.

```sql
SELECT 이름 FROM 사원, 사원 WHERE 사원.관리자사번 = 사원.사번;           -- 오류: 두 사원 표를 구분할 수 없어요 (ORA-00918, 열 이름이 모호함)
SELECT E.이름 FROM 사원 E, 사원 M WHERE E.관리자사번 = M.사번;            -- 별칭을 붙이면 실행돼요
```

**조건의 방향을 바꾸면 역할도 바뀌어요.** `E.관리자사번 = M.사번`에서는 E가 사원이고 M이 관리자예요. 조건을 `E.사번 = M.관리자사번`으로 바꾸면 E가 관리자, M이 부하가 돼요. 짝지어지는 행은 똑같이 7행이지만, `E.이름`이 가리키는 사람이 달라지므로 SELECT 절의 별칭과 조건을 함께 맞춰서 읽어야 해요.

```sql
SELECT E.이름 AS 관리자, M.이름 AS 부하
FROM 사원 E, 사원 M
WHERE E.사번 = M.관리자사번;
```

이 SQL은 `김민수 | 이지은`, `이지은 | 박서준`처럼 앞 열에 관리자가 오는 7행을 돌려줘요.

**외부 조인의 기준을 잘못 고르면 다른 사람이 남아요.** 김민수를 살리려고 `사원 E RIGHT JOIN 사원 M ON E.관리자사번 = M.사번`이라고 쓰면, 오른쪽에 쓴 관리자 쪽(M)이 기준이 돼요. 결과 행 수는 두 부분으로 나눠 세면 돼요.

1. 짝이 맞는 행은 INNER JOIN과 같은 7행이에요. 부하가 있는 김민수(3명), 이지은(2명), 최유나(2명)가 관리자 칸에 부하 수만큼 나와요.
2. 관리자 쪽(M)에 놓인 사원 8명 가운데 부하가 한 명도 없는 사람은 짝이 없어요. 사원 표에서 관리자사번 열에 한 번도 나오지 않는 박서준, 정하늘, 한도윤, 오지민, 윤서연 다섯 명이에요. 이들은 기준 쪽이라 버려지지 않고, 사원 칸이 NULL인 행으로 하나씩 남아요.

그래서 결과는 7 + 5 = 12행이고, 늘어난 다섯 행은 다음과 같아요.

| 사원 | 관리자 |
|---|---|
| NULL | 박서준 |
| NULL | 정하늘 |
| NULL | 한도윤 |
| NULL | 오지민 |
| NULL | 윤서연 |

어디에도 김민수가 사원 칸에 나오는 행은 없어요. 관리자가 없는 사원을 남기려면 사원 쪽(E)이 기준이어야 하므로 LEFT JOIN을 써야 해요.

**같은 표 안의 두 행을 비교할 수도 있어요.** 셀프 조인을 하면 한 행에 사원의 값과 관리자의 값이 나란히 놓여서, 두 값을 바로 비교할 수 있어요. 아래 SQL은 관리자보다 급여가 많은 사원을 찾는데, 최유나(3200 > 김민수 3000)와 박서준(2800 > 이지은 2500)이 나와요.

```sql
SELECT E.이름, E.급여, M.이름 AS 관리자, M.급여 AS 관리자급여
FROM 사원 E JOIN 사원 M ON E.관리자사번 = M.사번
WHERE E.급여 > M.급여;
```

## 시험에서는 이렇게 나와요 {{#exam-point}}

사원-관리자 표를 주고 셀프 조인 결과가 몇 행인지, 특정 사원의 관리자가 누구인지 묻는 문제가 가장 많아요. 행 수를 셀 때는 관리자사번이 NULL인 행부터 빼면 되고, 외부 조인이 붙었다면 어느 쪽이 기준인지부터 확인해요. 관리자의 관리자를 찾는 SQL을 고르는 문제나, 별칭 없이 같은 표를 두 번 써서 오류가 나는 SQL을 고르는 문제도 나와요.""",
    "checkQuestions": [
        question(1, "사원 표 하나로 셀프 조인을 하려면 꼭 필요한 것은 무엇인가요?", "definition",
                 "셀프 조인은 같은 표를 두 번 읽으므로, 두 번 읽은 표를 구분할 서로 다른 별칭이 꼭 필요해요. 별도 키워드나 외부 조인은 필요하지 않아요.",
                 [choice("A", "SELF JOIN이라는 키워드", rationale="SELF JOIN이라는 키워드는 따로 없고 같은 표를 두 번 쓰면 돼요."),
                  choice("B", "이름이 같은 열을 가진 다른 표", rationale="셀프 조인은 다른 표 없이 같은 표끼리 이어요."),
                  choice("C", "같은 표에 붙인 서로 다른 별칭 두 개", True, "두 번 읽은 표를 구분하려면 별칭이 달라야 해요."),
                  choice("D", "LEFT OUTER JOIN", rationale="외부 조인은 짝 없는 행을 남길 때만 쓰고, 셀프 조인에 꼭 필요하지는 않아요.")]),
        question(2, "본문의 사원 표에서 관리자사번이 NULL인 사원은 김민수 한 명이에요. 다음 SQL은 몇 행을 돌려주나요?", "example",
                 "관리자사번이 NULL인 김민수는 짝이 맞지 않아 빠지고, 관리자가 있는 사원 7명이 한 행씩 나와요.",
                 [choice("A", "8행", rationale="관리자사번이 NULL인 김민수는 짝이 없어 빠져요."),
                  choice("B", "7행", True, "관리자가 있는 사원 7명만 짝이 맞아요."),
                  choice("C", "3행", rationale="관리자 수를 세었어요. 결과는 사원마다 한 행이에요."),
                  choice("D", "64행", rationale="64행은 조인 조건이 없을 때의 8 × 8 결과예요.")],
                 stem_sql=EMPLOYEE_MANAGER_SQL),
        question(3, "`SELECT E.이름 AS 사원, M.이름 AS 관리자`의 사원 칸에 김민수까지 8명이 모두 나오게 하려면 FROM 절을 어떻게 써야 하나요?", "outer",
                 "관리자사번이 NULL인 김민수를 남기려면 사원 쪽(E)을 기준으로 외부 조인해야 해요. 관리자 쪽(M)을 기준으로 하면 부하 없는 사원들이 관리자 칸에 남을 뿐이에요.",
                 [choice("A", "FROM 사원 E JOIN 사원 M ON E.관리자사번 = M.사번", rationale="INNER JOIN이라 김민수가 빠진 7행이 나와요."),
                  choice("B", "FROM 사원 E RIGHT JOIN 사원 M ON E.관리자사번 = M.사번", rationale="관리자 쪽이 기준이 되어 사원 칸이 NULL인 행만 늘어나요."),
                  choice("C", "FROM 사원 E, 사원 M WHERE E.관리자사번(+) = M.사번", rationale="사원 쪽에 (+)가 붙어 관리자 쪽이 기준인 RIGHT JOIN과 같아요."),
                  choice("D", "FROM 사원 E LEFT JOIN 사원 M ON E.관리자사번 = M.사번", True, "사원 쪽이 기준이라 김민수가 관리자 NULL로 남아요.")]),
        question(4, "본문의 사원 표에 다음 SQL을 실행하면 결과에서 '김민수'는 몇 번 나오나요?", "example",
                 "김민수를 관리자사번으로 가진 사원은 이지은, 최유나, 윤서연 세 명이에요. 관리자는 부하 수만큼 반복해서 나와요.",
                 [choice("A", "3번", True, "부하 세 명과 한 번씩 짝지어져요."),
                  choice("B", "1번", rationale="관리자는 한 번만 나오는 것이 아니라 부하 수만큼 반복돼요."),
                  choice("C", "0번", rationale="김민수는 사원 칸에서는 빠지지만 관리자 칸에는 나와요."),
                  choice("D", "7번", rationale="7은 전체 결과 행 수이고, 그중 김민수가 관리자인 행은 일부예요.")],
                 stem_sql=MANAGER_NAME_SQL),
        question(5, "아래 사원 표에 다음 SQL을 실행한 결과로 알맞은 것은 무엇인가요?\n\n" + EMPLOYEE_TABLE_MD, "confusing",
                 "셀프 조인으로 사원의 급여와 관리자의 급여를 한 행에 놓고 비교해요. 최유나(3200)는 김민수(3000)보다, 박서준(2800)은 이지은(2500)보다 급여가 많아요.",
                 [choice("A", "최유나", rationale="박서준도 관리자 이지은보다 급여가 많아서 함께 나와요."),
                  choice("B", "최유나, 박서준", True, "두 사람만 자기 관리자보다 급여가 많아요."),
                  choice("C", "김민수, 이지은", rationale="이 두 사람은 관리자 쪽 값이고, SELECT 절은 사원 쪽 이름을 보여 줘요."),
                  choice("D", "0행", rationale="관리자보다 급여가 많은 사원이 두 명 있어요.")],
                 stem_sql=EARNS_MORE_THAN_MANAGER_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문: 사원-관리자, 외부 조인, 관리자의 관리자
        sql_check(EMPLOYEE_MANAGER_SQL, EMPLOYEE_MANAGER_ROWS),
        sql_check("SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E JOIN 사원 M ON E.관리자사번 = M.사번", EMPLOYEE_MANAGER_ROWS),
        sql_check("SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E LEFT JOIN 사원 M ON E.관리자사번 = M.사번",
                  EMPLOYEE_MANAGER_ROWS + [["김민수", None]]),
        sql_check("SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E, 사원 M WHERE E.관리자사번 = M.사번(+)",
                  EMPLOYEE_MANAGER_ROWS + [["김민수", None]]),
        sql_check("SELECT E.이름 AS 사원, M.이름 AS 관리자, T.이름 AS 윗관리자 FROM 사원 E "
                  "JOIN 사원 M ON E.관리자사번 = M.사번 JOIN 사원 T ON M.관리자사번 = T.사번",
                  [["박서준", "이지은", "김민수"], ["정하늘", "이지은", "김민수"],
                   ["한도윤", "최유나", "김민수"], ["오지민", "최유나", "김민수"]]),
        # 본문: 헷갈리는 점 (별칭, 방향, 기준, 값 비교)
        sql_error_check("SELECT 이름 FROM 사원, 사원 WHERE 사원.관리자사번 = 사원.사번", "ORA-00918"),
        sql_check("SELECT E.이름 AS 관리자, M.이름 AS 부하 FROM 사원 E, 사원 M WHERE E.사번 = M.관리자사번",
                  [[manager, employee] for employee, manager in EMPLOYEE_MANAGER_ROWS]),
        sql_check("SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E RIGHT JOIN 사원 M ON E.관리자사번 = M.사번",
                  MANAGER_SIDE_OUTER_ROWS),
        sql_check("SELECT E.이름, E.급여, M.이름 AS 관리자, M.급여 AS 관리자급여 FROM 사원 E JOIN 사원 M "
                  "ON E.관리자사번 = M.사번 WHERE E.급여 > M.급여",
                  [["최유나", 3200, "김민수", 3000], ["박서준", 2800, "이지은", 2500]]),
        # 확인 문제: stemSql, 3번 보기 (RIGHT·(+) 오답)
        sql_check(MANAGER_NAME_SQL, [[manager] for _, manager in EMPLOYEE_MANAGER_ROWS]),
        sql_check(EARNS_MORE_THAN_MANAGER_SQL, [["최유나"], ["박서준"]]),
        sql_check("SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E RIGHT JOIN 사원 M ON E.관리자사번 = M.사번 WHERE E.이름 IS NULL",
                  MANAGER_SIDE_OUTER_ROWS[len(EMPLOYEE_MANAGER_ROWS):]),
        sql_check("SELECT E.이름 AS 사원, M.이름 AS 관리자 FROM 사원 E, 사원 M WHERE E.관리자사번(+) = M.사번",
                  MANAGER_SIDE_OUTER_ROWS),
    ],
}
