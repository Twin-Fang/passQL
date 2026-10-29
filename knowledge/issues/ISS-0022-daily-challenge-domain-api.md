---
type: issue
id: ISS-0022
created: 2026-04-08
topics: [practice, admin]
symptoms: ["오늘의 문제", daily_challenge, "데일리 챌린지", alreadySolvedToday, "/api/questions/today", "날짜 시드 폴백"]
root_cause: "홈 '오늘의 문제' 카드에 쓸 일일 챌린지 도메인이 없었다 (기능 이슈)"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/26"
---

# ISS-0022: Daily Challenge 도메인, 오늘의 챌린지 API, 관리자 화면

GitHub #26 (원본: 이슈 본문. 댓글 없음).

## 증상
홈 "오늘의 문제" 카드에 표시할 일일 챌린지를 백엔드가 결정해야 하는데 도메인이 없었다. 어드민이 캘린더에 문제를 미리 배정하는 큐레이션과, 배정 안 된 날의 폴백, 오늘 이미 풀었는지 표시(`alreadySolvedToday`)가 필요했다.
제안(이슈 본문): `daily_challenge`(UNIQUE `challenge_date`, 하루 1문제). 배정이 있으면 그 문제, 없으면 활성 문제 풀에서 `today.toEpochDay() % activeIds.size()` 날짜 시드 결정적 선택. `GET /api/questions/today?memberUuid=` → `{ question, alreadySolvedToday }`, 활성 문제 0개면 `{ question: null, alreadySolvedToday: false }`. 어드민 `GET/PUT/DELETE /admin/daily-challenges`(활성 문제가 아니면 422), 월별 캘린더 화면.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 댓글 없음. 완료 내용은 원본에 없다. (GitHub #27 리포트가 `DailyChallengeRepository.findByChallengeDate(LocalDate.now())`를 사용한다고 적었다.)

## 근본 원인
해당 없음 (기능 이슈).
