"""머메이드 erDiagram > 그림 명세 (#1132): 문제 하네스 diagramMermaid 를 그대로 그림으로
읽는 것 4가지: 관계 줄(양 끝 차수, -- 식별 실선 / .. 비식별 점선), 엔터티 블록(PK 는 주식별자 칸, FK 는 "(FK)"),
엔터티 별칭 MEMBER["회원 MEMBER"] (상자 제목), 주석 %% pos MEMBER 0 1 (격자 칸, 없으면 등장 순서대로 2열)
관계 라벨은 앞머리 표시만 그림: "ㄱ 소속" > ㄱ, "(가) 주문" > (가), 그 외 라벨은 그리지 않음
"""
import re

# 자동 배치 열 수 (폰 화면 폭)
AUTO_LAYOUT_COLUMNS = 2

# 머메이드 끝 표기 > 명세 표기 (왼쪽 끝, 오른쪽 끝 따로)
LEFT_END_NOTATIONS = {"||": "||", "|o": "o|", "o|": "o|", "}|": "|<", "}o": "o<"}
RIGHT_END_NOTATIONS = {"||": "||", "o|": "o|", "|o": "o|", "|{": "|<", "o{": "o<"}

RELATION_LINE = re.compile(
    r'^\s*(?P<left>[A-Za-z_][\w]*)\s+(?P<left_end>[|}o]{2})(?P<line>--|\.\.)(?P<right_end>[|{o]{2})\s+'
    r'(?P<right>[A-Za-z_][\w]*)\s*(?::\s*"?(?P<label>[^"]*)"?)?\s*$')
ENTITY_OPEN = re.compile(r'^\s*(?P<name>[A-Za-z_][\w]*)\s*(?:\["(?P<alias>[^"]+)"\])?\s*\{\s*$')
ENTITY_ALIAS_ONLY = re.compile(r'^\s*(?P<name>[A-Za-z_][\w]*)\s*\["(?P<alias>[^"]+)"\]\s*$')
ATTRIBUTE_LINE = re.compile(r'^\s*(?P<type>\S+)\s+(?P<name>\S+)(?P<keys>(?:\s+(?:PK|FK|UK)(?:\s*,\s*(?:PK|FK|UK))*)?)'
                            r'(?:\s+"[^"]*")?\s*$')
POSITION_COMMENT = re.compile(r'^\s*%%\s*pos\s+(?P<name>[A-Za-z_][\w]*)\s+(?P<col>\d+)\s+(?P<row>\d+)\s*$')
LABEL_MARKER = re.compile(r'^\s*(\([가-하]\)|[ㄱ-ㅎ])(?:\s|$)')


def convert_mermaid_to_spec(mermaid_text):
    """머메이드 원문 > 그림 명세 dict (render_figure 입력)"""
    entities, relations, positions, order = {}, [], {}, []

    def ensure_entity(name):
        if name not in entities:
            entities[name] = {"id": name, "title": name, "pk": [], "attrs": []}
            order.append(name)
        return entities[name]

    current_entity = None
    for raw_line in mermaid_text.splitlines():
        line = raw_line.strip()
        if not line or line == "erDiagram":
            continue
        if position := POSITION_COMMENT.match(line):
            positions[position["name"]] = (int(position["col"]), int(position["row"]))
            continue
        if line.startswith("%%"):
            continue
        if current_entity is not None:
            if line == "}":
                current_entity = None
            elif attribute := ATTRIBUTE_LINE.match(line):
                _add_attribute(current_entity, attribute["name"], attribute["keys"] or "")
            continue
        if relation := RELATION_LINE.match(line):
            ensure_entity(relation["left"])
            ensure_entity(relation["right"])
            relations.append(_to_relation(relation))
        elif opened := ENTITY_OPEN.match(line):
            current_entity = ensure_entity(opened["name"])
            if opened["alias"]:
                current_entity["title"] = opened["alias"]
        elif alias := ENTITY_ALIAS_ONLY.match(line):
            ensure_entity(alias["name"])["title"] = alias["alias"]
    _place_entities(entities, order, positions)
    return {"entities": [entities[name] for name in order], "relations": relations}


def _add_attribute(entity, name, keys):
    """PK > 주식별자 칸 (FK 도 함께면 "(FK)"), 그 외 > 일반 칸"""
    is_primary_key = "PK" in keys
    display_name = f"{name} (FK)" if "FK" in keys else name
    entity["pk" if is_primary_key else "attrs"].append(display_name)


def _to_relation(relation):
    """관계 줄 > 명세 관계 (-- 실선 식별, .. 점선 비식별, 라벨은 앞머리 표시만)"""
    label = ""
    if relation["label"] and (marker := LABEL_MARKER.match(relation["label"])):
        label = marker[1]
    return {
        "from": relation["left"], "to": relation["right"],
        "fromEnd": LEFT_END_NOTATIONS[relation["left_end"]],
        "toEnd": RIGHT_END_NOTATIONS[relation["right_end"]],
        "style": "solid" if relation["line"] == "--" else "dashed",
        "label": label,
    }


def _place_entities(entities, order, positions):
    """격자 칸: 주석 위치 우선, 나머지는 빈 칸을 등장 순서대로 2열로 채움"""
    taken = set(positions.values())
    next_index = 0
    for name in order:
        if name in positions:
            entities[name]["col"], entities[name]["row"] = positions[name]
            continue
        while (next_index % AUTO_LAYOUT_COLUMNS, next_index // AUTO_LAYOUT_COLUMNS) in taken:
            next_index += 1
        cell = (next_index % AUTO_LAYOUT_COLUMNS, next_index // AUTO_LAYOUT_COLUMNS)
        entities[name]["col"], entities[name]["row"] = cell
        taken.add(cell)
