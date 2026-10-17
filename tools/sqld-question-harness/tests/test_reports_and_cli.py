"""리포트·통계·CLI 명령 (오프라인 명령만, verify 는 Oracle 통합 테스트)"""
import json

import harness
from sqld_harness.choice_verifier import VerificationResult
from sqld_harness.pipeline import attach_verifications, run_offline_checks
from sqld_harness.question_statistics import build_question_statistics
from sqld_harness.report_html import render_html_report
from sqld_harness.report_markdown import render_markdown_report
from sqld_harness.trend_catalog import load_trend_catalog

from conftest import FIXTURE_DIRECTORY

FIXTURE_QUESTIONS_PATH = str(FIXTURE_DIRECTORY / "questions-v2.yaml")


def build_batch(fixture_questions, trend_catalog_path):
    catalog = load_trend_catalog(trend_catalog_path)
    return run_offline_checks(fixture_questions, catalog), catalog


def test_statistics_counts(fixture_questions, trend_catalog_path):
    batch, catalog = build_batch(fixture_questions, trend_catalog_path)
    statistics = build_question_statistics(batch.questions, catalog, findings=batch.all_findings)
    assert statistics["questionCount"] == 2
    assert statistics["answerPositions"] == {"A": 2, "B": 0, "C": 0, "D": 0}
    assert statistics["latestTrendCount"] == 1
    assert statistics["templateCoverage"] == {"T01": 1, "T06": 1, "T99": 0}
    assert statistics["resultTracing"]["share"] == 1.0


def test_reports_show_failure_reason_and_escape_html(fixture_questions, trend_catalog_path):
    fixture_questions[0]["stem"] = "<script>alert(1)</script> 옳은 것은?"
    batch, catalog = build_batch(fixture_questions, trend_catalog_path)
    attach_verifications(batch, [VerificationResult("fixture_not_in_null", False, ["  [NG] B correct=False answer scalar=0"]), None])
    statistics = build_question_statistics(batch.questions, catalog, None, batch.all_findings)
    markdown = render_markdown_report(batch, statistics, "테스트")
    html = render_html_report(batch, statistics, "테스트")
    assert "[NG] B correct=False" in markdown
    assert "<script>alert" not in html and "&lt;script&gt;" in html
    assert "최신 경향 62회" in html
    assert "prefers-color-scheme:dark" in html


def test_cli_lint_stats_explain_report_scaffold(tmp_path, trend_catalog_path, capsys):
    catalog_option = ["--trend-catalog", str(trend_catalog_path)]
    assert harness.main(["lint", FIXTURE_QUESTIONS_PATH, *catalog_option]) == 0
    assert harness.main(["stats", FIXTURE_QUESTIONS_PATH, *catalog_option]) == 0
    explanation_path = tmp_path / "explanations.json"
    assert harness.main(["explain", FIXTURE_QUESTIONS_PATH, "--output", str(explanation_path), *catalog_option]) == 0
    assert json.loads(explanation_path.read_text(encoding="utf-8"))[0]["id"] == "fixture_not_in_null"
    markdown_path, html_path = tmp_path / "report.md", tmp_path / "report.html"
    assert harness.main(["report", FIXTURE_QUESTIONS_PATH, "--md", str(markdown_path), "--html", str(html_path), *catalog_option]) == 0
    assert "## 요약" in markdown_path.read_text(encoding="utf-8") and html_path.is_file()


def test_cli_stats_json_is_parseable(trend_catalog_path, capsys):
    assert harness.main(["stats", FIXTURE_QUESTIONS_PATH, "--json", "--trend-catalog", str(trend_catalog_path)]) == 0
    assert json.loads(capsys.readouterr().out)["questionCount"] == 2


def test_cli_lint_fails_on_error_and_strict_warning(tmp_path, trend_catalog_path):
    broken_path = tmp_path / "broken.yaml"
    broken_path.write_text((FIXTURE_DIRECTORY / "questions-v2.yaml").read_text(encoding="utf-8").replace("trapDesign:", "unusedField:", 1), encoding="utf-8")
    assert harness.main(["lint", str(broken_path), "--trend-catalog", str(trend_catalog_path)]) == 1


def test_scaffold_output_passes_lint_without_error(tmp_path, trend_catalog_path, capsys):
    assert harness.main(["scaffold", "--id", "scaffold_sample"]) == 0
    scaffold_path = tmp_path / "scaffold.yaml"
    scaffold_path.write_text(capsys.readouterr().out, encoding="utf-8")
    assert harness.main(["lint", str(scaffold_path), "--trend-catalog", str(trend_catalog_path)]) == 0
