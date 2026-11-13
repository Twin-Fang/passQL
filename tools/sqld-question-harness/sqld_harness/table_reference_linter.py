"""
지문 표 이름 점검 (Oracle 불필요, #1017): 언급 표 존재, 이름 다른 같은 컬럼 표, 같은 이름 표 중복
표 출처 3개: tables(지문 표), ddl CREATE 문, 지문 안 [이름] 머리말 표 (화면에 보이는 표 전부)
"""
import re

from .findings import SEVERITY_ERROR, SEVERITY_WARNING

IDENTIFIER = r"[A-Za-z_][A-Za-z0-9_$#]*"
# 표 이름 자리 키워드 뒤 이름: FROM·JOIN·INTO·UPDATE·USING·TABLE (괄호 시작이면 서브쿼리·USING(컬럼)이라 제외)
TABLE_POSITION_PATTERN = re.compile(
    r"\b(?:FROM|JOIN|INTO|UPDATE|USING|TABLE)\s+(?!\()((?:" + IDENTIFIER + r"\.)?" + IDENTIFIER + r")", re.IGNORECASE)
# FROM 절 쉼표 목록의 두 번째 이후 표 (FROM A, B / FROM A X, B Y)
FROM_LIST_PATTERN = re.compile(
    r"\bFROM\s+(" + IDENTIFIER + r"(?:\s+(?!(?:WHERE|GROUP|ORDER|HAVING|CONNECT|START)\b)" + IDENTIFIER + r")?"
    r"(?:\s*,\s*" + IDENTIFIER + r"(?:\s+" + IDENTIFIER + r")?)+)", re.IGNORECASE)
# Oracle 은 DELETE 뒤 FROM 생략 가능 (DELETE EMP WHERE ...)
DELETE_WITHOUT_FROM_PATTERN = re.compile(r"\bDELETE\s+(?!FROM\b)(" + IDENTIFIER + r")", re.IGNORECASE)
# SQL 안에서 새로 만드는 이름 (CREATE TABLE·VIEW, WITH 절 이름) > 제공 표 아니어도 됨
CREATED_OBJECT_PATTERN = re.compile(
    r"\bCREATE\s+(?:OR\s+REPLACE\s+)?(?:GLOBAL\s+TEMPORARY\s+)?(?:MATERIALIZED\s+)?(?:TABLE|VIEW|SYNONYM)\s+("
    + IDENTIFIER + r")", re.IGNORECASE)
COMMON_TABLE_EXPRESSION_PATTERN = re.compile(
    r"(?:\bWITH|,)\s*(" + IDENTIFIER + r")\s*(?:\([^()]*\))?\s+AS\s*\(", re.IGNORECASE)
# 인자 안에 FROM 을 쓰는 함수 (EXTRACT(YEAR FROM d), TRIM(' ' FROM s))
FROM_INSIDE_FUNCTION_PATTERN = re.compile(r"\b(?:EXTRACT|TRIM|SUBSTRING|OVERLAY|POSITION)\s*\([^()]*\)", re.IGNORECASE)
CREATE_TABLE_BODY_PATTERN = re.compile(
    r"\bCREATE\s+(?:GLOBAL\s+TEMPORARY\s+)?TABLE\s+(" + IDENTIFIER + r")\s*\(", re.IGNORECASE)
CODE_FENCE_PATTERN = re.compile(r"```[A-Za-z]*\n?(.*?)```", re.DOTALL)
STEM_TABLE_LABEL_PATTERN = re.compile(r"^\s*\[(" + IDENTIFIER + r")\]\s*$", re.MULTILINE)
# 지문 글 언급: "EMP 테이블", "(A_T, B_T) 테이블", "테이블 EMP"
PROSE_TABLE_BEFORE_PATTERN = re.compile(
    r"(?<![A-Za-z0-9_])((?:[A-Z][A-Z0-9_]*\s*,\s*)*[A-Z][A-Z0-9_]*)\s*\)?\s*테이블")
PROSE_TABLE_AFTER_PATTERN = re.compile(r"테이블\s+([A-Z][A-Z0-9_]*)\b")
# 표 이름 자리에 와도 표가 아닌 낱말 (SQL 키워드, 가상 표, 글 속 약어)
NON_TABLE_WORDS = frozenset("""
SELECT FROM WHERE SET VALUES ALL DISTINCT LATERAL ONLY DUAL NULL SQL SQLD DBMS ORACLE ANSI DDL DML DCL TCL PK FK ERD
""".split())
DICTIONARY_VIEW_PREFIXES = ("USER_", "ALL_", "DBA_", "V$")
TABLE_CONSTRAINT_WORDS = ("CONSTRAINT", "PRIMARY", "FOREIGN", "UNIQUE", "CHECK")


def lint_table_references(question, add):
    """표 이름 점검 3개: 같은 이름 중복(error), 언급 표 없음(error), 이름 다른 같은 컬럼(warning)"""
    yaml_table_names = [str(table.get("name", "")).upper() for table in question.get("tables") or []]
    ddl_columns_by_table = _parse_create_table_columns(question.get("ddl"))
    ddl_table_names = [name for name, _ in ddl_columns_by_table]
    stem_label_names = [name.upper() for name in STEM_TABLE_LABEL_PATTERN.findall(str(question.get("stem") or ""))]

    _check_duplicate_table_names(yaml_table_names, "tables", add)
    _check_duplicate_table_names(ddl_table_names, "ddl", add)
    _check_duplicate_table_names(stem_label_names, "지문 [이름] 표", add)
    provided_names = set(yaml_table_names) | set(ddl_table_names) | set(stem_label_names)
    provided_names |= {name.upper() for name in CREATED_OBJECT_PATTERN.findall(str(question.get("ddl") or ""))}
    columns_by_table = _merge_columns_by_table(question, ddl_columns_by_table)
    _check_referenced_tables_exist(question, provided_names, columns_by_table, add)
    _check_same_columns_with_different_names(columns_by_table, add)


def _check_duplicate_table_names(table_names, source_label, add):
    """같은 출처 안 같은 이름 표 2개 > 화면에 같은 표가 두 번 또는 한쪽 데이터가 덮임"""
    duplicated_names = sorted({name for name in table_names if name and table_names.count(name) > 1})
    if duplicated_names:
        add(SEVERITY_ERROR, "stem.table-duplicate-name", f"{source_label} 에 같은 이름 표 중복: {', '.join(duplicated_names)}")


def _check_referenced_tables_exist(question, provided_names, columns_by_table, add):
    """지문 글·지문 SQL·displaySql 이 언급한 표 > tables·ddl·지문 표에 있어야 함 (제공 표가 하나도 없는 개념형은 생략)"""
    if not provided_names:
        return
    stem = str(question.get("stem") or "")
    sql_texts = CODE_FENCE_PATTERN.findall(stem) + [str(question.get("displaySql") or "")]
    referenced_names = set()
    for sql in sql_texts:
        referenced_names |= _extract_sql_table_names(sql)
    # 글 언급은 컬럼 이름 제외 ("테이블 SAL 합" 의 SAL)
    known_column_names = {str(column).upper() for columns in columns_by_table.values() for column in columns}
    referenced_names |= _extract_prose_table_names(CODE_FENCE_PATTERN.sub("\n", stem)) - known_column_names
    missing_names = sorted(name for name in referenced_names if name not in provided_names)
    if missing_names:
        add(SEVERITY_ERROR, "stem.table-reference-missing",
            f"지문이 언급한 표 {', '.join(missing_names)} 가 tables·ddl 에 없음 (제공 표: {', '.join(sorted(provided_names))})")


def _merge_columns_by_table(question, ddl_columns_by_table):
    """표 이름 > 컬럼 목록 (tables 위에 ddl 덮어씀, ddl 이 실제 스키마)"""
    columns_by_table = {str(table.get("name", "")).upper(): table.get("columns") or [] for table in question.get("tables") or []}
    columns_by_table.update(dict(ddl_columns_by_table))
    return columns_by_table


def _check_same_columns_with_different_names(columns_by_table, add):
    """이름 다른 표의 컬럼 구성(대소문자·순서 무시)이 같음 > 이름 없는 지문 표는 컬럼으로 자리를 맞춰 혼동 위험"""
    table_names_by_signature = {}
    for table_name, columns in columns_by_table.items():
        if table_name and columns:
            signature = tuple(sorted(str(column).upper() for column in columns))
            table_names_by_signature.setdefault(signature, []).append(table_name)
    for signature, table_names in table_names_by_signature.items():
        if len(table_names) > 1:
            add(SEVERITY_WARNING, "stem.same-columns-different-name",
                f"표 {', '.join(table_names)} 컬럼 구성 같음 ({', '.join(signature)}) > 화면 배치 혼동 위험, 지문 표엔 [이름] 머리말 필수")


def _extract_sql_table_names(sql):
    """SQL > 참조 표 이름 (주석·문자열 제거, 새로 만드는 표·WITH 이름·사전 뷰·DUAL 제외)"""
    text = re.sub(r"--[^\n]*", " ", sql)
    text = re.sub(r"'(?:[^']|'')*'", "''", text)
    text = FROM_INSIDE_FUNCTION_PATTERN.sub(" ", text)
    candidate_names = [name.split(".")[-1] for name in TABLE_POSITION_PATTERN.findall(text)]
    candidate_names += DELETE_WITHOUT_FROM_PATTERN.findall(text)
    for from_list in FROM_LIST_PATTERN.findall(text):
        candidate_names += [part.split()[0] for part in from_list.split(",")]
    created_names = {name.upper() for name in CREATED_OBJECT_PATTERN.findall(text)}
    created_names |= {name.upper() for name in COMMON_TABLE_EXPRESSION_PATTERN.findall(text)}
    return {name.upper() for name in candidate_names if _is_table_name(name) and name.upper() not in created_names}


def _extract_prose_table_names(prose):
    """지문 글 > "EMP 테이블" 같은 표 언급 이름"""
    names = set(PROSE_TABLE_AFTER_PATTERN.findall(prose))
    for name_list in PROSE_TABLE_BEFORE_PATTERN.findall(prose):
        names |= {name.strip() for name in name_list.split(",")}
    return {name for name in names if _is_table_name(name)}


def _is_table_name(name):
    upper_name = name.upper()
    return upper_name not in NON_TABLE_WORDS and not upper_name.startswith(DICTIONARY_VIEW_PREFIXES)


def _parse_create_table_columns(ddl):
    """ddl > [(표 이름 대문자, 컬럼 이름 목록)] (작성 순서, 같은 이름 반복도 그대로)"""
    text = re.sub(r"--[^\n]*", " ", str(ddl or ""))
    tables = []
    for match in CREATE_TABLE_BODY_PATTERN.finditer(text):
        body = _read_parenthesized_body(text, match.end() - 1)
        column_names = []
        for part in _split_top_level_commas(body):
            first_word = part.strip().split()[0].strip('"').upper() if part.strip() else ""
            if first_word and first_word not in TABLE_CONSTRAINT_WORDS:
                column_names.append(first_word)
        tables.append((match.group(1).upper(), column_names))
    return tables


def _read_parenthesized_body(text, open_index):
    depth = 0
    for index in range(open_index, len(text)):
        depth += {"(": 1, ")": -1}.get(text[index], 0)
        if depth == 0:
            return text[open_index + 1:index]
    return text[open_index + 1:]


def _split_top_level_commas(body):
    parts, depth, start = [], 0, 0
    for index, character in enumerate(body):
        depth += {"(": 1, ")": -1}.get(character, 0)
        if character == "," and depth == 0:
            parts.append(body[start:index])
            start = index + 1
    parts.append(body[start:])
    return parts
