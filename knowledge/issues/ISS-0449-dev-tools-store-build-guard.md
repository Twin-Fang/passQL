---
type: issue
id: ISS-0449
created: 2026-11-04
topics: [dev-workflow, ci-deploy]
symptoms: ["개발자 도구 스토어 빌드 포함", "Android 스토어 빌드 프로파일 없음", "개발 키 안 걷힘", "실행 시점 판정", "개발자 도구 코드가 바이너리에 남음", "APP_FLAVOR 실수 주입", "개발자 도구 운영 서버 수정", AppBuildFlavor, isDevBuild, canUseDevTools, app_build_flavor.dart, build-profile.json, PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml, PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml, APP_SHOW_DEV_TOOLS]
root_cause: "Android 스토어 워크플로에 빌드 프로파일 release 단계가 없었고, 개발자 도구 표시 판정이 실행 시점 값이라 코드가 스토어 바이너리에 들어갔으며, 스토어 워크플로의 개발 플래그와 개발자 도구의 운영 서버 수정을 막는 자동 검사가 없었다"
status: resolved
resolution: "[[ISS-0449-dev-tools-store-build-guard-report]]"
related: ["[[ISS-0449-dev-tools-store-build-guard-report]]", "[[DEC-0246-dev-tools-no-prod-writes-store-exclusion]]", "[[DEC-0240-dev-tools-two-layer-gate-test-builds]]", "[[ISS-0444-test-build-dev-tools-overlay]]"]
source: "https://github.com/Twin-Fang/passQL/issues/820"
---

# ISS-0449: 개발자 도구 스토어 빌드 차단 보장 (컴파일 상수, Android 스토어 프로파일, 규칙 테스트)

GitHub #820 이슈 본문 기준. 원본 사본: `_sources/issues/ISS-0449-dev-tools-store-build-guard.md` (로컬 전용). 완료 리포트: [[ISS-0449-dev-tools-store-build-guard-report]]

## 증상
개발자 도구([[ISS-0444-test-build-dev-tools-overlay]], #809)는 스토어 빌드에서 안 보이지만, 보장 장치가 일부 비어 있었다.
- Android 스토어 워크플로는 빌드 프로파일 release 단계가 없어 `.env` 개발 키를 걷어내거나 꺼짐을 검증하지 않는다 (iOS 스토어는 함).
- 표시 판정이 실행 시점 값이라 개발자 도구 코드가 스토어 바이너리에 그대로 들어간다.
- 스토어 워크플로에 개발용 플래그(`APP_FLAVOR=dev`)가 실수로 들어가도 막는 자동 검사가 없다.
- 개발자 도구가 운영 서버를 수정하지 않는다는 것을 강제하는 검사가 없다.

## 재현 조건
Android 스토어 워크플로(`PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`)로 빌드할 때, Secret `.env`에 `APP_SHOW_DEV_TOOLS=true`가 남아 있거나 워크플로에 `APP_FLAVOR`가 들어간 경우.

## 조사 기록
- 2026-11-04: 사용자 결정 — 개발자 도구에 운영 데이터를 바꾸는 기능은 넣지 않는다 → [[DEC-0246-dev-tools-no-prod-writes-store-exclusion]].

## 근본 원인
스토어 빌드 제외가 실행 시점 판정과 iOS 워크플로에만 기대고 있었고, 이를 지키는 자동 검사가 없었다.
