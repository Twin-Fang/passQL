---
type: decision
id: DEC-0039
created: 2026-04-10
reviewed: null
topics: [home]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0040-home-screen-api-integration]]", "[[ISS-0040-home-screen-api-integration-report]]"]
---

# DEC-0039: 홈 섹션은 API별로 독립 호출하고, `progress` 실패만 전체 에러 화면, 나머지는 조용히 숨긴다

## 문제 정의 (Context)
홈 화면에 인사말·오늘의 문제·D-day·추천·히트맵·합격 준비도를 붙이면서 API 실패 처리 방식을 정해야 했다 (GitHub #67).

## 결정 (Decision)
- 홈 진입 시 API를 병렬로 호출하고 각각 독립적으로 로딩·에러를 처리한다. 원칙: "각 섹션은 자기 API가 실패해도 다른 섹션에 영향을 주지 않아야 한다."
- `progress` 실패 → 전체 `ErrorFallback`(핵심 데이터). `greeting` 실패 → 정적 "안녕하세요, {닉네임}" fallback. `today`·`schedule`·`recommendations`·`heatmap` 실패 → 섹션 숨김. `readiness`는 `progress` 응답에 항상 포함(non-nullable).
- 구현은 통합 훅 `useHome.ts` 대신 API별 훅으로 나눴다.

## 검토한 대안 (Alternatives)
- 통합 훅 `useHome.ts`(기존): 작업 댓글은 "훅 단일 책임 원칙", "각 훅의 독립적 캐시 관리 및 에러 격리"를 목표로 분리했다고 적었다.
- 그 밖의 대안: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 한 섹션 API 장애가 홈 전체를 깨지 않는다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`client/src/pages/Home.tsx`, `src/hooks/useGreeting.ts`·`useTodayQuestion.ts`·`useSelectedSchedule.ts`·`useRecommendations.ts`·`useHeatmap.ts`·`useProgress.ts`.

## 출처 (References)
- GitHub #67 이슈 본문 「섹션별 독립 렌더링 원칙」·「에러 처리 원칙」, 프론트 작업 댓글(2026-04-10)
