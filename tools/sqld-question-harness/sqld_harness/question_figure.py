"""
문제 그림 (#1132): 문제 YAML 의 figureSpec(그림 명세) 또는 diagramMermaid(머메이드 erDiagram) > 가져오기 JSON figureSvg
그림은 tools/question-figure 생성기 하나로만 만듦 (시험지 모양 IE·바커 ERD). figureSpec 이 있으면 우선
lint: 그림 생성 실패, 크기 초과, IE 식별 관계 실선·점선 판정 (자식 주식별자에 부모 식별자가 들어가면 실선)
"""
import sys
from pathlib import Path

from .findings import SEVERITY_ERROR, Finding

# 생성기 위치 (레포 tools/question-figure, 하네스와 같은 레포라 상대 경로 고정)
FIGURE_GENERATOR_DIRECTORY = Path(__file__).resolve().parents[2] / "question-figure"
# 서버 QuestionFigureSvgRule.MAX_FIGURE_SVG_BYTES 와 같음
MAX_FIGURE_SVG_BYTES = 40 * 1024
FOREIGN_KEY_SUFFIX = " (FK)"

if str(FIGURE_GENERATOR_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(FIGURE_GENERATOR_DIRECTORY))
from figure_svg import render_figure  # noqa: E402
from mermaid_to_spec import convert_mermaid_to_spec  # noqa: E402


def build_figure_spec(question):
    """문제 > 그림 명세 (figureSpec 우선, 없으면 diagramMermaid 변환, 둘 다 없으면 None)"""
    if question.get("figureSpec"):
        return question["figureSpec"]
    if question.get("diagramMermaid"):
        return convert_mermaid_to_spec(str(question["diagramMermaid"]))
    return None


def build_figure_svg(question):
    """문제 > 그림 SVG (그림 없으면 None)"""
    figure_spec = build_figure_spec(question)
    return render_figure(figure_spec) if figure_spec else None


def lint_question_figure(question):
    """그림 lint: 생성 > 크기 > IE 식별 관계 선 모양"""
    question_id = str(question.get("id"))
    try:
        figure_spec = build_figure_spec(question)
        figure_svg = render_figure(figure_spec) if figure_spec else None
    except (KeyError, ValueError) as error:
        return [Finding(SEVERITY_ERROR, "figure.render", question_id, f"그림 생성 실패: {error}")]
    if figure_svg is None:
        return []
    findings = []
    if len(figure_svg.encode("utf-8")) > MAX_FIGURE_SVG_BYTES:
        findings.append(Finding(SEVERITY_ERROR, "figure.size", question_id, "그림 SVG 가 40KB 를 넘음"))
    if figure_spec.get("notation", "ie") == "ie":
        findings += [Finding(SEVERITY_ERROR, "figure.identifying-line", question_id, message)
                     for message in find_identifying_line_mismatches(figure_spec)]
    return findings


def find_identifying_line_mismatches(figure_spec):
    """관계마다 자식(부모 주식별자 이름을 외래키로 가진 쪽) 판정 > 외래키가 자식 주식별자에 있으면 실선, 아니면 점선이어야 함"""
    entity_by_id = {entity["id"]: entity for entity in figure_spec.get("entities", [])}
    mismatches = []
    for relation in figure_spec.get("relations", []):
        source, target = entity_by_id.get(relation["from"]), entity_by_id.get(relation["to"])
        if source is None or target is None:
            continue
        for parent, child in ((source, target), (target, source)):
            foreign_key_location = _find_foreign_key_location(parent, child)
            if foreign_key_location is None:
                continue
            expected_style = "solid" if foreign_key_location == "pk" else "dashed"
            actual_style = relation.get("style", "solid")
            if actual_style != expected_style:
                relation_name = f'{relation["from"]}-{relation["to"]}'
                mismatches.append(f"{relation_name}: 외래키가 자식 {'주식별자' if expected_style == 'solid' else '일반 속성'}"
                                  f"에 있어 {'실선(식별, --)' if expected_style == 'solid' else '점선(비식별, ..)'}이어야 함")
            break
    return mismatches


def _find_foreign_key_location(parent, child):
    """부모 주식별자 이름 중 하나를 자식이 외래키로 가지면 그 위치 ('pk' 또는 'attrs'), 없으면 None"""
    parent_key_names = {_strip_foreign_key(name) for name in parent.get("pk", [])}
    for location in ("pk", "attrs"):
        for name in child.get(location, []):
            if name.endswith(FOREIGN_KEY_SUFFIX) and _strip_foreign_key(name) in parent_key_names:
                return location
    return None


def _strip_foreign_key(name):
    return name[: -len(FOREIGN_KEY_SUFFIX)] if name.endswith(FOREIGN_KEY_SUFFIX) else name
