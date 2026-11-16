"""일반 도형 2종 (#1132): 화살표(개념 관계도·분해 전후), 서브타입 묶음(슈퍼타입 아래 갈래)
선 모양·색은 figure_svg 와 같은 상수
"""
from figure_style import BOX_FILL, DASH_PATTERN, LINE_COLOR, STROKE_WIDTH


def unit_vector(from_point, to_point):
    dx, dy = to_point[0] - from_point[0], to_point[1] - from_point[1]
    length = (dx * dx + dy * dy) ** 0.5 or 1
    return dx / length, dy / length


def draw_arrow(arrow, shape_by_id, anchor_points, draw_label):
    """화살표 (일반 그림): 선 > 도착 쪽 삼각 머리 > 가운데 글자"""
    source, target = shape_by_id[arrow["from"]], shape_by_id[arrow["to"]]
    points = anchor_points(source, target)
    dash = f' stroke-dasharray="{DASH_PATTERN}"' if arrow.get("style") == "dashed" else ""
    path = " ".join(f"{'M' if index == 0 else 'L'}{x:.1f},{y:.1f}" for index, (x, y) in enumerate(points))
    parts = [f'<path d="{path}" fill="none" stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"{dash}/>']
    end, before = points[-1], points[-2]
    ux, uy = unit_vector(end, before)
    px, py = -uy, ux
    head = [(end[0], end[1]), (end[0] + ux * 10 + px * 5, end[1] + uy * 10 + py * 5),
            (end[0] + ux * 10 - px * 5, end[1] + uy * 10 - py * 5)]
    parts.append('<polygon points="' + " ".join(f"{x:.1f},{y:.1f}" for x, y in head) + f'" fill="{LINE_COLOR}"/>')
    if arrow.get("label"):
        parts += draw_label(points, arrow["label"])
    return parts


def draw_subtype_group(group, shape_by_id):
    """서브타입 묶음: 슈퍼타입 아래 세로선 > 갈래 기호(배타면 X 표시 원) > 가로선 > 서브타입마다 세로선"""
    parent = shape_by_id[group["parent"]]
    children = [shape_by_id[child_id] for child_id in group["children"]]
    parent_x = parent["x"] + parent["width"] / 2
    parent_bottom = parent["y"] + parent["height"]
    child_top = min(child["y"] for child in children)
    junction_y = parent_bottom + (child_top - parent_bottom) / 2
    parts = [f'<line x1="{parent_x:.1f}" y1="{parent_bottom:.1f}" x2="{parent_x:.1f}" y2="{junction_y - 8:.1f}" '
             f'stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>',
             f'<circle cx="{parent_x:.1f}" cy="{junction_y:.1f}" r="8" fill="{BOX_FILL}" stroke="{LINE_COLOR}" '
             f'stroke-width="{STROKE_WIDTH}"/>']
    if group.get("exclusive"):
        parts.append(f'<path d="M{parent_x - 5:.1f},{junction_y - 5:.1f} L{parent_x + 5:.1f},{junction_y + 5:.1f} '
                     f'M{parent_x + 5:.1f},{junction_y - 5:.1f} L{parent_x - 5:.1f},{junction_y + 5:.1f}" '
                     f'stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>')
    child_xs = [child["x"] + child["width"] / 2 for child in children]
    rail_y = junction_y + 8 + (child_top - junction_y - 8) / 2
    parts.append(f'<line x1="{parent_x:.1f}" y1="{junction_y + 8:.1f}" x2="{parent_x:.1f}" y2="{rail_y:.1f}" '
                 f'stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>')
    parts.append(f'<line x1="{min(child_xs + [parent_x]):.1f}" y1="{rail_y:.1f}" x2="{max(child_xs + [parent_x]):.1f}" '
                 f'y2="{rail_y:.1f}" stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>')
    for child, child_x in zip(children, child_xs):
        parts.append(f'<line x1="{child_x:.1f}" y1="{rail_y:.1f}" x2="{child_x:.1f}" y2="{child["y"]:.1f}" '
                     f'stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>')
    return parts
