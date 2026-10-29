---
type: issue
id: ISS-0155
created: 2026-04-25
topics: [progress-stats, home]
symptoms: ["히트맵 즉시 갱신 안 됨", "학습현황 캘린더", invalidateQueries, refetchOnWindowFocus, "홈 복귀 캐시", streak, "5분 후 갱신"]
root_cause: "`invalidateQueries()`는 stale 표시만 하고, `refetchOnWindowFocus: false`와 네비게이션 타이밍 때문에 홈 복귀 시 재요청이 일어나지 않음"
status: resolved
resolution: "[[ISS-0155-heatmap-stale-after-solving-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/290"
---

# ISS-0155: 문제 풀이 후 홈 복귀 시 학습현황 캘린더가 즉시 갱신되지 않음

GitHub #290 (원본: 이슈 본문과 구현 보고서 댓글).

## 증상
오늘의 문제·추천 문제·문제 세트·문제 상세에서 풀고 홈으로 돌아오면 heatmap과 streak(progress)가 갱신되지 않는다. 새로고침하거나 5분이 지나야 반영된다.

## 재현 조건
홈 → 오늘의 문제(또는 추천) → 정답 제출 → 피드백 화면 "홈으로 가기" → 캘린더 오늘 셀 미갱신. macOS / Chrome.

## 조사 기록
- 2026-04-25: 관련 파일 `client/src/pages/DailyChallenge.tsx`, `PracticeSet.tsx`, `RecommendationPractice.tsx`, `QuestionDetail.tsx`. 타임존 원인의 비슷한 증상은 GitHub #261.

## 근본 원인
`invalidateQueries()`가 재요청을 다음 마운트로 미루는데 네비게이션 타이밍과 어긋났다.
