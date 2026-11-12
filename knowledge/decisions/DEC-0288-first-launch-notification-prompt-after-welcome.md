---
type: decision
id: DEC-0288
created: 2026-11-12
reviewed: null
topics: [notification, home]
status: active
supersedes: DEC-0149
superseded_by: null
related: ["[[DEC-0149-contextual-notification-permission-prompt]]", "[[DEC-0132-push-permission-pre-prompt-sheet]]", "[[ISS-0492-first-launch-notification-prompt]]"]
---

# DEC-0288: 알림 권한 안내는 처음 켤 때 홈 환영 안내의 「시작하기」 직후에 띄운다 (권한 미결정이고 다시 물어도 될 때만)

## 문제 정의 (Context)
[[DEC-0149-contextual-notification-permission-prompt]]는 알림 권한 안내를 "가입 직후가 아니라" 결과 화면 뒤 탭 복귀 시나 두 번째 실행부터 띄우게 했다. 그래서 앱을 처음 켠 날에는 묻지 않았고, 사용자가 2026-11-12에 "처음 켤 때 바로 물어봐 달라"고 요청했다 (GitHub #980).

## 결정 (Decision)
- 홈 첫 방문 환영 안내에서 「시작하기」를 누르면 바로 알림 허용 안내 시트를 띄운다.
- 권한이 미결정(`notDetermined`)이고 다시 물어도 되는 시점(`canPromptNow`)일 때만 띄운다. 이미 허용·거절한 사람에게는 묻지 않는다.
- 시스템 권한 창을 안내 없이 바로 띄우지 않는다. 앱 안내 시트를 거친다 ([[DEC-0132-push-permission-pre-prompt-sheet]] 유지). "나중에" 뒤 7일 규칙도 그대로.
- DEC-0149의 "가입 직후가 아니라" 부분을 사용자 요청으로 뒤집는다. DEC-0149의 다른 시점(결과 화면 뒤 탭 복귀, 두 번째 실행)을 없앴다는 기록은 없다.

## 검토한 대안 (Alternatives)
- 시스템 권한 창을 안내 없이 바로 띄우기: 거부하면 다시 물을 수 없어 버렸다(이슈 본문).
- 앱을 켜자마자 시스템 창: 이유를 모르고 거절하기 쉬워, 환영 안내로 맥락을 준 다음 묻는다(리포트 「왜 이렇게 했나」).

## 결과 (Consequences)
**긍정**
- 첫날부터 알림 허용을 물을 수 있다. 리포트는 맥락을 준 뒤 묻는 편이 허용률이 높다고 적었다(측정 기록 없음).

**부정**
- `pushPermissionPromptStoreProvider`의 다시 묻기 간격을 줄이면 같은 사람에게 자주 묻게 된다.

## 영향 범위 (Scope)
- 앱 `home_welcome_guide.dart`(환영 시트 닫힘 > 권한 미결정·간격 확인 > `runNotificationPermissionPrompt`).

## 출처 (References)
- GitHub #980 이슈 본문과 구현 보고(PR #981): https://github.com/Twin-Fang/passQL/issues/980
