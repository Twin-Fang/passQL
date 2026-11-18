# 문제 그림 생성기 (#1132·#1155)

그림 명세 JSON > SVG. 앱(flutter_svg)이 지문 아래 흰 종이 위에 그대로 그린다.
서버 `QuestionFigureSvgRule`(스크립트·외부 참조·HTML 금지, 40KB 이하)을 통과하는 모양만 만든다.

```
python3 figure_svg.py spec.json --out figure.svg
```

## 명세

```json
{
  "entities": [
    {"id": "MEMBER", "title": "회원 MEMBER", "col": 0, "row": 0, "pk": ["회원번호"], "attrs": ["회원명"]}
  ],
  "boxes": [
    {"id": "A", "text": ["(가)", "엔터티"], "col": 0, "row": 1, "rounded": false, "bold": false}
  ],
  "relations": [
    {"from": "MEMBER", "to": "REVIEW", "fromEnd": "||", "toEnd": "o<", "style": "solid", "label": "ㄱ"}
  ],
  "arrows": [{"from": "A", "to": "B", "label": "", "style": "solid"}],
  "subtypes": [{"parent": "PAY", "children": ["CARD", "BANK"], "exclusive": true}]
}
```

- 배치: `col`, `row` 격자 칸. 같은 행·같은 열이면 곧은 선, 그 외는 세로 > 가로 꺾은선
- 엔터티: 머리(이름) > 주식별자 칸 > 구분선 > 일반 속성 칸 (IE 표기). `"divider": false` 면 구분선 없음
- 관계 끝 표기: `||` 정확히 하나, `o|` 0 또는 1, `|<` 1 이상, `o<` 0 이상, `""` 기호 없음
  - 엔터티에 가까운 기호가 최대(| 또는 까마귀발), 바깥 기호가 최소(| 또는 원)
- `style`: `solid` 식별 관계, `dashed` 비식별 관계
- 글꼴: 앱 번들 Pretendard-Regular / Pretendard-Bold

## 머메이드 입력

`.mmd`(머메이드 `erDiagram`) 파일도 그대로 받는다. 문제 하네스는 문항 YAML 의 `figureSpec`(우선) 또는 `diagramMermaid` 로 그림을 만든다.

```
erDiagram
  MEMBER["회원 MEMBER"]
  %% pos MEMBER 0 0
  %% pos REVIEW 1 0
  MEMBER ||..o{ REVIEW : "작성"
  MEMBER { string 회원번호 PK }
  REVIEW { string 리뷰번호 PK
           string 회원번호 FK }
```

- 별칭 `NAME["표시 이름"]` = 상자 제목, `%% pos 이름 열 행` = 격자 칸(없으면 등장 순서대로 2열)
- `--` 실선(식별), `..` 점선(비식별). 하네스 lint `figure.identifying-line` 이 외래키 위치로 선 모양을 검사
- 관계 라벨은 앞머리 표시(ㄱ, (가))만 그림

## 바커 표기

명세에 `"notation": "barker"`. 관계 끝 `"1"` 필수 하나, `"1?"` 선택 하나, `"N"` 필수 여럿, `"N?"` 선택 여럿,
`"identifyingAt": "to"` 면 그 끝에 식별 바. 엔터티는 둥근 상자, 속성 앞 기호(#, *, o)는 작성자가 붙인다.

## 큰 ERD 자동 배치·속성 라벨 (#1155)

엔터티·상자에 `col`/`row` 를 **모두 빼면** 자동 배치한다(일부만 주면 오류).
가로 한 줄이 목표 폭(`PHONE_FIGURE_TARGET_WIDTH`, 앱 카드 폭 기준) 안이면 한 줄, 아니면 2열, 2열도 넘으면 1열.
칸 순서는 관계선이 곧고 다른 상자를 건너지 않는 순서를 고르고(상자 6개 이하), 간격은 좁은 격자(`COMPACT_GAP_*`).
엔터티 3~4개·컬럼 6~8개도 폭 약 380px 라 폰에서 글자가 줄지 않는다. 예시 `examples/large_erd_attr_labels.json`

```json
{"id": "CUSTOMER", "title": "고객", "pk": ["고객번호"], "attrs": ["고객명", "전화번호"],
 "attrLabels": {"고객번호": "(가)", "전화번호": "(나)"}}
```

- `attrLabels`: 속성 이름(명세에 쓴 그대로, `"부서번호 (FK)"` 도 됨) > 줄 앞 굵은 라벨. 라벨 있는 엔터티는 속성 글자가 라벨 칸만큼 들여 써짐 (IE 표기만)
- 속성 문자열 앞에 `"(가) 회원명"` 처럼 직접 써도 보통 글자로 그대로 나온다(라벨 칸 정렬은 없음)

## 키 정의 표 (#1155)

ERD 명세에 `"keyTable"` 을 더하면 그림 아래(기본) 또는 오른쪽(`"position": "right"`)에 작은 표. 예시 `examples/erd_key_table.json`

```json
"keyTable": {"columns": ["테이블", "기본키", "그 밖의 속성"], "rows": [["부서", "부서번호", "부서명"]], "title": ""}
```

- `columns` 를 빼면 `["테이블명", "컬럼", "키 구분"]`

## 보기 그림 격자 (#1155)

보기 ①~④ 가 각각 그림인 문항. 위에 지문 그림(선택), 아래에 번호 원 + 작은 그림 4개를 2x2.
예시 `examples/choice_figures_barker.json`

```json
{"stemFigure": {"entities": [...], "relations": [...]},
 "choiceFigures": [{"notation": "barker", "entities": [...], "relations": [...]}, {...}, {...}, {...}],
 "choiceColumns": 2}
```

- 각 칸은 기존 명세(IE·바커·상자·화살표·첸) 그대로. 칸 안 그림은 좁은 격자 간격으로 그림
- `choiceColumns`: 기본 2(① ② / ③ ④). 보기 그림이 넓어 폰에서 글자가 작으면 `1`(세로 한 줄)
- 하네스 lint `figure.identifying-line` 은 보기 칸을 검사하지 않음 (틀린 보기가 일부러 어긋나므로)

## 결과 표 보기 (#1155)

보기 ①~④ 가 각각 결과 표인 문항. `"choiceTables"` > 번호 붙은 작은 표 4개를 2x2 (`stemFigure`·`choiceColumns` 같이 씀).
예시 `examples/choice_tables_result.json`

```json
{"choiceTables": [{"columns": ["DEPTNO", "SAL_SUM"], "rows": [[10, 8750], [null, 29025]], "title": ""}, ...]}
```

- **NULL 표시 규칙**: JSON `null` > 흐린 `NULL` 글자, `""` > 빈칸. 빈칸 하나로는 NULL 과 빈 문자열·공백을 구분할 수 없고, 앱 결과 표(`sqlNullCellLabel`)도 흐린 NULL 이라 같은 규칙으로 통일
- 셀 수가 `columns` 보다 적으면 나머지는 빈칸, 많으면 오류

## 피터 첸 표기 (#1155)

`"notation": "chen"`. 엔터티 사각형, 관계 마름모, 속성 타원(`pk` 는 밑줄), 연결선 엔터티 쪽 끝 위에 차수 글자.
예시 `examples/chen_notation.json`

```json
{"notation": "chen",
 "entities": [{"id": "STUDENT", "title": "학생", "col": 0, "row": 0, "pk": ["학번"], "attrs": ["이름"], "attrSide": "top"}],
 "relationships": [{"id": "TAKES", "title": "수강", "col": 1, "row": 0, "links": [{"to": "STUDENT", "cardinality": "M"}]}]}
```

- 속성 타원 줄은 엔터티 위, `"attrSide": "bottom"` 이면 아래. 같은 행의 사각형·마름모는 가운데 줄이 맞음
- 첸 명세는 `col`/`row` 필수 (자동 배치 없음)

## 상호배타 관계 (#1155)

IE 명세에 `"exclusiveArcs": [{"entity": "ACCOUNT", "targets": ["PERSON", "COMPANY"]}]` > `entity` 에서 나가는 관계선들을
엔터티 가까이(IE 기호 바깥)에서 호로 묶음. 같은 변에서 나가는 선은 변을 따라 벌려 따로 보이게 함.
`entity` <-> 각 `target` 관계가 `relations` 에 있어야 함(없으면 오류). 예시 `examples/exclusive_arc.json`

## 테스트

```
python3 -m pytest -q tests        # tools/question-figure 에서 (pytest 필요, 하네스 .venv 써도 됨)
python3 tests/record_snapshots.py # 모양을 일부러 바꿨을 때만: 스냅샷 SVG 다시 쓰기
```

- `tests/legacy/`: 기존 명세 모양 고정 (IE·바커·상자·화살표·서브타입·머메이드). 출력이 한 바이트라도 바뀌면 실패
- `examples/`: 새 유형 예시 명세와 출력 SVG. 스냅샷 비교 + 서버 `QuestionFigureSvgRule` 과 같은 조건(40KB, 금지 요소) 검사

## 파일

| 파일 | 하는 일 |
|---|---|
| `figure_svg.py` | 명세 > SVG (IE 엔터티·관계선, 그림 종류 분기, 키 표 붙이기) |
| `erd_layout.py` | 격자 배치, 선 양 끝, 자동 배치 |
| `svg_primitives.py` | 글자·선·문서 머리·이동 묶음 |
| `ie_symbols.py` | IE 관계 끝 기호 |
| `figure_style.py` | 글꼴·색·간격 상수 (단일 원본) |
| `barker_notation.py` | 바커 표기 |
| `generic_shapes.py` | 화살표, 서브타입 묶음 |
| `mermaid_to_spec.py` | 머메이드 erDiagram > 명세 |
| `table_shapes.py` | 작은 표 (결과 표 보기, 키 정의 표) |
| `choice_grid.py` | 보기 ①~④ 격자 |
| `chen_notation.py` | 피터 첸 표기 |
| `exclusive_arc.py` | 상호배타 호 |

## 시험지 모양 (SQL 전문가 가이드·복원 기출 그림 기준)

- IE 엔터티: 이름은 상자 바깥 왼쪽 위, 상자 안은 주식별자 칸 > 구분선 > 일반 속성 칸 (머리칸 채움 없음, 흑백)
- 부모 식별자를 물려받은 의존 엔터티(주식별자에 외래키)는 둥근 모서리, 독립 엔터티는 직각
- 외래키는 이름에 붙여 `부서번호(FK)` (명세는 `"부서번호 (FK)"` 그대로 써도 됨)
- 엔터티 이름은 한글만 (`"주문 ORDERS"` > `주문`). 보기가 영문 이름을 쓰는 문항만 명세에 `"showEnglishNames": true`
- 관계 라벨은 상자 없이 선 옆 굵은 글자 (세로선은 그림 오른쪽 절반이면 선 왼쪽)
- 바커: 둥근 상자 안 맨 위 굵은 이름, 속성 줄 앞 `□`
