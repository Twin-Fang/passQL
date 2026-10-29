---
type: issue
id: ISS-0072
created: 2026-04-11
topics: [home]
symptoms: [ErrorFallback, "데이터를 불러올 수 없습니다", "GET /api/progress 500", useProgress, "retry 기본값 3", "홈 전체 에러 화면", "스켈레톤 30초"]
root_cause: "Home.tsx가 useProgress 하나의 isError로 홈 전체를 ErrorFallback으로 교체했고, useProgress에 retry 설정이 없어 기본 3회 재시도"
status: resolved
resolution: "[[ISS-0072-home-single-api-failure-full-fallback-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/123"
---

# ISS-0072: 홈 API 하나만 실패해도 홈 전체가 ErrorFallback으로 교체

GitHub #123 (원본: 이슈 본문과 리포트 댓글).

## 증상
홈 진입 시 7개 API를 병렬 호출하는데 `useProgress()`(`/progress`)가 500을 내면 홈 전체가 "데이터를 불러올 수 없습니다" 화면으로 바뀐다. `/home/greeting`, `/members/me`, `/questions/today`, `/exam-schedules/selected`는 성공했는데도 빈 에러 화면만 보인다. `useProgress`에 `retry` 설정이 없어 에러 확정까지 약 30초 동안 스켈레톤이 전체 화면을 덮는다.

## 재현 조건
`/progress`, `/progress/heatmap`, `/questions/recommendations`를 500 상태로 두고 홈(`/`) 진입.

## 조사 기록
- 2026-04-11: `client/src/pages/Home.tsx` L37~39 `if (isError) return <ErrorFallback />`, `client/src/hooks/useProgress.ts` retry 미설정.

## 근본 원인
페이지 전체를 하나의 쿼리 에러 상태에 묶은 구조.
