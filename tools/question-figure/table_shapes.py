"""작은 표 (#1155): 결과 표 보기(choiceTables)·ERD 키 정의 표(keyTable) 공용
모양: 선택 제목 > 머리 줄(굵게) > 값 줄, 바깥 테두리·칸 구분선. NULL(JSON null) > 흐린 NULL 글자, "" > 빈칸
"""
from figure_style import (BOX_FILL, LINE_COLOR, NULL_CELL_TEXT, NULL_TEXT_COLOR, STROKE_WIDTH, TABLE_CELL_PADDING_X,
                          TABLE_ROW_HEIGHT, TABLE_TITLE_HEIGHT)
from svg_primitives import draw_line, draw_text, measure_text_width

# 칸 최소 폭, 칸 안 글자 기준선 (줄 위에서)
MIN_TABLE_CELL_WIDTH = 36
TABLE_TEXT_BASELINE = 16
INNER_LINE_WIDTH = 1


def to_cell_text(value):
    """셀 값 > 글자 (None > NULL, 숫자 > 문자열)"""
    return NULL_CELL_TEXT if value is None else str(value)


def build_table(table):
    """표 명세 {title?, columns, rows} > 크기와 칸 폭"""
    columns = [str(column) for column in table["columns"]]
    rows = [list(row) + [""] * (len(columns) - len(row)) for row in table.get("rows", [])]
    if any(len(row) > len(columns) for row in rows):
        raise ValueError("표 행의 칸 수가 columns 보다 많음")
    column_widths = []
    for index, column in enumerate(columns):
        texts = [column] + [to_cell_text(row[index]) for row in rows]
        column_widths.append(max(MIN_TABLE_CELL_WIDTH,
                                 max(measure_text_width(text) for text in texts) + TABLE_CELL_PADDING_X * 2))
    title = table.get("title", "")
    title_height = TABLE_TITLE_HEIGHT if title else 0
    width = max(sum(column_widths), measure_text_width(title))
    height = title_height + TABLE_ROW_HEIGHT * (1 + len(rows))
    return {"columns": columns, "rows": rows, "columnWidths": column_widths, "title": title,
            "titleHeight": title_height, "width": width, "height": height}


def draw_table(layout, x, y):
    """표 그리기: 제목 > 테두리 > 머리 줄 아래 굵은 선 > 칸 구분선 > 글자(가운데 정렬)"""
    parts = []
    if layout["title"]:
        parts.append(draw_text(x, y + TABLE_TITLE_HEIGHT - 6, layout["title"], weight="bold"))
    top = y + layout["titleHeight"]
    table_width = sum(layout["columnWidths"])
    table_height = TABLE_ROW_HEIGHT * (1 + len(layout["rows"]))
    parts.append(f'<rect x="{x:.1f}" y="{top:.1f}" width="{table_width:.1f}" height="{table_height:.1f}" '
                 f'fill="{BOX_FILL}" stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>')
    # 가로선 (머리 줄 아래는 굵게), 세로선
    for row_index in range(1, len(layout["rows"]) + 1):
        line_y = top + TABLE_ROW_HEIGHT * row_index
        parts.append(draw_line(x, line_y, x + table_width, line_y,
                               STROKE_WIDTH if row_index == 1 else INNER_LINE_WIDTH))
    column_x = x
    for column_width in layout["columnWidths"][:-1]:
        column_x += column_width
        parts.append(draw_line(column_x, top, column_x, top + table_height, INNER_LINE_WIDTH))
    # 글자: 머리 줄 굵게 > 값 줄 (NULL 은 흐리게)
    for row_index, cells in enumerate([layout["columns"], *layout["rows"]]):
        cell_x = x
        for column_width, value in zip(layout["columnWidths"], cells):
            text_y = top + TABLE_ROW_HEIGHT * row_index + TABLE_TEXT_BASELINE
            if row_index == 0:
                parts.append(draw_text(cell_x + column_width / 2, text_y, value, anchor="middle", weight="bold"))
            elif value is None:
                parts.append(draw_text(cell_x + column_width / 2, text_y, NULL_CELL_TEXT, anchor="middle",
                                       color=NULL_TEXT_COLOR))
            elif str(value) != "":
                parts.append(draw_text(cell_x + column_width / 2, text_y, str(value), anchor="middle"))
            cell_x += column_width
    return parts


def render_table_body(table):
    """표 1개 > (폭, 높이, 본문) — 보기 칸·키 표 배치용"""
    layout = build_table(table)
    return layout["width"], layout["height"], "".join(draw_table(layout, 0, 0))
