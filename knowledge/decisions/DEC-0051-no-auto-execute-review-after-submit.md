---
type: decision
id: DEC-0051
created: 2026-04-11
reviewed: null
topics: [practice]
status: active
supersedes: DEC-0016
superseded_by: null
related: ["[[ISS-0064-recommended-flow-ui-unify]]", "[[ISS-0064-recommended-flow-ui-unify-report]]", "[[DEC-0049-ai-only-redefined-sql-equivalence]]", "[[DEC-0016-auto-execute-on-choice-click]]"]
---

# DEC-0051: 선택지 클릭 시 SQL 자동 실행을 없애고, 제출 후 `ChoiceReview`에서 각 선택지를 실행해 비교한다

## 문제 정의 (Context)
홈 추천 문제 플로우를 PracticeSet·DailyChallenge와 통일하면서 문제 풀이 화면을 다시 정리했다 (GitHub #112).

## 결정 (Decision)
- `QuestionDetail`에서 선택지 클릭 시 자동 SQL 실행을 제거한다. 선택은 카드 전체 클릭.
- EXECUTABLE 문제는 제출 후 `ChoiceReview`(오답노트)에서 각 선택지 SQL을 직접 실행해 결과를 나란히 비교한다. `kind === "SQL"` 선택지만 실행 대상.

## 검토한 대안 (Alternatives)
- 선택지 클릭 즉시 자동 실행(볼트의 기존 결정 DEC-0016): 작업 댓글은 "선택지 클릭 시 자동 SQL 실행 제거 (제출 후 ChoiceReview에서 직접 실행)"라고만 적었고, 제거 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 제출 전에는 선택지 실행 결과를 볼 수 없다.

## 영향 범위 (Scope)
`client/src/pages/QuestionDetail.tsx`, `components/ChoiceCard.tsx`, `components/ChoiceReview.tsx`, `AnswerFeedback.tsx`, `PracticeSet.tsx`, `DailyChallenge.tsx`.

## 출처 (References)
- GitHub #112 프론트 작업 댓글 「구현 목표」·「QuestionDetail 개선」(2026-04-11)
