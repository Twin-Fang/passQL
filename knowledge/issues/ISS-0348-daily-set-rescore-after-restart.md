---
type: issue
id: ISS-0348
created: 2026-10-20
topics: [practice, progress-stats]
symptoms: ["오늘의 세트", "앱 재실행", "1번부터 다시", "이어 풀기 없음", "새 세션", sessionUuid, countVerifiedCorrect, DailySetService, "순위 공정성", "첫 제출"]
root_cause: "완료 채점이 '같은 문제는 첫 제출만 인정'을 풀이 세션(sessionUuid) 안에서만 셌다"
status: resolved
resolution: "[[ISS-0348-daily-set-rescore-after-restart-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/561"
---

# ISS-0348: 앱을 다시 켜면 1번부터 다시 풀려 앞에서 본 정답으로 점수를 다시 낼 수 있음

GitHub #561 (원본: 이슈 본문과 댓글).

## 증상
- 오늘의 세트를 몇 문제 풀다가 앱을 다시 켜면 홈 카드가 다시 "풀어보기"로 나오고 1/10부터 새로 시작(이어 풀기 없음).
- 서버 완료 채점(`DailySetService.countVerifiedCorrect`)은 "같은 문제는 첫 제출만 인정"이 의도지만 풀이 세션(sessionUuid) 안에서만 첫 제출을 셈 → 앞 세션에서 정답·AI 해설을 본 뒤 새 세션에서 다시 풀면 그 점수로 완료되어 순위에 오름.

## 재현 조건
앱 홈 > 오늘의 세트 "풀어보기" > 1, 2번 제출(오답 포함), 채점 결과로 정답 확인 > 앱 종료 후 재실행 > 다시 1번부터 정답 제출 > 완료. iOS 18.3 시뮬레이터, 운영 서버, 2026-10-21 오늘의 세트. 관련: `server/PQL-Application/.../DailySetService.java:83`, 앱 `presentation/flows/daily_set_flow.dart`.

## 조사 기록
- 2026-10-21: 커밋 89ad4778로 서버 채점 수정. 이어 풀기는 별도 개선 후보 → GitHub #566.

## 근본 원인
첫 제출 판정 범위가 세션 단위였고, 앱 재실행 시 새 세션이 생긴다.
