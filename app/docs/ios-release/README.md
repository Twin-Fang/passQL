# iOS TestFlight 배포 (GitHub Actions)

이 맥의 Xcode 가 오래되어(iOS 26 SDK 미만) 직접 업로드할 수 없으므로 GitHub Actions 의 macOS 26 러너로 빌드·업로드한다.

1. 최초 1회: `bash app/docs/ios-release/register-ios-secrets.sh` 로 시크릿을 등록한다(비밀 값은 이 맥에서만 처리).
2. Actions 탭 > PROJECT-FLUTTER-IOS-TESTFLIGHT > Run workflow (모드 `store_only` = TestFlight 까지).
3. TestFlight 에서 실기기 확인 후 App Store Connect 에서 심사 제출.

| 파일 | 역할 |
|---|---|
| `app/ios/ExportOptions.plist` | 앱스토어 내보내기 설정(수동 서명, 프로파일 이름) |
| `app/ios/fastlane/Fastfile`, `Appfile` | TestFlight 업로드 레인 |
| 시크릿 `GOOGLE_SERVICE_INFO_PLIST_BASE64` | Firebase 설정(저장소에 커밋하지 않음) |

프로파일은 Xcode 자동 서명이 만든 `iOS Team Store Provisioning Profile: com.coldredrice.passql` 을 쓴다. 만료(2027-10-02) 전에 갱신해야 한다.
