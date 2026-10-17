"""
SQLD 고정 보기 문제 하네스 v2 (#511 > #524): 경향 근거 > 초안 > Oracle 검증 > 품질 점검 > 해설 초안 > 등록 JSON·리포트

사용 (v1 명령 하위호환):
  python harness.py verify   <YAML 폴더|파일> [--output import.json] [--workers 4] [--no-cache] [--results results.json]
  python harness.py render   <YAML>                      # 지문 미리보기
  python harness.py lint     <YAML> [--against pool.json] [--strict]   # Oracle 없이 품질 점검
  python harness.py stats    <YAML> [--json]             # 분포 통계
  python harness.py report   <YAML> [--results results.json] [--md report.md] [--html report.html]
  python harness.py explain  <YAML> [--output explanations.json]       # 해설 초안(#521 형식) + 검증
  python harness.py scaffold [--id 새_문제_id]           # YAML v2 빈 양식 출력

YAML 스키마·expect 종류·품질 기준: README.md
"""
import argparse
import json
import sys
from pathlib import Path

# python -I 실행 시 스크립트 폴더가 sys.path 에서 빠짐 > 하네스 패키지 위치 명시
sys.path.insert(0, str(Path(__file__).resolve().parent))

from sqld_harness.choice_verifier import VerificationResult
from sqld_harness.constants import CHOICE_KEYS
from sqld_harness.duplicate_detector import load_pool_items
from sqld_harness.findings import SEVERITY_ERROR, SEVERITY_INFO, SEVERITY_WARNING, sort_findings
from sqld_harness.import_exporter import render_stem, to_import_item, to_question_metadata
from sqld_harness.pipeline import attach_verifications, run_offline_checks
from sqld_harness.question_schema import load_questions
from sqld_harness.question_statistics import build_question_statistics, format_statistics_text
from sqld_harness.report_html import render_html_report
from sqld_harness.report_markdown import render_markdown_report
from sqld_harness.scaffold_template import build_scaffold_yaml
from sqld_harness.trend_catalog import load_trend_catalog
from sqld_harness.verification_runner import DEFAULT_CACHE_PATH, DEFAULT_WORKER_COUNT, VerificationCache, run_verifications

LOG_PREFIX = "[sqld harness]"
DEFAULT_REPORT_TITLE = "SQLD 문제 하네스 리포트"


# ── 공통 단계 ─────────────────────────────────────────────

def build_offline_batch(arguments):
    """(a)(b)(d)(e) 단계: 문제 로드 > 구조·경향·품질·중복·해설 점검"""
    questions = load_questions(arguments.path)
    catalog = load_trend_catalog(getattr(arguments, "trend_catalog", None))
    pool_items = load_pool_items(arguments.against) if getattr(arguments, "against", None) else None
    return run_offline_checks(questions, catalog, pool_items), catalog


def print_findings(findings, minimum_severity=SEVERITY_WARNING):
    visible_severities = {SEVERITY_ERROR, SEVERITY_WARNING} if minimum_severity == SEVERITY_WARNING else {SEVERITY_ERROR, SEVERITY_WARNING, SEVERITY_INFO}
    for finding in findings:
        if finding.severity in visible_severities:
            print(finding.to_line())


def write_json(path, document):
    Path(path).write_text(json.dumps(document, ensure_ascii=False, indent=2), encoding="utf-8")


# ── 명령 ─────────────────────────────────────────────────

def command_verify(arguments):
    """(c)(f) 단계 포함 전체: 차단 finding 없음 + Oracle 통과분만 가져오기 JSON"""
    from sqld_harness.oracle_executor import OracleExecutor

    batch, catalog = build_offline_batch(arguments)
    cache = VerificationCache(None if arguments.no_cache else arguments.cache)
    executor = OracleExecutor()
    try:
        verification_results = run_verifications(executor, batch.questions, cache, arguments.workers)
    finally:
        executor.close()
    attach_verifications(batch, verification_results)
    for outcome in batch.outcomes:
        cache_mark = " (cache)" if outcome.verification.is_from_cache else ""
        print(f"[{'PASS' if outcome.is_passed else 'FAIL'}] {outcome.question_id} ({outcome.question.get('topicCode')}){cache_mark}")
        for line in outcome.verification.report_lines:
            print(line)
        print_findings(sort_findings(outcome.findings))
    print_findings(batch.batch_findings)
    passed_outcomes = [outcome for outcome in batch.outcomes if outcome.is_passed]
    failed_ids = [outcome.question_id for outcome in batch.outcomes if not outcome.is_passed]
    write_json(arguments.output, [to_import_item(outcome.question) for outcome in passed_outcomes])
    if arguments.metadata:
        write_json(arguments.metadata, [to_question_metadata(outcome.question, outcome.explanation) for outcome in passed_outcomes])
    if arguments.results:
        write_json(arguments.results, [result.to_dict() for result in verification_results])
    print(f"\n{LOG_PREFIX} passed {len(passed_outcomes)} / {len(batch.outcomes)} > {arguments.output}")
    if failed_ids:
        print(f"{LOG_PREFIX} failed : " + ", ".join(failed_ids))
    return 0 if not failed_ids else 1


def command_render(arguments):
    for question in load_questions(arguments.path):
        print(render_stem(question))
        for index, choice in enumerate(question["choices"]):
            print(f"{CHOICE_KEYS[index]}. {choice['body']}{'  (정답)' if choice.get('isCorrect') else ''}")
        print("-" * 40)
    return 0


def command_lint(arguments):
    batch, _ = build_offline_batch(arguments)
    findings = sort_findings(batch.all_findings)
    print_findings(findings, SEVERITY_INFO if arguments.verbose else SEVERITY_WARNING)
    error_count = sum(1 for finding in findings if finding.severity == SEVERITY_ERROR)
    warning_count = sum(1 for finding in findings if finding.severity == SEVERITY_WARNING)
    print(f"{LOG_PREFIX} lint {len(batch.outcomes)} questions : error {error_count}, warning {warning_count}")
    is_failed = error_count > 0 or (arguments.strict and warning_count > 0)
    return 1 if is_failed else 0


def command_stats(arguments):
    batch, catalog = build_offline_batch(arguments)
    statistics = build_question_statistics(batch.questions, catalog, findings=batch.all_findings)
    if arguments.json:
        print(json.dumps(statistics, ensure_ascii=False, indent=2))
    else:
        print("\n".join(format_statistics_text(statistics)))
    return 0


def command_report(arguments):
    batch, catalog = build_offline_batch(arguments)
    verification_results = load_verification_results(arguments.results, batch) if arguments.results else None
    if verification_results is not None:
        attach_verifications(batch, verification_results)
    statistics = build_question_statistics(batch.questions, catalog, verification_results, batch.all_findings)
    markdown_path = arguments.md or (None if arguments.html else "report.md")
    if markdown_path:
        Path(markdown_path).write_text(render_markdown_report(batch, statistics, arguments.title), encoding="utf-8")
        print(f"{LOG_PREFIX} report md > {markdown_path}")
    if arguments.html:
        Path(arguments.html).write_text(render_html_report(batch, statistics, arguments.title), encoding="utf-8")
        print(f"{LOG_PREFIX} report html > {arguments.html}")
    return 0


def load_verification_results(path, batch):
    """verify --results 파일 > 문제 순서대로 결과 (없는 문제는 None)"""
    result_by_id = {entry["questionId"]: VerificationResult.from_dict(entry) for entry in json.loads(Path(path).read_text(encoding="utf-8"))}
    return [result_by_id.get(outcome.question_id) for outcome in batch.outcomes]


def command_explain(arguments):
    batch, _ = build_offline_batch(arguments)
    explanation_rules = [finding for finding in batch.all_findings if finding.rule.startswith("explanation.")]
    print_findings(sort_findings(explanation_rules), SEVERITY_INFO)
    write_json(arguments.output, [{"id": outcome.question_id, "questionUuid": outcome.question.get("questionUuid"), **outcome.explanation} for outcome in batch.outcomes])
    print(f"{LOG_PREFIX} explanation drafts {len(batch.outcomes)} > {arguments.output}")
    return 1 if any(finding.severity == SEVERITY_ERROR for finding in explanation_rules) else 0


def command_scaffold(arguments):
    print(build_scaffold_yaml(arguments.id))
    return 0


# ── 인자 ─────────────────────────────────────────────────

def build_argument_parser():
    parser = argparse.ArgumentParser(description="SQLD 고정 보기 문제 하네스 v2")
    subparsers = parser.add_subparsers(dest="command", required=True)

    def add_question_command(name, help_text):
        command_parser = subparsers.add_parser(name, help=help_text)
        command_parser.add_argument("path")
        command_parser.add_argument("--trend-catalog", help="출제 경향 카탈로그 YAML (기본 docs/sqld-research/trend-catalog.yaml)")
        command_parser.add_argument("--against", help="기존 문제 풀 JSON (관리자 내보내기) 중복 비교")
        return command_parser

    verify_parser = add_question_command("verify", "Oracle 검증 + 가져오기 JSON")
    verify_parser.add_argument("--output", default="import.json")
    verify_parser.add_argument("--metadata", help="통과분 v2 메타(경향·개념·해설 초안) JSON")
    verify_parser.add_argument("--results", help="문제별 검증 결과 JSON (report --results 입력)")
    verify_parser.add_argument("--workers", type=int, default=DEFAULT_WORKER_COUNT)
    verify_parser.add_argument("--cache", default=str(DEFAULT_CACHE_PATH))
    verify_parser.add_argument("--no-cache", action="store_true")

    render_parser = subparsers.add_parser("render", help="지문 미리보기")
    render_parser.add_argument("path")

    lint_parser = add_question_command("lint", "Oracle 없이 구조·품질 점검")
    lint_parser.add_argument("--strict", action="store_true", help="warning 도 실패 처리")
    lint_parser.add_argument("--verbose", action="store_true", help="info 까지 출력")

    stats_parser = add_question_command("stats", "분포 통계")
    stats_parser.add_argument("--json", action="store_true")

    report_parser = add_question_command("report", "Markdown·HTML 리포트")
    report_parser.add_argument("--results", help="verify --results 출력 파일")
    report_parser.add_argument("--md")
    report_parser.add_argument("--html")
    report_parser.add_argument("--title", default=DEFAULT_REPORT_TITLE)

    explain_parser = add_question_command("explain", "해설 초안 생성·검증")
    explain_parser.add_argument("--output", default="explanations.json")

    scaffold_parser = subparsers.add_parser("scaffold", help="YAML v2 빈 양식")
    scaffold_parser.add_argument("--id", default="new_question_id")
    return parser


COMMAND_HANDLERS = {
    "verify": command_verify,
    "render": command_render,
    "lint": command_lint,
    "stats": command_stats,
    "report": command_report,
    "explain": command_explain,
    "scaffold": command_scaffold,
}


def main(argv=None):
    arguments = build_argument_parser().parse_args(argv)
    return COMMAND_HANDLERS[arguments.command](arguments)


if __name__ == "__main__":
    sys.exit(main())
