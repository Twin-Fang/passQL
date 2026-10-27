"""개념 학습 공통 예시 데이터: 부서·사원·급여등급 표 (모든 개념이 같은 표를 씀, 설계 7장 4번)

화면용 마크다운 표와 Oracle 검증용 생성 SQL 의 원본이 이곳 하나다. 값을 바꾸면 두 쪽이 함께 바뀐다.
데이터 특징: 사원 없는 부서 40, 부서 없는 사원 1008, 커미션 NULL 4명·0 1명, 20번 부서 급여 2500 동점, 관리자 3단계
"""

# 부서 4개 (40 인사부는 소속 사원 없음 > 외부 조인 예시)
DEPARTMENT_ROWS = (
    (10, "기획부", "서울"),
    (20, "개발부", "판교"),
    (30, "영업부", "부산"),
    (40, "인사부", "서울"),
)

# 사원 8명: 사번, 이름, 직급, 관리자사번, 입사일, 급여, 커미션, 부서번호 (1008 은 부서 미배정)
EMPLOYEE_ROWS = (
    (1001, "김민수", "사장", None, "2015-03-02", 3000, None, 10),
    (1002, "이지은", "과장", 1001, "2018-07-16", 2500, 300, 20),
    (1003, "박서준", "대리", 1002, "2020-01-06", 2800, 0, 20),
    (1004, "최유나", "부장", 1001, "2016-11-21", 3200, None, 30),
    (1005, "정하늘", "사원", 1002, "2022-03-14", 2500, None, 20),
    (1006, "한도윤", "대리", 1004, "2019-09-02", 2700, 500, 30),
    (1007, "오지민", "사원", 1004, "2023-02-01", 2200, 200, 30),
    (1008, "윤서연", "사원", 1001, "2024-05-20", 2000, None, None),
)

# 급여등급 4개 (최저~최고 사이에 급여가 들면 그 등급 > 비등가 조인 예시)
SALARY_GRADE_ROWS = (
    (1, 0, 2299),
    (2, 2300, 2699),
    (3, 2700, 2999),
    (4, 3000, 3999),
)

DEPARTMENT_COLUMNS = ("부서번호", "부서명", "지역")
EMPLOYEE_COLUMNS = ("사번", "이름", "직급", "관리자사번", "입사일", "급여", "커미션", "부서번호")
SALARY_GRADE_COLUMNS = ("등급", "최저급여", "최고급여")


def to_markdown_table(columns, rows):
    """열 이름 + 행 > 마크다운 표 (None 은 NULL 로 표시)"""
    def to_cell(value):
        return "NULL" if value is None else str(value)

    lines = ["| " + " | ".join(columns) + " |", "|" + "---|" * len(columns)]
    lines += ["| " + " | ".join(to_cell(value) for value in row) + " |" for row in rows]
    return "\n".join(lines)


DEPARTMENT_TABLE_MD = to_markdown_table(DEPARTMENT_COLUMNS, DEPARTMENT_ROWS)
EMPLOYEE_TABLE_MD = to_markdown_table(EMPLOYEE_COLUMNS, EMPLOYEE_ROWS)
SALARY_GRADE_TABLE_MD = to_markdown_table(SALARY_GRADE_COLUMNS, SALARY_GRADE_ROWS)


def to_employee_table_md(*column_names, employee_numbers=None):
    """사원 표 일부 열(·일부 사번)만 > 마크다운 표 (좁은 화면용, 값은 원본 그대로)"""
    indexes = [EMPLOYEE_COLUMNS.index(name) for name in column_names]
    rows = [row for row in EMPLOYEE_ROWS if employee_numbers is None or row[0] in employee_numbers]
    return to_markdown_table(column_names, [[row[index] for index in indexes] for row in rows])


def _to_sql_literal(value, is_date=False):
    if value is None:
        return "NULL"
    if is_date:
        return f"DATE '{value}'"
    if isinstance(value, str):
        return "'" + value.replace("'", "''") + "'"
    return str(value)


def _to_insert_statements(table_name, rows, date_column_indexes=()):
    return [
        f"INSERT INTO {table_name} VALUES ("
        + ", ".join(_to_sql_literal(value, index in date_column_indexes) for index, value in enumerate(row))
        + ");"
        for row in rows
    ]


# Oracle 검증 스키마 초기 상태 (개념마다, SQL 블록·검증 항목마다 이 상태에서 시작)
SETUP_SQL = "\n".join([
    "CREATE TABLE 부서 (부서번호 NUMBER(2) PRIMARY KEY, 부서명 VARCHAR2(20) NOT NULL, 지역 VARCHAR2(20));",
    "CREATE TABLE 사원 (사번 NUMBER(4) PRIMARY KEY, 이름 VARCHAR2(20) NOT NULL, 직급 VARCHAR2(10),"
    " 관리자사번 NUMBER(4), 입사일 DATE, 급여 NUMBER(5), 커미션 NUMBER(5),"
    " 부서번호 NUMBER(2) REFERENCES 부서(부서번호));",
    "CREATE TABLE 급여등급 (등급 NUMBER(1) PRIMARY KEY, 최저급여 NUMBER(5), 최고급여 NUMBER(5));",
    *_to_insert_statements("부서", DEPARTMENT_ROWS),
    *_to_insert_statements("사원", EMPLOYEE_ROWS, date_column_indexes=(4,)),
    *_to_insert_statements("급여등급", SALARY_GRADE_ROWS),
])
