---
type: issue
id: ISS-0141
created: 2026-04-13
topics: [practice, admin]
symptoms: [daily_challenge, "폴백 오늘의 문제", "관리자 달력 빈 날짜", "toEpochDay() % activeCount", "이력 추적 불가", DailyChallengeScheduler]
root_cause: "관리자 미배정 날은 폴백(`toEpochDay() % activeCount`)으로 노출만 되고 `daily_challenge`에 기록되지 않음"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/260"
---

# ISS-0141: 폴백 오늘의 문제가 DB에 저장되지 않아 달력이 비고 이력이 흔들림

GitHub #260 (원본: 이슈 본문만, 댓글 없음).

## 증상
- 관리자가 수동 배정하지 않은 날은 `daily_challenge` 행이 없어 관리자 달력에서 비어 보인다.
- 폴백 로직(`toEpochDay() % activeCount`)으로 문제는 노출되지만 기록되지 않아 이력 추적이 안 된다.
- 활성 문제 수가 바뀌면 과거 날짜의 폴백 결과가 달라진다.

## 재현 조건
관리자가 배정하지 않은 날짜를 관리자 달력에서 확인.

## 조사 기록
- 2026-04-13: 제안 — 매일 자정 `@Scheduled(cron = "0 0 0 * * *")`로 당일 행이 없으면 폴백 결과 저장, 스케줄러 실패 시 `resolveTodayQuestion()` 최초 조회 때 저장하는 백업. 작업: `PQL-Web/scheduler/DailyChallengeScheduler.java`, `AdminDailyChallengeService.confirmFallback(LocalDate)`, `QuestionService.resolveTodayQuestion()` 수정.

## 근본 원인
폴백 결과를 저장하는 경로가 없었다. 구현·확인 결과는 원본에 적혀 있지 않다.
