---
type: completion-report
id: ISS-0235
created: 2026-10-07
topics: [admin]
status: resolved
resolves: "[[ISS-0235-admin-login-page-cleanup]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/402"
---

# ISS-0235 완료 리포트: `_csrf` 1개, `lucide@1.52.0` 고정, 좌우 여백, 실패 시 아이디 유지

GitHub #402 완료 댓글 기준 (PR #407, 운영 v0.0.247). `## 개요` 형식 리포트는 없음.

## 해결 방법
- 중복 `_csrf` 입력 제거, lucide 버전 고정(`lucide@1.52.0`), 로그인 화면 좌우 여백(`body px-4`).
- 실패 후 아이디 유지는 탭 세션(sessionStorage)에만 잠깐 보관.

## 근본 원인 (확정)
이슈 본문 기준.

## 재발 방지
운영 HTML 확인: `_csrf input 수: 1`, `lucide: lucide@1.52.0`, `body px-4: 1`. 후속(별도 승인 필요): 운영용 빌드 CSS 전환, 문제 등록 화면 3종 정리.

## 교훈
(원본에 없음, 볼트 정리) CDN 스크립트는 `@latest` 대신 정확한 버전을 고정한다.
