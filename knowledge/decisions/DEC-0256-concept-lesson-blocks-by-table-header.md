---
type: decision
id: DEC-0256
created: 2026-11-05
reviewed: null
topics: [concept-learning, design-system]
status: active
supersedes: DEC-0253
superseded_by: null
related: ["[[ISS-0456-concept-lesson-textbook-blocks]]", "[[DEC-0252-concept-reading-single-scroll]]", "[[DEC-0253-concept-collapse-only-long-later-sections]]"]
---

# DEC-0256: 개념 글은 내용 유형별 레슨 블록으로 쓰고, 블록은 표준 마크다운 표 머리글로 구분한다

## 문제 정의 (Context)
한 스크롤 카드 구조([[DEC-0252-concept-reading-single-scroll]])에서도 글이 줄글이라 읽히지 않았다 (GitHub #848). 사용자는 방식이 내용보다 중요하고, 유형마다 외우는 방식이 다르다고 했다.

## 결정 (Decision)
- 내용 유형 > 블록: 정의·용어 = 용어 카드, 순서 = 단계(+두문자 외우는 법), 분류·비슷한 쌍 = 비교 표, 규칙·함정 = 헷갈리는 말 + OX 바로 확인, SQL = 풀이 예시.
- 블록은 표 머리글(`용어 | 뜻`, `단계 | 내용`, `외우기 | 뜻`, `헷갈리는 말 | 실제로는`, `바로 확인 | 정답 | 이유`)로 구분한다. 옛 앱은 일반 표로 보이고 서버는 바꾸지 않는다.
- 문단 제목은 `제목 — 부제`. 글 문단은 2문장 이내.
- 외우는 법은 수험생들이 쓰는 암기법 중 사실 검증한 것만.
- 긴 문단 접기는 없앤다 ([[DEC-0253-concept-collapse-only-long-later-sections]] 대체, 글이 짧아짐).
- 스크롤로 들어올 때 블록이 차례로 등장한다 (동작 줄이기면 정지).

## 검토한 대안 (Alternatives)
- 카드 넘기기(안 B), 노트 레일(안 C): 이슈에 시안으로 올림. 사용자 확인 전까지 안 A(교과서 스크롤)를 기본으로 했다.
- 서버에 블록 타입 필드 추가: API·DB 변경과 옛 앱 호환 부담이 커서 버렸다.

## 결과 (Consequences)
**긍정**
- 개념을 훑어보며 외울 수 있고, 함정은 OX 로 바로 확인한다. 옛 앱도 깨지지 않는다.

**부정**
- 표 머리글 문자열이 계약이 되어, 바꾸면 일반 표로 보인다.

## 영향 범위 (Scope)
`ConceptLessonBlockParser`, 레슨 블록 위젯들, `ConceptSectionCard`, `ConceptReadView`, `PassqlScrollReveal`, content/concepts 63개, README 「레슨 블록」.

## 출처 (References)
- GitHub #848 PR #851 (2026-11-05)
- 이슈: [[ISS-0456-concept-lesson-textbook-blocks]]
