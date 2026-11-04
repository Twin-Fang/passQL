---
type: completion-report
id: ISS-0449
created: 2026-11-04
topics: [dev-workflow, ci-deploy]
status: resolved
resolves: "[[ISS-0449-dev-tools-store-build-guard]]"
related: ["[[DEC-0246-dev-tools-no-prod-writes-store-exclusion]]", "[[DEC-0240-dev-tools-two-layer-gate-test-builds]]", "[[ISS-0444-test-build-dev-tools-overlay-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/820"
---

# ISS-0449 완료 리포트: 개발용 빌드 판정을 컴파일 상수로, Android 스토어에 release 프로파일, 규칙 테스트 3개

GitHub #820 리포트 기준 (2026-11-04). 원본 사본: `_sources/issues/ISS-0449-dev-tools-store-build-guard-report.md` (로컬 전용). PR #821로 main에 머지됐다.

> 배포 상태: 작성 시점(2026-11-04)에 #817 릴리스 뒤 머지돼 다음 릴리스에 들어간다.

## 해결 방법
개발자 도구가 스토어 빌드에 절대 들어가지 않고, 운영 데이터를 바꾸지 않는다는 것을 코드·워크플로·테스트 세 겹으로 보장했다 → [[DEC-0246-dev-tools-no-prod-writes-store-exclusion]].
- `app/lib/core/config/app_build_flavor.dart`: `AppBuildFlavor.isDevBuild`·`canUseDevTools`를 컴파일 상수(`const`)로. 스토어 빌드는 상수 false라 이 값으로 막은 개발자 도구 코드가 빌드에서 빠진다.
- `.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`: `.env`를 만드는 두 곳 뒤에 빌드 프로파일 release 단계 (iOS 스토어와 같음). 개발 키를 걷어내고 꺼짐을 검증하며, 켜져 있으면 빌드를 멈춘다.
- `app/test/architecture/dev_tools_release_guard_test.dart` (신규) 규칙 3개:
  - `build-profile.json` release: 개발 키 false, dart_define 없음
  - 스토어 워크플로 2개: `APP_FLAVOR` 없음 + release 프로파일 적용
  - 개발자 도구 코드: 서버 API·데이터 소스·HTTP 클라이언트 import 금지 (운영 변경 금지)
- `app/lib/core/config/env_keys.dart` (신규): `.env` 서버 주소 키 원본. 개발자 도구가 HTTP 클라이언트 파일을 import하던 것을 이 테스트가 바로 잡아내 옮겼다.
- **검증:** 앱 analyze 0, 테스트 101 통과. release 프로파일을 운영 `.env` 사본에 적용해 "런타임·컴파일타임 양쪽 모두 꺼진 것을 확인".

## 근본 원인 (확정)
스토어 빌드 제외가 실행 시점 판정과 iOS 스토어 워크플로의 release 단계에만 기대고 있었고, Android 스토어 워크플로에는 그 단계가 없었다. 이를 지키는 자동 검사도 없었다.

## 재발 방지
- 컴파일 상수 + 두 스토어 워크플로의 release 프로파일 + 규칙 테스트 3개. 새 개발자 도구 코드가 서버 API·데이터 소스·HTTP 클라이언트를 import하면 테스트가 실패한다.

## 알고 남긴 것
- 개발자 도구에 운영 데이터를 바꾸는 기능(결제 스위치 등)은 넣지 않는다 (사용자 결정). 실제 결제 시험은 관리자 화면의 결제 미리보기 회원 목록으로 한다.

## 교훈
(원본에서 정리)
- iOS·Android 스토어 워크플로는 같은 보호 단계를 각각 가져야 한다. 한쪽에만 있는 단계는 규칙 테스트로 두 워크플로 모두를 검사한다.
