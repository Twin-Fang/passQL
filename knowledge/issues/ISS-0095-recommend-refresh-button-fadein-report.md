---
type: completion-report
id: ISS-0095
created: 2026-04-12
topics: [home]
status: resolved
resolves: "[[ISS-0095-recommend-refresh-button-fadein]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/174"
---

# ISS-0095 완료 리포트: 추천 새로고침 버튼, 1회전·카드 순차 페이드인

GitHub #174 리포트 댓글 기준 (2026-04-12).

## 해결 방법
- `client/src/pages/Home.tsx`: `useRecommendations`에서 `refetch`·`isFetching`, `spinning`·`refreshKey` state, `handleRefresh`. `spinning || isFetching` 이중 가드로 중복 클릭 방지, `onAnimationEnd`로 `spinning` 초기화, refetch 완료 후 `refreshKey` 증가로 카드 컨테이너 재마운트.
- `client/src/styles/components.css`: `animate-refresh-once`(360도, 0.4s), `animate-card-in` + nth-child 딜레이(0~240ms).
- `GET /questions/recommendations`는 `staleTime` 안에서도 강제 refetch.

## 근본 원인 (확정)
해당 없음 (기능 추가).

## 재발 방지
리포트 주의사항: `onAnimationEnd`가 `<button>`에 있고 애니메이션은 내부 `<RefreshCw>`에 걸려 있어 `spinning` 고착 가능 — `<RefreshCw>`로 이동 권장. `refetchRecommendations().then()`은 실패 시 콜백이 안 돌아 `spinning`이 영구 `true`일 수 있음 — `.finally()` 권장. `hover:bg-gray-100`은 토큰 미사용.

## 교훈
원본에 적혀 있지 않다.
