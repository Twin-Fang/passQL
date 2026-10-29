---
type: issue
id: ISS-0177
created: 2026-10-02
topics: [practice, progress-stats]
symptoms: ["앱 데일리 세트 없음", "오늘의 문제 카드 항상 비어 있음", "/questions/today 없음", "/daily-set/today", "/daily-set/complete", "/daily-set/leaderboard", "리더보드 점수 조작"]
root_cause: "웹의 오늘의 세트·결과·리더보드가 앱에 없고, 앱 홈 카드는 서버에서 제거된 `/questions/today`를 호출"
status: resolved
resolution: "[[ISS-0177-app-daily-set-result-leaderboard-report]]"
related: ["[[DEC-0089-shared-question-flow-for-solving]]", "[[DEC-0085-daily-set-ten-questions-daily]]"]
source: "https://github.com/Twin-Fang/passQL/issues/332"
---

# ISS-0177: 앱 데일리 세트, 결과, 리더보드

GitHub #332 (원본: 이슈 본문과 댓글 3개). 관련 GitHub #304, 선행 GitHub #327, #328.

## 증상
(현재 문제점) 웹에는 오늘의 세트 풀이·결과·리더보드가 있으나 앱에는 없다. 또한 앱 홈의 "오늘의 문제" 카드는 존재하지 않는 엔드포인트를 호출해 항상 비어 있다.

## 재현 조건
앱 홈 진입 → "오늘의 문제" 카드 빈 상태.

## 조사 기록
- 2026-10-02(#328 작업 중 발견): 서버에는 `GET /api/questions/today`가 없고 `GET /api/daily-set/today`(응답 `questions`, `alreadyCompleted`, `correctCount`)만 있다. 웹 홈은 이미 데일리 세트(`useDailySet`)를 쓰고 `fetchTodayQuestion`은 미사용.
- 2026-10-02 구현 중 확인: 서버 `complete`가 앱이 보낸 정답 수를 그대로 받아, 서버 대조가 없으면 리더보드 점수 조작 가능(GitHub #339로).

## 근본 원인
앱이 서버 API 변경(오늘의 문제 → 데일리 세트)을 따라가지 못했다.
