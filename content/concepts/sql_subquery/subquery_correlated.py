"""개념: 연관 서브쿼리와 EXISTS (6단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check
from concept_dataset import DEPARTMENT_TABLE_MD, to_employee_table_md

# 이 개념의 계산에 쓰는 열 전부 (관리자사번·급여·부서번호)
EMPLOYEE_TABLE = to_employee_table_md("사번", "이름", "관리자사번", "급여", "부서번호")

CONCEPT = {
    "tagKey": "subquery-correlated",
    "topicCode": "sql_subquery",
    "sortOrder": 3,
    "title": "연관 서브쿼리와 EXISTS",
    "summary": "메인 쿼리의 행마다 다시 계산되는 서브쿼리이고, EXISTS는 행이 있는지만 봐요",
    "coreMd": (
        "- 연관 서브쿼리는 서브쿼리 안에서 메인 쿼리의 열을 참조하고, 메인 쿼리의 행이 바뀔 때마다 그 행의 값으로 다시 계산돼요.\n"
        "- `EXISTS`는 서브쿼리 결과에 행이 하나라도 있으면 참이고 어떤 값이 나오는지는 보지 않아서, 보통 `SELECT 1`로 적어요.\n"
        "- `NOT IN` 서브쿼리 결과에 NULL이 하나라도 섞이면 결과가 0행이 되지만, `NOT EXISTS`는 NULL과 상관없이 짝이 없는 행을 찾아 줘요.\n"
        "- 그래서 사원이 없는 부서를 찾을 때 `NOT IN (SELECT 부서번호 FROM 사원)`은 0행이 나오고, `NOT EXISTS`는 인사부를 돌려줘요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

앞에서는 전체 평균보다 급여가 많은 사원을 찾았어요. 그때 서브쿼리는 평균 2612.5라는 값 하나만 구하면 됐고, 모든 사원이 같은 값과 비교됐어요. 이번에는 "자기 부서 평균보다 급여가 많은 사원"을 찾으려고 해요.

이 조건에서는 비교할 값이 사원마다 달라져요. 20번 개발부의 박서준은 개발부 평균과, 30번 영업부의 최유나는 영업부 평균과 비교해야 하거든요. 그래서 서브쿼리가 "지금 메인 쿼리가 보고 있는 사원이 어느 부서인지" 알아야 하는데, 이렇게 메인 쿼리의 값을 받아 쓰는 서브쿼리가 연관 서브쿼리예요.

이 글의 예시는 모두 아래 두 표로 계산해요. 윤서연(1008)은 부서가 정해지지 않아 부서번호가 NULL이고, 사장 김민수(1001)는 위에 관리자가 없어서 관리자사번이 NULL이에요. 인사부(40번)에는 소속 사원이 없어요.

{EMPLOYEE_TABLE}

{DEPARTMENT_TABLE_MD}

## 한 줄 정의 {{#definition}}

연관 서브쿼리(Correlated Subquery)는 서브쿼리 안에서 메인 쿼리의 열을 참조하는 서브쿼리이고, 상관 서브쿼리라고도 불러요. 메인 쿼리의 열을 쓰지 않아서 혼자 실행해도 되는 서브쿼리는 비연관 서브쿼리라고 해요.

```sql
SELECT e.이름, e.부서번호, e.급여
FROM 사원 e
WHERE e.급여 > (SELECT AVG(s.급여)
                FROM 사원 s
                WHERE s.부서번호 = e.부서번호);
```

`AVG(s.급여)`는 급여의 평균을 구하는 함수예요. 메인 쿼리와 서브쿼리가 같은 사원 테이블을 쓰기 때문에, 바깥 사원 테이블에는 `e`, 안쪽 사원 테이블에는 `s`라는 별칭(Alias, 테이블에 붙이는 짧은 이름)을 붙여 구분했어요. 서브쿼리 안의 `e.부서번호`가 메인 쿼리의 열이고, 이 부분이 두 쿼리를 연결해 줘요. 이 서브쿼리는 `e`가 무엇인지 알아야 실행할 수 있어서 혼자 떼어 내면 실행되지 않아요.

결과로는 아래 두 명이 나와요.

| 이름 | 부서번호 | 급여 |
|---|---|---|
| 박서준 | 20 | 2800 |
| 최유나 | 30 | 3200 |

## 행마다 다시 계산돼요 {{#row-by-row}}

연관 서브쿼리의 결과는 메인 쿼리가 사원 한 명을 볼 때마다 그 사원의 부서번호로 다시 계산된다고 생각하면 이해하기 쉬워요. 위 SQL이 사원 8명을 차례로 볼 때 서브쿼리가 구하는 값은 아래와 같아요.

| 메인 쿼리가 보는 사원 | 서브쿼리가 구한 부서 평균 | 급여 > 평균 |
|---|---|---|
| 김민수 (10번, 3000) | 3000 | 거짓 |
| 이지은 (20번, 2500) | 2600 | 거짓 |
| 박서준 (20번, 2800) | 2600 | 참 |
| 최유나 (30번, 3200) | 2700 | 참 |
| 정하늘 (20번, 2500) | 2600 | 거짓 |
| 한도윤 (30번, 2700) | 2700 | 거짓 |
| 오지민 (30번, 2200) | 2700 | 거짓 |
| 윤서연 (NULL, 2000) | NULL | UNKNOWN |

김민수는 10번 부서에 혼자라 부서 평균이 자기 급여와 같아서 남지 않아요. 한도윤도 급여가 평균과 똑같은 2700이라 `>` 조건을 넘지 못해요. 윤서연은 부서번호가 NULL이라 `s.부서번호 = NULL`을 만족하는 행이 없고, 행이 없으니 평균도 NULL이 되어 비교 결과가 UNKNOWN이에요.

비연관 서브쿼리는 메인 쿼리와 상관없이 한 번 계산한 값을 모든 행이 함께 쓰지만, 연관 서브쿼리는 메인 쿼리 행의 값이 바뀌면 결과도 바뀐다는 점이 달라요.

## EXISTS와 NOT EXISTS {{#exists}}

`EXISTS (서브쿼리)`는 서브쿼리 결과에 행이 하나라도 있으면 참, 하나도 없으면 거짓이에요. 값을 비교하지 않고 행이 있는지만 확인하기 때문에, 보통 연관 서브쿼리와 함께 써서 "짝이 되는 행이 있는가"를 물어요.

```sql
SELECT d.부서명
FROM 부서 d
WHERE EXISTS (SELECT 1 FROM 사원 e WHERE e.부서번호 = d.부서번호);

SELECT d.부서명
FROM 부서 d
WHERE NOT EXISTS (SELECT 1 FROM 사원 e WHERE e.부서번호 = d.부서번호);
```

첫 번째 SQL은 부서마다 그 부서번호를 가진 사원이 있는지 찾아보고, 있으면 참으로 보아 기획부, 개발부, 영업부를 돌려줘요. 인사부(40번)는 소속 사원이 없어서 EXISTS가 거짓이 되고, 대신 두 번째 SQL의 NOT EXISTS에서 참이 되어 인사부 하나만 나와요.

서브쿼리 SELECT 절에 `1`을 적는 이유는 EXISTS가 어떤 값이 나오는지 보지 않기 때문이에요. `SELECT *`나 `SELECT 이름`이라고 적어도 결과는 같고, `1`은 "값은 상관없다"는 뜻으로 관례처럼 써요.

## 자주 헷갈리는 점 {{#confusing}}

**NOT IN과 NOT EXISTS는 NULL 때문에 결과가 달라져요.** 두 SQL은 같은 질문처럼 보이지만, 사원이 없는 부서를 각각의 방법으로 찾아보면 결과가 갈려요.

```sql
SELECT 부서명
FROM 부서
WHERE 부서번호 NOT IN (SELECT 부서번호 FROM 사원);  -- 0행이 나와요

SELECT d.부서명
FROM 부서 d
WHERE NOT EXISTS (SELECT 1 FROM 사원 e WHERE e.부서번호 = d.부서번호);  -- 인사부가 나와요
```

NOT IN 쪽의 서브쿼리는 사원들의 부서번호 10, 20, 20, 30, 20, 30, 30, NULL을 돌려주는데, 마지막 NULL은 부서가 없는 윤서연의 값이에요. 인사부의 40을 검사하면 `40 <> 10 AND 40 <> 20 AND ... AND 40 <> NULL`이 되고, 마지막 비교만 UNKNOWN이에요.

AND는 묶인 조건이 모두 참이어야 참이 되는데, 참 AND UNKNOWN은 UNKNOWN이에요. 그래서 앞의 비교가 모두 참이어도 전체는 UNKNOWN에 머무르고, WHERE 절은 참인 행만 남기므로 인사부는 빠져요. 다른 부서도 모두 마찬가지라서 결과가 0행이 나와요.

NOT EXISTS 쪽은 부서마다 `e.부서번호 = d.부서번호`를 만족하는 사원이 있는지만 찾아요. 윤서연의 행은 어느 부서와도 같지 않으니 그냥 걸러질 뿐 결과를 망가뜨리지 않고, 40번 부서는 짝이 되는 사원이 없으니 NOT EXISTS가 참이 돼요. 같은 결과를 NOT IN으로 얻으려면 서브쿼리에 `WHERE 부서번호 IS NOT NULL`을 붙여 NULL을 미리 빼야 해요.

```sql
SELECT 부서명
FROM 부서
WHERE 부서번호 NOT IN (SELECT 부서번호 FROM 사원 WHERE 부서번호 IS NOT NULL);  -- 인사부가 나와요
```

**NOT IN 서브쿼리가 돌려주는 열에 NULL이 있는지부터 봐야 해요.** 부서번호뿐 아니라 관리자사번 열도 마찬가지예요. 사장 김민수는 관리자가 없어서 관리자사번이 NULL이므로, 서브쿼리가 관리자사번 열을 돌려주는 NOT IN은 같은 이유로 어떤 행도 참이 되지 못해요.

**NULL이 메인 쿼리 쪽에 있어도 NOT IN은 결과가 달라요.** 이번에는 부서 표에 없는 부서번호를 가진 사원을 찾아볼게요. `WHERE 부서번호 NOT IN (SELECT 부서번호 FROM 부서)`는 0행이 나와요. 윤서연의 부서번호 NULL과 10, 20, 30, 40을 비교하면 모두 UNKNOWN이 되기 때문이에요. 반면 NOT EXISTS로 쓰면 부서 표에서 짝을 찾지 못한 윤서연이 정상적으로 나와요.

```sql
SELECT e.이름
FROM 사원 e
WHERE NOT EXISTS (SELECT 1 FROM 부서 d WHERE d.부서번호 = e.부서번호);  -- 윤서연이 나와요
```

**IN과 EXISTS는 이 차이가 없어요.** `부서번호 IN (SELECT 부서번호 FROM 사원)`은 목록 중 하나와만 같으면 참이라서, 목록에 NULL이 섞여 있어도 기획부, 개발부, 영업부가 정상적으로 나와요. OR로 묶인 비교는 하나만 참이면 전체가 참이 되기 때문이에요. NULL 때문에 결과가 망가지는 것은 "모두와 달라야 한다"를 AND로 묻는 NOT IN 쪽이에요.

**EXISTS 안에 집계 함수를 쓰면 언제나 참이 돼요.** 집계 함수는 COUNT(행 개수)처럼 여러 행을 모아 값 하나를 계산하는 함수예요. `EXISTS (SELECT COUNT(*) FROM 사원 e WHERE e.부서번호 = d.부서번호)`는 인사부까지 네 부서를 모두 돌려줘요. 사원이 없어도 COUNT(*)는 0이라는 한 행을 돌려주고, EXISTS는 값이 0인지가 아니라 행이 있는지만 보기 때문이에요.

**연결 조건을 빠뜨리면 모든 행이 나오거나 하나도 나오지 않아요.** `EXISTS (SELECT 1 FROM 부서 d WHERE d.지역 = '서울')`처럼 메인 쿼리의 열을 쓰지 않으면, 서울 부서가 하나라도 있는 한 모든 사원에게 참이 되어 8명이 모두 나와요. EXISTS를 쓸 때는 서브쿼리 안에 메인 쿼리와 연결하는 조건이 있는지 꼭 확인해야 해요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

NOT IN과 NOT EXISTS를 쓴 SQL 두 개를 주고 결과가 같은지, 각각 몇 행인지 묻는 문제가 자주 나와요. 서브쿼리가 돌려주는 열과 메인 쿼리에서 비교하는 열에 NULL이 있는지부터 확인하면 대부분 풀려요. 그 밖에 연관 서브쿼리로 "자기 부서 평균보다 많은" 사원을 고르는 문제, EXISTS의 SELECT 목록이 결과에 영향을 주는지 묻는 문제가 나와요.""",
    "checkQuestions": [
        question(1, "연관 서브쿼리를 가장 알맞게 설명한 것은 무엇인가요?", "definition",
                 "연관 서브쿼리는 서브쿼리 안에서 메인 쿼리의 열을 참조해요. 그래서 메인 쿼리의 행이 바뀔 때마다 그 행의 값으로 다시 계산돼요.",
                 [choice("A", "메인 쿼리와 상관없이 한 번만 계산되는 서브쿼리", rationale="비연관 서브쿼리의 설명이에요."),
                  choice("B", "결과로 열 두 개 이상을 돌려주는 서브쿼리", rationale="다중 컬럼 서브쿼리의 설명이에요."),
                  choice("C", "FROM 절에 놓여 표처럼 쓰이는 서브쿼리", rationale="인라인 뷰의 설명이에요."),
                  choice("D", "메인 쿼리의 열을 참조해서, 메인 쿼리 행마다 다시 계산되는 서브쿼리", True,
                         "연관 서브쿼리의 정의예요.")]),
        question(2, "`WHERE EXISTS (SELECT 1 FROM 사원 e WHERE e.부서번호 = d.부서번호)`에서 `SELECT 1`을 `SELECT *`로 바꾸면 결과는 어떻게 되나요?", "exists",
                 "EXISTS는 서브쿼리 결과에 행이 있는지만 보고 어떤 값이 나오는지는 보지 않아요. 그래서 SELECT 목록을 바꿔도 결과가 같아요.",
                 [choice("A", "결과가 같다", True, "EXISTS는 행이 있는지만 확인해요."),
                  choice("B", "열이 많아져서 오류가 난다", rationale="EXISTS 안의 SELECT 목록은 열 개수 제한이 없어요."),
                  choice("C", "사원 열이 함께 나와서 결과 열이 늘어난다", rationale="EXISTS 서브쿼리의 열은 메인 쿼리 결과에 나오지 않아요."),
                  choice("D", "0행이 나온다", rationale="행이 있는지는 SELECT 목록과 상관이 없어요.")]),
        question(3, "아래 부서 표와 사원 표에 다음 SQL을 실행하면 결과는 무엇인가요?\n\n" + DEPARTMENT_TABLE_MD + "\n\n" + EMPLOYEE_TABLE, "confusing",
                 "서브쿼리 결과에 윤서연의 NULL이 섞여서, 어느 부서번호든 `<> NULL` 비교가 UNKNOWN이 돼요. AND로 묶인 비교 하나가 UNKNOWN이면 전체가 참이 되지 못해 0행이 나와요.",
                 [choice("A", "인사부", rationale="NOT EXISTS를 썼을 때의 결과이고, NOT IN은 NULL 때문에 0행이 돼요."),
                  choice("B", "0행", True, "서브쿼리 결과에 NULL이 있어서 NOT IN이 참이 될 수 없어요."),
                  choice("C", "기획부, 개발부, 영업부", rationale="IN을 썼을 때의 결과예요."),
                  choice("D", "오류가 난다", rationale="문법에 문제가 없어서 오류 없이 0행이 나와요.")],
                 stem_sql="SELECT 부서명 FROM 부서 WHERE 부서번호 NOT IN (SELECT 부서번호 FROM 사원);"),
        question(4, "부서 표(10, 20, 30, 40)에 없는 부서번호를 가진 사원을 찾으려고 해요. 사원 윤서연(1008)은 부서번호가 NULL이에요. 다음 SQL의 결과는 무엇인가요?", "confusing",
                 "NOT EXISTS는 사원마다 같은 부서번호를 가진 부서가 있는지 찾아요. 윤서연은 부서번호가 NULL이라 짝이 되는 부서가 없어서 결과에 나와요.",
                 [choice("A", "0행", rationale="NOT IN으로 썼을 때의 결과이고, NOT EXISTS는 짝이 없는 행을 그대로 찾아요."),
                  choice("B", "인사부", rationale="이 SQL은 부서가 아니라 사원 이름을 돌려줘요."),
                  choice("C", "윤서연", True, "부서 표에서 짝을 찾지 못한 사원은 윤서연뿐이에요."),
                  choice("D", "사원 8명 모두", rationale="나머지 7명은 부서 표에 같은 부서번호가 있어요.")],
                 stem_sql="SELECT e.이름 FROM 사원 e WHERE NOT EXISTS (SELECT 1 FROM 부서 d WHERE d.부서번호 = e.부서번호);"),
        question(5, "부하 직원이 없는 사원을 찾으려고 다음 SQL을 썼어요. 아래 표를 보고 결과로 알맞은 것을 고르세요.\n\n" + EMPLOYEE_TABLE, "confusing",
                 "관리자사번 열에는 김민수의 NULL이 들어 있어서, 어느 사번이든 `<> NULL` 비교가 UNKNOWN이 되어 NOT IN이 참이 되지 못해요. 원하는 다섯 명을 얻으려면 NOT EXISTS를 쓰거나 서브쿼리에서 NULL을 빼야 해요.",
                 [choice("A", "박서준, 정하늘, 한도윤, 오지민, 윤서연", rationale="NOT EXISTS로 썼거나 서브쿼리에서 NULL을 뺐을 때의 결과예요."),
                  choice("B", "김민수, 이지은, 최유나", rationale="부하 직원이 있는 사원으로, IN을 썼을 때의 결과예요."),
                  choice("C", "윤서연", rationale="NULL이 섞인 NOT IN은 어떤 사원도 돌려주지 못해서 윤서연도 나오지 않아요."),
                  choice("D", "0행", True, "서브쿼리 결과에 NULL이 섞여서 NOT IN이 참이 될 수 없어요.")],
                 stem_sql="SELECT 이름 FROM 사원 WHERE 사번 NOT IN (SELECT 관리자사번 FROM 사원);"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        sql_check("SELECT e.이름, e.부서번호, e.급여 FROM 사원 e WHERE e.급여 > "
                  "(SELECT AVG(s.급여) FROM 사원 s WHERE s.부서번호 = e.부서번호)",
                  [["박서준", 20, 2800], ["최유나", 30, 3200]]),
        sql_check("SELECT 부서번호, AVG(급여) FROM 사원 GROUP BY 부서번호",
                  [[10, 3000], [20, 2600], [30, 2700], [None, 2000]]),
        # EXISTS·NOT EXISTS (사원 없는 부서 40)
        sql_check("SELECT d.부서명 FROM 부서 d WHERE EXISTS (SELECT 1 FROM 사원 e WHERE e.부서번호 = d.부서번호)",
                  [["기획부"], ["개발부"], ["영업부"]]),
        sql_check("SELECT d.부서명 FROM 부서 d WHERE EXISTS (SELECT * FROM 사원 e WHERE e.부서번호 = d.부서번호)",
                  [["기획부"], ["개발부"], ["영업부"]]),
        sql_check("SELECT d.부서명 FROM 부서 d WHERE NOT EXISTS (SELECT 1 FROM 사원 e WHERE e.부서번호 = d.부서번호)",
                  [["인사부"]]),
        # NOT IN <-> NOT EXISTS (NULL 부서 사원 1008)
        sql_check("SELECT 부서명 FROM 부서 WHERE 부서번호 NOT IN (SELECT 부서번호 FROM 사원);", []),
        sql_check("SELECT 부서명 FROM 부서 WHERE 부서번호 NOT IN (SELECT 부서번호 FROM 사원 WHERE 부서번호 IS NOT NULL)",
                  [["인사부"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 NOT IN (SELECT 부서번호 FROM 부서)", []),
        sql_check("SELECT e.이름 FROM 사원 e WHERE NOT EXISTS (SELECT 1 FROM 부서 d WHERE d.부서번호 = e.부서번호);",
                  [["윤서연"]]),
        sql_check("SELECT 부서명 FROM 부서 WHERE 부서번호 IN (SELECT 부서번호 FROM 사원)",
                  [["기획부"], ["개발부"], ["영업부"]]),
        sql_check("SELECT d.부서명 FROM 부서 d WHERE EXISTS (SELECT COUNT(*) FROM 사원 e WHERE e.부서번호 = d.부서번호)",
                  [["기획부"], ["개발부"], ["영업부"], ["인사부"]]),
        sql_check("SELECT COUNT(*) FROM 사원 e WHERE EXISTS (SELECT 1 FROM 부서 d WHERE d.지역 = '서울')", [[8]]),
        # 부하 직원 없는 사원 (김민수 관리자사번 NULL)
        sql_check("SELECT 이름 FROM 사원 WHERE 사번 NOT IN (SELECT 관리자사번 FROM 사원);", []),
        sql_check("SELECT e.이름 FROM 사원 e WHERE NOT EXISTS (SELECT 1 FROM 사원 s WHERE s.관리자사번 = e.사번)",
                  [["박서준"], ["정하늘"], ["한도윤"], ["오지민"], ["윤서연"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 사번 NOT IN (SELECT 관리자사번 FROM 사원 WHERE 관리자사번 IS NOT NULL)",
                  [["박서준"], ["정하늘"], ["한도윤"], ["오지민"], ["윤서연"]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 사번 IN (SELECT 관리자사번 FROM 사원)",
                  [["김민수"], ["이지은"], ["최유나"]]),
    ],
}
