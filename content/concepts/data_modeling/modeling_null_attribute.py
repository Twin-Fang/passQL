"""개념: NULL 속성 (1단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

EMPLOYEE_PAY_TABLE = to_employee_table_md("사번", "이름", "급여", "커미션", "부서번호")

# 본문 예시: SQL 블록 + 결과 표 = 검증 항목 (sql_example 한 원본)
# 30번 부서 급여 + 커미션 (커미션 NULL 이면 합계도 NULL)
DEPARTMENT_30_TOTAL_PAY_EXAMPLE = sql_example(
    "SELECT 이름, 급여 + 커미션 FROM 사원 WHERE 부서번호 = 30;",
    ("이름", "급여 + 커미션"), [["최유나", None], ["한도윤", 3200], ["오지민", 2400]], is_ordered=False)
# 집계 함수 네 개 (NULL 행 제외, COUNT(*) 만 모든 행), 표 폭 때문에 MIN 은 sqlChecks 에서 따로 확인
COMMISSION_AGGREGATE_EXAMPLE = sql_example(
    "SELECT COUNT(*), COUNT(커미션), SUM(커미션), AVG(커미션) FROM 사원;",
    ("COUNT(*)", "COUNT(커미션)", "SUM(커미션)", "AVG(커미션)"), [[8, 4, 1000, 250]])
# 평균 분모 비교: NULL 아닌 4명 <-> 전체 8명
COMMISSION_AVERAGE_EXAMPLE = sql_example(
    "SELECT AVG(커미션), SUM(커미션) / COUNT(*) FROM 사원;",
    ("AVG(커미션)", "SUM(커미션) / COUNT(*)"), [[250, 125]])
# 합계 순서 비교: 행마다 더한 뒤 합침 <-> 합친 뒤 더함
TOTAL_PAY_SUM_EXAMPLE = sql_example(
    "SELECT SUM(급여 + 커미션), SUM(급여) + SUM(커미션) FROM 사원;",
    ("SUM(급여 + 커미션)", "SUM(급여) + SUM(커미션)"), [[11200, 21900]])

CONCEPT = {
    "tagKey": "modeling-null-attribute",
    "topicCode": "data_modeling",
    "sortOrder": 13,
    "title": "NULL 속성",
    "summary": "값이 아직 정해지지 않았다는 표시라서, 계산과 집계가 달라져요",
    "coreMd": (
        "- NULL은 값이 정해지지 않았거나 알 수 없다는 표시이고, **0이나 공백**과 달라요.\n"
        "- 주식별자는 **존재성** 때문에 어떤 경우에도 NULL을 허용하지 않아요.\n"
        "- NULL이 섞인 산술 연산은 NULL, NULL과의 비교는 **UNKNOWN**이에요.\n"
        "- 집계 함수는 NULL인 행을 빼고 계산하고, COUNT(*)만 모든 행을 세요.\n"
        "- AVG는 **NULL이 아닌 행 수**로 나누고, SUM(A + B)에서는 A나 B가 NULL인 행이 통째로 빠져요."
    ),
    "detailMd": f"""## 왜 필요한가요 — 0과 "아직 없음"을 구별하려고 {{#why}}

신입 사원의 커미션(판매 실적에 따라 급여 외에 더 받는 돈)이 아직 정해지지 않았다면 그 칸에 0을 넣을 수는 없어요. 0을 넣으면 "커미션이 0원으로 정해졌다"와 구별되지 않아서, 데이터베이스는 "아직 값이 없다"를 뜻하는 NULL을 따로 둬요.

NULL은 계산과 집계 결과를 바꿔 놓기 때문에 어떤 속성에 NULL을 허용할지는 모델링 단계에서 정해요. 이 글은 공통 예시 데이터의 사원 표로 설명해요.

{EMPLOYEE_PAY_TABLE}

## 한 줄 정의 — 0도 공백도 아닌 "모름" {{#definition}}

| 용어 | 뜻 |
|---|---|
| NULL | 값이 아직 정해지지 않았거나 알 수 없다는 상태를 뜻하는 표시예요. 김민수의 커미션 NULL은 0원이 아니라 정해진 값이 없다는 뜻이에요 |
| 0 | 값이 0으로 정해진 거예요. 커미션이 0인 박서준은 커미션이 NULL인 김민수와 다른 상태예요 |
| 공백 (' ') | 스페이스 한 칸은 눈에 보이지 않을 뿐 문자 하나가 들어 있는 값이에요 |
| 빈 문자열 ('') | Oracle은 아무것도 없는 빈 문자열을 NULL로 저장해요. 이 점이 다른 데이터베이스와 달라요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| Oracle에서 빈 문자열('')을 넣으면 NULL로 저장돼요 | O | Oracle은 빈 문자열과 NULL을 같게 다뤄요 |

## 모델링에서 NULL 허용 여부 — 주식별자는 언제나 NOT NULL {{#nullable}}

모델을 만들 때는 속성마다 값이 반드시 있어야 하는지를 정해요. 공통 사원 테이블에서 사번은 주식별자, 이름은 NOT NULL이고, 커미션과 부서번호는 NULL을 허용해요.

| 용어 | 뜻 |
|---|---|
| 필수 속성 (NOT NULL) | 값이 반드시 있어야 하는 속성이에요. 예: 사원의 이름 |
| 선택 속성 (NULL 허용) | 비어 있어도 되는 속성이에요. 예: 커미션, 부서번호 |
| 주식별자 | 사원 한 명을 구별하는 대표 속성(사번)이에요. 존재성을 지켜야 해서 언제나 NULL을 허용하지 않아요 |

바커(Barker) 표기법은 속성 이름 앞에 기호를 붙여 이 셋을 구분해요.

| 바커 기호 | 뜻 |
|---|---|
| # | 주식별자 |
| * | 필수 속성 |
| o | NULL을 허용하는 선택 속성 |

INSERT는 테이블에 새 행을 넣는 SQL(데이터베이스에 내리는 명령문)이에요. 주식별자나 NOT NULL 칸에 NULL을 넣으려 하면 오류가 나서 행이 들어가지 않아요.

```sql
INSERT INTO 사원 (사번, 이름) VALUES (NULL, '홍길동'); -- 오류: 주식별자인 사번에는 NULL을 넣을 수 없어요
INSERT INTO 사원 (사번, 이름) VALUES (1009, NULL);     -- 오류: NOT NULL인 이름에도 NULL을 넣을 수 없어요
INSERT INTO 사원 (사번, 이름) VALUES (1009, '홍길동'); -- 성공, 적지 않은 칸은 NULL로 들어가요
```

## NULL이 섞인 계산과 비교 — 연산은 NULL, 비교는 UNKNOWN {{#operation}}

모르는 값에 무엇을 더해도 여전히 모르는 값이라서, NULL이 섞인 산술 연산은 결과가 NULL이에요. NULL과 비교하면 참도 거짓도 아닌 **UNKNOWN**(알 수 없음)이 되고, WHERE 절은 참인 행만 남겨서 그 행은 빠져요.

| 식 (커미션이 NULL인 행) | 결과 |
|---|---|
| 급여 + 커미션 | NULL |
| 커미션 = NULL | UNKNOWN |
| 커미션 > 100 | UNKNOWN |
| 커미션 IS NULL | 참 |

SELECT는 데이터를 조회하는 명령이고, WHERE 절은 조건에 맞는 행만 고르는 부분이에요. 아래는 30번 부서 사원 세 명의 급여와 커미션을 더해요.

{DEPARTMENT_30_TOTAL_PAY_EXAMPLE.markdown}

최유나는 급여가 3200이지만 커미션이 NULL이라서 합계도 NULL이에요. NULL인 행을 찾으려면 `=` 대신 전용 조건인 `IS NULL`을 쓰고, 자세한 규칙은 2단원의 WHERE 절과 NULL에서 다뤄요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 커미션이 NULL이면 급여 + 커미션은 급여 값만 남아요 | X | NULL이 섞인 산술 연산은 결과가 NULL이에요 |

## 집계 함수는 NULL을 빼요 — COUNT(*)만 모든 행 {{#aggregate}}

| 용어 | 뜻 |
|---|---|
| 집계 함수 | 여러 행을 모아 값 하나를 만드는 함수예요. SUM은 합계, AVG는 평균, MIN과 MAX는 최솟값과 최댓값, COUNT는 개수를 구하고, 모두 NULL인 행을 빼고 계산해요 |
| COUNT(*) | 행 자체를 세서, NULL이 있든 없든 모든 행을 세요 |
| COUNT(커미션) | 커미션이 NULL이 아닌 행만 세요 |

{COMMISSION_AGGREGATE_EXAMPLE.markdown}

박서준의 커미션 0은 NULL이 아닌 값이라서 **COUNT(커미션)의 4**에 들어가요. 그래서 커미션의 최솟값도 NULL이 아니라 0이에요.

AVG는 합계 1000을 8명이 아니라 커미션이 있는 **4명**으로 나눠요. NULL인 사원을 0으로 보고 8명 평균을 내려면 같은 사원 표에서 합계를 전체 행 수로 직접 나눠요.

{COMMISSION_AVERAGE_EXAMPLE.markdown}

## 자주 헷갈리는 점 — 분모와 더하는 순서 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| AVG(커미션)은 8명 전체로 나눠요 | NULL이 아닌 4명으로 나눠서 250이에요. 8명 기준 125를 원하면 SUM(커미션) / COUNT(*)로 직접 나눠요 |
| SUM(급여 + 커미션)과 SUM(급여) + SUM(커미션)은 같아요 | 앞은 행마다 먼저 더해서 커미션이 NULL인 네 명이 NULL이 되어 빠지고, 그 네 명의 급여도 함께 빠져요. 뒤는 각각 NULL을 빼고 합친 뒤 더해서 모든 급여가 들어가요 |
| COUNT(*)와 COUNT(커미션)은 같은 값이 나와요 | COUNT(*)는 행의 개수, COUNT(커미션)은 커미션 값이 있는 행의 개수예요. 시험은 두 값이 다르게 나오는 표를 줘요 |
| 0과 공백도 NULL처럼 집계에서 빠져요 | 0과 공백은 값이 있어서 COUNT에 세어지고 평균의 분모에도 들어가요. 빠지는 것은 NULL뿐이에요 |
| NULL과 비교하면 결과는 거짓이에요 | 거짓이 아니라 UNKNOWN이에요. WHERE 절은 참인 행만 남기니 결과에서 빠지는 것은 같아요 |
| NULL은 많이 허용할수록 유연해서 좋아요 | NULL이 많은 속성은 계산 결과를 헷갈리게 만들어요. 값이 반드시 있어야 하는 속성은 NOT NULL로 정해 두는 편이 안전해요 |

같은 사원 표로 두 합계를 나란히 구하면 차이가 바로 보여요.

{TOTAL_PAY_SUM_EXAMPLE.markdown}

집계 함수와 GROUP BY(같은 값끼리 행을 묶어 묶음마다 집계하는 문법)를 함께 쓸 때의 NULL 처리는 7단원의 집계 함수와 NULL에서 더 자세히 다뤄요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| COUNT(*)는 커미션이 NULL인 행도 세요 | O | COUNT(*)는 칸 값과 상관없이 행 자체를 세요 |
| MIN(커미션)은 NULL이 섞여 있으니 NULL이 나와요 | X | 집계 함수는 NULL을 빼고 계산해서 박서준의 0이 최솟값이에요 |

## 꼭 외울 것 — NULL이 들어가면 무엇이 나오나 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| NULL과 0, 공백 | 서로 다름 (0과 공백은 값이 있어 집계에 들어감) |
| Oracle의 빈 문자열('') | NULL로 저장 |
| 주식별자의 NULL | 존재성 때문에 언제나 허용 안 함 |
| NULL이 섞인 산술 연산 | 결과도 NULL |
| NULL과 =, > 비교 | UNKNOWN (WHERE에서 빠짐), 찾을 때는 IS NULL |
| COUNT(*)와 COUNT(열) | COUNT(*)는 모든 행, COUNT(열)은 NULL인 행을 뺌 |
| AVG의 분모 | NULL이 아닌 행 수 (커미션 평균 250, 8명 기준이면 125) |
| SUM(A + B)의 NULL 행 | 행마다 먼저 더해 통째로 빠짐 (SUM(A) + SUM(B)와 다름) |

## 시험에서는 이렇게 나와요 {{#exam-point}}

NULL이 섞인 표를 주고 집계 결과를 묻는 문제가 가장 많아요. NULL인 행부터 표시해 두고 아래 규칙을 적용하면 실수가 줄어요.

| 묻는 것 | 기억할 것 |
|---|---|
| COUNT(*) | NULL과 상관없이 모든 행을 세요 |
| COUNT(컬럼), SUM, MIN, MAX | NULL인 행을 빼고 계산해요 |
| AVG(컬럼) | 분모도 NULL이 아닌 행 수예요 |
| SUM(A + B) | A나 B가 NULL인 행은 통째로 빠져요 |
| 주식별자 | 존재성 때문에 NULL을 허용하지 않아요 |
| NULL, 0, 공백 | 서로 다른 값이고, 0과 공백은 값이 있는 거예요 |""",
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
        DEPARTMENT_30_TOTAL_PAY_EXAMPLE.check,
        COMMISSION_AGGREGATE_EXAMPLE.check,
        # 본문 "커미션의 최솟값도 0" (박서준의 0, NULL 제외)
        sql_check("SELECT MIN(커미션) FROM 사원", [[0]]),
        COMMISSION_AVERAGE_EXAMPLE.check,
        sql_check("SELECT SUM(커미션) / COUNT(*) FROM 사원", [[125]]),
        TOTAL_PAY_SUM_EXAMPLE.check,
        sql_check("SELECT SUM(급여) FROM 사원", [[20900]]),
        sql_check("SELECT COUNT(*), COUNT(커미션) FROM 사원;", [[8, 4]]),
        sql_check("SELECT AVG(커미션) FROM 사원;", [[250]]),
        sql_check("SELECT SUM(급여 + 커미션) FROM 사원;", [[11200]]),
    ],
}
