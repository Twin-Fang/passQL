---
type: issue
id: ISS-0494
created: 2026-11-11
topics: [ci-deploy, store-release]
symptoms: ["테스트 빌드 업데이트 필요 화면", "TestFlight 최소 버전 차단", "최소 지원 버전 올린 뒤 막힘", decideAppLaunch, app.minimum_version.ios, app.minimum_version.android, AppBuildFlavor.isDevBuild, APP_FLAVOR=dev]
root_cause: "앱 시작 판정 decideAppLaunch 가 설치 버전과 서버 최소 버전만 비교하고 빌드 종류를 보지 않아, 스토어 출시 버전과 별개로 번호가 매겨지는 테스트 빌드도 최소 버전을 올릴 때마다 막혔다"
status: resolved
resolution: "[[ISS-0494-test-build-minimum-version-block-report]]"
related: ["[[DEC-0291-dev-build-skips-minimum-version]]", "[[ISS-0495-admin-app-operation-settings]]", "[[ISS-0361-billing-switch-final-checks]]", "[[DEC-0246-dev-tools-no-prod-writes-store-exclusion]]", "[[DEC-0202-test-build-shared-version-adjust-no-block]]"]
source: "https://github.com/Twin-Fang/passQL/issues/962"
---

# ISS-0494: 테스트 빌드가 최소 버전 검사에 걸림

GitHub #962. 관련 #961, #596, #809, #820.

## 증상
- 운영 서버의 최소 지원 버전(`app.minimum_version.ios`·`android`)을 올리면 TestFlight 등으로 설치한 테스트 빌드도 "업데이트 필요" 화면에 막힌다.
- 2026-11-11 결제 켜기 전 점검 중 최소 버전을 1.66.1에서 1.83.0으로 올린 뒤 TestFlight 테스트 빌드에서 확인.

## 재현 조건
1. 운영 관리자에서 최소 지원 버전을 테스트 빌드 버전보다 높게 올린다.
2. 테스트 빌드(TestFlight 또는 테스트 APK)를 실행한다.

## 조사 기록
- 2026-11-11: 테스트 빌드의 버전 번호는 스토어 출시 버전과 별개로 매겨진다(출시로 닫힌 버전이면 다음 패치, [[DEC-0202-test-build-shared-version-adjust-no-block]]). 테스트 빌드는 운영 서버로 결제·한도를 시험하는 용도라 막히면 안 된다.
- 이슈 범위: 개발용 빌드(`APP_FLAVOR=dev`, `AppBuildFlavor.isDevBuild`)만 건너뛰고, 그 코드는 컴파일 상수로 막아 운영 빌드에 들어가지 않게(#820 방식). 점검 중 테스트 빌드를 막을지는 구현 때 정하기로 함.

## 근본 원인
앱 시작 판정이 빌드 종류를 보지 않았다.
