---
type: completion-report
id: ISS-0155
created: 2026-04-25
topics: [progress-stats, home]
status: resolved
resolves: "[[ISS-0155-heatmap-stale-after-solving]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/290"
---

# ISS-0155 완료 리포트: `invalidateQueries` → `refetchQueries`

GitHub #290 구현 보고서 댓글(2026-04-25) 기준.

## 해결 방법
`DailyChallenge.tsx`, `PracticeSet.tsx`, `QuestionDetail.tsx`, `RecommendationPractice.tsx`에서 heatmap/recommendations/progress 쿼리를 `invalidateQueries` 대신 `refetchQueries`로 무효화와 강제 재요청을 동시에 수행하도록 통일.

## 근본 원인 (확정)
`invalidateQueries`는 stale 표시만 하고 실제 재요청은 다음 마운트 때 일어나, navigate 타이밍과 어긋나면 이전 캐시가 그대로 보였다.

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) 화면 복귀 후 데이터가 안 바뀌면 캐시 무효화 방식(`invalidateQueries` vs `refetchQueries`)과 `refetchOnWindowFocus` 설정을 본다. 날짜 경계 문제라면 GitHub #261(타임존)도 함께 본다.
