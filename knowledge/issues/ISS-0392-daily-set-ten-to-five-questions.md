---
type: issue
id: ISS-0392
created: 2026-10-25
topics: ["practice"]
symptoms: ["오늘의 세트 10문제", "오늘의 세트 5문제", "DAILY_CHALLENGE_TOO_MANY_QUESTIONS", "AdminDailyChallengeService", "아무도 풀지 않음"]
root_cause: "오늘의 세트가 하루 10문제라 부담이 크고 아무도 풀지 않는다(사용자 판단)"
status: resolved
resolution: "[[ISS-0392-daily-set-ten-to-five-questions-report]]"
related: ["[[DEC-0178-daily-set-five-questions]]"]
source: "https://github.com/Twin-Fang/passQL/issues/644"
---

# ISS-0392: 오늘의 세트를 하루 10문제에서 5문제로 줄이기

GitHub #644 (원본: 이슈 본문과 완료 리포트 댓글).

## 증상
오늘의 세트가 하루 10문제라 부담이 크고, 지금은 아무도 풀지 않는다(사용자 판단). 10이 박힌 곳: 서버 자정 스케줄러 폴백 선정(토픽 round-robin 10문제, `AdminDailyChallengeService`), 관리자 배정 상한(`DAILY_CHALLENGE_TOO_MANY_QUESTIONS` 최대 10개), `QuizSession` 설명, 스토어 문구·홍보 이미지의 "오늘의 세트 10문제".

## 재현 조건
해당 없음 (기능 변경 이슈).

## 조사 기록
- 2026-10-25: 작업 범위 — 서버 세트 크기 상수(5) 도입·폴백 선정·상한 검증·에러 문구 적용, 앱·웹 고정 "10문제" 문구 정리, 스토어 문구·홍보 이미지(GitHub #636과 같이), 이미 배정된 날짜 데이터 처리 방침 확인, 배포 후 자정 스케줄러 실측. 무료 하루 한도(`DAILY_FREE_LIMIT=10`, GitHub #576)는 범위 밖.
- 2026-10-25: GitHub #636 댓글 — 홍보 이미지를 5문제 기준으로 재생성(PR #659).
- 2026-10-26: 완료 리포트(PR #663, 릴리스 #666) — 남은 문서·스토어 설명 문구 정리.

## 근본 원인
세트 크기 10이 여러 곳(서버 폴백 선정, 배정 상한, 설명, 스토어 문구)에 따로 박혀 있었다(원본 「현재 문제점」).
