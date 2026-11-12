---
type: completion-report
id: ISS-0494
created: 2026-11-12
topics: [ci-deploy, store-release]
status: resolved
resolves: "[[ISS-0494-test-build-minimum-version-block]]"
related: ["[[DEC-0291-dev-build-skips-minimum-version]]"]
source: "https://github.com/Twin-Fang/passQL/issues/962"
---

# ISS-0494 완료 리포트: 개발용 빌드는 최소 버전 비교를 건너뜀

GitHub #962 구현 보고 (2026-11-12). PR #967 머지(2026-11-12).

## 해결 방법
- `decideAppLaunch`에 `isMinimumVersionCheckSkipped`를 더하고, 개발용 빌드(`AppBuildFlavor.isDevBuild`, 컴파일 상수)면 최소 버전 비교를 건너뛴다.
- 점검 중에는 개발용 빌드도 그대로 막는다.
- 판정 순서: 점검 중? > 개발용 빌드? > 최소 버전 미만?

## 근본 원인 (확정)
앱 시작 판정이 설치 버전과 서버 최소 버전만 비교하고 빌드 종류를 보지 않았다.

## 재발 방지
- `app_launch_decision_test.dart`: 운영 빌드 차단, 개발용 빌드 통과, 개발용 빌드 점검 차단 3경우.

## 교훈
- 검증: flutter analyze, flutter test 통과. 실기기 TestFlight 테스트 빌드 확인은 다음 테스트 빌드에서 필요(리포트 시점 미확인).
