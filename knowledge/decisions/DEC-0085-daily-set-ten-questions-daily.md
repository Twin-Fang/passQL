---
type: decision
id: DEC-0085
created: 2026-10-07
reviewed: null
topics: [practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0161-daily-set-feature]]", "[[ISS-0161-daily-set-feature-report]]", "[[ISS-0177-app-daily-set-result-leaderboard]]"]
---

# DEC-0085: 데일리 세트는 기획한 5문제가 아니라 매일 10문제 세트로 한다

## 문제 정의 (Context)
매일 풀 목표와 재방문 동기를 주려고 데일리 세트를 기획했다(GitHub #304, 2026-04-25). 기획은 매일 자동 갱신 5문제, 전 회원 동일 세트였다.

## 결정 (Decision)
데일리 세트는 매일 10문제 세트로 최종 구현되었다(2026-10-07 댓글 "5문제 기획은 매일 10문제 세트로 최종 구현되었다"). 홈 '오늘의 세트' 카드, 완료 뱃지, 결과, 리더보드, 서버 점수 검증(GitHub #342)을 포함한다.

## 검토한 대안 (Alternatives)
- 5문제 세트(최초 기획, `daily_set.question_count` 기본값 5): 10문제로 바뀐 이유는 논의 기록 없음.
- "전 회원 동일 세트"·"날짜 시드 기반 조합"이 최종 구현에도 유지됐는지는 완료 댓글에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
데일리 세트 서버 로직과 홈 카드·결과·리더보드(웹, 앱 GitHub #332). 구체 파일은 원본에 적혀 있지 않다.

## 출처 (References)
- GitHub #304 이슈 본문, 2026-10-07 댓글
