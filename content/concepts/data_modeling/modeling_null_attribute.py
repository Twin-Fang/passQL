"""개념: NULL 속성 (1단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import to_employee_table_md, to_markdown_table

EMPLOYEE_PAY_TABLE = to_employee_table_md("사번", "이름", "급여", "커미션", "부서번호")

# 30번 부서 급여 + 커미션 결과 (본문 결과 표 = 검증 기대값)
DEPARTMENT_30_TOTAL_PAY_ROWS = [["최유나", None], ["한도윤", 3200], ["오지민", 2400]]

CONCEPT = {
    "tagKey": "modeling-null-attribute",
    "topicCode": "data_modeling",
    "sortOrder": 13,
    "title": "NULL 속성",
    "summary": "값이 아직 정해지지 않았다는 표시라서, 계산과 집계가 달라져요",
    "coreMd": (
        "- NULL은 값이 아직 정해지지 않았거나 알 수 없다는 표시라서, 숫자 0이나 공백 문자와는 다른 것이에요.\n"
        "- 모델링에서는 속성마다 NULL을 허용할지 정하는데, 주식별자는 값이 반드시 있어야 하므로 NULL을 허용하지 않아요.\n"
        "- NULL이 섞인 산술 연산은 결과가 NULL이고, NULL과의 비교는 참도 거짓도 아닌 UNKNOWN이에요.\n"
        "- SUM, AVG, COUNT(컬럼) 같은 집계 함수는 NULL인 행을 빼고 계산하고, COUNT(*)만 NULL과 상관없이 모든 행을 세요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

신입 사원을 등록할 때 커미션(판매 실적에 따라 급여 외에 더 받는 돈)이 아직 정해지지 않았다면 그 칸에 무엇을 넣어야 할까요. 0을 넣으면 "커미션이 0원으로 정해졌다"는 뜻과 구별할 수 없어요. 그래서 데이터베이스는 "아직 값이 없다"를 나타내는 NULL이라는 표시를 따로 둬요.

NULL은 편리하지만 계산과 집계 결과를 바꿔 놓기 때문에, 어떤 속성에 NULL을 허용할지는 모델링 단계에서 정해야 해요. 이 글은 공통 예시 데이터의 사원 표로 설명할게요.

{EMPLOYEE_PAY_TABLE}

## 한 줄 정의 {{#definition}}

NULL은 값이 아직 정해지지 않았거나 알 수 없다는 상태를 뜻하는 표시예요. 김민수의 커미션이 NULL이라는 것은 커미션이 0원이라는 뜻이 아니라 정해진 값이 없다는 뜻이고, 그래서 커미션이 0인 박서준과는 다른 상태예요.

공백도 NULL과 달라요. 스페이스 한 칸(`' '`)은 눈에 보이지 않을 뿐 문자 하나가 들어 있는 값이에요. 다만 Oracle은 아무것도 없는 빈 문자열(`''`)을 NULL로 저장한다는 점이 다른 데이터베이스와 달라요.

## 모델링에서 NULL 허용 여부 {{#nullable}}

모델을 만들 때는 속성마다 값이 반드시 있어야 하는지를 정해요. 값이 반드시 있어야 하는 속성은 필수 속성(NOT NULL)이고, 비어 있어도 되는 속성은 선택 속성(NULL 허용)이에요. 공통 사원 테이블에서 사번은 주식별자(사원 한 명을 구별하는 대표 속성)라 NULL일 수 없고, 이름은 NOT NULL로 정해져 있고, 커미션과 부서번호는 NULL을 허용해요.

주식별자는 존재성을 지켜야 하므로 언제나 NULL을 허용하지 않아요. 바커(Barker) 표기법에서는 속성 이름 앞에 기호를 붙여 구분하는데, `#`은 주식별자, `*`는 필수 속성, `o`는 NULL을 허용하는 선택 속성이에요.

아래 SQL(데이터베이스에 내리는 명령문)의 INSERT는 테이블에 새 행을 넣는 명령이에요. 주식별자나 NOT NULL 칸에 NULL을 넣으려 하면 오류가 나서 행이 들어가지 않아요.

```sql
INSERT INTO 사원 (사번, 이름) VALUES (NULL, '홍길동'); -- 오류: 주식별자인 사번에는 NULL을 넣을 수 없어요
INSERT INTO 사원 (사번, 이름) VALUES (1009, NULL);     -- 오류: NOT NULL인 이름에도 NULL을 넣을 수 없어요
INSERT INTO 사원 (사번, 이름) VALUES (1009, '홍길동'); -- 성공, 적지 않은 칸은 NULL로 들어가요
```

## NULL이 섞인 계산과 비교 {{#operation}}

NULL에 어떤 숫자를 더하거나 곱해도 결과는 NULL이에요. 모르는 값에 무엇을 더해도 여전히 모르는 값이기 때문이에요. 아래 SELECT는 데이터를 조회하는 명령이고, WHERE 절은 조건에 맞는 행만 고르는 부분이라서 여기서는 30번 부서 사원 세 명만 보여 줘요.

```sql
SELECT 이름, 급여 + 커미션 FROM 사원 WHERE 부서번호 = 30;
```

{to_markdown_table(("이름", "급여 + 커미션"), DEPARTMENT_30_TOTAL_PAY_ROWS)}

최유나는 급여가 3200이지만 커미션이 NULL이라서 합계도 NULL이 나와요. 비교도 비슷해서 `커미션 = NULL`이나 `커미션 > 100`처럼 NULL과 비교하면 참도 거짓도 아닌 UNKNOWN(알 수 없음)이 되고, WHERE 절은 참인 행만 남기므로 그 행은 빠져요. NULL인 행을 찾으려면 `=` 대신 NULL인지 확인하는 전용 조건인 `IS NULL`을 써요. 비교와 `IS NULL`의 자세한 규칙은 2단원의 WHERE 절과 NULL에서 다뤄요.

## 집계 함수는 NULL을 빼고 계산해요 {{#aggregate}}

여러 행을 모아 값 하나를 만드는 함수를 집계 함수라고 해요. SUM은 합계, AVG는 평균, MIN과 MAX는 최솟값과 최댓값, COUNT는 개수를 구해요. 이 함수들은 NULL인 행을 빼고 계산해요.

```sql
SELECT COUNT(*), COUNT(커미션), SUM(커미션), AVG(커미션), MIN(커미션) FROM 사원;
-- 8, 4, 1000, 250, 0이 나와요
```

`COUNT(*)`는 행 자체를 세므로 8이 나오고, `COUNT(커미션)`은 커미션이 NULL이 아닌 행만 세므로 4가 나와요. 박서준의 커미션 0은 NULL이 아닌 값이라서 이 4에 들어가요. 그래서 커미션의 최솟값도 NULL이 아니라 0이에요.

## 자주 헷갈리는 점 {{#confusing}}

**AVG는 NULL이 아닌 행 수로 나눠요.** 커미션 합계 1000을 8명이 아니라 커미션이 있는 4명으로 나누므로 `AVG(커미션)`은 250이에요. 커미션이 NULL인 사원을 0으로 보고 8명 전체의 평균을 구하려면 합계를 전체 행 수로 직접 나눠야 해요.

```sql
SELECT SUM(커미션) / COUNT(*) FROM 사원;
-- 125가 나와요
```

**행마다 더한 뒤 합치는 것과, 합친 뒤 더하는 것은 결과가 달라요.** `SUM(급여 + 커미션)`은 행마다 급여와 커미션을 먼저 더하는데, 커미션이 NULL인 네 명은 그 결과가 NULL이 되어 SUM에서 빠져요. 그 네 명의 급여까지 함께 빠지는 셈이에요. `SUM(급여) + SUM(커미션)`은 각각 NULL을 빼고 합친 뒤 더하므로 모든 급여가 들어가요.

```sql
SELECT SUM(급여 + 커미션), SUM(급여) + SUM(커미션) FROM 사원;
-- 11200, 21900이 나와요
```

**COUNT(*)와 COUNT(컬럼)은 다른 것을 세요.** `COUNT(*)`는 NULL이 있든 없든 행의 개수이고, `COUNT(커미션)`은 커미션 값이 있는 행의 개수예요. 시험에서는 두 값이 다르게 나오는 표를 주고 결과를 물어요.

**NULL과 0과 공백은 서로 다른 값이에요.** 0과 공백은 값이 있는 것이라 COUNT에 세어지고 평균의 분모에도 들어가요. NULL만 값이 없는 것으로 보고 빠져요.

**모델링에서는 NULL을 꼭 필요한 곳에만 허용해요.** NULL이 많은 속성은 위처럼 계산 결과를 헷갈리게 만들어서, 값이 반드시 있어야 하는 속성은 NOT NULL로 정해 두는 편이 안전해요. 집계 함수와 GROUP BY(같은 값끼리 행을 묶어 묶음마다 집계하는 문법)를 함께 쓸 때의 NULL 처리는 7단원의 집계 함수와 NULL에서 더 자세히 다뤄요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

NULL이 섞인 표를 주고 `COUNT(*)`, `COUNT(컬럼)`, `AVG(컬럼)`, `SUM(A + B)`의 결과를 묻는 문제가 가장 많아요. 이때는 NULL인 행부터 표시해 두고, 집계 함수가 그 행을 빼고 계산한다는 점을 적용하면 실수가 줄어요. 모델링 쪽에서는 주식별자가 NULL을 허용하지 않는다는 점과, NULL이 0이나 공백과 다르다는 점을 물어요.""",
    "checkQuestions": [
        question(1, "NULL에 대한 설명으로 옳은 것은 무엇인가요?", "definition",
                 "NULL은 값이 정해지지 않았거나 알 수 없다는 표시예요. 0이나 공백은 값이 있는 것이라 NULL과 달라요.",
                 [choice("A", "숫자 칸의 NULL은 0과 같다", rationale="0은 값이 정해진 것이라 NULL과 달라요."),
                  choice("B", "스페이스 한 칸(' ')은 NULL이다", rationale="스페이스도 문자 하나가 들어 있는 값이에요."),
                  choice("C", "값이 아직 정해지지 않았거나 알 수 없다는 표시이다", True, "NULL의 뜻이에요."),
                  choice("D", "NULL과 비교하면 결과는 항상 거짓이다", rationale="NULL과의 비교 결과는 거짓이 아니라 UNKNOWN이에요.")]),
        question(2, "모델링에서 NULL 허용 여부에 대한 설명으로 옳지 않은 것은 무엇인가요?", "nullable",
                 "주식별자는 존재성 때문에 어떤 경우에도 NULL을 허용하지 않아요. 나머지는 모두 맞는 설명이에요.",
                 [choice("A", "주식별자도 값이 아직 없으면 NULL을 허용할 수 있다", True, "주식별자는 존재성 때문에 NULL일 수 없어서 틀린 설명이에요."),
                  choice("B", "값이 반드시 있어야 하는 속성은 NOT NULL로 정한다", rationale="필수 속성에 맞는 설명이에요."),
                  choice("C", "커미션처럼 없을 수 있는 값은 NULL을 허용한다", rationale="선택 속성에 맞는 설명이에요."),
                  choice("D", "바커 표기법에서 'o'는 NULL을 허용하는 속성을 뜻한다", rationale="바커 표기법의 선택 속성 기호예요.")]),
        question(3, "아래 사원 표에 다음 SQL을 실행한 결과는 무엇인가요?\n\n" + EMPLOYEE_PAY_TABLE, "confusing",
                 "COUNT(*)는 행 수 8을 세고, COUNT(커미션)은 커미션이 NULL이 아닌 4행만 세요. 박서준의 0도 값이라서 세어져요.",
                 [choice("A", "8, 8", rationale="COUNT(커미션)은 NULL인 행을 빼고 세요."),
                  choice("B", "4, 4", rationale="COUNT(*)는 NULL과 상관없이 모든 행을 세요."),
                  choice("C", "8, 3", rationale="박서준의 커미션 0은 NULL이 아니라서 세어져요."),
                  choice("D", "8, 4", True, "전체 8행, 커미션이 있는 4행이에요.")],
                 stem_sql="SELECT COUNT(*), COUNT(커미션) FROM 사원;"),
        question(4, "아래 사원 표에 다음 SQL을 실행한 결과는 무엇인가요?\n\n" + EMPLOYEE_PAY_TABLE, "confusing",
                 "커미션 합계 1000을 커미션이 NULL이 아닌 4명으로 나눠서 250이에요. 8명으로 나눈 125와 헷갈리지 않아야 해요.",
                 [choice("A", "125", rationale="8명 전체로 나눈 값이에요. AVG는 NULL인 행을 분모에서 빼요."),
                  choice("B", "250", True, "1000을 NULL이 아닌 4명으로 나눈 값이에요."),
                  choice("C", "NULL", rationale="집계 함수는 NULL을 빼고 계산하므로 NULL이 나오지 않아요."),
                  choice("D", "333", rationale="박서준의 0은 NULL이 아니라서 분모에 들어가요.")],
                 stem_sql="SELECT AVG(커미션) FROM 사원;"),
        question(5, "아래 사원 표에 다음 SQL을 실행한 결과는 무엇인가요?\n\n" + EMPLOYEE_PAY_TABLE, "confusing",
                 "행마다 급여 + 커미션을 먼저 계산하면 커미션이 NULL인 네 명은 NULL이 되어 SUM에서 빠져요. 남은 네 명의 합계 2800 + 2800 + 3200 + 2400이 11200이에요.",
                 [choice("A", "21900", rationale="SUM(급여) + SUM(커미션)의 결과예요."),
                  choice("B", "20900", rationale="급여만 더한 값이에요."),
                  choice("C", "11200", True, "커미션이 있는 네 명의 급여 + 커미션만 더해져요."),
                  choice("D", "NULL", rationale="SUM은 NULL인 행을 빼고 계산하므로 NULL이 나오지 않아요.")],
                 stem_sql="SELECT SUM(급여 + 커미션) FROM 사원;"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        sql_error_check("INSERT INTO 사원 (사번, 이름) VALUES (NULL, '홍길동')", "ORA-01400"),
        sql_error_check("INSERT INTO 사원 (사번, 이름) VALUES (1009, NULL)", "ORA-01400"),
        sql_check("SELECT 이름, 급여 + 커미션 FROM 사원 WHERE 부서번호 = 30",
                  DEPARTMENT_30_TOTAL_PAY_ROWS),
        sql_check("SELECT COUNT(*), COUNT(커미션), SUM(커미션), AVG(커미션), MIN(커미션) FROM 사원",
                  [[8, 4, 1000, 250, 0]]),
        sql_check("SELECT SUM(커미션) / COUNT(*) FROM 사원", [[125]]),
        sql_check("SELECT SUM(급여 + 커미션), SUM(급여) + SUM(커미션) FROM 사원", [[11200, 21900]]),
        sql_check("SELECT SUM(급여) FROM 사원", [[20900]]),
        sql_check("SELECT COUNT(*), COUNT(커미션) FROM 사원;", [[8, 4]]),
        sql_check("SELECT AVG(커미션) FROM 사원;", [[250]]),
        sql_check("SELECT SUM(급여 + 커미션) FROM 사원;", [[11200]]),
    ],
}
