---
type: issue
id: ISS-0424
created: 2026-10-28
topics: [ci-deploy]
symptoms: ["Xcode 27 iOS 빌드 실패", IPHONEOS_DEPLOYMENT_TARGET, "Encountered error while building for device.", "range of supported deployment target versions is 15.0 to 27.1", Pods.xcodeproj]
root_cause: "CocoaPods 라이브러리 다수가 최소 iOS 버전을 9.0~13.0으로 선언했고 Xcode 27은 지원 범위(15.0~27.1) 밖 값을 빌드 에러로 처리한다"
status: open
resolution: null
related: ["[[ISS-0403-ios-dependency-lockfiles-sync]]"]
source: "https://github.com/Twin-Fang/passQL/issues/732"
---

# ISS-0424: Xcode 27에서 iOS 빌드 실패 — Pod 최소 iOS 버전 미달

GitHub #732 (원본: 이슈 본문과 댓글). 이슈는 열려 있다(라벨 작업중). 원본에 완료 리포트는 없다.

## 증상
빌드 맥을 Xcode 27.1(macOS 27.2)로 올린 뒤 `flutter build ios`가 실패한다. Pods 타깃 약 40개에서 같은 에러:
```
Pods.xcodeproj: error: The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 13.0,
but the range of supported deployment target versions is 15.0 to 27.1.x.
(in target 'in_app_purchase_storekit-in_app_purchase_storekit_privacy' from project 'Pods')
```
대상 예: PromisesObjC(9.0), GTMSessionFetcher(10.0), RecaptchaInterop(11.0), AppAuth(12.0), Flutter·url_launcher_ios(13.0).

## 재현 조건
1. Xcode 27.1 설치 후 `cd app/ios && pod install`
2. `cd app && flutter build ios --release --no-codesign`
3. `Encountered error while building for device.`

환경: macOS 27.2, Xcode 27.1 (27A9275), Flutter 3.38.9.

## 조사 기록
- App Store 업로드에 최신 SDK(Xcode 26 이상)가 요구되어 Xcode 16.2 → 27.1 업그레이드 과정에서 드러남.
- 앱 자체 최소 지원 버전은 이미 iOS 15.0(`app/ios/Podfile` `platform :ios, '15.0'`, Runner 타깃 15.0)이라 사용자 기기 지원 범위에는 영향 없음.
- 조치 방향(이슈 본문): `app/ios/Podfile` `post_install`에서 15.0 미만 Pod 타깃의 최소 iOS 버전을 15.0으로 맞춘다.
- 다른 이슈 기록: GitHub #727·#708 실측에서도 Xcode 27 빌드 문제가 언급됨. #708 후속 리포트는 Xcode 27의 `lipo -verify_arch`가 Flutter 3.38.9와 맞지 않아 "#732 수정만으로는 해결되지 않는다"고 적었다.

## 근본 원인
Pod 타깃의 최소 iOS 버전 선언이 Xcode 27 지원 범위 밖(이슈 본문).
