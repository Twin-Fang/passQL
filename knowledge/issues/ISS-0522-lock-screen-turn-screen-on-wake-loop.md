---
type: issue
id: ISS-0522
created: 2026-11-16
topics: [practice]
symptoms: ["화면이 꺼지면 다시 켜짐", "잠금화면 화면 켜짐 반복", "화면이 안 꺼짐", "배터리 소모", "turnScreenOn", "setTurnScreenOn", "FLAG_TURN_SCREEN_ON", "ACTION_SCREEN_OFF", "LockScreenActivity", "mWakefulness Awake"]
root_cause: "잠금화면 서비스가 화면 꺼짐 때 미리 띄우는 LockScreenActivity 에 turnScreenOn 설정이 있어 꺼지자마자 화면을 다시 켜고, 자동 꺼짐 > 다시 켜짐이 반복됐다"
status: resolved
resolution: "[[ISS-0522-lock-screen-turn-screen-on-wake-loop-report]]"
related: ["[[ISS-0501-lock-screen-question-android]]", "[[ISS-0518-lock-screen-engine-stale-refresh-token-reuse]]"]
source: "_sources/issues/ISS-0522-lock-screen-turn-screen-on-wake-loop.md"
---

# ISS-0522: 잠금화면 문제를 켜면 화면이 꺼진 직후 다시 켜짐

GitHub #1096. 원본: https://github.com/Twin-Fang/passQL/issues/1096 (사용자 의견 보내기로 접수)

## 증상
- Android, 잠금화면 문제 켜짐. 폰을 가만히 둬 화면이 저절로 꺼진 직후 문제 화면과 함께 다시 켜짐.
- 간격 "매번"이면 꺼짐 > 켜짐이 끝없이 반복돼 화면이 사실상 꺼지지 않음 (배터리·발열).

## 재현 조건
설정 > 잠금화면 문제 켜기, 간격 "매번" > 화면 자동 꺼짐까지 대기 (또는 전원 끄기).

## 조사 기록
- 2026-11-16: `LockScreenService.onScreenOff()` 가 `LockScreenActivity` 시작, 매니페스트 `turnScreenOn="true"` + `setTurnScreenOn(true)` 확인. 상태 알림 재게시는 낮은 중요도 채널 + `setOnlyAlertOnce` 라 원인 아님. 에뮬레이터 수정 전 빌드(1.128.1)에서 `dumpsys power` 로 `Asleep` > 4초 뒤 `Awake` 반복 재현.
