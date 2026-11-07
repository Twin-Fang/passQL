---
type: issue
id: ISS-0484
created: 2026-11-07
topics: [ci-deploy, store-release]
symptoms: ["심사 대기 버전 표기 바뀜", "Successfully set the version", "reject_if_possible doesn't work when using submit_build", "The app store version is in Waiting For Review", "select_build", "iOS 배포 매번 실패", "브랜치 수동 실행이 main 체크아웃", PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml, ios_release.py, deliver]
root_cause: "store_submit 이 심사 대기 버전이 있어도 deliver 로 그 버전 표기·메타데이터를 바꾼 뒤 빌드 선택에서 실패했다"
status: resolved
resolution: "[[ISS-0484-ios-deploy-mutates-version-in-review-report]]"
related: ["[[DEC-0280-ios-deploy-skip-app-store-step-while-in-review]]", "[[ISS-0452-server-only-release-triggers-store-submit]]", "[[ISS-0197-app-store-review-submission]]"]
source: "_sources/issues/ISS-0484-ios-deploy-mutates-version-in-review.md"
---

# ISS-0484: 심사 대기 중에 iOS 배포가 대기 버전 표기·메타데이터를 바꿈

GitHub #939 (https://github.com/Twin-Fang/passQL/issues/939). projectops 템플릿에도 보고: Cassiiopeia/projectops#1079.

## 증상
- `store_submit` 배포에서 deliver 가 심사 대기 버전의 버전 문자열을 새 버전으로 바꾸고(`Successfully set the version to ...`) 메타데이터를 올린 뒤 빌드 선택에서 실패: `The app store version is in Waiting For Review`.
- 배포가 거듭되며 심사 대기 버전 표기가 1.89.1 > 1.90.0 > 1.92.0 > 1.94.0 으로 바뀜(ASC 상태 조회). 붙은 빌드는 그대로일 가능성이 큼.
- 워크플로는 매번 실패로 끝남(TestFlight 업로드는 성공).

## 재현 조건
App Store 에 `WAITING_FOR_REVIEW`·`IN_REVIEW` 버전이 있을 때 앱 변경이 든 릴리스를 deploy 에 머지.

## 조사 기록
- 2026-11-07: 실패 로그 확인, ASC 상태 조회 워크플로로 표기 변화 확인.
- 2026-11-07: Fastfile(Spaceship) 가드를 넣고 브랜치에서 `store_prepare` 수동 실행 2회 > 둘 다 App Store 단계 실행됨. 원인: 이 워크플로는 실행 브랜치와 관계없이 `ref: main` 을 체크아웃해 브랜치 수정이 시험되지 않았다. 그 시험 실행이 대기 버전 표기를 1.94.0 으로 한 번 더 바꿨다.
- 2026-11-07: Fastfile 가드를 되돌리고 `ios_release.py` 업로드 단계에서 ASC 버전 목록으로 판정(PR #940). main 수동 실행(run 42355714866)에서 `::notice::App Store 단계 건너뜀: 1.94.0 심사 대기·심사 중` 확인.

## 근본 원인
배포 흐름에 "심사 중이면 App Store 단계를 건너뛴다"는 확인이 없었다.
