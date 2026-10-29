---
type: completion-report
id: ISS-0072
created: 2026-04-11
topics: [home]
status: resolved
resolves: "[[ISS-0072-home-single-api-failure-full-fallback]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/123"
---

# ISS-0072 완료 리포트: 섹션별 독립 에러·로딩 처리 (Graceful Degradation)

GitHub #123 리포트 댓글 기준 (2026-04-11).

## 해결 방법
- `client/src/pages/Home.tsx`: 전체 화면 `ErrorFallback`·전체 스켈레톤 분기 제거. 각 훅의 `isLoading`/`isError`/`refetch`를 따로 받아 섹션별로 처리.
- 섹션 정책: 학습 현황(`useProgress`)·히트맵(`useHeatmap`)은 인라인 에러 + 재시도 버튼, 추천 문제(`useRecommendations`)는 에러 시 섹션 숨김, 인사말·오늘의 문제·시험 일정은 fallback 값으로 렌더링 유지. progress 에러 시 `solvedCount`·`correctRate`·`streakDays`는 `?? 0`.
- `client/src/hooks/useProgress.ts`: `retry: false`.

## 근본 원인 (확정)
`useProgress` 하나의 `isError`가 홈 전체를 덮었고, retry 기본값 3회로 에러 확정이 늦었다.

## 재발 방지
리포트 주의사항: `useHome.ts`의 다른 훅은 이미 `retry: false`였고 `useProgress`만 빠져 있었다 — 신규 훅도 `retry: false`로 통일할 것. 홈 전체 수준 `ErrorFallback`은 완전히 제거됐으므로 인증 실패 등 홈 자체를 못 그리는 상황은 별도 검토가 필요하다.

## 교훈
(원본에 없음, 볼트 정리) 여러 API를 모으는 화면에서는 한 API의 에러 상태가 페이지 전체 분기에 쓰이고 있는지 먼저 본다.
