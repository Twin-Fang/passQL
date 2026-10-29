---
type: completion-report
id: ISS-0226
created: 2026-10-07
topics: [admin]
status: resolved
resolves: "[[ISS-0226-admin-tags-template-missing-500]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/392"
---

# ISS-0226 완료 리포트: `/admin/tags`를 `/admin/concepts`로 리다이렉트

GitHub #392 완료 댓글과 로그인 후 실측 댓글 기준 (PR #407, 운영 v0.0.247). `## 개요` 형식 리포트는 없음.

## 해결 방법
`AdminTagController`가 템플릿 없는 `admin/tags` 대신 태그를 관리하는 `/admin/concepts`로 리다이렉트.

## 근본 원인 (확정)
템플릿 파일 부재.

## 재발 방지
관리자 로그인 후 운영 실측(2026-10-08, v0.0.247): `GET /admin/tags` → 302 → `/admin/concepts` 200, 이전 500 재현 안 됨.

## 교훈
원본에 적혀 있지 않다.
