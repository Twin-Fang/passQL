---
type: issue
id: ISS-0217
created: 2026-10-07
topics: [practice]
symptoms: ["오늘의 세트 재진입", "결과와 순위 보기", "문제별 결과 없음", HomeService.getToday, DailySetTodayResponse]
root_cause: "세트 기록에 정답 수만 있고, 재진입 응답에 문제별 정오(results)가 없었다"
status: resolved
resolution: "[[ISS-0217-daily-set-revisit-per-question-results-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/372"
---

# ISS-0217: 완료한 오늘의 세트 재진입 시 문제별 결과가 안 보임

GitHub #372 (원본: 이슈 본문과 완료 댓글). GitHub #370 후보 2.

## 증상
오늘의 세트를 완료한 뒤 홈의 "결과와 순위 보기"로 다시 들어가면 점수·순위만 보이고, 완료 직후 화면에 있던 "문제별 결과"(정답/오답 목록)가 없다.

## 재현 조건
오늘의 세트 완료 → 홈 → "결과와 순위 보기" 재진입.

## 조사 기록
- 2026-10-07: 작업 범위 — 서버 응답에 있는지 확인 후 앱/서버 중 필요한 쪽 수정.

## 근본 원인
세트 기록에는 정답 수만 있고 재진입 응답에 문제별 정오가 없었다 (완료 댓글 기준).
