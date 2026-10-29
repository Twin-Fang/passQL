---
type: completion-report
id: ISS-0348
created: 2026-10-21
topics: [practice, progress-stats]
status: resolved
resolves: "[[ISS-0348-daily-set-rescore-after-restart]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/561"
---

# ISS-0348 완료 리포트: 문제별 정답 여부를 오늘 그 문제의 첫 제출(세션 무관)로 판정

GitHub #561 리포트 댓글(`## 개요`, 2026-10-21) 기준. 커밋 89ad4778, v1.27.0.

## 해결 방법
- `SubmissionRepository.java`: `findByMemberUuidAndQuestionUuidInAndSubmittedAtGreaterThanEqualOrderBySubmittedAtAsc`.
- `DailySetService.java`: `countVerifiedCorrect`가 세션 제출로 문제 범위를 정하고, 정답 판정은 오늘 첫 제출(세션 무관, 시간순) 기준.
- `DailySetScoreVerificationTest.java`: `앱을_다시_켜_새_세션으로_다시_풀어도_오늘_첫_제출로_채점한다` 포함 7건.

## 근본 원인 (확정)
첫 제출 판정이 sessionUuid 범위 안에서만 이뤄졌다.

## 재발 방지
- 검증: DailySet 테스트 통과. 운영 배포 후 "다음 오늘의 세트 완료부터 적용".
- 주의: 오늘의 기준은 서버 `LocalDate.now()` 자정(기존 세트 조회와 같은 기준). 이 세션에 제출이 없는 문제는 점수에 들어가지 않는다(기존 동작 유지).

## 교훈
(원본에 없음, 볼트 정리) "첫 제출만 인정" 같은 공정성 규칙은 세션이 아니라 사용자·날짜 범위로 판정해야 재시작·재진입으로 우회되지 않는다.
