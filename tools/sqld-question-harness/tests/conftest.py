"""
테스트 공통: 하네스 패키지 경로, SQLite 대역 실행기(Oracle 없이 검증 로직 확인), --run-oracle 옵션
"""
import copy
import sqlite3
import sys
from pathlib import Path

import pytest

HARNESS_DIRECTORY = Path(__file__).resolve().parents[1]
FIXTURE_DIRECTORY = Path(__file__).resolve().parent / "fixtures"
sys.path.insert(0, str(HARNESS_DIRECTORY))

from sqld_harness.question_schema import load_questions  # noqa: E402
from sqld_harness.sql_script import normalize_rows, split_sql_script  # noqa: E402


def pytest_addoption(parser):
    parser.addoption("--run-oracle", action="store_true", help="Oracle Free 컨테이너 통합 테스트 실행")


def pytest_collection_modifyitems(config, items):
    if config.getoption("--run-oracle"):
        return
    skip_oracle = pytest.mark.skip(reason="Oracle 통합 테스트: --run-oracle 로 실행")
    for item in items:
        if "oracle" in item.keywords:
            item.add_marker(skip_oracle)


class SqliteQuestionSession:
    """Oracle 세션과 같은 모양 (run, reset, rollback) 의 SQLite 메모리 DB 세션"""

    def __init__(self, setup_script):
        self.setup_script = setup_script
        self.connection = sqlite3.connect(":memory:")

    def __enter__(self):
        self.reset()
        return self

    def __exit__(self, exc_type, exc, traceback):
        self.connection.close()

    def run(self, script):
        try:
            last_rows = None
            for statement in split_sql_script(script):
                cursor = self.connection.execute(statement)
                if cursor.description is not None:
                    last_rows = normalize_rows(cursor.fetchall())
            return last_rows, None
        except sqlite3.Error as error:
            return None, str(error)

    def reset(self):
        self.connection.rollback()
        table_names = [row[0] for row in self.connection.execute("SELECT name FROM sqlite_master WHERE type = 'table'")]
        for table_name in table_names:
            self.connection.execute(f'DROP TABLE "{table_name}"')
        for statement in split_sql_script(self.setup_script):
            self.connection.execute(statement)
        self.connection.commit()

    def rollback(self):
        self.connection.rollback()


class SqliteExecutor:
    """open_session 호출 수를 세는 대역 실행기 (캐시 적중 확인용)"""

    def __init__(self):
        self.opened_question_ids = []

    def open_session(self, question_id, setup_script):
        self.opened_question_ids.append(question_id)
        return SqliteQuestionSession(setup_script)


@pytest.fixture
def sqlite_executor():
    return SqliteExecutor()


@pytest.fixture
def fixture_questions():
    return load_questions(FIXTURE_DIRECTORY / "questions-v2.yaml")


@pytest.fixture
def not_in_question(fixture_questions):
    return copy.deepcopy(fixture_questions[0])


@pytest.fixture
def pick_question(fixture_questions):
    return copy.deepcopy(fixture_questions[1])


@pytest.fixture
def trend_catalog_path():
    return FIXTURE_DIRECTORY / "trend-catalog.yaml"
