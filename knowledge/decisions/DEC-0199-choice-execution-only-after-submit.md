---
type: decision
id: DEC-0199
created: 2026-10-28
reviewed: null
topics: [practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0421-surface-direct-sql-execution]]", "[[ISS-0421-surface-direct-sql-execution-report]]"]
---

# DEC-0199: 앱 실행형 문제의 보기 실행은 제출 뒤에만 연다 (고르기와 실행 분리, 제출 전에는 안내 문구만)

## 문제 정의 (Context)
실행형 문제에서 실행이 보이지 않아 보기마다 ▶ 실행 버튼(구상안 A)을 넣었는데, 결과를 묻는 문제라 제출 전에 실행하면 정답이 보였다 (GitHub #727 2차 변경 댓글).

## 결정 (Decision)
- 보기 실행은 제출 뒤에만. 제출 전에는 실행 버튼을 숨기고 "제출하면 보기마다 실제 DB 에서 실행해 볼 수 있어요" 안내만 둔다. 제출 뒤 정답·오답 표시 아래 작은 ▶(카드 탭도 실행).
- 고르기(`selectChoice`)와 실행(`runChoice`)을 분리한다.
- 채점 후 내 답 vs 정답 실행 결과 비교 카드(구상안 B)와 정답 SQL을 고쳐 실행하는 실습 칸(구상안 C, 입력 보조 막대 G)을 둔다.
- 리포트: "제출 전 실행 금지는 의도된 제한 — 다시 열면 결과형 문제의 답이 노출된다."

## 검토한 대안 (Alternatives)
- 1차 구현은 제출 전에도 보기마다 ▶ 실행(구상안 A)이었고 실측 후 2차에서 제출 뒤로 옮김. 이유: 결과를 묻는 문제라 제출 전에 실행하면 정답이 보인다.
- ▶를 코드 옆에 두기: 코드 폭이 줄어 SQL이 한 줄 더 꺾여 채점 아이콘 칸 아래(`trailingAccessory`)로.
- 구상안 D(전용 실습 화면), E(Oracle 실행 기록), F(값만 바꾸기 칩)를 기본으로 하는 안: 이 이슈에서 고르지 않음. E는 범위 밖으로 남김. 그 외 탈락 이유는 원본에 없다.

## 결과 (Consequences)
**긍정**
- 답 노출 없이 실행 경험을 제출 뒤에 보여 준다.

**부정**
- 실행 경험은 실행형 문제(48개, 16%)에만 해당. 개념형 Oracle 문제는 범위 밖.

## 영향 범위 (Scope)
앱 문제 풀이 화면(`PassqlChoiceCard`, `ExecutionComparisonCard`, `SqlPracticeCard`, `SqlInputAssistBar`, `question_interaction_state.dart`, `question_choices.dart`).

## 출처 (References)
- GitHub #727 이슈 본문(구상안), 2차 변경 댓글(2026-10-28), 리포트 「주의 사항」
- [[ISS-0421-surface-direct-sql-execution]]
