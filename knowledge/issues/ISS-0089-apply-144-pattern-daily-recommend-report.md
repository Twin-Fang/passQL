---
type: completion-report
id: ISS-0089
created: 2026-04-12
topics: [practice, home]
status: resolved
resolves: "[[ISS-0089-apply-144-pattern-daily-recommend]]"
related: ["[[DEC-0062-separate-recommendation-practice-page]]"]
source: "https://github.com/Twin-Fang/passQL/issues/159"
---

# ISS-0089 완료 리포트: DailyChallenge 패턴 통일, RecommendationPractice 페이지 신규

GitHub #159 작업 댓글 기준 (2026-04-12).

## 해결 방법
- `src/pages/DailyChallenge.tsx`: `PracticeFeedbackBar`(정답 "홈으로 가기", 오답 "다시 풀기" + "홈으로 가기"), `LoadingOverlay`("채점 중이에요"), `showExecution={!!feedback}`. `retryCount`로 QuestionDetail 강제 리마운트, `isProcessingRef`로 연타 방지(state는 async 클로저에서 stale).
- `src/pages/RecommendationPractice.tsx` 신규, 라우트 `recommendation/:questionUuid`. `location.state.returnPath`로 복귀 경로 판별, PracticeResult에서 왔으면 정답 시 `markCorrect(questionUuid)`.
- `src/pages/Home.tsx`: 추천 문제 링크 → `/recommendation/:questionUuid`.
- `practiceStore`에 `returnStep`·`setReturnStep`·`clearReturnStep` — React Router v7에서 `location.state` 전달이 불안정해 store로 우회.
- 피드백바 "다시 풀기" 후 300ms 사이 탭-스루 방어(`isProcessingRef` 쿨다운), `PracticeFeedbackBar` 내부 `hasActedRef`로 이중 클릭 방지.

## 근본 원인 (확정)
해당 없음 (기능 개선).

## 재발 방지
참고사항: `DailyChallenge`는 오답 시 `submitAnswer`를 호출하지 않아 당일 재풀기 가능. `RecommendationPractice`는 정답/오답 무관하게 `submitAnswer`를 항상 호출(연습 이력 기록 목적). `practiceStore.returnStep`은 PracticeResult 진입 시 소비·초기화.

## 교훈
리포트 서술: React state는 async 클로저에서 stale하므로 연타 방지 같은 동기 플래그는 ref로 관리했다.
