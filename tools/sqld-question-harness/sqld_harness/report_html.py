"""
HTML 리포트 (외부 의존 없는 단일 파일): 요약 카드 > 분포 막대 > 실패 사유 > 점검 표 > 학습자 미리보기 카드(해설 초안 포함)
"""
from html import escape

from .constants import CHOICE_KEYS
from .findings import SEVERITY_ERROR, SEVERITY_WARNING, sort_findings
from .import_exporter import render_stem
from .question_schema import get_choices, get_concepts, get_trend
from .report_markdown import STATUS_FAILED, STATUS_PASSED, collect_failure_reasons, describe_outcome_status

# 색·간격 토큰 (라이트·다크 함께 정의)
STYLE_SHEET = """
:root{--bg:#f7f7f8;--surface:#fff;--text:#1d1d1f;--muted:#6e6e73;--line:#e5e5ea;--accent:#0a66ff;
--pass:#1f9d55;--fail:#d93025;--warn:#b26a00;--info:#5856d6;--bar:#cfe0ff;--radius:12px;--gap:16px}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){--bg:#111113;--surface:#1c1c1f;--text:#f2f2f7;
--muted:#a1a1a6;--line:#2c2c30;--accent:#4c8dff;--bar:#23365c}}
:root[data-theme="dark"]{--bg:#111113;--surface:#1c1c1f;--text:#f2f2f7;--muted:#a1a1a6;--line:#2c2c30;--accent:#4c8dff;--bar:#23365c}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font:15px/1.6 -apple-system,BlinkMacSystemFont,"Apple SD Gothic Neo",sans-serif}
main{max-width:980px;margin:0 auto;padding:24px 16px 64px}h1{font-size:24px;margin:0 0 4px}h2{font-size:18px;margin:32px 0 12px}
.muted{color:var(--muted)}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:var(--gap)}
.card{background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:14px 16px}
.card b{display:block;font-size:22px}.bars{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:var(--gap)}
.bar-row{display:grid;grid-template-columns:120px 1fr 32px;gap:8px;align-items:center;font-size:13px}
.bar-track{background:var(--line);border-radius:6px;height:10px;overflow:hidden}.bar-fill{background:var(--accent);height:100%}
table{width:100%;border-collapse:collapse;background:var(--surface);border-radius:var(--radius);overflow:hidden;font-size:13px}
th,td{text-align:left;padding:8px 10px;border-bottom:1px solid var(--line);vertical-align:top}
.badge{display:inline-block;padding:1px 8px;border-radius:999px;font-size:12px;border:1px solid currentColor;margin-right:4px}
.pass{color:var(--pass)}.fail,.error{color:var(--fail)}.warning{color:var(--warn)}.info,.latest{color:var(--info)}
.question{background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:16px;margin-bottom:var(--gap)}
pre{white-space:pre-wrap;word-break:break-word;background:var(--bg);border-radius:8px;padding:10px;font-size:13px;margin:8px 0}
ol.choices{padding-left:20px}ol.choices li.correct{font-weight:600}.chips span{font-size:12px;background:var(--bar);border-radius:6px;padding:1px 6px;margin-right:4px}
details{margin-top:8px}summary{cursor:pointer;color:var(--accent)}.scroll{overflow-x:auto}
"""


def render_html_report(batch, statistics, title):
    sections = [
        f"<h1>{escape(title)}</h1><p class='muted'>경향 근거 > 초안 > Oracle 검증 > 품질 점검 > 해설 초안 > 등록</p>",
        _render_summary_cards(batch, statistics),
        _render_distribution_bars(statistics),
        _render_failures(batch),
        _render_findings_table(batch),
        "<h2>학습자 미리보기</h2>" + "".join(_render_question_card(outcome) for outcome in batch.outcomes),
    ]
    return (
        "<!doctype html><html lang='ko'><head><meta charset='utf-8'>"
        "<meta name='viewport' content='width=device-width,initial-scale=1'>"
        f"<title>{escape(title)}</title><style>{STYLE_SHEET}</style></head><body><main>"
        + "".join(sections)
        + "</main></body></html>"
    )


def _render_summary_cards(batch, statistics):
    statuses = [describe_outcome_status(outcome) for outcome in batch.outcomes]
    severities = statistics.get("findingSeverities", {})
    tracing = statistics["resultTracing"]
    share_text = "-" if tracing["share"] is None else f"{tracing['share']:.0%}"
    cards = [
        ("문제", statistics["questionCount"], ""),
        ("통과", statuses.count(STATUS_PASSED), "pass"),
        ("실패", statuses.count(STATUS_FAILED), "fail"),
        ("warning", severities.get("warning", 0), "warning"),
        ("최신 경향", statistics["latestTrendCount"], "latest"),
        (f"결과 추적형 (목표 {tracing['targetShare']:.0%})", share_text, ""),
    ]
    return "<div class='cards'>" + "".join(f"<div class='card'><span class='muted'>{escape(label)}</span><b class='{css}'>{escape(str(value))}</b></div>" for label, value, css in cards) + "</div>"


def _render_bar_group(label, counts):
    maximum = max(counts.values(), default=0) or 1
    rows = "".join(
        f"<div class='bar-row'><span>{escape(str(name))}</span><div class='bar-track'><div class='bar-fill' style='width:{count / maximum * 100:.0f}%'></div></div><span>{count}</span></div>"
        for name, count in counts.items()
    )
    return f"<div class='card'><b style='font-size:15px'>{escape(label)}</b>{rows}</div>"


def _render_distribution_bars(statistics):
    groups = [("토픽", statistics["topics"]), ("난이도", statistics["difficulties"]), ("정답 위치", statistics["answerPositions"]), ("expect 종류", statistics["expectTypes"])]
    if statistics.get("templateCoverage"):
        groups.append(("출제 템플릿 (0 = 양산 공백)", statistics["templateCoverage"]))
    if statistics.get("topConcepts"):
        groups.append(("개념 태그", statistics["topConcepts"]))
    return "<h2>분포</h2><div class='bars'>" + "".join(_render_bar_group(label, counts) for label, counts in groups) + "</div>"


def _render_failures(batch):
    failed = [outcome for outcome in batch.outcomes if not outcome.is_passed]
    if not failed:
        return "<h2>실패·차단 사유</h2><p class='pass'>없음</p>"
    items = "".join(
        f"<li><b>{escape(outcome.question_id)}</b><ul>" + "".join(f"<li>{escape(reason)}</li>" for reason in collect_failure_reasons(outcome)) + "</ul></li>"
        for outcome in failed
    )
    return f"<h2>실패·차단 사유</h2><ul>{items}</ul>"


def _render_findings_table(batch):
    visible = [finding for finding in sort_findings(batch.all_findings) if finding.severity in (SEVERITY_ERROR, SEVERITY_WARNING)]
    if not visible:
        return "<h2>점검 결과</h2><p class='pass'>error·warning 없음</p>"
    rows = "".join(
        f"<tr><td class='{finding.severity}'>{finding.severity}</td><td>{escape(finding.question_id)}</td><td>{escape(finding.rule)}</td><td>{escape(finding.message)}</td></tr>"
        for finding in visible
    )
    return f"<h2>점검 결과</h2><div class='scroll'><table><tr><th>심각도</th><th>문제</th><th>규칙</th><th>내용</th></tr>{rows}</table></div>"


def _render_question_card(outcome):
    question = outcome.question
    status = describe_outcome_status(outcome)
    badges = [f"<span class='badge {'fail' if status == STATUS_FAILED else 'pass'}'>{status}</span>"]
    if get_trend(question)["isLatestTrend"]:
        rounds = ", ".join(str(round_number) for round_number in get_trend(question)["examRounds"])
        badges.append(f"<span class='badge latest'>최신 경향 {escape(rounds)}회</span>")
    badges.append(f"<span class='badge muted'>{escape(str(question.get('topicCode')))} · 난이도 {escape(str(question.get('difficulty')))}</span>")
    chips = "".join(f"<span>{escape(concept)}</span>" for concept in get_concepts(question))
    choices = "".join(
        f"<li class='{'correct' if choice.get('isCorrect') else ''}'>{escape(str(choice.get('body', '')))}</li>"
        for choice in get_choices(question)[: len(CHOICE_KEYS)]
    )
    stem = escape(render_stem(question)) if question.get("stem") else ""
    return (
        f"<div class='question'><div>{''.join(badges)}</div><b>{escape(outcome.question_id)}</b>"
        f"<div class='chips'>{chips}</div><pre>{stem}</pre><ol class='choices' type='A'>{choices}</ol>"
        f"{_render_explanation(outcome.explanation)}</div>"
    )


def _render_explanation(explanation):
    if not explanation:
        return ""
    analysis = "".join(
        f"<li><b>{escape(str(entry.get('choiceKey')))}</b> {escape(str(entry.get('analysis', '')))}</li>" for entry in explanation.get("choiceAnalysis") or []
    )
    confusing = "".join(f"<li>{escape(str(point))}</li>" for point in explanation.get("confusingPoints") or [])
    return (
        "<details><summary>해설 초안</summary>"
        f"<p><b>정답 이유</b> {escape(str(explanation.get('correctReason', '')))}</p>"
        f"<p><b>핵심 개념</b> {escape(', '.join(map(str, explanation.get('keyConcepts') or [])))}</p>"
        f"<p><b>헷갈리는 지점</b></p><ul>{confusing}</ul><p><b>보기 분석</b></p><ul>{analysis}</ul>"
        f"<p><b>시험 팁</b> {escape(str(explanation.get('examTip', '')))}</p></details>"
    )
