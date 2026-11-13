---
type: decision
id: DEC-0307
created: 2026-11-12
reviewed: null
topics: [ci-deploy, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0512-test-build-minimum-version-block]]", "[[DEC-0246-dev-tools-no-prod-writes-store-exclusion]]", "[[DEC-0240-dev-tools-two-layer-gate-test-builds]]"]
---

# DEC-0307: 개발용 빌드(`AppBuildFlavor.isDevBuild`, 컴파일 상수)는 최소 지원 버전 비교를 건너뛰고, 점검 중에는 개발용 빌드도 막는다

## 문제 정의 (Context)
운영 최소 지원 버전을 올리면 테스트 빌드도 "업데이트 필요" 화면에 막혀 운영 서버로 하는 결제·한도 시험이 끊겼다 (GitHub #962, [[ISS-0512-test-build-minimum-version-block]]). 이슈는 점검 중 테스트 빌드를 막을지를 구현 때 정하기로 남겼다.

## 결정 (Decision)
- 앱 시작 판정(`decideAppLaunch`)은 개발용 빌드면 최소 버전 비교를 건너뛴다(`isMinimumVersionCheckSkipped`).
- 이 판정은 컴파일 상수 `AppBuildFlavor.isDevBuild`로 막아 스토어 운영 빌드에는 들어가지 않는다 ([[DEC-0246-dev-tools-no-prod-writes-store-exclusion]]와 같은 방식).
- 스토어 운영 빌드는 지금처럼 최소 버전 미만이면 막힌다.
- 점검 중에는 개발용 빌드도 막는다. 점검은 서버 작업 중이라는 뜻이기 때문이다(리포트 「변경」).

## 검토한 대안 (Alternatives)
- 점검 중에도 개발용 빌드는 통과: 위 이유로 막는 쪽을 골랐다. 그 밖의 논의 기록 없음.
- 권장 버전 안내는 이번 범위가 아니다(이슈 본문).

## 결과 (Consequences)
**긍정**
- 최소 버전을 올려도 테스트 빌드로 운영 서버 시험을 계속할 수 있다.

**부정**
- 논의 기록 없음. 리포트 시점에 실기기 TestFlight 확인은 다음 테스트 빌드로 남았다.

## 영향 범위 (Scope)
- 앱 `decideAppLaunch`, `app_launch_decision_test.dart`.

## 출처 (References)
- GitHub #962 이슈 본문과 구현 보고(PR #967): https://github.com/Twin-Fang/passQL/issues/962
