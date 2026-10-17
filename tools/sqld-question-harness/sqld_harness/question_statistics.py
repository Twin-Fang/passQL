"""
문제 묶음 분포 통계: 토픽·난이도·정답 위치·보기 종류·expect 종류·최신 경향·개념·템플릿 커버리지·결과 추적형 비율
"""
from collections import Counter

from .constants import CHOICE_KEYS, TARGET_RESULT_TRACING_SHARE
from .question_schema import (
    get_choices,
    get_concepts,
    get_correct_choice_index,
    get_expect_type,
    get_schema_version,
    get_trend,
    is_concept_question,
)
from .trend_catalog import count_template_coverage

# 1과목 토픽 (결과 추적형 비율은 2과목만 계산)
MODELING_TOPIC_CODE = "data_modeling"
# 부정형 지문 단어
NEGATIVE_STEM_KEYWORDS = ("옳지 않은", "아닌", "틀린", "다른 하나")
TOP_CONCEPT_COUNT = 15


def build_question_statistics(questions, catalog, verification_results=None, findings=None):
    """묶음 > 통계 dict (리포트·stats 명령 공통 원본)"""
    sql_subject_questions = [question for question in questions if question.get("topicCode") != MODELING_TOPIC_CODE]
    result_tracing_count = sum(1 for question in sql_subject_questions if not is_concept_question(question))
    latest_trend_count = sum(1 for question in questions if get_trend(question)["isLatestTrend"])
    statistics = {
        "questionCount": len(questions),
        "schemaVersions": _count(get_schema_version(question) for question in questions),
        "topics": _count(question.get("topicCode") for question in questions),
        "difficulties": _count(question.get("difficulty") for question in questions),
        "answerPositions": {choice_key: 0 for choice_key in CHOICE_KEYS} | _count(
            CHOICE_KEYS[index] for index in (get_correct_choice_index(question) for question in questions) if index is not None
        ),
        "choiceKinds": _count(choice.get("kind", "TEXT") for question in questions for choice in get_choices(question)),
        "expectTypes": _count(get_expect_type(choice) for question in questions for choice in get_choices(question)),
        "latestTrendCount": latest_trend_count,
        "negativeStemCount": sum(1 for question in questions if any(word in str(question.get("stem", "")) for word in NEGATIVE_STEM_KEYWORDS)),
        "topConcepts": dict(Counter(concept for question in questions for concept in get_concepts(question)).most_common(TOP_CONCEPT_COUNT)),
        "templateCoverage": count_template_coverage(questions, catalog),
        "templateNames": {template_id: catalog.get_template_name(template_id) for template_id in catalog.templates},
        "resultTracing": {
            "sqlSubjectCount": len(sql_subject_questions),
            "resultTracingCount": result_tracing_count,
            "share": round(result_tracing_count / len(sql_subject_questions), 3) if sql_subject_questions else None,
            "targetShare": TARGET_RESULT_TRACING_SHARE,
        },
    }
    if verification_results is not None:
        statistics["verification"] = {
            "passedCount": sum(1 for result in verification_results if result.is_passed),
            "failedCount": sum(1 for result in verification_results if not result.is_passed),
            "cachedCount": sum(1 for result in verification_results if result.is_from_cache),
        }
    if findings is not None:
        statistics["findingSeverities"] = _count(finding.severity for finding in findings)
        statistics["findingRules"] = _count(finding.rule for finding in findings)
    return statistics


def _count(values):
    """값 > 개수 (키 정렬, None 은 '(none)')"""
    counter = Counter("(none)" if value is None else value for value in values)
    return {key: counter[key] for key in sorted(counter, key=str)}


def format_statistics_text(statistics):
    """통계 > 터미널 출력 줄 목록"""
    tracing = statistics["resultTracing"]
    share_text = "-" if tracing["share"] is None else f"{tracing['share']:.0%}"
    lines = [
        f"[sqld harness] questions {statistics['questionCount']} (schemaVersion {statistics['schemaVersions']})",
        f"  topics        : {statistics['topics']}",
        f"  difficulties  : {statistics['difficulties']}",
        f"  answer A~D    : {statistics['answerPositions']}",
        f"  choice kinds  : {statistics['choiceKinds']}",
        f"  expect types  : {statistics['expectTypes']}",
        f"  latest trend  : {statistics['latestTrendCount']} / {statistics['questionCount']}",
        f"  result tracing: {tracing['resultTracingCount']} / {tracing['sqlSubjectCount']} ({share_text}, target {tracing['targetShare']:.0%})",
        f"  negative stems: {statistics['negativeStemCount']}",
    ]
    if statistics["templateCoverage"]:
        empty_templates = [template_id for template_id, count in statistics["templateCoverage"].items() if count == 0]
        lines.append(f"  templates     : {statistics['templateCoverage']}")
        lines.append(f"  empty templates (양산 공백): {', '.join(empty_templates) or '-'}")
    return lines
