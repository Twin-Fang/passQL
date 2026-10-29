---
type: decision
id: DEC-0181
created: 2026-10-26
reviewed: null
topics: [ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0403-ios-dependency-lockfiles-sync]]", "[[ISS-0403-ios-dependency-lockfiles-sync-report]]"]
---

# DEC-0181: iOS `Podfile.lock`과 SPM `Package.resolved` 2개를 레포에 커밋해 의존성 버전을 고정한다

## 문제 정의 (Context)
커밋된 `Podfile.lock`이 `pubspec.yaml`과 어긋나 있었고, Flutter가 일부 iOS 플러그인을 SPM으로 가져오며 생긴 `Package.resolved`가 레포에 없어 사람·CI마다 패키지 버전이 달라질 수 있었다 (GitHub #670).

## 결정 (Decision)
- 갱신된 `Podfile.lock`과 `Package.resolved` 2개(`Runner.xcworkspace/...`, `Runner.xcodeproj/project.xcworkspace/...`)를 한 커밋으로 반영해 의존성 버전을 고정한다(이슈 본문).
- 리포트: "이 파일을 커밋하면 팀원과 CI가 같은 패키지 버전으로 빌드합니다." 두 위치 모두 커밋.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 팀원과 CI가 같은 패키지 버전으로 빌드.

**부정**
- Flutter 버전·SPM 설정이 다르면 파일들이 서로 덮어써진다 — Flutter 버전 맞추기 공유 필요(미실시).
- TestFlight 워크플로우의 `pod install`과 충돌 여부 미확인.

## 영향 범위 (Scope)
`app/ios/Podfile.lock`, `app/ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved`, `app/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`, iOS TestFlight 워크플로우.

## 출처 (References)
- GitHub #670 이슈 본문 「해결 방안」, 리포트 댓글 「주요 구현 내용」·「주의사항」
- [[ISS-0403-ios-dependency-lockfiles-sync]]
