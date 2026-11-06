---
type: decision
id: DEC-0269
created: 2026-11-07
reviewed: null
topics: [auth-member, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0468-web-audit-cross-tab-reissue-logout]]", "[[ISS-0468-web-audit-cross-tab-reissue-logout-report]]", "[[DEC-0144-per-device-refresh-token-reuse-revoke]]", "[[DEC-0270-reissue-logout-only-on-session-end]]"]
---

# DEC-0269: 웹 토큰 재발급은 탭 간 Web Locks 로 한 번만 하고, 잠금 안에서 저장값을 다시 읽으며, 새 토큰은 `storage` 이벤트로 다른 탭에 반영한다

## 문제 정의 (Context)
서버는 이미 회전된 refresh token 이 다시 오면 그 회원 세션을 전부 폐기한다([[DEC-0144-per-device-refresh-token-reuse-revoke]]). 웹은 재발급을 탭 안에서만 한 번으로 묶어, 탭 두 개면 한 탭이 회전한 뒤 다른 탭이 옛 refresh token 을 보내 앱을 포함한 모든 기기가 로그아웃됐다 (GitHub #881, [[ISS-0468-web-audit-cross-tab-reissue-logout]]).

## 결정 (Decision)
- **탭 간 단일 실행:** 재발급은 Web Locks 로 여러 탭 중 한 탭만 한다 (`accessTokenReissueCoordinator.ts`, 탭 안 단일 비행 + 탭 간 잠금).
- **잠금 안 재확인:** 잠금을 얻으면 저장된 토큰을 다시 읽는다. 요청 때 토큰과 다르면 다른 탭이 이미 재발급한 것이므로 저장된 새 토큰으로 재시도하고 재발급하지 않는다.
- **탭 간 동기화:** 새 토큰은 저장 후 `storage` 이벤트로 다른 탭에 바로 반영한다 (`authStore.ts`).
- 서버 재사용 탐지(DEC-0144)는 그대로 둔다.

## 검토한 대안 (Alternatives)
논의 기록 없음. (이슈 본문 「예상 동작」이 storage 이벤트 동기화 + Web Locks 재발급 한 번을 처음부터 제시.)

## 결과 (Consequences)
**긍정**
- 웹 탭이 여러 개여도 회전된 refresh token 이 다시 나가지 않아 전 기기 로그아웃이 생기지 않는다.

**부정**
- 잠금 안 재확인 단계를 빼면 문제가 돌아온다 (리포트 「주의할 점」). 그 밖의 비용은 논의 기록 없음.

## 영향 범위 (Scope)
웹 `client/src/lib/accessTokenReissueCoordinator.ts`, `api/client.ts`(apiFetch·SSE 공통 진입점 `resolveAccessTokenAfterUnauthorized`), `authStore.ts`. 서버 `AuthService` 재사용 탐지와 짝.

## 출처 (References)
- GitHub #881 이슈 본문·리포트 댓글 (2026-11-07)
- W4 충돌 검사: [[DEC-0144-per-device-refresh-token-reuse-revoke]] 와 충돌 없음 — DEC-0144 「결과」가 요구한 "웹은 재발급을 동시에 한 번만"을 탭 사이까지 넓힌 것
