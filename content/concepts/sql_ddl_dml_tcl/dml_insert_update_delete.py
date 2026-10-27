"""개념: INSERT·UPDATE·DELETE (3단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

SALES_DEPARTMENT_SALARY_TABLE = to_employee_table_md("사번", "이름", "급여", "부서번호", employee_numbers=(1004, 1006, 1007))
# 이 개념 예시·확인 문제 계산용 (사원 8명: 직급·급여·커미션·부서번호)
EMPLOYEE_DML_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "커미션", "부서번호")

PARTIAL_INSERT_STEM_SQL = "INSERT INTO 부서 (부서번호, 부서명) VALUES (60, '재무부');\nSELECT 지역 FROM 부서 WHERE 부서번호 = 60;"
UPDATE_ALL_STEM_SQL = "UPDATE 사원 SET 커미션 = 0;\nSELECT COUNT(*) FROM 사원 WHERE 커미션 = 0;"
UPDATE_NULL_STEM_SQL = "UPDATE 사원 SET 커미션 = 커미션 + 100;\nSELECT COUNT(*) FROM 사원 WHERE 커미션 IS NULL;"
DELETE_ROLLBACK_STEM_SQL = "DELETE 사원 WHERE 부서번호 = 30;\nROLLBACK;\nSELECT COUNT(*) FROM 사원;"

# 본문 예시: INSERT 두 형태 (열 목록 생략·일부 열·순서 바꾼 열 목록)
INSERT_FORMS_EXAMPLE = sql_example(
    "INSERT INTO 부서 VALUES (50, '총무부', '대전');                -- 모든 열에 정의 순서대로 넣어요\n"
    "INSERT INTO 부서 (부서번호, 부서명) VALUES (60, '재무부');      -- 지역은 NULL이 돼요\n"
    "INSERT INTO 부서 (부서명, 부서번호) VALUES ('법무부', 70);      -- 열 목록 순서로 맞추면 돼요\n"
    "SELECT 부서번호, 부서명, 지역 FROM 부서 WHERE 부서번호 >= 50 ORDER BY 부서번호;",
    ('부서번호', '부서명', '지역'), [(50, '총무부', '대전'), (60, '재무부', None), (70, '법무부', None)])

# 본문 예시: INSERT ... SELECT (20번 부서 3명)
INSERT_SELECT_EXAMPLE = sql_example(
    "CREATE TABLE 사원보관 AS SELECT * FROM 사원 WHERE 1 = 2;\n"
    "INSERT INTO 사원보관 SELECT * FROM 사원 WHERE 부서번호 = 20;\n"
    "SELECT 사번 FROM 사원보관;",
    ('사번',), [(1002,), (1003,), (1005,)])

# 본문 예시: UPDATE 계산식 (30번 부서 급여 + 100)
UPDATE_EXPRESSION_EXAMPLE = sql_example(
    "UPDATE 사원 SET 급여 = 급여 + 100 WHERE 부서번호 = 30;\n"
    "SELECT 사번, 급여 FROM 사원 WHERE 부서번호 = 30 ORDER BY 사번;",
    ('사번', '급여'), [(1004, 3300), (1006, 2800), (1007, 2300)])

# 본문 예시: UPDATE 여러 열·서브쿼리
UPDATE_COLUMNS_SUBQUERY_EXAMPLE = sql_example(
    "UPDATE 사원 SET 직급 = '과장', 급여 = 2900 WHERE 사번 = 1003;\n"
    "UPDATE 사원 SET 급여 = (SELECT MAX(급여) FROM 사원) WHERE 사번 = 1008;\n"
    "SELECT 사번, 직급, 급여 FROM 사원 WHERE 사번 IN (1003, 1008) ORDER BY 사번;",
    ('사번', '직급', '급여'), [(1003, '과장', 2900), (1008, '사원', 3200)])

# 다중 INSERT: 대상 표 3개, 조건 2개 + ELSE (ALL/FIRST 만 다름)
MULTI_INSERT_TABLES_SQL = (
    "CREATE TABLE 고급여사원 (사번 NUMBER(4), 이름 VARCHAR2(20), 급여 NUMBER(5));\n"
    "CREATE TABLE 개발부사원 (사번 NUMBER(4), 이름 VARCHAR2(20));\n"
    "CREATE TABLE 기타사원 (사번 NUMBER(4), 이름 VARCHAR2(20));"
)
MULTI_INSERT_COUNT_SQL = (
    "SELECT (SELECT COUNT(*) FROM 고급여사원) AS 고급여사원, (SELECT COUNT(*) FROM 개발부사원) AS 개발부사원,\n"
    "       (SELECT COUNT(*) FROM 기타사원) AS 기타사원 FROM DUAL;"
)


def to_conditional_insert_sql(keyword):
    """ALL 또는 FIRST > 조건부 다중 INSERT 문장 (급여 2700 이상 > 고급여, 20번 부서 > 개발부, 나머지 > 기타)"""
    return (f"INSERT {keyword}\n"
            "  WHEN 급여 >= 2700 THEN INTO 고급여사원 VALUES (사번, 이름, 급여)\n"
            "  WHEN 부서번호 = 20 THEN INTO 개발부사원 VALUES (사번, 이름)\n"
            "  ELSE INTO 기타사원 VALUES (사번, 이름)\n"
            "SELECT 사번, 이름, 급여, 부서번호 FROM 사원;")


MULTI_INSERT_COLUMNS = ("고급여사원", "개발부사원", "기타사원")
UNCONDITIONAL_INSERT_ALL_EXAMPLE = sql_example(
    "CREATE TABLE 사원이름 (사번 NUMBER(4), 이름 VARCHAR2(20));\n"
    "CREATE TABLE 사원급여 (사번 NUMBER(4), 급여 NUMBER(5));\n"
    "INSERT ALL\n"
    "  INTO 사원이름 VALUES (사번, 이름)\n"
    "  INTO 사원급여 VALUES (사번, 급여)\n"
    "SELECT 사번, 이름, 급여 FROM 사원 WHERE 부서번호 = 30;\n"
    "SELECT (SELECT COUNT(*) FROM 사원이름) AS 사원이름, (SELECT COUNT(*) FROM 사원급여) AS 사원급여 FROM DUAL;",
    ("사원이름", "사원급여"), [(3, 3)])
INSERT_ALL_EXAMPLE = sql_example("\n".join([MULTI_INSERT_TABLES_SQL, to_conditional_insert_sql("ALL"), MULTI_INSERT_COUNT_SQL]),
                                 MULTI_INSERT_COLUMNS, [(4, 3, 2)])
INSERT_FIRST_EXAMPLE = sql_example("\n".join([MULTI_INSERT_TABLES_SQL, to_conditional_insert_sql("FIRST"), MULTI_INSERT_COUNT_SQL]),
                                   MULTI_INSERT_COLUMNS, [(4, 2, 2)])
INSERT_FIRST_STEM_SQL = "\n".join([MULTI_INSERT_TABLES_SQL, to_conditional_insert_sql("FIRST"), "SELECT COUNT(*) FROM 개발부사원;"])

CONCEPT = {
    "tagKey": "dml-insert-update-delete",
    "topicCode": "sql_ddl_dml_tcl",
    "sortOrder": 4,
    "title": "INSERT·UPDATE·DELETE",
    "summary": "테이블의 행을 넣고 고치고 지우는 DML이고, COMMIT 전까지는 되돌릴 수 있어요",
    "coreMd": (
        "- INSERT에서 열 목록을 생략하면 모든 열에 테이블 정의 순서대로 값을 넣고, 일부 열만 적으면 빠진 열은 DEFAULT 값이나 NULL이 돼요.\n"
        "- UPDATE와 DELETE에서 WHERE를 빼면 테이블의 모든 행이 바뀌거나 지워져요.\n"
        "- `INSERT INTO 테이블 SELECT ...`는 조회 결과를 한꺼번에 넣고, INSERT ALL은 맞는 WHEN 절을 모두, INSERT FIRST는 처음 맞는 WHEN 절 하나만 실행해요.\n"
        "- Oracle은 `DELETE 사원 WHERE ...`처럼 FROM을 생략할 수 있고, DELETE는 열이 아니라 행 전체를 지워요.\n"
        "- DML 결과는 COMMIT 전까지 내 세션에서만 보이고, ROLLBACK하면 되돌아가요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

CREATE TABLE로 테이블을 만들어도 처음에는 빈 표예요. 표에 행을 넣고, 넣은 값을 고치고, 필요 없는 행을 지우는 명령어가 각각 INSERT, UPDATE, DELETE이고, 이들을 DML(Data Manipulation Language, 데이터 조작어)이라고 불러요. 데이터를 읽는 SELECT와 다음 개념에서 볼 MERGE도 DML에 들어가요.

DDL이 테이블의 구조를 다룬다면 DML은 테이블 안의 행을 다뤄요. 또 Oracle은 DDL을 실행할 때 그 앞과 뒤에서 자동으로 확정하지만, DML은 COMMIT으로 확정하기 전까지 ROLLBACK으로 되돌릴 수 있다는 점도 달라요.

이 개념의 예시와 확인 문제는 공통 예시 데이터의 사원 표 8명을 고쳐요. 계산에 쓰는 열은 아래와 같아요.

{EMPLOYEE_DML_TABLE}

## INSERT: 행 넣기 {{#insert}}

INSERT는 열 목록을 적는 방법과 생략하는 방법 두 가지로 쓸 수 있어요.

```sql
-- 문법
INSERT INTO 테이블 (열1, 열2, ...) VALUES (값1, 값2, ...);
INSERT INTO 테이블 VALUES (값1, 값2, ...);
```

열 목록을 생략하면 테이블의 모든 열에, 테이블을 만들 때 정한 열 순서대로 값을 넣어야 해요. 부서 표는 부서번호, 부서명, 지역 순서라서 값도 세 개를 그 순서로 적어요. 열 목록을 적으면 적은 순서대로 값을 맞추면 되고, 적지 않은 열에는 DEFAULT로 정한 기본값이 들어가며, 기본값이 없으면 NULL이 들어가요.

{INSERT_FORMS_EXAMPLE.markdown}

값의 개수가 열과 맞지 않으면 오류가 나요. 값이 모자라면 ORA-00947(값이 모자람), 남으면 ORA-00913(값이 너무 많음)이에요. NOT NULL 열을 열 목록에서 빼도, 그 열에 NULL이 들어가려다 막혀서 오류(ORA-01400, NULL을 넣을 수 없음)가 나요.

```sql
INSERT INTO 부서 VALUES (80, '감사부');                      -- 오류: 지역 값이 없어요 (ORA-00947)
INSERT INTO 부서 (부서번호, 지역) VALUES (80, '대전');        -- 오류: 부서명은 NOT NULL이에요 (ORA-01400)
```

문자와 날짜 값은 작은따옴표로 감싸요. 날짜는 `DATE '2026-10-27'`처럼 DATE를 앞에 붙여 쓰면 설정과 관계없이 정확히 들어가요. 그냥 `'2026-10-27'`이라고 쓰면 데이터베이스의 날짜 형식 설정에 따라 오류가 날 수 있어요.

## INSERT ... SELECT: 조회 결과를 한꺼번에 넣기 {{#insert-select}}

VALUES 자리에 SELECT 문을 바로 쓰면, 조회된 행이 몇 개든 한 문장으로 모두 넣을 수 있어요. 아래는 20번 부서 사원을 보관용 표로 옮겨 담은 예시예요. 보관용 표는 CTAS로 구조만 복사해서 먼저 만들어 두었어요.

{INSERT_SELECT_EXAMPLE.markdown}

이때 VALUES는 쓰지 않아요. `VALUES (SELECT ...)`처럼 쓰면 오류(ORA-00936, 값 자리의 식이 잘못됨)가 나요. SELECT가 돌려주는 열의 개수와 순서는 넣을 열과 맞아야 해요.

## 다중 INSERT: INSERT ALL과 INSERT FIRST {{#multi-insert}}

Oracle은 SELECT 결과를 한 번 읽어서 여러 표에 나눠 넣는 다중 INSERT를 지원해요. 끝에 쓴 SELECT(서브쿼리)가 돌려준 행마다 INTO 절을 따져서, 그 행을 어느 표에 넣을지 정해요.

```sql
-- 문법: 조건 없이 모든 INTO를 실행해요
INSERT ALL
  INTO 표1 VALUES (...)
  INTO 표2 VALUES (...)
SELECT ... FROM ...;
-- 문법: WHEN 조건에 따라 나눠 넣어요 (ALL 또는 FIRST)
INSERT ALL
  WHEN 조건1 THEN INTO 표1 VALUES (...)
  WHEN 조건2 THEN INTO 표2 VALUES (...)
  ELSE INTO 표3 VALUES (...)
SELECT ... FROM ...;
```

조건 없이 쓰면 SELECT가 돌려준 행 하나하나가 모든 INTO 절의 표에 들어가요. 아래는 30번 부서 3명을 두 표에 동시에 넣은 예시예요. 마지막 SELECT의 괄호 안 SELECT는 각 표의 행 수를 하나씩 세어 한 줄로 보여 주고(스칼라 서브쿼리, 서브쿼리 단원), DUAL은 Oracle이 미리 준비해 둔 한 행짜리 표예요.

{UNCONDITIONAL_INSERT_ALL_EXAMPLE.markdown}

WHEN 조건을 붙이면 ALL과 FIRST가 다르게 움직여요. INSERT ALL은 행마다 맞는 WHEN 절을 모두 실행하고, INSERT FIRST는 위에서부터 따져서 처음 맞는 WHEN 절 하나만 실행해요. ELSE는 어떤 WHEN에도 맞지 않은 행만 받아요. 아래 두 예시는 키워드만 다르고, 급여가 2700 이상이면 고급여사원, 20번 부서면 개발부사원, 나머지는 기타사원에 넣어요.

{INSERT_ALL_EXAMPLE.markdown}

{INSERT_FIRST_EXAMPLE.markdown}

개발부사원의 행 수만 3과 2로 달라요. 맨 위 사원 표의 8명을 한 명씩 따라가면 이유가 보여요.

| 사원 | 급여 >= 2700 | 부서번호 = 20 | INSERT ALL | INSERT FIRST |
|---|---|---|---|---|
| 1001 김민수 | 참 | 거짓 | 고급여사원 | 고급여사원 |
| 1002 이지은 | 거짓 | 참 | 개발부사원 | 개발부사원 |
| 1003 박서준 | 참 | 참 | 고급여사원, 개발부사원 | 고급여사원 |
| 1004 최유나 | 참 | 거짓 | 고급여사원 | 고급여사원 |
| 1005 정하늘 | 거짓 | 참 | 개발부사원 | 개발부사원 |
| 1006 한도윤 | 참 | 거짓 | 고급여사원 | 고급여사원 |
| 1007 오지민 | 거짓 | 거짓 | 기타사원 (ELSE) | 기타사원 (ELSE) |
| 1008 윤서연 | 거짓 | UNKNOWN (부서번호 NULL) | 기타사원 (ELSE) | 기타사원 (ELSE) |

박서준은 두 조건에 모두 맞아서, INSERT ALL에서는 두 표에 들어가고 INSERT FIRST에서는 먼저 맞은 고급여사원에만 들어가요. 그래서 넣은 행은 모두 INSERT ALL이 9행(4 + 3 + 2), INSERT FIRST가 8행(4 + 2 + 2)이에요.

## UPDATE: 값 고치기 {{#update}}

UPDATE는 SET 뒤에 바꿀 열과 새 값을 적고, WHERE로 바꿀 행을 골라요. 새 값에는 `급여 + 100`처럼 지금 값을 이용한 계산을 쓸 수 있어요. 아래는 30번 부서 사원의 급여를 100씩 올린 예시예요.

{SALES_DEPARTMENT_SALARY_TABLE}

{UPDATE_EXPRESSION_EXAMPLE.markdown}

여러 열을 한 번에 고칠 때는 SET 뒤에 쉼표로 이어 적고, 새 값 자리에 서브쿼리(괄호 안에 넣은 SELECT)를 써도 돼요. 아래의 `MAX(급여)`는 가장 큰 급여를 구하는 함수라서 3200이 나오고, 그룹 함수 단원에서 자세히 다뤄요.

{UPDATE_COLUMNS_SUBQUERY_EXAMPLE.markdown}

## DELETE: 행 지우기 {{#delete}}

DELETE는 WHERE로 고른 행을 통째로 지워요. 표준 문법은 `DELETE FROM 테이블`이지만, Oracle은 FROM을 생략한 `DELETE 테이블`도 받아 줘요.

```sql
DELETE FROM 사원 WHERE 사번 = 1008;
DELETE 사원 WHERE 부서번호 = 30;    -- FROM을 생략했어요
SELECT COUNT(*) FROM 사원;          -- 4가 나와요
```

남은 행을 세어 주는 `COUNT(*)`로 확인하면, 8명에서 윤서연과 30번 부서 3명이 지워져 4명이 남아요. COUNT 같은 함수는 그룹 함수 단원에서 따로 배워요.

DELETE는 행 단위로만 지우기 때문에 `DELETE 이름 FROM 사원`처럼 열을 고를 수 없어요(ORA-00933, 문장이 잘못 끝남). 한 칸만 비우고 싶으면 `UPDATE ... SET 열 = NULL`을 쓰고, 열 자체를 없애고 싶으면 `ALTER TABLE ... DROP COLUMN`을 써요. 외래 키로 참조되고 있는 부모 행은 DELETE로도 지울 수 없는데, 이 내용은 제약조건 개념에서 다뤘어요.

## 실행 후 COMMIT 전 상태 {{#before-commit}}

INSERT, UPDATE, DELETE를 실행해도 결과가 바로 확정되지는 않아요. COMMIT 전까지 바뀐 내용은 실행한 사람의 세션(데이터베이스에 접속한 연결 하나)에서만 보이고, 다른 사용자는 바뀌기 전의 값을 봐요. 바뀐 행에는 잠금(lock)이 걸려서, 다른 사용자가 같은 행을 고치려고 하면 끝날 때까지 기다려야 해요.

이 상태에서 COMMIT하면 변경이 확정되어 모두가 보게 되고, ROLLBACK하면 마지막 COMMIT 상태로 되돌아가요.

```sql
DELETE FROM 사원;
SELECT COUNT(*) FROM 사원;   -- 내 세션에서는 지워진 상태라 0이 나와요
ROLLBACK;
SELECT COUNT(*) FROM 사원;   -- 되돌아와서 8이 나와요
```

트랜잭션과 COMMIT, ROLLBACK은 뒤의 트랜잭션 개념에서 자세히 다뤄요.

## 자주 헷갈리는 점 {{#confusing}}

**WHERE를 빼면 모든 행이 대상이에요.** `UPDATE 사원 SET 커미션 = 0`은 8명 모두의 커미션을 0으로 바꾸고, `DELETE FROM 사원`은 8명을 모두 지워요. 오류가 나지 않으니 실수를 알아채기 어려워요. 시험에서도 WHERE 없는 UPDATE나 DELETE의 결과 행 수를 물으면 전체 행 수가 답이에요.

**NULL이 섞인 계산은 UPDATE에서도 NULL이에요.** 맨 위 사원 표에서 커미션이 NULL인 사원은 김민수, 최유나, 정하늘, 윤서연 4명이에요. `UPDATE 사원 SET 커미션 = 커미션 + 100`을 실행하면 이지은은 400, 박서준은 100이 되지만, 김민수처럼 NULL이던 4명은 NULL + 100이 NULL이라서 여전히 NULL이에요. NULL을 0으로 보고 더하려면 `NVL(커미션, 0) + 100`처럼 써야 하고, NVL은 SQL 함수 단원에서 다뤄요.

**같은 `= NULL`이라도 SET과 WHERE에서 뜻이 달라요.** SET에서는 값을 넣는 대입이고, WHERE에서는 값이 같은지 묻는 비교예요.

| 자리 | 예 | 뜻 | 결과 |
|---|---|---|---|
| SET | `UPDATE 사원 SET 커미션 = NULL WHERE 사번 = 1002` | 커미션을 NULL로 바꾸라는 대입이에요 | 이지은의 커미션이 NULL이 돼요 |
| WHERE | `UPDATE 사원 SET 급여 = 급여 * 2 WHERE 급여 = NULL` | 급여가 NULL과 같은지 묻는 비교예요 | 비교 결과가 늘 UNKNOWN이라 바뀌는 행이 없어요 |

그래서 NULL인 행을 고를 때는 WHERE에 `IS NULL`을 써야 해요.

**INSERT ... SELECT와 CTAS는 테이블이 있느냐가 달라요.** `INSERT INTO 사원보관 SELECT ...`는 이미 있는 테이블에 행을 더하는 DML이고, `CREATE TABLE 사원보관 AS SELECT ...`는 테이블을 새로 만드는 DDL이에요. 그래서 INSERT ... SELECT는 ROLLBACK할 수 있고, CTAS는 자동으로 커밋돼요.

**DELETE 전체 삭제와 TRUNCATE는 결과만 같아요.** `DELETE FROM 사원`과 `TRUNCATE TABLE 사원` 모두 행이 0개가 되지만, DELETE는 DML이라 ROLLBACK할 수 있고 WHERE도 붙일 수 있어요. TRUNCATE는 DDL이라 자동으로 커밋되어 되돌릴 수 없고, 테이블 구조까지 없애는 것은 DROP이에요.

**오류가 난 문장은 그 문장 전체가 취소돼요.** `DELETE FROM 부서`는 네 부서를 모두 지우려고 하는데, 사원이 있는 10·20·30번 부서에서 외래 키 오류가 나요. 이때 사원이 없는 40번 부서만 지워지고 끝나는 것이 아니라, 문장 하나가 통째로 취소되어 네 부서가 모두 남아요. 그 전에 성공한 다른 문장은 그대로 남아 있어요.

```sql
DELETE FROM 부서;            -- 오류: 사원이 있는 부서가 있어요 (ORA-02292)
SELECT COUNT(*) FROM 부서;   -- 40번도 지워지지 않아서 4가 나와요
```

**INSERT ALL은 한 행이 여러 표에 들어갈 수 있고, INSERT FIRST는 한 표에만 들어가요.** 여러 WHEN에 동시에 맞는 행이 있을 때 결과가 갈려요. INSERT FIRST에 ELSE까지 있으면 SELECT가 돌려준 행이 꼭 한 번씩 들어가서, 넣은 행 수의 합이 SELECT 결과 행 수와 같아요. INSERT ALL은 그 합이 더 커질 수 있어요.

**INSERT FIRST는 WHEN의 순서가 결과를 바꿔요.** 같은 고급여사원 표에 `WHEN 급여 >= 2700`과 `WHEN 급여 >= 3000`을 둘 다 쓰면, INSERT ALL에서는 김민수와 최유나가 두 조건에 모두 맞아 두 번씩 들어가서 6행이 돼요. INSERT FIRST로 바꾸면 위의 조건 하나만 실행되어 한 사람이 한 번만 들어가므로 4행이에요.

**다중 INSERT 끝에는 SELECT가 꼭 있어야 해요.** 고정된 값 몇 행을 넣을 때도 끝에 `SELECT * FROM DUAL`을 붙여요. 또 INSERT FIRST는 WHEN 없이 쓸 수 없어요.

```sql
CREATE TABLE 사원이름 (사번 NUMBER(4), 이름 VARCHAR2(20));
INSERT ALL INTO 사원이름 VALUES (1009, '강하준');                                -- 오류: 끝에 SELECT가 없어요 (ORA-00928)
INSERT FIRST INTO 사원이름 VALUES (사번, 이름) SELECT 사번, 이름 FROM 사원;     -- 오류: FIRST에는 WHEN이 있어야 해요 (ORA-00905)
INSERT ALL
  INTO 사원이름 VALUES (1009, '강하준')
  INTO 사원이름 VALUES (1010, '서지우')
SELECT * FROM DUAL;
SELECT COUNT(*) FROM 사원이름;                                                  -- 두 행이 들어가서 2가 나와요
```

**INSERT의 INTO는 생략할 수 없어요.** DELETE의 FROM은 Oracle에서 생략할 수 있지만, INSERT의 INTO를 빼고 `INSERT 부서 VALUES (...)`라고 쓰면 오류(ORA-00925, INTO 키워드 누락)가 나요. 생략 가능한 키워드를 묻는 보기에서 둘이 섞여 나와요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

예시 표를 주고 INSERT, UPDATE, DELETE를 실행한 뒤의 결과 행 수나 값을 묻는 문제가 가장 많아요. 이때는 WHERE 조건에 맞는 행이 몇 개인지, NULL이 섞인 계산이 있는지, 중간에 ROLLBACK이 있는지를 차례로 확인하면 돼요. 열 목록을 생략한 INSERT의 값 개수, Oracle에서 생략할 수 있는 키워드, DELETE와 TRUNCATE의 차이도 보기로 자주 나와요. 최근에는 INSERT FIRST나 INSERT ALL을 주고 표마다 들어간 행 수를 묻는 문제도 나왔는데, 위의 추적 표처럼 행마다 맞는 WHEN을 적어 보면 풀려요.""",
    "checkQuestions": [
        question(1, "테이블에 이미 들어 있는 행의 값을 고치는 명령어는 무엇인가요?", "update",
                 "UPDATE는 SET으로 새 값을 정하고 WHERE로 고칠 행을 골라 값을 바꿔요. INSERT는 행을 더하고, DELETE는 행을 지워요.",
                 [choice("A", "INSERT", rationale="INSERT는 새 행을 넣는 명령어예요."),
                  choice("B", "DELETE", rationale="DELETE는 행을 통째로 지우는 명령어예요."),
                  choice("C", "UPDATE", True, "이미 있는 행의 값을 고치는 DML이에요."),
                  choice("D", "ALTER", rationale="ALTER는 값이 아니라 테이블 구조를 고치는 DDL이에요.")]),
        question(2, "다음 SQL을 실행했을 때 마지막 SELECT의 결과는 무엇인가요? (지역 열에는 DEFAULT가 없어요)", "insert",
                 "열 목록에 지역을 적지 않았고 기본값도 없으므로 지역에는 NULL이 들어가요.",
                 [choice("A", "'서울'", rationale="다른 행의 값을 가져오지 않아요. 기본값이 없으면 NULL이에요."),
                  choice("B", "NULL", True, "열 목록에서 빠진 열은 기본값이 없으면 NULL이 돼요."),
                  choice("C", "오류가 난다", rationale="지역 열은 NOT NULL이 아니라서 비워 둘 수 있어요."),
                  choice("D", "공백 한 칸", rationale="빠진 열을 공백으로 채우지 않아요.")],
                 stem_sql=PARTIAL_INSERT_STEM_SQL),
        question(3, "공통 예시 데이터(커미션 NULL인 사원 4명)에서 다음 SQL을 실행하면 마지막 결과는 무엇인가요?", "confusing",
                 "NULL + 100은 NULL이라서 커미션이 NULL이던 4명은 그대로 NULL이에요. 값이 있던 4명만 100씩 늘어나요.",
                 [choice("A", "4", True, "NULL이 섞인 계산은 NULL이라서 4명이 그대로 NULL이에요."),
                  choice("B", "0", rationale="NULL을 0으로 보고 더하지 않아요. 그러려면 NVL이 필요해요."),
                  choice("C", "8", rationale="커미션 값이 있던 4명은 100씩 늘어나 NULL이 되지 않아요."),
                  choice("D", "오류가 난다", rationale="NULL과 숫자의 덧셈은 오류 없이 NULL이 돼요.")],
                 stem_sql=UPDATE_NULL_STEM_SQL),
        question(4, "공통 예시 데이터(사원 8명, 30번 부서 3명)에서 다음 SQL을 차례로 실행하면 마지막 결과는 무엇인가요?", "before-commit",
                 "Oracle은 DELETE에서 FROM을 생략할 수 있어서 30번 부서 3명이 지워져요. 그러나 COMMIT 전에 ROLLBACK했으므로 8명으로 되돌아와요.",
                 [choice("A", "5", rationale="ROLLBACK으로 지운 3명이 되돌아와요."),
                  choice("B", "FROM이 없어서 오류가 난다", rationale="Oracle은 DELETE의 FROM을 생략해도 돼요."),
                  choice("C", "8", True, "COMMIT 전이라 ROLLBACK으로 지우기 전 상태가 돼요."),
                  choice("D", "0", rationale="WHERE로 30번 부서만 골랐고, 그마저 ROLLBACK으로 되돌아와요.")],
                 stem_sql=DELETE_ROLLBACK_STEM_SQL),
        question(5, "공통 예시 데이터(본문 맨 위 사원 표의 급여·부서번호)에서 다음 SQL을 차례로 실행하면 마지막 결과는 무엇인가요?", "multi-insert",
                 "INSERT FIRST는 처음 맞는 WHEN 하나만 실행해요. 20번 부서 3명 중 박서준은 급여 2800이라 먼저 고급여사원에 들어가서, 개발부사원에는 이지은과 정하늘 2명만 들어가요.",
                 [choice("A", "3", rationale="INSERT ALL이라면 3이지만, FIRST라서 박서준은 고급여사원에만 들어가요."),
                  choice("B", "4", rationale="급여 2700 이상인 고급여사원의 행 수예요."),
                  choice("C", "0", rationale="20번 부서 사원 중 급여가 2700보다 낮은 2명은 개발부사원에 들어가요."),
                  choice("D", "2", True, "박서준이 고급여사원으로 먼저 빠져서 이지은과 정하늘만 남아요.")],
                 stem_sql=INSERT_FIRST_STEM_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 다중 INSERT: 무조건 ALL, 조건부 ALL·FIRST, 추적 표, 확인 문제 5
        UNCONDITIONAL_INSERT_ALL_EXAMPLE.check,
        INSERT_ALL_EXAMPLE.check,
        INSERT_FIRST_EXAMPLE.check,
        sql_check(INSERT_FIRST_STEM_SQL, [[2]]),
        sql_check("SELECT 사번 FROM 개발부사원 ORDER BY 사번", [[1002], [1003], [1005]], True,
                  setup=MULTI_INSERT_TABLES_SQL + "\n" + to_conditional_insert_sql("ALL")),
        sql_check("SELECT 사번 FROM 개발부사원 ORDER BY 사번", [[1002], [1005]], True,
                  setup=MULTI_INSERT_TABLES_SQL + "\n" + to_conditional_insert_sql("FIRST")),
        sql_check("SELECT 사번 FROM 기타사원 ORDER BY 사번", [[1007], [1008]], True,
                  setup=MULTI_INSERT_TABLES_SQL + "\n" + to_conditional_insert_sql("ALL")),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 급여 >= 2700", [[4]]),
        # WHEN 순서: ALL 은 두 번(6행), FIRST 는 한 번(4행)
        sql_check("CREATE TABLE 고급여사원 (사번 NUMBER(4), 이름 VARCHAR2(20), 급여 NUMBER(5));\n"
                  "INSERT ALL\n  WHEN 급여 >= 2700 THEN INTO 고급여사원 VALUES (사번, 이름, 급여)\n"
                  "  WHEN 급여 >= 3000 THEN INTO 고급여사원 VALUES (사번, 이름, 급여)\nSELECT 사번, 이름, 급여 FROM 사원;\n"
                  "SELECT COUNT(*) FROM 고급여사원;", [[6]]),
        sql_check("CREATE TABLE 고급여사원 (사번 NUMBER(4), 이름 VARCHAR2(20), 급여 NUMBER(5));\n"
                  "INSERT FIRST\n  WHEN 급여 >= 3000 THEN INTO 고급여사원 VALUES (사번, 이름, 급여)\n"
                  "  WHEN 급여 >= 2700 THEN INTO 고급여사원 VALUES (사번, 이름, 급여)\nSELECT 사번, 이름, 급여 FROM 사원;\n"
                  "SELECT COUNT(*) FROM 고급여사원;", [[4]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 급여 >= 3000 ORDER BY 사번", [["김민수"], ["최유나"]], True),
        # 끝 SELECT 필수, FIRST 는 WHEN 필수, DUAL 로 고정값 여러 행
        sql_error_check("INSERT ALL INTO 사원이름 VALUES (1009, '강하준')", "ORA-00928",
                        setup="CREATE TABLE 사원이름 (사번 NUMBER(4), 이름 VARCHAR2(20));"),
        sql_error_check("INSERT FIRST INTO 사원이름 VALUES (사번, 이름) SELECT 사번, 이름 FROM 사원", "ORA-00905",
                        setup="CREATE TABLE 사원이름 (사번 NUMBER(4), 이름 VARCHAR2(20));"),
        sql_check("CREATE TABLE 사원이름 (사번 NUMBER(4), 이름 VARCHAR2(20));\n"
                  "INSERT ALL\n  INTO 사원이름 VALUES (1009, '강하준')\n  INTO 사원이름 VALUES (1010, '서지우')\nSELECT * FROM DUAL;\n"
                  "SELECT COUNT(*) FROM 사원이름;", [[2]]),
        # INSERT 두 형태, 빠진 열 NULL, 값 개수 오류, NOT NULL 열 빠짐 (확인 문제 2)
INSERT_FORMS_EXAMPLE.check,
        sql_check(PARTIAL_INSERT_STEM_SQL, [[None]]),
        sql_error_check("INSERT INTO 부서 VALUES (80, '감사부')", "ORA-00947"),
        sql_error_check("INSERT INTO 부서 VALUES (80, '감사부', '서울', '추가')", "ORA-00913"),
        sql_error_check("INSERT INTO 부서 (부서번호, 지역) VALUES (80, '대전')", "ORA-01400"),
        sql_check("INSERT INTO 사원 (사번, 이름, 입사일) VALUES (1009, '강하준', DATE '2026-10-27');\n"
                  "SELECT 입사일 FROM 사원 WHERE 사번 = 1009;", [["2026-10-27"]]),
        # INSERT ... SELECT, VALUES (SELECT ...) 불가
INSERT_SELECT_EXAMPLE.check,
        sql_error_check("INSERT INTO 사원보관 VALUES (SELECT * FROM 사원 WHERE 사번 = 1001)", "ORA-00936",
                        setup="CREATE TABLE 사원보관 AS SELECT * FROM 사원 WHERE 1 = 2;"),
        # UPDATE: 계산식, 여러 열, 서브쿼리
UPDATE_EXPRESSION_EXAMPLE.check,
UPDATE_COLUMNS_SUBQUERY_EXAMPLE.check,
        # DELETE: FROM 생략, 열 지정 불가
        sql_check("SELECT COUNT(*) FROM 사원", [[4]],
                  setup="DELETE FROM 사원 WHERE 사번 = 1008;\nDELETE 사원 WHERE 부서번호 = 30;"),
        sql_error_check("DELETE 이름 FROM 사원 WHERE 사번 = 1001", "ORA-00933"),
        # COMMIT 전 내 세션에서 보임, ROLLBACK 으로 되돌림
        sql_check("DELETE FROM 사원;\nSELECT COUNT(*) FROM 사원;", [[0]]),
        sql_check("DELETE FROM 사원;\nROLLBACK;\nSELECT COUNT(*) FROM 사원;", [[8]]),
        # WHERE 없는 UPDATE, NULL 계산 (확인 문제 3)
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 커미션 = 0", [[1]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 커미션 IS NULL", [[4]]),
        sql_check(UPDATE_ALL_STEM_SQL, [[8]]),
        sql_check(UPDATE_NULL_STEM_SQL, [[4]]),
        sql_check("SELECT 사번, 커미션 FROM 사원 WHERE 사번 IN (1001, 1002, 1003) ORDER BY 사번", [[1001, None], [1002, 400], [1003, 100]], True,
                  setup="UPDATE 사원 SET 커미션 = 커미션 + 100;"),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 커미션 IS NULL", [[0]],
                  setup="UPDATE 사원 SET 커미션 = NVL(커미션, 0) + 100;"),
        # SET = NULL 은 대입, WHERE = NULL 은 0행
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 커미션 IS NULL", [[5]],
                  setup="UPDATE 사원 SET 커미션 = NULL WHERE 사번 = 1002;"),
        sql_check("SELECT SUM(급여) FROM 사원", [[20900]], setup="UPDATE 사원 SET 급여 = 급여 * 2 WHERE 급여 = NULL;"),
        # 문장 단위 취소, INSERT 의 INTO 생략 불가
        sql_check("SELECT COUNT(*) FROM 부서", [[4]], setup="DELETE FROM 부서; -- 오류: ORA-02292"),
        sql_error_check("DELETE FROM 부서", "ORA-02292"),
        sql_error_check("INSERT 부서 VALUES (50, '총무부', '대전')", "ORA-00925"),
        # DELETE FROM 생략 + ROLLBACK (확인 문제 4)
        sql_check(DELETE_ROLLBACK_STEM_SQL, [[8]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 부서번호 = 30", [[3]]),
    ],
}
