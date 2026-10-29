---
type: decision
id: DEC-0130
created: 2026-10-15
reviewed: null
topics: [admin, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0284-admin-accounts-roles-lockout-rate-limit]]"]
---

# DEC-0130: 관리자 계정은 `admin_account` 테이블(ADMIN/VIEWER), yml 기본 계정은 시드·폴백으로 유지, 로그인 잠금과 인메모리 요청 제한

## 문제 정의 (Context)
관리자는 yml 단일 계정뿐이었고 로그인 잠금·rate limit이 없었다 (GitHub #478).

## 결정 (Decision)
- 관리자 계정을 `admin_account` 테이블에 둔다. 역할은 ADMIN(전부, 계정 관리)과 VIEWER(GET만, 변경은 403 `ADMIN_WRITE_FORBIDDEN`).
- yml 기본 계정은 기동 시 `AdminAccountSeeder`가 테이블에 만들거나 동기화하고, 비밀번호는 항상 yml 해시로 검증. 계정 행이 없거나 DB 조회가 실패해도 yml 아이디면 ADMIN으로 로그인(폴백).
- 로그인 5회 연속 실패 시 15분 잠금(기본 계정 포함).
- 회원 API 요청 제한은 인메모리 고정 창, 초과 시 429 `RATE_LIMITED`. 한도: 로그인 IP 분당 20, 재발급 IP 분당 60, 선택지 생성 회원 분당 30, `/api/ai/**` 회원 분당 20, SQL 실행 회원 분당 60.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 계정별 역할 분리, 무차별 로그인 시도 차단, DB 장애 시에도 기본 계정 로그인 유지.

**부정**
- 기본 계정도 잠길 수 있다(해제: 다른 ADMIN 또는 DB 직접 수정).
- 요청 제한은 서버 한 대 기준 인메모리라 Blue-Green 전환 시 카운터가 초기화된다.

## 영향 범위 (Scope)
`AdminUserDetailsService`, `AdminSecurityConfig`, `AdminAccountSeeder`, `/admin/accounts`, 마이그레이션 `V0_10_10`, 회원 API 요청 제한 필터.

## 출처 (References)
- GitHub #478 이슈 본문, 구현 보고서 댓글(2026-10-15)
- [[ISS-0284-admin-accounts-roles-lockout-rate-limit]]
