"""보기 격자 (#1155): 위 지문 그림(선택) > 아래 ①~④ 번호 붙은 작은 그림·표를 2x2(choiceColumns 로 열 수 변경)
보기 칸은 기존 명세(IE·바커·상자·첸) 또는 표 명세를 그대로 씀. 칸 안 그림은 좁은 격자 간격(compact)
"""
from figure_style import (BOX_FILL, CANVAS_MARGIN, CHOICE_CELL_GAP_X, CHOICE_CELL_GAP_Y, CHOICE_NUMBER_GAP,
                          CHOICE_NUMBER_RADIUS, LINE_COLOR, STEM_TO_CHOICES_GAP, STROKE_WIDTH)
from svg_primitives import draw_text, translate_group, wrap_svg_document
from table_shapes import render_table_body

# 기본 열 수 (시험지 보기 그림 배치 ① ② / ③ ④)
DEFAULT_CHOICE_COLUMNS = 2
# 번호 원 안 숫자 크기
NUMBER_FONT_SIZE = 11


def is_choice_grid_spec(spec):
    return bool(spec.get("choiceFigures") or spec.get("choiceTables"))


def render_choice_grid(spec, render_figure_body):
    """보기 격자 명세 > SVG: 칸 본문 렌더 > 열 폭·행 높이 > 지문 그림(가운데) > 번호 + 칸 본문"""
    stem_body = render_figure_body(spec["stemFigure"]) if spec.get("stemFigure") else None
    choice_bodies = _render_choice_bodies(spec, render_figure_body)
    column_count = spec.get("choiceColumns", DEFAULT_CHOICE_COLUMNS)
    cell_width = max(width for width, _, _ in choice_bodies) + _number_column_width()
    row_heights = [max(height for _, height, _ in choice_bodies[start:start + column_count])
                   for start in range(0, len(choice_bodies), column_count)]
    grid_width = cell_width * column_count + CHOICE_CELL_GAP_X * (column_count - 1)
    canvas_width = max(grid_width + CANVAS_MARGIN * 2, stem_body[0] if stem_body else 0)
    parts, y = [], 0
    # 지문 그림 (가운데)
    if stem_body:
        parts.append(translate_group((canvas_width - stem_body[0]) / 2, 0, stem_body[2]))
        y = stem_body[1] + STEM_TO_CHOICES_GAP - CANVAS_MARGIN
    else:
        y = CANVAS_MARGIN
    grid_left = (canvas_width - grid_width) / 2
    # 보기 칸: 번호 원 > 본문
    for index, (width, height, markup) in enumerate(choice_bodies):
        row, col = divmod(index, column_count)
        cell_x = grid_left + col * (cell_width + CHOICE_CELL_GAP_X)
        cell_y = y + sum(row_heights[:row]) + CHOICE_CELL_GAP_Y * row
        parts += _draw_choice_number(cell_x, cell_y, index + 1)
        parts.append(translate_group(cell_x + _number_column_width(), cell_y, markup))
    canvas_height = y + sum(row_heights) + CHOICE_CELL_GAP_Y * (len(row_heights) - 1) + CANVAS_MARGIN
    return wrap_svg_document(canvas_width, canvas_height, "".join(parts))


def _render_choice_bodies(spec, render_figure_body):
    """보기 4개 본문 (그림 명세는 compact 격자, 표 명세는 바깥 여백을 그림과 맞춰 붙임)"""
    if spec.get("choiceFigures"):
        return [render_figure_body(choice, is_compact=True) for choice in spec["choiceFigures"]]
    bodies = []
    for table in spec["choiceTables"]:
        width, height, markup = render_table_body(table)
        bodies.append((width + CANVAS_MARGIN, height + CANVAS_MARGIN, translate_group(0, CANVAS_MARGIN / 2, markup)))
    return bodies


def _number_column_width():
    return CHOICE_NUMBER_RADIUS * 2 + CHOICE_NUMBER_GAP


def _draw_choice_number(x, y, number):
    """보기 번호: 원 안 숫자 (글꼴의 ① 글리프에 기대지 않음)"""
    center_x, center_y = x + CHOICE_NUMBER_RADIUS, y + CANVAS_MARGIN / 2 + CHOICE_NUMBER_RADIUS
    return [f'<circle cx="{center_x:.1f}" cy="{center_y:.1f}" r="{CHOICE_NUMBER_RADIUS}" fill="{BOX_FILL}" '
            f'stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH - 0.4:.1f}"/>',
            draw_text(center_x, center_y + 4, str(number), anchor="middle", weight="bold", font_size=NUMBER_FONT_SIZE)]
