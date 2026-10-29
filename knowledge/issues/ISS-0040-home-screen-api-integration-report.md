---
type: completion-report
id: ISS-0040
created: 2026-04-10
topics: [home, progress-stats]
status: resolved
resolves: "[[ISS-0040-home-screen-api-integration]]"
related: ["[[DEC-0039-home-sections-independent-failure]]"]
source: "https://github.com/Twin-Fang/passQL/issues/67"
---

# ISS-0040 완료 리포트: `useHome.ts`를 API별 훅으로 분리하고 홈에서 병렬 호출

GitHub #67 프론트 작업 댓글(2026-04-10) 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
- `src/hooks/useHome.ts`(59줄 통합 훅) 삭제 → `useGreeting.ts`, `useTodayQuestion.ts`, `useRecommendations.ts`, `useSelectedSchedule.ts`, `useHeatmap.ts` 추가(`useProgress.ts` 유지). TanStack Query `useQuery`, `staleTime` 5분(일정 30분), `retry: false`.
- `src/pages/Home.tsx`: 훅을 병렬 호출. `isLoading`/`isError`는 progress 기준, 나머지는 데이터가 없으면 섹션 숨김 또는 placeholder.
- `src/api/api-contract.test.ts` 추가: `explainError`, `diffExplain`, `submitAnswer`, `fetchHeatmap` 필드명·파라미터와 타입 export 검증.
- `types/api.ts`: `HeatmapEntry`, `HeatmapResponse` 추가, SSE 관련 타입(`SubmitPayload`, `ChoiceGenerationPhase` 등) 제거.
- 검증: `npm run build`, `npx vitest run`.

## 근본 원인 (확정)
프론트 연동 미완료.

## 재발 방지
작업 댓글: `useHome.ts` 삭제로 기존 import 경로 참조 시 빌드 에러가 난다(마이그레이션 완료 확인). 명세(오늘의 문제 24시간, 일정 1시간)와 구현 `staleTime`(5분, 30분)이 다르다.

## 교훈
(원본에 없음, 볼트 정리) 프론트·백엔드 필드명 불일치는 `api-contract.test.ts` 같은 계약 테스트로 빌드 시점에 잡는다.
