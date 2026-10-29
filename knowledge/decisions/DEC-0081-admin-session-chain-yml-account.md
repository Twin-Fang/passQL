---
type: decision
id: DEC-0081
created: 2026-04-22
reviewed: null
topics: [admin, security]
status: superseded
supersedes: null
superseded_by: DEC-0130
related: ["[[ISS-0149-admin-form-login-session-chain]]", "[[ISS-0149-admin-form-login-session-chain-report]]", "[[DEC-0008-admin-csrf-common-fetch-wrapper]]", "[[DEC-0130-admin-accounts-roles-lockout-rate-limit]]"]
---

# DEC-0081: 관리자 페이지는 `/admin/**` 전용 세션 폼 로그인 체인, 계정은 DB 없이 yml 환경변수의 단일 계정

## 문제 정의 (Context)
`/admin/**`이 `permitAll()`로 열려 있었고, 기존 보안 설정은 앱용 JWT 무상태 체인뿐이었다(GitHub #275).

## 결정 (Decision)
- `AdminSecurityConfig`(`@Order(1)`)가 `/admin/**`를 ID/PW 폼 로그인 + 세션으로 보호하고, `SecurityConfig`(`@Order(2)`)의 `/api/**` JWT 체인과 분리한다.
- 관리자 계정은 DB 없이 yml 환경변수 기반 단일 계정(`AdminUserDetailsService`). 비밀번호는 `ADMIN_PASSWORD_HASH`(BCrypt 해시) 환경변수.

## 검토한 대안 (Alternatives)
- 이슈 본문이 제시한 계정 저장 후보: `member` 테이블 `role = ADMIN` 행에 `admin_password` 컬럼 추가, 또는 `admin_account` 테이블 신설(Flyway). 구현은 두 후보 대신 yml 환경변수 단일 계정을 택했다. 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 관리자는 단일 계정뿐. 운영 배포 전 `ADMIN_PASSWORD_HASH`를 강한 비밀번호의 해시로 교체해야 한다(댓글 경고).

## 영향 범위 (Scope)
`AdminSecurityConfig`, `SecurityConfig`, `AdminUserDetailsService`, `AdminLoginController`, `admin/login.html`, `admin/layout.html`. 관리자 체인의 CSRF 처리는 이후 [[DEC-0008-admin-csrf-common-fetch-wrapper]].

## 출처 (References)
- GitHub #275 이슈 본문, 구현 완료 댓글(2026-04-22, PR #276)
