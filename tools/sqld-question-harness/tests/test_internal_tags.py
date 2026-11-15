"""내부 관리 태그 (#1117): YAML 경향·개념·파일 묶음 > internalTags, 서버 QuestionInternalTagRule 과 같은 판정"""
from sqld_harness.internal_tags import build_internal_tags, find_internal_tag_findings, find_tag_reject_reason, normalize_tag


def test_builds_tags_in_namespace_order():
    question = {
        "id": "q1",
        "_sourceFile": "batch06-round63a-window.yaml",
        "trend": {"templates": ["T41"], "examRounds": [63], "sources": ["63-17"], "isLatestTrend": True},
        "concepts": ["NULL 3값 논리", "비등가조인"],
        "internalTags": ["New-Type", "bad tag"],
    }
    assert build_internal_tags(question) == [
        "source:63-17", "round:63", "trend:t41", "batch:batch06", "concept:null-3값-논리", "concept:비등가조인", "new-type",
    ]


def test_rule_matches_server():
    assert normalize_tag("  Trend:T41 ") == "trend:t41"
    for invalid_tag in ["", "concept:a b", "trend:t*", "a,b", ":x", "x:", "x" * 65]:
        assert find_tag_reject_reason(invalid_tag), invalid_tag
    assert find_tag_reject_reason("가" * 64) is None


def test_caps_tag_count_and_flags_bad_source():
    question = {"id": "q2", "concepts": [f"개념{number}" for number in range(30)], "trend": {"sources": ["63번17"]}}
    assert len(build_internal_tags(question)) == 20
    assert [finding.rule for finding in find_internal_tag_findings(question)] == ["tag.source-format"]
