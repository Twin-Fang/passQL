---
type: completion-report
id: ISS-0035
created: 2026-04-10
topics: [progress-stats, home]
status: resolved
resolves: "[[ISS-0035-replace-progress-with-readiness]]"
related: ["[[DEC-0033-readiness-replaces-progress-rate]]"]
source: "https://github.com/Twin-Fang/passQL/issues/52"
---

# ISS-0035 완료 리포트: 홈 progress 바를 `readiness.score` 게이지 + 24칸 카피 매트릭스로 교체 (FE)

GitHub #52 프론트 구현 보고 댓글(2026-04-10) 기준. 백엔드 쪽 완료 보고는 원본에 없다.

## 해결 방법
- 타입: `ToneKey` 8종(`NO_EXAM / ONBOARDING / POST_EXAM / TODAY / SPRINT / PUSH / STEADY / EARLY`), `ReadinessResponse`(score, accuracy, coverage, recency, lastStudiedAt, recentAttemptCount, coveredTopicCount, activeTopicCount, daysUntilExam, toneKey), `ProgressSummary` → `ProgressResponse`에 `readiness: ReadinessResponse | null`.
- `src/api/progress.ts`: 인증 오류 수정 — `X-User-UUID` 헤더 → `?memberUuid=` 쿼리(스펙 불일치). `fetchHeatmap(memberUuid, from?, to?)`.
- `src/constants/readinessCopy.ts`: `ScoreBand`(low / mid / high) × `ToneKey` 8종 = 24칸, `getReadinessCopy(toneKey, score)`.
- `Home.tsx`: readiness 있으면 점수(%) + 게이지 + 카피 + 3요소 드릴다운, null이면 기존 푼문제/정답률 그리드 폴백. score는 0.0~1.0 → `Math.round(score * 100)`. 인사말·오늘의 문제·시험 일정·히트맵·추천 섹션.
- 검증: `npm run build` 통과, readiness null 케이스와 존재 케이스(STEADY, score 0.52) 렌더링 확인.

## 근본 원인 (확정)
원본 이슈 본문의 문제점과 같다 (진도율 오독). 리포트가 추가로 확인한 것은 `fetchProgress`의 인증 방식 불일치(헤더 vs 쿼리 파라미터)다.

## 재발 방지
리포트: readiness null 체크로 미지원 응답에도 기존 UI 유지.

## 교훈
원본에 적혀 있지 않다.
