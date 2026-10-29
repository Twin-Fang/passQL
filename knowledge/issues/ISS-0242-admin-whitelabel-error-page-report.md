---
type: completion-report
id: ISS-0242
created: 2026-10-07
topics: [admin]
status: resolved
resolves: "[[ISS-0242-admin-whitelabel-error-page]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/410"
---

# ISS-0242 완료 리포트: `templates/error.html` 추가

GitHub #410 완료 댓글 기준 (v0.0.248, PR #413). `## 개요` 형식 리포트는 없음.

## 해결 방법
`templates/error.html` 추가 — 상태 코드, 짧은 안내, 관리자 경로면 "관리자 홈으로" 링크.

## 근본 원인 (확정)
오류 템플릿 부재.

## 재발 방지
브라우저 `/admin/__qa_no_such__` → 404 안내 화면. JSON 요청(`Accept: application/json`) → 기존 JSON 응답 유지 확인.

## 교훈
원본에 적혀 있지 않다.
