---
type: completion-report
id: ISS-0268
created: 2026-10-15
topics: [design-system, store-release]
status: resolved
resolves: "[[ISS-0268-web-brand-color-token-lint]]"
related: ["[[DEC-0121-unified-brand-color]]", "[[DEC-0119-legal-urls-on-github-pages]]"]
source: "https://github.com/Twin-Fang/passQL/issues/462"
---

# ISS-0268 완료 리포트: 웹 토큰 앱 light 값 통일(`#5856D6`), ESLint로 hex·인라인 style 금지, 약관 308 리다이렉트

GitHub #462 구현 보고서(2026-10-15) 기준.

## 해결 방법
- 색 토큰: 웹 토큰을 앱 light 값으로 통일(브랜드 `#5856D6`).
- 화면 코드의 hex, `[#]` 임의값, Tailwind 기본 팔레트, 인라인 style을 토큰으로. ESLint `no-restricted-syntax`로 hex·인라인 style 금지.
- 약관: `vercel.json`에서 `/legal/{terms,privacy,delete-account}.html` → GitHub Pages 308, 운영 주소는 `siteUrls.ts` 한 곳, 참조 0건 `public/legal/legal.js` 삭제.
- 정리: `design.ts`, Vite 템플릿 잔재 삭제, 약어 파일명 정리(`dateUtil.ts` 등), client 규칙 문서 갱신.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 원본: 새 색이 필요하면 토큰을 먼저 추가한다. hex를 직접 쓰면 lint가 실패한다.
- 검증: `npm run build`, vitest 21개, eslint 오류 0, Vercel run `38697240844` 후 https://passql.vercel.app 로그인 화면 정상, `/legal/*.html` 3개 → 308 → GitHub Pages(200).
- 주의(원본): 리다이렉트는 `.html` 경로만, 확장자 없는 `/legal/terms`는 SPA 라우트. 큰 페이지 파일 분리는 하지 않음(#458 남은 일).

## 교훈
원본 재발 방지 문장과 같음.
