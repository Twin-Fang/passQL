---
type: issue
id: ISS-0109
created: 2026-04-12
topics: [home, progress-stats]
symptoms: [heatmap, "학습 현황 캘린더", streak, invalidateQueries, staleTime, "풀이 없음", "제출 후 갱신 안 됨"]
root_cause: "답안 제출 성공 시 heatmap/progress 쿼리 무효화가 누락되어 staleTime 5분 동안 캐시가 그대로 표시됐다"
status: resolved
resolution: "[[ISS-0109-heatmap-not-refreshed-after-submit-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/194"
---

# ISS-0109: 문제 풀이 후 홈 학습 현황(heatmap)·streak이 즉시 갱신되지 않음

GitHub #194 (원본: 이슈 본문, 리포트 댓글, 2026-04-22 완료 보고 댓글).

## 증상
문제를 풀고 홈으로 돌아와도 학습 현황 캘린더와 연속 streak이 갱신되지 않는다. 다수 문제를 풀었는데도 "4월 13일 풀이 없음" 툴팁.

## 재현 조건
1. 홈에서 캘린더 확인(오늘 풀이 없음) 2. 오늘의 문제 또는 추천 문제 제출 3. 홈 복귀 → 5분 이내엔 미반영.

## 조사 기록
- 2026-04-12: 이슈 본문이 원인 지목 — `DailyChallenge`, `QuestionDetail`, `RecommendationPractice`의 제출 완료 시 `heatmap`/`progress` 무효화 누락, `staleTime: 5분`.

## 근본 원인
제출 성공 후 TanStack Query 캐시 무효화 누락.
