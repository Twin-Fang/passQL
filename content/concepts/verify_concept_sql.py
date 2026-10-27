"""개념 SQL Oracle 21c 검증: 본문 SQL 블록 실행 > sqlChecks 결과 비교 > stemSql 검증 누락 확인
작성 규칙(블록마다 초기 데이터, '오류' 주석, '-- 문법' 블록)은 content/concepts/README.md"""
import argparse
import datetime
import os
import re
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

CONCEPTS_DIR = Path(__file__).resolve().parent
HARNESS_DIR = CONCEPTS_DIR.parent.parent / "tools" / "sqld-question-harness"
sys.path.insert(0, str(CONCEPTS_DIR))
sys.path.insert(0, str(HARNESS_DIR))

from build_concept_bundle import load_concepts  # noqa: E402
from concept_bundle import TOPIC_CODES  # noqa: E402
from concept_dataset import SETUP_SQL  # noqa: E402
from sqld_harness.oracle_executor import OracleExecutor  # noqa: E402
from sqld_harness.sql_script import are_rows_equal, normalize_sql_text  # noqa: E402

SYNTAX_ONLY_BLOCK_MARKER = "-- 문법"
EXPECTED_ERROR_MARKER = "오류"
# '오류' 주석에 적은 오류 번호 (있으면 실제 오류 번호와 맞아야 함)
ORACLE_ERROR_CODE_PATTERN = re.compile(r"ORA-\d{5}")
DEFAULT_WORKER_COUNT = 4
# 세션 날짜·언어 설정 고정 (XE 컨테이너 기본값 그대로 명시, 기본값이 바뀌어도 결과 동일)
SESSION_NLS_STATEMENTS = (
    "ALTER SESSION SET NLS_LANGUAGE = 'AMERICAN'",
    "ALTER SESSION SET NLS_TERRITORY = 'AMERICA'",
    "ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-RR'",
)


def extract_sql_blocks(markdown):
    """마크다운 > ```sql 블록 본문 목록 (문법 표시 블록 제외)"""
    blocks, buffer, is_inside_sql = [], [], False
    for line in (markdown or "").splitlines():
        stripped = line.strip()
        if not is_inside_sql and stripped.lower().startswith("```sql"):
            is_inside_sql, buffer = True, []
        elif is_inside_sql and stripped.startswith("```"):
            is_inside_sql = False
            body = "\n".join(buffer).strip()
            if body and not body.startswith(SYNTAX_ONLY_BLOCK_MARKER):
                blocks.append(body)
        elif is_inside_sql:
            buffer.append(line)
    return blocks


def split_line_comment(line):
    """한 줄 > (코드, 주석) ('--' 가 문자열 안이면 코드로 봄)"""
    is_inside_quote = False
    for index, character in enumerate(line):
        if character == "'":
            is_inside_quote = not is_inside_quote
        elif not is_inside_quote and line.startswith("--", index):
            return line[:index], line[index:]
    return line, ""


def split_statements(script):
    """스크립트 > [(문장, 기대 오류)] (줄 끝 주석 제거 후 ';' 로 분리)
    기대 오류: None 성공 기대, "" 오류 기대(번호 없음), "ORA-xxxxx" 그 번호의 오류 기대"""
    statements, code_lines, comments = [], [], []
    for line in (script or "").splitlines():
        code, comment = split_line_comment(line)
        code_lines.append(code)
        comments.append(comment)
        if code.rstrip().endswith(";"):
            sql = "\n".join(code_lines).strip().rstrip(";").strip()
            if sql:
                statements.append((sql, to_expected_error(comments)))
            code_lines, comments = [], []
    rest = "\n".join(code_lines).strip()
    if rest:
        statements.append((rest.rstrip(";"), to_expected_error(comments)))
    return statements


def to_expected_error(comments):
    """문장 주석들 > 기대 오류 ('오류' 표시 없으면 None, 표시 주석에 번호가 있으면 그 번호)"""
    error_comments = [text for text in comments if EXPECTED_ERROR_MARKER in text]
    if not error_comments:
        return None
    codes = ORACLE_ERROR_CODE_PATTERN.findall(" ".join(error_comments))
    return codes[0] if codes else ""


def to_comparable_rows(rows):
    """날짜 > 'YYYY-MM-DD'(시각이 있으면 'YYYY-MM-DD HH:MM:SS') 문자열"""
    def to_value(value):
        if isinstance(value, datetime.datetime):
            return value.strftime("%Y-%m-%d" if value.time() == datetime.time() else "%Y-%m-%d %H:%M:%S")
        return value
    return [[to_value(value) for value in row] for row in rows]


class ConceptSqlVerifier:
    """개념 1개 검증: 전용 스키마 세션 > 블록·검증 항목마다 초기화 후 실행"""

    def __init__(self, executor, concept):
        self.executor = executor
        self.concept = concept
        self.failures = []
        self.statement_count = 0

    def verify(self):
        # 스키마 이름에 프로세스 번호 포함 (같은 개념을 여러 세션이 동시에 검증해도 충돌 없음)
        with self.executor.open_session(f"{self.concept['tagKey']}#{os.getpid()}", SETUP_SQL) as session:
            self.session = session
            with session.connection.cursor() as cursor:
                for statement in SESSION_NLS_STATEMENTS:
                    cursor.execute(statement)
            for index, block in enumerate(self._collect_blocks(), start=1):
                self._run_block(f"block {index}", block)
            for index, check in enumerate(self.concept.get("sqlChecks") or [], start=1):
                self._run_check(f"check {index}", check)
        self._verify_stem_sql_coverage()
        return self.failures

    def _collect_blocks(self):
        blocks = extract_sql_blocks(self.concept.get("coreMd")) + extract_sql_blocks(self.concept.get("detailMd"))
        return blocks

    def _execute(self, sql):
        """문장 1개 > (행 또는 None, 오류 첫 줄 또는 None)"""
        self.statement_count += 1
        try:
            with self.session.connection.cursor() as cursor:
                cursor.execute(sql)
                rows = cursor.fetchall() if cursor.description is not None else None
            return (to_comparable_rows(rows) if rows is not None else None), None
        except self.executor.oracledb.Error as error:
            return None, str(error).splitlines()[0]

    def _run_script(self, where, script):
        """스크립트 실행 > 마지막 조회 행 (기대와 다른 오류·성공은 실패로 기록)"""
        last_rows = None
        for sql, expected_error in split_statements(script):
            rows, error = self._execute(sql)
            if error and expected_error is None:
                self.failures.append(f"{where}: unexpected error {error} : {sql[:120]}")
            elif expected_error is not None and not error:
                self.failures.append(f"{where}: expected error but succeeded : {sql[:120]}")
            elif error and expected_error and expected_error not in error:
                self.failures.append(f"{where}: expected {expected_error}, got {error} : {sql[:120]}")
            if rows is not None:
                last_rows = rows
        return last_rows

    def _run_block(self, where, block):
        self.session.reset()
        self._run_script(where, block)

    def _run_check(self, where, check):
        self.session.reset()
        if check.get("setup"):
            self._run_script(where + " setup", check["setup"])
        statements = split_statements(check["sql"])
        if check.get("errorCode"):
            last_error = None
            for sql, _ in statements:
                _, last_error = self._execute(sql)
            if not last_error or check["errorCode"] not in last_error:
                self.failures.append(f"{where}: expected {check['errorCode']}, got {last_error} : {check['sql'][:120]}")
            return
        last_rows = None
        for sql, _ in statements:
            rows, error = self._execute(sql)
            if error:
                self.failures.append(f"{where}: error {error} : {sql[:120]}")
                return
            if rows is not None:
                last_rows = rows
        if not are_rows_equal(last_rows, check["rows"], check.get("isOrdered", False)):
            self.failures.append(f"{where}: rows mismatch expected {check['rows']} actual {last_rows} : {check['sql'][:120]}")

    def _verify_stem_sql_coverage(self):
        checked_sql_texts = {normalize_sql_text(check["sql"]) for check in self.concept.get("sqlChecks") or []}
        for question in self.concept.get("checkQuestions") or []:
            stem_sql = question.get("stemSql")
            if stem_sql and normalize_sql_text(stem_sql) not in checked_sql_texts:
                self.failures.append(f"Q{question['sortOrder']}: stemSql has no matching sqlChecks entry")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--topic", choices=TOPIC_CODES)
    parser.add_argument("--tag-key", action="append", default=[])
    parser.add_argument("--workers", type=int, default=DEFAULT_WORKER_COUNT)
    args = parser.parse_args()

    concepts = [concept for _, concept in load_concepts(args.topic)
                if not args.tag_key or concept["tagKey"] in args.tag_key]
    executor = OracleExecutor()
    try:
        def verify_one(concept):
            verifier = ConceptSqlVerifier(executor, concept)
            return concept["tagKey"], verifier.verify(), verifier.statement_count

        with ThreadPoolExecutor(max_workers=args.workers) as pool:
            results = list(pool.map(verify_one, concepts))
    finally:
        executor.close()

    failed_count = 0
    for tag_key, failures, statement_count in results:
        print(f"{'FAIL' if failures else 'OK  '} {tag_key} ({statement_count} statements)")
        for failure in failures:
            print(f"     {failure}")
        failed_count += bool(failures)
    print(f"[concept sql] {len(results) - failed_count}/{len(results)} concepts passed")
    sys.exit(1 if failed_count else 0)


if __name__ == "__main__":
    main()
