---
type: issue
id: ISS-0284
created: 2026-10-15
topics: [admin, security]
symptoms: [관리자 단일 계정, yml 관리자 계정, 로그인 잠금 없음, rate limit 없음, AdminUserDetailsService, AdminSecurityConfig]
root_cause: "관리자는 yml 단일 계정뿐이었고, 로그인 실패는 로그만 남을 뿐 잠금이나 요청 제한이 없었다"
status: resolved
resolution: "[[ISS-0284-admin-accounts-roles-lockout-rate-limit-report]]"
related: ["[[DEC-0130-admin-accounts-roles-lockout-rate-limit]]"]
source: "https://github.com/Twin-Fang/passQL/issues/478"
---

# ISS-0284: 관리자 계정이 yml 단일 계정뿐이고 로그인 잠금·요청 제한이 없음

GitHub #478 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- 관리자는 yml의 단일 계정뿐.
- 로그인 실패는 로그만 남고 잠금이나 rate limit이 없음.
- 위치: `server/PQL-Web/.../config/admin/AdminUserDetailsService.java`, `AdminSecurityConfig.java:41`.

## 재현 조건
해당 없음(기능 개선).

## 조사 기록
- 2026-10-15: 제안 — 관리자 계정 테이블과 역할(운영자/조회자), 로그인 연속 실패 잠금, API rate limit.

## 근본 원인
frontmatter `root_cause`와 같음.
