---
type: issue
id: ISS-0268
created: 2026-10-15
topics: [design-system, store-release]
symptoms: ["#4F46E5", "#5856D6", hex 하드코딩 70건, 인라인 style 20건, design.ts, icons.svg, 약관 사본]
root_cause: "웹 브랜드 색이 앱과 달랐고, 화면 코드의 hex·인라인 style을 막는 규칙이 없었으며, 약관이 웹과 GitHub Pages에 사본으로 있었다"
status: resolved
resolution: "[[ISS-0268-web-brand-color-token-lint-report]]"
related: ["[[DEC-0121-unified-brand-color]]", "[[DEC-0119-legal-urls-on-github-pages]]", "[[DEC-0118-single-source-commonization-rules]]"]
source: "https://github.com/Twin-Fang/passQL/issues/462"
---

# ISS-0268: 웹 브랜드 색이 앱과 다르고 hex·인라인 style이 흩어짐, 약관 사본

GitHub #462 (원본: 이슈 본문과 구현 보고서). 상위 GitHub #458.

## 증상
- 웹 브랜드 색(#4F46E5)이 앱(#5856D6)과 다르다.
- hex 70건 이상, 인라인 style 20건. 안 쓰는 `design.ts`와 `icons.svg`.
- 약관 사본이 따로 있다.

## 재현 조건
해당 없음 (구조 문제).

## 조사 기록
- 2026-10-15: 기준 — 상위 #458, 동작은 바꾸지 않고 구조만.

## 근본 원인
frontmatter `root_cause`와 같음.
