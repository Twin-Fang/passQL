"""품질 점검: 함정 타당성, 길이 균형, 숫자 배치, 지문 체크리스트, 표<->데이터, 순서 의존, 정답 위치 분포"""
import copy

from sqld_harness.quality_linter import find_answer_position_findings, lint_question


def rules_of(findings):
    return {finding.rule: finding.severity for finding in findings}


def test_valid_fixture_has_no_error_or_warning(not_in_question, pick_question):
    for question in (not_in_question, pick_question):
        assert [finding for finding in lint_question(question) if finding.severity != "info"] == []


def test_v2_wrong_choice_without_why_plausible_is_error(not_in_question):
    not_in_question["choices"][1].pop("whyPlausible")
    assert rules_of(lint_question(not_in_question))["trap.why-plausible"] == "error"


def test_v1_wrong_choices_without_why_plausible_is_single_info(not_in_question):
    not_in_question.pop("schemaVersion")
    for choice in not_in_question["choices"]:
        choice.pop("whyPlausible", None)
    legacy_findings = [finding for finding in lint_question(not_in_question) if finding.rule == "trap.why-plausible-legacy"]
    assert len(legacy_findings) == 1 and legacy_findings[0].severity == "info"


def test_short_why_plausible_is_warning(not_in_question):
    not_in_question["choices"][2]["whyPlausible"] = "착각"
    assert rules_of(lint_question(not_in_question))["trap.why-plausible-short"] == "warning"


def test_correct_choice_much_longer_than_wrong_choices_is_warning(not_in_question):
    for choice in not_in_question["choices"]:
        choice["body"] = "짧은 설명"
    not_in_question["choices"][0]["body"] = "정답만 아주 길고 자세하게 조건을 모두 적은 설명"
    assert rules_of(lint_question(not_in_question))["balance.correct-longest"] == "warning"


def test_unsorted_numeric_choices_is_warning(not_in_question):
    not_in_question["choices"][0]["body"], not_in_question["choices"][3]["body"] = "3", "0"
    assert rules_of(lint_question(not_in_question))["balance.numeric-order"] == "warning"


def test_duplicate_choice_bodies_is_error(not_in_question):
    # 들여쓰기만 다른 같은 결과 표 2개 (#555)
    not_in_question["choices"][1]["body"] = '[{"NAME": "A", "SAL": 1}]'
    not_in_question["choices"][2]["body"] = '[ {"NAME":"A","SAL":1} ]'
    assert rules_of(lint_question(not_in_question))["choice.duplicate-body"] == "error"


def test_stem_checklist(not_in_question):
    not_in_question["stem"] = "NOT IN 문제"
    rules = rules_of(lint_question(not_in_question))
    assert rules["stem.question-form"] == "warning"
    assert rules["stem.selection-criterion"] == "warning"


def test_hidden_data_and_sql_are_warnings(not_in_question):
    not_in_question.pop("tables")
    not_in_question.pop("displaySql")
    rules = rules_of(lint_question(not_in_question))
    assert rules["stem.data-hidden"] == "warning"
    assert rules["stem.sql-hidden"] == "warning"


def test_table_row_as_string_is_shape_error(not_in_question):
    not_in_question["tables"][0]["rows"] = ["1", "2", "3"]
    rules = rules_of(lint_question(not_in_question))
    assert rules["data.table-shape"] == "error"
    assert "data.table-mismatch" not in rules


def test_table_different_from_insert_data_is_error(not_in_question):
    not_in_question["tables"][0]["rows"] = [[1], [2], [4]]
    assert rules_of(lint_question(not_in_question))["data.table-mismatch"] == "error"


def test_ordered_rows_without_order_by_is_warning(not_in_question):
    not_in_question["answerSql"] = "SELECT ID FROM T1;"
    not_in_question["choices"][0]["expect"] = {"rows": [[1], [2], [3]]}
    assert rules_of(lint_question(not_in_question))["expect.order-dependent"] == "warning"


def test_answer_position_skew_is_batch_warning(not_in_question):
    questions = [copy.deepcopy(not_in_question) for _ in range(8)]
    findings = find_answer_position_findings(questions)
    assert [finding.rule for finding in findings] == ["distribution.answer-position"]
    assert find_answer_position_findings(questions[:3]) == []
