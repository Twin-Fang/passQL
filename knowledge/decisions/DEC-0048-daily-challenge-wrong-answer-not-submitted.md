---
type: decision
id: DEC-0048
created: 2026-04-11
reviewed: null
topics: [practice, home]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0060-daily-challenge-result-ux]]", "[[ISS-0060-daily-challenge-result-ux-report]]", "[[ISS-0064-recommended-flow-ui-unify]]", "[[DEC-0015-zero-business-logic-in-frontend]]"]
---

# DEC-0048: 데일리 챌린지는 정답일 때만 서버에 제출하고, 오답은 로컬 피드백 후 다시 풀게 한다

## 문제 정의 (Context)
오늘의 문제(데일리 챌린지)는 1문제 플로우라 완료 처리와 결과 후 이동을 정해야 했다 (GitHub #106, #112).

## 결정 (Decision)
- 정답이면 `submitAnswer`를 호출해 완료 처리(`alreadySolvedToday=true`)하고 "홈으로 가기".
- 오답이면 `submitAnswer`를 호출하지 않는다. 로컬 `SubmitResult`로 피드백만 보여 주고 "다시 풀기"로 같은 문제를 재시도한다.
- 원본 이유: "오답은 완료로 처리하지 않음" — 작업 댓글은 서버 제출 기록이 남지 않는 것을 "의도된 동작"이라고 적었다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 오답 후에도 `alreadySolvedToday=false`가 유지돼 다시 풀 수 있다.

**부정**
- 데일리 챌린지 오답 시도는 서버 제출 기록에 남지 않는다.
- 제출 없이 정답·오답을 어떻게 판정하는지는 원본에 적혀 있지 않다.

## 영향 범위 (Scope)
`client/src/pages/DailyChallenge.tsx`, `AnswerFeedback.tsx`, `PracticeFeedbackBar`(GitHub #112).

## 출처 (References)
- GitHub #106 프론트 작업 댓글 「DailyChallenge 오답 처리 로직」·「참고사항」(2026-04-11)
- GitHub #112 이슈 본문 「DailyChallenge 개선」
