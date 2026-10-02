# 앱 서버 JWT 인증 전환 설계 (#327)

승인: 2026-10-02 (대화에서 설계안 승인, 앱 ID `kr.suhsaechan.passql` 확정)

## 배경

- 서버는 `Authorization: Bearer` JWT만 인증으로 인정한다. 공개 경로는 `/api/auth/**`, `GET /api/meta/**` 뿐이다.
- 앱은 `X-Member-UUID` 헤더, `memberUuid` 쿼리, `/members/register`(서버에 없음)를 쓰고 있어, 운영 서버에서 인증이 필요한 API가 401이다. (2026-10-02 `/api/progress?memberUuid=...` 호출로 확인)

## 서버 계약 (변경 없음)

| 엔드포인트 | 요청 | 응답 |
|---|---|---|
| `POST /auth/login` | `authProvider`(GOOGLE/APPLE), `idToken` | `accessToken`, `refreshToken`, `isNewMember`, `memberUuid`, `nickname` |
| `POST /auth/reissue` | `refreshToken` | `accessToken`, `refreshToken` (회전) |
| `POST /auth/logout` | `refreshToken` | 204 |

## 구조

- `TokenStore`: 세션을 secure storage(Keychain/Keystore)에 저장. 요청마다 읽히므로 메모리 캐시.
- `AuthApi`: `/auth/*` 호출 전용. 인증 인터셉터가 없는 Dio를 쓴다(재발급 요청의 순환 방지).
- `AuthInterceptor`: Bearer 부착, 401이면 재발급 후 1회 재시도. 동시 401은 재발급 1회로 합친다. 재발급 실패 시 세션 삭제 후 로그아웃 상태로 전환.
- `AuthNotifier`: 로그인 세션 상태. 앱 시작 시 저장된 세션을 읽는다.
- `SocialSignIn`: 소셜 제공자에서 idToken을 받는 추상화. Firebase/Google/Apple SDK 설정 전까지는 `UnconfiguredSocialSignIn`.
- 라우터: `authenticated` 값으로 redirect. 미로그인이면 `/login`, 로그인 상태에서 `/login`이면 홈.

## 결정

- 기존 UUID 회원은 마이그레이션하지 않는다. 서버에 UUID 인증이 없어 이관 수단이 없고, 앱은 출시 전이다.
- iOS는 소셜 로그인 제공 시 Sign in with Apple이 필수이므로 버튼을 함께 둔다.
- 앱 ID: `kr.suhsaechan.passql` (Android applicationId/namespace, iOS 번들 ID). macOS/Linux/Windows 타깃은 모바일 출시와 무관해 `com.example`을 유지한다.
- `MemberStore`는 `memberUuid` 인자가 정리되는 #328까지 호환용으로 유지한다.

## 이번 범위에서 제외 (후속)

- Firebase 연동: `firebase_core`/`firebase_auth`/`google_sign_in`/`sign_in_with_apple` 추가, `google-services.json`, `GoogleService-Info.plist`, Android SHA-1 등록. Firebase 콘솔 작업이 선행되어야 한다.
- 설정 화면의 로그아웃 버튼 연결, 회원 탈퇴.
- API 호출부의 `memberUuid` 인자 제거(#328).
