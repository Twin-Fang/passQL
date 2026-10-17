"""
SQL 스크립트 순수 처리: 문장 분리, DB 값 정규화, 결과 행 비교, INSERT 리터럴 파싱 (DB 연결 없음)
"""
import re
from decimal import Decimal

PLSQL_BLOCK_PREFIXES = ("BEGIN", "DECLARE", "CREATE OR REPLACE")


def split_sql_script(script):
    """스크립트 > 문장 목록 (';' 줄 끝 기준, PL/SQL 블록은 '/' 단독 줄로 구분)"""
    if not script:
        return []
    statements, buffer = [], []
    for line in script.splitlines():
        stripped = line.strip()
        if stripped == "/":
            statements.append("\n".join(buffer).strip())
            buffer = []
            continue
        buffer.append(line)
        if stripped.endswith(";") and not _is_inside_plsql_block(buffer):
            statements.append("\n".join(buffer).strip().rstrip(";"))
            buffer = []
    rest = "\n".join(buffer).strip()
    if rest:
        statements.append(rest.rstrip(";"))
    return [statement for statement in statements if statement]


def _is_inside_plsql_block(buffer):
    first_line = buffer[0].strip().upper() if buffer else ""
    return first_line.startswith(PLSQL_BLOCK_PREFIXES)


def normalize_value(value):
    """DB 값 > 비교용 값 (Decimal·정수 float 정수화, 문자열 그대로)"""
    if isinstance(value, Decimal):
        return int(value) if value == value.to_integral_value() else float(value)
    if isinstance(value, float) and value.is_integer():
        return int(value)
    return value


def normalize_rows(rows):
    return [[normalize_value(value) for value in row] for row in rows]


def are_rows_equal(actual_rows, expected_rows, is_ordered):
    """결과 행 비교 (is_ordered False 면 순서 무시, None 은 불일치)"""
    if actual_rows is None or expected_rows is None:
        return False
    actual = normalize_rows(actual_rows)
    expected = normalize_rows(expected_rows)
    if is_ordered:
        return actual == expected
    return sorted(map(repr, actual)) == sorted(map(repr, expected))


def normalize_sql_text(sql):
    """SQL 비교용: 주석 제거 > 공백 1칸 > 대문자 > 끝 ';' 제거"""
    if not sql:
        return ""
    without_comments = re.sub(r"--[^\n]*", " ", sql)
    return re.sub(r"\s+", " ", without_comments).strip().rstrip(";").strip().upper()


# INSERT INTO 테이블 VALUES (...) 1문장 (컬럼 목록·서브쿼리·함수 호출은 파싱 대상 아님)
SIMPLE_INSERT_PATTERN = re.compile(r"^\s*INSERT\s+INTO\s+(\w+)\s+VALUES\s*\((.*)\)\s*;?\s*$", re.IGNORECASE | re.DOTALL)
# 리터럴 1개: '문자열'('' 이스케이프) | 숫자 | NULL
LITERAL_PATTERN = re.compile(r"\s*('(?:[^']|'')*'|-?\d+(?:\.\d+)?|NULL)\s*(,|$)", re.IGNORECASE)


def parse_simple_insert_rows(data_script):
    """data 스크립트 > {테이블 대문자: 행 목록}. 파싱 못 하는 문장이 있으면 None (비교 생략 신호)"""
    rows_by_table = {}
    for statement in split_sql_script(data_script):
        match = SIMPLE_INSERT_PATTERN.match(statement)
        if not match:
            return None
        values = _parse_literal_list(match.group(2))
        if values is None:
            return None
        rows_by_table.setdefault(match.group(1).upper(), []).append(values)
    return rows_by_table


def _parse_literal_list(text):
    values, position = [], 0
    while position < len(text):
        match = LITERAL_PATTERN.match(text, position)
        if not match:
            return None
        values.append(_to_literal_value(match.group(1)))
        position = match.end()
        if match.group(2) == "":
            break
    return values if position >= len(text.rstrip()) else None


def _to_literal_value(token):
    if token.upper() == "NULL":
        return None
    if token.startswith("'"):
        return token[1:-1].replace("''", "'")
    return normalize_value(Decimal(token))


def to_display_value(value):
    """표 표시값 > 비교용 (YAML 숫자·문자 혼용 흡수)"""
    if value is None:
        return None
    if isinstance(value, bool):
        return str(value).upper()
    if isinstance(value, (int, float)):
        return normalize_value(Decimal(str(value)))
    return str(value)
