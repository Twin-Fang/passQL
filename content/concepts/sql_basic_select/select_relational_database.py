"""개념: 관계형 데이터베이스와 SQL의 특징 (2단원, 확인 문제 5개)
범위: DB·DBMS > 관계형 구조(테이블·행·열·키) > SQL 특징 > 명령어 분류 > 관계대수"""

from concept_bundle import choice, question, sql_check, sql_error_check, sql_example
from concept_dataset import DEPARTMENT_TABLE_MD, to_employee_table_md, to_insert_statements, to_markdown_table

EMPLOYEE_BASIC_TABLE = to_employee_table_md("사번", "이름", "직급", "급여", "부서번호")

# 셀렉트 연산 예시 (부서 지역 = 서울 > 2행)
SELECTION_EXAMPLE = sql_example("SELECT * FROM 부서 WHERE 지역 = '서울';", ("부서번호", "부서명", "지역"),
                                [[10, "기획부", "서울"], [40, "인사부", "서울"]])
# 프로젝트 연산 예시 (SQL 은 중복 행을 남김 > 서울 2번)
PROJECTION_EXAMPLE = sql_example("SELECT 지역 FROM 부서;", ("지역",),
                                 [["서울"], ["판교"], ["부산"], ["서울"]], is_ordered=False)
# 셀렉트 + 프로젝트 함께 (20번 부서 3명의 이름·급여)
SELECTION_PROJECTION_EXAMPLE = sql_example("SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 20;", ("이름", "급여"),
                                           [["이지은", 2500], ["박서준", 2800], ["정하늘", 2500]], is_ordered=False)

# 집합 단위 처리 예시: 20번 부서 급여 +100 (한 문장으로 3행 변경)
RAISE_SALARY_SQL = "UPDATE 사원 SET 급여 = 급여 + 100 WHERE 부서번호 = 20;"

# 디비전 예시 표 2개: 자격보유(사번, 자격) ÷ 필수자격(자격) > 1002, 1005
CERTIFICATE_HOLDING_ROWS = (
    (1002, "SQLD"), (1002, "정보처리기사"),
    (1003, "SQLD"),
    (1005, "SQLD"), (1005, "정보처리기사"), (1005, "빅데이터분석기사"),
    (1006, "정보처리기사"),
)
REQUIRED_CERTIFICATE_ROWS = (("SQLD",), ("정보처리기사",))
CERTIFICATE_HOLDING_TABLE = to_markdown_table(("사번", "자격"), CERTIFICATE_HOLDING_ROWS)
REQUIRED_CERTIFICATE_TABLE = to_markdown_table(("자격",), REQUIRED_CERTIFICATE_ROWS)
DIVISION_SETUP = "\n".join([
    "CREATE TABLE 자격보유 (사번 NUMBER(4), 자격 VARCHAR2(30));",
    "CREATE TABLE 필수자격 (자격 VARCHAR2(30));",
    *to_insert_statements("자격보유", CERTIFICATE_HOLDING_ROWS),
    *to_insert_statements("필수자격", REQUIRED_CERTIFICATE_ROWS),
])
# 디비전 SQL (이중 NOT EXISTS: 이 사원이 갖지 않은 필수 자격이 하나도 없음) — 본문에는 6단원으로 연결만
DIVISION_SQL = (
    "SELECT DISTINCT a.사번 FROM 자격보유 a WHERE NOT EXISTS ("
    "SELECT 1 FROM 필수자격 r WHERE NOT EXISTS ("
    "SELECT 1 FROM 자격보유 b WHERE b.사번 = a.사번 AND b.자격 = r.자격))"
)

CONCEPT = {
    "tagKey": "select-relational-database",
    "topicCode": "sql_basic_select",
    "sortOrder": 1,
    "title": "관계형 데이터베이스와 SQL의 특징",
    "summary": "데이터를 표에 나눠 담는 관계형 데이터베이스와, 그 표를 다루는 SQL의 특징이에요",
    "coreMd": (
        "- 관계형 데이터베이스는 데이터를 행과 열로 된 테이블에 나눠 담고, 기본키와 외래키로 테이블끼리 이어요.\n"
        "- SQL은 원하는 결과만 적고 처리 방법은 DBMS가 정하는 선언적(비절차적) 언어이고, 행을 집합 단위로 다루는 표준 언어예요. \"절차적 언어\"라는 설명은 틀린 보기예요.\n"
        "- 명령어는 DML(SELECT·INSERT·UPDATE·DELETE·MERGE), DDL(CREATE·ALTER·DROP·RENAME·TRUNCATE), DCL(GRANT·REVOKE), TCL(COMMIT·ROLLBACK·SAVEPOINT)로 나뉘어요.\n"
        "- 관계대수의 합집합·교집합·차집합·곱집합은 UNION·INTERSECT·MINUS·CROSS JOIN에 대응하고, 셀렉트는 WHERE, 프로젝트는 SELECT의 열 목록, 조인은 JOIN에 대응해요.\n"
        "- 셀렉트 연산은 이름과 달리 행을 고르는 WHERE에 해당하고, 디비전은 다른 테이블의 값을 모두 가진 쪽을 찾는 연산인데 SQL에 따로 대응하는 명령어가 없어요."
    ),
    "detailMd": f"""## 데이터베이스와 DBMS {{#why}}

회사에서 사원 명단을 직원마다 각자 엑셀 파일로 들고 있으면, 누군가 급여를 고쳐도 다른 사람의 파일은 그대로라서 금세 값이 서로 달라져요. 그래서 여러 사람이 함께 쓰는 데이터는 한곳에 정리해 모아 두는데, 이렇게 모아 둔 데이터 묶음을 **데이터베이스**라고 불러요.

데이터베이스를 만들고, 데이터를 저장하고, 찾아 주고, 고쳐 주는 소프트웨어를 **DBMS**(데이터베이스 관리 시스템)라고 해요. 여러 사람이 동시에 같은 데이터를 쓰게 해 주고, 누가 어떤 데이터를 볼 수 있는지 권한을 관리하는 일도 DBMS가 맡아요. Oracle과 SQL Server는 DBMS 제품의 이름이에요. SQLD 시험은 주로 Oracle을 기준으로 나오고, SQL Server와 문법이 다른 부분을 함께 묻기도 해요.

## 관계형 데이터베이스 {{#definition}}

**관계형 데이터베이스**는 데이터를 엑셀처럼 칸이 나뉜 표에 담는 데이터베이스예요. 이 표를 **테이블**이라고 부르고, 1970년에 E. F. Codd가 집합 이론을 바탕으로 제안한 관계형 모델에서 출발했어요. 아래가 이 앱의 모든 예시에서 쓰는 사원 테이블과 부서 테이블이에요.

{EMPLOYEE_BASIC_TABLE}

{DEPARTMENT_TABLE_MD}

테이블의 가로 한 줄을 **행**(로우)이라고 하고, 세로 칸 하나를 **열**(컬럼)이라고 해요. 사원 테이블에서 "1001 김민수 사장 3000 10"은 행 하나이고, "급여"는 열 이름이에요. 시험에서는 관계형 모델의 용어로 묻기도 해서 아래처럼 짝지어 기억해 두면 좋아요.

| 흔히 부르는 말 | 관계형 모델 용어 | 사원 테이블에서 |
|---|---|---|
| 테이블 | 릴레이션 | 사원 테이블 전체 |
| 행 | 튜플 | 김민수 한 사람의 정보 |
| 열 | 속성(애트리뷰트) | 이름, 급여 같은 항목 |

열의 개수는 **차수**, 행의 개수는 **카디널리티**라고 불러요. 부서 테이블은 열이 부서번호, 부서명, 지역 세 개이고 행이 네 개라서 차수가 3, 카디널리티가 4예요. 데이터 모델링 단원의 관계에서 말하는 관계 차수(1:1, 1:M처럼 몇 개와 이어지는지)와 이름이 비슷하지만, 여기서는 테이블의 열 개수와 행 개수를 가리키는 말이라 뜻이 달라요. 1단원 데이터 모델링에서 그린 엔터티가 테이블로, 인스턴스가 행으로, 속성이 열로 만들어진다고 보면 돼요.

사원 테이블에는 부서 이름이 없고 부서번호만 있어요. 부서 이름은 부서 테이블에 한 번만 적어 두고, 두 테이블에 함께 있는 부서번호로 이어 보기 때문이에요. 이렇게 행을 구별하거나 테이블을 잇는 데 쓰는 열을 **키**라고 하고, 아래 두 가지가 대표적이에요.

- **기본키**: 행 하나를 다른 행과 구별하는 열이에요. 사원 테이블의 사번, 부서 테이블의 부서번호가 기본키라서 같은 값이 두 번 들어갈 수 없고 비워 둘(NULL) 수도 없어요.
- **외래키**: 다른 테이블의 기본키를 가리키는 열이에요. 사원 테이블의 부서번호는 부서 테이블의 부서번호를 가리키므로, 부서 테이블에 있는 값이나 NULL만 들어갈 수 있어요. 윤서연처럼 부서가 정해지지 않은 사원은 NULL(값이 비어 있다는 표시)로 둘 수 있어요.

```sql
INSERT INTO 사원 (사번, 이름, 부서번호) VALUES (1009, '강하준', 50);  -- 오류: 부서 테이블에 50번 부서가 없어요 (ORA-02291, 참조할 부모 키 없음)
INSERT INTO 사원 (사번, 이름, 부서번호) VALUES (1009, '강하준', 40);  -- 40번 인사부는 있어서 들어가요
```

INSERT는 테이블에 행을 넣는 명령이고 3단원에서 다뤄요. 키를 정하는 방법은 1단원 식별자 개념에서 자세히 다뤄요.

## SQL의 특징 {{#sql-features}}

**SQL**은 관계형 데이터베이스에 일을 시키는 언어예요. Structured Query Language를 줄인 이름이라 구조적 질의 언어라고도 불러요. 시험에서는 SQL의 특징을 고르는 문제가 나오는데, 아래 세 가지가 맞는 설명이에요.

**원하는 결과만 적어요.** "20번 부서 사원의 이름과 급여를 보여 줘"라고 쓰면, 어느 행부터 읽을지, 어떤 순서로 찾을지는 DBMS가 알아서 정해요. 이렇게 무엇을 원하는지만 적는 언어를 **선언적 언어**, 다른 말로 **비절차적 언어**라고 해요. 반대로 C나 Java처럼 처리 순서를 한 단계씩 적는 언어는 절차적 언어예요. 그래서 "SQL은 절차적 언어다"는 틀린 설명이고, 시험에서 자주 나오는 오답 보기예요. 처리 방법을 고르는 DBMS 안의 부품을 **옵티마이저**라고 불러요. 아래 SQL에서 SELECT 뒤에는 보여 줄 열을, FROM 뒤에는 읽을 테이블을, WHERE 뒤에는 행을 고를 조건을 적었어요. SELECT 문의 생김새는 다음 개념에서 자세히 다뤄요.

{SELECTION_PROJECTION_EXAMPLE.markdown}

**행을 집합 단위로 다뤄요.** SQL 문장 하나는 조건에 맞는 행 전체를 한꺼번에 처리해요. 아래 UPDATE(행의 값을 고치는 명령, 3단원) 한 문장은 20번 부서 세 명의 급여를 모두 100씩 올려요. 행마다 반복문을 쓸 필요가 없어요.

```sql
{RAISE_SALARY_SQL}
SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 20;
```

| 이름 | 급여 |
|---|---|
| 이지은 | 2600 |
| 박서준 | 2900 |
| 정하늘 | 2600 |

**표준 언어예요.** SQL은 ANSI와 ISO가 정한 관계형 데이터베이스의 표준 언어라서, Oracle과 SQL Server 모두 같은 기본 문법을 써요. 다만 제품마다 표준에 없는 기능을 덧붙여서, Oracle의 ROWNUM과 SQL Server의 TOP처럼 제품마다 다른 문법도 있어요. 시험은 이런 차이를 보기로 내기도 해요.

## SQL 명령어의 종류 {{#sql-types}}

SQL 명령어는 하는 일에 따라 네 무리로 나뉘어요. 명령어를 보여 주고 어느 무리인지 묻는 문제가 자주 나와요.

| 종류 | 하는 일 | 명령어 |
|---|---|---|
| DML (데이터 조작어) | 행을 조회하고, 넣고, 고치고, 지워요 | SELECT, INSERT, UPDATE, DELETE, MERGE |
| DDL (데이터 정의어) | 테이블 같은 구조를 만들고, 바꾸고, 없애요 | CREATE, ALTER, DROP, RENAME, TRUNCATE |
| DCL (데이터 제어어) | 다른 사용자에게 권한을 주고 빼앗아요 | GRANT, REVOKE |
| TCL (트랜잭션 제어어) | 지금까지 한 변경을 확정하거나 취소해요 | COMMIT, ROLLBACK, SAVEPOINT |

SELECT는 데이터를 바꾸지 않고 읽기만 해서 **DQL**(데이터 질의어)이라고 따로 부르기도 하지만, SQLD에서는 보통 DML에 넣어요. 트랜잭션은 계좌 이체의 출금과 입금처럼 함께 성공하거나 함께 취소되어야 하는 변경 묶음을 말해요. DDL은 3단원 앞부분에서, DCL과 TCL은 3단원 뒷부분에서 자세히 다뤄요.

## 관계대수 {{#relational-algebra}}

**관계대수**는 테이블을 넣으면 테이블이 나오는 연산들의 모음이에요. SQL은 이 연산들을 문장으로 쓸 수 있게 만든 언어라서, 시험에서는 관계대수 연산이 어떤 SQL에 해당하는지를 물어요. 연산은 집합 이론에서 가져온 **일반 집합 연산** 네 가지와, 관계형 모델을 위해 만든 **순수 관계 연산** 네 가지로 나뉘어요.

| 분류 | 연산 | 기호 | 하는 일 | SQL |
|---|---|---|---|---|
| 일반 집합 연산 | 합집합 | ∪ | 두 테이블의 행을 합쳐요 | UNION |
| 일반 집합 연산 | 교집합 | ∩ | 두 테이블에 함께 있는 행만 남겨요 | INTERSECT |
| 일반 집합 연산 | 차집합 | − | 앞 테이블에만 있는 행을 남겨요 | MINUS (표준은 EXCEPT) |
| 일반 집합 연산 | 곱집합(카티션 곱) | × | 두 테이블의 행을 모든 조합으로 이어 붙여요 | CROSS JOIN |
| 순수 관계 연산 | 셀렉트 | σ | 조건에 맞는 행을 골라요 | WHERE |
| 순수 관계 연산 | 프로젝트 | π | 원하는 열을 골라요 | SELECT의 열 목록 |
| 순수 관계 연산 | 조인 | ⋈ | 공통 값으로 두 테이블을 이어요 | JOIN |
| 순수 관계 연산 | 디비전 | ÷ | 다른 테이블의 값을 모두 가진 쪽을 찾아요 | 대응하는 명령어 없음 |

**일반 집합 연산은 행을 통째로 비교해요.** 합집합, 교집합, 차집합은 두 쪽의 열 개수와 데이터 종류가 같아야 쓸 수 있어요. 아래는 부서 테이블과 사원 테이블에서 부서번호 열만 뽑아 비교한 예시이고, 집합 연산자의 자세한 규칙은 6단원에서 다뤄요.

```sql
SELECT 부서번호 FROM 부서 UNION SELECT 부서번호 FROM 사원;      -- 합집합이에요
SELECT 부서번호 FROM 부서 INTERSECT SELECT 부서번호 FROM 사원;  -- 교집합이에요
SELECT 부서번호 FROM 부서 MINUS SELECT 부서번호 FROM 사원;      -- 차집합이에요
SELECT COUNT(*) FROM 부서 CROSS JOIN 사원;                     -- 곱집합의 행 수는 32예요
```

| 연산 | 결과 |
|---|---|
| UNION | 10, 20, 30, 40, NULL (중복은 한 번만 남아요) |
| INTERSECT | 10, 20, 30 |
| MINUS | 40 (사원이 없는 인사부) |
| CROSS JOIN | 32행 |

UNION 결과의 NULL은 부서가 없는 윤서연의 부서번호에서 왔어요. `COUNT(*)`는 행 수를 세는 함수이고 7단원에서 다뤄요. 곱집합은 부서 4개마다 사원 8명을 모두 이어 붙여서 4 × 8 = 32행이 돼요.

**셀렉트는 행을, 프로젝트는 열을 골라요.** 아래 첫 SQL은 지역이 서울인 행만 골라서 셀렉트 연산이 되고, 두 번째 SQL은 지역 열만 골라서 프로젝트 연산이 돼요. `*`는 모든 열을 뜻해요.

{SELECTION_EXAMPLE.markdown}

{PROJECTION_EXAMPLE.markdown}

**조인은 공통 값으로 테이블을 이어요.** 사원의 부서번호와 부서의 부서번호가 같은 행끼리 이어 붙이면 사원 이름 옆에 부서 이름을 함께 볼 수 있어요. 조인은 5단원에서 따로 다뤄요.

**디비전은 "모두 가진 쪽"을 찾아요.** 나눗셈이라는 뜻의 연산이고, 한 테이블의 값을 빠짐없이 모두 가진 행을 찾아요. 아래 자격보유 테이블을 필수자격 테이블로 나누면, SQLD와 정보처리기사를 둘 다 가진 사원만 남아요.

{CERTIFICATE_HOLDING_TABLE}

{REQUIRED_CERTIFICATE_TABLE}

1002는 두 자격을 모두 가져서 남아요. 1005는 빅데이터분석기사를 더 가졌지만 필수 자격 두 개를 빠짐없이 가졌으니 역시 남아요. 1003은 정보처리기사가, 1006은 SQLD가 없어서 빠지므로 결과는 1002, 1005예요. SQL에는 디비전 명령어가 없어서 "이 사원이 갖지 않은 필수 자격이 하나도 없다"처럼 부정을 두 번 겹쳐 써요. 이때 쓰는 NOT EXISTS는 6단원 연관 서브쿼리와 EXISTS 개념에서 다뤄요.

## 자주 헷갈리는 점 {{#confusing}}

**셀렉트 연산은 SELECT 절이 아니라 WHERE 절이에요.** 이름이 같아서 셀렉트 연산을 SELECT 절과 짝짓기 쉬운데, 셀렉트 연산은 조건에 맞는 행을 고르는 일이라 WHERE가 하는 일이에요. SELECT 절에서 보여 줄 열을 적는 일은 프로젝트 연산이에요. 앞에서 본 `SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 20`을 나눠 보면 아래와 같아요.

| SQL 부분 | 하는 일 | 관계대수 연산 |
|---|---|---|
| `WHERE 부서번호 = 20` | 20번 부서 행만 골라요 | 셀렉트 |
| `SELECT 이름, 급여` | 이름과 급여 열만 골라요 | 프로젝트 |

**프로젝트 연산은 중복을 없애지만 SQL은 중복을 남겨요.** 관계대수에서 테이블은 집합이라 같은 행이 두 번 있을 수 없어서, 프로젝트 결과에서 중복된 행은 하나로 합쳐져요. 그런데 SQL의 `SELECT 지역 FROM 부서`는 서울을 두 번 보여 줘요. SQL에서 관계대수의 프로젝트와 같은 결과를 얻으려면 중복을 지우는 DISTINCT를 붙여야 하고, DISTINCT는 다음 개념 "별칭과 DISTINCT"에서 다뤄요.

```sql
SELECT DISTINCT 지역 FROM 부서;   -- 중복된 서울이 하나로 합쳐져서 세 행이 나와요
```

**곱집합은 일반 집합 연산이고, 조인은 순수 관계 연산이에요.** 곱집합(CROSS JOIN)도 이름에 JOIN이 들어가서 순수 관계 연산으로 착각하기 쉬워요. 곱집합은 집합 이론에서 가져온 연산이라 합집합·교집합·차집합과 같은 일반 집합 연산이에요. 순수 관계 연산은 셀렉트, 프로젝트, 조인, 디비전 네 가지예요.

**TRUNCATE는 DML이 아니라 DDL이에요.** TRUNCATE는 테이블의 행을 모두 지워서 DELETE와 결과가 비슷하지만, 테이블을 처음 만든 상태로 되돌리는 구조 명령이라 DDL로 분류해요. DELETE는 DML이라서 COMMIT 전이면 ROLLBACK으로 되돌릴 수 있지만, Oracle은 DDL을 실행하면 자동으로 COMMIT(변경 확정)을 하기 때문에 TRUNCATE는 되돌릴 수 없어요. 자세한 차이는 3단원 CREATE·ALTER·DROP·TRUNCATE 개념에서 다뤄요.

**GRANT는 DCL이고, COMMIT은 TCL이에요.** COMMIT과 ROLLBACK은 권한과 상관없이 변경을 확정하거나 취소하는 명령이라 DCL이 아니라 TCL이에요. Oracle 공식 문서는 GRANT와 REVOKE를 DDL에 함께 묶어 두기도 하지만, SQLD 시험은 이 둘을 DCL로 따로 분류하니 시험에서는 DCL로 답해요. MERGE는 행을 넣거나 고치는 명령이라 DML이고, 이름을 바꾸는 RENAME은 구조를 바꾸므로 DDL이에요.

**SQL에는 처리 절차를 적지 않아요.** SQL이 선언적 언어라는 말은 "결과는 사용자가, 방법은 DBMS가 정한다"는 뜻이에요. 그래서 같은 SQL이라도 데이터 양에 따라 DBMS가 다른 방법으로 처리할 수 있고, 결과는 항상 같아요. 다음 개념에서 배울 SELECT 문의 실행 순서는 결과가 어떻게 정해지는지 설명하는 규칙이지, 사용자가 처리 절차를 적는 것이 아니에요.

## 시험에서는 이렇게 나와요 {{#exam-point}}

SQL의 특징으로 알맞지 않은 것을 고르는 문제가 나오고, 보기에는 선언적, 집합 단위, 구조적, 절차적 같은 말이 섞여 나와요. SQL은 처리 절차를 적지 않으므로 "절차적"이 틀린 보기예요. TRUNCATE, GRANT, COMMIT, MERGE 같은 명령어가 DML·DDL·DCL·TCL 중 어디에 속하는지 묻는 문제도 자주 나와요. 관계대수는 연산과 SQL을 짝짓는 문제, 셀렉트와 프로젝트를 구별하는 문제, 작은 표 두 개를 주고 디비전 결과를 묻는 문제로 나와요.""",
    "checkQuestions": [
        question(1, "관계형 모델에서 테이블의 열(컬럼)을 부르는 말은 무엇인가요?", "definition",
                 "테이블은 릴레이션, 행은 튜플, 열은 속성(애트리뷰트)이라고 불러요. 기본키는 행을 구별하는 데 쓰는 열을 가리키는 말이에요.",
                 [choice("A", "튜플", rationale="튜플은 가로 한 줄인 행을 부르는 말이에요."),
                  choice("B", "릴레이션", rationale="릴레이션은 테이블 전체를 부르는 말이에요."),
                  choice("C", "속성", True, "열 하나가 이름, 급여 같은 속성 하나에 해당해요."),
                  choice("D", "기본키", rationale="기본키는 열 중에서 행을 구별하는 데 쓰는 특정한 열이에요.")]),
        question(2, "SQL 언어의 특징으로 알맞지 않은 것은 무엇인가요?", "sql-features",
                 "SQL은 원하는 결과만 적고 처리 방법은 DBMS가 정하는 선언적(비절차적) 언어예요. 처리 순서를 한 단계씩 적는 것은 절차적 언어의 특징이에요.",
                 [choice("A", "원하는 결과만 적고 처리 방법은 DBMS가 정하는 선언적 언어이다", rationale="SQL의 맞는 특징이에요."),
                  choice("B", "조건에 맞는 행을 집합 단위로 한꺼번에 처리한다", rationale="문장 하나가 조건에 맞는 행 전체를 처리하므로 맞는 설명이에요."),
                  choice("C", "관계형 데이터베이스의 표준 언어이다", rationale="ANSI와 ISO가 정한 표준 언어라서 맞는 설명이에요."),
                  choice("D", "데이터를 처리하는 순서를 한 단계씩 적는 절차적 언어이다", True, "SQL은 절차를 적지 않는 비절차적 언어라서 틀린 설명이에요.")]),
        question(3, "SQL 명령어와 종류를 짝지은 것으로 알맞지 않은 것은 무엇인가요?", "sql-types",
                 "COMMIT은 변경을 확정하는 트랜잭션 제어어(TCL)예요. 권한을 다루는 DCL에는 GRANT와 REVOKE가 들어가요.",
                 [choice("A", "COMMIT - DCL", True, "COMMIT은 TCL이라서 잘못 짝지었어요."),
                  choice("B", "TRUNCATE - DDL", rationale="TRUNCATE는 테이블을 처음 상태로 되돌리는 DDL이에요."),
                  choice("C", "GRANT - DCL", rationale="권한을 주는 명령이라 DCL이 맞아요."),
                  choice("D", "MERGE - DML", rationale="행을 넣거나 고치는 명령이라 DML이 맞아요.")]),
        question(4, "관계대수의 셀렉트 연산과 같은 일을 하는 SQL 부분은 무엇인가요?", "confusing",
                 "셀렉트 연산은 조건에 맞는 행을 고르는 연산이라 **WHERE 절**에 해당해요. SELECT 절의 열 목록은 열을 고르는 프로젝트 연산이에요.",
                 [choice("A", "SELECT 절의 열 목록", rationale="열을 고르는 일은 프로젝트 연산이에요."),
                  choice("B", "WHERE 절", True, "조건에 맞는 행만 남기는 일이 셀렉트 연산이에요."),
                  choice("C", "CROSS JOIN", rationale="모든 조합을 이어 붙이는 곱집합 연산이에요."),
                  choice("D", "MINUS", rationale="앞쪽에만 있는 행을 남기는 차집합 연산이에요.")]),
        question(5, "아래 자격보유 테이블을 필수자격 테이블로 나눈 디비전(÷) 결과로 알맞은 것은 무엇인가요?\n\n"
                 + CERTIFICATE_HOLDING_TABLE + "\n\n" + REQUIRED_CERTIFICATE_TABLE, "relational-algebra",
                 "디비전은 필수자격의 SQLD와 정보처리기사를 빠짐없이 모두 가진 사번을 찾아요. 1002와 1005가 둘 다 가졌고, 1005가 다른 자격을 더 가진 것은 결과에 영향을 주지 않아요.",
                 [choice("A", "1003, 1006", rationale="필수 자격을 하나씩만 가진 사원이라 디비전 결과에서 빠져요."),
                  choice("B", "1002, 1003, 1005, 1006", rationale="자격을 하나라도 가진 사원을 모두 셌는데, 디비전은 전부 가진 쪽만 남겨요."),
                  choice("C", "1002, 1005", True, "두 필수 자격을 모두 가진 사원은 1002와 1005예요."),
                  choice("D", "1002", rationale="필수 자격 외의 자격을 더 가져도 결과에서 빠지지 않아서 1005도 남아요.")]),
    ],
    "relatedQuestionUuids": [],
    "sqlChecks": [
        # 외래키 (부서 테이블에 없는 부서번호 > 오류, 있는 부서번호 > 성공)
        sql_error_check("INSERT INTO 사원 (사번, 이름, 부서번호) VALUES (1009, '강하준', 50)", "ORA-02291"),
        sql_check("INSERT INTO 사원 (사번, 이름, 부서번호) VALUES (1009, '강하준', 40);\n"
                  "SELECT 이름, 부서번호 FROM 사원 WHERE 사번 = 1009", [["강하준", 40]]),
        # SQL 특징 (선언적 조회, 집합 단위 UPDATE 3행)
        SELECTION_PROJECTION_EXAMPLE.check,
        sql_check("SELECT 이름, 급여 FROM 사원 WHERE 부서번호 = 20",
                  [["이지은", 2600], ["박서준", 2900], ["정하늘", 2600]], setup=RAISE_SALARY_SQL),
        # 일반 집합 연산 (UNION·INTERSECT·MINUS·CROSS JOIN)
        sql_check("SELECT 부서번호 FROM 부서 UNION SELECT 부서번호 FROM 사원", [[10], [20], [30], [40], [None]]),
        sql_check("SELECT 부서번호 FROM 부서 INTERSECT SELECT 부서번호 FROM 사원", [[10], [20], [30]]),
        sql_check("SELECT 부서번호 FROM 부서 MINUS SELECT 부서번호 FROM 사원", [[40]]),
        sql_check("SELECT COUNT(*) FROM 부서 CROSS JOIN 사원", [[32]]),
        # 셀렉트·프로젝트 (SQL 은 중복 유지, DISTINCT 로 제거)
        SELECTION_EXAMPLE.check,
        PROJECTION_EXAMPLE.check,
        sql_check("SELECT DISTINCT 지역 FROM 부서", [["서울"], ["판교"], ["부산"]]),
        # 디비전 (5번 문제: 1002, 1005)
        sql_check(DIVISION_SQL, [[1002], [1005]], setup=DIVISION_SETUP),
    ],
}
