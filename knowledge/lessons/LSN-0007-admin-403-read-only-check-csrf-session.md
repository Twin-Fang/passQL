---
type: lesson
id: LSN-0007
created: 2026-11-16
reviewed: null
topics: [admin, security]
trigger: "관리자 변경 요청(스크립트·일괄 작업 포함)이 403 \"조회 전용 관리자는 변경할 수 없습니다\"(ADMIN_WRITE_FORBIDDEN)로 실패할 때"
status: active
source: "ISS-0540 (2026-11-16 #1132 작업 세션)"
supersedes: null
superseded_by: null
related: ["[[ISS-0540-past-exam-figure-erd-generator]]", "[[DEC-0008-admin-csrf-common-fetch-wrapper]]"]
---

# LSN-0007: 관리자 403 "조회 전용"은 계정 권한보다 세션 만료·CSRF 헤더 누락을 먼저 의심한다

## 규칙
관리자 변경 요청이 403 `ADMIN_WRITE_FORBIDDEN`("조회 전용 관리자는 변경할 수 없습니다")으로 실패하면 계정 역할을 바꾸려 하지 말고, (1) 세션이 살아 있는지(다시 로그인), (2) 요청에 `meta[name=_csrf]` 값을 `meta[name=_csrf_header]` 이름의 헤더로 보냈는지부터 확인한다.

## Why
- #1132 운영 반영 중 관리자 일괄 작업이 세션 만료 뒤 이 403 으로 실패해 조회 전용 계정 문제처럼 보였다(작업 세션 전달, 보고서에는 기록 없음).
- 코드 근거: 관리자 체인(`AdminSecurityConfig`)은 CSRF 를 켜 두고(세션 저장) 모든 `AccessDeniedException` 을 `AdminAccessDeniedHandler` 가 받아 GET 이 아닌 요청에 `ADMIN_WRITE_FORBIDDEN` 을 돌려준다. CSRF 토큰 누락·불일치(세션 만료로 토큰이 사라진 경우 포함)도 같은 메시지가 된다.
- 화면 fetch 는 공통 래퍼가 헤더를 붙이지만([[DEC-0008-admin-csrf-common-fetch-wrapper]]), 래퍼를 거치지 않는 스크립트 요청은 직접 붙여야 한다.

## How to apply
- 관리자 API 일괄 작업 스크립트는 시작 전에 로그인하고 CSRF 토큰을 읽어 매 변경 요청 헤더에 넣는다. 오래 걸리는 작업은 403 을 만나면 다시 로그인·토큰 재조회 후 실패 건만 재시도한다.
