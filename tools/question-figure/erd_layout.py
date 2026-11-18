"""격자 배치 (#1132·#1155): 칸(col, row) > 좌표, 상자 사이 선 양 끝, 칸 없는 명세 자동 배치(가로 한 줄 > 2열 > 1열)"""
from itertools import permutations

from figure_style import CANVAS_MARGIN, COMPACT_GAP_X, GAP_X, GAP_Y, PHONE_FIGURE_TARGET_WIDTH

# 자동 배치 시도 열 수 (폰 폭: 2열까지, 넓으면 1열)
AUTO_LAYOUT_MAX_COLUMNS = 2
# 칸 순서를 전부 시도하는 상자 수 상한 (6! = 720)
MAX_SHAPES_FOR_ORDER_SEARCH = 6


def place_on_grid(shapes, gap_x=GAP_X, gap_y=GAP_Y):
    """격자 배치: 칸(col, row)마다 열 폭·행 높이 최댓값 > 칸 가운데에 상자"""
    column_widths, row_heights = {}, {}
    for shape in shapes:
        column_widths[shape["col"]] = max(column_widths.get(shape["col"], 0), shape["width"])
        row_heights[shape["row"]] = max(row_heights.get(shape["row"], 0), shape["height"])
    column_x, row_y = {}, {}
    x = CANVAS_MARGIN
    for col in sorted(column_widths):
        column_x[col] = x
        x += column_widths[col] + gap_x
    y = CANVAS_MARGIN
    for row in sorted(row_heights):
        row_y[row] = y
        y += row_heights[row] + gap_y
    for shape in shapes:
        shape["x"] = column_x[shape["col"]] + (column_widths[shape["col"]] - shape["width"]) / 2
        shape["y"] = row_y[shape["row"]] + (row_heights[shape["row"]] - shape["height"]) / 2
    canvas_width = x - gap_x + CANVAS_MARGIN
    canvas_height = y - gap_y + CANVAS_MARGIN
    return canvas_width, canvas_height


def has_grid_cells(shapes):
    """명세가 칸을 정했는지 (전부 있음 True, 전부 없음 False, 일부만 있으면 오류)"""
    placed_count = sum(1 for shape in shapes if "col" in shape and "row" in shape)
    if 0 < placed_count < len(shapes):
        raise ValueError("col/row 는 모든 상자에 주거나 모두 빼야 함 (빼면 자동 배치)")
    return placed_count == len(shapes)


def assign_auto_grid_cells(shapes, edges=()):
    """칸 자동 배정: 열 수(가로 한 줄이 목표 폭 안이면 한 줄, 아니면 2열, 2열도 넘으면 1열) > 칸 순서 고르기"""
    widest = max(shape["width"] for shape in shapes)
    column_count = 1
    for candidate in (len(shapes), AUTO_LAYOUT_MAX_COLUMNS):
        if candidate > 1 and _estimate_row_width(shapes, candidate, widest) <= PHONE_FIGURE_TARGET_WIDTH:
            column_count = candidate
            break
    ordered_shapes = _choose_cell_order(shapes, list(edges), column_count)
    for index, shape in enumerate(ordered_shapes):
        shape["col"], shape["row"] = index % column_count, index // column_count


def _choose_cell_order(shapes, edges, column_count):
    """선이 곧고 다른 상자를 건너지 않는 순서 (상자 6개 이하는 전부 시도, 그 외 등장 순서). 동점이면 등장 순서에 가까운 쪽"""
    if column_count == 1 or len(shapes) > MAX_SHAPES_FOR_ORDER_SEARCH or not edges:
        return shapes
    best_order, best_cost = shapes, None
    for order in permutations(shapes):
        cost = _count_layout_penalty(order, edges, column_count)
        if best_cost is None or cost < best_cost:
            best_order, best_cost = list(order), cost
    return best_order


def _count_layout_penalty(order, edges, column_count):
    """벌점: 꺾은선 1, 같은 줄인데 사이에 다른 상자가 있으면 2"""
    cell_by_id = {shape["id"]: divmod(index, column_count)[::-1] for index, shape in enumerate(order)}
    penalty = 0
    for source_id, target_id in edges:
        (source_col, source_row), (target_col, target_row) = cell_by_id[source_id], cell_by_id[target_id]
        if source_row != target_row and source_col != target_col:
            penalty += 1
        elif abs(source_col - target_col) > 1 or abs(source_row - target_row) > 1:
            penalty += 2
    return penalty


def _estimate_row_width(shapes, column_count, widest):
    if column_count == len(shapes):
        return sum(shape["width"] for shape in shapes) + COMPACT_GAP_X * (column_count - 1) + CANVAS_MARGIN * 2
    return widest * column_count + COMPACT_GAP_X * (column_count - 1) + CANVAS_MARGIN * 2


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
