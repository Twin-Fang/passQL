---
type: issue
id: ISS-0204
created: 2026-10-07
topics: [store-release]
symptoms: [GitHub Pages 404, gh-pages, 개인정보처리방침 URL, 서비스 소개 페이지 없음, "twin-fang.github.io/passQL"]
root_cause: "해당 없음 — 서비스 소개·약관 공개 페이지가 없었다 (`https://twin-fang.github.io/passQL/` 404)"
status: resolved
resolution: "[[ISS-0204-github-pages-intro-legal-site-report]]"
related: ["[[ISS-0191-store-public-legal-pages-metadata]]"]
source: "https://github.com/Twin-Fang/passQL/issues/359"
---

# ISS-0204: passQL 서비스 소개·이용약관·개인정보처리방침 GitHub Pages 페이지

GitHub #359 (원본: 이슈 본문과 댓글).

## 증상
`https://twin-fang.github.io/passQL/`이 404다. 스토어 심사(App Store/Play)에서 개인정보처리방침 URL이 필요하고 서비스 소개용 공개 페이지도 없다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-07: 기존 프로젝트(EarLocAlert gh-pages: `index.html` / `privacy.html` / `terms.html` / `style.css`) 구조를 참고하기로 함. 작업 범위: `gh-pages` 브랜치(소스 브랜치와 분리, `.nojekyll`), 소개 페이지, 앱 내 `legal` 본문과 같은 약관·방침, 모바일 대응.

## 근본 원인
해당 없음.
