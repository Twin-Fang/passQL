"""보기 기대값 검증 로직 (SQLite 대역 실행기, Oracle 불필요)"""
from sqld_harness.choice_verifier import verify_question_with_executor


def test_scalar_question_passes(sqlite_executor, not_in_question):
    result = verify_question_with_executor(sqlite_executor, not_in_question)
    assert result.is_passed, result.report_lines


def test_wrong_scalar_marked_correct_fails(sqlite_executor, not_in_question):
    not_in_question["choices"][0]["isCorrect"] = False
    not_in_question["choices"][1]["isCorrect"] = True
    result = verify_question_with_executor(sqlite_executor, not_in_question)
    assert not result.is_passed
    assert sum("[NG]" in line for line in result.report_lines) == 2


def test_wrong_choice_equal_to_answer_fails(sqlite_executor, not_in_question):
    not_in_question["choices"][1]["expect"] = {"scalar": 0}
    assert not verify_question_with_executor(sqlite_executor, not_in_question).is_passed


def test_rows_expect_ordered_and_unordered(sqlite_executor, not_in_question):
    not_in_question["answerSql"] = "SELECT ID FROM T1 ORDER BY ID DESC;"
    not_in_question["choices"][0]["expect"] = {"rows": [[1], [2], [3]], "ordered": False}
    for choice, rows in zip(not_in_question["choices"][1:], ([[1]], [[2]], [[3]])):
        choice["expect"] = {"rows": rows}
    assert verify_question_with_executor(sqlite_executor, not_in_question).is_passed


def test_choice_sql_expect_types(sqlite_executor, not_in_question):
    not_in_question["choices"] = [
        {"body": "SELECT COUNT(*) FROM T1 WHERE ID NOT IN (SELECT ID FROM T2)", "isCorrect": True, "expect": {"same_as_answer": True}, "rationale": "r"},
        {"body": "SELECT * FROM NO_TABLE", "expect": {"error": True}, "rationale": "r"},
        {"body": "SELECT ID FROM T1 ORDER BY ID", "expect": {"body_rows": [[1], [2], [3]]}, "rationale": "r"},
        {"body": "SELECT COUNT(*) FROM T1 WHERE ID NOT IN (SELECT ID FROM T2 WHERE ID IS NOT NULL)", "expect": {"same_as_answer": False}, "rationale": "r"},
    ]
    result = verify_question_with_executor(sqlite_executor, not_in_question)
    assert result.is_passed, result.report_lines


def test_dml_choice_runs_on_fresh_data(sqlite_executor, not_in_question):
    """보기마다 reset: 앞 보기의 DELETE 가 뒤 보기 결과에 영향 없음"""
    not_in_question["choices"] = [
        {"body": "DELETE FROM T1;\nSELECT COUNT(*) FROM T1", "isCorrect": True, "expect": {"body_rows": [[0]]}, "rationale": "r"},
        {"body": "SELECT COUNT(*) FROM T1", "expect": {"body_rows": [[3]]}, "rationale": "r"},
        {"body": "SELECT COUNT(*) FROM T2", "expect": {"body_rows": [[2]]}, "rationale": "r"},
        {"body": "SELECT 1", "expect": {"error": False}, "rationale": "r"},
    ]
    assert verify_question_with_executor(sqlite_executor, not_in_question).is_passed


def test_pick_max_requires_unique_maximum(sqlite_executor, pick_question):
    assert verify_question_with_executor(sqlite_executor, pick_question).is_passed
    pick_question["choices"][2]["body"] = "SELECT ID FROM A"
    pick_question["choices"][2]["expect"] = {"count": 3}
    result = verify_question_with_executor(sqlite_executor, pick_question)
    assert not result.is_passed and "pick" in result.report_lines[-1]


def test_answer_sql_error_fails_without_choice_lines(sqlite_executor, not_in_question):
    not_in_question["answerSql"] = "SELECT FROM"
    result = verify_question_with_executor(sqlite_executor, not_in_question)
    assert not result.is_passed and result.report_lines[0].startswith("정답 SQL 오류")


def test_setup_failure_is_harness_error(sqlite_executor, not_in_question):
    not_in_question["ddl"] = "CREATE TABLE"
    result = verify_question_with_executor(sqlite_executor, not_in_question)
    assert not result.is_passed and result.is_harness_error
