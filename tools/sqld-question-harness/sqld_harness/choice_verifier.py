"""
보기 기대값 검증: 정답 SQL 실행 > 보기별 expect 판정 > pick(max|min) 유일성 (실행기 세션 인터페이스에만 의존)
정답 보기는 expect 참, 오답 보기는 rows·scalar 불일치 / 나머지 expect 는 사실이어야 통과
"""
from dataclasses import dataclass, field

from .constants import ANSWER_COMPARE_EXPECT_TYPES, CHOICE_KEYS
from .question_schema import get_choices, get_expect_type
from .sql_script import are_rows_equal, normalize_value


@dataclass
class VerificationResult:
    question_id: str
    is_passed: bool
    report_lines: list = field(default_factory=list)
    # 캐시 재사용 여부, 하네스·연결 오류 여부 (하네스 오류는 캐시 저장 제외)
    is_from_cache: bool = False
    is_harness_error: bool = False

    def to_dict(self):
        return {
            "questionId": self.question_id,
            "isPassed": self.is_passed,
            "reportLines": self.report_lines,
            "isFromCache": self.is_from_cache,
            "isHarnessError": self.is_harness_error,
        }

    @classmethod
    def from_dict(cls, data):
        return cls(
            question_id=data["questionId"],
            is_passed=data["isPassed"],
            report_lines=list(data.get("reportLines") or []),
            is_from_cache=bool(data.get("isFromCache")),
            is_harness_error=bool(data.get("isHarnessError")),
        )


def build_setup_script(question):
    return "\n".join(filter(None, [question.get("ddl"), question.get("data")]))


def verify_question_with_executor(executor, question):
    """문제 1건 > VerificationResult (실행 오류는 실패 줄로, 하네스 자체 오류는 is_harness_error)"""
    question_id = str(question["id"])
    try:
        with executor.open_session(question_id, build_setup_script(question)) as session:
            return _verify_in_session(session, question)
    except Exception as error:  # 하네스·연결 오류도 문제 실패로 기록 (전체 중단 방지)
        return VerificationResult(question_id, False, [f"harness error: {error}"], is_harness_error=True)


def _verify_in_session(session, question):
    question_id = str(question["id"])
    answer_rows = None
    if question.get("answerSql"):
        answer_rows, answer_error = session.run(question["answerSql"])
        if answer_error:
            return VerificationResult(question_id, False, [f"정답 SQL 오류: {answer_error}"])
    is_passed, report_lines, actual_counts = True, [], []
    for index, choice in enumerate(get_choices(question)):
        is_expect_true, detail, actual_count = evaluate_choice(session, answer_rows, choice)
        actual_counts.append(actual_count)
        is_choice_ok = is_expect_true if choice.get("isCorrect") else is_wrong_choice_ok(choice, is_expect_true)
        is_passed = is_passed and is_choice_ok
        mark = "ok" if is_choice_ok else "NG"
        report_lines.append(f"  [{mark}] {CHOICE_KEYS[index]} correct={bool(choice.get('isCorrect'))} {detail}")
    pick_reject_reason = find_pick_reject_reason(question, actual_counts)
    if pick_reject_reason:
        report_lines.append(f"  [NG] pick: {pick_reject_reason}")
        is_passed = False
    return VerificationResult(question_id, is_passed, report_lines)


def evaluate_choice(session, answer_rows, choice):
    """보기 1개 > (expect 성립 여부, 상세, count 결과). 보기 SQL 은 초기 데이터에서 실행"""
    expect = choice.get("expect") or {}
    expect_type = get_expect_type(choice)
    if expect_type == "rows":
        return are_rows_equal(answer_rows, expect["rows"], expect.get("ordered", True)), f"answer={answer_rows}", None
    if expect_type == "scalar":
        actual = answer_rows[0][0] if answer_rows and answer_rows[0] else None
        return actual == normalize_value(expect["scalar"]), f"answer scalar={actual!r}", None
    if expect_type == "concept":
        return True, "concept (manual review)", None
    if expect_type is None:
        return False, "expect 누락", None
    session.reset()
    choice_rows, error = session.run(choice["body"])
    if expect_type == "same_as_answer":
        is_same = error is None and are_rows_equal(choice_rows, answer_rows, expect.get("ordered", False))
        return is_same == bool(expect["same_as_answer"]), f"choice={choice_rows} error={error}", None
    if expect_type == "error":
        session.rollback()
        return (error is not None) == bool(expect["error"]), f"error={error}", None
    if expect_type == "body_rows":
        is_same = error is None and are_rows_equal(choice_rows, expect["body_rows"], expect.get("ordered", True))
        return is_same, f"choice={choice_rows} error={error}", None
    # count
    actual_count = None if error else len(choice_rows or [])
    return actual_count == int(expect["count"]), f"count={actual_count} error={error}", actual_count


def is_wrong_choice_ok(choice, is_expect_true):
    """오답 보기: rows·scalar 는 정답 결과와 불일치해야 함, 나머지는 expect 가 사실이어야 함"""
    if get_expect_type(choice) in ANSWER_COMPARE_EXPECT_TYPES:
        return not is_expect_true
    return is_expect_true


def find_pick_reject_reason(question, actual_counts):
    """pick: max|min > 정답 보기 행 수가 유일한 최대·최소인지 (count 보기 전용)"""
    pick = question.get("pick")
    if not pick:
        return None
    if any(count is None for count in actual_counts):
        return "count 보기 실행 실패"
    target = max(actual_counts) if pick == "max" else min(actual_counts)
    correct_index = next(index for index, choice in enumerate(get_choices(question)) if choice.get("isCorrect"))
    if actual_counts[correct_index] != target or actual_counts.count(target) != 1:
        return f"정답이 유일한 {pick} 아님 counts={actual_counts}"
    return None
