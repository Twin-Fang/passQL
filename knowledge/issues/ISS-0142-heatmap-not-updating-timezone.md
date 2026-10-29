---
type: issue
id: ISS-0142
created: 2026-04-13
topics: [progress-stats]
symptoms: ["히트맵 색 갱신 안 됨", "UTC KST 9시간", toISOString, "LocalDate.now()", "DATE(submitted_at)", useHeatmap, StreakCalculator, "스트릭"]
root_cause: "오늘 날짜 계산(클라이언트 `toISOString()`)과 서버 조회 범위(`LocalDate.now()`)·DB 집계(`DATE(submitted_at)`)가 모두 UTC 기준"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/261"
---

# ISS-0142: 문제 풀이 후 히트맵 색이 갱신되지 않는 타임존 버그

GitHub #261 (원본: 이슈 본문만, 댓글 없음).

## 증상
문제를 풀고 홈으로 돌아와도 히트맵 오늘 셀이 `background-color: rgb(245, 245, 245)`(level 0)로 남는다. 영향 범위: 히트맵 색, 연속 학습 일수(스트릭), 합격 준비도 recency.

## 재현 조건
`passql.vercel.app`에서(KST 오전 9시 이전이면 더 명확) 오늘의 문제 / AI 추천 / 연습 세트 중 하나를 풀고 홈 복귀. 서버는 시놀로지 NAS Docker(기본 UTC), DB `submitted_at TIMESTAMP(6)`(타임존 없음).

## 조사 기록
- 2026-04-13: 세 곳 + 1.
  - 클라이언트 `client/src/hooks/useHome.ts` `useHeatmap()`: `today`, `from`을 `toISOString()`으로 계산 → KST 9시 이전엔 전날.
  - 서버 `ProgressService.getHeatmap()`: `LocalDate.now()`, `atStartOfDay()` 타임존 미명시 → JVM 기본(UTC).
  - 서버 `SubmissionRepository.findHeatmapByMemberUuid()`: `DATE(submitted_at)` UTC 추출 → KST 0~9시 제출이 전날로 집계.
  - `StreakCalculator.calculate()`의 `LocalDate.now()`도 타임존 미명시.

## 근본 원인
날짜 경계를 UTC로 계산했다. 수정 방식과 결과는 원본에 적혀 있지 않다.
