"""개념: MERGE (3단원, 확인 문제 5개)"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import to_employee_table_md

# 대상 사원 8명 (예시·확인 문제의 행 수와 급여 계산용)
MERGE_TARGET_EMPLOYEE_TABLE = to_employee_table_md("사번", "이름", "급여", "부서번호")

# 블록 안에서 만드는 변경 표: 기존 사원 2명(1002·1007) + 새 사원 1명(1009)
SALARY_CHANGE_SETUP = (
    "CREATE TABLE 급여변경 (사번 NUMBER(4), 이름 VARCHAR2(20), 새급여 NUMBER(5));\n"
    "INSERT INTO 급여변경 VALUES (1002, '이지은', 2700);\n"
    "INSERT INTO 급여변경 VALUES (1007, '오지민', 2400);\n"
    "INSERT INTO 급여변경 VALUES (1009, '강하준', 2100);"
)
BASIC_MERGE_SQL = (
    "MERGE INTO 사원 t\n"
    "USING 급여변경 s\n"
    "ON (t.사번 = s.사번)\n"
    "WHEN MATCHED THEN\n"
    "  UPDATE SET t.급여 = s.새급여\n"
    "WHEN NOT MATCHED THEN\n"
    "  INSERT (사번, 이름, 급여) VALUES (s.사번, s.이름, s.새급여);"
)
INSERT_ONLY_MERGE_SQL = (
    "MERGE INTO 사원 t\n"
    "USING 급여변경 s\n"
    "ON (t.사번 = s.사번)\n"
    "WHEN NOT MATCHED THEN\n"
    "  INSERT (사번, 이름, 급여) VALUES (s.사번, s.이름, s.새급여);"
)
# DELETE WHERE 예시: 1002 는 갱신 후 2700 이라 남고, 1007 은 2100 이라 지워짐
DELETE_WHERE_SETUP = (
    "CREATE TABLE 급여변경 (사번 NUMBER(4), 이름 VARCHAR2(20), 새급여 NUMBER(5));\n"
    "INSERT INTO 급여변경 VALUES (1002, '이지은', 2700);\n"
    "INSERT INTO 급여변경 VALUES (1007, '오지민', 2100);"
)
DELETE_WHERE_MERGE_SQL = (
    "MERGE INTO 사원 t\n"
    "USING 급여변경 s\n"
    "ON (t.사번 = s.사번)\n"
    "WHEN MATCHED THEN\n"
    "  UPDATE SET t.급여 = s.새급여\n"
    "  DELETE WHERE t.급여 < 2600;"
)
SUBQUERY_MERGE_SETUP = (
    "CREATE TABLE 사원보관 (사번 NUMBER(4), 이름 VARCHAR2(20), 급여 NUMBER(5));\n"
    "INSERT INTO 사원보관 VALUES (1002, '이지은', 2000);"
)
SUBQUERY_MERGE_SQL = (
    "MERGE INTO 사원보관 t\n"
    "USING (SELECT 사번, 이름, 급여 FROM 사원 WHERE 부서번호 = 20) s\n"
    "ON (t.사번 = s.사번)\n"
    "WHEN MATCHED THEN\n"
    "  UPDATE SET t.급여 = s.급여\n"
    "WHEN NOT MATCHED THEN\n"
    "  INSERT (사번, 이름, 급여) VALUES (s.사번, s.이름, s.급여);"
)
# 본문 예시 4개 (SQL 블록 + 결과 표 = 검증 항목)
BASIC_MERGE_EXAMPLE = sql_example(
    SALARY_CHANGE_SETUP + "\n" + BASIC_MERGE_SQL + "\nSELECT 사번, 이름, 급여 FROM 사원 WHERE 사번 IN (1002, 1007, 1009) ORDER BY 사번;",
    ("사번", "이름", "급여"), [(1002, "이지은", 2700), (1007, "오지민", 2400), (1009, "강하준", 2100)])
INSERT_ONLY_MERGE_EXAMPLE = sql_example(
    SALARY_CHANGE_SETUP + "\n" + INSERT_ONLY_MERGE_SQL + "\nSELECT 사번, 급여 FROM 사원 WHERE 사번 IN (1002, 1009) ORDER BY 사번;",
    ("사번", "급여"), [(1002, 2500), (1009, 2100)])
DELETE_WHERE_EXAMPLE = sql_example(
    DELETE_WHERE_SETUP + "\n" + DELETE_WHERE_MERGE_SQL + "\nSELECT 사번, 급여 FROM 사원 WHERE 사번 IN (1002, 1005, 1007, 1008) ORDER BY 사번;",
    ("사번", "급여"), [(1002, 2700), (1005, 2500), (1008, 2000)])
SUBQUERY_MERGE_EXAMPLE = sql_example(
    SUBQUERY_MERGE_SETUP + "\n" + SUBQUERY_MERGE_SQL + "\nSELECT 사번, 급여 FROM 사원보관 ORDER BY 사번;",
    ("사번", "급여"), [(1002, 2500), (1003, 2800), (1005, 2500)])

DELETE_WHERE_STEM_SQL = (
    "CREATE TABLE 급여변경 (사번 NUMBER(4), 이름 VARCHAR2(20), 새급여 NUMBER(5));\n"
    "INSERT INTO 급여변경 VALUES (1003, '박서준', 2600);\n"
    "INSERT INTO 급여변경 VALUES (1006, '한도윤', 2200);\n"
    "INSERT INTO 급여변경 VALUES (1009, '강하준', 2000);\n"
    "MERGE INTO 사원 t\n"
    "USING 급여변경 s\n"
    "ON (t.사번 = s.사번)\n"
    "WHEN MATCHED THEN\n"
    "  UPDATE SET t.급여 = s.새급여\n"
    "  DELETE WHERE t.급여 < 2300\n"
    "WHEN NOT MATCHED THEN\n"
    "  INSERT (사번, 이름, 급여) VALUES (s.사번, s.이름, s.새급여);\n"
    "SELECT COUNT(*) FROM 사원;"
)
ON_COLUMN_UPDATE_STEM_SQL = (
    "CREATE TABLE 급여변경 (사번 NUMBER(4), 이름 VARCHAR2(20), 새급여 NUMBER(5));\n"
    "INSERT INTO 급여변경 VALUES (1002, '이지은', 2700);\n"
    "MERGE INTO 사원 t\n"
    "USING 급여변경 s\n"
    "ON (t.사번 = s.사번)\n"
    "WHEN MATCHED THEN\n"
    "  UPDATE SET t.사번 = s.사번, t.급여 = s.새급여;"
)

# 본문 예시: MATCHED 절 끝 WHERE (새 급여가 더 높을 때만)
MATCHED_WHERE_EXAMPLE = sql_example(
    "CREATE TABLE 급여변경 (사번 NUMBER(4), 이름 VARCHAR2(20), 새급여 NUMBER(5));\n"
    "INSERT INTO 급여변경 VALUES (1002, '이지은', 2400);\n"
    "INSERT INTO 급여변경 VALUES (1007, '오지민', 2400);\n"
    "MERGE INTO 사원 t\n"
    "USING 급여변경 s\n"
    "ON (t.사번 = s.사번)\n"
    "WHEN MATCHED THEN\n"
    "  UPDATE SET t.급여 = s.새급여 WHERE s.새급여 > t.급여;\n"
    "SELECT 사번, 급여 FROM 사원 WHERE 사번 IN (1002, 1007) ORDER BY 사번;",
    ('사번', '급여'), [(1002, 2500), (1007, 2400)])

CONCEPT = {
    "tagKey": "dml-merge",
    "topicCode": "sql_ddl_dml_tcl",
    "sortOrder": 5,
    "title": "MERGE",
    "summary": "짝이 되는 행이 있으면 고치고, 없으면 새로 넣는 일을 한 문장으로 해요",
    "coreMd": (
        "- MERGE는 원본 행마다 ON으로 짝을 찾아, **있으면 UPDATE하고 없으면 INSERT**해요.\n"
        "- Oracle에서는 ON 조건을 **괄호**로 감싸고, ON에 쓴 열은 UPDATE할 수 없어요.\n"
        "- 두 WHEN 절 가운데 **하나만 써도** 되고, USING에는 테이블·뷰·서브쿼리를 쓸 수 있어요.\n"
        "- UPDATE 뒤의 `DELETE WHERE`는 **이번에 UPDATE된 행만**, 고친 뒤의 값으로 따져 지워요."
    ),
    "detailMd": f"""## 왜 MERGE일까요 — 고칠 행과 넣을 행이 섞여 있을 때 {{#why}}

인사팀이 이번 달 급여 변경 목록을 보내왔어요. 이미 있는 사원 두 명의 새 급여와, 새로 들어온 사원 한 명이 섞여 있어요.

| 사번 | 이름 | 새급여 |
|---|---|---|
| 1002 | 이지은 | 2700 |
| 1007 | 오지민 | 2400 |
| 1009 | 강하준 | 2100 |

사원 표는 공통 예시 데이터의 8명이고 지금 급여는 아래와 같아요. 1009번 사원은 아직 없어요.

{MERGE_TARGET_EMPLOYEE_TABLE}

UPDATE와 INSERT로 나눠 하려면 어떤 사원이 이미 있는지부터 가려내야 해서 번거로워요. MERGE는 "짝이 있으면 고치고, 없으면 넣는다"를 한 문장으로 처리하고, 이런 동작을 업서트(upsert, update와 insert를 합친 말)라고도 불러요.

## 문법 — INTO는 대상, USING은 원본, ON은 짝 찾기 {{#definition}}

```sql
-- 문법
MERGE INTO 대상테이블 별칭
USING 원본 별칭
ON (짝을 찾는 조건)
WHEN MATCHED THEN
  UPDATE SET 열 = 값, ...
WHEN NOT MATCHED THEN
  INSERT (열, ...) VALUES (값, ...);
```

| 단계 | 내용 |
|---|---|
| INTO | 실제로 바뀌는 대상 테이블을 정해요 |
| USING | 바꿀 내용을 가진 원본을 정해요. 테이블, 뷰(저장해 둔 SELECT 문), 서브쿼리(괄호로 감싼 SELECT) 모두 돼요 |
| ON | 원본 행마다 대상에서 짝을 찾는 조건이에요. Oracle에서는 괄호로 감싸요 |
| WHEN MATCHED | 짝을 찾은 원본 행이에요. UPDATE를 실행해요 |
| WHEN NOT MATCHED | 짝을 못 찾은 원본 행이에요. INSERT를 실행해요 |

별칭 t와 s는 대상과 원본을 짧게 부르려고 붙인 이름이고, 뷰와 서브쿼리는 서브쿼리 단원에서 자세히 다뤄요. 대상은 INTO에서 이미 정해졌으니, WHEN 절 안에는 `UPDATE SET ...`, `INSERT (열) VALUES (...)`처럼 테이블 이름 없이 적어요.

## 예시 — 둘은 고치고 하나는 넣어요 {{#example}}

{BASIC_MERGE_EXAMPLE.markdown}

1002와 1007은 사원 표에 같은 사번이 있어서 MATCHED가 되고 급여가 새 값으로 바뀌었어요. 1009는 짝이 없어서 NOT MATCHED가 되고 새 행으로 들어갔어요.

원본에 없는 1001 같은 사원은 아무 영향도 받지 않아요. 그래서 `COUNT(*)`(행의 개수를 세는 함수)로 세어 보면 사원은 8명에서 9명으로 늘어나요.

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| 원본 목록에 없는 1001 김민수는 MERGE로 지워져요 | X | 원본에 없는 대상 행은 짝 찾기에 쓰이지 않아서 그대로 남아요 |

## 한쪽 절만 쓰기와 조건 붙이기 — 필요한 동작만 골라요 {{#one-clause}}

WHEN MATCHED와 WHEN NOT MATCHED는 둘 다 써도 되고 하나만 써도 돼요. 새 사원만 넣고 기존 사원의 급여는 건드리지 않으려면 NOT MATCHED 절만 써요.

{INSERT_ONLY_MERGE_EXAMPLE.markdown}

1002는 MATCHED지만 MATCHED 절이 없어서 급여가 2500 그대로 남고, 1009만 새로 들어갔어요. 각 절 끝에 WHERE를 붙이면 조건에 맞을 때만 그 동작을 하는데, 아래는 새 급여가 지금보다 높을 때만 고치는 예시예요.

{MATCHED_WHERE_EXAMPLE.markdown}

이지은은 새 급여 2400이 지금 급여 2500보다 낮아서 바뀌지 않았어요. 오지민은 2200에서 2400으로 바뀌었어요.

## DELETE WHERE — 방금 고친 행만, 고친 뒤 값으로 {{#delete-where}}

Oracle은 WHEN MATCHED의 UPDATE 뒤에 `DELETE WHERE 조건`을 붙일 수 있어요. 아래 원본은 이지은(1002)의 새 급여 2700과 오지민(1007)의 새 급여 2100이고, 지우는 조건은 `급여 < 2600`이에요.

{DELETE_WHERE_EXAMPLE.markdown}

1007만 결과에서 사라졌어요. 네 사람이 거친 단계를 따라가면 이유가 보여요.

| 사원 | 원본에 있나 | UPDATE 전 급여 | UPDATE 후 급여 | 급여 < 2600 | 결과 |
|---|---|---|---|---|---|
| 이지은(1002) | 있어요 | 2500 | 2700 | 거짓 | 남아요 |
| 오지민(1007) | 있어요 | 2200 | 2100 | 참 | 지워져요 |
| 정하늘(1005) | 없어요 | 2500 | 바뀌지 않아요 | 따지지 않아요 | 남아요 |
| 윤서연(1008) | 없어요 | 2000 | 바뀌지 않아요 | 따지지 않아요 | 남아요 |

| 헷갈리는 말 | 실제로는 |
|---|---|
| DELETE WHERE는 고치기 전의 값으로 판단해요 | 고친 뒤의 값으로 판단해요. 이지은은 고치기 전 2500으로 따졌다면 지워졌겠지만, 고친 뒤 2700이라 남았어요 |
| DELETE WHERE는 대상 테이블에서 조건에 맞는 행을 모두 지워요 | 이번에 UPDATE된 행에만 적용돼요. 정하늘과 윤서연은 2600보다 작아도 UPDATE되지 않아서 남아요 |
| `WHEN MATCHED THEN DELETE`처럼 DELETE만 쓸 수 있어요 | DELETE WHERE는 UPDATE 절에 딸린 문법이라 UPDATE 없이 쓰면 Oracle에서는 오류가 나요 |
| 같은 MERGE에서 새로 넣은 행도 DELETE WHERE로 지워질 수 있어요 | WHEN NOT MATCHED로 새로 넣은 행은 UPDATE된 행이 아니라서 지워지지 않아요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| UPDATE 뒤 급여가 조건에 맞게 바뀐 행은 DELETE WHERE로 지워질 수 있어요 | O | 오지민처럼 고친 뒤 값이 조건에 맞으면 그 행이 지워져요 |

## USING에 서브쿼리 쓰기 — 원본 표가 없어도 돼요 {{#using-subquery}}

USING 뒤에 서브쿼리를 괄호로 감싸 쓰고 별칭을 붙이면 원본처럼 쓸 수 있어요. 아래는 이지은의 옛 급여 2000만 들어 있는 보관용 표에, 20번 부서 사원의 최신 급여를 맞춰 넣는 예시예요.

{SUBQUERY_MERGE_EXAMPLE.markdown}

이지은은 짝이 있어서 2500으로 고쳐졌어요. 보관용 표에 없던 박서준과 정하늘은 새로 들어갔어요.

## 자주 헷갈리는 점 — 괄호, ON 열, WHEN 절 모양 {{#confusing}}

| 헷갈리는 말 | 실제로는 |
|---|---|
| ON 조건은 JOIN처럼 괄호 없이 써도 돼요 | Oracle MERGE에서는 `ON t.사번 = s.사번`처럼 괄호 없이 쓰면 오류(ORA-00969, ON 절 괄호 누락)가 나요. 조인 단원의 JOIN ON은 괄호가 없어도 돼서 자주 섞여요 |
| ON에 쓴 열도 UPDATE SET에서 고칠 수 있어요 | 짝을 찾는 기준이 흔들리기 때문에 `UPDATE SET t.사번 = ...`은 오류(ORA-38104, ON 절의 열은 수정 불가)가 나요. 다른 열만 고치면 문제없어요 |
| WHEN 절 안에도 평소처럼 `UPDATE 사원 SET`, `INSERT INTO 사원`으로 써요 | 테이블 이름을 넣으면 ORA-00971(SET 키워드 누락)이나 ORA-00926(VALUES 키워드 누락) 오류가 나요 |
| MERGE의 INSERT는 열 목록을 꼭 적어야 해요 | 생략하고 `INSERT VALUES (...)`로 써도 돼요. 다만 일반 INSERT처럼 대상의 모든 열에 정의 순서대로 값을 적어야 해요 |
| 원본에 같은 사번이 두 번 있어도 마지막 값으로 고쳐져요 | 대상의 한 행을 두 번 고치게 되어 오류(ORA-30926, 원본 행이 하나로 정해지지 않음)가 나요 |
| MERGE는 DDL이라 자동으로 확정돼요 | MERGE는 DML이라 COMMIT 전에는 ROLLBACK으로 되돌릴 수 있어요 |
| SQL Server의 MERGE도 Oracle과 똑같아요 | SQL Server는 문장 끝 세미콜론이 꼭 필요하고, 원본에 없는 대상 행을 처리하는 `WHEN NOT MATCHED BY SOURCE` 절도 쓸 수 있어요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| MERGE를 실행하면 USING의 원본 표도 함께 바뀌어요 | X | 바뀌는 쪽은 INTO 뒤의 대상뿐이고, 원본은 읽기만 해요 |

## 꼭 외울 것 — 짝이 있으면 UPDATE, 없으면 INSERT {{#memorize}}

| 외울 것 | 답 |
|---|---|
| MERGE 문법 순서 | INTO 대상 → USING 원본 → ON (조건) → WHEN 절 |
| 짝이 있을 때와 없을 때 | MATCHED는 UPDATE, NOT MATCHED는 INSERT |
| Oracle ON 조건의 괄호 | 꼭 감싸요 (없으면 오류) |
| ON에 쓴 열 | UPDATE SET으로 고칠 수 없어요 |
| WHEN 절 개수 | 둘 중 하나만 써도 돼요 |
| USING에 올 수 있는 것 | 테이블, 뷰, 서브쿼리 |
| DELETE WHERE의 대상 | 이번에 UPDATE된 행만, 고친 뒤 값으로 판단 |
| MERGE의 분류 | DML (COMMIT 전 ROLLBACK 가능) |

## 시험에서는 이렇게 나와요 {{#exam-point}}

대상 표와 원본 표를 주고 MERGE 뒤의 행 수나 특정 행의 값을 묻는 문제가 가장 많아요. 원본 행마다 MATCHED인지 NOT MATCHED인지 표시하고, DELETE WHERE가 있으면 UPDATE된 행에만 고친 뒤 값으로 조건을 따지면 돼요.

문법 문제에서는 ON의 괄호, ON 열 UPDATE 금지, 한쪽 절만 쓸 수 있다는 점이 보기로 나와요.""",
    "checkQuestions": [
        question(1, "대상 테이블에 짝이 되는 행이 있으면 수정하고, 없으면 새로 넣는 일을 한 문장으로 처리하는 명령어는 무엇인가요?", "why",
                 "MERGE는 ON 조건으로 짝을 찾아 있으면 UPDATE, 없으면 INSERT를 한 문장으로 실행해요.",
                 [choice("A", "UPDATE", rationale="UPDATE는 이미 있는 행을 고치기만 하고 새 행을 넣지 않아요."),
                  choice("B", "INSERT ... SELECT", rationale="조회 결과를 넣기만 하고 이미 있는 행을 고치지 않아요."),
                  choice("C", "MERGE", True, "수정과 입력을 한 문장으로 처리해요."),
                  choice("D", "TRUNCATE", rationale="TRUNCATE는 모든 행을 지우는 DDL이에요.")]),
        question(2, "MERGE에서 원본의 행이 ON 조건으로 대상 테이블의 어떤 행과도 짝지어지지 않으면 어떤 절이 실행되나요?", "definition",
                 "짝을 찾으면 MATCHED, 못 찾으면 NOT MATCHED가 돼요. 짝이 없는 원본 행은 WHEN NOT MATCHED의 INSERT로 새로 들어가요.",
                 [choice("A", "WHEN MATCHED THEN UPDATE", rationale="대상에 짝이 있을 때 실행되는 절이에요."),
                  choice("B", "WHEN NOT MATCHED THEN INSERT", True, "짝이 없는 원본 행을 대상에 새로 넣어요."),
                  choice("C", "UPDATE 뒤의 DELETE WHERE", rationale="DELETE WHERE는 MATCHED로 UPDATE된 행에만 적용돼요."),
                  choice("D", "원본 행이 지워진다", rationale="MERGE는 USING의 원본을 바꾸지 않아요.")]),
        question(3, "공통 예시 데이터(사원 8명)에서 다음 SQL을 차례로 실행하면 마지막 결과는 무엇인가요?", "example",
                 "1002와 1007은 짝이 있어서 급여만 바뀌고, 짝이 없는 1009는 새로 들어가요. 그래서 사원은 9명이 돼요.",
                 [choice("A", "9", True, "UPDATE 2건, INSERT 1건이라 한 명이 늘어요."),
                  choice("B", "8", rationale="짝이 없는 1009가 WHEN NOT MATCHED로 새로 들어가요."),
                  choice("C", "11", rationale="짝이 있는 1002와 1007은 새로 들어가지 않고 급여만 바뀌어요."),
                  choice("D", "3", rationale="원본에 없는 기존 사원은 지워지지 않고 그대로 남아요.")],
                 stem_sql=SALARY_CHANGE_SETUP + "\n" + BASIC_MERGE_SQL + "\nSELECT COUNT(*) FROM 사원;"),
        question(4, "공통 예시 데이터(사원 8명)에서 다음 SQL을 차례로 실행하면 마지막 결과는 무엇인가요?", "delete-where",
                 "1006만 UPDATE 뒤 급여가 2200이라 DELETE WHERE로 지워지고, 1009는 새로 들어가요. 새로 넣은 행과 원본에 없는 행은 DELETE WHERE의 대상이 아니라서 8명이 돼요.",
                 [choice("A", "9", rationale="1006은 고친 뒤 급여가 2200이라 DELETE WHERE로 지워져요."),
                  choice("B", "7", rationale="새로 INSERT된 1009는 UPDATE된 행이 아니라서 지워지지 않아요."),
                  choice("C", "5", rationale="DELETE WHERE는 대상 테이블 전체가 아니라 이번에 UPDATE된 행에만 적용돼요."),
                  choice("D", "8", True, "1006이 지워지고 1009가 들어가서 8명이에요.")],
                 stem_sql=DELETE_WHERE_STEM_SQL),
        question(5, "다음 MERGE를 실행하면 어떻게 되나요?", "confusing",
                 "ON 조건에 쓴 t.사번을 UPDATE SET에서 바꾸려고 해서 ORA-38104(ON 절의 열은 수정 불가) 오류가 나요. 급여만 고치면 정상으로 실행돼요.",
                 [choice("A", "1002 사원의 사번과 급여가 모두 바뀐다", rationale="ON에 쓴 열은 UPDATE할 수 없어서 실행되지 않아요."),
                  choice("B", "사번은 그대로 두고 급여만 바뀐다", rationale="문장 전체가 오류로 거부되어 급여도 바뀌지 않아요."),
                  choice("C", "ON 절에 쓴 열은 UPDATE할 수 없다는 오류가 난다", True, "t.사번이 ON 조건에 쓰여서 ORA-38104(ON 절의 열은 수정 불가) 오류가 나요."),
                  choice("D", "1002 사원 행이 하나 더 들어간다", rationale="짝이 있는 행은 INSERT되지 않고, 이 문장에는 INSERT 절도 없어요.")],
                 stem_sql=ON_COLUMN_UPDATE_STEM_SQL),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 기본 예시: UPDATE 2건 + INSERT 1건 (확인 문제 3)
        BASIC_MERGE_EXAMPLE.check,
        sql_check(SALARY_CHANGE_SETUP + "\n" + BASIC_MERGE_SQL + "\nSELECT COUNT(*) FROM 사원;", [[9]]),
        sql_check("SELECT 급여 FROM 사원 WHERE 사번 = 1001", [[3000]], setup=SALARY_CHANGE_SETUP + "\n" + BASIC_MERGE_SQL),
        sql_check("SELECT COUNT(*) FROM 급여변경", [[3]], setup=SALARY_CHANGE_SETUP + "\n" + BASIC_MERGE_SQL),
        # 한쪽 절만, 절 끝 WHERE
        INSERT_ONLY_MERGE_EXAMPLE.check,
MATCHED_WHERE_EXAMPLE.check,
        # DELETE WHERE: 갱신 후 값으로 판단, 원본에 없는 행·새로 넣은 행은 대상 아님 (확인 문제 4)
        DELETE_WHERE_EXAMPLE.check,
        sql_check(DELETE_WHERE_STEM_SQL, [[8]]),
        sql_check("SELECT 사번 FROM 사원 WHERE 사번 IN (1006, 1009)", [[1009]], setup=DELETE_WHERE_STEM_SQL),
        sql_error_check("MERGE INTO 사원 t USING 급여변경 s ON (t.사번 = s.사번) WHEN MATCHED THEN DELETE", "ORA-00905",
                        setup=DELETE_WHERE_SETUP),
        # USING 서브쿼리
        SUBQUERY_MERGE_EXAMPLE.check,
        # 문법 오류: ON 괄호, ON 열 UPDATE (확인 문제 5), WHEN 절 안 테이블 이름, 원본 중복
        sql_error_check("MERGE INTO 사원 t USING 급여변경 s ON t.사번 = s.사번 WHEN MATCHED THEN UPDATE SET t.급여 = s.새급여",
                        "ORA-00969", setup=DELETE_WHERE_SETUP),
        sql_error_check(ON_COLUMN_UPDATE_STEM_SQL, "ORA-38104"),
        sql_check("SELECT 급여 FROM 사원 WHERE 사번 = 1002", [[2500]],
                  setup=ON_COLUMN_UPDATE_STEM_SQL + " -- 오류: ORA-38104"),
        sql_error_check("MERGE INTO 사원 t USING 급여변경 s ON (t.사번 = s.사번) WHEN MATCHED THEN UPDATE 사원 SET t.급여 = s.새급여",
                        "ORA-00971", setup=DELETE_WHERE_SETUP),
        sql_error_check("MERGE INTO 사원 t USING 급여변경 s ON (t.사번 = s.사번)"
                        " WHEN NOT MATCHED THEN INSERT INTO 사원 (사번, 이름, 급여) VALUES (s.사번, s.이름, s.새급여)",
                        "ORA-00926", setup=SALARY_CHANGE_SETUP),
        sql_check("SELECT 급여 FROM 사원 WHERE 사번 = 1009", [[2100]],
                  setup=SALARY_CHANGE_SETUP + "\nMERGE INTO 사원 t USING 급여변경 s ON (t.사번 = s.사번)\n"
                        "WHEN NOT MATCHED THEN INSERT VALUES (s.사번, s.이름, NULL, NULL, NULL, s.새급여, NULL, NULL);"),
        sql_error_check("MERGE INTO 사원 t USING 급여변경 s ON (t.사번 = s.사번) WHEN MATCHED THEN UPDATE SET t.급여 = s.새급여",
                        "ORA-30926",
                        setup="CREATE TABLE 급여변경 (사번 NUMBER(4), 이름 VARCHAR2(20), 새급여 NUMBER(5));\n"
                              "INSERT INTO 급여변경 VALUES (1002, '이지은', 2700);\nINSERT INTO 급여변경 VALUES (1002, '이지은', 2900);"),
        # MERGE 도 ROLLBACK 가능
        sql_check(SALARY_CHANGE_SETUP + "\n" + BASIC_MERGE_SQL + "\nROLLBACK;\nSELECT COUNT(*) FROM 사원;", [[8]]),
    ],
}
