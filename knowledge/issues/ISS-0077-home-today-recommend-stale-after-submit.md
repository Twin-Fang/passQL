---
type: issue
id: ISS-0077
created: 2026-04-11
topics: [home, practice]
symptoms: ["풀이없음 유지", "추천 목록 갱신 안 됨", staleTime, invalidateQueries, useTodayQuestion, useRecommendations, "React Query 캐시"]
root_cause: "useTodayQuestion·useRecommendations staleTime 5분 안에 제출해도 관련 쿼리 캐시를 무효화하지 않았다"
status: resolved
resolution: "[[ISS-0077-home-today-recommend-stale-after-submit-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/134"
---

# ISS-0077: 문제 풀이 후 홈의 오늘의 문제·추천 문제 상태가 즉시 갱신되지 않음

GitHub #134 (원본: 이슈 본문과 리포트 댓글).

## 증상
오늘의 문제를 풀고 홈에 돌아와도 "풀이없음"이 그대로이고, 추천 문제를 풀어도 같은 추천 목록이 남는다.

## 재현 조건
홈 → 오늘의 문제 또는 추천 문제 풀이·제출 → 홈 복귀 (React Query `staleTime` 5분 안).

## 조사 기록
- 2026-04-11: 리포트 — `DailyChallenge`에는 `todayQuestion` 무효화만 있고 `recommendations` 무효화가 없었으며, `QuestionDetail` 단독 모드에는 무효화가 전혀 없었다.

## 근본 원인
제출 성공 시점의 쿼리 캐시 무효화 누락.
