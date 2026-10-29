---
type: decision
id: DEC-0062
created: 2026-04-12
reviewed: null
topics: [practice, home]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0089-apply-144-pattern-daily-recommend]]", "[[ISS-0089-apply-144-pattern-daily-recommend-report]]", "[[DEC-0090-app-no-separate-recommendation-screen]]"]
---

# DEC-0062: 홈 추천 문제는 QuestionDetail 직접 링크 대신 전용 `RecommendationPractice` 페이지로 풀고, 정답·오답 모두 제출 기록한다

## 문제 정의 (Context)
홈 추천 문제 진입 플로우가 GitHub #144의 피드백·채점 패턴과 달랐다 (GitHub #159).

## 결정 (Decision)
- 홈 추천 문제 링크를 `/recommendation/:questionUuid`로 바꾸고, 전용 페이지 `RecommendationPractice.tsx`가 PracticeFeedbackBar + LoadingOverlay + showExecution 패턴으로 처리한다. 작업 댓글 표현: "기존 QuestionDetail 직접 링크 방식 대신 독립 플로우로 분리".
- `RecommendationPractice`는 정답/오답 무관하게 `submitAnswer`를 항상 호출한다(연습 이력 기록 목적). `DailyChallenge`는 오답 시 호출하지 않는다(당일 재풀기 가능).

## 검토한 대안 (Alternatives)
- QuestionDetail 직접 링크 유지: 위 표현대로 독립 플로우로 바꿨다. 바꾼 이유는 "PracticeSet과 동일한 UX를 제공하여 화면 간 일관성 확보" 외에 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 추천 문제도 연습 모드와 같은 피드백 흐름, PracticeResult에서 진입 시 복귀 경로 처리.

**부정**
- 논의 기록 없음. (참고: GitHub #146은 이 페이지에도 같은 `useBlocker` 패턴 적용 여부 검토를 권했다.)

## 영향 범위 (Scope)
`src/App.tsx` 라우트, `src/pages/RecommendationPractice.tsx`, `src/pages/Home.tsx`, `practiceStore`.

## 출처 (References)
- GitHub #159 작업 댓글 (2026-04-12)
- [[ISS-0089-apply-144-pattern-daily-recommend]]
