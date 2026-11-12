---
type: completion-report
id: ISS-0492
created: 2026-11-12
topics: [notification, home, practice, ads]
status: resolved
resolves: "[[ISS-0492-first-launch-notification-prompt]]"
related: ["[[DEC-0288-first-launch-notification-prompt-after-welcome]]", "[[DEC-0289-home-next-step-no-ad-card-mock-trial]]"]
source: "https://github.com/Twin-Fang/passQL/issues/980"
---

# ISS-0492 완료 리포트: 처음 켤 때 알림 허용 안내와 어색한 화면 정리

GitHub #980 구현 보고 (2026-11-12). PR #981 머지(2026-11-12).

## 해결 방법
- **처음 켤 때 알림 허용:** 홈 환영 안내에서 「시작하기」를 누르면 바로 알림 허용 안내를 띄운다. 권한이 미결정(`notDetermined`)이고 다시 물어도 되는 시점(`canPromptNow`)일 때만. 이미 허용·거절한 사람에게는 묻지 않는다.
- **크레딧을 다 쓴 날의 홈 「다음에 할 일」:** 광고 보라는 카드(`earnCredits`)는 홈에서 숨긴다. 모의고사 무료 1회가 남아 있으면 「SQLD 모의고사 1회 무료」 카드(`mockExamTrial`). 홈과 무료 문제 탭의 모의고사 행에 「무료 1회」 배지, 무료 문제 탭에도 모의고사 행을 보이게 했다.
- **결과 화면 3종(랜덤 풀이 요약, 오늘의 세트 결과, 단원 결과):** 「1번째 문제 · 3번째 문제」처럼 번호만 있는 목록을 없애고 공통 부품 `SolvedQuestionListSection`(틀린 문제 먼저, 토픽과 지문 표시)을 세 화면이 함께 쓴다. 점수와 같은 내용을 반복하던 지표·문장을 지웠다.
- **그 밖에:** 홈 모의고사 제목 중복, 다음에 할 일 카드의 크레딧 수 중복 제거. 모의고사 안내의 사실과 다른 문구와 "이용권" 표현, 해요체가 아니던 토스트 수정. 세트 보너스 이름을 세 곳 모두 「세트 완료 · 세트 정답 80%」로 맞춤. 홈 랜덤 풀기 행은 세트 보너스를 다 받은 날 광고만 안내.

## 근본 원인 (확정)
알림 안내 시점이 결과 화면 뒤·두 번째 실행에만 있었다.

## 재발 방지
- 홈 카드 순서는 `decideHomeNextStep`(세트 > 랜덤 노출 여부 > 크레딧 0 > 랜덤)이고 `home_next_step_test`가 고정한다. 순서를 바꾸면 홈 카드가 달라진다.
- 알림 안내는 `pushPermissionPromptStoreProvider`의 다시 묻기 간격을 따른다. 간격을 줄이면 같은 사람에게 자주 묻게 된다.

## 교훈
- 결과 화면 세 곳이 같은 목록을 따로 만들고 있어 공통 부품 하나로 모았다(같은 코드 3곳).
- 검증: `home_next_step_test`, 디자인 규칙 테스트, 전체 앱 테스트 통과. 실제 코드로 결과 화면과 홈 카드를 렌더링해 확인.
