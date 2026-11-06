---
type: decision
id: DEC-0273
created: 2026-11-07
reviewed: null
topics: [ops-infra, ads, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0469-billing-switch-unverified-screens-races]]", "[[ISS-0458-server-side-free-limit-pro-gating-report]]", "[[ISS-0270-maintenance-force-update-notices]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]"]
---

# DEC-0273: 점검 모드에서도 외부 콜백(AdMob 보상 서버 검증, App Store 서버 알림)은 통과시키고, 그 경로는 `ExternalCallbackPaths` 한 곳에서 관리한다

## 문제 정의 (Context)
점검 모드는 `/api/**` 를 503 으로 막는다([[ISS-0270-maintenance-force-update-notices]]). #860 에서 만든 AdMob 보상 서버 검증 콜백도 이 필터에 걸려, 점검 중 본 광고의 보상이 기록되지 않았다([[ISS-0458-server-side-free-limit-pro-gating-report]] 「알고 남긴 것」). 503 을 받으면 재전송 사이에 보상이나 환불 알림이 늦어지거나 유실된다 (GitHub #867, [[ISS-0469-billing-switch-unverified-screens-races]]).

## 결정 (Decision)
- 점검 모드에서도 AdMob 보상 서버 검증 콜백과 App Store 서버 알림은 통과시킨다 (`MaintenanceModeFilter`).
- 두 경로는 `ExternalCallbackPaths` 한 곳에 두고, 보안 설정(`SecurityConfig`)과 점검 필터가 함께 쓴다. 규칙 테스트로 강제 (`MaintenanceModeFilterTest`).
- 외부 콜백 경로를 추가하면 `ExternalCallbackPaths` 에 넣는다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 점검 중에도 광고 보상·환불 알림이 지연·유실되지 않는다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
서버 `PQL-Web` `ExternalCallbackPaths`, `MaintenanceModeFilter`, `SecurityConfig`. 기존 점검 예외(`/api/meta/**`, `/api/auth/**`, 관리자)에 외부 콜백이 더해진다. PR #898 main 머지 (2026-11-07).

## 출처 (References)
- GitHub #867 이슈 본문·리포트 댓글 (2026-11-07, PR #898 main 머지)
- W4 충돌 검사: 점검 모드 범위를 정한 활성 결정 없음, [[DEC-0239-free-daily-limit-bonus-three-kinds]](광고 보너스)와 충돌 없음
