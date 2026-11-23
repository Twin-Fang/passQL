"""피터 첸(Chen) 표기 (#1155): 엔터티 사각형, 관계 마름모, 속성 타원(주식별자 밑줄), 연결선 + 차수 글자
배치(좁은 격자 간격): 칸(col, row)마다 본체(사각형·마름모)를 행 가운데 줄에 맞추고, 속성 타원 줄은 본체 위(attrSide "bottom" 이면 아래)
"""
from figure_style import (BOX_FILL, BOX_PADDING_X, CANVAS_MARGIN, COMPACT_GAP_X, COMPACT_GAP_Y,
                          LINE_COLOR, MIN_BOX_WIDTH, STROKE_WIDTH)
from erd_layout import anchor_points
from svg_primitives import draw_line, draw_text, measure_text_width, unit_vector

# 본체 크기: 사각형 높이, 마름모 좌우·위아래 여백
CHEN_ENTITY_HEIGHT = 36
DIAMOND_PADDING_X = 26
DIAMOND_HEIGHT = 48
# 속성 타원: 글자 좌우 여백, 세로 반지름, 타원 사이, 타원 줄과 본체 사이
ELLIPSE_PADDING_X = 12
ELLIPSE_RADIUS_Y = 14
ELLIPSE_GAP = 10
ATTRIBUTE_TO_ENTITY_GAP = 26
# 차수 글자: 선 위 엔터티 쪽 끝에서 거리, 선에서 비켜 쓰는 거리
CARDINALITY_DISTANCE = 16
CARDINALITY_OFFSET = 9
TEXT_BASELINE_SHIFT = 4


def render_chen_body(spec):
    """첸 명세 > (폭, 높이, 본문): 크기 > 행 가운데 줄 맞춤 배치 > 연결선(뒤) > 도형(앞)"""
    entities = [_build_entity(entity) for entity in spec.get("entities", [])]
    relationships = [_build_relationship(relationship) for relationship in spec.get("relationships", [])]
    shapes = entities + relationships
    shape_by_id = {shape["id"]: shape for shape in shapes}
    if len(shape_by_id) != len(shapes):
        raise ValueError("상자 id 중복")
    canvas_width, canvas_height = _place_with_aligned_cores(shapes)
    parts = []
    for relationship in relationships:
        for link in relationship.get("links", []):
            parts += _draw_link(relationship, shape_by_id[link["to"]], link.get("cardinality", ""))
    for entity in entities:
        parts += _draw_entity(entity)
    for relationship in relationships:
        parts += _draw_diamond(relationship)
    return canvas_width, canvas_height, "".join(parts)


def _build_entity(entity):
    """엔터티 > 본체 크기 + 속성 타원 줄 크기 (주식별자 먼저)"""
    attributes = [(name, True) for name in entity.get("pk", [])] + [(name, False) for name in entity.get("attrs", [])]
    ellipse_widths = [measure_text_width(name) + ELLIPSE_PADDING_X * 2 for name, _ in attributes]
    attribute_row_width = sum(ellipse_widths) + ELLIPSE_GAP * max(0, len(attributes) - 1)
    band = ELLIPSE_RADIUS_Y * 2 + ATTRIBUTE_TO_ENTITY_GAP if attributes else 0
    is_bottom = entity.get("attrSide") == "bottom"
    width = max(MIN_BOX_WIDTH, measure_text_width(entity["title"]) + BOX_PADDING_X * 2)
    return {**entity, "kind": "entity", "width": width, "height": CHEN_ENTITY_HEIGHT, "attributes": attributes,
            "ellipseWidths": ellipse_widths, "cellWidth": max(width, attribute_row_width),
            "bandAbove": 0 if is_bottom else band, "bandBelow": band if is_bottom else 0}


def _build_relationship(relationship):
    width = measure_text_width(relationship["title"]) + DIAMOND_PADDING_X * 2
    return {**relationship, "kind": "relationship", "width": width, "height": DIAMOND_HEIGHT, "cellWidth": width,
            "bandAbove": 0, "bandBelow": 0}


def _place_with_aligned_cores(shapes):
    """격자: 열 폭(속성 줄 포함) > 행마다 위 띠·본체·아래 띠 최댓값 > 본체 가운데를 행 가운데 줄에"""
    column_widths, row_bands = {}, {}
    for shape in shapes:
        column_widths[shape["col"]] = max(column_widths.get(shape["col"], 0), shape["cellWidth"])
        above, core, below = row_bands.get(shape["row"], (0, 0, 0))
        row_bands[shape["row"]] = (max(above, shape["bandAbove"]), max(core, shape["height"]),
                                   max(below, shape["bandBelow"]))
    column_x, x = {}, CANVAS_MARGIN
    for col in sorted(column_widths):
        column_x[col] = x
        x += column_widths[col] + COMPACT_GAP_X
    core_center_y, y = {}, CANVAS_MARGIN
    for row in sorted(row_bands):
        above, core, below = row_bands[row]
        core_center_y[row] = y + above + core / 2
        y += above + core + below + COMPACT_GAP_Y
    for shape in shapes:
        shape["x"] = column_x[shape["col"]] + (column_widths[shape["col"]] - shape["width"]) / 2
        shape["y"] = core_center_y[shape["row"]] - shape["height"] / 2
    return x - COMPACT_GAP_X + CANVAS_MARGIN, y - COMPACT_GAP_Y + CANVAS_MARGIN


def _draw_link(relationship, entity, cardinality):
    """마름모 꼭짓점 <-> 엔터티 변 (같은 행·열이면 곧은선, 그 외 꺾은선) > 엔터티 쪽 끝 옆 차수 글자"""
    points = anchor_points(relationship, entity)
    path = " ".join(f"{'M' if index == 0 else 'L'}{x:.1f},{y:.1f}" for index, (x, y) in enumerate(points))
    parts = [f'<path d="{path}" fill="none" stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>']
    if cardinality:
        ux, uy = unit_vector(points[-1], points[-2])
        # 가로선이면 선 위, 세로선이면 선 오른쪽
        is_horizontal = abs(ux) >= abs(uy)
        x = points[-1][0] + ux * CARDINALITY_DISTANCE + (0 if is_horizontal else CARDINALITY_OFFSET)
        y = points[-1][1] + uy * CARDINALITY_DISTANCE - (CARDINALITY_OFFSET if is_horizontal else -TEXT_BASELINE_SHIFT)
        parts.append(draw_text(x, y, cardinality, anchor="middle", weight="bold"))
    return parts


def _draw_entity(shape):
    """사각형 + 가운데 이름 > 속성 타원 줄(가운데 정렬) + 타원에서 사각형 변 가운데로 선"""
    x, y, width, height = shape["x"], shape["y"], shape["width"], shape["height"]
    parts = [f'<rect x="{x:.1f}" y="{y:.1f}" width="{width:.1f}" height="{height:.1f}" fill="{BOX_FILL}" '
             f'stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>',
             draw_text(x + width / 2, y + height / 2 + TEXT_BASELINE_SHIFT, shape["title"], anchor="middle",
                       weight="bold")]
    if not shape["attributes"]:
        return parts
    is_bottom = shape["bandBelow"] > 0
    ellipse_center_y = (y + height + ATTRIBUTE_TO_ENTITY_GAP + ELLIPSE_RADIUS_Y if is_bottom
                        else y - ATTRIBUTE_TO_ENTITY_GAP - ELLIPSE_RADIUS_Y)
    entity_side_y = y + height if is_bottom else y
    row_width = sum(shape["ellipseWidths"]) + ELLIPSE_GAP * (len(shape["attributes"]) - 1)
    ellipse_left = x + width / 2 - row_width / 2
    lines, ellipses = [], []
    for (name, is_key), ellipse_width in zip(shape["attributes"], shape["ellipseWidths"]):
        center_x = ellipse_left + ellipse_width / 2
        near_y = ellipse_center_y - ELLIPSE_RADIUS_Y if is_bottom else ellipse_center_y + ELLIPSE_RADIUS_Y
        lines.append(draw_line(center_x, near_y, x + width / 2, entity_side_y))
        ellipses += _draw_ellipse(center_x, ellipse_center_y, ellipse_width / 2, name, is_key)
        ellipse_left += ellipse_width + ELLIPSE_GAP
    return lines + parts + ellipses


def _draw_ellipse(center_x, center_y, radius_x, name, is_key):
    """속성 타원 + 이름 (주식별자는 밑줄)"""
    parts = [f'<ellipse cx="{center_x:.1f}" cy="{center_y:.1f}" rx="{radius_x:.1f}" ry="{ELLIPSE_RADIUS_Y}" '
             f'fill="{BOX_FILL}" stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>',
             draw_text(center_x, center_y + TEXT_BASELINE_SHIFT, name, anchor="middle")]
    if is_key:
        half = measure_text_width(name) / 2
        underline_y = center_y + TEXT_BASELINE_SHIFT + 3
        parts.append(draw_line(center_x - half, underline_y, center_x + half, underline_y, 1))
    return parts


def _draw_diamond(shape):
    """관계 마름모 (꼭짓점 = 상자 변 가운데) + 가운데 이름"""
    x, y, width, height = shape["x"], shape["y"], shape["width"], shape["height"]
    corners = [(x + width / 2, y), (x + width, y + height / 2), (x + width / 2, y + height), (x, y + height / 2)]
    points = " ".join(f"{cx:.1f},{cy:.1f}" for cx, cy in corners)
    return [f'<polygon points="{points}" fill="{BOX_FILL}" stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>',
            draw_text(x + width / 2, y + height / 2 + TEXT_BASELINE_SHIFT, shape["title"], anchor="middle",
                      weight="bold")]
