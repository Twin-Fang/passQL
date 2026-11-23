"""문항 그림 연결 (#1155): figureSpec 새 키(보기 격자·첸·키 표)가 생성기로 그대로 넘어가 SVG 가 되고 lint 오류가 없음"""
from sqld_harness.question_figure import build_figure_svg, lint_question_figure

TWO_ENTITIES = [{"id": "A", "title": "고객", "col": 0, "row": 0}, {"id": "B", "title": "주문", "col": 1, "row": 0}]
NEW_FIGURE_SPECS = {
    "choiceFigures": {"choiceFigures": [{"notation": "barker", "entities": TWO_ENTITIES,
                                         "relations": [{"from": "A", "to": "B", "fromEnd": "1", "toEnd": "N"}]}] * 4},
    "choiceTables": {"choiceTables": [{"columns": ["C1"], "rows": [[None]]}] * 4},
    "chen": {"notation": "chen", "entities": [{"id": "A", "title": "학생", "col": 0, "row": 0, "pk": ["학번"]}],
             "relationships": [{"id": "R", "title": "수강", "col": 1, "row": 0, "links": [{"to": "A"}]}]},
    "keyTable": {"entities": TWO_ENTITIES, "keyTable": {"rows": [["고객", "고객번호", "PK"]]}},
}


def test_new_figure_spec_keys_render_and_pass_lint():
    for name, figure_spec in NEW_FIGURE_SPECS.items():
        question = {"id": f"figure-{name}", "figureSpec": figure_spec}
        assert build_figure_svg(question).startswith("<svg"), name
        assert lint_question_figure(question) == [], name
