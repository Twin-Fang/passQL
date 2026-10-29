---
type: completion-report
id: ISS-0137
created: 2026-04-13
topics: [home, ai]
status: resolved
resolves: "[[ISS-0137-home-recommendation-missing-member-uuid]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/253"
---

# ISS-0137 완료 리포트: 추천 API에 `memberUuid` 전달

GitHub #253 `## 개요` 리포트 댓글(2026-04-13) 기준.

## 해결 방법
- `client/src/api/questions.ts`: `fetchRecommendations()`에 `memberUuid` 파라미터 추가(없으면 백엔드 RANDOM fallback).
- `client/src/hooks/useHome.ts`: `useMemberStore` uuid를 queryKey에 포함(`["recommendations", uuid]`), `fetchRecommendations(3, undefined, uuid ?? undefined)`. 로그인 상태 전환 시 자동 재조회.

## 근본 원인 (확정)
프론트가 UUID를 보내지 않아 항상 RANDOM fallback.

## 재발 방지
리포트 주의사항: 비로그인(`uuid = null`)은 RANDOM fallback이 의도된 동작. staleTime 5분 유지.

## 교훈
(원본에 없음, 볼트 정리) 개인화가 안 되는데 서버 실패 로그도 없으면, 클라이언트가 사용자 식별 파라미터를 보내는지부터 본다.
