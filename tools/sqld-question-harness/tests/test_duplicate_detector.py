"""중복 문제 탐지: 같은 정답·보기 error, 유사 warning, 같은 uuid 는 수정본으로 제외"""
import copy

from sqld_harness.duplicate_detector import find_duplicate_findings
from sqld_harness.import_exporter import to_import_item


def test_identical_answer_and_choices_is_error(not_in_question):
    item = to_import_item(not_in_question)
    findings = find_duplicate_findings([("a", item), ("b", copy.deepcopy(item))])
    assert [(finding.rule, finding.severity) for finding in findings] == [("duplicate.identical", "error")]


def test_slightly_reworded_question_is_similar_warning(not_in_question):
    item = to_import_item(not_in_question)
    reworded = copy.deepcopy(item)
    reworded["answerSql"] = item["answerSql"].replace("COUNT(*)", "COUNT(ID)")
    findings = find_duplicate_findings([("a", item), ("b", reworded)])
    assert [finding.rule for finding in findings] == ["duplicate.similar"]


def test_different_questions_are_not_duplicates(not_in_question, pick_question):
    assert find_duplicate_findings([("a", to_import_item(not_in_question)), ("b", to_import_item(pick_question))]) == []


def test_pool_comparison_skips_same_uuid(not_in_question):
    not_in_question["questionUuid"] = "11111111-1111-1111-1111-111111111111"
    item = to_import_item(not_in_question)
    assert find_duplicate_findings([("a", item)], pool_items=[copy.deepcopy(item)]) == []
    pool_item = copy.deepcopy(item)
    pool_item["questionUuid"] = None
    assert [finding.rule for finding in find_duplicate_findings([("a", item)], pool_items=[pool_item])] == ["duplicate.identical"]
