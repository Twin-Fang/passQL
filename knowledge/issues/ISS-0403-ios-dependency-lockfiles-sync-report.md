---
type: completion-report
id: ISS-0403
created: 2026-10-26
topics: [ci-deploy]
status: resolved
resolves: "[[ISS-0403-ios-dependency-lockfiles-sync]]"
related: ["[[DEC-0181-commit-ios-package-resolved]]"]
source: "https://github.com/Twin-Fang/passQL/issues/670"
---

# ISS-0403 완료 리포트: `Podfile.lock` 동기화와 `Package.resolved` 2개 커밋

GitHub #670 리포트 댓글 기준 (PR #671, `main` 머지, 앱 CI 통과). 앱 코드는 바꾸지 않았다.

## 해결 방법
- `app/ios/Podfile.lock`: `in_app_purchase_storekit` 추가, 일부 pod 체크섬 갱신(29줄 추가, 22줄 삭제).
- `Package.resolved` 2개 추가. 예: `firebase-ios-sdk 12.19.0`, `GoogleSignIn-iOS 9.2.0`, `swift-package-manager-google-mobile-ads 13.11.0`, `SDWebImage 5.21.7`. 새 라이브러리 없음.
- 두 위치는 Xcode가 워크스페이스로 열 때와 프로젝트로 열 때 각각 만들어 둘 다 커밋.
- 이 레포는 커밋 제목으로 버전을 올리기 때문에 커밋 타입을 `feat` 대신 `chore`로 커밋.

## 근본 원인 (확정)
lock 파일 미갱신과 SPM 산출물 미추적.

## 재발 방지
- 팀원의 Flutter 버전·SPM 설정이 다르면 이 파일들이 서로 덮어써진다. 팀 공유는 아직 하지 않음.
- `Podfile.lock` 체크섬 29줄은 하나씩 대조하지 않음.
- iOS TestFlight 워크플로우는 `ios/Podfile`이 있으면 `pod install`을 실행한다. `Package.resolved`와 충돌하는지는 확인하지 않았고 TestFlight 빌드도 돌려 보지 않음.

## 교훈
(원본에 없음, 볼트 정리) iOS 빌드 뒤 lock 파일이 작업 트리에 남으면 pubspec과의 불일치나 미추적 SPM 산출물부터 확인한다.
