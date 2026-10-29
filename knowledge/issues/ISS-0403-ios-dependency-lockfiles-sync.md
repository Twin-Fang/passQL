---
type: issue
id: ISS-0403
created: 2026-10-26
topics: [ci-deploy]
symptoms: [Podfile.lock, Package.resolved, in_app_purchase_storekit, "작업 트리에 lock 변경 남음", "Swift Package Manager", SPM]
root_cause: "커밋된 Podfile.lock이 pubspec.yaml과 어긋났고, SPM이 만든 Package.resolved가 레포에 없었다"
status: resolved
resolution: "[[ISS-0403-ios-dependency-lockfiles-sync-report]]"
related: ["[[DEC-0181-commit-ios-package-resolved]]"]
source: "https://github.com/Twin-Fang/passQL/issues/670"
---

# ISS-0403: iOS 의존성 고정 파일 갱신

GitHub #670 (원본: 이슈 본문과 댓글).

## 증상
- `app/ios/Podfile.lock`이 `app/pubspec.yaml`과 어긋남: pubspec에는 `in_app_purchase_storekit`이 있지만 커밋된 lock에는 없다.
- 로컬 iOS 빌드 때마다 `Podfile.lock`이 바뀌어 작업 트리에 남고, 무관한 이슈 커밋에 섞일 위험.
- Flutter가 iOS 플러그인 일부를 SPM으로 가져오면서 `Package.resolved`가 새로 생겼는데 레포에 없어 사람·CI마다 패키지 버전이 달라질 수 있다:
  - `app/ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved`
  - `app/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`

## 재현 조건
로컬에서 iOS 빌드.

## 조사 기록
- 2026-10-26: 두 `Package.resolved`는 바이트 단위로 동일, 패키지 21개 고정. iOS 시뮬레이터 빌드 2회 성공.

## 근본 원인
lock 파일이 pubspec 변경 뒤 갱신·커밋되지 않았고, SPM 산출물이 추적되지 않았다.
