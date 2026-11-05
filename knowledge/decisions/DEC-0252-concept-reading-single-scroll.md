---
type: decision
id: DEC-0252
created: 2026-11-05
reviewed: null
topics: [concept-learning, design-system]
status: active
supersedes: DEC-0217
superseded_by: null
related: ["[[ISS-0453-app-concept-reading-readability-redesign]]", "[[DEC-0217-concept-study-single-segment]]", "[[DEC-0253-concept-collapse-only-long-later-sections]]"]
---

# DEC-0252: 개념 읽기는 깊이 전환 없이 한 스크롤 카드 구조로, 세그먼트는 `개념 | 확인 문제`

## 문제 정의 (Context)
`핵심 | 자세히 | 문제` 세그먼트([[DEC-0217-concept-study-single-segment]])로 읽기 깊이를 나누자 한 화면에서 전체 흐름이 보이지 않았고, 자세히 본문은 긴 글로 이어져 가독성이 떨어졌다 (GitHub #835).

## 결정 (Decision)
- 읽기는 한 스크롤: 한 줄 핵심 > 꼭 기억할 것(번호 카드) > 번호 문단 카드.
- 자주 헷갈리는 점은 함정 카드(주의색), 시험 포인트는 강조 카드로 분리한다.
- 세그먼트는 `개념 | 확인 문제` 두 칸. 하단은 확인 문제 풀기(보조) · 다음 개념(주).
- 왼쪽 띠 카드는 디자인 시스템 `PassqlCallout`(강조·주의)로 공통화한다.

## 검토한 대안 (Alternatives)
- 깊이 전환 유지 + 글 다듬기: 화면 구조 문제가 남아 버렸다.
- 논의 기록 없음 (그 밖의 대안).

## 결과 (Consequences)
**긍정**
- 스크롤만으로 핵심 > 설명 > 함정 > 시험 포인트 순서가 보인다.

**부정**
- 화면이 길어진다 (긴 문단 접기로 보완, [[DEC-0253-concept-collapse-only-long-later-sections]]).
- 서버 `lastDepth`는 쓰이지 않지만 API 계약 유지를 위해 남긴다.

## 영향 범위 (Scope)
`ConceptPage`, `ConceptReadView`, `ConceptReadingParser`, `ConceptCoreHeader`, `ConceptSectionCard`, `ConceptPitfallCard`, `PassqlCallout`.

## 출처 (References)
- GitHub #835 PR #844 (2026-11-05)
- 이슈: [[ISS-0453-app-concept-reading-readability-redesign]]
