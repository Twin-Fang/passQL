---
type: issue
id: ISS-0161
created: 2026-04-25
topics: [practice]
symptoms: ["오늘의 세트", "데일리 세트", "재방문 동기", "daily_set.question_count", "/api/question-sets/daily", "완료 뱃지"]
root_cause: "해당 없음 — 기능 추가(매일 풀 목표·습관 장치 부재)"
status: resolved
resolution: "[[ISS-0161-daily-set-feature-report]]"
related: ["[[DEC-0085-daily-set-ten-questions-daily]]", "[[ISS-0160-ai-practice-set-epic-cancelled]]"]
source: "https://github.com/Twin-Fang/passQL/issues/304"
---

# ISS-0161: 오늘의 데일리 세트 기능 추가

GitHub #304 (원본: 이슈 본문과 2026-10-07 댓글). 기능 이슈, 에픽 GitHub #303의 하위 이슈.

## 증상
(현재 문제점) 사용자가 능동적으로 문제를 찾아야만 풀 수 있고, 매일 "오늘 이것만 풀면 된다"는 목표가 없어 재방문 동기가 낮다. 연속 학습 습관 장치가 없다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-04-25 기획: 매일 자동 갱신 5문제, 전 회원 동일 세트, AI가 토픽 고르게 조합. 홈 "오늘의 세트" 카드, 완료 결과 요약, 자정 기준 갱신(`app_setting`으로 문제 수 조정), 완료 뱃지.
  - BE 계획: `QuestionSetService.generateDailySet()`(날짜 시드 기반), `GET /api/question-sets/daily`, `POST /api/question-sets/{setId}/submit`, `app_setting` 키 `daily_set.question_count`(기본값 5).
  - FE 계획: 홈 카드, 진행 바 풀이 화면, 결과 요약(맞힌 수/틀린 수/소요 시간).
- 2026-10-07: 구현·운영 확인 댓글(아래 리포트).

## 근본 원인
해당 없음 (기능 추가).
