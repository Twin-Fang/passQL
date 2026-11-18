"""그림 스냅샷 (#1155): 기존 모양 고정(legacy) + 새 유형 예시(examples) 출력이 저장된 SVG 와 같은지, 서버 규칙 통과"""
import re
from pathlib import Path

import pytest

from figure_svg import load_spec, render_figure

GENERATOR_DIRECTORY = Path(__file__).resolve().parents[1]
SPEC_PATHS = sorted(path for directory in (GENERATOR_DIRECTORY / "tests" / "legacy", GENERATOR_DIRECTORY / "examples")
                    for path in directory.iterdir() if path.suffix in (".json", ".mmd"))

# 서버 QuestionFigureSvgRule 과 같은 조건: 40KB, 금지 요소 6개
MAX_FIGURE_SVG_BYTES = 40 * 1024
FORBIDDEN_PATTERNS = [re.compile(pattern) for pattern in (
    r"<\s*script", r"<\s*foreignobject", r"<\s*image", r"\son[a-z]+\s*=",
    r"href\s*=\s*[\"']\s*(?!#)", r"@import|url\s*\(\s*[\"']?\s*(?!#)")]


@pytest.mark.parametrize("spec_path", SPEC_PATHS, ids=lambda path: path.name)
def test_rendered_svg_matches_snapshot(spec_path):
    """명세 > SVG 가 저장된 스냅샷과 바이트 단위로 같음 (일부러 바꿨으면 tests/record_snapshots.py)"""
    expected_svg = spec_path.with_suffix(".svg").read_text(encoding="utf-8")
    assert render_figure(load_spec(spec_path)) == expected_svg


@pytest.mark.parametrize("spec_path", SPEC_PATHS, ids=lambda path: path.name)
def test_rendered_svg_passes_server_rule(spec_path):
    """서버 규칙: <svg ...>...</svg> 하나, 40KB 이하, 금지 요소 없음"""
    svg = render_figure(load_spec(spec_path)).strip()
    assert svg.startswith("<svg") and svg.endswith("</svg>")
    assert len(svg.encode("utf-8")) <= MAX_FIGURE_SVG_BYTES
    lowered = svg.lower()
    assert not [pattern.pattern for pattern in FORBIDDEN_PATTERNS if pattern.search(lowered)]
