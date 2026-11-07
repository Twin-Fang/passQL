---
type: completion-report
id: ISS-0484
created: 2026-11-07
topics: [ci-deploy, store-release]
status: resolved
resolves: "[[ISS-0484-ios-deploy-mutates-version-in-review]]"
related: ["[[DEC-0280-ios-deploy-skip-app-store-step-while-in-review]]"]
source: "_sources/issues/ISS-0484-ios-deploy-mutates-version-in-review.md"
---

# ISS-0484 완료 리포트: iOS 배포 심사 대기 가드

## 해결 방법
- `.github/scripts/ios_release.py` 업로드 단계가 fastlane 을 부르기 전에 `asc_client.list_app_store_versions` 로 확인. `review_locked_version`: 신형(`appVersionState`)·구형(`appStoreState`) 중 하나라도 `WAITING_FOR_REVIEW`·`IN_REVIEW` 면 그 버전.
- 심사 대기 버전이 있거나 조회에 실패하면 fastlane 을 `store_only`(TestFlight 만)로 부르고 `::notice::App Store 단계 건너뜀` 을 남긴다.
- 처음 넣은 Fastfile(Spaceship) 가드는 되돌림.
- 검증: main 수동 실행(`deploy_mode=store_prepare`) > 배포 모드 `store_only`, TestFlight 업로드 완료, 워크플로 성공.

## 근본 원인 (확정)
deliver 는 심사 대기 버전에도 버전 표기·메타데이터를 쓰고, 빌드 선택에서야 실패한다.

## 재발 방지
- 판정 규칙: [[DEC-0280-ios-deploy-skip-app-store-step-while-in-review]].
- 심사가 끝나면 최신 빌드를 `store_submit` 으로 다시 내야 한다(세션 점검이 대신함, 세션 한정).

## 교훈
`PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml` 은 `ref: main` 을 체크아웃한다. 브랜치에서 수동 실행해도 브랜치 코드가 돌지 않는다. 이 워크플로 수정은 main 에 머지한 뒤 main 에서 시험한다. 지금 심사 대기 버전은 표기(1.94.0)와 붙은 빌드가 어긋났을 수 있어 App Store Connect 에서 확인이 필요하다(사용자 Apple 로그인).
