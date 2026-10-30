---
type: decision
id: DEC-0217
created: 2026-10-30
reviewed: null
topics: [concept-learning, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0432-app-concept-tab-redesign]]", "[[ISS-0432-app-concept-tab-redesign-report]]"]
---

# DEC-0217: 개념 화면은 기존 세그먼트 한 줄 `핵심 | 자세히 | 문제`로 읽기 깊이와 풀기를 고른다

## 문제 정의 (Context)
개념 화면에 읽기/풀기 전환과 핵심/자세히 깊이 전환이 두 줄로 나뉘어 있었다 (GitHub #764).

## 결정 (Decision)
- 두 줄을 공통 컴포넌트 `PassqlSegmentedControl` 한 줄 세 칸 `핵심 | 자세히 | 문제`로 합친다. 한 칸이 읽기 깊이와 모드를 함께 정한다.
- 문제 칸에는 숫자를 붙이지 않고 진행 수는 문제 화면의 점 줄에서만 보여 준다.
- 하단 버튼 순서는 지금 앱 그대로 왼쪽 문제 풀기(보조), 오른쪽 다음 개념(주).

## 검토한 대안 (Alternatives)
- 밑줄 탭 등 별도 탭 모양: 시안 검토 중 사용자가 "이렇게 할 바에는 세그먼트 사용하는게 낫다. 재사용하고"라며 기존 세그먼트 재사용을 골랐다.

## 결과 (Consequences)
**긍정**
- 전환 줄이 하나로 줄고 문제 탭·알림함과 같은 세그먼트 모양을 쓴다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`app/lib/presentation/pages/concepts/concept_page.dart`(`_ConceptStudyTab`), `widgets/concept/concept_read_view.dart`(깊이 세그먼트 제거), `PassqlSize.depthSwitchMaxWidth` 삭제.

## 출처 (References)
- GitHub #764 이슈 본문과 리포트 댓글 6512843324
- [[ISS-0432-app-concept-tab-redesign]]
