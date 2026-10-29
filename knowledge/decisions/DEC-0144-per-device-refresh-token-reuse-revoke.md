---
type: decision
id: DEC-0144
created: 2026-10-18
reviewed: null
topics: [auth-member, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0316-social-login-token-unlink-account-switch]]", "[[ISS-0316-social-login-token-unlink-account-switch-report]]", "[[DEC-0080-firebase-oauth-own-jwt-no-anonymous]]"]
---

# DEC-0144: refresh token은 기기별(`jti`)로 저장하고, 이미 회전된 토큰이 다시 오면 그 회원 세션을 전부 폐기한다

## 문제 정의 (Context)
리프레시 토큰이 회원당 1개라 다른 기기에서 로그인하면 기존 기기가 로그아웃됐고, 로그아웃은 받은 토큰과 저장된 토큰을 대조하지 않았다 (GitHub #516).

## 결정 (Decision)
- refresh token을 기기별(`jti`)로 저장해 다른 기기 로그인이 기존 기기를 끊지 않게 한다.
- 재발급은 Redis compare-and-delete(Lua)로 원자 처리한다.
- 이미 회전된 토큰이 다시 오면 재사용으로 보고 그 회원 세션을 전부 폐기한다.

## 검토한 대안 (Alternatives)
논의 기록 없음. 원본 이유(재사용 감지): 탈취된 refresh token을 공격자가 먼저 회전시키는 경우를 막으려는 것.

## 결과 (Consequences)
**긍정**
- 기기마다 세션이 따로 유지된다.

**부정**
- 앱·웹이 같은 refresh token으로 재발급을 동시에 두 번 보내면 정상 사용자 세션이 전부 끊긴다. 웹은 재발급을 동시에 한 번만 보내도록 고쳤고, 앱 인터셉터는 원래 단일 요청이었다.

## 영향 범위 (Scope)
서버 토큰 저장·재발급·로그아웃, Redis, 웹 토큰 재발급 로직. 기존 결정 DEC-0080은 RefreshToken을 Redis `refresh_token:{memberUuid}`(회원 단위 키)로 적었다.

## 출처 (References)
- GitHub #516 이슈 본문 "세션", 개요 댓글 "핵심 변경"·"왜 이렇게 했는가"·"주의사항" (2026-10-18)
- [[ISS-0316-social-login-token-unlink-account-switch]]
