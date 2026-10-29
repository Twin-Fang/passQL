---
type: issue
id: ISS-0158
created: 2026-04-25
topics: [home]
symptoms: ["무한 반복 호출", "/api/questions/recommendations", queryKey, excludeUuids, useRecommendations, "React Query", seenUuids]
root_cause: "`queryKey`에 `excludeUuids` 배열이 들어가 React Query 캐시 키가 렌더마다 달라져 무한 재요청"
status: resolved
resolution: "[[ISS-0158-home-recommendation-api-infinite-loop-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/298"
---

# ISS-0158: 홈 진입 시 추천 문제 API가 무한 반복 호출됨

GitHub #298 (원본: 이슈 본문과 구현 완료 보고 댓글).

## 증상
홈 진입 시 `/api/questions/recommendations`가 멈추지 않고 반복 호출되고, `excludeQuestionUuids` 배열이 점점 늘어나며 네트워크 탭에 수십 건이 쌓인다. 기대 동작: 진입 시 1회, 새로고침 버튼 클릭 시에만 새 요청.

## 재현 조건
로그인 → 홈(`/`) → 네트워크 탭(Fetch/XHR)에서 `/api/questions/recommendations` 필터 → 자동 반복 호출. 환경 macOS, Chrome 146, PC.

## 조사 기록
- 2026-04-25: 관련 파일 `client/src/hooks/useHome.ts`(`useRecommendations`), `client/src/pages/Home.tsx`(`seenUuids`, `handleRefresh`).
- 2026-04-26: 3단계에 걸쳐 수정(커밋 `997cf7b` → `e92aa66` → `49ad7c6` → `b48daf2`). 첫 커밋은 queryKey `JSON.stringify` 직렬화, 근본 수정은 `setQueryData` 패턴 전환.

## 근본 원인
`queryKey`에 `excludeUuids` 배열이 포함되어 매 렌더마다 캐시 키가 바뀌었다.
