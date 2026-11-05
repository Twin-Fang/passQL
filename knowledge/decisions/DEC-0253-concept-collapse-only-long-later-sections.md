---
type: decision
id: DEC-0253
created: 2026-11-05
reviewed: null
topics: [concept-learning]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0453-app-concept-reading-readability-redesign]]", "[[DEC-0252-concept-reading-single-scroll]]"]
---

# DEC-0253: 개념 문단은 앞 3문단 이후 1200자 이상 일반 문단만 접는다

## 문제 정의 (Context)
한 스크롤 개념 화면([[DEC-0252-concept-reading-single-scroll]])이 길어져 긴 문단 접기가 필요했다. 처음 기준(앞 2문단 이후 400자 이상)으로는 일반 문단 182개 중 156개가 접혀 예시가 대부분 숨겨졌다 (GitHub #835, 개념 원본 63개 실측).

## 결정 (Decision)
- 앞 3문단, 자주 헷갈리는 점, 시험 포인트는 항상 펼친다.
- 그 뒤 일반 문단 중 1200자 이상만 미리보기 3줄 + "이어서 읽기"로 접는다 (17개 개념의 18문단).
- 다시 읽기로 들어온 문단은 펼친 뒤 그 위치로 스크롤한다.

## 검토한 대안 (Alternatives)
- 400자 기준: 156문단이 접혀 예시가 숨겨져 버렸다.
- 접지 않음: 2000자가 넘는 문단(관계대수 등)이 화면을 오래 차지한다.

## 결과 (Consequences)
**긍정**
- 예시 문단 대부분이 펼쳐진 채로 보이고, 아주 긴 문단만 접힌다.

**부정**
- 개념 원본이 길어지면 접히는 문단이 늘어난다 (기준 변경 전 원본으로 개수를 다시 센다).

## 영향 범위 (Scope)
`concept_read_view.dart`의 `_alwaysOpenSectionCount`, `_collapsibleBodyMinCharacters`.

## 출처 (References)
- GitHub #835 PR #844 (2026-11-05)
- 이슈: [[ISS-0453-app-concept-reading-readability-redesign]]
