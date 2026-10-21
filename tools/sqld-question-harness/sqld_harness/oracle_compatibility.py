"""
Oracle 버전 호환 점검 (Oracle 불필요): 23ai 부터 허용된 문법 5종 사용 탐지 > warning
시험 기준(19c 이하)에서는 오류인 문법이라, 23ai 이상 DB 로 검증하면 시험과 다른 결과가 통과할 수 있음
"""
import re

from .findings import SEVERITY_WARNING, Finding
from .question_schema import get_choices
from .sql_script import split_sql_script

RULE_ORACLE_VERSION = "compat.oracle-23ai-syntax"
# 보기 본문을 SQL 로 보는 시작 키워드 (kind 누락 보기 포함)
SQL_BODY_START_PATTERN = re.compile(r"^\s*(SELECT|WITH|INSERT|UPDATE|DELETE|MERGE|CREATE|ALTER|DROP)\b", re.IGNORECASE)
# SELECT 목록의 AS 별칭 (식 AS 이름)
SELECT_ALIAS_PATTERN = re.compile(r"\bAS\s+([A-Za-z_][A-Za-z0-9_$#]*)", re.IGNORECASE)
# GROUP BY·HAVING 절 본문 (다음 절 키워드 또는 문장 끝까지)
GROUPING_CLAUSE_PATTERN = re.compile(r"\b(GROUP\s+BY|HAVING)\b(.*?)(?=\bGROUP\s+BY\b|\bHAVING\b|\bORDER\s+BY\b|\bUNION\b|\bMINUS\b|\bINTERSECT\b|\)|$)", re.IGNORECASE | re.DOTALL)
IDENTIFIER_PATTERN = re.compile(r"[A-Za-z_][A-Za-z0-9_$#]*")
STRING_LITERAL_PATTERN = re.compile(r"'(?:[^']|'')*'")
# 23ai 전용 문법 4종 (별칭은 아래 함수에서 따로 판정)
SYNTAX_PATTERNS = {
    "FROM 없는 SELECT": re.compile(r"^\s*SELECT\b(?![\s\S]*\bFROM\b)", re.IGNORECASE),
    "다중 행 VALUES": re.compile(r"\bVALUES\s*\([^()]*(?:\([^()]*\)[^()]*)*\)\s*,\s*\(", re.IGNORECASE),
    "BOOLEAN 타입·리터럴": re.compile(r"\bBOOLEAN\b|\bIS\s+(NOT\s+)?(TRUE|FALSE)\b|=\s*(TRUE|FALSE)\b", re.IGNORECASE),
    "IF [NOT] EXISTS": re.compile(r"\b(CREATE|DROP)\b[^;]*?\bIF\s+(NOT\s+)?EXISTS\b", re.IGNORECASE),
}


def find_oracle_compatibility_findings(question):
    """문제 1건 SQL (ddl·data·정답·지문·SQL 보기) > 23ai 전용 문법 finding 목록"""
    question_id = str(question.get("id"))
    findings = []
    for location, sql in _iterate_question_sql(question):
        for syntax_name in find_23ai_only_syntax(sql):
            findings.append(Finding(SEVERITY_WARNING, RULE_ORACLE_VERSION, question_id, f"{location}: {syntax_name} (19c 오류, 23ai 이상만 허용)"))
    return findings


def find_23ai_only_syntax(sql):
    """SQL 문장들 > 사용한 23ai 전용 문법 이름 목록 (문자열 리터럴 안은 제외)"""
    syntax_names = []
    for statement in split_sql_script(sql or ""):
        searchable = STRING_LITERAL_PATTERN.sub("''", statement)
        syntax_names += [name for name, pattern in SYNTAX_PATTERNS.items() if pattern.search(searchable)]
        if _uses_select_alias_in_grouping(searchable):
            syntax_names.append("GROUP BY·HAVING 에서 SELECT 별칭 참조")
    return list(dict.fromkeys(syntax_names))


def _iterate_question_sql(question):
    """점검 대상 (위치 이름, SQL) 목록: 스키마·데이터·정답·지문 SQL + SQL 로 시작하는 보기"""
    for field_name in ("ddl", "data", "answerSql", "displaySql"):
        if question.get(field_name):
            yield field_name, question[field_name]
    for index, choice in enumerate(get_choices(question)):
        body = choice.get("body") or ""
        if choice.get("kind") == "SQL" or SQL_BODY_START_PATTERN.match(body):
            yield f"choices[{index}]", body


def _uses_select_alias_in_grouping(statement):
    """같은 문장 GROUP BY·HAVING 절이 SELECT 목록 AS 별칭을 이름으로 참조 (단순 판정: 실제 컬럼명과 같은 별칭은 제외)"""
    select_head = re.split(r"\bFROM\b", statement, maxsplit=1, flags=re.IGNORECASE)[0]
    aliases = {alias.upper() for alias in SELECT_ALIAS_PATTERN.findall(select_head)}
    if not aliases:
        return False
    column_names_in_expressions = _find_source_column_names(select_head)
    alias_only_names = aliases - column_names_in_expressions
    for _, clause_body in GROUPING_CLAUSE_PATTERN.findall(statement):
        referenced_names = {name.upper() for name in IDENTIFIER_PATTERN.findall(clause_body)}
        if referenced_names & alias_only_names:
            return True
    return False


def _find_source_column_names(select_head):
    """SELECT 목록에서 AS 앞 식에 쓰인 이름들 (별칭과 같은 이름의 원래 컬럼 구분용)"""
    expressions_only = SELECT_ALIAS_PATTERN.sub(" ", select_head)
    return {name.upper() for name in IDENTIFIER_PATTERN.findall(expressions_only)}
