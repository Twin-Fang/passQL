---
type: issue
id: ISS-0262
created: 2026-10-15
topics: [ci-deploy]
symptoms: ["@projectops app build", "Resource not accessible by integration", "Expected to find project root in current working directory.", "flutter pub get 레포 루트", GITHUB_TOKEN permissions, "Keystore file not found", upload_testflight lane, Firebase App Distribution]
root_cause: "테스트 빌드 워크플로 2개가 모노레포 경로(`app/`)와 `permissions`가 반영되지 않은 projectops 옛 템플릿 상태였다"
status: resolved
resolution: "[[ISS-0262-issue-comment-app-test-build-fail-report]]"
related: ["[[ISS-0258-github-secret-synology-backup]]"]
source: "https://github.com/Twin-Fang/passQL/issues/456"
---

# ISS-0262: 이슈 댓글 앱 테스트 빌드(`@projectops app build`)가 Android·iOS 모두 실패

GitHub #456 (원본: 이슈 본문, 구현 보고서, 후속 보고). 원본의 테스터 이메일·Firebase 앱 ID·서비스 계정 주소는 옮기지 않았다.

## 증상
이슈 댓글 `@projectops app build main`으로 테스트 빌드를 돌리면 둘 다 실패 (run `38679553275`, `38679553763`).
- Android 테스트 APK: "진행 상황 댓글 생성" 단계에서 `Resource not accessible by integration`.
- iOS 테스트 TestFlight: 레포 루트에서 `flutter pub get` → `Expected to find project root in current working directory.`
- Android 테스트 APK의 Firebase App Distribution 설정이 비어 있음(`FIREBASE_APP_ID`·`FIREBASE_TESTER_GROUP` placeholder, Secret `FIREBASE_SERVICE_ACCOUNT_JSON_BASE64` 미등록).
- 트리거 워크플로(`PROJECT-FLUTTER-PROJECTOPS-APP-BUILD-TRIGGER.yaml`)는 정상.

## 재현 조건
아무 이슈에 `@projectops app build main` 댓글 → `PROJECT-Flutter-Android-Test-APK`, `PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT` 실패.

## 조사 기록
- 2026-10-15: 원인 표 — Android: 레포 기본 `GITHUB_TOKEN` 권한 `read`인데 워크플로에 `permissions` 없음. iOS: 레포 루트 실행 + 존재하지 않는 `upload_testflight` lane 호출. 교체 후 Android: `Keystore file '.../android/app/keystore/key.jks' not found`(템플릿은 `android/keystore`, `build.gradle.kts`는 `android/app/keystore`). 교체 후 iOS 1회차: 업로드 마지막 단계 500(Apple 서버 일시 오류, 재실행으로 해결).
- 2026-10-15: 기존 서버용 서비스 계정에 App Distribution 권한이 없다고 판단(조회 시 `PERMISSION_DENIED`). 2026-10-16 후속: 서비스 계정이 이미 App Distribution 서비스 에이전트 역할을 갖고 있어 역할 추가는 필요 없었다.

## 근본 원인
frontmatter `root_cause`와 같음.
