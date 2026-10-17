"""
해설 초안 훅 (#521 구조화 해설): correctReason, keyConcepts, confusingPoints, choiceAnalysis, examTip
초안 생성기·검증기는 인터페이스로 분리 > 기본은 YAML 필드 조립, LLM 생성기는 같은 draft() 모양으로 교체
"""
from typing import Protocol

from .constants import CHOICE_KEYS, MAXIMUM_KEY_CONCEPT_COUNT, MINIMUM_KEY_CONCEPT_COUNT
from .findings import SEVERITY_ERROR, SEVERITY_INFO, SEVERITY_WARNING, Finding
from .question_schema import get_choices, get_concepts, get_correct_choice_index

# 해설 필드 5개 (#521 형식, 서버 연결 시 이 키 그대로 매핑)
EXPLANATION_FIELDS = ("correctReason", "keyConcepts", "confusingPoints", "choiceAnalysis", "examTip")
# 정답 값이 해설 본문에 보이는지 확인할 보기 최대 길이 (긴 SQL 보기는 대상 아님)
ANSWER_MENTION_CHECK_MAXIMUM_LENGTH = 20


class ExplanationDrafter(Protocol):
    """해설 초안 생성기: 문제 dict > 해설 dict (EXPLANATION_FIELDS 키)"""

    def draft(self, question): ...


class FieldExplanationDrafter:
    """
    YAML 필드 조립형 초안: explanation 블록 값 우선, 없으면 보기 근거·함정·힌트로 채움
    correctReason < 정답 rationale, keyConcepts < concepts, confusingPoints < trapDesign + 오답 whyPlausible,
    choiceAnalysis < 보기별 rationale, examTip < hint
    """

    def draft(self, question):
        authored = question.get("explanation") or {}
        choices = get_choices(question)
        correct_index = get_correct_choice_index(question)
        correct_choice = choices[correct_index] if correct_index is not None else {}
        return {
            "correctReason": authored.get("correctReason") or correct_choice.get("rationale", ""),
            "keyConcepts": list(authored.get("keyConcepts") or get_concepts(question) or _intent_as_concepts(question)),
            "confusingPoints": list(authored.get("confusingPoints") or _collect_confusing_points(question)),
            "choiceAnalysis": authored.get("choiceAnalysis") or _build_choice_analysis(choices),
            "examTip": authored.get("examTip") or question.get("hint") or "",
        }


def _intent_as_concepts(question):
    return [question["intent"]] if question.get("intent") else []


def _collect_confusing_points(question):
    """함정 설계 1줄 + 오답별 '이렇게 생각하면 틀림'"""
    points = [question["trapDesign"]] if question.get("trapDesign") else []
    for index, choice in enumerate(get_choices(question)[: len(CHOICE_KEYS)]):
        if not choice.get("isCorrect"):
            reason = choice.get("whyPlausible") or choice.get("rationale")
            if reason:
                points.append(f"{CHOICE_KEYS[index]}: {reason}")
    return points


def _build_choice_analysis(choices):
    return [
        {"choiceKey": CHOICE_KEYS[index], "isCorrect": bool(choice.get("isCorrect")), "analysis": choice.get("rationale", "")}
        for index, choice in enumerate(choices[: len(CHOICE_KEYS)])
    ]


def find_explanation_findings(question, explanation):
    """해설 초안 검증: 필드 존재, 개념 개수, 보기 분석 4개·정답 표시 일치, 정답 값 언급"""
    question_id = str(question.get("id"))
    findings = []

    def add(severity, rule, message):
        findings.append(Finding(severity, rule, question_id, message))

    if not str(explanation.get("correctReason") or "").strip():
        add(SEVERITY_ERROR, "explanation.correct-reason", "correctReason 비어 있음")
    key_concept_count = len(explanation.get("keyConcepts") or [])
    if not MINIMUM_KEY_CONCEPT_COUNT <= key_concept_count <= MAXIMUM_KEY_CONCEPT_COUNT:
        add(SEVERITY_WARNING, "explanation.key-concepts", f"keyConcepts {key_concept_count}개 ({MINIMUM_KEY_CONCEPT_COUNT}~{MAXIMUM_KEY_CONCEPT_COUNT}개)")
    if not explanation.get("confusingPoints"):
        add(SEVERITY_WARNING, "explanation.confusing-points", "confusingPoints 비어 있음")
    if not str(explanation.get("examTip") or "").strip():
        add(SEVERITY_INFO, "explanation.exam-tip", "examTip 비어 있음 (hint 또는 explanation.examTip 작성 권장)")
    _check_choice_analysis(question, explanation.get("choiceAnalysis") or [], add)
    _check_answer_mentioned(question, explanation, add)
    return findings


def _check_choice_analysis(question, choice_analysis, add):
    keys = [str(entry.get("choiceKey")) for entry in choice_analysis]
    if keys != CHOICE_KEYS:
        add(SEVERITY_ERROR, "explanation.choice-analysis", f"choiceAnalysis 키 {keys} (A~D 순서 4개 필요)")
        return
    for entry in choice_analysis:
        if not str(entry.get("analysis") or "").strip():
            add(SEVERITY_ERROR, "explanation.choice-analysis", f"{entry['choiceKey']} 보기 분석 비어 있음")
    correct_index = get_correct_choice_index(question)
    marked_indexes = [index for index, entry in enumerate(choice_analysis) if entry.get("isCorrect")]
    if correct_index is not None and marked_indexes != [correct_index]:
        add(SEVERITY_ERROR, "explanation.correct-mismatch", "choiceAnalysis 정답 표시가 문제 정답과 다름")


def _check_answer_mentioned(question, explanation, add):
    """짧은 정답(숫자·값)은 correctReason 에 그 값이 보여야 학습자가 근거를 따라감"""
    correct_index = get_correct_choice_index(question)
    if correct_index is None:
        return
    correct_body = str(get_choices(question)[correct_index].get("body", "")).strip()
    if not correct_body or len(correct_body) > ANSWER_MENTION_CHECK_MAXIMUM_LENGTH or get_choices(question)[correct_index].get("kind") == "SQL":
        return
    if correct_body not in str(explanation.get("correctReason") or ""):
        add(SEVERITY_INFO, "explanation.answer-not-mentioned", f"correctReason 에 정답 값 {correct_body!r} 이 보이지 않음")
