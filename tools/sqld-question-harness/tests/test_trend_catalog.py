"""출제 경향 카탈로그: 템플릿 존재, 최신 경향 플래그 근거 회차, 커버리지"""
from sqld_harness.trend_catalog import count_template_coverage, find_trend_findings, load_trend_catalog


def rules_of(findings):
    return {finding.rule: finding.severity for finding in findings}


def test_load_catalog_and_missing_file(trend_catalog_path, tmp_path):
    catalog = load_trend_catalog(trend_catalog_path)
    assert catalog.is_loaded and catalog.latest_exam_rounds == {61, 62}
    assert catalog.get_template_name("T01") == "NOT IN 서브쿼리 + NULL"
    assert not load_trend_catalog(tmp_path / "none.yaml").is_loaded


def test_valid_trend_has_no_finding(not_in_question, trend_catalog_path):
    assert find_trend_findings(not_in_question, load_trend_catalog(trend_catalog_path)) == []


def test_unknown_template_is_error(not_in_question, trend_catalog_path):
    not_in_question["trend"]["templates"] = ["T77"]
    assert rules_of(find_trend_findings(not_in_question, load_trend_catalog(trend_catalog_path)))["trend.template-unknown"] == "error"


def test_latest_flag_needs_latest_round(not_in_question, trend_catalog_path):
    catalog = load_trend_catalog(trend_catalog_path)
    not_in_question["trend"]["examRounds"] = [55]
    assert rules_of(find_trend_findings(not_in_question, catalog))["trend.latest-stale-round"] == "error"
    not_in_question["trend"]["examRounds"] = []
    assert rules_of(find_trend_findings(not_in_question, catalog))["trend.latest-without-round"] == "error"


def test_latest_round_without_flag_suggests_info(pick_question, trend_catalog_path):
    assert rules_of(find_trend_findings(pick_question, load_trend_catalog(trend_catalog_path)))["trend.latest-flag-suggest"] == "info"


def test_coverage_includes_empty_templates(fixture_questions, trend_catalog_path):
    assert count_template_coverage(fixture_questions, load_trend_catalog(trend_catalog_path)) == {"T01": 1, "T06": 1, "T99": 0}
