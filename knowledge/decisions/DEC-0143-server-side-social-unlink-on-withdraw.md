---
type: decision
id: DEC-0143
created: 2026-10-18
reviewed: null
topics: [auth-member, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0316-social-login-token-unlink-account-switch]]", "[[ISS-0316-social-login-token-unlink-account-switch-report]]"]
---

# DEC-0143: 탈퇴 시 소셜 제공자 연결 해제는 서버가 하고, GitHub·네이버 토큰은 암호화 보관한다

## 문제 정의 (Context)
카카오·네이버·GitHub·Google은 탈퇴해도 제공자 쪽 연결이 남았다. 웹은 Apple revoke도 하지 않았다 (GitHub #516).

## 결정 (Decision)
- 탈퇴 트랜잭션 커밋 뒤 서버가 비동기로 카카오 unlink(Admin 키), GitHub grant 삭제, 네이버 토큰 삭제를 호출한다. 실패해도 탈퇴는 유지하고 로그만 남긴다.
- GitHub·네이버는 로그인 때 받은 토큰을 암호화해 `member_social_credential`에 보관했다가 탈퇴 때 쓰고 삭제한다.
- 앱·웹은 Apple revoke를 하고, 재인증한 계정 uid가 가입 계정과 다르면 중단한다.

## 검토한 대안 (Alternatives)
논의 기록 없음. 원본 이유: 웹과 앱을 모두 커버하려면 한 곳이어야 한다. 카카오는 Admin 키로 `user_id` 기반 unlink가 되지만 GitHub·네이버는 토큰이 필요해 암호화 저장이 불가피했다. uid 대조는 Firebase 세션이 없어 새 팝업에서 다른 계정을 고르면 엉뚱한 토큰을 revoke하게 되기 때문.

## 결과 (Consequences)
**긍정**
- 운영 실측: GitHub·카카오 탈퇴 후 재로그인 시 동의 화면 재등장, 새 회원 가입. 네이버 unlink ok.

**부정**
- 제공자 토큰을 서버에 보관해야 한다.
- 네이버 SDK 직접 로그인 회원은 refresh token이 없어 연결 해제가 실패할 수 있다.

## 영향 범위 (Scope)
서버 탈퇴 흐름, `member_social_credential`, 운영 설정(카카오 `admin-key`), 앱·웹 탈퇴 분기. 탈퇴 시 익명화·소프트 삭제를 정한 기존 결정 DEC-0095 위에 제공자 연결 해제를 더한다.

## 출처 (References)
- GitHub #516 개요 댓글 "왜 이렇게 했는가" (2026-10-18)
- [[ISS-0316-social-login-token-unlink-account-switch]]
