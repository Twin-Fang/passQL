---
type: completion-report
id: ISS-0031
created: 2026-04-10
topics: [progress-stats, home]
status: resolved
resolves: "[[ISS-0031-daily-study-heatmap-api]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/42"
---

# ISS-0031 완료 리포트: `GET /api/progress/heatmap` 백엔드와 홈 `HeatmapCalendar`

GitHub #42 백엔드 `## 개요` 리포트 댓글과 프론트 작업 보고 댓글(둘 다 2026-04-10) 기준.

## 해결 방법
- 백엔드: `HeatmapEntry`(date, solvedCount, correctCount), `HeatmapResponse`. `SubmissionRepository.findHeatmapByMemberUuid()` — `DATE(submitted_at)` `GROUP BY`, `COUNT(*)`·`SUM(is_correct)`. `ProgressService.getHeatmap()` — 기본값(30일 전 ~ 오늘), 기간 역전 시 빈 배열, `to + 1일` 시작시각을 exclusive upper bound로. 회원 없음은 `MEMBER_NOT_FOUND`. 기존 인덱스 `idx_submission_member_submitted`(member_uuid, submitted_at) 활용, 추가 인덱스 없음. `@ApiLog(issueNumber = 42)`. Entity 변경 없음 → Flyway 불필요.
- 프론트: `fetchHeatmap(memberUuid, from?, to?)`, `HeatmapEntry`/`HeatmapResponse` readonly 타입, `useHeatmap`(`queryKey: ["heatmap", uuid, from, today]`), `HeatmapCalendar`(`getLast30Days`, `buildDayMap`, `getLevel`: 0→0, 1→1, 2–3→2, 4–5→3, 6+→4), 홈 "학습 현황" 섹션, 데이터 없으면 skeleton 유지. `HeatmapCalendar.test.ts`, `api-contract.test.ts`.

## 근본 원인 (확정)
해당 없음 (기능 요청).

## 재발 방지
리포트 주의사항: `ProgressServiceTest`의 `memberUuid`를 실제 DB에 있는 값으로 바꿔야 테스트가 돈다. `correctCount`는 현재 UI에서 미사용.

## 교훈
원본에 적혀 있지 않다.
