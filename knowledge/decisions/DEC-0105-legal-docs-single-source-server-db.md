---
type: decision
id: DEC-0105
created: 2026-10-08
reviewed: null
topics: [store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0236-legal-docs-three-sources-mismatch]]", "[[ISS-0236-legal-docs-three-sources-mismatch-report]]"]
---

# DEC-0105: 약관·개인정보처리방침 원본은 서버 DB(관리자 `/admin/legal`) 하나

GitHub #403 (원본: 이슈 본문과 완료 댓글).

## 문제 정의 (Context)
약관·개인정보처리방침 원본이 서버 `/api/meta/legal`, Vercel `/legal/*.html`, gh-pages 세 곳에 있었고 내용이 이미 달랐다. 이슈는 "원본을 하나(서버 API 또는 정적 페이지)로 정하고 나머지는 그곳을 가리키게 한다"를 제안했다.

## 결정 (Decision)
원본 = 서버 DB(관리자 `/admin/legal`) 하나로 결정. Vercel `/legal/*.html`은 열릴 때 `GET /api/meta/legal/{type}` 본문으로 렌더(HTML 이스케이프)하고, 실패 시 사본 + 다시 시도.

## 검토한 대안 (Alternatives)
- 정적 페이지를 원본으로: 이슈 본문이 후보로 적었다. 서버 DB를 고른 이유로 완료 댓글은 "앱(로그인·설정)과 웹 모달이 이미 `GET /api/meta/legal/{type}`만 쓰고, 세 곳 본문 조항도 같았다"고 적었다.

## 결과 (Consequences)
**긍정**
- 문구 수정이 관리자 화면 한 곳에서 끝난다 (운영 DB 문구 수정으로 반영 확인).

**부정 / 조건**
- 정적 페이지는 API가 실패하면 사본을 보여 준다 — 사본은 DB와 다를 수 있다. (원본에 없음, 볼트 정리)
- 스토어 콘솔에 등록된 약관 URL은 직접 확인 필요 (원본 「남은 것」).

## 영향 범위 (Scope)
서버 `/api/meta/legal/{type}`·관리자 `/admin/legal`, 웹 `/legal/*.html`·로그인 약관 모달, 앱 로그인·설정, gh-pages `delete-account.html`.

## 출처 (References)
- GitHub #403 이슈 본문 「해결 방안」, 완료 댓글(PR #426, gh-pages #427, 2026-10-08)
- [[ISS-0236-legal-docs-three-sources-mismatch]]
