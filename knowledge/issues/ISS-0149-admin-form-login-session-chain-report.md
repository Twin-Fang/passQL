---
type: completion-report
id: ISS-0149
created: 2026-04-22
topics: [admin, security]
status: resolved
resolves: "[[ISS-0149-admin-form-login-session-chain]]"
related: ["[[DEC-0081-admin-session-chain-yml-account]]"]
source: "https://github.com/Twin-Fang/passQL/issues/275"
---

# ISS-0149 완료 리포트: `/admin/**` 전용 세션 체인과 yml 기반 단일 관리자 계정

GitHub #275 "구현 완료" 댓글과 "정상 작동 확인" 댓글(2026-04-22, PR #276) 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
- `AdminSecurityConfig`(`@Order(1)`): `/admin/**` 전용 세션 기반 filter chain.
- `SecurityConfig`(`@Order(2)`): `/api/**` JWT 체인과 완전 분리.
- `AdminUserDetailsService`: DB 없이 yml 환경변수 기반 단일 관리자 계정 인증.
- `AdminLoginController` + `login.html`(로고, 에러/로그아웃 메시지, CSRF), `layout.html` navbar 로그아웃 버튼.
- 경로: `GET /admin/login`, `POST /admin/login`(성공 시 `/admin` 리다이렉트), `POST /admin/logout`(세션 무효화 + `/admin/login?logout=true`).

## 근본 원인 (확정)
관리자 경로 인증 체인 미구현.

## 재발 방지
댓글 경고: 운영 배포 전 `ADMIN_PASSWORD_HASH` 환경변수를 강한 비밀번호의 BCrypt 해시로 교체할 것.

## 교훈
(원본에 없음, 볼트 정리) 관리자 체인에 CSRF가 켜진 뒤의 403 문제는 이후 [[ISS-0001-admin-fetch-csrf-header-missing]]에서 다뤄졌다.
