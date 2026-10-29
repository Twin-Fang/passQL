---
type: cluster
topic: security
created: 2026-10-29
members: 3
status: active
related: []
---

# 클러스터: 보안

## 이 주제는
인증 토큰·CSRF·민감 정보 노출 등 보안 결함과 대책.

## 현재 상태 요약
(2026-10-29) 관리자 CSRF 헤더는 공통 fetch 래퍼가 붙인다 — [[DEC-0008-admin-csrf-common-fetch-wrapper]]. 인증 엔드포인트 본문은 서버 로그에 남기지 않는다([[ISS-0002-auth-response-body-logged-plaintext]]).

## 활성 결정
- [[DEC-0008-admin-csrf-common-fetch-wrapper]] — 관리자 CSRF 공통 래퍼

## 관련 이슈
- [[ISS-0001-admin-fetch-csrf-header-missing]] (resolved)
- [[ISS-0002-auth-response-body-logged-plaintext]] (resolved)
