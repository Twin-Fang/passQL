"""개념: 뷰 (6단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check
from concept_dataset import DEPARTMENT_TABLE_MD, to_employee_table_md

# 이 개념의 계산에 쓰는 열 전부 (직급·급여·부서번호)
EMPLOYEE_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")

# 확인 문제·검증 공통: 개발부 사원만 보여 주는 뷰 (조건 검사 있음·없음)
DEVELOPMENT_VIEW_SQL = "CREATE VIEW 개발부사원 AS SELECT 사번, 이름, 급여, 부서번호 FROM 사원 WHERE 부서번호 = 20;"
DEVELOPMENT_CHECK_VIEW_SQL = ("CREATE VIEW 개발부사원 AS SELECT 사번, 이름, 부서번호 FROM 사원 WHERE 부서번호 = 20 "
                              "WITH CHECK OPTION;")

CONCEPT = {
    "tagKey": "subquery-view",
    "topicCode": "sql_subquery",
    "sortOrder": 5,
    "title": "뷰",
    "summary": "SELECT 문에 이름을 붙여 저장해 두고 테이블처럼 쓰는 가상 테이블이에요",
    "coreMd": (
        "- 뷰는 **SELECT 문만** 저장한 가상 테이블이라, 조회할 때마다 기본 테이블에서 읽어 와요.\n"
        "- 정의를 바꿀 때는 `CREATE OR REPLACE VIEW`를 쓰고, `ALTER VIEW`로는 **바꿀 수 없어요**.\n"
        "- 장점은 독립성·편리성·보안성(**독편보**)이고, 뷰를 쓴다고 조회가 빨라지지는 않아요.\n"
        "- 뷰에는 **인덱스**를 만들 수 없고, 집계나 DISTINCT가 든 뷰로는 데이터를 바꿀 수 없어요.\n"
        "- `WITH CHECK OPTION`은 뷰 조건을 벗어나는 변경을, `WITH READ ONLY`는 모든 변경을 막아요."
    ),
    "detailMd": f"""## 자주 쓰는 SELECT에 이름 붙이기 — 반복과 노출 줄이기 {{#why}}

개발부 사원 목록을 매일 보는 사람은 같은 SELECT 문을 매번 다시 적어야 하고, 여러 사람이 각자 적다 보면 조건을 틀리기도 해요. 다른 팀에 급여를 숨긴 사원 목록만 보여 주고 싶을 때도, 보여 줄 열만 고른 SELECT 문에 이름을 붙여 저장해 두면 돼요.

예시는 모두 아래 두 표로 계산해요.

{EMPLOYEE_TABLE}

{DEPARTMENT_TABLE_MD}

## 한 줄 정의 — 데이터 없는 가상 테이블 {{#definition}}

| 용어 | 뜻 |
|---|---|
| 뷰 (View) | SELECT 문에 이름을 붙여 저장해 둔 가상 테이블이에요. 뷰 자체에는 데이터가 없어요 |
| 기본 테이블 (Base Table) | 뷰가 읽어 오는 원래 테이블이에요. 뷰를 조회할 때마다 저장된 SELECT 문이 이 테이블에서 값을 가져와요 |

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름, 급여
FROM 사원
WHERE 부서번호 = 20;

SELECT 이름, 급여 FROM 개발부사원;
```

| 이름 | 급여 |
|---|---|
| 이지은 | 2500 |
| 박서준 | 2800 |
| 정하늘 | 2500 |

뷰가 데이터를 저장하지 않는다는 것은 기본 테이블을 고쳐 보면 드러나요. 뷰는 건드리지 않고 사원 테이블에서 정하늘의 급여만 2600으로 고쳤는데, 뷰에서도 2600으로 보여요.

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름, 급여 FROM 사원 WHERE 부서번호 = 20;

UPDATE 사원 SET 급여 = 2600 WHERE 사번 = 1005;  -- 기본 테이블만 고쳐요
SELECT 이름, 급여 FROM 개발부사원;               -- 정하늘의 급여가 2600으로 보여요
```

| 비교 | 인라인 뷰 | 뷰 (`CREATE VIEW`) |
|---|---|---|
| 있는 기간 | 그 SQL 안에서만 쓰고 사라져요 | 이름과 함께 데이터베이스에 남아요 |
| 다시 쓰기 | 못 해요 | 권한만 있으면 누구든 다시 써요 |

## 만들고, 바꾸고, 지우기 — CREATE·CREATE OR REPLACE·DROP {{#create-replace-drop}}

| 명령 | 하는 일 |
|---|---|
| `CREATE VIEW` | 새 뷰를 만들어요. 이미 있는 이름이면 ORA-00955(이미 쓰고 있는 이름) 오류예요 |
| `CREATE OR REPLACE VIEW` | 같은 이름의 뷰를 새 정의로 덮어써요. 정의를 바꿀 때 써요 |
| `DROP VIEW` | 뷰를 지워요. 저장된 SELECT 문만 사라지고 데이터는 기본 테이블에 남아요 |

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름 FROM 사원 WHERE 부서번호 = 20;

CREATE VIEW 개발부사원 AS
SELECT 사번, 이름, 직급 FROM 사원 WHERE 부서번호 = 20;  -- 오류: 같은 이름의 뷰가 이미 있어요

CREATE OR REPLACE VIEW 개발부사원 AS
SELECT 사번, 이름, 직급 FROM 사원 WHERE 부서번호 = 20;  -- 직급 열이 들어간 정의로 바뀌어요

SELECT * FROM 개발부사원;
```

| 사번 | 이름 | 직급 |
|---|---|---|
| 1002 | 이지은 | 과장 |
| 1003 | 박서준 | 대리 |
| 1005 | 정하늘 | 사원 |

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름 FROM 사원 WHERE 부서번호 = 20;

DROP VIEW 개발부사원;
SELECT COUNT(*) FROM 사원;  -- 8명이 그대로 있어요
```

## 장점과 한계 — 독편보, 그리고 못 하는 것 {{#pros-cons}}

| 외우기 | 뜻 |
|---|---|
| 독 | 독립성: 기본 테이블 구조가 바뀌어도 뷰 정의만 고치면, 뷰를 쓰던 프로그램과 SQL은 그대로 둬요 |
| 편 | 편리성: 복잡한 조인과 조건을 뷰로 만들어 두면 짧은 SELECT 문으로 같은 결과를 얻어요 |
| 보 | 보안성: 숨기고 싶은 열이나 행을 뺀 뷰만 보여 주면, 사용자가 그 데이터를 볼 수 없어요 |

보안성은 사원 테이블 조회 권한은 주지 않고 급여를 뺀 뷰의 조회 권한만 주는 식으로 써요. 권한을 허락하는 명령은 GRANT이고, 3단원에서 다뤄요.

```sql
CREATE VIEW 사원공개 AS
SELECT 사번, 이름, 직급, 부서번호 FROM 사원;

SELECT 급여 FROM 사원공개;  -- 오류: 뷰에 급여 열이 없어요
```

뷰에 없는 열을 부르면 ORA-00904(없는 열 이름) 오류가 나서, 이 뷰만 쓰는 사람은 급여를 볼 수 없어요.

| 한계 | 뜻 |
|---|---|
| 인덱스 | 뷰에는 인덱스(조회를 빠르게 하려고 만드는 색인)를 따로 만들 수 없어요 |
| 정의 변경 | ALTER로 정의를 고칠 수 없어서 `CREATE OR REPLACE`로 다시 만들어요 |
| 데이터 변경 | 뷰의 모양에 따라 뷰를 통한 INSERT, UPDATE, DELETE가 막혀요 |

## 뷰로 데이터 바꾸기 — 단순한 뷰만 돼요 {{#view-dml}}

뷰에는 데이터가 없으니, 뷰를 통해 바꾸면 실제로 바뀌는 것은 기본 테이블이에요. 뷰의 한 행이 기본 테이블의 어느 행인지 정할 수 있을 때만 바꿀 수 있어요.

| 뷰의 모양 | 뷰로 변경 | 이유 |
|---|---|---|
| 테이블 하나에서 집계 없이 열과 행만 고른 뷰 | 돼요 | 뷰의 행이 기본 테이블의 행 하나와 이어져요 |
| GROUP BY, 집계 함수, DISTINCT가 든 뷰 | 안 돼요 | 여러 행이 한 행으로 합쳐져서 ORA-01732(이 뷰에는 데이터 변경을 할 수 없음) 오류예요 |
| 계산식으로 만든 열 | 그 열은 안 돼요 | 기본 테이블에 그런 열이 없어서 ORA-01733(가상 열은 바꿀 수 없음) 오류예요 |

집계 함수는 SUM처럼 여러 행을 모아 값 하나를 계산하는 함수이고, DISTINCT는 중복을 없애는 키워드예요.

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름, 직급 FROM 사원 WHERE 부서번호 = 20;

UPDATE 개발부사원 SET 직급 = '과장' WHERE 사번 = 1003;
SELECT 직급 FROM 사원 WHERE 사번 = 1003;  -- 기본 테이블에서도 과장으로 바뀌었어요
```

```sql
CREATE VIEW 부서별급여 AS
SELECT 부서번호, SUM(급여) AS 급여합계 FROM 사원 GROUP BY 부서번호;

UPDATE 부서별급여 SET 급여합계 = 0 WHERE 부서번호 = 10;  -- 오류: 집계한 뷰는 바꿀 수 없어요

CREATE VIEW 사원연봉 AS
SELECT 사번, 급여 * 12 AS 연봉 FROM 사원;

UPDATE 사원연봉 SET 연봉 = 0 WHERE 사번 = 1001;  -- 오류: 계산한 열은 바꿀 수 없어요
```

## WITH CHECK OPTION과 WITH READ ONLY — 뷰로 바꾸는 범위 정하기 {{#check-option}}

| 옵션 | 막는 것 | 위반하면 |
|---|---|---|
| `WITH CHECK OPTION` | 뷰 조건을 벗어나게 하는 INSERT·UPDATE | ORA-01402(WITH CHECK OPTION 조건 위반) 오류예요 |
| `WITH READ ONLY` | 뷰를 통한 INSERT, UPDATE, DELETE 전부 | ORA-42399(읽기 전용 뷰에는 데이터 변경을 할 수 없음) 오류예요 |

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름, 부서번호 FROM 사원 WHERE 부서번호 = 20
WITH CHECK OPTION;

UPDATE 개발부사원 SET 부서번호 = 30 WHERE 사번 = 1005;  -- 오류: 30번이 되면 뷰 조건을 벗어나요
INSERT INTO 개발부사원 VALUES (1009, '강하나', 30);       -- 오류: 30번 사원은 뷰 조건 밖이에요
INSERT INTO 개발부사원 VALUES (1009, '강하나', 20);       -- 20번 사원이라 그대로 들어가요
SELECT 이름 FROM 개발부사원;
```

마지막 SELECT는 이지은, 박서준, 정하늘에 새로 들어간 강하나까지 네 명을 돌려줘요.

```sql
CREATE VIEW 개발부조회 AS
SELECT 사번, 이름, 부서번호 FROM 사원 WHERE 부서번호 = 20
WITH READ ONLY;

UPDATE 개발부조회 SET 이름 = '정하늘' WHERE 사번 = 1005;  -- 오류: 읽기 전용 뷰예요
```

## 자주 헷갈리는 점 — 저장, ALTER, 인덱스, 성능, 옵션 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| 뷰는 조회 결과를 저장해 둬요 | SELECT 문만 저장해요. 결과를 미리 계산해 저장하는 것은 머티리얼라이즈드 뷰(Materialized View)라는 다른 객체이고, SQLD 시험 범위 밖이에요 |
| ALTER VIEW로 뷰의 SELECT 문을 바꿔요 | Oracle의 ALTER VIEW는 뷰를 다시 점검하는 관리용 명령이에요. `ALTER VIEW ... AS SELECT ...`는 ORA-00922(없거나 잘못된 옵션) 오류예요 |
| ALTER TABLE로 뷰에 열을 더해요 | ALTER TABLE은 테이블만 고쳐서, 뷰 이름을 넣으면 ORA-00942(테이블이나 뷰가 없음) 오류예요 |
| 뷰에 인덱스를 만들어 빠르게 해요 | `CREATE INDEX`는 ORA-01702(뷰는 이 자리에 쓸 수 없음) 오류예요. 뷰를 조회할 때는 기본 테이블의 인덱스가 쓰여요 |
| 뷰를 쓰면 조회 성능이 좋아져요 | 조회할 때마다 저장된 SELECT 문이 기본 테이블을 상대로 다시 실행돼서, 직접 쓴 SQL과 하는 일이 같아요 |
| CHECK OPTION이 없어도 뷰 조건 밖으로는 못 바꿔요 | 옵션이 없으면 조건을 벗어나는 변경도 통과하고, 바뀐 행은 뷰에서 사라져요 |
| CHECK OPTION과 READ ONLY는 막는 범위가 같아요 | CHECK OPTION은 조건 안의 변경을 허용하고, READ ONLY는 조건과 상관없이 모두 막아요 |

무엇을 지우느냐에 따라 남는 것이 달라져요.

| 지운 것 | 뷰 | 사원 데이터 |
|---|---|---|
| 뷰 (`DROP VIEW`) | 사라져요 | 기본 테이블에 그대로 남아요 |
| 기본 테이블 (`DROP TABLE`) | 이름은 남지만 조회하면 ORA-04063(뷰에 오류가 있음) 오류예요 | 테이블과 함께 사라져요 |

```sql
CREATE TABLE 부서사본 AS SELECT * FROM 부서;
CREATE VIEW 부서명목록 AS SELECT 부서명 FROM 부서사본;

DROP TABLE 부서사본;
SELECT * FROM 부서명목록;  -- 오류: 기본 테이블이 없어서 뷰를 쓸 수 없어요
```

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름 FROM 사원 WHERE 부서번호 = 20;

ALTER VIEW 개발부사원 AS
SELECT 사번, 이름, 직급 FROM 사원 WHERE 부서번호 = 20;  -- 오류: ALTER VIEW로는 정의를 못 바꿔요

ALTER TABLE 개발부사원 ADD (메모 VARCHAR2(10));  -- 오류: 뷰는 ALTER TABLE 대상이 아니에요

CREATE INDEX 개발부사원_이름 ON 개발부사원 (이름);  -- 오류: 뷰에는 인덱스를 만들 수 없어요
```

정의를 바꾸려면 `CREATE OR REPLACE VIEW`를 쓰거나, DROP VIEW로 지운 뒤 다시 만들어요. 속도가 문제라면 기본 테이블 쪽에 인덱스를 만들어요.

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름, 급여 FROM 사원 WHERE 부서번호 = 20;

SELECT 이름 FROM 개발부사원 WHERE 급여 >= 2600;
SELECT 이름 FROM 사원 WHERE 부서번호 = 20 AND 급여 >= 2600;  -- 위 뷰 조회와 같은 일을 해서 둘 다 박서준이 나와요
```

옵션 없이 만든 개발부 뷰에서는 정하늘을 30번으로 옮기는 것도, 30번 사원을 넣는 것도 오류 없이 통과해요.

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름, 부서번호 FROM 사원 WHERE 부서번호 = 20;

UPDATE 개발부사원 SET 부서번호 = 30 WHERE 사번 = 1005;  -- 그대로 바뀌어요
INSERT INTO 개발부사원 VALUES (1009, '강하나', 30);       -- 그대로 들어가요
SELECT 이름 FROM 개발부사원;  -- 30번이 된 정하늘과 강하나는 보이지 않아요
SELECT COUNT(*) FROM 사원;     -- 강하나가 더해져 9명이에요
```

뷰 조회 결과는 이지은과 박서준 두 명뿐이고, 기본 테이블에는 강하나가 들어가 사원이 9명이 돼요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 뷰를 지우면 뷰가 보여 주던 사원 데이터도 함께 지워져요 | X | 저장된 SELECT 문만 사라지고 데이터는 기본 테이블에 남아요 |
| WITH CHECK OPTION이 있는 개발부 뷰로 20번 사원을 새로 넣을 수 있어요 | O | 뷰 조건 안의 변경은 허용돼요 |
| DISTINCT를 쓴 뷰로는 UPDATE를 할 수 없어요 | O | 여러 행이 한 행으로 합쳐져서 어느 행을 바꿀지 정할 수 없어요 |

## 꼭 외울 것 — 옵션과 뷰가 못 하는 것 {{#memorize}}

| 외울 것 | 답 |
|---|---|
| 뷰에 저장되는 것 | SELECT 문만, 데이터는 기본 테이블에 있어요 |
| 뷰의 장점 세 가지 | 독립성·편리성·보안성 (독편보) |
| 뷰 정의 바꾸기 | CREATE OR REPLACE VIEW, ALTER VIEW로는 못 바꿔요 |
| 뷰에 인덱스 | 만들 수 없고, 조회 때 기본 테이블 인덱스가 쓰여요 |
| 뷰로 데이터를 못 바꾸는 뷰 | GROUP BY·집계 함수·DISTINCT가 든 뷰 |
| WITH CHECK OPTION | 뷰 조건을 벗어나게 만드는 INSERT·UPDATE만 막아요 |
| WITH READ ONLY | 뷰를 통한 INSERT·UPDATE·DELETE를 모두 막아요 |
| 기본 테이블을 지우면 | 뷰 이름은 남고, 조회하면 ORA-04063(뷰에 오류가 있음) 오류 |

## 시험에서는 이렇게 나와요 — 틀린 특징 고르기 {{#exam-point}}

뷰의 특징으로 옳지 않은 것을 고르는 문제가 가장 흔해요. 아래 보기가 정답(틀린 설명)으로 자주 나와요.

| 자주 나오는 틀린 보기 | 바른 내용 |
|---|---|
| 뷰는 데이터를 저장한다 | SELECT 문만 저장해요 |
| ALTER VIEW로 정의를 바꿀 수 있다 | CREATE OR REPLACE VIEW로 바꿔요 |
| 뷰에 인덱스를 만들 수 있다 | 만들 수 없어요 |
| 뷰를 쓰면 조회 성능이 좋아진다 | 장점은 속도가 아니라 독립성, 편리성, 보안성이에요 |

독편보를 장점으로 고르는 문제와, 뷰를 통한 UPDATE가 WITH CHECK OPTION 때문에 실패하는지 묻는 문제도 나와요.""",
    "checkQuestions": [
        question(1, "뷰를 가장 알맞게 설명한 것은 무엇인가요?", "definition",
                 "뷰는 SELECT 문에 이름을 붙여 저장한 가상 테이블이에요. 데이터는 기본 테이블에만 있고, 뷰는 조회할 때마다 기본 테이블에서 읽어 와요.",
                 [choice("A", "조회 결과를 복사해서 따로 저장해 둔 테이블", rationale="뷰는 결과를 저장하지 않고 SELECT 문만 저장해요."),
                  choice("B", "SELECT 문을 저장한 가상 테이블이라서 데이터를 따로 저장하지 않는다", True, "뷰의 정의예요."),
                  choice("C", "뷰를 지우면 기본 테이블의 데이터도 함께 지워진다", rationale="뷰를 지우면 저장된 SELECT 문만 사라져요."),
                  choice("D", "뷰에 인덱스를 만들어 조회를 빠르게 할 수 있다", rationale="뷰에는 인덱스를 만들 수 없어요.")]),
        question(2, "이미 있는 개발부사원 뷰에 직급 열을 추가하려고 해요. 알맞은 방법은 무엇인가요?", "confusing",
                 "뷰의 정의는 ALTER VIEW로도 ALTER TABLE로도 바꿀 수 없어서, CREATE OR REPLACE VIEW로 같은 이름의 뷰를 새 정의로 덮어써요. DROP VIEW 후 다시 만드는 방법도 있어요.",
                 [choice("A", "ALTER VIEW 개발부사원 AS SELECT ... 로 정의를 고친다", rationale="ALTER VIEW로는 뷰의 SELECT 문을 바꿀 수 없어요."),
                  choice("B", "ALTER TABLE 개발부사원 ADD (직급 ...) 로 열을 추가한다", rationale="ALTER TABLE은 테이블만 고치는 명령이라 뷰에는 쓸 수 없어요."),
                  choice("C", "CREATE OR REPLACE VIEW 개발부사원 AS SELECT ... 로 다시 정의한다", True, "같은 이름의 뷰를 새 정의로 덮어써요."),
                  choice("D", "CREATE VIEW 개발부사원 AS SELECT ... 를 한 번 더 실행한다", rationale="같은 이름이 이미 있어서 이미 쓰고 있는 이름이라는 오류가 나요.")]),
        question(3, "뷰의 장점으로 알맞지 않은 것은 무엇인가요?", "pros-cons",
                 "뷰의 장점은 독립성, 편리성, 보안성이에요. 일반 뷰는 결과를 저장하지 않고 조회할 때마다 SELECT 문을 다시 실행하므로, 뷰를 쓴다고 조회가 빨라지지는 않아요.",
                 [choice("A", "기본 테이블 구조가 바뀌어도 뷰 정의만 고치면 뷰를 쓰는 SQL은 그대로 둘 수 있다", rationale="독립성이라는 장점이에요."),
                  choice("B", "복잡한 조인과 조건을 짧은 SELECT 문으로 쓸 수 있다", rationale="편리성이라는 장점이에요."),
                  choice("C", "숨기고 싶은 열을 뺀 뷰만 보여 줄 수 있다", rationale="보안성이라는 장점이에요."),
                  choice("D", "조회 결과가 뷰에 미리 저장되어 있어서 기본 테이블을 직접 조회할 때보다 빠르다", True,
                         "일반 뷰는 결과를 저장하지 않고 조회할 때마다 기본 테이블에서 다시 읽어서, 그 자체로 빨라지지 않아요.")]),
        question(4, "개발부사원 뷰(사원 테이블에서 부서번호 20인 사원의 사번, 이름, 급여, 부서번호)를 만든 뒤, 뷰가 아니라 사원 테이블에서 정하늘(1005)의 급여를 2500에서 2600으로 바꿨어요. 다음 SQL의 결과는 무엇인가요?", "definition",
                 "뷰는 데이터를 따로 저장하지 않고 조회할 때마다 기본 테이블에서 읽어 와요. 그래서 기본 테이블에서 바꾼 2600이 그대로 보여요.",
                 [choice("A", "2600", True, "뷰는 조회할 때마다 기본 테이블의 현재 값을 읽어요."),
                  choice("B", "2500", rationale="뷰를 만들 때의 값을 저장해 두는 것이 아니라서 옛 값이 나오지 않아요."),
                  choice("C", "NULL", rationale="기본 테이블에 값이 있으니 NULL이 될 이유가 없어요."),
                  choice("D", "오류가 난다", rationale="기본 테이블을 고쳐도 뷰는 그대로 쓸 수 있어요.")],
                 stem_sql="SELECT 급여 FROM 개발부사원 WHERE 사번 = 1005;"),
        question(5, "개발부사원 뷰를 `CREATE VIEW 개발부사원 AS SELECT 사번, 이름, 부서번호 FROM 사원 WHERE 부서번호 = 20 WITH CHECK OPTION`으로 만들었어요. "
                    "이 뷰를 통해 정하늘(1005)의 부서를 30으로 바꾸면 어떻게 되나요?", "check-option",
                 "WITH CHECK OPTION은 뷰의 WHERE 조건(부서번호 = 20)을 벗어나게 만드는 변경을 막아요. 그래서 ORA-01402(WITH CHECK OPTION 조건 위반) 오류가 나고 아무것도 바뀌지 않아요.",
                 [choice("A", "정하늘의 부서가 30으로 바뀌고 뷰에서 사라진다", rationale="옵션이 없을 때의 결과이고, CHECK OPTION이 있으면 막혀요."),
                  choice("B", "오류가 나고 바뀌지 않는다", True, "뷰 조건을 벗어나는 변경이라 조건 위반 오류가 나요."),
                  choice("C", "뷰에서만 30으로 바뀌고 기본 테이블은 그대로다", rationale="뷰에는 데이터가 없어서 뷰에서만 바뀌는 일은 없어요."),
                  choice("D", "뷰의 조건이 부서번호 = 30으로 바뀐다", rationale="UPDATE는 뷰 정의를 바꾸지 않아요.")],
                 stem_sql="UPDATE 개발부사원 SET 부서번호 = 30 WHERE 사번 = 1005;"),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        sql_check("SELECT 이름, 급여 FROM 개발부사원", [["이지은", 2500], ["박서준", 2800], ["정하늘", 2500]],
                  setup=DEVELOPMENT_VIEW_SQL),
        # 기본 테이블 변경 > 뷰 결과에 바로 보임 (확인 문제 4)
        sql_check("SELECT 이름, 급여 FROM 개발부사원", [["이지은", 2500], ["박서준", 2800], ["정하늘", 2600]],
                  setup=DEVELOPMENT_VIEW_SQL + "\nUPDATE 사원 SET 급여 = 2600 WHERE 사번 = 1005;"),
        sql_check("SELECT 급여 FROM 개발부사원 WHERE 사번 = 1005;", [[2600]],
                  setup=DEVELOPMENT_VIEW_SQL + "\nUPDATE 사원 SET 급여 = 2600 WHERE 사번 = 1005;"),
        # 정의 바꾸기·지우기
        sql_check("SELECT * FROM 개발부사원",
                  [[1002, "이지은", "과장"], [1003, "박서준", "대리"], [1005, "정하늘", "사원"]],
                  setup="CREATE VIEW 개발부사원 AS SELECT 사번, 이름 FROM 사원 WHERE 부서번호 = 20;\n"
                        "CREATE OR REPLACE VIEW 개발부사원 AS SELECT 사번, 이름, 직급 FROM 사원 WHERE 부서번호 = 20;"),
        sql_error_check("CREATE VIEW 개발부사원 AS SELECT 사번, 이름, 직급 FROM 사원 WHERE 부서번호 = 20", "ORA-00955",
                        setup=DEVELOPMENT_VIEW_SQL),
        sql_error_check("ALTER VIEW 개발부사원 AS SELECT 사번, 이름, 직급 FROM 사원 WHERE 부서번호 = 20", "ORA-00922",
                        setup=DEVELOPMENT_VIEW_SQL),
        sql_error_check("ALTER TABLE 개발부사원 ADD (메모 VARCHAR2(10))", "ORA-00942", setup=DEVELOPMENT_VIEW_SQL),
        sql_check("SELECT COUNT(*) FROM 사원", [[8]], setup=DEVELOPMENT_VIEW_SQL + "\nDROP VIEW 개발부사원;"),
        sql_error_check("SELECT * FROM 개발부사원", "ORA-00942", setup=DEVELOPMENT_VIEW_SQL + "\nDROP VIEW 개발부사원;"),
        # 뷰 조회 <-> 같은 조건의 기본 테이블 조회 (같은 결과)
        sql_check("SELECT 이름 FROM 개발부사원 WHERE 급여 >= 2600", [["박서준"]], setup=DEVELOPMENT_VIEW_SQL),
        sql_check("SELECT 이름 FROM 사원 WHERE 부서번호 = 20 AND 급여 >= 2600", [["박서준"]]),
        # 보안성·인덱스
        sql_error_check("SELECT 급여 FROM 사원공개", "ORA-00904",
                        setup="CREATE VIEW 사원공개 AS SELECT 사번, 이름, 직급, 부서번호 FROM 사원;"),
        sql_error_check("CREATE INDEX 개발부사원_이름 ON 개발부사원 (이름)", "ORA-01702", setup=DEVELOPMENT_VIEW_SQL),
        # 뷰로 데이터 바꾸기 (단순 뷰 가능, 집계·DISTINCT·계산 열 불가)
        sql_check("SELECT 직급 FROM 사원 WHERE 사번 = 1003", [["과장"]],
                  setup="CREATE VIEW 개발부사원 AS SELECT 사번, 이름, 직급 FROM 사원 WHERE 부서번호 = 20;\n"
                        "UPDATE 개발부사원 SET 직급 = '과장' WHERE 사번 = 1003;"),
        sql_error_check("UPDATE 부서별급여 SET 급여합계 = 0 WHERE 부서번호 = 10", "ORA-01732",
                        setup="CREATE VIEW 부서별급여 AS SELECT 부서번호, SUM(급여) AS 급여합계 FROM 사원 GROUP BY 부서번호;"),
        sql_error_check("UPDATE 직급목록 SET 직급 = '주임' WHERE 직급 = '사원'", "ORA-01732",
                        setup="CREATE VIEW 직급목록 AS SELECT DISTINCT 직급 FROM 사원;"),
        sql_error_check("UPDATE 사원연봉 SET 연봉 = 0 WHERE 사번 = 1001", "ORA-01733",
                        setup="CREATE VIEW 사원연봉 AS SELECT 사번, 급여 * 12 AS 연봉 FROM 사원;"),
        # WITH CHECK OPTION (확인 문제 5)·WITH READ ONLY
        sql_error_check("UPDATE 개발부사원 SET 부서번호 = 30 WHERE 사번 = 1005;", "ORA-01402", setup=DEVELOPMENT_CHECK_VIEW_SQL),
        sql_check("SELECT 부서번호 FROM 사원 WHERE 사번 = 1005", [[20]],
                  setup=DEVELOPMENT_CHECK_VIEW_SQL + "\nUPDATE 개발부사원 SET 부서번호 = 30 WHERE 사번 = 1005; -- 오류"),
        sql_check("SELECT 이름 FROM 개발부사원", [["이지은"], ["박서준"], ["정하늘"], ["강하나"]],
                  setup=DEVELOPMENT_CHECK_VIEW_SQL + "\nINSERT INTO 개발부사원 VALUES (1009, '강하나', 20);"),
        sql_error_check("UPDATE 개발부조회 SET 이름 = '정하늘' WHERE 사번 = 1005", "ORA-42399",
                        setup="CREATE VIEW 개발부조회 AS SELECT 사번, 이름, 부서번호 FROM 사원 WHERE 부서번호 = 20 WITH READ ONLY;"),
        # 기본 테이블 삭제 > 뷰 사용 불가
        sql_error_check("SELECT * FROM 부서명목록", "ORA-04063",
                        setup="CREATE TABLE 부서사본 AS SELECT * FROM 부서;\n"
                              "CREATE VIEW 부서명목록 AS SELECT 부서명 FROM 부서사본;\nDROP TABLE 부서사본;"),
        # CHECK OPTION 없음: 조건 밖 변경도 통과, 뷰에서는 안 보임
        sql_check("SELECT 이름 FROM 개발부사원", [["이지은"], ["박서준"]],
                  setup="CREATE VIEW 개발부사원 AS SELECT 사번, 이름, 부서번호 FROM 사원 WHERE 부서번호 = 20;\n"
                        "UPDATE 개발부사원 SET 부서번호 = 30 WHERE 사번 = 1005;\n"
                        "INSERT INTO 개발부사원 VALUES (1009, '강하나', 30);"),
        sql_check("SELECT COUNT(*) FROM 사원", [[9]],
                  setup="CREATE VIEW 개발부사원 AS SELECT 사번, 이름, 부서번호 FROM 사원 WHERE 부서번호 = 20;\n"
                        "INSERT INTO 개발부사원 VALUES (1009, '강하나', 30);"),
    ],
}
