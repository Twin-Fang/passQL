---
type: decision
id: DEC-0305
created: 2026-11-12
reviewed: null
topics: [home, ads, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0493-first-launch-push-prompt-common-sense-fixes]]", "[[ISS-0491-first-run-guide-home-next-step]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]", "[[DEC-0283-daily-limit-view-reward-first]]"]
---

# DEC-0305: 홈 「다음에 할 일」 카드는 광고를 권하지 않는다 — 크레딧이 0이면 모의고사 무료 1회가 남았을 때만 그 카드를, 없으면 카드를 숨긴다

## 문제 정의 (Context)
[[ISS-0491-first-run-guide-home-next-step]]에서 홈 맨 위 `다음에 할 일` 카드를 오늘의 세트 > 랜덤 풀기 > 크레딧 받기 순으로 두었다. 크레딧을 다 쓴 날에는 광고를 보라는 카드(`earnCredits`)가 홈 맨 위에 떴다 (GitHub #980 구현 보고).

## 결정 (Decision)
- 홈 `다음에 할 일` 카드에서 광고 보라는 카드(`earnCredits`)를 숨긴다.
- 크레딧이 0이고 모의고사 무료 1회가 남아 있으면 「SQLD 모의고사 1회 무료」 카드(`mockExamTrial`)를 보인다. 둘 다 아니면 카드를 숨긴다.
- 판정 순서는 `decideHomeNextStep`의 세트 > 랜덤 노출 여부 > 크레딧 0 > 랜덤이다.
- 광고 보상 안내는 크레딧이 막힌 순간(한도 시트)에 둔다 ([[DEC-0283-daily-limit-view-reward-first]]).
- 범위: 이 결정은 `다음에 할 일` 카드에 한한다. 홈 랜덤 풀기 행은 세트 보너스를 다 받은 날 광고만 안내하고, 홈 인라인 광고 구간은 이 결정과 무관하다.

## 검토한 대안 (Alternatives)
- 크레딧 0일 때 광고 카드(`earnCredits`) 유지: 홈은 학습을 시작하는 곳이라 광고 권유를 두지 않기로 해 버렸다(리포트 「왜 이렇게 했나」). 그 밖의 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 크레딧이 없어도 할 수 있는 일(모의고사 무료 1회, [[DEC-0264-mock-exam-fixed-rounds-server-judged]])로 이어진다.

**부정**
- 크레딧이 0이고 모의고사 무료도 쓴 무료 회원은 홈 맨 위에 할 일 카드가 없다.

## 영향 범위 (Scope)
- 앱 홈 `decideHomeNextStep`(`home_next_step_test`가 순서 고정), 홈·무료 문제 탭 모의고사 행 「무료 1회」 배지.

## 출처 (References)
- GitHub #980 구현 보고(PR #981): https://github.com/Twin-Fang/passQL/issues/980
