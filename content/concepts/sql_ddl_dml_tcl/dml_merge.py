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
        "- MERGE는 USING의 원본 행마다 ON 조건으로 대상 테이블에서 짝을 찾아, 있으면 WHEN MATCHED(UPDATE), 없으면 WHEN NOT MATCHED(INSERT)를 실행해요.\n"
        "- Oracle에서는 ON 조건을 괄호로 감싸야 하고, ON에 쓴 열은 UPDATE SET에서 바꿀 수 없어요(ORA-38104, ON 절의 열은 수정 불가).\n"
        "- 두 절 중 하나만 써도 되고, UPDATE 뒤의 `DELETE WHERE`는 이번 MERGE로 수정된 행 중 조건에 맞는 행만 지워요.\n"
        "- USING에는 테이블뿐 아니라 뷰나 서브쿼리도 쓸 수 있어요."
    ),
    "detailMd": f"""## 왜 필요한가요 {{#why}}

인사팀이 이번 달 급여 변경 목록을 보내왔어요. 목록에는 이미 있는 사원 두 명의 새 급여와, 이번에 새로 들어온 사원 한 명이 섞여 있어요.

| 사번 | 이름 | 새급여 |
|---|---|---|
| 1002 | 이지은 | 2700 |
| 1007 | 오지민 | 2400 |
| 1009 | 강하준 | 2100 |

사원 표는 공통 예시 데이터의 8명이고, 지금 급여는 아래와 같아요. 1009번 사원은 아직 없어요.

{MERGE_TARGET_EMPLOYEE_TABLE}

이 목록을 사원 표에 반영하려면 이미 있는 사원은 UPDATE로 급여를 고치고, 없는 사원은 INSERT로 넣어야 해요. 문장을 두 개 쓰고, 어떤 사원이 이미 있는지도 따로 가려내야 해서 번거로워요. MERGE는 "짝이 있으면 고치고, 없으면 넣는다"는 일을 한 문장으로 처리해요. 이렇게 수정(update)과 입력(insert)을 합친 동작을 업서트(upsert)라고도 불러요.

## 문법 {{#definition}}

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

INTO 뒤에는 실제로 바뀌는 대상 테이블을 쓰고, USING 뒤에는 바꿀 내용을 가진 원본을 써요. 원본으로는 테이블, 뷰(저장해 둔 SELECT 문), 서브쿼리(괄호로 감싼 SELECT)를 모두 쓸 수 있고, 둘 다 서브쿼리 단원에서 자세히 다뤄요. 별칭 t와 s는 대상과 원본을 짧게 부르려고 붙인 이름이에요. ON에는 원본 행과 대상 행을 짝짓는 조건을 써요. 원본 행마다 대상 테이블에서 이 조건에 맞는 행을 찾고, 찾으면 MATCHED, 못 찾으면 NOT MATCHED가 돼요.

WHEN 절 안의 UPDATE와 INSERT에는 테이블 이름을 쓰지 않아요. 대상이 이미 INTO에서 정해졌기 때문에 `UPDATE SET ...`, `INSERT (열) VALUES (...)`처럼 바로 적어요.

## 예시 {{#example}}

급여변경 표를 만들고 사원 표에 MERGE하면 아래처럼 돼요.

{BASIC_MERGE_EXAMPLE.markdown}

원본의 1002와 1007은 사원 표에 같은 사번이 있어서 MATCHED가 되고, 급여가 새 값으로 바뀌었어요. 1009는 짝이 없어서 NOT MATCHED가 되고, 새 행으로 들어갔어요. 사원 표에만 있고 원본에 없는 1001 같은 사원은 아무 영향도 받지 않아요. 그래서 `COUNT(*)`(행의 개수를 세는 함수)로 세어 보면 사원은 8명에서 9명으로 늘어나요.

## 한쪽 절만 쓰기와 조건 붙이기 {{#one-clause}}

WHEN MATCHED와 WHEN NOT MATCHED는 둘 다 써도 되고 하나만 써도 돼요. 새 사원만 넣고 기존 사원의 급여는 건드리지 않으려면 NOT MATCHED 절만 써요.

{INSERT_ONLY_MERGE_EXAMPLE.markdown}

1002는 MATCHED지만 MATCHED 절이 없어서 급여가 2500 그대로 남고, 1009만 새로 들어갔어요.

각 절 끝에 WHERE를 붙이면 조건에 맞을 때만 그 동작을 해요. 아래는 새 급여가 지금보다 높을 때만 고치는 예시예요.

{MATCHED_WHERE_EXAMPLE.markdown}

이지은은 새 급여 2400이 지금 급여 2500보다 낮아서 바뀌지 않았고, 오지민은 2200에서 2400으로 바뀌었어요.

## MATCHED 뒤의 DELETE WHERE {{#delete-where}}

Oracle은 WHEN MATCHED의 UPDATE 뒤에 `DELETE WHERE 조건`을 붙일 수 있어요. 아래 예시의 원본은 이지은(1002)의 새 급여 2700과 오지민(1007)의 새 급여 2100이고, 지우는 조건은 `급여 < 2600`이에요.

{DELETE_WHERE_EXAMPLE.markdown}

1007이 결과에서 사라졌어요. 네 사람이 어떤 단계를 거쳤는지 따라가 보면 이유가 보여요.

| 사원 | 원본에 있나 | UPDATE 전 급여 | UPDATE 후 급여 | 급여 < 2600 | 결과 |
|---|---|---|---|---|---|
| 이지은(1002) | 있어요 | 2500 | 2700 | 거짓이에요 | 남아요 |
| 오지민(1007) | 있어요 | 2200 | 2100 | 참이에요 | 지워져요 |
| 정하늘(1005) | 없어요 | 2500 | 바뀌지 않아요 | 따지지 않아요 | 남아요 |
| 윤서연(1008) | 없어요 | 2000 | 바뀌지 않아요 | 따지지 않아요 | 남아요 |

정리하면 DELETE WHERE는 방금 UPDATE된 행에만 적용되고, 고친 뒤의 값으로 판단해요. 이지은은 고치기 전 급여 2500으로 따졌다면 지워졌겠지만, 고친 뒤 값 2700으로 따져서 남았어요. 정하늘과 윤서연은 급여가 2600보다 작아도 UPDATE되지 않았기 때문에 남았어요.

DELETE WHERE는 UPDATE 절에 딸린 문법이라서 혼자 쓸 수 없어요. `WHEN MATCHED THEN DELETE`처럼 UPDATE 없이 쓰면 Oracle에서는 오류가 나요. 또 같은 MERGE에서 WHEN NOT MATCHED로 새로 넣은 행은 UPDATE된 행이 아니므로 지워지지 않아요.

## USING에 서브쿼리 쓰기 {{#using-subquery}}

원본이 따로 테이블로 있지 않아도, USING 뒤에 서브쿼리를 괄호로 감싸 쓰고 별칭을 붙이면 원본처럼 쓸 수 있어요. 아래는 보관용 표에 20번 부서 사원의 최신 급여를 맞춰 넣는 예시예요. 보관용 표에는 이지은의 옛 급여 2000만 들어 있어요.

{SUBQUERY_MERGE_EXAMPLE.markdown}

이지은은 짝이 있어서 2500으로 고쳐졌고, 보관용 표에 없던 박서준과 정하늘은 새로 들어갔어요.

## 자주 헷갈리는 점 {{#confusing}}

**ON 조건은 괄호로 감싸야 해요.** Oracle에서는 `ON t.사번 = s.사번`처럼 괄호 없이 쓰면 오류(ORA-00969, ON 절 괄호 누락)가 나요. 조인 단원에서 배울 JOIN(두 테이블을 이어 붙이는 문법)의 ON은 괄호가 없어도 되기 때문에 자주 틀려요.

**ON에 쓴 열은 UPDATE할 수 없어요.** 짝을 찾는 기준인 열을 MERGE 도중에 바꾸면 어떤 행이 짝인지가 흔들리기 때문에, Oracle은 `UPDATE SET t.사번 = ...`처럼 ON에 쓴 열을 고치려고 하면 오류(ORA-38104, ON 절의 열은 수정 불가)를 내요. 다른 열만 고치면 문제없어요.

**WHEN 절 안에는 테이블 이름을 쓰지 않아요.** `UPDATE 사원 SET ...`(ORA-00971, SET 키워드 누락)이나 `INSERT INTO 사원 (...)`(ORA-00926, VALUES 키워드 누락)처럼 평소 DML 모양으로 쓰면 오류가 나요. INSERT 열 목록을 생략하고 `INSERT VALUES (...)`로 쓰면, 일반 INSERT처럼 대상 테이블의 모든 열에 순서대로 값을 적어야 해요.

**DELETE WHERE는 이번에 UPDATE된 행만 지워요.** 대상 테이블 전체에서 조건에 맞는 행을 지우는 것이 아니에요. 원본에 없어서 MATCHED가 되지 않은 행과 새로 INSERT된 행은 조건에 맞아도 남고, 조건은 고친 뒤의 값으로 판단해요.

**바뀌는 쪽은 INTO 뒤의 대상 테이블뿐이에요.** USING의 원본은 읽기만 하고 바뀌지 않아요. 또 원본에 같은 사번이 두 번 있으면 대상의 한 행을 두 번 고치게 되어서, 결과를 정할 수 없다는 오류(ORA-30926, 원본 행이 하나로 정해지지 않음)가 나요.

**MERGE도 DML이에요.** 그래서 COMMIT 전에는 ROLLBACK으로 되돌릴 수 있어요. SQL Server에도 MERGE가 있는데, 문장 끝에 세미콜론이 꼭 필요하고 원본에 없는 대상 행을 처리하는 `WHEN NOT MATCHED BY SOURCE` 절도 쓸 수 있다는 점이 달라요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

대상 표와 원본 표를 주고 MERGE를 실행한 뒤의 행 수나 특정 행의 값을 묻는 문제가 가장 많아요. 원본 행을 하나씩 짚으면서 MATCHED인지 NOT MATCHED인지 표시하고, DELETE WHERE가 있으면 UPDATE된 행에만 고친 뒤 값으로 조건을 적용하면 돼요. 문법 문제에서는 ON의 괄호, ON 열 UPDATE 금지, 한쪽 절만 쓸 수 있다는 점이 보기로 나와요.""",
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
