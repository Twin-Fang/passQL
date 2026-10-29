---
type: completion-report
id: ISS-0001
created: 2026-10-08
topics: [admin, security]
status: resolved
resolves: "[[ISS-0001-admin-fetch-csrf-header-missing]]"
related: ["[[DEC-0008-admin-csrf-common-fetch-wrapper]]"]
source: "https://github.com/Twin-Fang/passQL/issues/391"
---

# ISS-0001 완료 리포트: 관리자 공통 fetch 래퍼가 CSRF 헤더를 자동 부착

GitHub #391 완료 댓글 기준 (PR #407, 운영 v0.0.247). `## 개요` 형식 리포트는 없음.

## 해결 방법
`admin/layout.html`의 공통 fetch 래퍼가 같은 출처의 GET/HEAD 외 요청에 `_csrf_header` 토큰을 자동으로 붙인다. 화면별 코드 변경 없이 18곳 일괄 해결. `choice-set-detail.html`은 실패 시 상태 코드를 알림으로 표시.

## 근본 원인 (확정)
헤더 부착이 화면마다 흩어져 있었고 공통 지점이 없었다.

## 재발 방지
새 관리자 화면은 공통 래퍼를 거치면 헤더가 자동으로 붙는다. 운영 실측(2026-10-08): 래퍼 경유 요청은 CSRF 필터를 통과(없는 경로 404, 깨진 JSON 400), 헤더 없는 XHR은 여전히 403 — 보호는 유지. 관리자 21개 화면 순회 콘솔 오류 0건(`/admin/sandbox` 404는 #410).

## 교훈
(원본에 없음, 볼트 정리) 관리자 화면에서 403이 나면 CSRF 헤더 경로(공통 래퍼를 우회한 직접 XHR/fetch인지)부터 본다.
