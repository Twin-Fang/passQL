"""개념: CROSS JOIN (5단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import (DEPARTMENT_ROWS, DEPARTMENT_TABLE_MD, EMPLOYEE_TABLE_MD, SALARY_GRADE_ROWS,
                             SALARY_GRADE_TABLE_MD)

# 본문·문제 공통 SQL
DEPARTMENT_GRADE_ALL_SQL = "SELECT * FROM 부서 CROSS JOIN 급여등급;"
THREE_TABLES_GRADE_ONLY_SQL = ("SELECT COUNT(*) FROM 사원 E, 부서 D, 급여등급 G "
                               "WHERE E.급여 BETWEEN G.최저급여 AND G.최고급여;")
CROSS_JOIN_WITH_ON_SQL = "SELECT COUNT(*) FROM 사원 E CROSS JOIN 부서 D ON E.부서번호 = D.부서번호"
SEOUL_FILTER_ONLY_SQL = "SELECT COUNT(*) FROM 부서 D, 사원 E WHERE D.지역 = '서울';"

# 부서 4행 × 급여등급 4행 = 16행, 열은 3 + 3 = 6열
DEPARTMENT_GRADE_ALL_ROWS = [[*department, *grade] for department in DEPARTMENT_ROWS for grade in SALARY_GRADE_ROWS]

CONCEPT = {
    "tagKey": "join-cross",
    "topicCode": "sql_join",
    "sortOrder": 5,
    "title": "CROSS JOIN",
    "summary": "조건 없이 두 표의 행을 모든 경우로 짝지어 M × N 행을 만들어요",
    "coreMd": (
        "- CROSS JOIN은 조인 조건 없이 한 표의 모든 행을 다른 표의 모든 행과 하나씩 짝짓고, 이 결과를 카티션 곱이라고 불러요.\n"
        "- 결과 행 수는 두 표 행 수의 곱이라서 사원 8행과 부서 4행이면 32행이 되고, 열 수는 두 표 열 수의 합이에요.\n"
        "- Oracle 방식에서 WHERE 절의 조인 조건을 빠뜨려도 똑같이 카티션 곱이 생겨요.\n"
        "- CROSS JOIN에는 ON 절을 쓸 수 없고, WHERE 절로 결과를 거르는 것은 가능해요."
    ),
    "detailMd": f"""## 왜 알아야 하나요 {{#why}}

조인 결과가 갑자기 몇 배로 불어나는 일이 있어요. 대부분 표를 잇는 조건 하나를 빠뜨려서, 데이터베이스가 두 표의 행을 모든 경우로 짝지었기 때문이에요. 이런 결과가 어떻게 생기는지 알아야 실수를 찾을 수 있고, 시험에서도 행 수를 계산하는 문제로 자주 나와요. 반대로 모든 조합이 필요한 경우에는 이 방식을 일부러 쓰기도 해요.

이 개념의 행 수는 모두 아래 세 표로 계산해요. 사원 표는 8행 8열, 부서 표는 4행 3열, 급여등급 표는 4행 3열이에요.

{EMPLOYEE_TABLE_MD}

{DEPARTMENT_TABLE_MD}

{SALARY_GRADE_TABLE_MD}

## 한 줄 정의 {{#definition}}

CROSS JOIN은 조인 조건 없이 한 표의 모든 행을 다른 표의 모든 행과 하나씩 짝지어요. 이렇게 만든 모든 조합을 카티션 곱(Cartesian product)이라고 부르는데, 이 이름은 수학자 데카르트에게서 왔어요. 셔츠 3벌과 바지 2벌로 만들 수 있는 옷차림이 3 × 2 = 6가지인 것과 같은 계산이에요. 아래의 `COUNT(*)`는 결과 행이 몇 개인지 세어 숫자 하나로 돌려주는 함수예요(7단원에서 자세히 다뤄요).

```sql
SELECT COUNT(*) FROM 사원 CROSS JOIN 부서;  -- 사원 8행 × 부서 4행이라 32가 나와요
SELECT COUNT(*) FROM 사원, 부서;            -- 조건 없이 쓰는 Oracle 방식도 32가 나와요
```

## 예시 {{#example}}

부서와 급여등급을 CROSS JOIN한 결과에서 부서 하나만 떼어 보면 모양을 알기 쉬워요. 아래 SQL은 부서 4개 × 등급 4개 = 16행을 만든 뒤, WHERE 절로 기획부의 행만 남겨요.

```sql
SELECT D.부서명, G.등급
FROM 부서 D CROSS JOIN 급여등급 G
WHERE D.부서번호 = 10;
```

| 부서명 | 등급 |
|---|---|
| 기획부 | 1 |
| 기획부 | 2 |
| 기획부 | 3 |
| 기획부 | 4 |

기획부 한 행이 등급 네 행과 하나씩 짝지어져서, 같은 부서명이 네 번 나와요. 나머지 세 부서도 똑같이 네 행씩 만들어지므로 WHERE 절이 없으면 16행이 돼요.

## 조인 조건을 빠뜨리면 {{#missing-condition}}

Oracle 방식에서는 FROM 절에 표를 쉼표로 나열하고 WHERE 절에 조인 조건을 적는데, 이 조건을 빠뜨려도 오류가 나지 않고 카티션 곱이 만들어져요. 표가 세 개라면 조건이 몇 개 빠졌는지에 따라 행 수가 이렇게 달라져요.

| WHERE 절의 조인 조건 | 결과 행 수 |
|---|---|
| 사원-부서, 사원-급여등급 둘 다 있음 | 7행 |
| 사원-부서만 있음 | 7 × 4 = 28행 |
| 사원-급여등급만 있음 | 8 × 4 = 32행 |
| 하나도 없음 | 8 × 4 × 4 = 128행 |

사원과 급여등급만 이은 경우를 보면, 사원마다 등급이 하나씩 붙어 8행이 돼요. 부서 표는 WHERE 절의 어떤 조건으로도 사원과 이어지지 않았으므로, 그 8행 하나하나가 부서 표의 4행(기획부, 개발부, 영업부, 인사부)과 모두 짝지어져 32행이 돼요. 이때 부서번호가 NULL인 윤서연도 8행 안에 들어 있어요. 부서와는 아무것도 비교하지 않으니 NULL이어도 빠질 이유가 없기 때문이에요.

조인 조건이 아닌 조건만 있을 때도 마찬가지예요. `FROM 부서 D, 사원 E WHERE D.지역 = '서울'`은 서울에 있는 부서 2개(기획부, 인사부)를 고른 뒤 사원 8명과 모두 짝지어 2 × 8 = 16행을 만들어요. 행을 거르는 조건은 있지만 두 표를 잇는 조건은 없기 때문이에요.

## 쓰이는 곳 {{#use}}

모든 조합이 필요할 때는 CROSS JOIN을 일부러 써요. 부서별·등급별 인원표를 만들 때 사원이 한 명도 없는 칸까지 0으로 보여 주려면, 부서 4개와 등급 4개를 CROSS JOIN해서 16칸의 틀을 먼저 만들고 그 틀에 실제 인원을 채워요. 날짜 목록과 상품 목록을 짝지어 모든 날짜·상품 조합을 만들 때나, 시험용 데이터를 한꺼번에 만들 때도 쓰여요.

## 자주 헷갈리는 점 {{#confusing}}

**CROSS JOIN에는 ON 절을 쓸 수 없어요.** CROSS JOIN은 조건 없이 짝짓는 문법이라서 ON 절을 붙이면 ORA-00933 오류가 나요. 문법에 없는 단어가 문장 뒤에 붙었다는 뜻이에요. USING도 마찬가지예요. 반면 WHERE 절은 조인이 끝난 결과를 거르는 것이라 쓸 수 있어요.

```sql
SELECT COUNT(*) FROM 사원 E CROSS JOIN 부서 D ON E.부서번호 = D.부서번호;     -- 오류: CROSS JOIN에는 ON을 쓸 수 없어요 (ORA-00933, 문법에 없는 단어)
SELECT COUNT(*) FROM 사원 E CROSS JOIN 부서 D WHERE E.부서번호 = D.부서번호;  -- INNER JOIN과 같은 7이 나와요
```

**WHERE 절에 조인 조건을 쓰면 INNER JOIN과 같아져요.** 위 두 번째 SQL처럼 CROSS JOIN의 결과를 `E.부서번호 = D.부서번호`로 거르면, 32행 중 짝이 맞는 7행만 남아서 등가 조인이나 INNER JOIN과 결과가 똑같아요.

**행은 곱하고 열은 더해요.** 카티션 곱의 행 수는 두 표의 행 수를 곱한 값이지만, 열 수는 두 표의 열 수를 더한 값이에요. `SELECT *`는 모든 열을 보여 달라는 뜻인데, 사원(8열)과 부서(3열)를 CROSS JOIN해서 `SELECT *`로 보면 32행 11열이 나와요.

**항상 참인 조건도 카티션 곱을 만들어요.** `사원 E JOIN 부서 D ON 1 = 1`처럼 ON 절에 언제나 참인 조건을 쓰면, 모든 짝이 조건을 통과해서 CROSS JOIN과 같은 32행이 나와요. 이름이 같은 열이 하나도 없는 두 표를 NATURAL JOIN할 때도 비교할 열이 없어서 카티션 곱이 돼요.

**같은 표끼리도 카티션 곱이 생겨요.** 사원 표를 별칭 두 개로 두 번 읽으면서 조건을 빠뜨리면 8 × 8 = 64행이 나와요. 같은 표를 두 번 읽는 방법은 다음 개념인 셀프 조인에서 다뤄요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

두 표의 행 수를 주고 CROSS JOIN 결과가 몇 행인지 묻는 문제가 가장 흔해요. 세 표 중 조인 조건이 하나 빠진 SQL의 행 수를 묻는 문제도 자주 나오는데, 조건으로 이어진 표끼리 먼저 행 수를 세고, 어떤 조건으로도 이어지지 않은 표의 행 수를 곱하면 돼요. CROSS JOIN에 ON 절을 붙인 SQL처럼 오류가 나는 문장을 고르는 문제도 나와요.""",
    "checkQuestions": [
        question(1, "카티션 곱(Cartesian product)을 가장 알맞게 설명한 것은 무엇인가요?", "definition",
                 "카티션 곱은 조건 없이 두 표의 행을 모든 경우로 짝지은 결과예요. 그래서 행 수는 두 표 행 수의 곱이 돼요.",
                 [choice("A", "두 표에서 값이 같은 행끼리만 짝지은 결과", rationale="값이 같은 행끼리 짝짓는 것은 등가 조인이에요."),
                  choice("B", "한쪽 표의 행을 짝이 없어도 모두 남긴 결과", rationale="짝이 없는 행을 남기는 것은 OUTER JOIN이에요."),
                  choice("C", "두 표에서 이름이 같은 열로 짝지은 결과", rationale="이름이 같은 열로 짝짓는 것은 NATURAL JOIN이에요."),
                  choice("D", "한 표의 모든 행을 다른 표의 모든 행과 짝지은 결과", True, "조건 없이 모든 조합을 만든 것이 카티션 곱이에요.")]),
        question(2, "본문의 부서 표는 4행 3열, 급여등급 표는 4행 3열이에요. `SELECT *`는 모든 열을 보여 줘요. 다음 SQL의 결과는 몇 행, 몇 열인가요?", "confusing",
                 "카티션 곱의 행 수는 4 × 4 = 16이고, 열 수는 두 표의 열을 모두 이어 붙인 3 + 3 = 6이에요.",
                 [choice("A", "16행 6열", True, "행은 곱하고 열은 더해요."),
                  choice("B", "16행 9열", rationale="열 수는 곱하지 않고 더해요."),
                  choice("C", "8행 6열", rationale="행 수는 더하지 않고 곱해요."),
                  choice("D", "4행 3열", rationale="CROSS JOIN은 두 표의 모든 조합을 만들어서 행과 열이 모두 늘어나요.")],
                 stem_sql=DEPARTMENT_GRADE_ALL_SQL),
        question(3, "사원(8행), 부서(4행), 급여등급(4행) 세 표를 FROM 절에 쓰고, 사원과 급여등급을 잇는 조건만 적었어요. `COUNT(*)`는 결과 행의 개수를 세요. 다음 SQL의 결과는 무엇인가요?", "missing-condition",
                 "사원과 급여등급은 이어져서 8행이 되지만, 부서 표는 이어지지 않아 4행과 모두 짝지어져요. 그래서 8 × 4 = 32예요.",
                 [choice("A", "8", rationale="부서 표를 잇는 조건이 없어서 8행이 네 배로 늘어나요."),
                  choice("B", "28", rationale="28은 사원과 부서만 이었을 때(7행 × 4)의 결과예요."),
                  choice("C", "32", True, "사원·급여등급 8행 × 부서 4행이에요."),
                  choice("D", "128", rationale="128은 조인 조건이 하나도 없을 때의 결과예요.")],
                 stem_sql=THREE_TABLES_GRADE_ONLY_SQL),
        question(4, "다음 중 실행하면 오류가 나는 SQL은 무엇인가요?", "confusing",
                 "CROSS JOIN은 조건 없이 짝짓는 문법이라 ON 절을 붙이면 문법 오류가 나요. 결과를 거르는 WHERE 절은 쓸 수 있어요.",
                 [choice("A", "SELECT COUNT(*) FROM 사원 E CROSS JOIN 부서 D WHERE E.부서번호 = D.부서번호",
                         rationale="WHERE 절로 거르는 것은 가능해서 7이 나와요."),
                  choice("B", "SELECT COUNT(*) FROM 사원 E CROSS JOIN 부서 D ON E.부서번호 = D.부서번호", True,
                         "CROSS JOIN에 ON 절을 붙여서 오류가 나요."),
                  choice("C", "SELECT COUNT(*) FROM 사원 E, 부서 D", rationale="조건 없는 Oracle 방식이라 오류 없이 32가 나와요."),
                  choice("D", "SELECT COUNT(*) FROM 사원 E JOIN 부서 D ON 1 = 1", rationale="ON 절이 있으니 오류 없이 32가 나와요.")]),
        question(5, "본문의 부서 표에서 지역이 서울인 부서는 기획부와 인사부 2개예요. 다음 SQL의 결과는 무엇인가요?", "missing-condition",
                 "WHERE 절의 조건은 부서를 거를 뿐 두 표를 잇지 않아요. 서울 부서 2행이 사원 8행과 모두 짝지어져 2 × 8 = 16이에요.",
                 [choice("A", "1", rationale="두 표를 잇는 조건이 없어서 사원 소속과 상관없이 모두 짝지어져요."),
                  choice("B", "2", rationale="서울 부서 2행이 사원 8행과 각각 짝지어지므로 행이 늘어나요."),
                  choice("C", "16", True, "서울 부서 2행 × 사원 8행이에요."),
                  choice("D", "32", rationale="지역 조건이 부서를 2개로 줄여서 32행보다 적어요.")],
                 stem_sql=SEOUL_FILTER_ONLY_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 본문: 기본 행 수, 예시, 조건 빠뜨리기 표
        sql_check("SELECT D.부서명, G.등급 FROM 부서 D CROSS JOIN 급여등급 G WHERE D.부서번호 = 10",
                  [["기획부", 1], ["기획부", 2], ["기획부", 3], ["기획부", 4]]),
        sql_check("SELECT COUNT(*) FROM 사원 E, 부서 D, 급여등급 G "
                  "WHERE E.부서번호 = D.부서번호 AND E.급여 BETWEEN G.최저급여 AND G.최고급여", [[7]]),
        sql_check("SELECT COUNT(*) FROM 사원 E, 부서 D, 급여등급 G WHERE E.부서번호 = D.부서번호", [[28]]),
        sql_check("SELECT COUNT(*) FROM 사원, 부서, 급여등급", [[128]]),
        # 본문: 헷갈리는 점 (열 수, 항상 참, NATURAL, 같은 표)
        sql_check("SELECT * FROM 사원 CROSS JOIN 부서 WHERE 사번 = 1001 AND 부서.부서번호 = 40",
                  [[1001, "김민수", "사장", None, "2015-03-02", 3000, None, 10, 40, "인사부", "서울"]]),
        sql_check("SELECT COUNT(*) FROM 사원 E JOIN 부서 D ON 1 = 1", [[32]]),
        sql_check("SELECT COUNT(*) FROM 사원 NATURAL JOIN 급여등급", [[32]]),
        sql_check("SELECT COUNT(*) FROM 사원 E, 사원 M", [[64]]),
        # 확인 문제: stemSql, 4번 보기 4개
        sql_check(DEPARTMENT_GRADE_ALL_SQL, DEPARTMENT_GRADE_ALL_ROWS),
        sql_check(THREE_TABLES_GRADE_ONLY_SQL, [[32]]),
        sql_check(SEOUL_FILTER_ONLY_SQL, [[16]]),
        sql_error_check(CROSS_JOIN_WITH_ON_SQL, "ORA-00933"),
        sql_error_check("SELECT 이름 FROM 사원 CROSS JOIN 부서 USING (부서번호)", "ORA-00933"),
        sql_check("SELECT COUNT(*) FROM 사원 E CROSS JOIN 부서 D WHERE E.부서번호 = D.부서번호", [[7]]),
        sql_check("SELECT COUNT(*) FROM 사원 E, 부서 D", [[32]]),
    ],
}
