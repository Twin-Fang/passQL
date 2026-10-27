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
        "- 뷰는 SELECT 문에 이름을 붙여 저장해 둔 가상 테이블이라서 데이터를 따로 저장하지 않고, 조회할 때마다 기본 테이블에서 읽어 와요.\n"
        "- 만들 때는 `CREATE VIEW`, 정의를 바꿀 때는 `CREATE OR REPLACE VIEW`, 지울 때는 `DROP VIEW`를 쓰고, `ALTER VIEW`로는 정의를 바꿀 수 없어요.\n"
        "- 장점은 독립성·편리성·보안성이고, 뷰에는 인덱스를 만들 수 없으며 집계나 DISTINCT가 들어간 뷰로는 데이터를 바꿀 수 없어요.\n"
        "- `WITH CHECK OPTION`은 뷰 조건을 벗어나는 변경을 막고, `WITH READ ONLY`는 뷰를 통한 변경을 모두 막아요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

개발부(20번) 사원 목록을 매일 확인하는 사람이 있다면, 그 사람은 매번 `SELECT 사번, 이름, 급여 FROM 사원 WHERE 부서번호 = 20`을 다시 적어야 해요. 조건이 길어지거나 조인이 들어가면 같은 SQL을 여러 사람이 각자 적다가 조건을 틀리기도 하고요.

사원 표를 다른 팀에 보여 줘야 하는데 급여와 커미션은 숨기고 싶은 경우도 있어요. 테이블을 통째로 열어 주면 숨길 방법이 없으니, 보여 줄 열만 고른 SELECT 문을 따로 준비해서 그것만 쓰게 하는 편이 안전해요. 이렇게 자주 쓰는 SELECT 문에 이름을 붙여 데이터베이스에 저장해 두는 것이 뷰예요.

이 글의 예시는 모두 아래 사원 표와 부서 표로 계산해요.

{EMPLOYEE_TABLE}

{DEPARTMENT_TABLE_MD}

## 한 줄 정의 {{#definition}}

뷰(View)는 SELECT 문에 이름을 붙여 저장해 둔 가상 테이블이에요. 뷰가 읽어 오는 원래 테이블은 기본 테이블(Base Table)이라고 불러요. 뷰를 조회하면 테이블처럼 행과 열이 나오지만, 뷰 자체에는 데이터가 없고 조회할 때마다 저장된 SELECT 문을 실행해서 기본 테이블에서 값을 가져와요.

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

뷰가 데이터를 따로 저장하지 않는다는 것은 기본 테이블을 고쳐 보면 바로 드러나요. 아래에서는 뷰를 건드리지 않고 사원 테이블에서 정하늘의 급여만 2600으로 고쳤는데, 뷰를 다시 조회하면 정하늘의 급여가 2600으로 보여요.

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름, 급여 FROM 사원 WHERE 부서번호 = 20;

UPDATE 사원 SET 급여 = 2600 WHERE 사번 = 1005;  -- 기본 테이블만 고쳐요
SELECT 이름, 급여 FROM 개발부사원;               -- 정하늘의 급여가 2600으로 보여요
```

FROM 절에 쓰는 인라인 뷰는 그 SQL 안에서만 쓰고 사라지지만, `CREATE VIEW`로 만든 뷰는 이름과 함께 데이터베이스에 남아서 권한만 있으면 누구든 다시 쓸 수 있어요.

## 만들고, 바꾸고, 지우기 {{#create-replace-drop}}

뷰를 다루는 명령은 `CREATE VIEW`, `CREATE OR REPLACE VIEW`, `DROP VIEW` 세 가지예요. 이미 있는 이름으로 `CREATE VIEW`를 다시 실행하면 ORA-00955(이미 쓰고 있는 이름) 오류가 나고, 정의를 바꿀 때는 `CREATE OR REPLACE VIEW`로 같은 이름의 뷰를 새 정의로 덮어써요.

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

뷰를 지우면 저장해 둔 SELECT 문만 사라지고, 뷰가 보여 주던 사원 데이터는 사원 테이블에 그대로 남아요.

## 장점과 한계 {{#pros-cons}}

뷰의 장점은 보통 아래 세 가지로 정리해요.

| 장점 | 뜻 |
|---|---|
| 독립성 | 기본 테이블의 구조가 바뀌어도 뷰 정의만 고치면, 뷰를 쓰던 프로그램과 SQL은 그대로 둘 수 있어요 |
| 편리성 | 복잡한 조인과 조건을 뷰로 만들어 두면 짧은 SELECT 문으로 같은 결과를 얻어요 |
| 보안성 | 숨기고 싶은 열이나 행을 뺀 뷰만 보여 주면, 사용자가 그 데이터를 볼 수 없어요 |

보안성은 급여를 뺀 뷰를 만들어 보면 이해하기 쉬워요. 실제로는 사원 테이블을 조회할 권한은 주지 않고 이 뷰를 조회할 권한만 줘요. 권한을 주는 명령은 GRANT인데, 사용자에게 어떤 테이블이나 뷰를 조회·변경할 수 있게 허락하는 명령이고 3단원에서 다뤄요.

```sql
CREATE VIEW 사원공개 AS
SELECT 사번, 이름, 직급, 부서번호 FROM 사원;

SELECT 급여 FROM 사원공개;  -- 오류: 뷰에 급여 열이 없어요
```

뷰에 없는 열을 부르면 ORA-00904(없는 열 이름) 오류가 나서, 이 뷰만 쓰는 사람은 급여를 볼 수 없어요.

한계도 함께 나와요. 뷰에는 따로 인덱스(조회를 빠르게 하려고 만드는 색인)를 만들 수 없고, 정의를 ALTER로 고칠 수 없어서 `CREATE OR REPLACE`로 다시 만들어야 해요. 그리고 뷰의 모양에 따라 뷰를 통한 INSERT, UPDATE, DELETE가 막히기도 해요.

## 뷰로 데이터 바꾸기 {{#view-dml}}

테이블 하나에서 집계 없이 열과 행만 고른 단순한 뷰는 뷰를 통해 데이터를 바꿀 수 있어요. 뷰에는 데이터가 없으니 이때 바뀌는 것은 기본 테이블이에요.

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름, 직급 FROM 사원 WHERE 부서번호 = 20;

UPDATE 개발부사원 SET 직급 = '과장' WHERE 사번 = 1003;
SELECT 직급 FROM 사원 WHERE 사번 = 1003;  -- 기본 테이블에서도 과장으로 바뀌었어요
```

GROUP BY나 집계 함수(SUM처럼 여러 행을 모아 값 하나를 계산하는 함수), 중복을 없애는 DISTINCT가 들어간 뷰는 뷰의 한 행이 기본 테이블의 어느 행인지 정할 수 없어요. 그래서 이런 뷰로는 데이터를 바꿀 수 없고, ORA-01732(이 뷰에는 데이터 변경을 할 수 없음) 오류가 나요. 계산식으로 만든 열도 기본 테이블에 그런 열이 없으니 고칠 수 없어서, ORA-01733(가상 열은 바꿀 수 없음) 오류가 나요.

```sql
CREATE VIEW 부서별급여 AS
SELECT 부서번호, SUM(급여) AS 급여합계 FROM 사원 GROUP BY 부서번호;

UPDATE 부서별급여 SET 급여합계 = 0 WHERE 부서번호 = 10;  -- 오류: 집계한 뷰는 바꿀 수 없어요

CREATE VIEW 사원연봉 AS
SELECT 사번, 급여 * 12 AS 연봉 FROM 사원;

UPDATE 사원연봉 SET 연봉 = 0 WHERE 사번 = 1001;  -- 오류: 계산한 열은 바꿀 수 없어요
```

## WITH CHECK OPTION과 WITH READ ONLY {{#check-option}}

뷰를 만들 때 맨 끝에 옵션을 붙여 뷰를 통한 변경을 제한할 수 있어요. `WITH CHECK OPTION`은 뷰의 WHERE 조건을 벗어나게 만드는 INSERT와 UPDATE를 막아요. 개발부 뷰에 이 옵션을 붙이면, 뷰를 통해 사원을 다른 부서로 옮기거나 다른 부서 사원을 넣으려 할 때 ORA-01402(WITH CHECK OPTION 조건 위반) 오류가 나요.

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

`WITH READ ONLY`는 뷰를 읽기 전용으로 만들어서, 뷰를 통한 INSERT, UPDATE, DELETE를 조건과 상관없이 모두 막아요. 이때는 ORA-42399(읽기 전용 뷰에는 데이터 변경을 할 수 없음) 오류가 나요.

```sql
CREATE VIEW 개발부조회 AS
SELECT 사번, 이름, 부서번호 FROM 사원 WHERE 부서번호 = 20
WITH READ ONLY;

UPDATE 개발부조회 SET 이름 = '정하늘' WHERE 사번 = 1005;  -- 오류: 읽기 전용 뷰예요
```

## 자주 헷갈리는 점 {{#confusing}}

**뷰는 데이터를 저장하지 않아요.** 그래서 무엇을 지우느냐에 따라 남는 것이 달라져요. 두 경우를 나란히 놓으면 아래와 같아요.

| 지운 것 | 뷰 | 사원 데이터 |
|---|---|---|
| 뷰 (`DROP VIEW`) | 사라져요 | 기본 테이블에 그대로 남아요 |
| 기본 테이블 (`DROP TABLE`) | 이름은 남지만 조회하면 오류가 나요 | 테이블과 함께 사라져요 |

뷰를 지울 때는 저장된 SELECT 문만 없어지니 데이터에는 아무 일도 없어요. 기본 테이블을 지울 때는 데이터가 사라지고, 뷰는 읽어 올 곳이 없어져서 조회하면 ORA-04063(뷰에 오류가 있음) 오류가 나요. 조회 결과를 미리 저장해 두는 것으로 오해하면 이 두 경우를 거꾸로 고르게 돼요.

```sql
CREATE TABLE 부서사본 AS SELECT * FROM 부서;
CREATE VIEW 부서명목록 AS SELECT 부서명 FROM 부서사본;

DROP TABLE 부서사본;
SELECT * FROM 부서명목록;  -- 오류: 기본 테이블이 없어서 뷰를 쓸 수 없어요
```

**ALTER VIEW로는 뷰의 SELECT 문을 바꿀 수 없어요.** Oracle에 ALTER VIEW 명령이 있기는 하지만, 뷰를 다시 점검해서 쓸 수 있는 상태로 만드는 관리용 명령이라 정의를 바꾸는 데는 쓰지 못해요. `ALTER VIEW ... AS SELECT ...`처럼 쓰면 ORA-00922(없거나 잘못된 옵션) 오류가 나요.

뷰는 테이블이 아니라서 ALTER TABLE로 열을 더할 수도 없어요. ALTER TABLE은 테이블만 고치는 명령이라, 뷰 이름을 넣으면 그런 테이블이 없다는 ORA-00942(테이블이나 뷰가 없음) 오류가 나요. 정의를 바꾸려면 `CREATE OR REPLACE VIEW`를 쓰거나, DROP VIEW로 지운 뒤 다시 만들어야 해요.

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름 FROM 사원 WHERE 부서번호 = 20;

ALTER VIEW 개발부사원 AS
SELECT 사번, 이름, 직급 FROM 사원 WHERE 부서번호 = 20;  -- 오류: ALTER VIEW로는 정의를 못 바꿔요

ALTER TABLE 개발부사원 ADD (메모 VARCHAR2(10));  -- 오류: 뷰는 ALTER TABLE 대상이 아니에요
```

**뷰에는 인덱스를 만들 수 없어요.** 뷰에 `CREATE INDEX`를 실행하면 ORA-01702(뷰는 이 자리에 쓸 수 없음) 오류가 나요. 뷰를 조회할 때는 기본 테이블에 만든 인덱스가 쓰이므로, 속도가 문제라면 기본 테이블 쪽에 인덱스를 만들어요.

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름 FROM 사원 WHERE 부서번호 = 20;

CREATE INDEX 개발부사원_이름 ON 개발부사원 (이름);  -- 오류: 뷰에는 인덱스를 만들 수 없어요
```

**WITH CHECK OPTION이 없으면 뷰에서 사라지는 변경도 그대로 통과해요.** 옵션 없이 만든 개발부 뷰에서 정하늘의 부서를 30으로 바꾸면 오류 없이 바뀌고, 정하늘은 더 이상 개발부가 아니라서 뷰에서 사라져요. 30번 부서 사원을 뷰로 INSERT하는 것도 성공하지만, 넣은 행은 뷰에서 보이지 않아요.

```sql
CREATE VIEW 개발부사원 AS
SELECT 사번, 이름, 부서번호 FROM 사원 WHERE 부서번호 = 20;

UPDATE 개발부사원 SET 부서번호 = 30 WHERE 사번 = 1005;  -- 그대로 바뀌어요
INSERT INTO 개발부사원 VALUES (1009, '강하나', 30);       -- 그대로 들어가요
SELECT 이름 FROM 개발부사원;  -- 30번이 된 정하늘과 강하나는 보이지 않아요
SELECT COUNT(*) FROM 사원;     -- 강하나가 더해져 9명이에요
```

이 블록의 뷰 조회 결과는 이지은과 박서준 두 명뿐이고, 기본 테이블에는 강하나가 들어가서 사원이 9명이 돼요.

**CHECK OPTION과 READ ONLY가 막는 범위가 달라요.** WITH CHECK OPTION은 조건 안에서의 변경은 허용하므로, 개발부 사원끼리 이름을 고치거나 20번 부서 사원을 새로 넣는 것은 돼요. WITH READ ONLY는 조건과 상관없이 모든 변경을 막아요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

뷰의 특징으로 옳지 않은 것을 고르는 문제가 가장 흔하고, "뷰는 데이터를 저장한다", "ALTER VIEW로 정의를 바꿀 수 있다", "뷰에 인덱스를 만들 수 있다" 같은 보기가 정답으로 자주 나와요. 독립성, 편리성, 보안성을 장점으로 고르는 문제와, 뷰를 통한 UPDATE가 WITH CHECK OPTION 때문에 실패하는지 묻는 문제도 나와요.""",
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
                 "뷰의 장점은 독립성, 편리성, 보안성이에요. 뷰에는 인덱스를 만들 수 없어서, 뷰에 인덱스를 만들어 속도를 높인다는 설명은 틀렸어요.",
                 [choice("A", "기본 테이블 구조가 바뀌어도 뷰 정의만 고치면 뷰를 쓰는 SQL은 그대로 둘 수 있다", rationale="독립성이라는 장점이에요."),
                  choice("B", "복잡한 조인과 조건을 짧은 SELECT 문으로 쓸 수 있다", rationale="편리성이라는 장점이에요."),
                  choice("C", "숨기고 싶은 열을 뺀 뷰만 보여 줄 수 있다", rationale="보안성이라는 장점이에요."),
                  choice("D", "뷰에 인덱스를 따로 만들어 조회 속도를 높일 수 있다", True, "뷰에는 인덱스를 만들 수 없어서 장점이 아니에요.")]),
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
        # 보안성·인덱스
        sql_error_check("SELECT 급여 FROM 사원공개", "ORA-00904",
                        setup="CREATE VIEW 사원공개 AS SELECT 사번, 이름, 직급, 부서번호 FROM 사원;"),
        sql_error_check("CREATE INDEX 개발부사원_이름 ON 개발부사원 (이름)", "ORA-01702", setup=DEVELOPMENT_VIEW_SQL),
        # 뷰로 데이터 바꾸기 (단순 뷰 가능, 집계·계산 열 불가)
        sql_check("SELECT 직급 FROM 사원 WHERE 사번 = 1003", [["과장"]],
                  setup="CREATE VIEW 개발부사원 AS SELECT 사번, 이름, 직급 FROM 사원 WHERE 부서번호 = 20;\n"
                        "UPDATE 개발부사원 SET 직급 = '과장' WHERE 사번 = 1003;"),
        sql_error_check("UPDATE 부서별급여 SET 급여합계 = 0 WHERE 부서번호 = 10", "ORA-01732",
                        setup="CREATE VIEW 부서별급여 AS SELECT 부서번호, SUM(급여) AS 급여합계 FROM 사원 GROUP BY 부서번호;"),
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
