---
type: decision
id: DEC-0300
created: 2026-11-12
reviewed: null
topics: [practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0510-daily-set-retry-wrong-and-qa-fixes]]", "[[ISS-0510-daily-set-retry-wrong-and-qa-fixes-report]]", "[[DEC-0073-session-result-fixed-at-first-submit]]", "[[DEC-0089-shared-question-flow-for-solving]]"]
---

# DEC-0300: 오늘의 세트 오답 다시 풀기는 세트 점수를 바꾸지 않고, 다시 맞힌 표시는 서버에 저장하지 않고 앱 메모리에만 둔다

GitHub #1035 (이슈 본문 「예상 동작」, 완료 리포트 「주의사항」).

## 문제 정의 (Context)
세트 결과 화면 `틀린 N문제 다시 풀기`가 첫 오답 1문제만 열고, 다시 맞혀도 결과 표·버튼 문구가 그대로였다.

## 결정 (Decision)
- 다시 풀기는 오답 N문제를 차례로 풀고 세트 결과로 돌아온다(`DailySetRetryFlow`, [[DEC-0089-shared-question-flow-for-solving]]의 `QuestionFlow` 구현).
- 세트 점수·순위·보너스·크레딧은 바꾸지 않는다(서버에 다시 보내지 않음).
- 다시 맞힌 행은 원래 `오답` 배지를 유지하고 옆에 `맞힘`만 붙이며, 버튼 숫자는 남은 오답 수.
- `맞힘` 표시는 앱 메모리(`dailySetRetryProvider`, 날짜 키)에만 둔다. 앱 재실행·날짜·회원 변경 시 사라진다.

## 검토한 대안 (Alternatives)
- 로컬 저장소 또는 서버 기록으로 재실행 후에도 유지: 리포트가 "필요하면" 할 일로만 남김. 채택하지 않은 이유는 "세트 점수를 바꾸지 않는다는 원칙 때문에 서버에 저장하지 않았다" 외 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 세트 점수·순위가 최초 제출 기준으로 유지된다([[DEC-0073-session-result-fixed-at-first-submit]]의 최초 제출 고정과 같은 방향, 그 결정의 "복습 완료 표시 미구현"을 앱 세트에서 채움).
- 다시 맞힌 사실이 결과 화면에 드러난다.

**부정**
- 앱을 다시 켜면 결과 화면이 다시 `틀린 N문제`로 돌아간다.

## 영향 범위 (Scope)
`app/lib/presentation/pages/daily_set/daily_set_result_page.dart`, `DailySetRetryFlow`, `daily_set_retry_providers.dart`, 라우터 `/daily-set/retry`·`AppRoutes.dailySetRetryOf()`, `solving_flow_exit.dart`.

## 출처 (References)
- GitHub #1035 이슈 본문, 완료 리포트(PR #1040, 커밋 47d08b35)
