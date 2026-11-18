---
type: decision
id: DEC-0345
created: 2026-11-18
reviewed: null
topics: [home, auth-member]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0543-home-welcome-sheet-only-when-daily-set-solvable]]", "[[ISS-0543-home-welcome-sheet-only-when-daily-set-solvable-report]]", "[[DEC-0302-first-run-sheets-today-steps-notification-preview]]", "[[ISS-0521-sqld-exam-guide-and-yearly-stats]]"]
---

# DEC-0345: 홈 환영 시트는 오늘의 세트를 풀 수 있을 때만 띄우고, 버튼은 `오늘의 세트 시작하기` + `나중에` 두 개로 한다

GitHub #1157 (이슈 본문, 완료 보고서). [[DEC-0302-first-run-sheets-today-steps-notification-preview]] 의 환영 시트 버튼(`둘러볼게요`)과 #1076 에서 붙은 SQLD 알아보기 버튼을 이 결정이 대신한다. DEC-0302 의 3단계 구성과 알림 안내 미리보기 카드는 그대로 유효(사용자가 2026-11-18 대화에서 A안 선택).

## 문제 정의 (Context)
- 온보딩이 이미 오늘의 세트로 보내는데, 환영 시트가 홈 첫 방문만 보고 떠서 세트를 막 푼 사람에게 같은 권유를 반복했다.
- 주 버튼 아래 글자 버튼 2개가 같은 무게로 경쟁했고, SQLD 알아보기는 첫 문제 전 샛길이었다. 사용자 방향: 흐름대로 따라가면 자연스럽게 공부(리텐션).

## 결정 (Decision)
- 표시: 오늘의 세트를 풀 수 있음(문제 있고 미완료) > 시트 / 이미 풂·문제 없음 > 시트 없이 알림 권한 안내(기존 조건) / 세트 정보 없음 > 판정 미룸(본 것으로 기록 안 함).
- 버튼: `오늘의 세트 시작하기` + plain `나중에`. 잠금화면 소개·알림 안내 시트와 같은 구조.
- SQLD 알아보기는 환영 시트에 두지 않는다(입구는 시험 일정 화면).

## 검토한 대안 (Alternatives)
- B. 버튼만 정리: 작업은 적지만 세트 푼 사람에게 다시 권하는 문제가 남음(보고서).
- C. 시트 없이 「다음에 할 일」 카드 강조: 방해는 가장 적지만 온보딩을 건너뛴 사람에게 안내가 약함(보고서).

## 결과 (Consequences)
**긍정**
- 누구에게나 지금 할 일 하나만 보인다. 앱 안 시트 버튼 구조가 하나로 맞는다.

**부정**
- SQLD 알아보기 입구가 시험 일정 화면 하나로 줄었다(결과 화면·홈 카드 안내는 별도 판단, 보고서 주의사항).
- 판정은 첫 프레임 값 한 번이라 홈 데이터가 나중에 바뀌어도 다시 판정하지 않는다.

## 영향 범위 (Scope)
앱 `widgets/home/home_welcome_guide.dart`, `pages/home/home_page.dart`. 온보딩·알림 권한 조건은 그대로.

## 출처 (References)
- GitHub #1157 이슈 본문, 완료 보고서 댓글
- [[ISS-0543-home-welcome-sheet-only-when-daily-set-solvable-report]]
