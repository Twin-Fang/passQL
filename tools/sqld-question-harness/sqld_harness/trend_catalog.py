"""
출제 경향 카탈로그: 템플릿 id(T01~) > 이름·과목, 최신 회차 목록 > 문제 경향 태그 검증·커버리지 집계
원본: docs/sqld-research/trend-catalog.yaml (조사 자료라 로컬 원문, 커밋은 암호화본)
"""
from dataclasses import dataclass, field
from pathlib import Path

from .findings import SEVERITY_ERROR, SEVERITY_INFO, SEVERITY_WARNING, Finding
from .question_schema import get_trend, is_current_schema

# 기본 카탈로그 위치: tools/sqld-question-harness 기준 레포 루트 docs/sqld-research
DEFAULT_TREND_CATALOG_PATH = Path(__file__).resolve().parents[3] / "docs" / "sqld-research" / "trend-catalog.yaml"


@dataclass
class TrendCatalog:
    # 템플릿 id > {name, subject}
    templates: dict = field(default_factory=dict)
    # 최신 경향으로 인정하는 회차 (예: 최근 3회차)
    latest_exam_rounds: frozenset = frozenset()

    @property
    def is_loaded(self):
        return bool(self.templates)

    def get_template_name(self, template_id):
        return (self.templates.get(template_id) or {}).get("name", template_id)


def load_trend_catalog(path=None):
    """카탈로그 YAML > TrendCatalog (파일 없으면 빈 카탈로그: 템플릿 검증 생략)"""
    catalog_path = Path(path) if path else DEFAULT_TREND_CATALOG_PATH
    if not catalog_path.is_file():
        return TrendCatalog()
    import yaml

    document = yaml.safe_load(catalog_path.read_text(encoding="utf-8")) or {}
    templates = {
        str(template["id"]): {"name": template.get("name", ""), "subject": template.get("subject")}
        for template in document.get("templates") or []
    }
    latest_rounds = frozenset(int(round_number) for round_number in document.get("latestExamRounds") or [])
    return TrendCatalog(templates=templates, latest_exam_rounds=latest_rounds)


def find_trend_findings(question, catalog):
    """경향 태그 검증: 템플릿 존재, 최신 경향 플래그 근거 회차, v2 태그 누락"""
    question_id = str(question.get("id"))
    trend = get_trend(question)
    findings = []
    if is_current_schema(question) and not trend["templates"]:
        findings.append(Finding(SEVERITY_WARNING, "trend.template-missing", question_id, "trend.templates(출제 템플릿) 누락"))
    if catalog.is_loaded:
        for template_id in trend["templates"]:
            if template_id not in catalog.templates:
                findings.append(Finding(SEVERITY_ERROR, "trend.template-unknown", question_id, f"카탈로그에 없는 템플릿: {template_id}"))
    if trend["isLatestTrend"]:
        if not trend["examRounds"]:
            findings.append(Finding(SEVERITY_ERROR, "trend.latest-without-round", question_id, "isLatestTrend 는 examRounds(근거 회차) 필수"))
        elif catalog.latest_exam_rounds and not set(trend["examRounds"]) & catalog.latest_exam_rounds:
            latest_text = ", ".join(str(round_number) for round_number in sorted(catalog.latest_exam_rounds))
            findings.append(Finding(SEVERITY_ERROR, "trend.latest-stale-round", question_id, f"최신 경향 회차({latest_text}) 근거 없음"))
    elif trend["examRounds"] and catalog.latest_exam_rounds and set(trend["examRounds"]) & catalog.latest_exam_rounds:
        findings.append(Finding(SEVERITY_INFO, "trend.latest-flag-suggest", question_id, "최신 회차 근거가 있어 isLatestTrend: true 표시 가능"))
    return findings


def count_template_coverage(questions, catalog):
    """템플릿 id > 문제 수 (카탈로그 템플릿 중 0건도 포함 > 양산 공백 확인)"""
    coverage = {template_id: 0 for template_id in catalog.templates}
    for question in questions:
        for template_id in get_trend(question)["templates"]:
            coverage[template_id] = coverage.get(template_id, 0) + 1
    return coverage
