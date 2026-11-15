---
type: completion-report
id: ISS-0522
created: 2026-11-16
topics: [practice]
status: resolved
resolves: "[[ISS-0522-lock-screen-turn-screen-on-wake-loop]]"
related: ["[[ISS-0501-lock-screen-question-android]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1096"
---

# ISS-0522 완료 리포트: 잠금화면 문제 화면은 잠금 위 표시만, 화면은 켜지 않음

## 해결 방법
- `AndroidManifest.xml` 의 `android:turnScreenOn="true"`, `LockScreenActivity` 의 `setTurnScreenOn(true)`·구버전 `FLAG_TURN_SCREEN_ON` 제거. `showWhenLocked` 는 유지.
- 규칙 테스트 `app/test/architecture/lock_screen_wake_rules_test.dart`: 잠금화면 네이티브 코드의 화면 켜기 설정 4종 금지 (수정 전 코드에서 3곳 검출).
- PR #1100, 커밋 856d2dda.

## 근본 원인 (확정)
미리 띄우기(화면 꺼짐 시점)와 화면 켜기 설정이 함께 있어, 띄우는 순간 화면이 켜졌다. 미리 띄우는 목적(켤 때 바로 보임)에는 화면 켜기가 필요 없다.

## 검증
에뮬레이터(Android 16, 간격 매번): 수정 전 1.128.1 은 꺼진 뒤 4초 만에 `Awake` 반복, 수정 후는 40초 내내 `Asleep`. 전원 버튼으로 켜면 잠금 위 문제 화면 바로 표시.

## 재발 방지
- 화면 꺼짐 때 띄우는 활동에는 화면 켜기 설정을 두지 않는다 (규칙 테스트가 강제).
- 표시 시점을 화면 켜짐으로 옮기려면 첫 표시 지연 때문에 엔진 데우기와 함께 다시 설계.

## 교훈
- "미리 띄우기" 화면에 `turnScreenOn` 을 붙이면 자기 자신이 화면을 깨우는 루프가 된다. 잠금 위 표시(`showWhenLocked`)와 화면 켜기는 별개다.
