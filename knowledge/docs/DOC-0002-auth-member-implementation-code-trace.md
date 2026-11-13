---
type: doc
id: DOC-0002
doc_type: design
authority: internal
created: 2026-11-13
reviewed: null
source: "https://github.com/Twin-Fang/passQL/tree/118159a8"
topics: [auth-member]
topics_ref: [security, notification]
decisions: []
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0080-firebase-oauth-own-jwt-no-anonymous]]", "[[DEC-0095-account-deletion-anonymize-soft-delete]]", "[[DEC-0126-suspended-member-common-filter]]", "[[DEC-0143-server-side-social-unlink-on-withdraw]]", "[[DEC-0144-per-device-refresh-token-reuse-revoke]]", "[[DEC-0269-web-reissue-single-across-tabs]]", "[[DEC-0270-reissue-logout-only-on-session-end]]", "[[DOC-0001-billing-implementation-code-trace]]"]
---

# DOC-0002: 로그인·회원가입·탈퇴 구현 코드 추적 — 서버·앱·웹

## 요약
2026-11-13 main(`118159a8`, v1.120.0) 코드를 직접 따라가 정리한 인증·회원 구현 지도다. 소셜 제공자 토큰(또는 인가 코드)을 서버가 검증하고, 처음 보는 제공자 키면 그 자리에서 가입시킨 뒤 자체 JWT(액세스 1시간, 리프레시 14일)를 발급한다. 리프레시 토큰은 Redis에 기기별로 저장하고 재발급 때마다 회전한다. 탈퇴는 개인정보를 즉시 비우는 익명화 + 소프트 삭제이고, 제공자 연결 해제는 커밋 뒤 비동기로 한다. 코드가 바뀌면 이 문서는 낡으므로, 인용 전에 파일이 아직 있는지 확인한다.

## 핵심 내용 · 논점

### 스택별 역할
| 스택 | 역할 | 주요 위치 |
|---|---|---|
| 서버 | 제공자 토큰 검증, 가입, JWT 발급·재발급·폐기, 탈퇴 익명화, 제재 차단 | `PQL-Domain-Member/.../auth/application/`(`AuthService`, `AuthorizationCodeLoginService`, `MemberSignUpService`, `SocialProfileSyncService`, `SocialUnlinkService`), `.../auth/infrastructure/`(`jwt/JwtTokenProvider`, `social/strategy/*LoginStrategy`), `.../auth/repository/RefreshTokenRepository`, `.../service/MemberService`, `PQL-Web/.../AuthController`·`MemberController`·`config/SuspendedMemberBlockingFilter` |
| 앱 | 제공자 SDK 로그인, 서버 로그인, 보안 저장소 세션, 401 재발급, 탈퇴 재인증 | `app/lib/core/auth/`(`multi_provider_social_sign_in`, `firebase_social_sign_in`, `kakao_`·`naver_`·`github_social_sign_in`, `auth_interceptor`, `token_store`, `install_guard`), `presentation/providers/auth_provider.dart` |
| 웹 | Firebase 토큰 로그인과 카카오·네이버·GitHub 인가 코드 로그인 | `client/src/pages/Login.tsx`, `AuthCallback.tsx`, `api/auth` |

### 로그인 진입점 2개
- `POST /api/auth/login` {`authProvider`, `idToken`} > `AuthService.login`. 코드 전용 제공자(`CODE_ONLY_PROVIDERS` = GitHub)는 400 `UNSUPPORTED_AUTH_PROVIDER`.
- `POST /api/auth/login/code` > `AuthorizationCodeLoginService.login`(코드 > 제공자 토큰 교환, GitHub는 PKCE `codeVerifier` 선택) > `AuthService.loginWithExchangedTokens`. 카카오·네이버·GitHub 웹 로그인과 GitHub 앱 로그인이 쓴다.
- `GET /api/auth/social-config`: 제공자별 사용 여부와 공개 client ID(secret 제외).
- 제공자 선택은 `SocialLoginStrategyConfig`가 `AuthProvider`별 전략 맵으로 묶는다. 전략 6개: `FirebaseLoginStrategy`(Google·Apple), `GoogleLoginStrategy`, `AppleLoginStrategy`, `KakaoLoginStrategy`, `NaverLoginStrategy`, `GithubLoginStrategy`.

### 로그인·가입 처리 순서 (`AuthService`)
1. 메서드 전체가 `Propagation.NOT_SUPPORTED`: 제공자 API 호출(최대 5초 x 2) 동안 DB 커넥션을 잡지 않는다.
2. `verifyIssuedForThisApp`(이 앱용으로 발급된 토큰인지) > `fetchSocialProfile`(ID·이메일·이미지).
3. `findByAuthProviderAndProviderUserIdAndIsDeletedFalse`로 기존 회원 조회.
4. 없으면 `registerNewMember`: 닉네임 생성(`NicknameGenerator.generateUnique`) > `Member.signUp` > `MemberSignUpService.saveInNewTransaction`. 유니크 충돌이면 같은 제공자 키 회원을 다시 찾아 동시 가입이면 그 회원을, 아니면 닉네임 충돌로 보고 최대 3회 재시도(`NICKNAME_GENERATION_FAILED`).
5. 기존 회원이면 이메일·프로필 이미지가 바뀌었을 때만 `SocialProfileSyncService`로 저장(실패해도 로그인 유지).
6. `MemberSocialCredentialService.saveForUnlink`: 탈퇴 때 연결 해제에 쓸 자격 저장(실패해도 로그인 유지).
7. `issueTokens`: 새 기기 ID(`tokenId`, UUID) > 액세스·리프레시 발급 > `RefreshTokenRepository.save`.
8. 응답 `LoginResult`에 `isNewMember` 포함. 앱 온보딩 분기는 이 값을 쓴다.

### 토큰 재발급·로그아웃
- `POST /api/auth/reissue` > `reissueTokens`: 서명 검증 > 저장값과 같을 때만 원자적 삭제(Redis 스크립트 `COMPARE_AND_DELETE_DEVICE_TOKEN`) > 회원 확인 > 새 기기 키로 재발급.
- 삭제 실패 + 기기 목록에도 없는 `tokenId`면 회전된 토큰 재사용(탈취 의심)으로 보고 `deleteAllByMemberUuid`로 그 회원 세션 전체 폐기 > 401 `INVALID_TOKEN`.
- 옛 단일 키 형식(`isLegacyFormat`)은 `deleteLegacyIfMatches`로 호환.
- `POST /api/auth/logout`: 만료 토큰도 받아 그 기기 키만 지운다(다른 기기 세션 유지).
- 요청 인증: `JwtAuthenticationFilter`가 액세스 토큰을 읽어 `SecurityContext`를 채우고 로그에 회원 UUID 앞 8자리를 붙인다. 유효하지 않으면 비우고 넘기며, 401은 `SecurityConfig`가 낸다. 제재 회원 403 `MEMBER_SUSPENDED`는 `SuspendedMemberBlockingFilter`.
- 만료 시간: `application-prod.yml` 액세스 `1h`, 리프레시 `14d`.

### 앱 로그인·세션
1. `AuthNotifier.signIn(provider)` > `MultiProviderSocialSignIn.fetchCredential`: Google·Apple은 Firebase ID 토큰, 카카오·네이버는 SDK 액세스 토큰(`SocialTokenCredential`), GitHub은 인증 브라우저 PKCE 인가 코드(`SocialAuthorizationCodeCredential`).
2. 재료 종류로 `/auth/login` 또는 `/auth/login/code` > `TokenStore.save`(Keychain·Keystore, 메모리 캐시) > `RecentLoginProviderStore.save`(로그인 화면 "최근 로그인").
3. `AuthInterceptor`: 모든 요청에 Bearer 부착, 401이면 재발급 1회(동시 401도 재발급은 한 번 공유) 후 재시도. 재발급까지 실패하면 `SessionExpirySignal`로 인증 상태가 로그아웃된다.
4. `MemberSuspensionInterceptor`가 403 `MEMBER_SUSPENDED`를 `MemberSuspensionSignal`로 알리면 `endSessionBySuspension`(서버 토큰 폐기 생략).
5. `install_guard.resetSecureStorageOnFreshInstall`: iOS 키체인은 앱 삭제 뒤에도 남아 재설치 시 이전 계정이 살아나므로 첫 실행에 비운다.

### 탈퇴
- 앱 `AuthNotifier.withdraw`: 제공자·제공자 회원 식별자 확인(`/members/me`) > `revokeAccessForWithdrawal`(Apple 재인증·revoke, Google 계정 대조, 취소하면 중단) > 푸시 기기 삭제 요청 > `DELETE /api/members/me` > `disconnectAfterWithdrawal`(최선) > 세션·최근 로그인·SDK 정리 > `AppLogger.clear`(성공·실패 공통).
- 서버 `MemberService.withdraw` > `anonymizeAndWithdraw`: `MemberWithdrawnEvent` 발행(익명화 전 제공자 키) > 상태 `WITHDRAWN`, 닉네임 `탈퇴회원_{UUID 짧은 형식}`, 이메일·이미지 비움, `providerUserId = withdrawn:{uuid}` > `softDelete(사유)` > 리프레시 토큰 전부·푸시 토큰 전부 삭제.
- 관리자 탈퇴 `withdrawByAdmin`은 같은 처리 + 사유 `ADMIN_WITHDRAW` + 감사 로그.
- 커밋 뒤 리스너 3개: `SocialUnlinkService`(제공자 연결 해제 > 저장 자격 삭제, 전용 실행기 비동기, 실패는 로그만), `FeedbackWithdrawalCleanupListener`(의견 첨부 삭제), `CommunityWithdrawalCleanupListener`(커뮤니티 정리).
- 풀이 기록은 통계용으로 남지만 제공자 키가 바뀌어 같은 계정 재로그인은 새 회원 가입이 된다.

## 추출된 결정
없음. 이미 구현된 내용을 지도로 옮긴 문서라 새 결정은 만들지 않았다. 관련 결정은 `related`에 연결했다.

W4 대조(구현 vs 활성 결정): DEC-0080(자체 JWT, 익명 회원 없음), DEC-0095(탈퇴 익명화·소프트 삭제·재로그인은 새 회원), DEC-0126(제재 차단 공통 필터), DEC-0143(서버 연결 해제), DEC-0144(기기별 리프레시·재사용 시 전체 폐기)와 코드가 일치했다. 충돌 없음. 결정 본문은 읽지 않고 클러스터 한 줄 요약과 대조했다. 웹 재발급(DEC-0269·DEC-0270)은 웹 코드를 따라가지 않아 대조하지 않았다.

## 열린 질문
- **액세스 토큰 잔여 유효**: 탈퇴 뒤 액세스 토큰은 만료(최대 1시간)까지 서명상 유효하다. 이후 회원 조회가 `MEMBER_NOT_FOUND`로 거절된다는 것은 `MemberService.withdraw` 주석 기준이고, 모든 API가 회원 조회를 거치는지는 확인하지 않았다.
- **연결 해제 실패**: `SocialUnlinkService`는 실패를 로그로만 남긴다. 저장 자격이 없던 회원(기능 배포 전 마지막 로그인)은 해제를 건너뛴다.
- **전략 중복**: Google·Apple은 `FirebaseLoginStrategy`와 별도 `GoogleLoginStrategy`·`AppleLoginStrategy`가 함께 있다. 어느 클라이언트가 어느 경로를 쓰는지는 이번에 따라가지 않았다.

## 원본 참조
- 코드 기준: main `118159a8` (2026-11-13, v1.120.0). 원문은 코드 자체이며 별도 텍스트 원본은 없다.
