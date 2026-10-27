"""개념: 트랜잭션과 COMMIT·ROLLBACK·SAVEPOINT (3단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

# 저장점 예시·확인 문제 행 수 계산용 (사원 8명의 부서번호)
EMPLOYEE_DEPARTMENT_TABLE = to_employee_table_md("사번", "이름", "부서번호")

COMMIT_ROLLBACK_SQL = (
    "DELETE FROM 사원 WHERE 사번 = 1008;\n"
    "COMMIT;\n"
    "DELETE FROM 사원 WHERE 사번 = 1007;\n"
    "ROLLBACK;\n"
    "SELECT COUNT(*) FROM 사원;"
)
# 저장점 두 개: 1008 삭제(7명) > 첫째 > 30번 부서 삭제(4명) > 둘째 > 20번 부서 삭제(1명)
SAVEPOINT_STEPS_SQL = (
    "DELETE FROM 사원 WHERE 사번 = 1008;\n"
    "SAVEPOINT 첫째;\n"
    "DELETE FROM 사원 WHERE 부서번호 = 30;\n"
    "SAVEPOINT 둘째;\n"
    "DELETE FROM 사원 WHERE 부서번호 = 20;"
)
SAVEPOINT_STEM_SQL = SAVEPOINT_STEPS_SQL + "\nROLLBACK TO 첫째;\nSELECT COUNT(*) FROM 사원;"
SAME_NAME_SAVEPOINT_SQL = (
    "SAVEPOINT 저장점;\n"
    "DELETE FROM 사원 WHERE 부서번호 = 30;\n"
    "SAVEPOINT 저장점;\n"
    "DELETE FROM 사원 WHERE 부서번호 = 20;\n"
    "ROLLBACK TO 저장점;\n"
    "SELECT COUNT(*) FROM 사원;"
)
DDL_AUTO_COMMIT_SQL = (
    "DELETE FROM 사원 WHERE 사번 = 1008;\n"
    "CREATE TABLE 임시 (번호 NUMBER);\n"
    "ROLLBACK;\n"
    "SELECT COUNT(*) FROM 사원;"
)
CONTINUE_AFTER_ROLLBACK_TO_SQL = (
    "INSERT INTO 부서 VALUES (50, '총무부', '대전');\n"
    "SAVEPOINT 가;\n"
    "INSERT INTO 부서 VALUES (60, '재무부', '대전');\n"
    "ROLLBACK TO 가;\n"
    "INSERT INTO 부서 VALUES (70, '법무부', '대전');\n"
    "COMMIT;\n"
    "SELECT 부서번호 FROM 부서 WHERE 부서번호 >= 50 ORDER BY 부서번호;"
)
# 본문 예시: ROLLBACK TO 뒤에도 트랜잭션 계속 (SQL 블록 + 결과 표 = 검증 항목)
CONTINUE_AFTER_ROLLBACK_TO_EXAMPLE = sql_example(CONTINUE_AFTER_ROLLBACK_TO_SQL, ("부서번호",), [(50,), (70,)])

CONCEPT = {
    "tagKey": "tcl-commit-rollback",
    "topicCode": "sql_ddl_dml_tcl",
    "sortOrder": 6,
    "title": "트랜잭션과 COMMIT·ROLLBACK·SAVEPOINT",
    "summary": "여러 변경을 한 묶음으로 확정하거나 취소하고, 중간 지점까지만 되돌릴 수도 있어요",
    "coreMd": (
        "- 트랜잭션은 한꺼번에 성공하거나 한꺼번에 취소되어야 하는 작업 묶음이고, COMMIT으로 확정하고 ROLLBACK으로 마지막 COMMIT 상태까지 되돌려요.\n"
        "- COMMIT 전에는 바뀐 값이 내 세션에서만 보이고, 다른 사용자는 바뀌기 전 값을 보며 바뀐 행은 잠겨서 고칠 수 없어요.\n"
        "- `ROLLBACK TO 저장점`은 그 저장점 뒤의 작업만 취소하고, 같은 이름의 저장점을 다시 만들면 마지막 것이 기준이 돼요.\n"
        "- Oracle은 DDL을 실행하면 앞의 작업까지 자동으로 커밋되고, SQL Server는 기본이 문장마다 자동 커밋이라 묶으려면 BEGIN TRANSACTION을 써요.\n"
        "- 격리 수준은 READ UNCOMMITTED < READ COMMITTED < REPEATABLE READ < SERIALIZABLE 순으로 Dirty Read, Non-Repeatable Read, Phantom Read를 하나씩 더 막아요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

계좌 이체를 생각해 보면, A 계좌에서 10만 원을 빼는 UPDATE와 B 계좌에 10만 원을 더하는 UPDATE가 함께 실행되어야 해요. 첫 번째 문장만 실행된 뒤 장애가 나면 10만 원이 어디에도 없게 되고, 이런 상태는 절대 남으면 안 돼요. 그래서 두 문장을 하나로 묶어, 둘 다 성공하면 함께 확정하고 하나라도 실패하면 함께 취소해요.

이렇게 한 덩어리로 처리해야 하는 작업 묶음을 트랜잭션(transaction)이라고 불러요. 트랜잭션을 확정하거나 취소하는 명령어인 COMMIT, ROLLBACK, SAVEPOINT를 TCL(Transaction Control Language, 트랜잭션 제어어)이라고 해요. Oracle에서는 첫 DML 문장을 실행할 때 트랜잭션이 시작되고, COMMIT이나 ROLLBACK을 하면 끝나요.

## 트랜잭션의 네 가지 성질 ACID {{#acid}}

트랜잭션이 지켜야 할 성질 네 가지를 앞 글자를 따서 ACID라고 불러요. 데이터 모델링 단원의 '트랜잭션과 데이터 모델' 개념에서 본 내용과 같아요.

| 성질 | 뜻 | 이체 예시 |
|---|---|---|
| 원자성 (Atomicity) | 모두 반영되거나 하나도 반영되지 않아요 | 출금만 되고 입금이 안 되는 일은 없어요 |
| 일관성 (Consistency) | 실행 전과 후 모두 규칙을 지키는 올바른 상태예요 | 이체 전후로 두 계좌 잔액의 합이 같아요 |
| 고립성 (Isolation) | 실행 중인 트랜잭션은 다른 트랜잭션이 끼어들지 못해요 | 이체 도중의 잔액을 다른 사람이 보지 못해요 |
| 지속성 (Durability) | 확정된 결과는 장애가 나도 사라지지 않아요 | 이체 완료 후 서버가 꺼져도 결과가 남아요 |

## COMMIT과 ROLLBACK {{#commit-rollback}}

COMMIT은 트랜잭션에서 바꾼 내용을 모두 확정하고, ROLLBACK은 마지막 COMMIT 뒤에 바꾼 내용을 모두 취소해요. 한 번 COMMIT한 내용은 ROLLBACK으로 되돌릴 수 없어요.

```sql
{COMMIT_ROLLBACK_SQL}   -- 7이 나와요
```

마지막 줄의 `COUNT(*)`는 남은 사원이 몇 명인지 세는 함수예요. 1008을 지운 일은 COMMIT으로 확정되었어요. 그 뒤에 1007을 지운 일만 ROLLBACK으로 취소되어서, 사원은 7명이 남아요.

## COMMIT·ROLLBACK 전후의 데이터 상태 {{#before-commit}}

COMMIT이나 ROLLBACK을 하기 전까지 바뀐 데이터는 아직 확정되지 않은 상태예요. 이 상태가 어떻게 보이는지가 시험에 자주 나와요.

| 시점 | 내 세션 | 다른 사용자 | 바뀐 행의 잠금 |
|---|---|---|---|
| COMMIT·ROLLBACK 전 | 바뀐 값이 보여요 | 바뀌기 전 값이 보여요 | 걸려 있어서 다른 사용자는 그 행을 고칠 수 없어요 |
| COMMIT 후 | 바뀐 값이 보여요 | 바뀐 값이 보여요 | 풀려요 |
| ROLLBACK 후 | 바뀌기 전 값이 보여요 | 바뀌기 전 값이 보여요 | 풀려요 |

세션은 데이터베이스에 접속한 연결 하나를 말해요. 잠금(lock)은 내가 고치고 있는 행을 다른 사람이 동시에 고치지 못하게 막는 표시예요. 잠긴 행을 다른 사용자가 고치려고 하면, 내가 COMMIT이나 ROLLBACK을 할 때까지 기다려야 해요. Oracle에서는 잠긴 행이라도 다른 사용자가 읽는 것은 막지 않고, 대신 바뀌기 전의 값을 보여 줘요.

## SAVEPOINT와 ROLLBACK TO {{#savepoint}}

트랜잭션이 길면 처음부터 다 취소하기보다 중간까지만 되돌리고 싶을 때가 있어요. `SAVEPOINT 이름`으로 중간 지점(저장점)을 표시해 두면, `ROLLBACK TO 이름`으로 그 지점 뒤에 한 작업만 취소할 수 있어요. 아래 예시와 확인 문제는 공통 예시 데이터의 사원 8명을 지우며, 부서번호는 아래와 같아요.

{EMPLOYEE_DEPARTMENT_TABLE}

```sql
{SAVEPOINT_STEPS_SQL}
SELECT COUNT(*) FROM 사원;   -- 1이 나와요
ROLLBACK TO 둘째;
SELECT COUNT(*) FROM 사원;   -- 4가 나와요
ROLLBACK TO 첫째;
SELECT COUNT(*) FROM 사원;   -- 7이 나와요
ROLLBACK TO 둘째;            -- 오류: 둘째는 이미 사라졌어요 (ORA-01086)
ROLLBACK;
SELECT COUNT(*) FROM 사원;   -- 8이 나와요
```

| 실행한 문장 | 남은 사원 |
|---|---|
| 시작 | 8 |
| 1008 삭제 > SAVEPOINT 첫째 | 7 |
| 30번 부서(3명) 삭제 > SAVEPOINT 둘째 | 4 |
| 20번 부서(3명) 삭제 | 1 |
| ROLLBACK TO 둘째 | 4 |
| ROLLBACK TO 첫째 | 7 |
| ROLLBACK | 8 |

`ROLLBACK TO 첫째`를 하면 첫째 뒤에 만든 저장점 둘째도 함께 사라져요. 그래서 그다음 `ROLLBACK TO 둘째`는 그런 저장점이 없다는 오류가 나요. TO 없이 ROLLBACK만 쓰면 저장점과 관계없이 트랜잭션 처음(마지막 COMMIT)으로 돌아가요.

Oracle은 `ROLLBACK TO SAVEPOINT 첫째`처럼 SAVEPOINT를 넣어 써도 같아요. SQL Server는 저장점을 `SAVE TRANSACTION 이름`으로 만들고 `ROLLBACK TRANSACTION 이름`으로 되돌려요.

## 자동 커밋 {{#auto-commit}}

Oracle은 DML을 실행해도 직접 COMMIT하기 전까지는 확정하지 않아요. 하지만 CREATE, ALTER, DROP, RENAME, TRUNCATE 같은 DDL과 GRANT, REVOKE 같은 DCL은 자동으로 커밋돼요. Oracle은 DDL을 실행할 때 그 앞과 뒤에서 자동으로 커밋해요. 앞에서 하는 커밋 때문에, 그때까지 확정하지 않은 DML까지 함께 확정돼요.

```sql
{DDL_AUTO_COMMIT_SQL}   -- 7이 나와요
```

1008을 지운 뒤 COMMIT하지 않았는데, CREATE TABLE이 실행되면서 그 삭제가 함께 커밋되었어요. 그래서 ROLLBACK해도 되돌릴 것이 없어서 7명이 남아요. Oracle의 명령줄 접속 도구인 `SQL*Plus`는 정상적으로 종료하면 커밋하고, 접속이 비정상으로 끊기면 롤백해요.

SQL Server는 기본 동작이 반대예요. 문장 하나가 끝날 때마다 자동으로 커밋하는 자동 커밋(AUTOCOMMIT) 모드가 기본이라서, 여러 문장을 묶으려면 `BEGIN TRANSACTION`으로 트랜잭션을 직접 시작해야 해요. 이렇게 BEGIN TRANSACTION으로 직접 시작한 트랜잭션을 명시적 트랜잭션이라고 부르고, 그 안에서는 DDL도 ROLLBACK으로 되돌릴 수 있어요. 설정을 바꾸면 Oracle처럼 첫 문장에서 트랜잭션이 저절로 시작되어 COMMIT할 때까지 이어지게 할 수도 있는데, 이것을 암시적 트랜잭션이라고 해요.

```sql
-- 문법: SQL Server에서 쓰는 모양이에요
BEGIN TRANSACTION;
UPDATE 사원 SET 급여 = 급여 + 100 WHERE 부서번호 = 20;
SAVE TRANSACTION 저장점;
DELETE FROM 사원 WHERE 사번 = 1008;
ROLLBACK TRANSACTION 저장점;
COMMIT TRANSACTION;
```

## 격리 수준과 이상 현상 {{#isolation}}

여러 트랜잭션이 같은 데이터를 동시에 다루면, 서로의 작업이 끼어들면서 생기는 문제가 있어요. 시험에 나오는 이상 현상은 세 가지예요.

| 이상 현상 | 무슨 일이 생기나 |
|---|---|
| Dirty Read | 다른 트랜잭션이 고치고 아직 COMMIT하지 않은 값을 읽어요. 그 트랜잭션이 ROLLBACK하면 존재한 적 없는 값을 읽은 셈이 돼요. |
| Non-Repeatable Read | 한 트랜잭션 안에서 같은 행을 두 번 읽었는데, 그사이 다른 트랜잭션이 그 행을 고치거나 지우고 COMMIT해서 값이 달라져요. |
| Phantom Read | 같은 조건으로 두 번 조회했는데, 그사이 다른 트랜잭션이 조건에 맞는 행을 새로 넣고 COMMIT해서 처음에 없던 행이 나타나요. |

격리 수준(isolation level)은 트랜잭션끼리 얼마나 떼어 놓을지를 정하는 단계예요. 단계가 높을수록 이상 현상을 더 많이 막지만, 서로 기다리는 일이 늘어나 동시에 처리할 수 있는 양이 줄어요.

| 격리 수준 | Dirty Read | Non-Repeatable Read | Phantom Read |
|---|---|---|---|
| READ UNCOMMITTED | 생겨요 | 생겨요 | 생겨요 |
| READ COMMITTED | 막아요 | 생겨요 | 생겨요 |
| REPEATABLE READ | 막아요 | 막아요 | 생겨요 |
| SERIALIZABLE | 막아요 | 막아요 | 막아요 |

Oracle과 SQL Server 모두 기본 격리 수준은 READ COMMITTED예요. 다만 Oracle은 네 단계 중 READ COMMITTED와 SERIALIZABLE만 지원해서, 다른 단계를 지정하면 오류가 나요.

```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;   -- 오류: Oracle은 이 격리 수준을 지원하지 않아요 (ORA-02179)
```

## 자주 헷갈리는 점 {{#confusing}}

**앞쪽 저장점으로 돌아가면 그 뒤 저장점은 사라져요.** 위 예시처럼 첫째로 돌아간 뒤에는 둘째로 다시 갈 수 없어요. COMMIT을 해도 그 트랜잭션의 저장점이 모두 사라져서, COMMIT 뒤의 `ROLLBACK TO`는 오류(ORA-01086, 저장점이 없음)가 나요.

**같은 이름으로 저장점을 다시 만들면 마지막 것이 기준이에요.** 아래에서 저장점은 처음과 30번 부서 삭제 뒤, 두 번 만들어졌어요. 같은 이름이라 앞의 것은 지워지고 뒤의 것만 남기 때문에, ROLLBACK TO는 20번 부서 삭제만 취소해서 5명이 남아요.

```sql
{SAME_NAME_SAVEPOINT_SQL}   -- 5가 나와요
```

**ROLLBACK TO는 트랜잭션을 끝내지 않아요.** 저장점 뒤의 작업만 취소하고 트랜잭션은 계속돼요. 그 뒤에 COMMIT하면 저장점 앞의 작업과 ROLLBACK TO 뒤에 새로 한 작업이 함께 확정돼요. 아래에서 기존 부서번호는 10~40이라서, 50 이상인 부서는 새로 넣은 것만 나와요.

{CONTINUE_AFTER_ROLLBACK_TO_EXAMPLE.markdown}

**DDL 한 문장이 앞의 DML까지 확정해요.** Oracle에서 DML 뒤에 CREATE TABLE이나 TRUNCATE를 실행하면, 그 DDL만 확정되는 것이 아니라 앞에서 COMMIT하지 않은 DML도 함께 커밋돼요. 그 뒤의 ROLLBACK은 DDL 이후의 작업만 취소할 수 있어요.

**Non-Repeatable Read와 Phantom Read는 무엇이 바뀌었는지로 구분해요.** 이미 읽은 행의 값이 바뀌거나 행이 사라지면 Non-Repeatable Read이고, 같은 조건에 맞는 행이 새로 생겨서 행 수가 늘면 Phantom Read예요. 그래서 REPEATABLE READ는 이미 읽은 행을 지켜 주지만 새로 들어오는 행은 막지 못해요.

**Oracle과 SQL Server는 커밋 기본값이 달라요.** Oracle은 DML을 직접 COMMIT해야 확정되지만, SQL Server는 기본으로 문장마다 자동 커밋돼요. 또 Oracle의 DDL은 자동 커밋이라 되돌릴 수 없지만, SQL Server는 명시적 트랜잭션 안의 DDL을 ROLLBACK할 수 있어요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

SAVEPOINT와 ROLLBACK TO가 섞인 SQL을 주고 마지막 SELECT의 행 수를 묻는 문제가 가장 많아요. 문장마다 남은 행 수를 위의 표처럼 적어 가면서 풀고, 같은 이름의 저장점과 DDL의 자동 커밋이 있는지 확인하면 돼요. 그 밖에 COMMIT 전 데이터 상태로 옳은 설명을 고르는 문제, ACID 성질의 이름과 뜻을 짝짓는 문제, 이상 현상과 격리 수준을 짝짓는 문제가 나와요.""",
    "checkQuestions": [
        question(1, "UPDATE를 실행하고 아직 COMMIT하지 않은 상태에 대한 설명으로 옳은 것은 무엇인가요?", "before-commit",
                 "COMMIT 전에는 바뀐 값이 내 세션에서만 보이고 바뀐 행에는 잠금이 걸려요. ROLLBACK하면 바뀌기 전 값으로 돌아가요.",
                 [choice("A", "다른 사용자도 바뀐 값을 볼 수 있다", rationale="다른 사용자는 COMMIT 전까지 바뀌기 전 값을 봐요."),
                  choice("B", "바뀐 행은 잠겨서 다른 사용자가 그 행을 고칠 수 없다", True, "COMMIT이나 ROLLBACK을 할 때까지 잠금이 유지돼요."),
                  choice("C", "ROLLBACK을 해도 되돌릴 수 없다", rationale="COMMIT 전이라 ROLLBACK으로 되돌릴 수 있어요."),
                  choice("D", "바뀌기 전 값은 이미 사라져서 다시 볼 수 없다", rationale="바뀌기 전 값이 남아 있어서 다른 사용자에게 보이고, ROLLBACK에도 쓰여요.")]),
        question(2, "한 트랜잭션에서 같은 조건으로 두 번 조회했는데, 그사이 다른 트랜잭션이 행을 새로 넣고 COMMIT해서 두 번째 조회에 처음에 없던 행이 나타났어요. 이 현상은 무엇인가요?", "isolation",
                 "같은 조건에 맞는 행이 새로 생긴 경우라서 Phantom Read예요. 이미 읽은 행의 값이 바뀌었다면 Non-Repeatable Read예요.",
                 [choice("A", "Dirty Read", rationale="Dirty Read는 아직 COMMIT하지 않은 값을 읽는 현상이에요."),
                  choice("B", "Non-Repeatable Read", rationale="이미 읽은 행이 바뀌거나 사라진 경우이고, 새 행이 생긴 경우가 아니에요."),
                  choice("C", "Phantom Read", True, "같은 조건에 없던 행이 새로 나타나는 현상이에요."),
                  choice("D", "SERIALIZABLE", rationale="SERIALIZABLE은 이상 현상이 아니라 세 현상을 모두 막는 격리 수준이에요.")]),
        question(3, "공통 예시 데이터(사원 8명, 20번·30번 부서 각 3명)에서 다음 SQL을 차례로 실행하면 마지막 결과는 무엇인가요?", "savepoint",
                 "1008을 지운 뒤 만든 저장점 첫째로 돌아가므로, 그 뒤에 지운 30번·20번 부서 6명만 되살아나요. 1008 삭제는 남아서 7명이에요.",
                 [choice("A", "4", rationale="ROLLBACK TO 둘째를 했을 때의 결과예요."),
                  choice("B", "1", rationale="ROLLBACK TO 전의 결과예요."),
                  choice("C", "8", rationale="저장점 첫째 앞에서 지운 1008은 되살아나지 않아요."),
                  choice("D", "7", True, "첫째 뒤의 삭제만 취소되어 7명이 남아요.")],
                 stem_sql=SAVEPOINT_STEM_SQL),
        question(4, "공통 예시 데이터(사원 8명, 20번·30번 부서 각 3명)에서 다음 SQL을 차례로 실행하면 마지막 결과는 무엇인가요?", "confusing",
                 "같은 이름의 저장점을 다시 만들면 마지막 것만 남아요. 그래서 30번 부서 삭제 뒤의 지점으로 돌아가 5명이 남아요.",
                 [choice("A", "5", True, "두 번째 저장점으로 돌아가 20번 부서 삭제만 취소돼요."),
                  choice("B", "8", rationale="첫 번째 저장점은 같은 이름의 두 번째 저장점으로 바뀌어 사라졌어요."),
                  choice("C", "2", rationale="ROLLBACK TO 전의 결과예요."),
                  choice("D", "오류가 난다", rationale="같은 이름의 저장점을 다시 만들어도 오류는 나지 않아요.")],
                 stem_sql=SAME_NAME_SAVEPOINT_SQL),
        question(5, "Oracle에서 공통 예시 데이터(사원 8명)에 다음 SQL을 차례로 실행하면 마지막 결과는 무엇인가요?", "auto-commit",
                 "CREATE TABLE은 DDL이라 실행 직전에 자동으로 커밋되면서 앞의 DELETE도 확정돼요. 그래서 ROLLBACK해도 7명이 남아요.",
                 [choice("A", "8", rationale="DDL의 자동 커밋으로 DELETE가 이미 확정되어 ROLLBACK으로 되돌릴 수 없어요."),
                  choice("B", "7", True, "DELETE가 CREATE TABLE과 함께 커밋되어 1008은 되돌아오지 않아요."),
                  choice("C", "0", rationale="지운 사원은 1008 한 명뿐이에요."),
                  choice("D", "오류가 난다", rationale="DDL 뒤에 ROLLBACK해도 오류는 나지 않아요.")],
                 stem_sql=DDL_AUTO_COMMIT_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # COMMIT 뒤 작업만 ROLLBACK
        sql_check(COMMIT_ROLLBACK_SQL, [[7]]),
        # 저장점 단계별 행 수 (1 > 4 > 7 > 8), 사라진 저장점 오류 (확인 문제 3)
        sql_check(SAVEPOINT_STEPS_SQL + "\nSELECT COUNT(*) FROM 사원;", [[1]]),
        sql_check(SAVEPOINT_STEPS_SQL + "\nROLLBACK TO 둘째;\nSELECT COUNT(*) FROM 사원;", [[4]]),
        sql_check(SAVEPOINT_STEM_SQL, [[7]]),
        sql_error_check(SAVEPOINT_STEPS_SQL + "\nROLLBACK TO 첫째;\nROLLBACK TO 둘째;", "ORA-01086"),
        sql_check(SAVEPOINT_STEPS_SQL + "\nROLLBACK;\nSELECT COUNT(*) FROM 사원;", [[8]]),
        sql_check(SAVEPOINT_STEPS_SQL + "\nROLLBACK TO SAVEPOINT 첫째;\nSELECT COUNT(*) FROM 사원;", [[7]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 부서번호 = 30", [[3]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 부서번호 = 20", [[3]]),
        # COMMIT 뒤 저장점 소멸
        sql_error_check("DELETE FROM 사원 WHERE 사번 = 1008;\nSAVEPOINT 첫째;\nCOMMIT;\nROLLBACK TO 첫째;", "ORA-01086"),
        # 같은 이름 저장점은 마지막 것 (확인 문제 4)
        sql_check(SAME_NAME_SAVEPOINT_SQL, [[5]]),
        sql_check("SAVEPOINT 저장점;\nDELETE FROM 사원 WHERE 부서번호 = 30;\nSAVEPOINT 저장점;\n"
                  "DELETE FROM 사원 WHERE 부서번호 = 20;\nSELECT COUNT(*) FROM 사원;", [[2]]),
        # ROLLBACK TO 뒤 트랜잭션 계속
        CONTINUE_AFTER_ROLLBACK_TO_EXAMPLE.check,
        # DDL 자동 커밋 (확인 문제 5), TRUNCATE 도 같음
        sql_check(DDL_AUTO_COMMIT_SQL, [[7]]),
        sql_check("INSERT INTO 부서 VALUES (50, '총무부', '대전');\nTRUNCATE TABLE 급여등급;\nROLLBACK;\nSELECT COUNT(*) FROM 부서;", [[5]]),
        # Oracle 격리 수준: READ COMMITTED·SERIALIZABLE 만
        sql_check("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;\nSELECT COUNT(*) FROM 사원;", [[8]]),
        sql_error_check("SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED", "ORA-02179"),
        sql_error_check("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ", "ORA-02179"),
    ],
}
