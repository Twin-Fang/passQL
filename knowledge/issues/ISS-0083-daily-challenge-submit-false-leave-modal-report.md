---
type: completion-report
id: ISS-0083
created: 2026-04-12
topics: [practice]
status: resolved
resolves: "[[ISS-0083-daily-challenge-submit-false-leave-modal]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/146"
---

# ISS-0083 완료 리포트: blocker 조건에 `!submitting` 추가

GitHub #146 작업 댓글 기준 (2026-04-12).

## 해결 방법
`src/pages/DailyChallenge.tsx`: `useBlocker(!isLoading && feedback === null && !submitting)`. `setSubmitting(true)` → API → `finally { setSubmitting(false) }`. 제출 중 화면 조작은 `LoadingOverlay`가 막고, `useBlocker`는 실제 이탈(홈 이동, 뒤로가기)만 막는 역할로 분리.
검증: 제출 시 모달 없음, 채점 중 홈 버튼은 오버레이가 차단, 오답 catch의 `navigate("/")`는 모달 없이 이동, 풀이 중 홈 버튼은 모달 정상.

## 근본 원인 (확정)
제출 중에도 blocker가 활성이었다.

## 재발 방지
참고사항: `RecommendationPractice.tsx`에도 같은 `useBlocker` 패턴 적용 여부 검토 권장. `useBlocker`는 훅 규칙상 조건부 `return` 앞에 둔다.

## 교훈
(원본에 없음, 볼트 정리) blocker 조건에는 "풀이 중"뿐 아니라 "제출 처리 중"·"이탈 확정 후" 상태도 들어가야 한다 — GitHub #142의 `exitConfirmed`, #144의 `submitting`과 같은 패턴.
