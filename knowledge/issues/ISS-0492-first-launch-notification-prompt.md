---
type: issue
id: ISS-0492
created: 2026-11-12
topics: [notification, home, practice, ads]
symptoms: ["처음 켠 날 알림 권한을 묻지 않음", "두 번째 실행에만 알림 안내", "환영 안내 뒤 알림", notDetermined, canPromptNow, runNotificationPermissionPrompt, home_welcome_guide, earnCredits, "홈 광고 권유 카드", "1번째 문제 목록", "세트 보너스 이름 불일치"]
root_cause: "알림 권한 안내가 결과 화면 뒤 또는 두 번째 실행에만 뜨도록 되어 있어, 앱을 처음 켠 날에는 한 번도 묻지 않았다"
status: resolved
resolution: "[[ISS-0492-first-launch-notification-prompt-report]]"
related: ["[[DEC-0288-first-launch-notification-prompt-after-welcome]]", "[[DEC-0289-home-next-step-no-ad-card-mock-trial]]", "[[DEC-0149-contextual-notification-permission-prompt]]", "[[DEC-0132-push-permission-pre-prompt-sheet]]", "[[ISS-0491-first-run-guide-home-next-step]]"]
source: "https://github.com/Twin-Fang/passQL/issues/980"
---

# ISS-0492: 처음 켤 때 알림 허용 바로 안내

GitHub #980. 관련 #975([[ISS-0491-first-run-guide-home-next-step]]).

## 증상
- 알림 권한 안내가 "학습 결과를 본 뒤 또는 두 번째 실행"에만 떠서, 앱을 처음 켠 날에는 묻지 않는다.
- 사용자 요청(2026-11-12): 처음 켤 때 바로 물어봐 달라.

## 재현 조건
새로 설치한 앱에서 첫 실행, 홈 첫 방문.

## 조사 기록
- 2026-11-12: 이슈 본문 기준. 해결안은 홈 첫 방문 환영 안내 시트의 「시작하기」 직후 알림 권한 안내 시트를 잇는 것(권한 미결정일 때만). 기존 규칙(나중에 후 7일, 이미 허용·거부면 묻지 않음)은 그대로.
- 하지 않는 것(이슈 본문): 시스템 권한 창을 안내 없이 바로 띄우기. 거부하면 다시 물을 수 없어 안내 시트를 거친다.

## 근본 원인
알림 권한 안내 시점이 결과 화면 뒤·두 번째 실행으로만 정해져 있었다([[DEC-0149-contextual-notification-permission-prompt]]).
