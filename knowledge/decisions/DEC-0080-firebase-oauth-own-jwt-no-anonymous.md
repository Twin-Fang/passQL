---
type: decision
id: DEC-0080
created: 2026-04-18
reviewed: null
topics: [auth-member, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0146-oauth-jwt-auth-system]]", "[[ISS-0146-oauth-jwt-auth-system-report]]", "[[ISS-0147-firebase-project-and-secrets]]", "[[DEC-0144-per-device-refresh-token-reuse-revoke]]", "[[DEC-0012-nickname-via-suh-random-engine]]"]
---

# DEC-0080: 소셜 로그인 토큰을 서버가 검증해 자체 JWT(AT 1h + RT 14d, Redis)를 발급하고, 익명 회원은 없앤다

## 문제 정의 (Context)
서버에 인증이 없고(`anyRequest().permitAll()`), 회원 식별을 쿼리 파라미터 `memberUuid`에 맡기며, 익명 가입만 가능했다(GitHub #271).

## 결정 (Decision)
- 프론트가 Firebase SDK로 소셜 로그인 후 받은 `idToken`을 `POST /api/auth/login`으로 보내고, 서버가 검증해 자체 JWT를 발급한다.
- provider 5개: Google·Apple은 Firebase Admin SDK `verifyIdToken()`(`FirebaseLoginStrategy`), Kakao·Naver·Github는 각 REST API 직접 검증.
- AccessToken(1h) + RefreshToken(14d) 이중 토큰, RefreshToken은 Redis `refresh_token:{memberUuid}`.
- `MemberRole(USER/ADMIN/SUPER_ADMIN)` 기반 경로별 권한 분리.
- 보호 API의 `memberUuid` 쿼리 파라미터를 `@AuthMember` 토큰 기반으로 전환.
- 익명 회원(`createAnonymous`)과 `POST /api/members/register`는 삭제한다(이슈 본문 "하드리셋"). 기존 ANONYMOUS 데이터는 마이그레이션으로 삭제.

## 검토한 대안 (Alternatives)
논의 기록 없음. (기존 익명 회원 방식은 이 결정으로 "완전히 제거"됐다고 리포트가 적었다. 대체 이유는 이슈 본문의 현재 문제점 외에 적혀 있지 않다.)

## 결과 (Consequences)
**긍정**
- 리포트: `Map<AuthProvider, SocialLoginStrategy>`로 provider별 전략을 O(1) 조회.

**부정**
- Firebase 서비스 계정 JSON과 `APPLICATION_PROD_YML` Secret 갱신 전까지 dev/prod 기동 오류(리포트 주의사항, 후속 GitHub #272).
- 익명 회원 데이터는 하드리셋으로 사라진다.

## 영향 범위 (Scope)
`PQL-Domain-Member`(auth 전략·JWT·Redis 저장소·`Member.signUp()`), `PQL-Web`(`SecurityConfig`, `FirebaseConfig`, `AuthController`, `MemberController`), `PQL-Common` `ErrorCode`, `V0_0_155__auth_cleanup.sql`, CI/CD Secret 처리.

## 출처 (References)
- GitHub #271 이슈 본문, 리포트 댓글(2026-04-18), 설계 문서 `docs/superpowers/specs/2026-04-18-auth-design.md`
