---
type: decision
id: DEC-0337
created: 2026-11-16
reviewed: null
topics: [question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0540-past-exam-figure-erd-generator]]", "[[ISS-0540-past-exam-figure-erd-generator-report]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]", "[[DEC-0338-app-figure-white-paper-tap-to-zoom]]", "[[DEC-0339-figure-style-close-to-exam-sheet]]"]
---

# DEC-0337: 문제 그림은 AI 이미지 생성이 아니라 코드 생성기(`tools/question-figure`, 머메이드 erDiagram 또는 명세 JSON > SVG)로 만들고, 지문이 그림을 가리키거나 기호를 읽어야 풀리는 문항에만 붙인다

GitHub #1132 (이슈 본문, 보고서 댓글 2개, 작업 세션 사용자 발언).

## 문제 정의 (Context)
기출 복원 그림 문항이 지문에서 "아래 ERD"를 가리키지만 그림이 없었다([[ISS-0540-past-exam-figure-erd-generator]]). ERD 문항은 IE 기호(세로선, 원, 까마귀발)나 ㄱ·ㄴ·ㄷ 표시 하나만 틀려도 문제가 오답이 되므로 그림을 만드는 방법을 정해야 했다.

## 결정 (Decision)
- **만드는 방법:** 문항 YAML 의 `figureSpec`(명세, 우선) 또는 `diagramMermaid`(머메이드 erDiagram)를 생성기 `tools/question-figure` 에 넣어 SVG(`figureSvg`)를 만든다. IE, 바커, 서브타입, 화살표를 그린다. 머메이드는 **입력 문법**으로만 쓴다.
- **검사:** 하네스 lint `figure.identifying-line`(외래키 위치로 식별 실선·비식별 점선 검사), 서버 `QuestionFigureSvgRule`(스크립트·외부 참조 차단, 40KB).
- **붙이는 범위:** 지문이 그림을 가리키거나 그림 속 기호를 읽어야 풀리는 문항만. 지문만으로 풀리는 문항은 그림 없이 둔다(1차 보고서: 47-2, 60-4, 60-5 — 47-2 는 후속에서 원본에 그림이 있던 문항이라 추가).
- 사용자 발언(작업 세션): "코드적으로 저런걸 만드는게 문제만들기도 좋고 토큰 아끼기 좋다".

## 검토한 대안 (Alternatives)
- **AI 이미지 생성:** 기호·글자 오류 위험으로 쓰지 않음(이슈 본문, 보고서 "왜 이 방식인가").
- **외부 제작 그림 원본(SVG) 사용:** [[DEC-0328-past-exam-rewrite-operation-rules]]에서 이미 가져오지 않기로 함 — 이번 생성기는 우리 명세로 새로 그린다.
- 그 밖의 대안: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 기호를 정확히 그린다. 그림 하나 2~6KB SVG 라 확대해도 깨지지 않고, 만드는 비용이 명세 몇 줄이다(보고서).
- lint 가 머메이드 초안의 실선·점선 실수를 22개 중 12개 잡았다.

**부정**
- 자기 자신을 가리키는 순환 관계는 그리지 못한다(필요하면 생성기 확장).
- SVG 글꼴이 앱 Pretendard family 이름에 묶여 있어 `app/pubspec.yaml` 글꼴 이름을 바꾸면 `figure_style.py` 도 함께 바꿔야 한다.

## 영향 범위 (Scope)
`tools/question-figure/`(`figure_svg.py`, `figure_style.py`, `barker_notation.py`, `generic_shapes.py`, `mermaid_to_spec.py`), 하네스 `question_figure.py`·lint, 서버 `Question.figureSvg`·`V1_139_0__question_figure_svg.sql`·`QuestionFigureSvgRule`·`QuestionFigureService`·관리자 `PUT /admin/questions/{uuid}/figure`·가져오기/내보내기 `figureSvg`.

## 출처 (References)
- 이슈 https://github.com/Twin-Fang/passQL/issues/1132
- 보고서 https://github.com/Twin-Fang/passQL/issues/1132#issuecomment-6908908562 , 후속 https://github.com/Twin-Fang/passQL/issues/1132#issuecomment-6909699087

## W4 검사
- [[DEC-0328-past-exam-rewrite-operation-rules]](active) — "외부 그림 원본은 가져오지 않고 그림 속 정보만 추출"은 같은 방향(우리가 새로 그림). 다만 DEC-0328 의 "그림 문항은 엔터티를 바꿔 다시 구성하고 **관계를 지문에 글로 적는다**"와, 이번 후속에서 그림이 생기며 정답을 미리 알려 주게 된 5문항(49-4, 57-10, 58-5, 59-10, 62-4)의 기호 풀이 문장을 지워 **그림을 읽고 풀게 한 것**이 다르다. 그림 필드가 생긴 문항에 한정한 조건부 공존으로 볼 수 있으나 원본에 사용자 판단 기록이 없어 **사용자 확인 필요** — DEC-0328 은 바꾸지 않았다. DEC-0328 「검토한 대안」의 "머메이드로 그려 앱에서 렌더링(후속)"은 이 결정과 [[DEC-0338-app-figure-white-paper-tap-to-zoom]]으로 방향이 정해졌다(앱 렌더링이 아니라 생성기 입력).

## 사용자 확인 (2026-11-16)
DEC-0328 과의 차이를 사용자가 정했다: **그림이 있는 문항은 그림을 읽고 풀게 하고(지문에 기호 풀이 문장을 두지 않음), 그림이 없는 문항만 관계를 지문에 글로 적는다.** 조건부 공존으로 확정, DEC-0328 은 그림 없는 문항에 그대로 적용된다.
