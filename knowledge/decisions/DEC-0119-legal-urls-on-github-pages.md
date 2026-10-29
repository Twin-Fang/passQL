---
type: decision
id: DEC-0119
created: 2026-10-15
reviewed: null
topics: [store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0264-architecture-audit-commonization-refactor]]", "[[ISS-0268-web-brand-color-token-lint]]", "[[ISS-0268-web-brand-color-token-lint-report]]"]
---

# DEC-0119: 약관 공개 URL은 GitHub Pages(twin-fang.github.io/passQL)를 남기고 웹 `/legal/*`은 그쪽으로 리다이렉트

## 문제 정의 (Context)
약관 문서가 웹(`public/legal`)과 GitHub Pages에 사본으로 따로 있었다 (GitHub #458, #462).

## 결정 (Decision)
소유자 결정(2026-10-15): GitHub Pages(twin-fang.github.io/passQL)를 남긴다. 웹 `/legal/*`은 그쪽으로 연결(리다이렉트). 구현(#462): `vercel.json`에서 `/legal/{terms,privacy,delete-account}.html`을 GitHub Pages로 308, 운영 주소는 `siteUrls.ts` 한 곳.

## 검토한 대안 (Alternatives)
- 웹 `/legal/*`을 원본으로 남기기: 결정 표에 이유 없이 GitHub Pages가 선택됐다. 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 약관 사본이 하나로 줄어든다.

**부정**
- 리다이렉트는 `.html` 경로만 대상, `/legal/terms`처럼 확장자 없는 경로는 SPA 라우트로 처리된다(#462 주의사항).

## 영향 범위 (Scope)
`client/vercel.json`, `siteUrls.ts`, `gh-pages` 브랜치 약관 페이지.

## 출처 (References)
- GitHub #458 소유자 결정 댓글 2번 (2026-10-15), GitHub #462 구현 보고서
