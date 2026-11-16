"""바커(Barker) 표기 그리기 (#1132): 둥근 엔터티 상자, 관계선(끝마다 필수 실선·선택 점선 절반, 까마귀발, 식별 바)
관계 끝 표기 4종: "1" 필수 하나, "1?" 선택 하나, "N" 필수 여럿, "N?" 선택 여럿
"""

# 둥근 상자 모서리, 식별 바 위치(끝에서 거리), 까마귀발 크기
ENTITY_CORNER_RADIUS = 12
IDENTIFYING_BAR_DISTANCE = 22
IDENTIFYING_BAR_HALF = 9
CROW_FOOT_LENGTH = 14
CROW_FOOT_SPREAD = 9


def parse_barker_end(end):
    """끝 표기 > (선택 참여 여부, 여럿 여부)"""
    return end.endswith("?"), end.startswith("N")


def draw_barker_entity(shape, draw_text, line_color, box_fill, stroke_width, padding_x, line_height):
    """둥근 상자: 굵은 이름 > 속성 줄 (식별자 #, 필수 *, 선택 o 는 작성자가 붙임)"""
    x, y, width, height = shape["x"], shape["y"], shape["width"], shape["height"]
    parts = [f'<rect x="{x:.1f}" y="{y:.1f}" width="{width:.1f}" height="{height:.1f}" rx="{ENTITY_CORNER_RADIUS}" '
             f'fill="{box_fill}" stroke="{line_color}" stroke-width="{stroke_width}"/>',
             draw_text(x + width / 2, y + 18, shape["title"], anchor="middle", weight="bold")]
    text_y = y + 18 + line_height + 4
    for line in [*shape.get("pk", []), *shape.get("attrs", [])]:
        parts.append(draw_text(x + padding_x, text_y, line))
        text_y += line_height
    return parts


def draw_barker_relation(points, from_end, to_end, line_color, stroke_width, dash_pattern):
    """곧은 관계선 1개: 가운데에서 둘로 나눠 끝마다 실선(필수)·점선(선택) > 여럿이면 까마귀발"""
    start, end = points[0], points[-1]
    middle = ((start[0] + end[0]) / 2, (start[1] + end[1]) / 2)
    parts = []
    for edge_point, end_notation in ((start, from_end), (end, to_end)):
        is_optional, is_many = parse_barker_end(end_notation)
        dash = f' stroke-dasharray="{dash_pattern}"' if is_optional else ""
        parts.append(f'<line x1="{edge_point[0]:.1f}" y1="{edge_point[1]:.1f}" x2="{middle[0]:.1f}" y2="{middle[1]:.1f}" '
                     f'stroke="{line_color}" stroke-width="{stroke_width}"{dash}/>')
        if is_many:
            parts += _draw_crow_foot(edge_point, middle, line_color, stroke_width)
    return parts


def draw_identifying_bar(points, at_end, line_color, stroke_width):
    """식별 바: 식별자를 물려받는 쪽 끝 가까이 관계선을 가로지르는 바"""
    edge_point, toward = (points[-1], points[0]) if at_end == "to" else (points[0], points[-1])
    ux, uy = _unit(edge_point, toward)
    px, py = -uy, ux
    cx, cy = edge_point[0] + ux * IDENTIFYING_BAR_DISTANCE, edge_point[1] + uy * IDENTIFYING_BAR_DISTANCE
    return [f'<line x1="{cx + px * IDENTIFYING_BAR_HALF:.1f}" y1="{cy + py * IDENTIFYING_BAR_HALF:.1f}" '
            f'x2="{cx - px * IDENTIFYING_BAR_HALF:.1f}" y2="{cy - py * IDENTIFYING_BAR_HALF:.1f}" '
            f'stroke="{line_color}" stroke-width="{stroke_width + 0.6}"/>']


def _draw_crow_foot(edge_point, toward, line_color, stroke_width):
    ux, uy = _unit(edge_point, toward)
    px, py = -uy, ux
    tip = (edge_point[0] + ux * CROW_FOOT_LENGTH, edge_point[1] + uy * CROW_FOOT_LENGTH)
    return [f'<line x1="{tip[0]:.1f}" y1="{tip[1]:.1f}" x2="{edge_point[0] + px * spread:.1f}" '
            f'y2="{edge_point[1] + py * spread:.1f}" stroke="{line_color}" stroke-width="{stroke_width}"/>'
            for spread in (-CROW_FOOT_SPREAD, 0, CROW_FOOT_SPREAD)]


def _unit(from_point, to_point):
    dx, dy = to_point[0] - from_point[0], to_point[1] - from_point[1]
    length = (dx * dx + dy * dy) ** 0.5 or 1
    return dx / length, dy / length
