---
type: decision
id: DEC-0246
created: 2026-11-04
reviewed: null
topics: [dev-workflow, ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0449-dev-tools-store-build-guard]]", "[[ISS-0449-dev-tools-store-build-guard-report]]", "[[DEC-0240-dev-tools-two-layer-gate-test-builds]]", "[[DEC-0005-ship-with-billing-switch-off]]", "[[DEC-0118-single-source-commonization-rules]]"]
---

# DEC-0246: 개발자 도구는 운영 데이터를 바꾸는 기능을 넣지 않고, 스토어 빌드 제외는 컴파일 상수 + 두 스토어 워크플로의 release 프로파일 + 규칙 테스트 세 겹으로 보장한다

## 문제 정의 (Context)
개발자 도구([[DEC-0240-dev-tools-two-layer-gate-test-builds]], #809)는 스토어 빌드에서 안 보였지만, Android 스토어 워크플로에 release 프로파일이 없었고 표시 판정이 실행 시점 값이라 코드가 스토어 바이너리에 남았다. 개발 플래그 주입이나 운영 서버 수정을 막는 자동 검사도 없었다 (GitHub #820).

## 결정 (Decision)
- **사용자 결정 (2026-11-04):** 개발자 도구에 운영 데이터를 바꾸는 기능(결제 스위치 등)은 넣지 않는다. 개발자 도구는 스토어 빌드에 절대 들어가지 않는다. 실제 결제 시험은 관리자 화면의 결제 미리보기 회원 목록으로 한다.
- **보장 세 겹:**
  1. 코드: `AppBuildFlavor.isDevBuild`·`canUseDevTools`는 컴파일 상수(`const`). 스토어 빌드는 상수 false라 이 값으로 막은 개발자 도구 코드가 빌드에서 빠진다.
  2. 워크플로: iOS·Android 스토어 워크플로 모두 `.env` 생성 뒤 빌드 프로파일 release 단계를 거친다 (개발 키 제거 + 꺼짐 검증, 켜져 있으면 빌드 중단).
  3. 규칙 테스트 `dev_tools_release_guard_test.dart`: release 프로파일은 개발 키 false·dart_define 없음, 스토어 워크플로 2개는 `APP_FLAVOR` 없음 + release 적용, 개발자 도구 코드는 서버 API·데이터 소스·HTTP 클라이언트 import 금지.
- `.env` 서버 주소 키는 `core/config/env_keys.dart`(`EnvKeys`) 한 곳에 둔다. 개발자 도구가 HTTP 클라이언트를 import하지 않고 이 키를 읽게 하기 위해서다.
- [[DEC-0240-dev-tools-two-layer-gate-test-builds]]의 두 층 게이트(컴파일타임 `APP_FLAVOR=dev` + `.env` `APP_SHOW_DEV_TOOLS=true`)와 "강제값은 표시만 바꾼다"는 그대로 유효하다. 이 결정은 그 컴파일타임 층을 상수로 굳히고 보장 장치를 더한 것이다.

## 검토한 대안 (Alternatives)
- 개발자 도구에 결제 스위치처럼 운영 데이터를 바꾸는 기능을 넣는 안: 사용자가 넣지 않기로 했다. 대신 관리자 화면의 결제 미리보기 회원 목록을 쓴다. 그 밖의 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 스토어 바이너리에 개발자 도구 코드가 남지 않고, Secret `.env`에 개발 키가 남아도 Android·iOS 스토어 빌드가 멈춘다.
- 개발자 도구가 서버 호출 계층을 import하면 테스트가 바로 실패한다 (`EnvKeys` 이동이 첫 사례).

**부정**
- 운영 데이터가 필요한 시험(실제 결제 등)은 개발자 도구로 할 수 없고 관리자 화면을 거쳐야 한다.

## 영향 범위 (Scope)
앱 `core/config/app_build_flavor.dart`, `core/config/env_keys.dart`, `presentation/widgets/dev_tools/`, `test/architecture/dev_tools_release_guard_test.dart`. CI `.github/config/build-profile.json`, `PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`, `PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml`.

## 출처 (References)
- GitHub #820 이슈 본문, 리포트 (2026-11-04), PR #821
- 사용자 결정 (2026-11-04, 이슈 본문 "사용자 결정 2026-11-04")
- 이슈: [[ISS-0449-dev-tools-store-build-guard]], 리포트 [[ISS-0449-dev-tools-store-build-guard-report]]
