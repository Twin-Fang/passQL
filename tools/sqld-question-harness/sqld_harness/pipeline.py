"""
파이프라인 조립: (a) 경향 근거 > (b) 초안 구조 > (c) Oracle 검증 > (d) 품질 점검 > (e) 해설 초안 > (f) 등록 JSON·리포트
단계 결과는 QuestionOutcome 하나에 모아 리포트·명령이 같은 원본을 씀
"""
from dataclasses import dataclass, field

from .constants import CHOICE_KEYS
from .duplicate_detector import find_duplicate_findings
from .explanation_hook import FieldExplanationDrafter, find_explanation_findings
from .findings import has_blocking_finding
from .import_exporter import to_import_item
from .oracle_compatibility import find_oracle_compatibility_findings
from .quality_linter import find_answer_position_findings, lint_question
from .question_schema import find_duplicate_id_findings, find_structure_findings
from .trend_catalog import find_trend_findings


@dataclass
class QuestionOutcome:
    question: dict
    findings: list = field(default_factory=list)
    explanation: dict = None
    # Oracle 검증 결과 (verify 를 돌리지 않으면 None)
    verification: object = None

    @property
    def question_id(self):
        return str(self.question.get("id"))

    @property
    def is_lint_blocked(self):
        return has_blocking_finding(self.findings)

    @property
    def is_passed(self):
        """등록 가능: 차단 finding 없음 + (검증했으면) 검증 통과"""
        is_verified = self.verification is None or self.verification.is_passed
        return not self.is_lint_blocked and is_verified


@dataclass
class BatchOutcome:
    outcomes: list
    # 묶음 규칙 finding (정답 위치 분포 등, 특정 문제에 속하지 않음)
    batch_findings: list = field(default_factory=list)

    @property
    def all_findings(self):
        return self.batch_findings + [finding for outcome in self.outcomes for finding in outcome.findings]

    @property
    def questions(self):
        return [outcome.question for outcome in self.outcomes]


def run_offline_checks(questions, catalog, pool_items=None, explanation_drafter=None):
    """(a)(b)(d)(e) 단계: Oracle 없이 구조·경향·품질·중복·해설 점검"""
    drafter = explanation_drafter or FieldExplanationDrafter()
    outcomes = []
    for question in questions:
        findings = find_structure_findings(question) + find_trend_findings(question, catalog) + lint_question(question)
        findings += find_oracle_compatibility_findings(question)
        explanation = drafter.draft(question)
        findings += find_explanation_findings(question, explanation)
        outcomes.append(QuestionOutcome(question=question, findings=findings, explanation=explanation))
    _attach_cross_question_findings(outcomes, pool_items)
    batch_findings = find_answer_position_findings(questions)
    return BatchOutcome(outcomes=outcomes, batch_findings=batch_findings)


def _attach_cross_question_findings(outcomes, pool_items):
    """문제 사이 규칙(id 중복, 중복 문제) > 해당 문제 finding 으로 붙임"""
    outcome_by_id = {outcome.question_id: outcome for outcome in outcomes}
    labeled_items = [
        (outcome.question_id, to_import_item(outcome.question)) for outcome in outcomes if _has_renderable_fields(outcome.question)
    ]
    cross_findings = find_duplicate_id_findings([outcome.question for outcome in outcomes])
    cross_findings += find_duplicate_findings(labeled_items, pool_items)
    for finding in cross_findings:
        outcome_by_id[finding.question_id].findings.append(finding)


def _has_renderable_fields(question):
    """가져오기 항목 변환에 필요한 필드 존재 (구조 오류 문제도 변환 가능하면 중복 비교)"""
    choices = question.get("choices") or []
    return bool(question.get("stem")) and bool(question.get("topicCode")) and "difficulty" in question and len(choices) <= len(CHOICE_KEYS) and all(
        "body" in choice and "rationale" in choice for choice in choices
    )


def attach_verifications(batch, verification_results):
    """(c) 단계 결과를 문제별 결과에 연결 (입력 순서 동일 전제)"""
    for outcome, result in zip(batch.outcomes, verification_results):
        outcome.verification = result
    return batch
