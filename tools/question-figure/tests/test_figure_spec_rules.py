"""새 명세 키 동작 (#1155): 자동 배치, 속성 라벨, 표 NULL 표시, 보기 격자 번호, 잘못된 명세 오류"""
import pytest

from figure_svg import render_figure

ENTITY_PAIR = [{"id": "A", "title": "부서", "pk": ["부서번호"], "attrs": ["부서명"]},
               {"id": "B", "title": "사원", "pk": ["사원번호"], "attrs": ["부서번호 (FK)"]}]


def test_entities_without_cells_are_placed_automatically():
    """col/row 없는 명세 > 자동 배치로 그림 생성"""
    svg = render_figure({"entities": ENTITY_PAIR,
                         "relations": [{"from": "A", "to": "B", "fromEnd": "||", "toEnd": "o<", "style": "dashed"}]})
    assert "부서번호(FK)" in svg


def test_partial_cells_are_rejected():
    """col/row 를 일부 상자에만 주면 오류 (배치가 섞이지 않게)"""
    with pytest.raises(ValueError):
        render_figure({"entities": [{**ENTITY_PAIR[0], "col": 0, "row": 0}, ENTITY_PAIR[1]]})


def test_attribute_label_is_drawn_bold():
    svg = render_figure({"entities": [{**ENTITY_PAIR[0], "attrLabels": {"부서명": "(가)"}}]})
    assert 'font-weight="bold" fill="#1C1C1E" text-anchor="start">(가)</text>' in svg


def test_null_cell_shows_null_text_and_empty_string_shows_blank():
    """표 셀: null > 흐린 NULL, "" > 빈칸"""
    table = {"columns": ["C1", "C2"], "rows": [[None, ""]]}
    svg = render_figure({"choiceTables": [table] * 4})
    assert svg.count(">NULL</text>") == 4
    assert "></text>" not in svg


def test_choice_grid_numbers_four_choices():
    svg = render_figure({"choiceFigures": [{"entities": [ENTITY_PAIR[0]]}] * 4})
    assert all(f">{number}</text>" in svg for number in range(1, 5))


def test_exclusive_arc_requires_existing_relation():
    spec = {"entities": [{**ENTITY_PAIR[0], "col": 0, "row": 0}, {**ENTITY_PAIR[1], "col": 1, "row": 0}],
            "relations": [], "exclusiveArcs": [{"entity": "A", "targets": ["B"]}]}
    with pytest.raises(ValueError):
        render_figure(spec)
