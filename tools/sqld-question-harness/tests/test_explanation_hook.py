"""해설 초안 훅 (#521 형식): 필드 조립, 작성값 우선, 검증 규칙"""
from sqld_harness.explanation_hook import EXPLANATION_FIELDS, FieldExplanationDrafter, find_explanation_findings


def test_draft_has_all_fields_built_from_question(not_in_question):
    explanation = FieldExplanationDrafter().draft(not_in_question)
    assert tuple(explanation) == EXPLANATION_FIELDS
    assert explanation["correctReason"] == "ID <> NULL 이 UNKNOWN 이라 0건."
    assert explanation["keyConcepts"] == ["NOT IN", "NULL 3값 논리"]
    assert explanation["confusingPoints"][0].startswith("서브쿼리 결과에 NULL")
    assert [entry["choiceKey"] for entry in explanation["choiceAnalysis"]] == ["A", "B", "C", "D"]
    assert explanation["examTip"] == "NOT IN 서브쿼리를 보면 NULL 부터 찾는다."
    assert find_explanation_findings(not_in_question, explanation) == []


def test_authored_explanation_overrides_draft(not_in_question):
    not_in_question["explanation"]["correctReason"] = "작성한 정답 이유 0건"
    assert FieldExplanationDrafter().draft(not_in_question)["correctReason"] == "작성한 정답 이유 0건"


def test_choice_analysis_mismatch_is_error(not_in_question):
    explanation = FieldExplanationDrafter().draft(not_in_question)
    explanation["choiceAnalysis"][0]["isCorrect"] = False
    explanation["choiceAnalysis"][1]["isCorrect"] = True
    explanation["correctReason"] = ""
    rules = {finding.rule for finding in find_explanation_findings(not_in_question, explanation)}
    assert {"explanation.correct-mismatch", "explanation.correct-reason"} <= rules


def test_short_answer_not_mentioned_is_info(not_in_question):
    explanation = FieldExplanationDrafter().draft(not_in_question)
    explanation["correctReason"] = "UNKNOWN 이라 남는 행이 없다."
    findings = find_explanation_findings(not_in_question, explanation)
    assert [(finding.rule, finding.severity) for finding in findings] == [("explanation.answer-not-mentioned", "info")]
