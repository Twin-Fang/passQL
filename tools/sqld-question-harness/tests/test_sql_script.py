"""SQL 스크립트 순수 처리: 문장 분리·값 정규화·행 비교·INSERT 파싱"""
from decimal import Decimal

from sqld_harness.sql_script import (
    are_rows_equal,
    normalize_sql_text,
    normalize_value,
    parse_simple_insert_rows,
    split_sql_script,
)


def test_split_sql_script_separates_statements_and_plsql_block():
    script = "INSERT INTO T VALUES (1);\nBEGIN\n  NULL;\nEND;\n/\nSELECT 1 FROM DUAL;"
    assert split_sql_script(script) == ["INSERT INTO T VALUES (1)", "BEGIN\n  NULL;\nEND;", "SELECT 1 FROM DUAL"]


def test_split_sql_script_handles_empty_and_trailing_statement():
    assert split_sql_script(None) == []
    assert split_sql_script("SELECT 1 FROM DUAL") == ["SELECT 1 FROM DUAL"]


def test_normalize_value_turns_integral_decimal_into_int():
    assert normalize_value(Decimal("3")) == 3
    assert normalize_value(Decimal("2.5")) == 2.5
    assert normalize_value(4.0) == 4
    assert normalize_value("A ") == "A "


def test_are_rows_equal_respects_order_flag():
    assert are_rows_equal([[1], [2]], [[1], [2]], is_ordered=True)
    assert not are_rows_equal([[2], [1]], [[1], [2]], is_ordered=True)
    assert are_rows_equal([[2], [1]], [[1], [2]], is_ordered=False)
    assert not are_rows_equal(None, [], is_ordered=True)


def test_normalize_sql_text_ignores_case_whitespace_and_comments():
    assert normalize_sql_text("select *\n  from t; -- 주석") == normalize_sql_text("SELECT * FROM T")


def test_parse_simple_insert_rows_reads_literals():
    data = "INSERT INTO t VALUES ('A''B', NULL, -1.5);\nINSERT INTO T VALUES ('x,y', 2, 'NULL');"
    assert parse_simple_insert_rows(data) == {"T": [["A'B", None, -1.5], ["x,y", 2, "NULL"]]}


def test_parse_simple_insert_rows_returns_none_for_unsupported_statement():
    assert parse_simple_insert_rows("INSERT INTO T VALUES (TO_DATE('2026-01-01', 'YYYY-MM-DD'));") is None
    assert parse_simple_insert_rows("INSERT INTO T (ID) VALUES (1);") is None
