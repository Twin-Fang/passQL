"""개념: CREATE·ALTER·DROP·TRUNCATE (3단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import to_employee_table_md

# ALTER 예시·확인 문제 5 계산용 (이름 길이, 직급 값, 커미션 NULL 4명)
EMPLOYEE_ALTER_TABLE = to_employee_table_md("사번", "이름", "직급", "커미션", "부서번호")

CONCEPT = {
    "tagKey": "ddl-create-alter-drop",
    "topicCode": "sql_ddl_dml_tcl",
    "sortOrder": 2,
    "title": "CREATE·ALTER·DROP·TRUNCATE",
    "summary": "테이블을 만들고 고치고 없애는 DDL이고, 실행하면 바로 확정돼요",
    "coreMd": (
        "- DDL은 테이블 같은 구조를 다루는 명령어로 CREATE, ALTER, DROP, RENAME, TRUNCATE가 있고, Oracle에서는 실행할 때 그 앞과 뒤에서 자동으로 커밋돼요.\n"
        "- 테이블 이름은 문자로 시작하고, 문자·숫자·`_`·`$`·`#`만 쓰며, 예약어나 이미 있는 이름은 쓸 수 없어요.\n"
        "- `CREATE TABLE ... AS SELECT`(CTAS)는 열과 데이터를 복사하지만 제약조건은 NOT NULL만 따라와요.\n"
        "- Oracle은 `ADD`, `MODIFY`, `DROP COLUMN`, `RENAME COLUMN`으로 열을 고치고, SQL Server는 MODIFY 대신 `ALTER COLUMN`을 써요.\n"
        "- DELETE는 행만 지우고 되돌릴 수 있지만, TRUNCATE는 구조만 남기고 되돌릴 수 없으며, DROP은 테이블 자체를 없애요."
    ),
    "detailMd": """## SQL 문장의 네 가지 종류 {#why}

데이터를 저장하려면 그 데이터를 담을 테이블(표)부터 있어야 해요. 테이블을 만들고, 열을 더하거나 고치고, 필요 없어지면 없애는 명령어를 DDL(Data Definition Language, 데이터 정의어)이라고 불러요. SQL 문장은 하는 일에 따라 네 가지로 나뉘고, 어떤 명령어가 어느 종류인지는 시험에서 자주 물어요.

| 종류 | 하는 일 | 명령어 |
|---|---|---|
| DDL (데이터 정의어) | 테이블 같은 구조를 만들고 바꾸고 없애요 | CREATE, ALTER, DROP, RENAME, TRUNCATE |
| DML (데이터 조작어) | 테이블 안의 데이터를 조회·입력·수정·삭제해요 | SELECT, INSERT, UPDATE, DELETE, MERGE |
| DCL (데이터 제어어) | 다른 사용자에게 권한을 주고 회수해요 | GRANT, REVOKE |
| TCL (트랜잭션 제어어) | 변경 내용을 확정하거나 취소해요 | COMMIT, ROLLBACK, SAVEPOINT |

TRUNCATE는 데이터를 지우는데도 DML이 아니라 DDL이라는 점이 자주 나와요. 이유는 아래 TRUNCATE 문단에서 설명해요.

## CREATE TABLE과 이름 규칙 {#create}

`CREATE TABLE` 뒤에 테이블 이름을 쓰고, 괄호 안에 열 이름과 데이터 타입을 쉼표로 이어 적어요.

```sql
-- 문법
CREATE TABLE 테이블이름 (
  열이름1 데이터타입 [제약조건],
  열이름2 데이터타입 [제약조건]
);
```

대괄호 안은 써도 되고 안 써도 되는 부분이에요. 아래는 부서별 프로젝트를 담을 테이블을 새로 만든 예시이고, 만든 직후에는 행이 하나도 없어요.

```sql
CREATE TABLE 프로젝트 (
  프로젝트번호 NUMBER(3),
  프로젝트명   VARCHAR2(30) NOT NULL,
  시작일       DATE,
  부서번호     NUMBER(2)
);
SELECT COUNT(*) FROM 프로젝트;   -- 만든 직후라 0이 나와요
```

`COUNT(*)`는 표에 행이 몇 개 있는지 세어 주는 함수이고, 그룹 함수 단원에서 다시 나와요. 테이블 이름과 열 이름은 아래 규칙을 지켜야 해요.

1. 문자로 시작해야 해요. `1분기매출`처럼 숫자로 시작하면 안 돼요.
2. 문자, 숫자, 밑줄(`_`), `$`, `#`만 쓸 수 있어요. 하이픈(`-`)이나 공백은 쓸 수 없어요.
3. `SELECT`, `TABLE`처럼 SQL이 이미 쓰는 단어(예약어)는 쓸 수 없어요.
4. 한 사용자 안에서 다른 테이블과 이름이 겹치면 안 되고, 한 테이블 안에서 열 이름이 겹쳐도 안 돼요.
5. 길이에도 한도가 있어요. Oracle 12.2부터는 128바이트이고, 그 전 버전은 30바이트였어요.

```sql
CREATE TABLE 1분기매출 (금액 NUMBER);       -- 오류: 숫자로 시작할 수 없어요 (ORA-00903)
CREATE TABLE 사원-연락처 (번호 NUMBER);     -- 오류: 하이픈은 쓸 수 없어요 (ORA-00922)
CREATE TABLE SELECT (번호 NUMBER);          -- 오류: 예약어는 쓸 수 없어요 (ORA-00903)
CREATE TABLE 사원 (번호 NUMBER);            -- 오류: 이미 있는 이름이에요 (ORA-00955)
CREATE TABLE 사원_2026 (번호 NUMBER);       -- 규칙을 지킨 이름이라 만들어져요
```

이름을 큰따옴표로 감싸면(`"1분기매출"`) 규칙을 벗어난 이름도 만들 수 있지만, 그 뒤로는 쓸 때마다 큰따옴표를 붙여야 해서 실무와 시험 모두 규칙을 지킨 이름을 기준으로 해요.

## CTAS: 다른 테이블을 복사해서 만들기 {#ctas}

`CREATE TABLE 새테이블 AS SELECT ...`처럼 SELECT 결과로 테이블을 만드는 방법을 CTAS(Create Table As Select)라고 불러요. 열 이름, 데이터 타입, 데이터가 한 번에 복사되지만 제약조건은 NOT NULL만 따라오고 기본 키(PRIMARY KEY)나 외래 키 같은 나머지 제약조건은 따라오지 않아요. 제약조건은 다음 개념에서 자세히 다루는데, 여기서는 "들어갈 수 있는 값을 막는 규칙" 정도로 이해하면 충분해요.

```sql
CREATE TABLE 사원복사 AS SELECT * FROM 사원;
INSERT INTO 사원복사 (사번, 이름) VALUES (1001, '김민수');   -- 기본 키가 없어서 같은 사번이 또 들어가요
SELECT COUNT(*) FROM 사원복사 WHERE 사번 = 1001;             -- 사번 1001이 2행 나와요
INSERT INTO 사원복사 (사번, 이름) VALUES (1009, NULL);       -- 오류: NOT NULL은 복사되어서 이름을 비울 수 없어요 (ORA-01400)
```

원본의 사원 표에서는 사번이 기본 키라서 같은 사번이 두 번 들어갈 수 없지만, 복사한 표에서는 들어가요. 반대로 이름 열의 NOT NULL은 복사되어서 이름을 비워 두면 오류가 나요.

구조만 복사하고 데이터는 비워 두고 싶으면 항상 거짓인 조건을 붙여요.

```sql
CREATE TABLE 사원빈표 AS SELECT * FROM 사원 WHERE 1 = 2;
SELECT COUNT(*) FROM 사원빈표;   -- 구조만 복사되어 0이 나와요
```

## ALTER TABLE: 열 추가·변경·삭제·이름 바꾸기 {#alter}

이미 만든 테이블의 구조는 `ALTER TABLE`로 고쳐요. Oracle에서 쓰는 형태는 네 가지예요.

| 하는 일 | Oracle 문법 |
|---|---|
| 열 추가 | `ALTER TABLE 사원 ADD (이메일 VARCHAR2(50));` |
| 열의 타입·크기·기본값 변경 | `ALTER TABLE 사원 MODIFY (이름 VARCHAR2(30));` |
| 열 삭제 | `ALTER TABLE 사원 DROP COLUMN 이메일;` |
| 열 이름 변경 | `ALTER TABLE 사원 RENAME COLUMN 커미션 TO 수당;` |

아래 예시는 공통 예시 데이터의 사원 표(8명)를 고쳐요. 결과를 따라가는 데 필요한 열만 보이면 다음과 같아요.

""" + EMPLOYEE_ALTER_TABLE + """

```sql
ALTER TABLE 사원 ADD (이메일 VARCHAR2(50));
ALTER TABLE 사원 MODIFY (이름 VARCHAR2(30));
ALTER TABLE 사원 RENAME COLUMN 커미션 TO 수당;
ALTER TABLE 사원 DROP COLUMN 이메일;
SELECT 수당 FROM 사원 WHERE 사번 = 1002;   -- 이름만 바뀌어서 300이 그대로 나와요
```

새로 더한 열은 테이블의 맨 뒤에 붙고, 이미 있던 행의 그 칸은 NULL로 채워져요. ADD와 MODIFY는 괄호 안에 여러 열을 쉼표로 이어서 한 번에 고칠 수도 있어요.

MODIFY는 이미 들어 있는 데이터와 부딪히지 않을 때만 성공해요. 크기를 늘리는 것은 언제나 되지만, 크기를 줄이거나 타입을 바꾸거나 NOT NULL을 붙이는 것은 아래처럼 조건이 있어요.

| 바꾸려는 것 | 성공하는 조건 | 어기면 |
|---|---|---|
| 크기 줄이기 | 들어 있는 값이 모두 새 크기에 맞을 때 | ORA-01441 (값이 커서 줄일 수 없어요) |
| 타입 바꾸기 | 그 열의 값이 모두 NULL일 때 | ORA-01439 (값이 있으면 타입을 바꿀 수 없어요) |
| NOT NULL 붙이기 | 그 열에 NULL이 하나도 없을 때 | ORA-02296 (NULL이 있어서 NOT NULL을 붙일 수 없어요) |
| 기본값(DEFAULT) 바꾸기 | 언제나 되고, 이후에 넣는 행부터 적용돼요 | 오류가 나지 않아요 |

```sql
ALTER TABLE 사원 MODIFY (이름 VARCHAR2(3));      -- 오류: 9바이트인 한글 이름이 들어 있어요 (ORA-01441)
ALTER TABLE 사원 MODIFY (직급 NUMBER);           -- 오류: 직급에 값이 들어 있어요 (ORA-01439)
ALTER TABLE 사원 MODIFY (커미션 NOT NULL);       -- 오류: 커미션이 NULL인 사원이 4명 있어요 (ORA-02296)
ALTER TABLE 사원 ADD (메모 VARCHAR2(10) NOT NULL);   -- 오류: 이미 행이 있어서 새 칸이 NULL이 돼요 (ORA-01758)
```

마지막 줄처럼 행이 이미 있는 테이블에 NOT NULL 열을 더하면, 기존 행의 새 칸이 NULL이 되어 규칙을 어기므로 오류가 나요. `ADD (상태 VARCHAR2(10) DEFAULT '재직' NOT NULL)`처럼 기본값을 함께 주면 기존 행이 '재직'으로 채워져서 성공해요.

## RENAME과 DROP TABLE {#rename-drop}

테이블 이름은 `RENAME 옛이름 TO 새이름`으로 바꾸고, `ALTER TABLE 옛이름 RENAME TO 새이름`으로 써도 결과는 같아요.

```sql
RENAME 급여등급 TO 급여구간;
SELECT COUNT(*) FROM 급여구간;   -- 이름만 바뀌어서 4가 나와요
```

`DROP TABLE`은 테이블의 구조와 데이터를 모두 없애요. 그런데 부서 표처럼 다른 테이블(사원)이 외래 키로 참조하고 있는 부모 테이블은 그냥 지울 수 없어요. 외래 키는 "사원의 부서번호는 부서 표에 있는 번호여야 한다" 같은 연결 규칙이에요. 이때 `CASCADE CONSTRAINTS`를 붙이면 그 연결 규칙까지 함께 지우고 테이블을 없애요.

```sql
DROP TABLE 부서;                       -- 오류: 사원 표가 부서를 참조하고 있어요 (ORA-02449)
DROP TABLE 부서 CASCADE CONSTRAINTS;   -- 부서를 지우면서 사원 쪽 외래 키 규칙도 지워요
SELECT COUNT(*) FROM 사원;             -- 사원 데이터는 그대로라서 8이 나와요
```

## TRUNCATE와 DELETE, DROP 비교 {#truncate}

`TRUNCATE TABLE`은 테이블의 모든 행을 지우고 구조만 남겨요. 결과만 보면 WHERE 없이 실행한 `DELETE FROM 사원`과 같지만, DELETE는 행을 하나씩 지우며 되돌릴 기록을 남기는 DML이고, TRUNCATE는 테이블을 처음 만든 상태로 되돌리는 DDL이에요. Oracle은 DDL을 실행할 때 그 앞과 뒤에서 자동으로 확정(커밋)해요. 그래서 TRUNCATE로 지운 행은 확정 전 상태로 되돌리는 명령인 ROLLBACK을 써도 돌아오지 않아요.

```sql
DELETE FROM 사원;
ROLLBACK;
SELECT COUNT(*) FROM 사원;   -- DELETE는 되돌릴 수 있어서 8이 나와요
```

```sql
TRUNCATE TABLE 사원;
ROLLBACK;
SELECT COUNT(*) FROM 사원;   -- TRUNCATE는 되돌릴 수 없어서 0이 나와요
```

세 명령어를 한 표로 비교하면 아래와 같아요.

| 비교 | DELETE | TRUNCATE | DROP |
|---|---|---|---|
| 종류 | DML | DDL | DDL |
| 지우는 것 | 조건에 맞는 행이에요 (WHERE가 없으면 전체) | 모든 행이에요 | 테이블 자체예요 |
| 테이블 구조 | 남아요 | 남아요 | 사라져요 |
| ROLLBACK | 돼요 | 안 돼요 (자동 커밋) | 안 돼요 (자동 커밋) |
| 저장 공간 | 그대로 잡고 있어요 | 처음 만들 때 크기만 남기고 돌려줘요 | 모두 돌려줘요 |
| 속도 | 행마다 기록을 남겨서 느려요 | 빨라요 | 빨라요 |

저장 공간은 테이블이 데이터를 담으려고 디스크에서 차지하는 자리예요. DELETE는 행을 지워도 차지한 자리를 그대로 두지만, TRUNCATE는 테이블을 처음 만들었을 때 잡은 만큼만 남기고 나머지 자리를 데이터베이스에 돌려줘요. DROP은 테이블이 없어지므로 자리를 모두 돌려줘요.

TRUNCATE에는 WHERE를 붙일 수 없어서 일부 행만 지우려면 DELETE를 써야 해요. 또 자식 테이블이 외래 키로 참조하는 부모 테이블은 TRUNCATE할 수 없어서, `TRUNCATE TABLE 부서`는 오류(ORA-02266, 외래 키가 참조하는 표)가 나요.

## SQL Server는 문법이 조금 달라요 {#sql-server}

SQL Server는 열을 고칠 때 MODIFY 대신 `ALTER COLUMN`을 쓰고, 이름을 바꿀 때는 `sp_rename`이라는 저장 프로시저(미리 만들어 둔 명령 묶음)를 실행해요.

```sql
-- 문법: SQL Server에서 쓰는 모양이에요
ALTER TABLE 사원 ADD 이메일 VARCHAR(50);
ALTER TABLE 사원 ALTER COLUMN 이름 VARCHAR(30) NOT NULL;
ALTER TABLE 사원 DROP COLUMN 이메일;
EXEC sp_rename '사원.커미션', '수당', 'COLUMN';
SELECT * INTO 사원복사 FROM 사원;
```

`ALTER COLUMN`은 한 문장에 열 하나만 고칠 수 있어서, 괄호 안에 여러 열을 넣는 Oracle의 MODIFY와 달라요. CTAS도 SQL Server에서는 `SELECT * INTO 새테이블 FROM 원본`처럼 써요.

## 자주 헷갈리는 점 {#confusing}

**Oracle ALTER는 동작마다 COLUMN을 붙이는지가 달라요.** ADD와 MODIFY에는 COLUMN을 붙이지 않고, DROP COLUMN과 RENAME COLUMN에는 붙여요. 그래서 `ADD COLUMN 이메일 ...`(ORA-00904, 잘못된 이름)이나 `MODIFY COLUMN 이름 ...`(ORA-00905, 키워드 누락)은 Oracle에서 오류가 나요. 이런 모양은 다른 데이터베이스의 문법이라서 보기에 섞여 나오면 틀린 보기예요. 여러 열을 한 번에 지울 때는 `DROP (전화, 상태)`처럼 COLUMN 없이 괄호로 묶어요.

**MODIFY와 ALTER COLUMN은 데이터베이스가 달라요.** 열을 고치는 키워드가 Oracle은 MODIFY, SQL Server는 ALTER COLUMN이에요. Oracle에서 `ALTER TABLE 사원 ALTER COLUMN ...`을 쓰면 오류(ORA-01735, 잘못된 ALTER TABLE 옵션)가 나요.

**CTAS는 NOT NULL만 복사해요.** 기본 키, 고유 키(UNIQUE), CHECK, 외래 키는 따라오지 않고, 열의 기본값(DEFAULT)도 따라오지 않아요. 그래서 복사한 테이블에서는 원본에서 막혔던 같은 사번 입력이나 없는 부서번호 입력이 성공해요. 필요한 제약조건은 복사한 뒤 ALTER TABLE로 다시 붙여야 해요.

**TRUNCATE는 데이터를 지우지만 DDL이에요.** 그래서 ROLLBACK이 되지 않고, Oracle은 DDL을 실행할 때 그 앞과 뒤에서 커밋하기 때문에, TRUNCATE 전에 해 두고 아직 확정하지 않은 INSERT나 DELETE까지 함께 커밋돼요. "TRUNCATE는 DML이다", "TRUNCATE 뒤에 ROLLBACK하면 되살아난다"는 보기는 모두 틀린 보기예요.

**DELETE 전체 삭제와 TRUNCATE는 결과가 같아도 성질이 달라요.** 둘 다 실행 후 행 수는 0이지만, DELETE는 되돌릴 수 있고 저장 공간을 그대로 잡고 있으며, TRUNCATE는 되돌릴 수 없고 저장 공간을 돌려줘요.

**DROP TABLE의 CASCADE CONSTRAINTS는 자식 데이터를 지우지 않아요.** 지워지는 것은 자식 테이블에 걸린 외래 키 규칙뿐이고, 사원 8명의 데이터는 그대로 남아요. 부모 행을 지울 때 자식 행까지 함께 지우는 `ON DELETE CASCADE`와 이름이 비슷해서 자주 섞여요.

**이름은 대소문자를 구분하지 않아요.** 큰따옴표 없이 만든 이름은 Oracle이 대문자로 바꿔 저장하기 때문에 `emp`, `EMP`, `Emp`는 모두 같은 테이블이에요.

## 시험에서는 이렇게 나와요 {#exam-point}

명령어를 주고 DDL·DML·DCL·TCL 중 어디에 속하는지 고르는 문제, 테이블 이름으로 쓸 수 없는 것을 고르는 문제가 자주 나와요. ALTER TABLE 문법은 Oracle과 SQL Server의 문법을 섞은 보기로 나오니 MODIFY와 ALTER COLUMN, COLUMN 키워드가 붙는 자리를 확인해요. DELETE, TRUNCATE, DROP 비교 문제는 구조가 남는지, ROLLBACK이 되는지, DDL인지를 위 표로 정리해 두면 풀려요.""",
    "checkQuestions": [
        question(1, "다음 중 DDL(데이터 정의어)이 아닌 것은 무엇인가요?", "why",
                 "UPDATE는 테이블 안의 데이터를 고치는 DML이에요. CREATE, TRUNCATE, RENAME은 구조를 다루는 DDL이에요.",
                 [choice("A", "CREATE", rationale="테이블 같은 구조를 만드는 DDL이에요."),
                  choice("B", "TRUNCATE", rationale="데이터를 지우지만 테이블을 처음 상태로 되돌리는 DDL이에요."),
                  choice("C", "RENAME", rationale="테이블 이름을 바꾸는 DDL이에요."),
                  choice("D", "UPDATE", True, "데이터를 수정하는 DML이라서 DDL이 아니에요.")]),
        question(2, "Oracle에서 테이블 이름으로 쓸 수 있는 것은 무엇인가요?", "create",
                 "테이블 이름은 문자로 시작하고 문자·숫자·_·$·#만 써야 하며, 예약어는 쓸 수 없어요. 사원_2026은 이 규칙을 모두 지켜요.",
                 [choice("A", "1분기매출", rationale="숫자로 시작해서 쓸 수 없어요."),
                  choice("B", "사원_2026", True, "문자로 시작하고 허용된 문자만 썼어요."),
                  choice("C", "사원-연락처", rationale="하이픈(-)은 이름에 쓸 수 없는 문자예요."),
                  choice("D", "SELECT", rationale="SQL이 이미 쓰는 예약어라서 쓸 수 없어요.")]),
        question(3, "`CREATE TABLE 사원복사 AS SELECT * FROM 사원;`을 실행했을 때 원본에서 함께 복사되는 제약조건은 무엇인가요?", "ctas",
                 "CTAS는 열, 데이터 타입, 데이터를 복사하지만 제약조건은 NOT NULL만 따라와요. 나머지는 복사한 뒤 다시 붙여야 해요.",
                 [choice("A", "NOT NULL", True, "CTAS로 복사되는 유일한 제약조건이에요."),
                  choice("B", "PRIMARY KEY", rationale="기본 키는 복사되지 않아서 같은 사번이 또 들어가요."),
                  choice("C", "FOREIGN KEY", rationale="외래 키는 복사되지 않아서 없는 부서번호도 들어가요."),
                  choice("D", "CHECK", rationale="CHECK 제약조건은 복사되지 않아요.")]),
        question(4, "공통 예시 데이터(사원 8명)에서 다음 SQL을 차례로 실행하면 마지막 결과는 무엇인가요?", "truncate",
                 "TRUNCATE는 DDL이라 실행하는 순간 자동으로 커밋돼요. 그래서 ROLLBACK을 해도 지워진 행이 돌아오지 않아 0이 나와요.",
                 [choice("A", "8", rationale="DELETE였다면 ROLLBACK으로 8명이 돌아오지만, TRUNCATE는 되돌릴 수 없어요."),
                  choice("B", "오류가 난다", rationale="TRUNCATE 뒤에 ROLLBACK을 해도 오류는 나지 않고, 되돌릴 것이 없을 뿐이에요."),
                  choice("C", "0", True, "TRUNCATE는 자동 커밋되어 ROLLBACK으로 되돌릴 수 없어요."),
                  choice("D", "테이블이 없다는 오류가 난다", rationale="TRUNCATE는 행만 지우고 테이블 구조는 남겨요.")],
                 stem_sql="TRUNCATE TABLE 사원;\nROLLBACK;\nSELECT COUNT(*) FROM 사원;"),
        question(5, "공통 예시 데이터의 사원 표에 실행했을 때 오류가 나는 문장은 무엇인가요?", "alter",
                 "커미션 열에는 NULL인 사원이 4명 있어서 NOT NULL을 붙일 수 없어요(ORA-02296, NULL이 있어 NOT NULL 불가). 나머지는 기존 데이터와 부딪히지 않아 성공해요.",
                 [choice("A", "ALTER TABLE 사원 ADD (이메일 VARCHAR2(50));", rationale="새 열이 맨 뒤에 붙고 기존 행은 NULL로 채워져요."),
                  choice("B", "ALTER TABLE 사원 MODIFY (커미션 NOT NULL);", True, "커미션에 NULL이 있어서 NOT NULL을 붙일 수 없어요."),
                  choice("C", "ALTER TABLE 사원 MODIFY (이름 VARCHAR2(30));", rationale="크기를 늘리는 것은 언제나 성공해요."),
                  choice("D", "ALTER TABLE 사원 RENAME COLUMN 커미션 TO 수당;", rationale="열 이름만 바뀌고 데이터는 그대로 남아요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # CREATE TABLE 직후 0행, 이름 규칙 (숫자 시작·하이픈·예약어·중복 이름·중복 열)
        sql_check("CREATE TABLE 프로젝트 (프로젝트번호 NUMBER(3), 프로젝트명 VARCHAR2(30) NOT NULL, 시작일 DATE, 부서번호 NUMBER(2));\n"
                  "SELECT COUNT(*) FROM 프로젝트;", [[0]]),
        sql_error_check("CREATE TABLE 1분기매출 (금액 NUMBER)", "ORA-00903"),
        sql_error_check("CREATE TABLE 사원-연락처 (번호 NUMBER)", "ORA-00922"),
        sql_error_check("CREATE TABLE SELECT (번호 NUMBER)", "ORA-00903"),
        sql_error_check("CREATE TABLE 사원 (번호 NUMBER)", "ORA-00955"),
        sql_check("CREATE TABLE 사원_2026 (번호 NUMBER);\nSELECT COUNT(*) FROM 사원_2026;", [[0]]),
        sql_error_check("CREATE TABLE 중복열 (번호 NUMBER, 번호 NUMBER)", "ORA-00957"),
        sql_check("CREATE TABLE \"1분기매출\" (금액 NUMBER);\nSELECT COUNT(*) FROM \"1분기매출\";", [[0]]),
        # CTAS: NOT NULL 만 복사 (기본 키·외래 키·CHECK·DEFAULT 는 빠짐)
        sql_check("SELECT COUNT(*) FROM 사원복사 WHERE 사번 = 1001", [[2]],
                  setup="CREATE TABLE 사원복사 AS SELECT * FROM 사원;\nINSERT INTO 사원복사 (사번, 이름) VALUES (1001, '김민수');"),
        sql_error_check("INSERT INTO 사원복사 (사번, 이름) VALUES (1009, NULL)", "ORA-01400",
                        setup="CREATE TABLE 사원복사 AS SELECT * FROM 사원;"),
        sql_check("SELECT COUNT(*) FROM 사원복사", [[9]],
                  setup="CREATE TABLE 사원복사 AS SELECT * FROM 사원;\nINSERT INTO 사원복사 (사번, 이름, 부서번호) VALUES (1010, '서지우', 99);"),
        sql_check("SELECT COUNT(*) FROM 부서복사", [[5]],
                  setup="ALTER TABLE 부서 ADD CONSTRAINT 부서_지역_CK CHECK (지역 IN ('서울', '판교', '부산'));\n"
                        "CREATE TABLE 부서복사 AS SELECT * FROM 부서;\nINSERT INTO 부서복사 VALUES (50, '총무부', '대전');"),
        sql_check("SELECT 직급 FROM 사원복사 WHERE 사번 = 1009", [[None]],
                  setup="ALTER TABLE 사원 MODIFY (직급 DEFAULT '사원');\nCREATE TABLE 사원복사 AS SELECT * FROM 사원;\n"
                        "INSERT INTO 사원복사 (사번, 이름) VALUES (1009, '강하준');"),
        sql_check("CREATE TABLE 사원빈표 AS SELECT * FROM 사원 WHERE 1 = 2;\nSELECT COUNT(*) FROM 사원빈표;", [[0]]),
        # ALTER TABLE 네 형태, 새 열은 NULL
        sql_check("SELECT 수당 FROM 사원 WHERE 사번 = 1002", [[300]],
                  setup="ALTER TABLE 사원 ADD (이메일 VARCHAR2(50));\nALTER TABLE 사원 MODIFY (이름 VARCHAR2(30));\n"
                        "ALTER TABLE 사원 RENAME COLUMN 커미션 TO 수당;\nALTER TABLE 사원 DROP COLUMN 이메일;"),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 이메일 IS NULL", [[8]], setup="ALTER TABLE 사원 ADD (이메일 VARCHAR2(50));"),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 전화 IS NULL AND 이메일 IS NULL", [[8]],
                  setup="ALTER TABLE 사원 ADD (이메일 VARCHAR2(50), 전화 VARCHAR2(20));"),
        sql_check("SELECT COUNT(*) FROM user_tab_columns WHERE table_name = '사원'", [[8]],
                  setup="ALTER TABLE 사원 ADD (이메일 VARCHAR2(50), 전화 VARCHAR2(20));\nALTER TABLE 사원 DROP (이메일, 전화);"),
        # MODIFY 조건 (크기 줄이기·타입 변경·NOT NULL·NOT NULL 열 추가)
        sql_error_check("ALTER TABLE 사원 MODIFY (이름 VARCHAR2(3))", "ORA-01441"),
        sql_error_check("ALTER TABLE 사원 MODIFY (직급 NUMBER)", "ORA-01439"),
        sql_error_check("ALTER TABLE 사원 MODIFY (커미션 NOT NULL);", "ORA-02296"),
        sql_error_check("ALTER TABLE 사원 ADD (메모 VARCHAR2(10) NOT NULL)", "ORA-01758"),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 상태 = '재직'", [[8]],
                  setup="ALTER TABLE 사원 ADD (상태 VARCHAR2(10) DEFAULT '재직' NOT NULL);"),
        sql_check("SELECT 직급 FROM 사원 WHERE 사번 = 1001", [[None]],
                  setup="UPDATE 사원 SET 직급 = NULL WHERE 사번 = 1001;\nALTER TABLE 사원 MODIFY (직급 DEFAULT '사원');"),
        sql_check("SELECT COUNT(*) FROM 사원", [[8]], setup="ALTER TABLE 사원 ADD (이메일 VARCHAR2(50));"),
        sql_check("SELECT COUNT(*) FROM 사원", [[8]], setup="ALTER TABLE 사원 MODIFY (이름 VARCHAR2(30));"),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 수당 IS NULL", [[4]],
                  setup="ALTER TABLE 사원 RENAME COLUMN 커미션 TO 수당;"),
        # Oracle 에 없는 ALTER 모양 (ADD COLUMN, MODIFY COLUMN, ALTER COLUMN)
        sql_error_check("ALTER TABLE 사원 ADD COLUMN 이메일 VARCHAR2(50)", "ORA-00904"),
        sql_error_check("ALTER TABLE 사원 MODIFY COLUMN 이름 VARCHAR2(30)", "ORA-00905"),
        sql_error_check("ALTER TABLE 사원 ALTER COLUMN 이름 VARCHAR2(30)", "ORA-01735"),
        # RENAME, DROP TABLE (참조 중인 부모, CASCADE CONSTRAINTS)
        sql_check("RENAME 급여등급 TO 급여구간;\nSELECT COUNT(*) FROM 급여구간;", [[4]]),
        sql_check("ALTER TABLE 급여등급 RENAME TO 급여구간;\nSELECT COUNT(*) FROM 급여구간;", [[4]]),
        sql_error_check("DROP TABLE 부서", "ORA-02449"),
        sql_check("DROP TABLE 부서 CASCADE CONSTRAINTS;\nSELECT COUNT(*) FROM 사원;", [[8]]),
        sql_check("SELECT COUNT(*) FROM user_constraints WHERE table_name = '사원' AND constraint_type = 'R'", [[0]],
                  setup="DROP TABLE 부서 CASCADE CONSTRAINTS;"),
        # DELETE 는 되돌림, TRUNCATE 는 자동 커밋 (앞선 DML 도 커밋), 부모 TRUNCATE 불가
        sql_check("DELETE FROM 사원;\nROLLBACK;\nSELECT COUNT(*) FROM 사원;", [[8]]),
        sql_check("TRUNCATE TABLE 사원;\nROLLBACK;\nSELECT COUNT(*) FROM 사원;", [[0]]),
        sql_check("INSERT INTO 부서 VALUES (50, '총무부', '대전');\nTRUNCATE TABLE 급여등급;\nROLLBACK;\nSELECT COUNT(*) FROM 부서;", [[5]]),
        sql_error_check("TRUNCATE TABLE 부서", "ORA-02266"),
        # 대소문자 구분 없음
        sql_check("CREATE TABLE emp (번호 NUMBER);\nSELECT COUNT(*) FROM EMP;", [[0]]),
    ],
}
