"""개념: GRANT·REVOKE와 ROLE (3단원, 확인 문제 5개)

다른 계정이 필요한 SQL 은 '-- 문법' 블록 (Oracle 21c 임시 계정으로 연쇄 회수·기본 역할 권한 확인, 2026-10-27)
"""

from concept_bundle import choice, question, sql_check

DCL_AUTO_COMMIT_SQL = (
    "DELETE FROM 사원 WHERE 사번 = 1008;\n"
    "GRANT SELECT ON 사원 TO PUBLIC;\n"
    "ROLLBACK;\n"
    "SELECT COUNT(*) FROM 사원 WHERE 사번 = 1008;"
)

CONCEPT = {
    "tagKey": "dcl-grant-revoke",
    "topicCode": "sql_ddl_dml_tcl",
    "sortOrder": 7,
    "title": "GRANT·REVOKE와 ROLE",
    "summary": "누가 무엇을 할 수 있는지 권한을 주고 회수하고, 권한을 역할로 묶어 관리해요",
    "coreMd": (
        "- 시스템 권한은 CREATE TABLE처럼 할 수 있는 작업이고, 객체 권한은 `SELECT ON 사원`처럼 **객체 하나**에 대한 권한이에요.\n"
        "- 권한은 `GRANT ... TO 사용자`로 주고 `REVOKE ... FROM 사용자`로 회수해요.\n"
        "- WITH GRANT OPTION으로 받은 객체 권한은 **연쇄로 회수**되고, WITH ADMIN OPTION으로 받은 시스템 권한은 연쇄되지 않아요.\n"
        "- ROLE은 **권한 묶음**이고, 기본 역할로 CONNECT(접속), RESOURCE(객체 생성), DBA(관리)가 있어요.\n"
        "- 역할을 거쳐 받은 권한은 그 길이 끊기면 사라지지만, **직접 받은 권한은 남아요**."
    ),
    "detailMd": """## 권한이란 — 누가 무엇을 할 수 있는지 정해요 {#why}

회사 데이터베이스에는 여러 사람이 각자의 계정으로 접속하는데, 급여가 든 사원 표를 모두가 읽거나 고칠 수 있으면 안 돼요. 그래서 데이터베이스는 사용자마다 할 수 있는 일을 정해 두고, 허락받지 않은 작업은 거부해요.

| 용어 | 뜻 |
|---|---|
| 권한 (privilege) | 사용자가 할 수 있는 일 하나하나예요. 권한이 없는 작업은 거부돼요 |
| DCL (Data Control Language, 데이터 제어어) | 권한을 주는 GRANT와 회수하는 REVOKE예요 |
| 소유자 (owner) | 테이블을 만든 사용자예요. 따로 권한을 받지 않아도 자기 테이블에 무엇이든 할 수 있어요 |
| 소유자 이름 붙이기 | 다른 사용자는 권한을 받은 뒤 `HR.사원`처럼 소유자 이름을 앞에 붙여 불러요 |

이 글은 사원 표의 소유자 HR, 일반 사용자 KIM과 LEE, 관리자 DBA라는 계정을 가정해요. 계정이 여러 개 필요한 SQL이라서 문법 예시로만 보여 줘요.

## 시스템 권한과 객체 권한 — ON 객체가 붙느냐 {#privilege-types}

| 용어 | 뜻 |
|---|---|
| 시스템 권한 | 데이터베이스 전체에서 어떤 작업을 할 수 있는지 정하는 권한이에요 |
| 객체 권한 | 테이블·뷰(저장해 둔 SELECT 문) 같은 객체 하나에 무엇을 할 수 있는지 정하는 권한이에요 |
| 다시 주기 옵션 | 받은 권한을 남에게 다시 주게 하는 옵션이에요 |

| 구분 | 시스템 권한 | 객체 권한 |
|---|---|---|
| 대상 | 데이터베이스 전체의 작업 | 테이블·뷰 같은 객체 하나 |
| 예 | CREATE SESSION(접속), CREATE TABLE, CREATE VIEW, CREATE USER | SELECT, INSERT, UPDATE, DELETE, ALTER, REFERENCES, INDEX, EXECUTE |
| 주로 주는 사람 | DBA(관리자) | 객체의 소유자 |
| 다시 주기 옵션 | WITH ADMIN OPTION | WITH GRANT OPTION |

CREATE SESSION은 데이터베이스에 접속하는 권한이라서, 계정을 만들어도 이 권한이 없으면 로그인할 수 없어요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| GRANT 문장에 ON 객체가 붙어 있으면 시스템 권한이에요 | X | ON 객체가 붙으면 객체 권한이고, 없으면 시스템 권한이에요 |

## GRANT와 REVOKE — 줄 때는 TO, 뺏을 때는 FROM {#grant-revoke}

```sql
-- 문법
GRANT 시스템권한 [, 시스템권한] TO 사용자 [WITH ADMIN OPTION];
GRANT 객체권한 [, 객체권한] ON 객체 TO 사용자 [WITH GRANT OPTION];
REVOKE 시스템권한 FROM 사용자;
REVOKE 객체권한 ON 객체 FROM 사용자;
```

대괄호 안은 필요할 때만 쓰는 부분이에요. 아래는 HR이 자기 사원 표의 권한을 나눠 주는 예시예요.

```sql
-- 문법: HR 계정에서 차례로 실행해요
GRANT SELECT, INSERT ON 사원 TO KIM;   -- KIM은 조회와 입력을 할 수 있어요
REVOKE INSERT ON 사원 FROM KIM;        -- 입력 권한만 회수하고, 조회 권한은 남아요
GRANT ALL ON 사원 TO LEE;              -- 사원 표의 모든 객체 권한을 줘요
GRANT SELECT ON 사원 TO PUBLIC;        -- 모든 사용자에게 조회 권한을 줘요
```

| 용어 | 뜻 |
|---|---|
| 쉼표 | 권한 여러 개를 한 번에 주거나 회수할 때 이어 써요 |
| ALL | 그 객체에 줄 수 있는 모든 객체 권한이에요 |
| PUBLIC | 특정 사용자가 아니라 데이터베이스의 모든 사용자예요 |

## GRANT OPTION과 ADMIN OPTION — 회수가 이어지느냐 {#grant-option}

두 옵션 모두 받은 사람이 그 권한을 남에게 다시 줄 수 있게 해요. 차이는 처음 준 사람이 회수할 때 나타나요.

```sql
-- 문법: 계정을 바꿔 가며 차례로 실행해요 (객체 권한, 연쇄 회수)
-- 1. HR: KIM에게 다시 줄 수 있는 조회 권한을 줘요
GRANT SELECT ON 사원 TO KIM WITH GRANT OPTION;
-- 2. KIM: 받은 권한을 LEE에게 줘요
GRANT SELECT ON HR.사원 TO LEE;
-- 3. HR: KIM의 권한을 회수하면 KIM과 LEE 모두 조회할 수 없어요
REVOKE SELECT ON 사원 FROM KIM;
```

```sql
-- 문법: 계정을 바꿔 가며 차례로 실행해요 (시스템 권한, 연쇄 없음)
-- 1. DBA: KIM에게 다시 줄 수 있는 테이블 생성 권한을 줘요
GRANT CREATE TABLE TO KIM WITH ADMIN OPTION;
-- 2. KIM: 받은 권한을 LEE에게 줘요
GRANT CREATE TABLE TO LEE;
-- 3. DBA: KIM의 권한을 회수해도 KIM만 잃고, LEE는 그대로 가져요
REVOKE CREATE TABLE FROM KIM;
```

| 비교 | WITH GRANT OPTION | WITH ADMIN OPTION |
|---|---|---|
| 붙이는 권한 | 객체 권한 | 시스템 권한과 역할 |
| 받은 사람이 다시 줄 수 있나 | 있어요 | 있어요 |
| 회수하면 | 받은 사람이 준 권한도 연쇄로 회수돼요 | 받은 사람의 권한만 회수돼요 |
| 역할(ROLE)에게 줄 수 있나 | 없어요 (ORA-01926, 역할에는 GRANT OPTION 불가) | 있어요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 역할에 객체 권한을 줄 때 WITH GRANT OPTION을 붙일 수 있어요 | X | 역할에는 WITH GRANT OPTION을 붙일 수 없어서 오류가 나요 |

## ROLE과 기본 역할 — 권한을 묶어서 주기 {#role}

신입 사원 30명에게 같은 권한 다섯 개를 주려면 GRANT를 150번 실행해야 하고, 권한 하나를 바꿀 때도 30명을 다시 고쳐야 해요. 역할(ROLE)은 여러 권한에 이름을 붙여 묶어 둔 것이라, 권한은 역할에 주고 사용자에게는 역할을 주면 돼요.

```sql
-- 문법: DBA와 HR이 차례로 실행해요
-- DBA: 역할을 만들어요 (CREATE ROLE 권한이 필요해요)
CREATE ROLE 조회역할;
GRANT CREATE SESSION TO 조회역할;
-- HR: 자기 표의 조회 권한을 역할에 줘요
GRANT SELECT ON 사원 TO 조회역할;
-- DBA: 사용자에게 역할을 주고, 다시 회수해요
GRANT 조회역할 TO KIM, LEE;
REVOKE 조회역할 FROM LEE;
```

역할에는 시스템 권한과 객체 권한을 함께 담을 수 있고, 다른 역할도 넣을 수 있어요. 역할에서 권한 하나를 회수하면 그 역할을 받은 모든 사용자에게서 한 번에 사라져요.

Oracle에 미리 만들어진 역할 가운데 시험에는 아래 세 개가 나와요. 새 사용자를 만들 때는 보통 CONNECT와 RESOURCE를 함께 줘요.

| 역할 | 들어 있는 권한 | 쓰임 |
|---|---|---|
| CONNECT | CREATE SESSION | 접속만 할 수 있게 해요 |
| RESOURCE | CREATE TABLE 같은 객체 생성 권한, CREATE VIEW는 없음 | 자기 테이블 같은 객체를 만들 수 있게 해요 |
| DBA | 거의 모든 시스템 권한 | 데이터베이스를 관리할 수 있게 해요 |

```sql
-- 문법: DBA 계정에서 실행해요
CREATE USER KIM IDENTIFIED BY 비밀번호;
GRANT CONNECT, RESOURCE TO KIM;
```

## 역할 안의 역할과 DROP ROLE — 화살표로 길을 그려요 {#nested-role}

역할은 다른 역할에도 줄 수 있고, 바깥 역할을 받은 사용자는 안쪽 역할의 권한까지 모두 가져요. 아래에서 조회역할은 조회 권한을, 팀역할은 입력 권한과 조회역할을 가지고 있어요.

```sql
-- 문법: 계정을 바꿔 가며 차례로 실행해요
-- HR: 조회역할에는 조회 권한을, 팀역할에는 입력 권한을 줘요
GRANT SELECT ON 사원 TO 조회역할;
GRANT INSERT ON 사원 TO 팀역할;
-- DBA: 조회역할을 팀역할 안에 넣고, 팀역할은 KIM에게, 조회역할은 LEE에게 줘요
GRANT 조회역할 TO 팀역할;
GRANT 팀역할 TO KIM;
GRANT 조회역할 TO LEE;
-- HR: LEE에게는 조회 권한을 직접 한 번 더 줘요
GRANT SELECT ON 사원 TO LEE;
```

권한이 흘러가는 길을 화살표로 그리면 네 개가 생겨요.

| 길 | 흐름 |
|---|---|
| 1 | 조회 권한 → 조회역할 → 팀역할 → KIM |
| 2 | 입력 권한 → 팀역할 → KIM |
| 3 | 조회 권한 → 조회역할 → LEE |
| 4 | 조회 권한 → LEE (직접 받음) |

화살표 하나가 끊기면 그 아래쪽은 그 길로 받은 권한을 잃어요. 그래도 같은 권한이 다른 길로 하나라도 남아 있으면 그대로 쓰고, 아래 표는 처음 상태에서 문장 하나씩만 실행한 결과예요.

| 실행한 문장 | 끊기는 길 | KIM 조회 | KIM 입력 | LEE 조회 |
|---|---|---|---|---|
| (처음 상태) | 없어요 | 돼요 | 돼요 | 돼요 |
| `REVOKE SELECT ON 사원 FROM 조회역할` | 1, 3 | 안 돼요 | 돼요 | 돼요 (4번 길) |
| `REVOKE 조회역할 FROM 팀역할` | 1 | 안 돼요 | 돼요 | 돼요 |
| `DROP ROLE 조회역할` | 1, 3 | 안 돼요 | 돼요 | 돼요 (4번 길) |

| 헷갈리는 말 | 실제로는 |
|---|---|
| DROP ROLE을 하면 그 역할과 같은 권한은 모두 사라져요 | 역할을 거쳐 받은 권한만 사라져요. 팀역할이 직접 가진 입력 권한이나 LEE가 직접 받은 조회 권한은 남아요 |
| DROP ROLE은 접속해 있던 세션에도 바로 반영돼요 | 이미 접속해 있던 세션에는 바로 반영되지 않고, 다시 접속할 때부터 반영돼요 |
| 역할끼리 서로를 품게 만들 수 있어요 | 조회역할이 팀역할 안에 있는데 `GRANT 팀역할 TO 조회역할`을 하면 순환이 생겨 오류(ORA-01934, 역할 순환 부여)가 나요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 같은 권한을 다른 길로도 받았다면 한 길이 끊겨도 그 권한을 계속 써요 | O | 권한은 남은 길이 하나라도 있으면 유지돼요 |

## 자주 헷갈리는 점 — TO와 FROM, 연쇄 회수, 없는 테이블 {#confusing}

| 헷갈리는 말 | 실제로는 |
|---|---|
| `REVOKE INSERT ON 사원 TO KIM`도 맞는 문법이에요 | GRANT는 TO, REVOKE는 FROM이에요. 객체 권한은 둘 다 `ON 객체`가 권한 바로 뒤에 와요 |
| ADMIN OPTION도 GRANT OPTION처럼 연쇄로 회수돼요 | Oracle은 객체 권한을 줄 때 누가 누구에게 줬는지 기록해서 따라가며 회수해요. 시스템 권한은 이 기록이 없어서 그 사람만 회수돼요 |
| 역할 자체를 사용자에게 줄 때도 옵션을 붙일 수 없어요 | `GRANT 조회역할 TO KIM WITH ADMIN OPTION`처럼 ADMIN OPTION은 붙일 수 있어요. 안 되는 것은 역할에 GRANT OPTION을 주는 쪽이에요 |
| 권한이 없으면 권한 부족 오류가 나요 | KIM이 권한 없이 `SELECT * FROM HR.사원`을 실행하면 테이블이 없다는 오류(ORA-00942, 테이블이나 뷰가 없음)가 나요 |
| 권한을 받으면 `SELECT * FROM 사원`으로 바로 조회돼요 | 소유자 이름이 없으면 KIM 자신의 사원 표를 찾아서 같은 ORA-00942 오류가 나요 |
| 소유자도 자기 테이블에 GRANT를 받아야 해요 | 소유자는 권한 없이도 모든 작업을 하고, 객체 권한을 처음 나눠 주는 사람도 소유자예요. 소유자가 아니면 WITH GRANT OPTION으로 받았을 때만 남에게 줄 수 있어요 |
| CONNECT 역할만 받아도 테이블을 만들 수 있어요 | 예전 버전과 달리 지금의 CONNECT에는 접속 권한뿐이에요. RESOURCE로 테이블은 만들지만, 뷰는 CREATE VIEW를 따로 받아야 해요 |

Oracle에서 GRANT와 REVOKE는 DDL처럼 실행 앞뒤로 자동 커밋되어, 그 앞에서 COMMIT하지 않은 DML까지 함께 확정돼요. 아래는 사원 표의 소유자가 직접 실행한 예시이고, `COUNT(*)`는 조건에 맞는 사원 수를 세는 함수예요.

```sql
DELETE FROM 사원 WHERE 사번 = 1008;
GRANT SELECT ON 사원 TO PUBLIC;
ROLLBACK;
SELECT COUNT(*) FROM 사원 WHERE 사번 = 1008;   -- GRANT 때 DELETE가 함께 커밋되어 0이 나와요
```

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| GRANT 앞에서 COMMIT하지 않은 DELETE는 GRANT와 함께 확정돼요 | O | DCL은 실행 앞뒤로 자동 커밋돼서, 뒤의 ROLLBACK으로 되돌릴 수 없어요 |

## 꼭 외울 것 — 두 옵션의 회수 차이와 기본 역할 {#memorize}

| 외울 것 | 답 |
|---|---|
| 시스템 권한과 객체 권한 | ON 객체가 붙으면 객체 권한, 없으면 시스템 권한 |
| 주기와 회수의 전치사 | GRANT ... TO, REVOKE ... FROM |
| 객체 권한 다시 주기 옵션 | WITH GRANT OPTION, 회수하면 준 권한까지 연쇄 회수 |
| 시스템 권한·역할의 옵션 | WITH ADMIN OPTION, 회수해도 이미 준 권한은 남음 |
| 역할에 줄 수 없는 옵션 | WITH GRANT OPTION (오류) |
| 기본 역할 세 개 | CONNECT(접속), RESOURCE(객체 생성), DBA(관리) |
| RESOURCE에 없는 권한 | CREATE VIEW (따로 받아야 해요) |
| GRANT·REVOKE와 커밋 | 앞뒤로 자동 커밋, 앞의 DML도 확정 |

## 시험에서는 이렇게 나와요 {#exam-point}

권한을 주고받는 순서를 보여 주고 마지막 REVOKE 뒤에 누가 권한을 가지는지 묻는 문제가 가장 많아요. 객체 권한(GRANT OPTION)인지 시스템 권한(ADMIN OPTION)인지부터 확인하면 연쇄 회수 여부가 정해져요.

시스템 권한과 객체 권한의 구분, TO와 FROM, 기본 역할 CONNECT·RESOURCE·DBA의 설명도 자주 나와요. 역할 안에 역할을 넣고 REVOKE나 DROP ROLE을 한 뒤의 권한을 묻는 문제는 위처럼 화살표로 길을 그려 추적하면 풀려요.""",
    "checkQuestions": [
        question(1, "다음 중 객체 권한에 해당하는 것은 무엇인가요?", "privilege-types",
                 "객체 권한은 특정 테이블 같은 객체 하나에 대한 권한이라 `ON 객체`가 붙어요. CREATE로 시작하는 나머지는 시스템 권한이에요.",
                 [choice("A", "CREATE TABLE", rationale="테이블을 만드는 작업에 대한 시스템 권한이에요."),
                  choice("B", "CREATE SESSION", rationale="데이터베이스에 접속하는 시스템 권한이에요."),
                  choice("C", "사원 테이블에 대한 SELECT", True, "특정 객체(사원 테이블)에 대한 권한이라 객체 권한이에요."),
                  choice("D", "CREATE USER", rationale="사용자를 만드는 시스템 권한이에요.")]),
        question(2, "HR이 KIM에게 준 사원 테이블의 INSERT 권한을 회수하는 문장으로 올바른 것은 무엇인가요?", "grant-revoke",
                 "회수는 REVOKE 권한 ON 객체 FROM 사용자 순서로 써요. 받는 사람 앞의 TO는 GRANT에서만 써요.",
                 [choice("A", "REVOKE INSERT ON 사원 FROM KIM;", True, "REVOKE, ON 객체, FROM 사용자 순서가 맞아요."),
                  choice("B", "REVOKE INSERT ON 사원 TO KIM;", rationale="REVOKE에서는 TO가 아니라 FROM을 써요."),
                  choice("C", "GRANT INSERT ON 사원 FROM KIM;", rationale="GRANT는 권한을 주는 명령어라 회수할 수 없어요."),
                  choice("D", "REVOKE INSERT FROM KIM ON 사원;", rationale="ON 객체는 권한 바로 뒤, FROM 사용자 앞에 와야 해요.")]),
        question(3, "다음 순서로 권한을 주고받았어요. 3번을 실행한 뒤의 상태로 옳은 것은 무엇인가요?\n\n"
                    "1. HR: `GRANT SELECT ON 사원 TO KIM WITH GRANT OPTION;`\n"
                    "2. KIM: `GRANT SELECT ON HR.사원 TO LEE;`\n"
                    "3. HR: `REVOKE SELECT ON 사원 FROM KIM;`", "grant-option",
                 "WITH GRANT OPTION으로 받은 객체 권한을 회수하면, KIM이 LEE에게 준 권한도 연쇄로 회수돼요. 그래서 둘 다 조회할 수 없어요.",
                 [choice("A", "LEE는 조회 권한을 그대로 가진다", rationale="객체 권한은 연쇄 회수되어 LEE의 권한도 사라져요."),
                  choice("B", "LEE는 조회는 할 수 있지만 남에게 줄 수는 없다", rationale="LEE의 조회 권한 자체가 회수돼요."),
                  choice("C", "KIM은 조회 권한을 그대로 가진다", rationale="HR이 KIM의 권한을 직접 회수했어요."),
                  choice("D", "KIM과 LEE 모두 조회 권한을 잃는다", True, "KIM의 권한이 회수되면서 LEE의 권한도 연쇄로 회수돼요.")]),
        question(4, "다음 순서로 권한을 주고받았어요. 3번을 실행한 뒤의 상태로 옳은 것은 무엇인가요?\n\n"
                    "1. DBA: `GRANT CREATE TABLE TO KIM WITH ADMIN OPTION;`\n"
                    "2. KIM: `GRANT CREATE TABLE TO LEE;`\n"
                    "3. DBA: `REVOKE CREATE TABLE FROM KIM;`", "grant-option",
                 "WITH ADMIN OPTION으로 받은 시스템 권한은 연쇄 회수되지 않아요. KIM의 권한만 사라지고 LEE는 그대로 가져요.",
                 [choice("A", "KIM과 LEE 모두 CREATE TABLE 권한을 잃는다", rationale="연쇄 회수는 객체 권한의 WITH GRANT OPTION에서만 일어나요."),
                  choice("B", "LEE는 CREATE TABLE 권한을 그대로 가진다", True, "시스템 권한은 회수가 다음 사람에게 이어지지 않아요."),
                  choice("C", "KIM이 LEE에게 준 권한이 남아 있어서 회수가 거부된다", rationale="DBA는 KIM의 권한을 문제없이 회수할 수 있어요."),
                  choice("D", "KIM은 CREATE TABLE 권한을 그대로 가진다", rationale="DBA가 KIM의 권한을 직접 회수했어요.")]),
        question(5, "다음 순서로 권한을 주고받았어요. 5번을 실행한 뒤 KIM과 LEE가 새로 접속해서 사원 표를 조회할 수 있는지로 옳은 것은 무엇인가요?\n\n"
                    "1. HR: `GRANT SELECT ON 사원 TO 조회역할;`\n"
                    "2. DBA: `GRANT 조회역할 TO 팀역할;`\n"
                    "3. DBA: `GRANT 팀역할 TO KIM;`\n"
                    "4. HR: `GRANT SELECT ON 사원 TO LEE;`\n"
                    "5. DBA: `DROP ROLE 조회역할;`", "nested-role",
                 "KIM의 조회 권한은 조회역할 → 팀역할 → KIM 길로만 왔기 때문에 조회역할이 없어지면 사라져요. LEE는 조회 권한을 직접 받았으므로 DROP ROLE과 관계없이 남아요.",
                 [choice("A", "KIM과 LEE 모두 조회할 수 있다", rationale="팀역할은 남지만 그 안의 조회역할이 없어져서 KIM의 조회 권한이 사라져요."),
                  choice("B", "KIM과 LEE 모두 조회할 수 없다", rationale="LEE는 조회 권한을 직접 받아서 DROP ROLE의 영향을 받지 않아요."),
                  choice("C", "KIM은 조회할 수 없고, LEE는 조회할 수 있다", True, "역할을 거친 KIM의 권한만 사라지고, 직접 받은 LEE의 권한은 남아요."),
                  choice("D", "KIM은 조회할 수 있고, LEE는 조회할 수 없다", rationale="방향이 거꾸로예요. 역할을 거친 쪽이 KIM이고, 직접 받은 쪽이 LEE예요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # DCL 자동 커밋: 소유자가 PUBLIC 에 GRANT > 앞의 DELETE 도 확정
        sql_check(DCL_AUTO_COMMIT_SQL, [[0]]),
    ],
}
