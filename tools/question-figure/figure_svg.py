"""문제 그림 SVG 생성기 (#1132·#1155): 그림 명세 JSON > 앱(flutter_svg)이 그대로 그리는 SVG
그림: 엔터티 상자(IE·바커·첸 표기), 관계선(실선 식별·점선 비식별, 양 끝 기호), 일반 상자, 화살표, 서브타입 묶음,
상호배타 호, 키 정의 표, 보기 격자(①~④ 그림·결과 표). CSS·foreignObject·외부 참조 없음 (서버 QuestionFigureSvgRule 통과)

사용: python3 figure_svg.py <명세.json|.mmd> [--out 그림.svg]
명세 형식은 README.md
"""
import argparse
import json
import re
import sys
from pathlib import Path

from barker_notation import BARKER_ATTRIBUTE_PREFIX, draw_barker_entity, draw_barker_relation, draw_identifying_bar
from chen_notation import render_chen_body
from choice_grid import is_choice_grid_spec, render_choice_grid
from erd_layout import anchor_points, assign_auto_grid_cells, has_grid_cells, place_on_grid
from exclusive_arc import draw_exclusive_arc, spread_shared_side_lines
from figure_style import (BOX_FILL, BOX_PADDING_X, CANVAS_MARGIN, COMPACT_GAP_X, COMPACT_GAP_Y, DASH_PATTERN,
                          DEPENDENT_ENTITY_CORNER_RADIUS, ENTITY_BOX_PADDING_Y, ENTITY_NAME_GAP, ENTITY_NAME_HEIGHT,
                          GAP_X, GAP_Y, HEADER_HEIGHT, LABEL_OFFSET, LINE_COLOR, LINE_HEIGHT, MIN_BOX_WIDTH,
                          STROKE_WIDTH, TITLE_FONT_SIZE)
from generic_shapes import draw_arrow, draw_subtype_group
from ie_symbols import draw_end_symbols
from mermaid_to_spec import convert_mermaid_to_spec
from svg_primitives import draw_text, measure_text_width, unit_vector, wrap_svg_document
from table_shapes import build_table, draw_table

# 속성 줄 앞 라벨 "(가)" 와 속성 이름 사이
ATTRIBUTE_LABEL_GAP = 4
# ERD 와 키 정의 표 사이, 키 표 기본 열 이름 3개
KEY_TABLE_GAP = 18
DEFAULT_KEY_TABLE_COLUMNS = ["테이블명", "컬럼", "키 구분"]


def to_display_title(title, show_english_names):
    """상자 제목: 시험지처럼 한글 이름만 ("주문 ORDERS" > "주문"), 영문 병기가 필요한 문항만 그대로"""
    if show_english_names:
        return title
    korean_part = re.split(r"\s+[A-Z][A-Z0-9_]*$", title.strip())[0]
    return korean_part if re.search(r"[가-힣]", korean_part) else title


def to_display_attribute(attribute):
    """속성 표시: 시험지처럼 외래키는 이름에 붙여 "부서번호(FK)" (명세는 "부서번호 (FK)")"""
    return attribute.replace(" (FK)", "(FK)")


def is_dependent_entity(entity):
    """부모 식별자를 물려받은 의존 엔터티 (주식별자에 외래키) > 시험지처럼 둥근 모서리"""
    return any(name.endswith("(FK)") for name in entity.get("pk", []))


def build_attribute_labels(entity):
    """attrLabels {속성 이름: "(가)"} > 표시 이름 기준 라벨, 라벨 칸 폭 (라벨 없으면 0)"""
    label_by_attribute = {to_display_attribute(name): label for name, label in entity.get("attrLabels", {}).items()}
    if not label_by_attribute:
        return {}, 0
    return label_by_attribute, max(measure_text_width(label) for label in label_by_attribute.values()) + ATTRIBUTE_LABEL_GAP


def build_entity_box(entity):
    """IE 엔터티 > 크기: 상자 위 이름 줄 + 상자(주식별자 칸, 구분선, 일반 속성 칸)
    바커(divider False)는 이름이 상자 안 맨 위"""
    primary_keys = [to_display_attribute(name) for name in entity.get("pk", [])]
    attributes = [to_display_attribute(name) for name in entity.get("attrs", [])]
    label_by_attribute, label_width = build_attribute_labels(entity)
    lines = [entity["title"], *primary_keys, *attributes]
    width = max([MIN_BOX_WIDTH] + [measure_text_width(line) + BOX_PADDING_X * 2 + (label_width if line in
                                   label_by_attribute else 0) for line in lines])
    if not entity.get("divider", True):
        # 바커: 속성 줄 앞 네모만큼 넓힘
        width += measure_text_width(BARKER_ATTRIBUTE_PREFIX)
        height = HEADER_HEIGHT + max(1, len(primary_keys) + len(attributes)) * LINE_HEIGHT + 8
        return {"kind": "entity", "width": width, "height": height, "nameHeight": 0, **entity,
                "pk": primary_keys, "attrs": attributes}
    box_height = ENTITY_BOX_PADDING_Y * 2 + (max(1, len(primary_keys)) + max(1, len(attributes))) * LINE_HEIGHT
    return {"kind": "entity", "width": width, "height": ENTITY_NAME_HEIGHT + box_height, "nameHeight": ENTITY_NAME_HEIGHT,
            **entity, "pk": primary_keys, "attrs": attributes, "isDependent": is_dependent_entity(entity),
            "labelByAttribute": label_by_attribute, "labelWidth": label_width}


def build_plain_box(box):
    """일반 상자 > 크기 (여러 줄 글자, 가운데 정렬)"""
    lines = box["text"] if isinstance(box["text"], list) else [box["text"]]
    width = max([MIN_BOX_WIDTH] + [measure_text_width(line) + BOX_PADDING_X * 2 for line in lines])
    height = len(lines) * LINE_HEIGHT + 14
    return {"kind": "box", "width": width, "height": height, "lines": lines, **box}


def draw_label(points, label, canvas_width=None):
    """선 가운데 옆 글자 (시험지처럼 상자 없이): 가로선이면 선 위, 세로선이면 선 오른쪽(그림 오른쪽 절반이면 왼쪽, 잘림 방지)"""
    middle_index = len(points) // 2
    a, b = points[middle_index - 1], points[middle_index]
    mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
    is_horizontal = abs(b[0] - a[0]) >= abs(b[1] - a[1])
    if is_horizontal:
        return [draw_text(mx, my - LABEL_OFFSET, label, anchor="middle", weight="bold")]
    if canvas_width is not None and mx > canvas_width / 2:
        return [draw_text(mx - LABEL_OFFSET, my + 4, label, anchor="end", weight="bold")]
    return [draw_text(mx + LABEL_OFFSET, my + 4, label, anchor="start", weight="bold")]


def draw_entity(shape):
    """IE 엔터티 (시험지 모양): 상자 위 이름 > 상자(의존 엔터티는 둥근 모서리) > 주식별자 칸 > 구분선 > 일반 속성 칸"""
    x, y, width, height = shape["x"], shape["y"], shape["width"], shape["height"]
    corner_radius = DEPENDENT_ENTITY_CORNER_RADIUS if shape.get("isDependent") else 0
    parts = [draw_text(x, y - ENTITY_NAME_GAP, shape["title"], weight="bold", font_size=TITLE_FONT_SIZE),
             f'<rect x="{x:.1f}" y="{y:.1f}" width="{width:.1f}" height="{height:.1f}" rx="{corner_radius}" '
             f'fill="{BOX_FILL}" stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>']
    primary_keys, attributes = shape.get("pk", []), shape.get("attrs", [])
    text_y = y + ENTITY_BOX_PADDING_Y + 14
    for line in primary_keys:
        parts += draw_attribute_line(shape, x, text_y, line)
        text_y += LINE_HEIGHT
    divider_y = y + ENTITY_BOX_PADDING_Y + max(1, len(primary_keys)) * LINE_HEIGHT + ENTITY_BOX_PADDING_Y / 2
    parts.append(f'<line x1="{x:.1f}" y1="{divider_y:.1f}" x2="{x + width:.1f}" y2="{divider_y:.1f}" '
                 f'stroke="{LINE_COLOR}" stroke-width="1"/>')
    text_y = divider_y + ENTITY_BOX_PADDING_Y / 2 + 14
    for line in attributes:
        parts += draw_attribute_line(shape, x, text_y, line)
        text_y += LINE_HEIGHT
    return parts


def draw_attribute_line(shape, x, text_y, line):
    """속성 한 줄: 라벨 있는 엔터티는 라벨 칸(굵게) > 이름, 없으면 이름만"""
    label_width = shape.get("labelWidth", 0)
    if not label_width:
        return [draw_text(x + BOX_PADDING_X, text_y, line)]
    parts = [draw_text(x + BOX_PADDING_X + label_width, text_y, line)]
    if line in shape["labelByAttribute"]:
        parts.append(draw_text(x + BOX_PADDING_X, text_y, shape["labelByAttribute"][line], weight="bold"))
    return parts


def draw_plain_box(shape):
    x, y, width, height = shape["x"], shape["y"], shape["width"], shape["height"]
    radius = 12 if shape.get("rounded") else 3
    parts = [f'<rect x="{x:.1f}" y="{y:.1f}" width="{width:.1f}" height="{height:.1f}" rx="{radius}" fill="{BOX_FILL}" '
             f'stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>']
    text_y = y + 7 + 14
    for line in shape["lines"]:
        parts.append(draw_text(x + width / 2, text_y, line, anchor="middle",
                               weight="bold" if shape.get("bold") else "normal"))
        text_y += LINE_HEIGHT
    return parts


def draw_relation(relation, points, notation, label_drawer=draw_label):
    """관계선: IE(실선 식별·점선 비식별 > 양 끝 IE 기호) 또는 바커(끝마다 실선·점선 절반, 식별 바) > 가운데 글자"""
    if notation == "barker":
        parts = draw_barker_relation(points, relation["fromEnd"], relation["toEnd"], LINE_COLOR, STROKE_WIDTH,
                                     DASH_PATTERN)
        if relation.get("identifyingAt"):
            parts += draw_identifying_bar(points, relation["identifyingAt"], LINE_COLOR, STROKE_WIDTH)
        if relation.get("label"):
            parts += label_drawer(points, relation["label"])
        return parts
    dash = f' stroke-dasharray="{DASH_PATTERN}"' if relation.get("style") == "dashed" else ""
    path = " ".join(f"{'M' if index == 0 else 'L'}{x:.1f},{y:.1f}" for index, (x, y) in enumerate(points))
    parts = [f'<path d="{path}" fill="none" stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"{dash}/>']
    parts += draw_end_symbols(points[0], unit_vector(points[0], points[1]), relation.get("fromEnd", ""))
    parts += draw_end_symbols(points[-1], unit_vector(points[-1], points[-2]), relation.get("toEnd", ""))
    if relation.get("label"):
        parts += label_drawer(points, relation["label"])
    return parts


def render_erd_body(spec, is_compact=False):
    """ERD 명세 > (폭, 높이, 본문): 상자 크기 > 격자 배치(칸 없으면 자동) > 선(뒤) > 상자(앞) > 키 정의 표"""
    notation = spec.get("notation", "ie")
    entities = spec.get("entities", [])
    if notation == "barker":
        entities = [{**entity, "divider": False} for entity in entities]
    show_english_names = spec.get("showEnglishNames", False)
    entities = [{**entity, "title": to_display_title(entity["title"], show_english_names)} for entity in entities]
    shapes = [build_entity_box(entity) for entity in entities]
    shapes += [build_plain_box(box) for box in spec.get("boxes", [])]
    shape_by_id = {shape["id"]: shape for shape in shapes}
    if len(shape_by_id) != len(shapes):
        raise ValueError("상자 id 중복")
    # 칸 없는 명세는 자동 배치 + 좁은 간격 (큰 ERD 가 폰 폭에서 글자가 줄지 않게)
    is_auto_layout = bool(shapes) and not has_grid_cells(shapes)
    if is_auto_layout:
        edges = [(line["from"], line["to"]) for line in [*spec.get("relations", []), *spec.get("arrows", [])]]
        assign_auto_grid_cells(shapes, edges)
    is_narrow = is_compact or is_auto_layout
    canvas_width, canvas_height = place_on_grid(shapes, *((COMPACT_GAP_X, COMPACT_GAP_Y) if is_narrow else (GAP_X, GAP_Y)))
    for shape in shapes:
        if shape.get("nameHeight"):
            shape["y"] += shape["nameHeight"]
            shape["height"] -= shape["nameHeight"]

    # 라벨은 그림 폭을 알아야 잘리지 않는 쪽에 놓음
    def label_drawer(points, label):
        return draw_label(points, label, canvas_width)

    relations = spec.get("relations", [])
    points_by_index = [anchor_points(shape_by_id[relation["from"]], shape_by_id[relation["to"]]) for relation in relations]
    for arc in spec.get("exclusiveArcs", []):
        spread_shared_side_lines(arc, relations, points_by_index)
    parts = []
    for relation, points in zip(relations, points_by_index):
        parts += draw_relation(relation, points, notation, label_drawer)
    for arc in spec.get("exclusiveArcs", []):
        parts += draw_exclusive_arc(arc, relations, points_by_index)
    for arrow in spec.get("arrows", []):
        parts += draw_arrow(arrow, shape_by_id, anchor_points, label_drawer)
    for group in spec.get("subtypes", []):
        parts += draw_subtype_group(group, shape_by_id)
    for shape in shapes:
        if shape["kind"] != "entity":
            parts += draw_plain_box(shape)
        elif notation == "barker":
            parts += draw_barker_entity(shape, draw_text, LINE_COLOR, BOX_FILL, STROKE_WIDTH, BOX_PADDING_X, LINE_HEIGHT)
        else:
            parts += draw_entity(shape)
    if spec.get("keyTable"):
        canvas_width, canvas_height = add_key_table(spec["keyTable"], canvas_width, canvas_height, parts)
    # 선 끝 기호는 상자 밖이라 상자 그린 뒤에도 보임, 라벨 상자는 선 위
    return canvas_width, canvas_height, "".join(parts)


def add_key_table(key_table, canvas_width, canvas_height, parts):
    """키 정의 표를 ERD 아래(기본) 또는 오른쪽(position "right")에 붙임 > 늘어난 그림 크기"""
    layout = build_table({"columns": DEFAULT_KEY_TABLE_COLUMNS, **key_table})
    if key_table.get("position") == "right":
        x, y = canvas_width - CANVAS_MARGIN + KEY_TABLE_GAP, CANVAS_MARGIN
        parts += draw_table(layout, x, y)
        return x + layout["width"] + CANVAS_MARGIN, max(canvas_height, y + layout["height"] + CANVAS_MARGIN)
    x, y = CANVAS_MARGIN, canvas_height - CANVAS_MARGIN + KEY_TABLE_GAP
    parts += draw_table(layout, x, y)
    return max(canvas_width, x + layout["width"] + CANVAS_MARGIN), y + layout["height"] + CANVAS_MARGIN


def render_figure_body(spec, is_compact=False):
    """그림 1개 > (폭, 높이, 본문): notation chen 이면 첸, 그 외 ERD(IE·바커·상자)"""
    if spec.get("notation") == "chen":
        return render_chen_body(spec)
    return render_erd_body(spec, is_compact)


def render_figure(spec):
    """명세 > SVG 문자열: 보기 격자(choiceFigures·choiceTables) 또는 그림 1개"""
    if is_choice_grid_spec(spec):
        return render_choice_grid(spec, render_figure_body)
    return wrap_svg_document(*render_figure_body(spec))


def load_spec(path):
    """명세 파일 > dict (JSON, 또는 머메이드 erDiagram 원문)"""
    source = Path(path).read_text(encoding="utf-8")
    return json.loads(source) if source.lstrip().startswith("{") else convert_mermaid_to_spec(source)


def main():
    parser = argparse.ArgumentParser(description="문제 그림 명세(JSON) 또는 머메이드 erDiagram(.mmd) > SVG")
    parser.add_argument("spec")
    parser.add_argument("--out")
    args = parser.parse_args()
    svg = render_figure(load_spec(args.spec))
    if args.out:
        with open(args.out, "w", encoding="utf-8") as out_file:
            out_file.write(svg)
    else:
        sys.stdout.write(svg)


if __name__ == "__main__":
    main()
