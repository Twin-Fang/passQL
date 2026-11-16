---
type: decision
id: DEC-0338
created: 2026-11-16
reviewed: null
topics: [practice, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0540-past-exam-figure-erd-generator]]", "[[ISS-0540-past-exam-figure-erd-generator-report]]", "[[DEC-0337-question-figure-code-generator-not-ai-image]]", "[[DEC-0332-exam-answer-share-image-always-light]]", "[[DEC-0116-app-apple-hig-design-system]]"]
---

# DEC-0338: 앱은 문제 그림을 지문 카드 아래 흰 종이(검정 선)로 보여 주고 눌러서 크게 보기를 둔다(시안 C) — 머메이드를 앱에서 직접 그리지 않는다

GitHub #1132 (이슈 본문, 보고서 댓글).

## 문제 정의 (Context)
서버가 내려주는 그림(`figureSvg`)을 앱 어디에 어떻게 보여 줄지, 그리고 머메이드 원문을 앱에서 그릴지 정해야 했다([[ISS-0540-past-exam-figure-erd-generator]]).

## 결정 (Decision)
- **표시:** 지문 카드(`QuestionStem`) 아래 흰 종이에 검정 선(시험지와 같음), 라이트·다크 공통. "눌러서 크게 보기" > 전체 화면 핀치 줌. 시안 C 채택.
- **부품 한 곳:** `QuestionFigure` 를 `QuestionStem` 한 곳에만 넣어 풀이, 모의고사, 잠금화면이 같은 부품을 쓴다. 색·크기는 토큰 `figurePaper`, `figureInk`, `questionFigureMaxWidth`.
- **앱은 SVG 만 그린다:** 머메이드는 생성기 입력 문법일 뿐 앱에 보내지 않는다([[DEC-0337-question-figure-code-generator-not-ai-image]]).
- **구버전 앱:** 그림 필드를 무시하고 지금처럼 글만 보인다.

## 검토한 대안 (Alternatives)
- **머메이드를 앱에서 렌더링:** Flutter 에 머메이드 렌더러가 없어 웹뷰가 필요하다(잠금화면·오프라인에 무거움). 머메이드 ERD 모양은 시험지(구분선 위 주식별자, 한글 이름, 바커 표기)와 다르다(보고서).
- **다른 시안(A, B):** 시안 C 를 골랐다는 기록만 있고 나머지 시안의 내용·탈락 이유는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 시험지와 같은 흑백 그림을 다크 모드에서도 그대로 읽는다. 작은 화면은 크게 보기로 보완.

**부정**
- 옆으로 넓은 그림(5번, 17번, 기출 50-3)은 폰에서 글자가 작다(크게 보기로 보완). 1차에서 10개는 2열 배치로 바꿈.
- 실기기 확인은 테스트 렌더로만 했고 다음 앱 빌드에서 한다(보고서).

## 영향 범위 (Scope)
앱 `QuestionFigure`, `QuestionStem`, 디자인 토큰(`figurePaper`, `figureInk`, `questionFigureMaxWidth`), 문제 상세·모의고사 시험지·결과 응답의 `figureSvg`.

## 출처 (References)
- 이슈 https://github.com/Twin-Fang/passQL/issues/1132
- 보고서 https://github.com/Twin-Fang/passQL/issues/1132#issuecomment-6908908562

## W4 검사
- [[DEC-0332-exam-answer-share-image-always-light]](공유 이미지는 다크여도 흰 바탕): 대상이 달라 충돌 없음 — 같은 방향(종이·이미지는 항상 밝게).
- [[DEC-0116-app-apple-hig-design-system]]: 토큰과 공통 부품으로 구현해 충돌 없음.
- [[DEC-0328-past-exam-rewrite-operation-rules]] 「검토한 대안」의 "머메이드로 그려 앱에서 렌더링(후속)"은 이 결정으로 앱 렌더링을 하지 않는 쪽으로 정해졌다. 결정 본문이 아니라 대안 기록이라 대체 관계는 두지 않는다.
