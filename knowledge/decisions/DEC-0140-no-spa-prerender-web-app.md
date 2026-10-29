---
type: decision
id: DEC-0140
created: 2026-10-16
reviewed: null
topics: [store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0310-sqld-seo-intro-site-revamp]]", "[[ISS-0310-sqld-seo-intro-site-revamp-report]]"]
---

# DEC-0140: 웹 앱은 SPA 사전 렌더링을 하지 않고 `index.html` 정적 태그로만 검색 노출을 맞춘다

## 문제 정의 (Context)
웹 앱(passql.vercel.app)의 제목·설명에 SQLD·SQLP가 없고 sitemap·canonical이 없었다 (GitHub #505).

## 결정 (Decision)
웹 앱 SPA 사전 렌더링과 다국어 페이지는 하지 않는다. `client/index.html`의 제목·설명·OG·canonical·JSON-LD와 sitemap·robots로 처리한다.

## 검토한 대안 (Alternatives)
- SPA 사전 렌더링: 하지 않음. 원본 이유 — 로그인 뒤 화면은 색인 대상이 아니고, 색인되는 첫 화면은 `index.html`의 정적 태그만으로 충분하다.
- 다국어 페이지: 하지 않음 (이유는 원본에 없음).

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`client/index.html`, `client/public/sitemap.xml`, `robots.txt`.

## 출처 (References)
- GitHub #505 이슈 본문 "하지 않는 것", 보고서 "왜 이렇게 했나" (2026-10-16)
- [[ISS-0310-sqld-seo-intro-site-revamp]]
