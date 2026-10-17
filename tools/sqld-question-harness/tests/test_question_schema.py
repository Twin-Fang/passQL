"""문제 YAML 로드·구조 검증 (v1·v2)"""
from sqld_harness.question_schema import (
    find_duplicate_id_findings,
    find_structure_findings,
    get_trend,
    is_concept_question,
    load_questions,
)


def rules_of(findings):
    return {finding.rule for finding in findings}


def test_load_questions_reads_multi_document_and_assigns_missing_id(tmp_path):
    question_file = tmp_path / "batch.yaml"
    question_file.write_text("stem: a\n---\nid: second\nstem: b\n", encoding="utf-8")
    questions = load_questions(tmp_path)
    assert [question["id"] for question in questions] == ["batch_0", "second"]
    assert questions[0]["_sourceFile"] == "batch.yaml"


def test_valid_v2_question_has_no_structure_error(not_in_question):
    assert find_structure_findings(not_in_question) == []


def test_choice_count_and_correct_count_are_errors(not_in_question):
    not_in_question["choices"] = not_in_question["choices"][:3]
    not_in_question["choices"][1]["isCorrect"] = True
    assert {"structure.choice-count", "structure.correct-count"} <= rules_of(find_structure_findings(not_in_question))


def test_v2_requires_trap_design_difficulty_reason_concepts(not_in_question):
    for field_name in ("trapDesign", "difficultyReason", "concepts"):
        not_in_question.pop(field_name)
    assert {"v2.trap-design", "v2.difficulty-reason", "v2.concepts"} <= rules_of(find_structure_findings(not_in_question))


def test_v1_question_does_not_require_v2_fields(not_in_question):
    not_in_question.pop("schemaVersion")
    for field_name in ("trapDesign", "difficultyReason", "concepts"):
        not_in_question.pop(field_name)
    assert find_structure_findings(not_in_question) == []


def test_concept_choice_requires_source_note(not_in_question):
    for choice in not_in_question["choices"]:
        choice["expect"] = {"concept": True}
    assert is_concept_question(not_in_question)
    assert "structure.source-note" in rules_of(find_structure_findings(not_in_question))


def test_unknown_topic_is_warning_and_bad_difficulty_is_error(not_in_question):
    not_in_question["topicCode"] = "sql_new_topic"
    not_in_question["difficulty"] = 9
    findings = {finding.rule: finding.severity for finding in find_structure_findings(not_in_question)}
    assert findings["structure.topic"] == "warning"
    assert findings["structure.difficulty"] == "error"


def test_scalar_choice_without_answer_sql_is_error(not_in_question):
    not_in_question.pop("answerSql")
    assert "structure.answer-sql" in rules_of(find_structure_findings(not_in_question))


def test_duplicate_id_is_error(not_in_question):
    assert rules_of(find_duplicate_id_findings([not_in_question, dict(not_in_question)])) == {"structure.duplicate-id"}


def test_get_trend_defaults_for_v1_question():
    assert get_trend({}) == {"templates": [], "examRounds": [], "isLatestTrend": False}
