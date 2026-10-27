"""개념: 제약조건 (3단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import DEPARTMENT_TABLE_MD, to_employee_table_md

# 외래 키 예시(부서번호)·확인 문제 5(급여 NULL 수) 계산용
EMPLOYEE_SALARY_DEPARTMENT_TABLE = to_employee_table_md("사번", "이름", "급여", "부서번호")

# 부서를 참조하는 작은 자식 표 (40번 부서는 사원이 없어 부모 삭제 예시에 씀)
PROJECT_CASCADE_SETUP = (
    "CREATE TABLE 프로젝트 (프로젝트번호 NUMBER(3) PRIMARY KEY, 프로젝트명 VARCHAR2(30),"
    " 부서번호 NUMBER(2) REFERENCES 부서(부서번호) ON DELETE CASCADE);\n"
    "INSERT INTO 프로젝트 VALUES (1, '채용 시스템', 40);\n"
    "INSERT INTO 프로젝트 VALUES (2, '교육 계획', 40);"
)
UNIQUE_NULL_STEM_SQL = (
    "CREATE TABLE 사원연락처 (사번 NUMBER(4), 이메일 VARCHAR2(50) UNIQUE);\n"
    "INSERT INTO 사원연락처 VALUES (1001, NULL);\n"
    "INSERT INTO 사원연락처 VALUES (1002, NULL);\n"
    "INSERT INTO 사원연락처 VALUES (1003, 'seojun@passql.kr');\n"
    "SELECT COUNT(*) FROM 사원연락처;"
)
CASCADE_STEM_SQL = (
    PROJECT_CASCADE_SETUP + "\n"
    "INSERT INTO 프로젝트 VALUES (3, '사내 메신저', 20);\n"
    "DELETE FROM 부서 WHERE 부서번호 = 40;\n"
    "SELECT COUNT(*) FROM 프로젝트;"
)
CHECK_NULL_STEM_SQL = (
    "ALTER TABLE 사원 ADD CONSTRAINT 사원_급여_CK CHECK (급여 > 0);\n"
    "UPDATE 사원 SET 급여 = NULL WHERE 사번 = 1001;\n"
    "SELECT COUNT(*) FROM 사원 WHERE 급여 IS NULL;"
)

# 본문 예시: DEFAULT 는 생략·DEFAULT 키워드일 때만, NULL 을 직접 넣으면 NULL
DEFAULT_VALUE_EXAMPLE = sql_example(
    "ALTER TABLE 사원 MODIFY (직급 DEFAULT '사원');\n"
    "INSERT INTO 사원 (사번, 이름) VALUES (1009, '강하준');                 -- 직급을 생략했어요\n"
    "INSERT INTO 사원 (사번, 이름, 직급) VALUES (1010, '서지우', NULL);     -- NULL을 직접 넣었어요\n"
    "INSERT INTO 사원 (사번, 이름, 직급) VALUES (1011, '문예린', DEFAULT);  -- DEFAULT라고 썼어요\n"
    "SELECT 사번, 직급 FROM 사원 WHERE 사번 >= 1009 ORDER BY 사번;",
    ('사번', '직급'), [(1009, '사원'), (1010, None), (1011, '사원')])

CONCEPT = {
    "tagKey": "ddl-constraints",
    "topicCode": "sql_ddl_dml_tcl",
    "sortOrder": 3,
    "title": "제약조건",
    "summary": "테이블에 규칙을 걸어 잘못된 값의 입력·수정·삭제를 그 자리에서 막아요",
    "coreMd": (
        "- 기본 키(PRIMARY KEY)는 UNIQUE와 NOT NULL을 합친 것이고 테이블에 하나만 둘 수 있어요. UNIQUE는 중복만 막고 NULL은 여러 개 허용해요.\n"
        "- CHECK는 조건이 거짓인 값만 막기 때문에, 비교 결과가 UNKNOWN(참도 거짓도 아닌 결과)이 되는 NULL은 통과해요.\n"
        "- 외래 키(FOREIGN KEY)가 있으면 부모에 없는 값을 자식에 넣을 수 없고(ORA-02291, 부모 키가 없음), 자식이 있는 부모 행은 지울 수 없어요(ORA-02292, 자식 행이 있음).\n"
        "- `ON DELETE CASCADE`는 부모를 지울 때 자식 행도 지우고, `ON DELETE SET NULL`은 자식의 외래 키를 NULL로 바꿔요.\n"
        "- DEFAULT는 값을 생략했을 때 채우는 기본값일 뿐 아무것도 막지 않아서 제약조건이 아니에요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

사원 표에 같은 사번이 두 번 들어가거나, 있지도 않은 50번 부서에 사원이 배정되면 그 데이터는 더 이상 믿을 수 없어요. 프로그램에서 매번 검사할 수도 있지만, 한 곳이라도 검사를 빠뜨리면 잘못된 값이 들어와요. 그래서 데이터베이스는 테이블에 규칙을 걸어 두고, 규칙을 어기는 입력·수정·삭제를 그 자리에서 거부해요. 이 규칙을 제약조건(constraint)이라고 불러요.

데이터가 정확하고 서로 어긋나지 않는 상태를 무결성이라고 하는데, 제약조건은 데이터베이스가 직접 무결성을 지키게 하는 장치예요.

## 제약조건 다섯 가지 {{#definition}}

| 제약조건 | 뜻 | NULL | 테이블에 몇 개 |
|---|---|---|---|
| PRIMARY KEY (기본 키) | 행을 하나씩 구별하는 열이고, 중복을 막아요 | 안 돼요 | 하나만 둘 수 있어요 |
| UNIQUE (고유 키) | 같은 값이 두 번 들어가지 못하게 해요 | 돼요 (여러 개도 돼요) | 여러 개 둘 수 있어요 |
| NOT NULL | 비워 둘 수 없게 해요 | 안 돼요 | 여러 개 둘 수 있어요 |
| CHECK | 정한 조건을 만족하는 값만 받아요 | 돼요 | 여러 개 둘 수 있어요 |
| FOREIGN KEY (외래 키) | 다른 테이블의 기본 키(또는 고유 키)에 있는 값만 받아요 | 돼요 | 여러 개 둘 수 있어요 |

공통 예시 데이터에도 제약조건이 걸려 있어요. 부서번호와 사번은 각 표의 기본 키이고, 부서명과 이름은 NOT NULL이며, 사원의 부서번호는 부서의 부서번호를 가리키는 외래 키예요.

## 기본 키와 고유 키 {{#primary-unique}}

기본 키는 "중복 불가(UNIQUE)"와 "비워 둘 수 없음(NOT NULL)"을 합친 제약조건이에요. 부서 표의 기본 키는 부서번호라서, 이미 있는 10번을 다시 넣거나 부서번호를 비워 두면 모두 거부돼요.

```sql
INSERT INTO 부서 VALUES (10, '총무부', '대전');     -- 오류: 10번 부서가 이미 있어요 (ORA-00001)
INSERT INTO 부서 VALUES (NULL, '총무부', '대전');   -- 오류: 기본 키에는 NULL을 넣을 수 없어요 (ORA-01400)
ALTER TABLE 부서 ADD PRIMARY KEY (부서명);          -- 오류: 기본 키는 테이블에 하나만 둘 수 있어요 (ORA-02260)
```

기본 키가 하나라는 말은 열이 하나라는 뜻은 아니에요. 사번과 연도처럼 여러 열을 묶어서 기본 키 하나로 만들 수 있고, 이렇게 만든 키를 복합 키라고 불러요. 기본 키와 고유 키를 만들면 Oracle은 중복을 빨리 찾기 위해 인덱스(값을 빨리 찾게 해 주는 색인)도 자동으로 만들어요.

고유 키(UNIQUE)는 중복만 막고 NULL은 막지 않아요. 그리고 NULL은 "모르는 값"이라 서로 같다고 보지 않기 때문에, NULL은 몇 개가 들어가도 중복으로 치지 않아요.

```sql
CREATE TABLE 사원연락처 (사번 NUMBER(4), 이메일 VARCHAR2(50) UNIQUE);
INSERT INTO 사원연락처 VALUES (1001, NULL);
INSERT INTO 사원연락처 VALUES (1002, NULL);                   -- NULL은 여러 개 들어가요
INSERT INTO 사원연락처 VALUES (1003, 'seojun@passql.kr');
INSERT INTO 사원연락처 VALUES (1004, 'seojun@passql.kr');     -- 오류: 같은 이메일이 이미 있어요 (ORA-00001)
SELECT COUNT(*) FROM 사원연락처;                              -- NULL 두 행과 이메일 한 행이라 3이 나와요
```

마지막 줄의 `COUNT(*)`는 표에 들어 있는 행을 세는 함수예요. 그룹 함수 단원에서 자세히 배워요.

## NOT NULL과 CHECK {{#not-null-check}}

NOT NULL은 그 열을 비워 둘 수 없게 해요. 부서명은 NOT NULL이라서 부서명 없이 부서를 넣으면 거부돼요. CHECK는 열에 들어갈 값의 조건을 직접 적어 두는 제약조건이고, 조건이 거짓이 되는 값을 막아요.

```sql
INSERT INTO 부서 (부서번호, 지역) VALUES (50, '대전');              -- 오류: 부서명이 비어 있어요 (ORA-01400)
ALTER TABLE 사원 ADD CONSTRAINT 사원_급여_CK CHECK (급여 > 0);
UPDATE 사원 SET 급여 = -100 WHERE 사번 = 1001;                     -- 오류: 급여 > 0을 어겨요 (ORA-02290)
```

CHECK 조건은 같은 행의 값만 볼 수 있어서, 다른 행이나 다른 테이블을 조회하는 서브쿼리(SQL 안에 괄호로 넣은 또 하나의 SELECT, 서브쿼리 단원)는 쓸 수 없어요(ORA-02251, CHECK에 서브쿼리 불가). 이미 조건을 어기는 데이터가 들어 있는 테이블에 CHECK를 새로 걸려고 하면, 걸리지 않고 오류(ORA-02293, 기존 데이터가 CHECK 위반)가 나요.

## 외래 키와 참조 무결성 {{#foreign-key}}

외래 키는 한 테이블의 열이 다른 테이블의 기본 키를 가리키게 하는 제약조건이에요. 사원의 부서번호는 부서 표의 부서번호를 가리키는데, 이때 가리킴을 받는 부서를 부모 테이블, 가리키는 사원을 자식 테이블이라고 불러요.

{DEPARTMENT_TABLE_MD}

{EMPLOYEE_SALARY_DEPARTMENT_TABLE}

자식의 외래 키 값은 부모에 실제로 있는 값이거나 NULL이어야 하고, 이 규칙을 참조 무결성이라고 해요. 윤서연(1008)처럼 부서번호가 NULL인 사원은 아직 부서가 정해지지 않았다는 뜻이라 허용돼요.

```sql
INSERT INTO 사원 (사번, 이름, 부서번호) VALUES (1009, '강하준', 50);   -- 오류: 50번 부서가 없어요 (ORA-02291)
DELETE FROM 부서 WHERE 부서번호 = 20;                                 -- 오류: 20번 부서에 사원이 3명 있어요 (ORA-02292)
DELETE FROM 부서 WHERE 부서번호 = 40;                                 -- 사원이 없는 부서라 지워져요
SELECT COUNT(*) FROM 부서;                                            -- 네 부서 중 40번만 빠져서 3이 나와요
```

오류 번호 두 개를 방향으로 구분하면 외우기 쉬워요. ORA-02291은 "부모 키를 찾을 수 없다"는 뜻이라 자식 쪽에 없는 값을 넣거나 고칠 때 나오고, ORA-02292는 "자식 레코드가 있다"는 뜻이라 부모 쪽 행을 지우거나 그 키를 고칠 때 나와요.

## 삭제 옵션: ON DELETE CASCADE와 SET NULL {{#on-delete}}

외래 키에 아무 옵션도 주지 않으면, 앞에서 본 것처럼 자식이 있는 부모 행은 지울 수 없어요. 외래 키를 만들 때 옵션을 붙이면 부모 행을 지울 때 자식 행을 어떻게 할지 정할 수 있어요.

| 옵션 | 부모 행을 지우면 |
|---|---|
| 없음 (기본) | 자식 행이 있으면 삭제를 거부해요 (ORA-02292, 자식 행이 있음) |
| `ON DELETE CASCADE` | 그 부모를 가리키던 자식 행도 함께 지워요 |
| `ON DELETE SET NULL` | 자식 행은 남기고 외래 키 값만 NULL로 바꿔요 |

아래는 부서를 가리키는 프로젝트 표를 새로 만들어 확인한 예시예요. 사원이 없는 40번 부서에 프로젝트 두 개를 달아 두고 40번 부서를 지웠어요.

```sql
CREATE TABLE 프로젝트 (
  프로젝트번호 NUMBER(3) PRIMARY KEY,
  프로젝트명   VARCHAR2(30),
  부서번호     NUMBER(2) REFERENCES 부서(부서번호) ON DELETE CASCADE
);
INSERT INTO 프로젝트 VALUES (1, '채용 시스템', 40);
INSERT INTO 프로젝트 VALUES (2, '교육 계획', 40);
DELETE FROM 부서 WHERE 부서번호 = 40;
SELECT COUNT(*) FROM 프로젝트;   -- 자식 행도 함께 지워져서 0이 나와요
```

```sql
CREATE TABLE 프로젝트 (
  프로젝트번호 NUMBER(3) PRIMARY KEY,
  프로젝트명   VARCHAR2(30),
  부서번호     NUMBER(2) REFERENCES 부서(부서번호) ON DELETE SET NULL
);
INSERT INTO 프로젝트 VALUES (1, '채용 시스템', 40);
DELETE FROM 부서 WHERE 부서번호 = 40;
SELECT 프로젝트번호, 부서번호 FROM 프로젝트;   -- 프로젝트 1은 남고, 부서번호만 NULL이 돼요
```

Oracle이 지원하는 삭제 옵션은 이 두 가지뿐이에요. 표준 SQL과 다른 데이터베이스에는 자식이 있으면 거부하는 RESTRICT·NO ACTION, 기본값으로 바꾸는 SET DEFAULT, 부모 키를 고칠 때 자식도 따라 고치는 ON UPDATE CASCADE가 더 있지만, Oracle에서 `ON DELETE RESTRICT`처럼 쓰면 오류가 나요.

## 제약조건 이름과 나중에 추가하기 {{#naming}}

제약조건에는 `CONSTRAINT 이름`으로 이름을 붙일 수 있어요. 이름을 붙이지 않으면 Oracle이 `SYS_C0010806`처럼 알아보기 어려운 이름을 붙이는데, 오류 메시지에 이 이름이 나오기 때문에 직접 이름을 붙여 두면 어떤 규칙에 걸렸는지 바로 알 수 있어요.

```sql
CREATE TABLE 부서이력 (
  부서번호 NUMBER(2),
  변경일   DATE,
  부서명   VARCHAR2(20) CONSTRAINT 부서이력_부서명_NN NOT NULL,
  CONSTRAINT 부서이력_PK PRIMARY KEY (부서번호, 변경일)
);
INSERT INTO 부서이력 VALUES (10, DATE '2026-01-01', '기획부');
INSERT INTO 부서이력 VALUES (10, DATE '2026-01-01', '기획팀');   -- 오류: 부서이력_PK에 걸려요 (ORA-00001)
```

열 정의 바로 뒤에 쓰는 방식을 열 수준, 모든 열을 적은 뒤 따로 쓰는 방식을 테이블 수준이라고 불러요. 여러 열을 묶는 복합 키는 테이블 수준으로만 쓸 수 있어요. 이미 만든 테이블에는 `ALTER TABLE ... ADD CONSTRAINT 이름 종류 (열)`로 추가하고, `ALTER TABLE ... DROP CONSTRAINT 이름`으로 지워요.

```sql
ALTER TABLE 부서 ADD CONSTRAINT 부서_부서명_UK UNIQUE (부서명);
INSERT INTO 부서 VALUES (50, '개발부', '대전');      -- 오류: 부서_부서명_UK에 걸려요 (ORA-00001)
ALTER TABLE 부서 DROP CONSTRAINT 부서_부서명_UK;
INSERT INTO 부서 VALUES (50, '개발부', '대전');      -- 규칙을 지웠으니 들어가요
```

## DEFAULT는 제약조건이 아니에요 {{#default}}

DEFAULT는 INSERT할 때 그 열의 값을 생략하면 대신 넣어 주는 기본값이에요. 어떤 값도 거부하지 않기 때문에 제약조건으로 치지 않아요. 기본값은 열을 아예 적지 않았거나 값 자리에 `DEFAULT`라고 썼을 때만 들어가고, NULL을 직접 적으면 NULL이 들어가요.

{DEFAULT_VALUE_EXAMPLE.markdown}

## 자주 헷갈리는 점 {{#confusing}}

**기본 키와 고유 키는 NULL과 개수에서 갈려요.** 둘 다 중복을 막지만, 기본 키는 NULL을 막고 테이블에 하나뿐이며, 고유 키는 NULL을 여러 개 허용하고 테이블에 여러 개 둘 수 있어요. 중복 값을 넣었을 때는 둘 다 같은 오류(ORA-00001, 중복 값)가 나요.

**CHECK는 NULL을 막지 못해요.** NULL은 모르는 값이라서 무엇과 비교해도 참도 거짓도 아닌 UNKNOWN이 돼요(SELECT 기본 단원의 'WHERE 절과 NULL' 개념). 그래서 급여가 NULL이면 `급여 > 0`의 결과도 UNKNOWN이에요. WHERE는 참인 행만 통과시키고, CHECK는 거짓인 행만 막아요. 그래서 UNKNOWN인 NULL은 CHECK를 통과해요. NULL까지 막으려면 NOT NULL을 함께 걸어야 해요.

```sql
ALTER TABLE 사원 ADD CONSTRAINT 사원_급여_CK CHECK (급여 > 0);
UPDATE 사원 SET 급여 = NULL WHERE 사번 = 1001;   -- CHECK가 있어도 바뀌어요
SELECT 급여 FROM 사원 WHERE 사번 = 1001;          -- NULL이 나와요
```

**외래 키 열에는 NULL이 들어갈 수 있어요.** "부모에 있는 값만"이라는 규칙은 값이 있을 때의 이야기이고, NULL은 아직 연결되지 않았다는 뜻이라 허용돼요. 외래 키 열에도 NULL을 막고 싶으면 NOT NULL을 따로 걸어요.

**외래 키는 부모의 기본 키나 고유 키만 가리킬 수 있어요.** 부서명처럼 중복될 수 있는 일반 열을 가리키게 만들면, 어느 행을 가리키는지 정할 수 없어서 오류(ORA-02270, 가리킬 기본 키·고유 키가 없음)가 나요.

**CASCADE가 붙은 두 문법은 지우는 대상이 달라요.** `ON DELETE CASCADE`는 부모 행을 지울 때 자식 행을 함께 지우는 외래 키 옵션이에요. `DROP TABLE 부서 CASCADE CONSTRAINTS`는 부모 테이블을 없애면서 자식에 걸린 외래 키 규칙만 지우고, 자식 데이터는 남겨요.

**NOT NULL은 ADD CONSTRAINT로 붙이지 않아요.** 다른 제약조건은 `ADD CONSTRAINT 이름 UNIQUE (열)`처럼 추가하지만, NOT NULL은 `ALTER TABLE 사원 MODIFY (직급 NOT NULL)`처럼 MODIFY로 붙여요. `ADD CONSTRAINT 이름 NOT NULL (직급)`은 오류(ORA-00904, 잘못된 이름)가 나고, CREATE TABLE에서도 NOT NULL은 테이블 수준이 아니라 열 수준으로만 써요.

**DEFAULT가 있어도 NULL을 직접 넣으면 NULL이에요.** 기본값은 값을 생략했을 때만 들어가요. 그리고 DEFAULT는 아무것도 막지 않으므로 "제약조건의 종류가 아닌 것"을 고르는 문제의 정답으로 자주 나와요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

기본 키와 고유 키의 차이를 고르는 문제, 제약조건이 걸린 테이블에 INSERT·UPDATE·DELETE를 실행했을 때 성공하는지 묻는 문제가 가장 많아요. 외래 키 문제는 지우려는 행이 부모인지 자식인지, ON DELETE 옵션이 있는지를 먼저 확인하면 풀려요. CHECK와 UNIQUE에 NULL을 넣는 보기도 자주 나오는데, 둘 다 NULL을 막지 않는다는 점을 기억해 두면 돼요.""",
    "checkQuestions": [
        question(1, "기본 키(PRIMARY KEY)에 대한 설명으로 옳은 것은 무엇인가요?", "primary-unique",
                 "기본 키는 UNIQUE와 NOT NULL을 합친 제약조건이고 테이블에 하나만 둘 수 있어요. 여러 열을 묶어 기본 키 하나로 만들 수도 있어요.",
                 [choice("A", "NULL을 여러 개 넣을 수 있다", rationale="NULL을 여러 개 허용하는 것은 고유 키이고, 기본 키는 NULL을 막아요."),
                  choice("B", "한 테이블에 여러 개 만들 수 있다", rationale="기본 키는 테이블에 하나뿐이라 두 번째를 만들면 ORA-02260(기본 키는 하나만) 오류가 나요."),
                  choice("C", "UNIQUE와 NOT NULL을 합친 것과 같고 테이블에 하나만 둘 수 있다", True, "기본 키의 정의 그대로예요."),
                  choice("D", "여러 열을 묶어서 기본 키로 만들 수 없다", rationale="여러 열을 묶은 복합 키도 기본 키 하나로 만들 수 있어요.")]),
        question(2, "다음 SQL을 실행한 결과는 무엇인가요?", "primary-unique",
                 "UNIQUE는 중복만 막고 NULL은 여러 개 허용해요. 세 INSERT가 모두 성공해서 3이 나와요.",
                 [choice("A", "2", rationale="두 번째 NULL도 중복으로 치지 않아서 들어가요."),
                  choice("B", "3", True, "NULL 두 개와 이메일 하나가 모두 들어가요."),
                  choice("C", "1", rationale="UNIQUE는 NULL을 막지 않아서 NULL 행도 들어가요."),
                  choice("D", "오류가 난다", rationale="같은 이메일을 넣지 않았으므로 오류가 나지 않아요.")],
                 stem_sql=UNIQUE_NULL_STEM_SQL),
        question(3, "공통 예시 데이터(20번 부서에 사원 3명)에서 다음 SQL을 실행하면 어떻게 되나요?", "foreign-key",
                 "사원의 부서번호가 옵션 없는 외래 키로 부서를 가리키고 있어요. 자식 행이 있는 부모 행은 지울 수 없어서 ORA-02292(자식 행이 있음) 오류가 나요.",
                 [choice("A", "20번 부서와 그 부서 사원 3명이 함께 지워진다", rationale="ON DELETE CASCADE가 있을 때의 결과인데, 공통 데이터의 외래 키에는 옵션이 없어요."),
                  choice("B", "20번 부서가 지워지고 사원 3명의 부서번호가 NULL이 된다", rationale="ON DELETE SET NULL이 있을 때의 결과예요."),
                  choice("C", "오류 없이 0행이 지워진다", rationale="20번 부서는 실제로 있으므로 0행이 아니라 삭제를 시도하다 거부돼요."),
                  choice("D", "자식 레코드가 있다는 오류(ORA-02292, 자식 행이 있음)가 난다", True, "자식이 있는 부모 행은 지울 수 없어요.")],
                 stem_sql="DELETE FROM 부서 WHERE 부서번호 = 20;"),
        question(4, "다음 SQL을 차례로 실행하면 마지막 결과는 무엇인가요?", "on-delete",
                 "ON DELETE CASCADE라서 40번 부서를 지우면 40번을 가리키던 프로젝트 1, 2가 함께 지워져요. 20번 부서의 프로젝트 3만 남아요.",
                 [choice("A", "1", True, "40번 부서의 프로젝트 두 개가 함께 지워지고 하나가 남아요."),
                  choice("B", "3", rationale="ON DELETE CASCADE가 있어서 자식 행이 그대로 남지 않아요."),
                  choice("C", "0", rationale="20번 부서를 가리키는 프로젝트 3은 지워지지 않아요."),
                  choice("D", "오류가 난다", rationale="CASCADE 옵션이 있어서 자식이 있어도 부모 행을 지울 수 있어요.")],
                 stem_sql=CASCADE_STEM_SQL),
        question(5, "다음 SQL을 차례로 실행하면 마지막 결과는 무엇인가요?", "confusing",
                 "NULL은 급여 > 0의 결과가 UNKNOWN이라 CHECK에 걸리지 않아요. CHECK는 거짓인 값만 막기 때문에 UPDATE가 성공하고 1이 나와요.",
                 [choice("A", "CHECK 위반 오류(ORA-02290, CHECK 조건 위반)가 난다", rationale="CHECK는 거짓인 값만 막고, UNKNOWN이 되는 NULL은 통과시켜요."),
                  choice("B", "0", rationale="UPDATE가 성공해서 김민수의 급여가 NULL이 돼요."),
                  choice("C", "1", True, "NULL은 CHECK를 통과해서 김민수 한 명의 급여가 NULL이 돼요."),
                  choice("D", "8", rationale="WHERE 사번 = 1001이라서 한 명만 바뀌어요.")],
                 stem_sql=CHECK_NULL_STEM_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 기본 키: 중복·NULL 거부, 테이블에 하나
        sql_error_check("INSERT INTO 부서 VALUES (10, '총무부', '대전')", "ORA-00001"),
        sql_error_check("INSERT INTO 부서 VALUES (NULL, '총무부', '대전')", "ORA-01400"),
        sql_error_check("ALTER TABLE 부서 ADD PRIMARY KEY (부서명)", "ORA-02260"),
        sql_check("SELECT COUNT(*) FROM user_indexes WHERE table_name IN ('부서', '사원')", [[2]]),
        # 고유 키: NULL 여러 개 허용, 같은 값 거부 (확인 문제 2)
        sql_check(UNIQUE_NULL_STEM_SQL, [[3]]),
        sql_error_check("INSERT INTO 사원연락처 VALUES (1004, 'seojun@passql.kr')", "ORA-00001",
                        setup="CREATE TABLE 사원연락처 (사번 NUMBER(4), 이메일 VARCHAR2(50) UNIQUE);\n"
                              "INSERT INTO 사원연락처 VALUES (1003, 'seojun@passql.kr');"),
        # NOT NULL, CHECK (위반·서브쿼리 불가·기존 데이터 위반)
        sql_error_check("INSERT INTO 부서 (부서번호, 지역) VALUES (50, '대전')", "ORA-01400"),
        sql_error_check("UPDATE 사원 SET 급여 = -100 WHERE 사번 = 1001", "ORA-02290",
                        setup="ALTER TABLE 사원 ADD CONSTRAINT 사원_급여_CK CHECK (급여 > 0);"),
        sql_error_check("ALTER TABLE 사원 ADD CONSTRAINT 사원_부서_CK CHECK (부서번호 IN (SELECT 부서번호 FROM 부서))", "ORA-02251"),
        sql_error_check("ALTER TABLE 사원 ADD CONSTRAINT 사원_커미션_CK CHECK (커미션 >= 100)", "ORA-02293"),
        # CHECK 는 NULL 통과 (확인 문제 5)
        sql_check(CHECK_NULL_STEM_SQL, [[1]]),
        sql_check("SELECT 급여 FROM 사원 WHERE 사번 = 1001", [[None]],
                  setup="ALTER TABLE 사원 ADD CONSTRAINT 사원_급여_CK CHECK (급여 > 0);\nUPDATE 사원 SET 급여 = NULL WHERE 사번 = 1001;"),
        # 외래 키: 자식 쪽 ORA-02291, 부모 쪽 ORA-02292, 자식 없는 부모는 삭제됨 (확인 문제 3)
        sql_error_check("INSERT INTO 사원 (사번, 이름, 부서번호) VALUES (1009, '강하준', 50)", "ORA-02291"),
        sql_error_check("UPDATE 사원 SET 부서번호 = 50 WHERE 사번 = 1001", "ORA-02291"),
        sql_error_check("DELETE FROM 부서 WHERE 부서번호 = 20;", "ORA-02292"),
        sql_error_check("UPDATE 부서 SET 부서번호 = 50 WHERE 부서번호 = 20", "ORA-02292"),
        sql_check("DELETE FROM 부서 WHERE 부서번호 = 40;\nSELECT COUNT(*) FROM 부서;", [[3]]),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 IS NULL", [["윤서연"]]),
        sql_check("SELECT COUNT(*) FROM 사원 WHERE 부서번호 = 20", [[3]]),
        sql_check("INSERT INTO 사원 (사번, 이름, 부서번호) VALUES (1009, '강하준', NULL);\nSELECT COUNT(*) FROM 사원;", [[9]]),
        sql_error_check("CREATE TABLE 프로젝트 (프로젝트번호 NUMBER(3), 부서명 VARCHAR2(20) REFERENCES 부서(부서명))", "ORA-02270"),
        # ON DELETE CASCADE·SET NULL, Oracle 에 없는 옵션 (확인 문제 4)
        sql_check(PROJECT_CASCADE_SETUP + "\nDELETE FROM 부서 WHERE 부서번호 = 40;\nSELECT COUNT(*) FROM 프로젝트;", [[0]]),
        sql_check(CASCADE_STEM_SQL, [[1]]),
        sql_check("SELECT 프로젝트번호, 부서번호 FROM 프로젝트", [[1, None]],
                  setup="CREATE TABLE 프로젝트 (프로젝트번호 NUMBER(3) PRIMARY KEY, 프로젝트명 VARCHAR2(30),"
                        " 부서번호 NUMBER(2) REFERENCES 부서(부서번호) ON DELETE SET NULL);\n"
                        "INSERT INTO 프로젝트 VALUES (1, '채용 시스템', 40);\nDELETE FROM 부서 WHERE 부서번호 = 40;"),
        sql_error_check("CREATE TABLE 프로젝트 (프로젝트번호 NUMBER(3), 부서번호 NUMBER(2) REFERENCES 부서(부서번호) ON DELETE RESTRICT)", "ORA-00905"),
        # 제약조건 이름 (오류 메시지에 이름), 복합 키, 추가·삭제
        sql_check("SELECT constraint_name FROM user_constraints WHERE table_name = '부서이력' AND constraint_type = 'P'", [["부서이력_PK"]],
                  setup="CREATE TABLE 부서이력 (부서번호 NUMBER(2), 변경일 DATE, 부서명 VARCHAR2(20) CONSTRAINT 부서이력_부서명_NN NOT NULL,"
                        " CONSTRAINT 부서이력_PK PRIMARY KEY (부서번호, 변경일));"),
        sql_check("SELECT COUNT(*) FROM 부서이력", [[2]],
                  setup="CREATE TABLE 부서이력 (부서번호 NUMBER(2), 변경일 DATE, 부서명 VARCHAR2(20), CONSTRAINT 부서이력_PK PRIMARY KEY (부서번호, 변경일));\n"
                        "INSERT INTO 부서이력 VALUES (10, DATE '2026-01-01', '기획부');\nINSERT INTO 부서이력 VALUES (10, DATE '2026-03-01', '기획팀');"),
        sql_error_check("INSERT INTO 부서 VALUES (50, '개발부', '대전')", "ORA-00001",
                        setup="ALTER TABLE 부서 ADD CONSTRAINT 부서_부서명_UK UNIQUE (부서명);"),
        sql_check("SELECT COUNT(*) FROM 부서 WHERE 부서명 = '개발부'", [[2]],
                  setup="ALTER TABLE 부서 ADD CONSTRAINT 부서_부서명_UK UNIQUE (부서명);\nALTER TABLE 부서 DROP CONSTRAINT 부서_부서명_UK;\n"
                        "INSERT INTO 부서 VALUES (50, '개발부', '대전');"),
        # NOT NULL 은 MODIFY 로만 (ADD CONSTRAINT·테이블 수준 불가)
        sql_error_check("ALTER TABLE 사원 ADD CONSTRAINT 사원_직급_NN NOT NULL (직급)", "ORA-00904"),
        sql_error_check("CREATE TABLE 프로젝트 (프로젝트번호 NUMBER(3), 이름 VARCHAR2(20), CONSTRAINT 프로젝트_이름_NN NOT NULL (이름))", "ORA-00904"),
        sql_error_check("UPDATE 사원 SET 직급 = NULL WHERE 사번 = 1001", "ORA-01407",
                        setup="ALTER TABLE 사원 MODIFY (직급 NOT NULL);"),
        # DEFAULT: 생략·DEFAULT 키워드면 기본값, NULL 을 직접 넣으면 NULL
DEFAULT_VALUE_EXAMPLE.check,
    ],
}
