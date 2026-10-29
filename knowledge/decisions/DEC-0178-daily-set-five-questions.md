---
type: decision
id: DEC-0178
created: 2026-10-25
reviewed: null
topics: ["practice"]
status: active
supersedes: DEC-0085
superseded_by: null
related: ["[[ISS-0392-daily-set-ten-to-five-questions]]", "[[ISS-0392-daily-set-ten-to-five-questions-report]]", "[[DEC-0085-daily-set-ten-questions-daily]]"]
---

# DEC-0178: 오늘의 세트는 하루 5문제, 값은 서버 상수 한 곳에서 정한다 (무료 하루 한도 10은 별개)

GitHub #644 (원본: 이슈 본문 「해결 방안」과 2026-10-26 완료 리포트).

## 문제 정의 (Context)
오늘의 세트가 하루 10문제라 부담이 크고 지금은 아무도 풀지 않는다(사용자 판단). 10이 서버 폴백 선정, 관리자 배정 상한, `QuizSession` 설명, 스토어 문구에 따로 박혀 있었다.

## 결정 (Decision)
- 오늘의 세트를 하루 5문제로 줄인다.
- 값은 한 곳(서버 상수)에서 정하고 폴백 선정·배정 상한·에러 문구가 그 값을 쓴다.
- 무료 하루 한도(`DAILY_FREE_LIMIT=10`, GitHub #576)는 범위가 아니다. 별개 규칙이라 사용자가 정하면 따로 바꾼다.

## 검토한 대안 (Alternatives)
논의 기록 없음. (5 외의 다른 개수를 검토한 기록은 원본에 없다.)

## 결과 (Consequences)
**긍정**
- 논의 기록 없음. (같은 시기 GitHub #645 실사용자 분석 댓글은 재방문 장치 후보로 "오늘의 세트 분량(#644에서 5문제로 줄임)"을 들었다.)

**부정**
- 홍보 이미지·스토어 스크린샷·설명을 다시 만들고 올려야 했다(GitHub #636, #644 리포트).

## 영향 범위 (Scope)
서버 오늘의 세트 선정(`AdminDailyChallengeService` 자정 스케줄러 폴백), 관리자 배정 상한(`DAILY_CHALLENGE_TOO_MANY_QUESTIONS`), `QuizSession` 설명, 앱·웹 문구, `README.md`, `app/docs/PRD.md`, 스토어 설명·홍보 이미지.

## 출처 (References)
- GitHub #644 이슈 본문, 완료 리포트 댓글(PR #663, 릴리스 #666)
- GitHub #636 댓글(홍보 이미지 재생성, PR #659)
- [[ISS-0392-daily-set-ten-to-five-questions]]
