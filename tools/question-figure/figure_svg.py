"""문제 그림 SVG 생성기 (#1132): 그림 명세 JSON > 앱(flutter_svg)이 그대로 그리는 SVG
그림 4종: 엔터티 상자(IE 표기), 관계선(실선 식별·점선 비식별, 양 끝 IE 기호), 일반 상자, 화살표
서브타입 묶음(슈퍼타입 아래 갈래)도 지원. CSS·foreignObject·외부 참조 없음 (서버 QuestionFigureSvgRule 통과)

사용: python3 figure_svg.py <명세.json> [--out 그림.svg]
명세 형식은 README.md
"""
import argparse
import json
import re
import sys
from html import escape

from barker_notation import BARKER_ATTRIBUTE_PREFIX, draw_barker_entity, draw_barker_relation, draw_identifying_bar
from generic_shapes import draw_arrow, draw_subtype_group
from mermaid_to_spec import convert_mermaid_to_spec

from figure_style import (DEPENDENT_ENTITY_CORNER_RADIUS, ENTITY_BOX_PADDING_Y, ENTITY_NAME_GAP, ENTITY_NAME_HEIGHT,
                          LABEL_OFFSET, BOLD_FONT_FAMILY, BOX_FILL, BOX_PADDING_X, CANVAS_MARGIN, DASH_PATTERN, FONT_FAMILY,
                          FONT_SIZE, GAP_X, GAP_Y, HEADER_HEIGHT, LINE_COLOR, LINE_HEIGHT,
                          MIN_BOX_WIDTH, STROKE_WIDTH, TEXT_COLOR, TITLE_FONT_SIZE)

# IE 기호 위치: 엔터티 쪽부터 최대 기호, 그 바깥 최소 기호 (엔터티에 가까운 기호 = 최대)
MAX_SYMBOL_DISTANCE = 9
CROW_FOOT_LENGTH = 13
CROW_FOOT_SPREAD = 8
MIN_SYMBOL_DISTANCE = 22
SYMBOL_HALF = 7
CIRCLE_RADIUS = 5

# 관계 끝 표기 4종 > (최소, 최대): 정확히 하나, 0 또는 1, 1 이상, 0 이상
END_NOTATIONS = {
    "||": ("one", "one"),
    "o|": ("zero", "one"),
    "|<": ("one", "many"),
    "o<": ("zero", "many"),
    "": (None, None),
}


def measure_text_width(text, font_size=FONT_SIZE):
    """글자 폭 추정 (한글·전각 1em, 그 외 0.6em)"""
    return sum(font_size if ord(ch) > 0x2E80 else font_size * 0.6 for ch in text)


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


def build_entity_box(entity):
    """IE 엔터티 > 크기: 상자 위 이름 줄 + 상자(주식별자 칸, 구분선, 일반 속성 칸)
    바커(divider False)는 이름이 상자 안 맨 위"""
    primary_keys = [to_display_attribute(name) for name in entity.get("pk", [])]
    attributes = [to_display_attribute(name) for name in entity.get("attrs", [])]
    lines = [entity["title"], *primary_keys, *attributes]
    width = max([MIN_BOX_WIDTH] + [measure_text_width(line) + BOX_PADDING_X * 2 for line in lines])
    if not entity.get("divider", True):
        # 바커: 속성 줄 앞 네모만큼 넓힘
        width += measure_text_width(BARKER_ATTRIBUTE_PREFIX)
        height = HEADER_HEIGHT + max(1, len(primary_keys) + len(attributes)) * LINE_HEIGHT + 8
        return {"kind": "entity", "width": width, "height": height, "nameHeight": 0, **entity,
                "pk": primary_keys, "attrs": attributes}
    box_height = ENTITY_BOX_PADDING_Y * 2 + (max(1, len(primary_keys)) + max(1, len(attributes))) * LINE_HEIGHT
    return {"kind": "entity", "width": width, "height": ENTITY_NAME_HEIGHT + box_height, "nameHeight": ENTITY_NAME_HEIGHT,
            **entity, "pk": primary_keys, "attrs": attributes, "isDependent": is_dependent_entity(entity)}


def build_plain_box(box):
    """일반 상자 > 크기 (여러 줄 글자, 가운데 정렬)"""
    lines = box["text"] if isinstance(box["text"], list) else [box["text"]]
    width = max([MIN_BOX_WIDTH] + [measure_text_width(line) + BOX_PADDING_X * 2 for line in lines])
    height = len(lines) * LINE_HEIGHT + 14
    return {"kind": "box", "width": width, "height": height, "lines": lines, **box}


def place_on_grid(shapes):
    """격자 배치: 칸(col, row)마다 열 폭·행 높이 최댓값 > 칸 가운데에 상자"""
    column_widths, row_heights = {}, {}
    for shape in shapes:
        column_widths[shape["col"]] = max(column_widths.get(shape["col"], 0), shape["width"])
        row_heights[shape["row"]] = max(row_heights.get(shape["row"], 0), shape["height"])
    column_x, row_y = {}, {}
    x = CANVAS_MARGIN
    for col in sorted(column_widths):
        column_x[col] = x
        x += column_widths[col] + GAP_X
    y = CANVAS_MARGIN
    for row in sorted(row_heights):
        row_y[row] = y
        y += row_heights[row] + GAP_Y
    for shape in shapes:
        shape["x"] = column_x[shape["col"]] + (column_widths[shape["col"]] - shape["width"]) / 2
        shape["y"] = row_y[shape["row"]] + (row_heights[shape["row"]] - shape["height"]) / 2
    canvas_width = x - GAP_X + CANVAS_MARGIN
    canvas_height = y - GAP_Y + CANVAS_MARGIN
    return canvas_width, canvas_height


def anchor_points(source, target):
    """두 상자 사이 선 양 끝 (같은 행 > 좌우 변, 같은 열 > 위아래 변, 그 외 > 가까운 변 꺾은선)"""
    source_center = (source["x"] + source["width"] / 2, source["y"] + source["height"] / 2)
    target_center = (target["x"] + target["width"] / 2, target["y"] + target["height"] / 2)
    if source["row"] == target["row"]:
        left, right = (source, target) if source_center[0] < target_center[0] else (target, source)
        y = (max(left["y"], right["y"]) + min(left["y"] + left["height"], right["y"] + right["height"])) / 2
        start, end = (left["x"] + left["width"], y), (right["x"], y)
        return [start, end] if left is source else [end, start]
    if source["col"] == target["col"]:
        top, bottom = (source, target) if source_center[1] < target_center[1] else (target, source)
        x = (max(top["x"], bottom["x"]) + min(top["x"] + top["width"], bottom["x"] + bottom["width"])) / 2
        start, end = (x, top["y"] + top["height"]), (x, bottom["y"])
        return [start, end] if top is source else [end, start]
    # 꺾은선: 출발 상자 위아래 변 가운데 > 세로 > 도착 상자 좌우 변 (같은 행 가로선과 겹치지 않게)
    going_down = target_center[1] > source_center[1]
    start = (source_center[0], source["y"] + source["height"] if going_down else source["y"])
    going_right = target_center[0] > source_center[0]
    end = (target["x"] if going_right else target["x"] + target["width"], target_center[1])
    return [start, (start[0], end[1]), end]


def unit_vector(from_point, to_point):
    dx, dy = to_point[0] - from_point[0], to_point[1] - from_point[1]
    length = (dx * dx + dy * dy) ** 0.5 or 1
    return dx / length, dy / length


def draw_end_symbols(edge_point, outward, notation):
    """관계 끝 IE 기호: 엔터티 쪽 최대 기호(| 또는 까마귀발) > 바깥 최소 기호(| 또는 원)"""
    minimum, maximum = END_NOTATIONS[notation]
    ux, uy = outward
    px, py = -uy, ux
    parts = []

    def bar_at(distance):
        cx, cy = edge_point[0] + ux * distance, edge_point[1] + uy * distance
        return (f'<line x1="{cx + px * SYMBOL_HALF:.1f}" y1="{cy + py * SYMBOL_HALF:.1f}" '
                f'x2="{cx - px * SYMBOL_HALF:.1f}" y2="{cy - py * SYMBOL_HALF:.1f}" '
                f'stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>')

    if maximum == "one":
        parts.append(bar_at(MAX_SYMBOL_DISTANCE))
    elif maximum == "many":
        tip_x, tip_y = edge_point[0] + ux * CROW_FOOT_LENGTH, edge_point[1] + uy * CROW_FOOT_LENGTH
        for spread in (-CROW_FOOT_SPREAD, 0, CROW_FOOT_SPREAD):
            foot_x, foot_y = edge_point[0] + px * spread, edge_point[1] + py * spread
            parts.append(f'<line x1="{tip_x:.1f}" y1="{tip_y:.1f}" x2="{foot_x:.1f}" y2="{foot_y:.1f}" '
                         f'stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>')
    if minimum == "one":
        parts.append(bar_at(MIN_SYMBOL_DISTANCE))
    elif minimum == "zero":
        cx = edge_point[0] + ux * (MIN_SYMBOL_DISTANCE + CIRCLE_RADIUS - 2)
        cy = edge_point[1] + uy * (MIN_SYMBOL_DISTANCE + CIRCLE_RADIUS - 2)
        parts.append(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{CIRCLE_RADIUS}" fill="{BOX_FILL}" '
                     f'stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>')
    return parts


def draw_text(x, y, text, anchor="start", weight="normal", font_size=FONT_SIZE):
    font_family = BOLD_FONT_FAMILY if weight == "bold" else FONT_FAMILY
    return (f'<text x="{x:.1f}" y="{y:.1f}" font-family="{font_family}" font-size="{font_size}" '
            f'font-weight="{weight}" fill="{TEXT_COLOR}" text-anchor="{anchor}">{escape(text)}</text>')


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
        parts.append(draw_text(x + BOX_PADDING_X, text_y, line))
        text_y += LINE_HEIGHT
    divider_y = y + ENTITY_BOX_PADDING_Y + max(1, len(primary_keys)) * LINE_HEIGHT + ENTITY_BOX_PADDING_Y / 2
    parts.append(f'<line x1="{x:.1f}" y1="{divider_y:.1f}" x2="{x + width:.1f}" y2="{divider_y:.1f}" '
                 f'stroke="{LINE_COLOR}" stroke-width="1"/>')
    text_y = divider_y + ENTITY_BOX_PADDING_Y / 2 + 14
    for line in attributes:
        parts.append(draw_text(x + BOX_PADDING_X, text_y, line))
        text_y += LINE_HEIGHT
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


def draw_relation(relation, shape_by_id, notation, label_drawer=draw_label):
    """관계선: IE(실선 식별·점선 비식별 > 양 끝 IE 기호) 또는 바커(끝마다 실선·점선 절반, 식별 바) > 가운데 글자"""
    source, target = shape_by_id[relation["from"]], shape_by_id[relation["to"]]
    points = anchor_points(source, target)
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


def render_figure(spec):
    """명세 > SVG 문자열: 상자 크기 > 격자 배치 > 선(뒤) > 상자(앞), notation: ie(기본) 또는 barker"""
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
    canvas_width, canvas_height = place_on_grid(shapes)
    for shape in shapes:
        if shape.get("nameHeight"):
            shape["y"] += shape["nameHeight"]
            shape["height"] -= shape["nameHeight"]
    # 라벨은 그림 폭을 알아야 잘리지 않는 쪽에 놓음
    def label_drawer(points, label):
        return draw_label(points, label, canvas_width)

    parts = []
    for relation in spec.get("relations", []):
        parts += draw_relation(relation, shape_by_id, notation, label_drawer)
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
    # 선 끝 기호는 상자 밖이라 상자 그린 뒤에도 보임, 라벨 상자는 선 위
    header = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {canvas_width:.0f} {canvas_height:.0f}" '
              f'width="{canvas_width:.0f}" height="{canvas_height:.0f}">')
    return header + "".join(parts) + "</svg>"


def main():
    parser = argparse.ArgumentParser(description="문제 그림 명세(JSON) 또는 머메이드 erDiagram(.mmd) > SVG")
    parser.add_argument("spec")
    parser.add_argument("--out")
    args = parser.parse_args()
    with open(args.spec, encoding="utf-8") as spec_file:
        source = spec_file.read()
    spec = json.loads(source) if source.lstrip().startswith("{") else convert_mermaid_to_spec(source)
    svg = render_figure(spec)
    if args.out:
        with open(args.out, "w", encoding="utf-8") as out_file:
            out_file.write(svg)
    else:
        sys.stdout.write(svg)


if __name__ == "__main__":
    main()
