---
type: decision
id: DEC-0271
created: 2026-11-07
reviewed: null
topics: [billing, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0469-billing-switch-unverified-screens-races]]", "[[ISS-0458-server-side-free-limit-pro-gating-report]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]", "[[DEC-0004-free-pro-feature-boundary]]"]
---

# DEC-0271: 무료 하루 한도 판정은 제출 기록 트랜잭션 안에서 회원 행을 잠근 뒤에 한다

## 문제 정의 (Context)
#860 에서 하루 한도를 제출 시점에 다시 판정하게 했지만([[ISS-0458-server-side-free-limit-pro-gating-report]]) 잠금이 없어, 한도가 1문제 남았을 때 서로 다른 문제를 동시에 제출하면 둘 다 통과할 수 있었다 (GitHub #867, [[ISS-0469-billing-switch-unverified-screens-races]]).

## 결정 (Decision)
- 하루 한도 판정을 제출 기록 트랜잭션 안으로 옮기고, 판정 전에 회원 행을 잠근다 (`DailyQuestionSubmitAdmission`, `SubmissionAdmissionCheck`).
- 초과면 롤백 후 `FREE_DAILY_LIMIT_REACHED` > 앱 사유 시트(광고 보너스·이용권) > 같은 답 다시 제출.
- 잠금 순서는 회원 > 제출 기록 한 방향. 같은 회원의 제출끼리만 순서대로 처리된다.
- 샌드박스 비교는 커밋 뒤 트랜잭션 밖에서 한다.
- 판정은 `SubmissionAdmissionCheck` 로만 넘긴다. 기록 트랜잭션 밖으로 다시 꺼내지 않는다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 같은 회원의 동시 제출이 한도를 넘지 않는다. 다른 회원에게는 영향이 없다.

**부정**
- 같은 회원의 제출이 직렬화된다 (구조상 결과, 원본에 별도 논의 없음).

## 영향 범위 (Scope)
서버 `DailyQuestionSubmitAdmission`, `SubmissionAdmissionCheck`, `SubmissionService`, `FeatureAccessPolicy`, `QuestionController`. 앱 제출 거부 사유 시트(`question_detail_page.dart`, `chapter_page.dart`). PR #898 main 머지 (2026-11-07).

## 출처 (References)
- GitHub #867 이슈 본문·리포트 댓글 (2026-11-07, PR #898 main 머지)
- W4 충돌 검사: [[DEC-0239-free-daily-limit-bonus-three-kinds]](한도 값·보너스), [[DEC-0245-free-limit-daily-reset-kept]](초기화 주기)와 충돌 없음 — 판정 시점·잠금만 정함
