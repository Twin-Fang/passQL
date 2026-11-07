---
type: decision
id: DEC-0280
created: 2026-11-07
reviewed: null
topics: [ci-deploy, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0484-ios-deploy-mutates-version-in-review]]", "[[DEC-0201-play-promote-closed-testing-default-false]]"]
---

# DEC-0280: App Store 에 심사 대기·심사 중 버전이 있거나 확인할 수 없으면 iOS 배포는 TestFlight 업로드만 한다

## 문제 정의 (Context)
심사 대기 중에 배포하면 deliver 가 그 버전의 표기·메타데이터를 바꾼 뒤 실패했다 (#939).

## 결정 (Decision)
iOS 배포 업로드 단계(`ios_release.py`)는 fastlane 을 부르기 전에 ASC 버전 목록을 본다. `WAITING_FOR_REVIEW`·`IN_REVIEW` 버전이 있거나 조회가 실패하면 배포 모드를 `store_only` 로 바꿔 TestFlight 업로드만 하고, App Store 버전 표기·메타데이터·심사 제출은 건드리지 않는다. 확인하지 못하면 다음 배포에서 다시 판단한다.

## 검토한 대안 (Alternatives)
- 심사 대기 제출을 취소하고 최신 빌드로 다시 제출: 리포트에 "대기열 뒤로 감, 사용자 결정"으로 남김. 자동화하지 않음. 그 밖의 논의 기록 없음.
- Fastfile 안에서 Spaceship 으로 확인: 넣었다가 되돌림. 브랜치 시험이 main 코드로 돌아 검증되지 않았고, 이미 쓰는 Python ASC 조회 경로가 더 확실하다는 이유 (PR #940 본문).

## 결과 (Consequences)
**긍정**
- 심사 중 버전의 표기와 메타데이터가 더 바뀌지 않는다. 배포 워크플로가 실패로 끝나지 않는다.

**부정**
- 심사가 끝난 뒤 최신 빌드 제출은 따로 해야 한다(자동 제출이 한 번 건너뛰어짐).

## 영향 범위 (Scope)
`.github/scripts/ios_release.py` `_phase_upload`, `PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml` 의 `store_submit`·`store_prepare` 배포.

## 출처 (References)
- GitHub #939 완료 리포트 댓글, PR #940 (2026-11-07)
