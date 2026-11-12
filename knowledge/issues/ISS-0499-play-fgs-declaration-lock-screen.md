---
type: issue
id: ISS-0499
created: 2026-11-12
topics: [store-release, ci-deploy]
symptoms: ["You must let us know whether your app uses any Foreground Service permissions", "upload_to_play_store 실패", "FOREGROUND_SERVICE_SPECIAL_USE", "잠금화면 권한"]
root_cause: "잠금화면 문제(#990)가 특수 용도 포그라운드 서비스 권한을 추가했는데 Play Console 앱 콘텐츠 신고가 없어 업로드가 거절됐다"
status: open
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/1002"
---

# ISS-0499: Play 업로드 거절 — 잠금화면 포그라운드 서비스 권한 미신고

GitHub #1002.

## 증상
1.106.2 Android Play 업로드 실패(fastlane upload_to_play_store): "You must let us know whether your app uses any Foreground Service permissions."

## 조사 기록
- 2026-11-12: PR #1003으로 매니페스트에서 FOREGROUND_SERVICE·FOREGROUND_SERVICE_SPECIAL_USE·RECEIVE_BOOT_COMPLETED, LockScreenService·LockScreenBootReceiver 선언 제거, `LockScreenBridge.isLockScreenShipped = false`. 1.106.3(533) 업로드·Google 심사 자동 등록 성공.
- 다시 켜기: 동작 영상(YouTube 미등록) + Play Console 앱 콘텐츠 > 포그라운드 서비스 권한 > 특수 용도 신고 > 승인 후 매니페스트 되돌리고 플래그 true. 특수 용도는 심사 거절 가능.

## 근본 원인
권한 신고 없이 특수 용도 포그라운드 서비스 권한을 배포에 포함.
