---
type: completion-report
id: ISS-0316
created: 2026-10-18
topics: [auth-member, security]
status: resolved
resolves: "[[ISS-0316-social-login-token-unlink-account-switch]]"
related: ["[[DEC-0143-server-side-social-unlink-on-withdraw]]", "[[DEC-0144-per-device-refresh-token-reuse-revoke]]"]
source: "https://github.com/Twin-Fang/passQL/issues/516"
---

# ISS-0316 완료 리포트: 토큰 출처 대조, 활성 회원 유니크, 서버 unlink, 기기별 세션, 앱 회원 데이터 재구성

GitHub #516 개요 댓글과 후속 댓글 기준 (2026-10-18).

## 해결 방법
- 서버: GitHub 토큰 직접 로그인 거부(앱·웹 모두 인가 코드). 카카오 `access_token_info`의 `app_id`, 네이버 `nid/verify`의 `client_id`, Firebase 토큰의 `sign_in_provider`를 대조. `(auth_provider, provider_user_id)` 활성 회원 부분 유니크 인덱스(`V1_13_0`), 동시 가입 충돌 시 기존 회원 재조회. 탈퇴 커밋 뒤 비동기 unlink(카카오 Admin 키, GitHub grant 삭제, 네이버 토큰 삭제), GitHub·네이버 토큰은 `member_social_credential`에 암호화 보관. refresh token 기기별(`jti`) 저장, Redis compare-and-delete(Lua) 재발급, 재사용 감지 시 회원 세션 전부 폐기. 로그인 트랜잭션 분할, GitHub PKCE, `/members/me`에 `authProvider`·`providerUserId`, 운영 redirect에서 localhost 제거, 로그 접두사 `[social login]`, `[auth]`, `[social unlink]`.
- 앱: 회원별 데이터를 `currentMemberUuidProvider` 기준으로 재구성. 탈퇴 시 Apple revoke 필수, 재인증 uid가 다르면 중단. `MainActivity`의 `taskAffinity=""` 제거(카카오·GitHub 콜백 액티비티의 `""`는 유지), 취소와 실패 구분, 버튼 라벨 `ExcludeSemantics`.
- 웹: 탈퇴 분기(Apple revoke, Google 토큰 폐기, uid 대조), 세션 정리 일원화, 토큰 재발급 단일 요청, GitHub PKCE.
- 운영 콘솔: 방침·계정 삭제 안내를 실제 동작에 맞게 수정, 네이버 검수 요청 제출.
- 실측: iOS 로그인 5종 성공, GitHub·카카오 탈퇴 후 재로그인 시 새 회원, 네이버 unlink ok, 계정 전환 150프레임에서 이전 데이터 노출 0회. iOS 1.19.0 심사 제출.

## 근본 원인 (확정)
이슈 노트 참조.

## 재발 방지
- 배포 순서: 서버 먼저. 웹·앱이 먼저 나가면 GitHub 로그인(PKCE)과 탈퇴(`authProvider` 의존)가 깨진다.
- 같은 refresh token으로 재발급을 동시에 두 번 보내면 정상 사용자 세션이 전부 끊긴다(웹은 단일 요청으로 수정).
- `taskAffinity=""` 제거로 태스크 가로채기 방어가 약해진다(네이버 SDK 요구).
- 네이버 SDK 직접 로그인 회원은 refresh token이 없어 탈퇴 unlink가 실패할 수 있다(로그만).
- 운영 `application-prod.yml`에 카카오 `app-id`·`admin-key`가 있어야 카카오 SDK 로그인이 동작한다.
- 남은 실기기·외부 심사 확인은 GitHub #537.

## 교훈
(원본에 없음, 볼트 정리) 계정 전환 시 이전 회원 데이터가 보이면 회원별 캐시·provider가 현재 회원 식별자 하나에 묶여 있는지부터 본다.
