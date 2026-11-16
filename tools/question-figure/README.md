# 문제 그림 생성기 (#1132)

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

## 파일

| 파일 | 하는 일 |
|---|---|
| `figure_svg.py` | 명세 > SVG (IE 엔터티·관계선, 배치) |
| `figure_style.py` | 글꼴·색·간격 상수 (단일 원본) |
| `barker_notation.py` | 바커 표기 |
| `generic_shapes.py` | 화살표, 서브타입 묶음 |
| `mermaid_to_spec.py` | 머메이드 erDiagram > 명세 |

## 시험지 모양 (SQL 전문가 가이드·복원 기출 그림 기준)

- IE 엔터티: 이름은 상자 바깥 왼쪽 위, 상자 안은 주식별자 칸 > 구분선 > 일반 속성 칸 (머리칸 채움 없음, 흑백)
- 부모 식별자를 물려받은 의존 엔터티(주식별자에 외래키)는 둥근 모서리, 독립 엔터티는 직각
- 외래키는 이름에 붙여 `부서번호(FK)` (명세는 `"부서번호 (FK)"` 그대로 써도 됨)
- 엔터티 이름은 한글만 (`"주문 ORDERS"` > `주문`). 보기가 영문 이름을 쓰는 문항만 명세에 `"showEnglishNames": true`
- 관계 라벨은 상자 없이 선 옆 굵은 글자 (세로선은 그림 오른쪽 절반이면 선 왼쪽)
- 바커: 둥근 상자 안 맨 위 굵은 이름, 속성 줄 앞 `□`
