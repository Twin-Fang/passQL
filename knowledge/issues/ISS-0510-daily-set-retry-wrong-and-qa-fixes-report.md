---
type: completion-report
id: ISS-0510
created: 2026-11-12
topics: [practice, design-system, home]
status: resolved
resolves: "[[ISS-0510-daily-set-retry-wrong-and-qa-fixes]]"
related: ["[[DEC-0300-daily-set-retry-correct-mark-memory-only]]", "[[DEC-0089-shared-question-flow-for-solving]]", "[[DEC-0073-session-result-fixed-at-first-submit]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1035"
---

# ISS-0510 완료 리포트: 오답 N문제 차례로 다시 풀기, 코드 줄바꿈 들여쓰기, 일정 버튼 위치, 모의고사 목록 재조회

커밋 47d08b35, PR #1040. 원본: 리포트 `docs/projectops/report/20261112_1035_1112_QA_결함_오답_다시_풀기_외_3건.md`(로컬).

## 해결 방법
- 다시 풀기: `DailySetRetryFlow`(신규, 기존 `QuestionFlow` 재사용, 흐름 id `daily-set-retry`로 세트 진행 상태와 분리) > `/daily-set/retry?questions=<오답 uuid 목록>`, `AppRoutes.dailySetRetryOf()`. 마지막 문제 `결과 보기` > 맞힘·틀림을 `dailySetRetryProvider`(`daily_set_retry_providers.dart`, 날짜 키, 메모리)에 기록 > 세트 결과 복귀. 다시 맞힌 행은 `오답` 배지 유지 + 초록 `맞힘`, 버튼 숫자 = 남은 오답 수, 0이면 `닫기 / 전체 순위`. 다시 틀리면 목록에서 뺌, 날짜·회원 바뀌면 비움.
- 풀이 흐름 경로 묶음(`solving_flow_exit.dart`)에 `/daily-set/retry` 추가 > 닫기(X)가 세트 결과로.
- `PassqlCodeBlock`: 넘친 뒷부분을 원래 줄 앞 공백 + 짧은 첫 단어(`SELECT ` 등) 뒤에서 이어 씀. 주석 줄(`--`)은 `--` 뒤로 들여 쓰고 회색 유지.
- `exam_schedule_timeline.dart`: 지난 일정 펼침 버튼을 목록 맨 위로.
- 모의고사: 회차 화면 진입마다 `GET /api/mock-exams/rounds` 재조회, 홈 당겨서 새로고침에도 회차 목록 갱신.

## 근본 원인 (확정)
[[ISS-0510-daily-set-retry-wrong-and-qa-fixes]]「근본 원인」 4건과 같음.

## 재발 방지
- 다시 풀기 완료 뒤 pop은 `Future(router.pop)`로 한 박자 늦춤. 동기 pop이면 완료 잠금 창만 닫혀 화면이 그대로(검증 중 발견).
- 새 풀이 흐름 경로는 `solving_flow_exit.dart` 경로 묶음에도 넣어야 닫기(X)가 결과 화면으로 돌아옴.
- 검증: `flutter analyze` 이슈 없음, `flutter test` 172개 통과, iOS 시뮬레이터 재검증(진행 바 `1 / 3`, 버튼 3 > 1, 다 맞히면 `닫기 / 전체 순위`). 서버 대조: 다시 풀기 4번 동안 `usedCredits` 15 유지, `/daily-set/today` `correctCount 2`, 순위 `2점 1위` 유지. 회차 화면 두 번 진입 > `GET /api/mock-exams/rounds 200` 두 번. 서버 로그는 보지 않음.

## 교훈
- 다시 풀기 `맞힘`은 메모리 전용 — 앱 재실행 시 `틀린 N문제`로 돌아감([[DEC-0300-daily-set-retry-correct-mark-memory-only]]). 재실행 후 유지 요구가 오면 로컬 저장소·서버 기록이 필요.
- 화면 재진입 시 목록이 안 바뀌면 다른 화면이 provider를 붙잡아 재조회가 안 되는지 먼저 확인.
