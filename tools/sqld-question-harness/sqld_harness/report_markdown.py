"""
Markdown 리포트: 요약 > 실패·차단 사유 > 분포 통계 > 문제별 점검 결과 (이슈·PR 댓글에 그대로 붙여넣기 용)
"""
from .findings import SEVERITY_ERROR, SEVERITY_WARNING, sort_findings

STATUS_PASSED = "PASS"
STATUS_FAILED = "FAIL"
STATUS_UNVERIFIED = "LINT-ONLY"


def describe_outcome_status(outcome):
    """문제 결과 > 상태 표시 (검증 미실행이면 lint 기준)"""
    if not outcome.is_passed:
        return STATUS_FAILED
    return STATUS_PASSED if outcome.verification is not None else STATUS_UNVERIFIED


def collect_failure_reasons(outcome):
    """실패 사유 목록: error finding + Oracle NG 줄"""
    reasons = [f"{finding.rule}: {finding.message}" for finding in outcome.findings if finding.severity == SEVERITY_ERROR]
    if outcome.verification is not None and not outcome.verification.is_passed:
        reasons += [line.strip() for line in outcome.verification.report_lines if "[NG]" in line or "오류" in line or "error:" in line]
    return reasons


def render_markdown_report(batch, statistics, title):
    lines = [f"# {title}", ""]
    lines += _render_summary(batch, statistics)
    lines += _render_failures(batch)
    lines += _render_distribution(statistics)
    lines += _render_findings(batch)
    return "\n".join(lines) + "\n"


def _render_summary(batch, statistics):
    status_counts = {STATUS_PASSED: 0, STATUS_FAILED: 0, STATUS_UNVERIFIED: 0}
    for outcome in batch.outcomes:
        status_counts[describe_outcome_status(outcome)] += 1
    severities = statistics.get("findingSeverities", {})
    tracing = statistics["resultTracing"]
    share_text = "-" if tracing["share"] is None else f"{tracing['share']:.0%}"
    return [
        "## 요약",
        "",
        "| 항목 | 값 |",
        "| --- | --- |",
        f"| 문제 수 | {statistics['questionCount']} |",
        f"| 통과 / 실패 / 검증 미실행 | {status_counts[STATUS_PASSED]} / {status_counts[STATUS_FAILED]} / {status_counts[STATUS_UNVERIFIED]} |",
        f"| finding error / warning / info | {severities.get('error', 0)} / {severities.get('warning', 0)} / {severities.get('info', 0)} |",
        f"| 최신 경향 표시 문제 | {statistics['latestTrendCount']} |",
        f"| 2과목 결과 추적형 비율 | {share_text} (목표 {tracing['targetShare']:.0%} 이상) |",
        "",
    ]


def _render_failures(batch):
    failed_outcomes = [outcome for outcome in batch.outcomes if not outcome.is_passed]
    lines = ["## 실패·차단 사유", ""]
    if not failed_outcomes:
        return lines + ["없음", ""]
    for outcome in failed_outcomes:
        lines.append(f"- **{outcome.question_id}** ({outcome.question.get('topicCode')})")
        lines += [f"  - {reason}" for reason in collect_failure_reasons(outcome)]
    return lines + [""]


def _render_distribution(statistics):
    lines = ["## 분포", ""]
    for label, key in (("토픽", "topics"), ("난이도", "difficulties"), ("정답 위치", "answerPositions"), ("expect 종류", "expectTypes")):
        lines.append(f"- {label}: " + ", ".join(f"{name} {count}" for name, count in statistics[key].items()))
    coverage = statistics.get("templateCoverage") or {}
    if coverage:
        names = statistics.get("templateNames") or {}
        lines += ["", "| 템플릿 | 이름 | 문제 수 |", "| --- | --- | --- |"]
        lines += [f"| {template_id} | {names.get(template_id, '')} | {count} |" for template_id, count in coverage.items()]
    return lines + [""]


def _render_findings(batch):
    lines = ["## 점검 결과 (error·warning)", ""]
    visible = [finding for finding in sort_findings(batch.all_findings) if finding.severity in (SEVERITY_ERROR, SEVERITY_WARNING)]
    if not visible:
        return lines + ["없음", ""]
    lines += ["| 심각도 | 문제 | 규칙 | 내용 |", "| --- | --- | --- | --- |"]
    lines += [f"| {finding.severity} | {finding.question_id} | {finding.rule} | {finding.message.replace('|', '/')} |" for finding in visible]
    return lines + [""]
