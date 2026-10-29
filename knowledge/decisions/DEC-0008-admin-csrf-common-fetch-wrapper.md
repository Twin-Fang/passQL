---
type: decision
id: DEC-0008
created: 2026-10-08
reviewed: null
topics: [admin, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0001-admin-fetch-csrf-header-missing]]"]
---

# DEC-0008: 관리자 CSRF 헤더는 화면별이 아니라 `layout.html` 공통 fetch 래퍼에서 붙인다

## 문제 정의 (Context)
관리자 체인은 CSRF 보호가 켜져 있는데 화면 18곳의 fetch가 헤더를 보내지 않아 상태 변경이 403으로 실패했다. #283에서는 `legal.html` 한 화면만 고쳤다 (GitHub #391).

## 결정 (Decision)
`admin/layout.html`의 공통 fetch 래퍼가 같은 출처의 GET/HEAD 외 요청에 `_csrf_header` 토큰을 자동으로 붙인다. CSRF 보호 자체는 유지한다.

## 검토한 대안 (Alternatives)
논의 기록 없음. (참고: 이전 #283은 `legal.html` 한 화면만 고쳤고, 이번 수정은 "화면별 코드 변경 없이 18곳 일괄 해결"이라고 적었다.)

## 결과 (Consequences)
**긍정**
- 18곳 일괄 해결, 새 관리자 화면도 래퍼를 거치면 자동 적용.

**부정**
- 래퍼를 우회한 직접 XHR은 여전히 403 (의도된 보호).

## 영향 범위 (Scope)
`admin/layout.html`, 관리자 Thymeleaf 화면 전체, `static/js/admin/question-import-export.js`.

## 출처 (References)
- GitHub #391 완료 댓글(PR #407, v0.0.247), 운영 실측 댓글(2026-10-08)
- [[ISS-0001-admin-fetch-csrf-header-missing]]
