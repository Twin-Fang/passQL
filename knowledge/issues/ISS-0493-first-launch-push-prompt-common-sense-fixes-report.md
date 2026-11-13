---
type: completion-report
id: ISS-0493
created: 2026-11-12
topics: [notification, home, practice]
status: resolved
resolves: "[[ISS-0493-first-launch-push-prompt-common-sense-fixes]]"
related: ["[[ISS-0491-first-run-guide-home-next-step]]"]
source: "https://github.com/Twin-Fang/passQL/issues/980"
---

# ISS-0493 완료 리포트: 첫 실행 알림 안내, 결과 목록 공통화, 크레딧 0일 때 홈 (PR #981)

## 해결 방법
- 홈 환영 안내 「시작하기」 뒤 알림 허용 안내. 권한 미결정(`notDetermined`)이고 다시 물어도 되는 시점(`canPromptNow`)일 때만.
- `decideHomeNextStep`: 크레딧 0이면 모의고사 무료 1회가 남았을 때 `mockExamTrial`, 아니면 `earnCredits`(홈에서는 숨김). 홈·무료 문제 탭 모의고사 행에 「무료 1회」 배지.
- 결과 화면 3종을 공통 `SolvedQuestionListSection`(틀린 문제 먼저, 토픽·지문)으로. 점수와 겹치는 지표·문장 제거.
- 세트 보너스 이름 「세트 완료 · 세트 정답 80%」로 통일, 모의고사 안내의 사실과 다른 문구·"이용권" 표현, 해요체 아닌 토스트 수정.
- 2026-11-12 1.102.0으로 Android 프로덕션 심사 등록, iOS 심사 제출.

## 근본 원인 (확정)
첫 실행 흐름에 알림 안내 없음, 결과 목록 3곳 중복, 홈 판정에 크레딧 0 대안 없음.

## 재발 방지
- 홈에서는 광고를 권하지 않는다. 광고 보상은 크레딧이 막힌 순간(한도 시트)에만.
- 풀이 결과 목록은 `SolvedQuestionListSection` 하나로 만든다.

## 교훈
- 시스템 알림 창은 앱 소개 직후, 맥락을 준 다음 띄운다(논의 기록: 사용자 요청 "알림 허용도 처음 켤 때 바로 물어봐줘").
