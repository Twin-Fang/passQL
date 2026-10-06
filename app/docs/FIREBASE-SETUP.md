# Firebase 설정 파일 받는 방법

앱은 Firebase 프로젝트 `passql`(웹, 서버와 같은 프로젝트)을 쓴다. 아래 두 파일은 환경별 값이라
저장소에 커밋하지 않고(`.gitignore`), 로컬과 CI 에서 각각 준비한다.

| 파일 | 위치 | 앱 ID |
|---|---|---|
| `google-services.json` | `android/app/` | `1:662424763183:android:fbecdd636daa8ef423bfda` |
| `GoogleService-Info.plist` | `ios/Runner/` | `1:662424763183:ios:0d246719760816ba23bfda` |

앱 ID(패키지/번들 ID)는 `kr.suhsaechan.passql` 이다.

## 받기

Firebase CLI 가 프로젝트 `passql` 에 로그인되어 있어야 한다(`firebase login`).

```bash
firebase apps:sdkconfig ANDROID 1:662424763183:android:fbecdd636daa8ef423bfda \
  --project passql --out android/app/google-services.json
firebase apps:sdkconfig IOS 1:662424763183:ios:0d246719760816ba23bfda \
  --project passql --out ios/Runner/GoogleService-Info.plist
```

## Android 구글 로그인

릴리스/디버그 서명 키의 SHA-1 지문이 Firebase 앱에 등록되어 있어야 로그인된다.

```bash
# 디버그 키 지문 확인
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android | grep SHA1
# 등록
firebase apps:android:sha:create 1:662424763183:android:fbecdd636daa8ef423bfda <SHA-1> --project passql
```

릴리스 키스토어를 만들면 그 SHA-1 도 같은 방법으로 등록한 뒤 `google-services.json` 을 다시 받는다.

## iOS

- Sign in with Apple 은 `ios/Runner/Runner.entitlements` 로 설정되어 있다. 실기기/배포 빌드에는
  Apple Developer 계정에서 같은 번들 ID 의 Sign in with Apple 기능이 켜진 프로비저닝이 필요하다.
- Firebase 콘솔 > Authentication 에서 Google, Apple 로그인 제공자가 켜져 있어야 한다.

## CI

CI 에서는 시크릿(`GOOGLE_SERVICES_JSON` 등)으로 위 파일을 만든 뒤 빌드한다.
