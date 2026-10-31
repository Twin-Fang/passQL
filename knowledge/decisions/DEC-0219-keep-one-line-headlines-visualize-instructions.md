---
type: decision
id: DEC-0219
created: 2026-10-30
reviewed: null
topics: [concept-learning, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0432-app-concept-tab-redesign]]", "[[ISS-0432-app-concept-tab-redesign-report]]", "[[DEC-0218-concept-result-ring-climax]]"]
---

# DEC-0219: 글자를 덜 때 감정·행동 한 줄 제목은 남기고 사용 안내 문장만 시각 요소로 바꾼다

## 문제 정의 (Context)
개념 결과 화면 시안에서 "풀이를 다시 볼 수 있다", "개념을 잡았다" 같은 글자가 많다는 지적이 나왔고 (GitHub #764), 한 번은 한 줄 제목까지 지운 시안이 나왔다.

## 결정 (Decision)
- "한 문제만 다시 보면 돼요", "이 개념은 확실히 잡았어요" 같은 한 줄 제목은 남긴다.
- 사용 방법을 설명하던 문장은 시각 요소로 바꾼다 (틀린 칩의 `›`, 5/5 체크·폭죽).

## 검토한 대안 (Alternatives)
- 한 줄 제목까지 모두 지우기: 사용자가 "이 개념은 확실히 잡았어요, 이런 거 놓지 않는 게 무조건 좋다는 건 아님"이라고 해 제목은 남겼다.

## 결과 (Consequences)
**긍정**
- 결과의 감정과 다음 행동은 글로, 조작 방법은 모양으로 전달한다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`app/lib/presentation/widgets/concept/concept_result_view.dart`의 헤드라인과 문제 칩. 앞으로의 화면 글자 덜기 판단 기준.

## 출처 (References)
- GitHub #764 시안 검토와 리포트 댓글 6512843324
- [[ISS-0432-app-concept-tab-redesign]]
