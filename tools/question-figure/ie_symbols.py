"""IE 관계 끝 기호 (#1132): 엔터티 쪽 최대 기호(| 또는 까마귀발) > 바깥 최소 기호(| 또는 원)"""
from figure_style import BOX_FILL, LINE_COLOR, STROKE_WIDTH

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
