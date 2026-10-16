"""
SQLD 고정 보기 문제 검증 하네스: 문제 YAML > Oracle 실행 > 보기 기대값 대조 > 통과분만 가져오기 JSON (#511)

사용:
  python harness.py verify  <문제 YAML 폴더> [--output import.json]
  python harness.py render  <문제 YAML 1개>           # 지문 미리보기

보기 expect 4종 (보기마다 1개):
  rows: [[...], ...]        정답 SQL 결과 행과 비교 (ordered: false 면 순서 무시)
  scalar: 값                정답 SQL 결과 1행 1열과 비교
  same_as_answer: true|false  보기 body(SQL)를 실행한 결과가 정답 SQL 결과와 같은지
  error: true|false         보기 body(SQL) 실행 시 오류 발생 여부
  body_rows: [[...]]        보기 body(SQL) 실행 결과 자체 (정답·오답 모두 사실이어야 함)
  count: n                  보기 body(SQL) 결과 행 수 (문제 pick: max|min 이면 정답이 유일한 최대·최소인지 확인)
  concept: true             실행 불가 설명형 (문제의 sourceNote 필수)
정답 보기는 expect 가 참이어야 하고, 오답 보기는 rows·scalar 의 경우 불일치여야 한다.
"""
import argparse
import json
import os
import re
import sys
from decimal import Decimal
from pathlib import Path

import oracledb
import yaml

# Oracle Free 컨테이너 접속 (docker run -p 1521:1521 gvenzl/oracle-free:23-slim-faststart)
ORACLE_DSN = os.environ.get("SQLD_HARNESS_DSN", "localhost:1521/FREEPDB1")
ORACLE_ADMIN_USER = os.environ.get("SQLD_HARNESS_ADMIN_USER", "system")
ORACLE_ADMIN_PASSWORD = os.environ.get("SQLD_HARNESS_ADMIN_PASSWORD", "harness")
# 문제별 임시 스키마 이름 접두사 (실행 후 삭제)
QUESTION_SCHEMA_PREFIX = "SQLDQ_"
QUESTION_SCHEMA_PASSWORD = "harness"

CHOICE_KEYS = ["A", "B", "C", "D"]


# ── SQL 실행 ─────────────────────────────────────────────

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
    return first_line.startswith(("BEGIN", "DECLARE", "CREATE OR REPLACE"))


def normalize_value(value):
    """DB 값 > 비교용 값 (Decimal 정수화, 문자열 우측 공백 유지)"""
    if isinstance(value, Decimal):
        return int(value) if value == value.to_integral_value() else float(value)
    if isinstance(value, float) and value.is_integer():
        return int(value)
    return value


def run_script(connection, script):
    """스크립트 전체 실행 > 마지막 SELECT 결과 행 (없으면 None), 오류는 예외"""
    last_rows = None
    with connection.cursor() as cursor:
        for statement in split_sql_script(script):
            cursor.execute(statement)
            if cursor.description is not None:
                last_rows = [[normalize_value(value) for value in row] for row in cursor.fetchall()]
    return last_rows


def run_script_or_error(connection, script):
    """스크립트 > (결과 행, 오류 문자열) 둘 중 하나"""
    try:
        return run_script(connection, script), None
    except oracledb.Error as error:
        return None, str(error).splitlines()[0]


# ── 문제별 격리 스키마 ────────────────────────────────────

class QuestionSchema:
    """문제 1건 전용 스키마: 생성 > DDL·데이터 적용 > 사용 > 삭제 (성공·실패 공통)"""

    def __init__(self, admin_connection, question_id, setup_script):
        self.admin_connection = admin_connection
        self.schema_name = QUESTION_SCHEMA_PREFIX + re.sub(r"[^A-Z0-9]", "_", question_id.upper())[:20]
        self.setup_script = setup_script
        self.connection = None

    def __enter__(self):
        self._drop_schema()
        with self.admin_connection.cursor() as cursor:
            cursor.execute(f'CREATE USER {self.schema_name} IDENTIFIED BY "{QUESTION_SCHEMA_PASSWORD}" QUOTA UNLIMITED ON USERS')
            cursor.execute(f"GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE TO {self.schema_name}")
        self.connection = oracledb.connect(user=self.schema_name, password=QUESTION_SCHEMA_PASSWORD, dsn=ORACLE_DSN)
        self.reset()
        return self

    def reset(self):
        """테이블 초기화: 기존 객체 삭제 > 설정 스크립트 재적용 (보기마다 같은 초기 데이터)"""
        with self.connection.cursor() as cursor:
            cursor.execute("SELECT object_name, object_type FROM user_objects WHERE object_type IN ('TABLE','VIEW','SEQUENCE')")
            for object_name, object_type in cursor.fetchall():
                suffix = " CASCADE CONSTRAINTS PURGE" if object_type == "TABLE" else ""
                cursor.execute(f'DROP {object_type} "{object_name}"{suffix}')
        run_script(self.connection, self.setup_script)
        self.connection.commit()

    def __exit__(self, exc_type, exc, traceback):
        if self.connection is not None:
            self.connection.close()
        self._drop_schema()

    def _drop_schema(self):
        with self.admin_connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) FROM dba_users WHERE username = :name", name=self.schema_name)
            if cursor.fetchone()[0]:
                cursor.execute(f"DROP USER {self.schema_name} CASCADE")


# ── 검증 ─────────────────────────────────────────────────

def rows_equal(actual_rows, expected_rows, is_ordered):
    if actual_rows is None or expected_rows is None:
        return False
    actual = [[normalize_value(value) for value in row] for row in actual_rows]
    expected = [[normalize_value(value) for value in row] for row in expected_rows]
    if is_ordered:
        return actual == expected
    return sorted(map(repr, actual)) == sorted(map(repr, expected))


def evaluate_choice(schema, answer_rows, choice):
    """보기 1개 > (expect 성립 여부, 상세). 실행이 필요한 보기는 초기 데이터에서 실행"""
    expect = choice.get("expect") or {}
    if "rows" in expect:
        return rows_equal(answer_rows, expect["rows"], expect.get("ordered", True)), f"answer={answer_rows}"
    if "scalar" in expect:
        actual = answer_rows[0][0] if answer_rows and answer_rows[0] else None
        return actual == normalize_value(expect["scalar"]), f"answer scalar={actual!r}"
    if "same_as_answer" in expect:
        schema.reset()
        choice_rows, error = run_script_or_error(schema.connection, choice["body"])
        is_same = error is None and rows_equal(choice_rows, answer_rows, expect.get("ordered", False))
        return is_same == bool(expect["same_as_answer"]), f"choice={choice_rows} error={error}"
    if "error" in expect:
        schema.reset()
        _, error = run_script_or_error(schema.connection, choice["body"])
        schema.connection.rollback()
        return (error is not None) == bool(expect["error"]), f"error={error}"
    if "body_rows" in expect:
        schema.reset()
        choice_rows, error = run_script_or_error(schema.connection, choice["body"])
        return error is None and rows_equal(choice_rows, expect["body_rows"], expect.get("ordered", True)), f"choice={choice_rows} error={error}"
    if "count" in expect:
        schema.reset()
        choice_rows, error = run_script_or_error(schema.connection, choice["body"])
        actual_count = None if error else len(choice_rows or [])
        choice["_actual_count"] = actual_count
        return actual_count == int(expect["count"]), f"count={actual_count} error={error}"
    if expect.get("concept"):
        return True, "concept (manual review)"
    return False, "expect 누락"


def find_question_reject_reason(question):
    """구조 검증: 보기 4개·정답 1개·근거 필수·개념형 근거 출처"""
    choices = question.get("choices") or []
    if len(choices) != len(CHOICE_KEYS):
        return f"보기 {len(choices)}개 (4개 필요)"
    if sum(1 for choice in choices if choice.get("isCorrect")) != 1:
        return "정답 보기 1개 필요"
    for choice in choices:
        if not choice.get("rationale"):
            return f"보기 근거(rationale) 누락: {choice.get('body')!r}"
    has_concept_choice = any((choice.get("expect") or {}).get("concept") for choice in choices)
    if has_concept_choice and not question.get("sourceNote"):
        return "개념형 보기는 sourceNote(근거 출처) 필수"
    return None


def verify_question(admin_connection, question):
    """문제 1건 > (통과 여부, 보고 줄 목록)"""
    reject_reason = find_question_reject_reason(question)
    if reject_reason:
        return False, [reject_reason]
    setup_script = "\n".join(filter(None, [question.get("ddl"), question.get("data")]))
    report_lines = []
    with QuestionSchema(admin_connection, question["id"], setup_script) as schema:
        answer_rows, answer_error = (None, None)
        if question.get("answerSql"):
            answer_rows, answer_error = run_script_or_error(schema.connection, question["answerSql"])
            if answer_error:
                return False, [f"정답 SQL 오류: {answer_error}"]
        is_passed = True
        for index, choice in enumerate(question["choices"]):
            is_expect_true, detail = evaluate_choice(schema, answer_rows, choice)
            is_choice_ok = is_expect_true if choice.get("isCorrect") else _is_wrong_choice_ok(choice, is_expect_true)
            is_passed = is_passed and is_choice_ok
            mark = "ok" if is_choice_ok else "NG"
            report_lines.append(f"  [{mark}] {CHOICE_KEYS[index]} correct={bool(choice.get('isCorrect'))} {detail}")
    pick_reject_reason = find_pick_reject_reason(question)
    if pick_reject_reason:
        report_lines.append(f"  [NG] pick: {pick_reject_reason}")
        is_passed = False
    return is_passed, report_lines


def find_pick_reject_reason(question):
    """pick: max|min > 정답 보기 행 수가 유일한 최대·최소인지 (count 보기 전용)"""
    pick = question.get("pick")
    if not pick:
        return None
    counts = [choice.get("_actual_count") for choice in question["choices"]]
    if any(count is None for count in counts):
        return "count 보기 실행 실패"
    target = max(counts) if pick == "max" else min(counts)
    correct_count = next(choice["_actual_count"] for choice in question["choices"] if choice.get("isCorrect"))
    if correct_count != target or counts.count(target) != 1:
        return f"정답이 유일한 {pick} 아님 counts={counts}"
    return None


def _is_wrong_choice_ok(choice, is_expect_true):
    """오답 보기: rows·scalar 는 정답 결과와 불일치해야 함, 나머지는 expect 가 사실이어야 함"""
    expect = choice.get("expect") or {}
    if "rows" in expect or "scalar" in expect:
        return not is_expect_true
    return is_expect_true


# ── 가져오기 JSON ─────────────────────────────────────────

def render_markdown_table(table):
    header = "| " + " | ".join(table["columns"]) + " |"
    divider = "| " + " | ".join("---" for _ in table["columns"]) + " |"
    body = ["| " + " | ".join("NULL" if value is None else str(value) for value in row) + " |" for row in table["rows"]]
    return "\n".join([f"[{table['name']}]", header, divider, *body])


def render_stem(question):
    """지문 + 데이터 표 + SQL 블록 (개념형은 스키마 화면이 없어 지문에 데이터 포함)"""
    parts = [question["stem"].strip()]
    for table in question.get("tables") or []:
        parts.append(render_markdown_table(table))
    if question.get("displaySql"):
        parts.append("```sql\n" + question["displaySql"].strip() + "\n```")
    return "\n\n".join(parts)


def to_import_item(question):
    choices = [
        {
            "choiceKey": CHOICE_KEYS[index],
            "kind": choice.get("kind", "TEXT"),
            "body": str(choice["body"]),
            "isCorrect": bool(choice.get("isCorrect")),
            "rationale": choice["rationale"],
        }
        for index, choice in enumerate(question["choices"])
    ]
    return {
        "questionUuid": question.get("questionUuid"),
        "topicCode": question["topicCode"],
        "difficulty": question["difficulty"],
        # Oracle 기준 검증 문제 > 운영 샌드박스(PostgreSQL) 실행 대상 아님
        "executionMode": "CONCEPT_ONLY",
        "choiceSetPolicy": "CURATED_ONLY",
        "stem": render_stem(question),
        "hint": question.get("hint"),
        "schemaDdl": question.get("ddl"),
        "schemaSampleData": question.get("data"),
        "schemaIntent": question.get("intent"),
        "answerSql": question.get("answerSql"),
        "choices": choices,
    }


def load_questions(path):
    files = sorted(Path(path).glob("*.yaml")) if Path(path).is_dir() else [Path(path)]
    questions = []
    for file in files:
        for document in yaml.safe_load_all(file.read_text(encoding="utf-8")):
            if document:
                document.setdefault("id", f"{file.stem}_{len(questions)}")
                questions.append(document)
    return questions


def command_verify(arguments):
    questions = load_questions(arguments.path)
    admin_connection = oracledb.connect(user=ORACLE_ADMIN_USER, password=ORACLE_ADMIN_PASSWORD, dsn=ORACLE_DSN)
    admin_connection.autocommit = True
    passed_items, failed_ids = [], []
    for question in questions:
        try:
            is_passed, report_lines = verify_question(admin_connection, question)
        except Exception as error:  # 하네스 자체 오류도 문제 실패로 기록 (전체 중단 방지)
            is_passed, report_lines = False, [f"harness error: {error}"]
        print(f"[{'PASS' if is_passed else 'FAIL'}] {question['id']} ({question.get('topicCode')})")
        for line in report_lines:
            print(line)
        (passed_items.append(to_import_item(question)) if is_passed else failed_ids.append(question["id"]))
    admin_connection.close()
    Path(arguments.output).write_text(json.dumps(passed_items, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\n[sqld harness] passed {len(passed_items)} / {len(questions)} > {arguments.output}")
    if failed_ids:
        print("[sqld harness] failed : " + ", ".join(failed_ids))
    return 0 if not failed_ids else 1


def command_render(arguments):
    for question in load_questions(arguments.path):
        print(render_stem(question))
        for index, choice in enumerate(question["choices"]):
            print(f"{CHOICE_KEYS[index]}. {choice['body']}{'  (정답)' if choice.get('isCorrect') else ''}")
        print("-" * 40)
    return 0


def main():
    parser = argparse.ArgumentParser(description="SQLD 고정 보기 문제 Oracle 검증 하네스")
    subparsers = parser.add_subparsers(dest="command", required=True)
    verify_parser = subparsers.add_parser("verify")
    verify_parser.add_argument("path")
    verify_parser.add_argument("--output", default="import.json")
    render_parser = subparsers.add_parser("render")
    render_parser.add_argument("path")
    arguments = parser.parse_args()
    return {"verify": command_verify, "render": command_render}[arguments.command](arguments)


if __name__ == "__main__":
    sys.exit(main())
