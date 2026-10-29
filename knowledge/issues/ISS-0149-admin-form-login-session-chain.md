---
type: issue
id: ISS-0149
created: 2026-04-22
topics: [admin, security]
symptoms: ["/admin/** permitAll", "관리자 페이지 인증 없음", SecurityConfig, "Stateless 세션", "관리자 폼 로그인", AdminUserDetailsService]
root_cause: "`SecurityConfig`에서 `/admin/**`이 `permitAll()`이고, JWT 무상태 설정뿐이라 관리자 폼 로그인용 세션 체인이 없음"
status: resolved
resolution: "[[ISS-0149-admin-form-login-session-chain-report]]"
related: ["[[DEC-0081-admin-session-chain-yml-account]]"]
source: "https://github.com/Twin-Fang/passQL/issues/275"
---

# ISS-0149: Thymeleaf 관리자 페이지에 누구나 인증 없이 접근 가능

GitHub #275 (원본: 이슈 본문과 댓글).

## 증상
`server/PQL-Web/src/main/java/com/passql/web/config/SecurityConfig.java`에서 `/admin/**`이 `permitAll()`로 열려 있다. 현재 설정은 JWT 무상태 세션이라 관리자 폼 로그인용 세션 기반 filter chain이 따로 필요하고, Member 엔티티에는 관리자 ID/PW 컬럼이 없다.

## 재현 조건
비로그인 상태로 `/admin/**` 접속.

## 조사 기록
- 2026-04-22: 제안 — `securityMatcher`로 `/admin/**` 전용 체인 분리(`@Order`로 우선순위), 계정 저장은 `member` `role = ADMIN` 행에 `admin_password`(BCrypt) 컬럼 추가 또는 `admin_account` 테이블 신설, `AdminUserDetailsService`, `GET/POST /admin/login`, `POST /admin/logout`, 초기 계정은 Flyway seed 또는 `CommandLineRunner`.

## 근본 원인
관리자 경로용 인증 체인 미구현.
