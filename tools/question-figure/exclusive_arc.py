"""상호배타(Arc) 관계 (#1155): 한 엔터티에서 나가는 관계선 2개 이상을 엔터티 가까이에서 호로 묶음
명세 {"entity": "ACCOUNT", "targets": ["PERSON", "COMPANY"]} > 같은 변에서 나가는 선은 변을 따라 벌림 > 호
"""
from figure_style import LINE_COLOR, STROKE_WIDTH
from svg_primitives import unit_vector

# 같은 변에서 나가는 선 사이 간격, 호가 선을 가로지르는 거리(IE 기호 약 32 바깥), 호 볼록 정도
SHARED_SIDE_SPREAD = 40
ARC_DISTANCE_FROM_ENTITY = 40
ARC_BULGE = 10


def find_arc_relation_indexes(arc, relations):
    """호에 묶이는 관계 위치 목록 (entity <-> targets 관계, 방향 무관)"""
    indexes = []
    for target in arc["targets"]:
        matches = [index for index, relation in enumerate(relations)
                   if {relation["from"], relation["to"]} == {arc["entity"], target}]
        if not matches:
            raise ValueError(f'exclusiveArcs: {arc["entity"]}-{target} 관계 없음')
        indexes.append(matches[0])
    return indexes


def spread_shared_side_lines(arc, relations, points_by_index):
    """같은 점에서 나가는 선들을 변을 따라 벌림 (상대 엔터티 위치 순서대로, 선이 엇갈리지 않게)"""
    entity_ends = {}
    for index in find_arc_relation_indexes(arc, relations):
        entity_ends.setdefault(_entity_end(arc, relations[index], points_by_index[index]), []).append(index)
    for edge_point, indexes in entity_ends.items():
        if len(indexes) < 2:
            continue
        outward = _outward(arc, relations[indexes[0]], points_by_index[indexes[0]])
        across = (-outward[1], outward[0])
        indexes.sort(key=lambda index: _far_end(arc, relations[index], points_by_index[index])[0] * across[0]
                     + _far_end(arc, relations[index], points_by_index[index])[1] * across[1])
        for order, index in enumerate(indexes):
            shift = (order - (len(indexes) - 1) / 2) * SHARED_SIDE_SPREAD
            _shift_entity_side(arc, relations[index], points_by_index[index], across, shift)


def draw_exclusive_arc(arc, relations, points_by_index):
    """호: 각 선의 엔터티 쪽 일정 거리 점들 > 양 끝 점을 바깥으로 볼록한 곡선으로 이음"""
    crossings, outwards = [], []
    for index in find_arc_relation_indexes(arc, relations):
        points = points_by_index[index]
        edge_point = _entity_end(arc, relations[index], points)
        outward = _outward(arc, relations[index], points)
        crossings.append((edge_point[0] + outward[0] * ARC_DISTANCE_FROM_ENTITY,
                          edge_point[1] + outward[1] * ARC_DISTANCE_FROM_ENTITY))
        outwards.append(outward)
    mean_outward = unit_vector((0, 0), (sum(u[0] for u in outwards), sum(u[1] for u in outwards)))
    across = (-mean_outward[1], mean_outward[0])
    crossings.sort(key=lambda point: point[0] * across[0] + point[1] * across[1])
    start, end = crossings[0], crossings[-1]
    control = ((start[0] + end[0]) / 2 + mean_outward[0] * ARC_BULGE * 2,
               (start[1] + end[1]) / 2 + mean_outward[1] * ARC_BULGE * 2)
    return [f'<path d="M{start[0]:.1f},{start[1]:.1f} Q{control[0]:.1f},{control[1]:.1f} {end[0]:.1f},{end[1]:.1f}" '
            f'fill="none" stroke="{LINE_COLOR}" stroke-width="{STROKE_WIDTH}"/>']


def _is_entity_at_start(arc, relation):
    return relation["from"] == arc["entity"]


def _entity_end(arc, relation, points):
    return points[0] if _is_entity_at_start(arc, relation) else points[-1]


def _far_end(arc, relation, points):
    return points[-1] if _is_entity_at_start(arc, relation) else points[0]


def _outward(arc, relation, points):
    """엔터티 쪽 끝 > 선을 따라 바깥 방향"""
    if _is_entity_at_start(arc, relation):
        return unit_vector(points[0], points[1])
    return unit_vector(points[-1], points[-2])


def _shift_entity_side(arc, relation, points, across, shift):
    """엔터티 쪽 끝과 그 이웃 점을 변 방향으로 이동 (꺾은선 모서리·곧은선 반대 끝도 같이 > 선 방향 유지)"""
    end_index, neighbor_index = (0, 1) if _is_entity_at_start(arc, relation) else (len(points) - 1, len(points) - 2)
    for index in (end_index, neighbor_index):
        points[index] = (points[index][0] + across[0] * shift, points[index][1] + across[1] * shift)
