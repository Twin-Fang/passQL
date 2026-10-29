---
type: completion-report
id: ISS-0284
created: 2026-10-15
topics: [admin, security]
status: resolved
resolves: "[[ISS-0284-admin-accounts-roles-lockout-rate-limit]]"
related: ["[[DEC-0130-admin-accounts-roles-lockout-rate-limit]]"]
source: "https://github.com/Twin-Fang/passQL/issues/478"
---

# ISS-0284 완료 리포트: `admin_account` 테이블, ADMIN/VIEWER 역할, 5회 실패 15분 잠금, 회원 API 요청 제한

GitHub #478 구현 보고서 댓글 기준 (3차 통합 main `c46b9e6`, 0.13.0).

## 해결 방법
- `admin_account` 테이블(마이그레이션 `V0_10_10`).
- 역할 2개: ADMIN(조회·변경 전부, 계정 관리), VIEWER(GET만, 변경 요청은 403 `ADMIN_WRITE_FORBIDDEN`).
- 로그인 5회 연속 실패 시 15분 잠금, 로그인 화면에 잠김·사용 중지 문구.
- `/admin/accounts`(ADMIN만): 추가, 역할·사용 여부, 비밀번호 재설정, 잠금 해제. 기본 계정과 자기 계정은 화면에서 못 바꿈.
- 회원 API 요청 제한(인메모리 고정 창, 초과 시 429 `RATE_LIMITED`): 로그인 IP 분당 20회, 토큰 재발급 IP 분당 60회, 선택지 생성 회원 분당 30회, `/api/ai/**` 회원 분당 20회, SQL 실행 회원 분당 60회.
- 운영 로그인 연속성: 기동 시 `AdminAccountSeeder`가 yml 기본 계정을 `admin_account`에 만들거나 동기화(기본 계정 비밀번호는 항상 yml 해시로 검증). 계정 행이 없거나 DB 조회가 실패해도 yml 아이디면 ADMIN으로 로그인(폴백). `AdminLoginContinuityTest` 6건.
- 검증: 서버 전체 108개 중 107개 통과. 운영 기본 관리자 로그인, 관리자 계정 화면 200·콘솔 오류 0.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
주의(원본):
- 기본 계정도 5회 실패하면 15분 잠긴다. 해제는 다른 ADMIN 계정이 화면에서 하거나 DB에서 `update admin_account set locked_until=null, failed_login_count=0`.
- VIEWER는 POST로 하는 내보내기, 샌드박스 실행, 가져오기 검증도 막힌다.
- 요청 제한은 서버 한 대 기준 인메모리라 Blue-Green 전환 시 카운터가 초기화된다.

## 교훈
(원본에 없음, 볼트 정리) 관리자 로그인이 갑자기 안 되면 15분 잠금 상태인지 먼저 확인한다.
