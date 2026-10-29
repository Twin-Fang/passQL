---
type: completion-report
id: ISS-0146
created: 2026-04-18
topics: [auth-member, security]
status: resolved
resolves: "[[ISS-0146-oauth-jwt-auth-system]]"
related: ["[[DEC-0080-firebase-oauth-own-jwt-no-anonymous]]"]
source: "https://github.com/Twin-Fang/passQL/issues/271"
---

# ISS-0146 완료 리포트: Firebase 기반 OAuth 5종 + 자체 JWT, 익명 회원 제거

GitHub #271 `## 개요` 리포트 댓글(2026-04-18) 기준.

## 해결 방법
- 공통: `ErrorCode.java`에 `EXPIRED_FIREBASE_TOKEN`, `INVALID_FIREBASE_TOKEN`, `FIREBASE_SERVER_ERROR`, `ACCESS_TOKEN_EXPIRED`, `REFRESH_TOKEN_EXPIRED`, `INVALID_TOKEN`, `UNAUTHENTICATED_REQUEST`, `UNSUPPORTED_AUTH_PROVIDER`.
- 회원 도메인: `AuthProvider`에서 `ANONYMOUS` 제거, `Member.createAnonymous()`·`createTestAccount()` 삭제 → `signUp(providerUserId, authProvider, email, emailVerified, nickname)`, `MemberService.register()` 삭제. 의존성 `firebase-admin:9.3.0`, `jjwt-api/impl/jackson:0.11.5`.
- JWT: `Tokens`, `JwtProperties`(`prefix = "jwt"`), `JwtTokenProvider`(만료 토큰 silent 파싱).
- 전략 패턴: `FirebaseLoginStrategy`(Google/Apple, `verifyIdToken()`), `KakaoLoginStrategy`·`NaverLoginStrategy`·`GithubLoginStrategy`(각 provider REST API 직접 호출), `SocialLoginStrategyConfig`가 `Map<AuthProvider, SocialLoginStrategy>` Bean.
- `RefreshTokenRepository`: Redis `refresh_token:{memberUuid}`. `AuthService`: `login()`/`reissueTokens()`/`logout()`.
- `JwtAuthenticationFilter`(`OncePerRequestFilter`, `UsernamePasswordAuthenticationFilter` 앞), `LoginMember` `record(UUID memberUuid, MemberRole role)`, `@AuthMember` + `LoginMemberArgumentResolver`.
- 웹: `FirebaseConfig`(`@Profile("!test")`), `SecurityConfig`(`/api/auth/**` permitAll, `/api/members/**` authenticated, `/api/admin/**` hasRole ADMIN), `AuthController` `POST /api/auth/login`(200/201)·`reissue`·`logout`, `MemberController`를 `@AuthMember LoginMember`로 전환.
- 마이그레이션 `V0_0_155__auth_cleanup.sql`: ANONYMOUS 회원 삭제. 자식 테이블 4개가 모두 `NO ACTION` FK이고 prod에 참조 데이터(submission 123건, member_suspend_history 2건)가 있어 `member_suspend_history` → `execution_log` → `submission` → `quiz_session` 순으로 먼저 삭제.
- CI/CD: `PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`이 Secret `FIREBASE_SERVICE_ACCOUNT_PROD_JSON`으로 `firebase-service-account-prod.json` 생성, `PROJECT-COMMON-SYNOLOGY-SECRET-FILE-UPLOAD.yaml` 백업 항목, `.gitignore`에 `**/firebase-service-account*.json`, `firebase-service-account-dev.json.example`.

## 근본 원인 (확정)
인증 체계 미구현.

## 재발 방지
리포트 주의사항:
- Firebase JSON 미발급 — 발급 전까지 dev/prod 기동 시 오류(후속 GitHub #272).
- `APPLICATION_PROD_YML` Secret에 `jwt` 블록과 `firebase.key-path: classpath:firebase-service-account-prod.json` 추가 필요.
- `LoginMember`, `JwtAuthenticationFilter`는 설계 문서의 `PQL-Common/security`가 아니라 `PQL-Domain-Member/auth/presentation/security`에 배치 — `PQL-Common`이 `PQL-Domain-Member`를 의존하지 않는 구조라서.

## 교훈
(원본에 없음, 볼트 정리) 회원 삭제 마이그레이션은 `NO ACTION` FK 자식 테이블부터 순서대로 지운다.
