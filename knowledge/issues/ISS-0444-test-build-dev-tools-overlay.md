---
type: issue
id: ISS-0444
created: 2026-11-04
topics: [dev-workflow, ci-deploy]
symptoms: ["개발자 도구", "플로팅 버튼", "테스트 빌드에서 등급 확인", "무료 한도 흉내", "등급 강제", "결제 스위치 꺼짐 무제한", "테스트 광고 단위", DevToolsOverlay, APP_FLAVOR, APP_SHOW_DEV_TOOLS, build-profile.json, PRO_DEBUG_PLAN, dev_plan_overrides, app_build_flavor]
root_cause: "운영 서버는 결제 스위치가 꺼져 모두 무제한이라 테스트 빌드에서 무료 등급·한도 소진 시트·보상형 광고 버튼·보너스 카드를 볼 방법이 없었다"
status: resolved
resolution: "[[ISS-0444-test-build-dev-tools-overlay-report]]"
related: ["[[ISS-0444-test-build-dev-tools-overlay-report]]", "[[DEC-0240-dev-tools-two-layer-gate-test-builds]]", "[[DEC-0202-test-build-shared-version-adjust-no-block]]", "[[ISS-0442-app-open-ad-interstitial-cap-relax]]", "[[ISS-0443-free-daily-limit-bonus]]"]
source: "https://github.com/Twin-Fang/passQL/issues/809"
---

# ISS-0444: 테스트 빌드 개발자 도구 (플로팅 버튼으로 등급·광고·무료 한도 상태 확인)

GitHub #809 (원본: 완료 리포트 댓글. 이슈 본문은 이 노트 작성에 쓰지 않았다).

> 상태: 이 노트는 코드 PR과 같이 들어간다. 작성 시점(2026-11-04)에는 미머지·미배포다. 완료 리포트: [[ISS-0444-test-build-dev-tools-overlay-report]]

## 증상
- 기능 요청이다. Android 테스트 APK, iOS 테스트 TestFlight에서 등급·무료 한도·광고 화면을 바로 확인할 수단이 없었다.
- 결제 스위치가 꺼진 운영 서버에서는 모두 무제한이라 #808의 한도 소진 시트·광고 버튼·보너스 카드를 볼 수 없었다.
- #787 앱 오프닝 광고의 Android 실기기 확인도 테스트 빌드가 필요했다.

## 재현 조건
테스트 빌드로 운영 서버에 로그인하면 등급이 무제한으로 보이고, 한도 소진 경로에 들어갈 수 없다.

## 조사 기록
- 2026-11-04: 엘룸 프로젝트의 `DevToolsOverlay`(끌어서 옮기는 플로팅 버튼 + 도구 시트) 방식을 가져오기로 했다.
- 2026-11-04: 워크플로에 이미 있던 빌드 프로파일(`.github/config/build-profile.json`)을 켜서 테스트 빌드에만 개발 값을 넣기로 했다.

## 근본 원인
결제 스위치 꺼짐 상태의 운영 서버로는 무료 회원 경로를 재현할 수 없었고, 테스트 빌드에 표시 상태를 바꿀 도구가 없었다.
