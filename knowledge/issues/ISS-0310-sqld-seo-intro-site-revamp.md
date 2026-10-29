---
type: issue
id: ISS-0310
created: 2026-10-16
topics: [store-release]
symptoms: [검색 노출, SQLD 검색, sitemap.xml 404, robots.txt Sitemap 없음, JSON-LD 없음, canonical 없음, 웹 제목 passQL]
root_cause: "소개 사이트·웹 앱에 sitemap·구조화 데이터·검색어 담은 제목과 본문이 없고 검색엔진 등록이 안 됨"
status: resolved
resolution: "[[ISS-0310-sqld-seo-intro-site-revamp-report]]"
related: ["[[DEC-0139-intro-site-generated-from-src]]", "[[DEC-0140-no-spa-prerender-web-app]]"]
source: "https://github.com/Twin-Fang/passQL/issues/505"
---

# ISS-0310: SQLD·SQLP 검색 노출과 소개 사이트 개편

GitHub #505 (원본: 이슈 본문과 댓글).

## 증상
"SQLD", "SQLP", "SQLD 문제", "SQLD 기출"로 passQL이 검색되기 어렵다.
- 소개 사이트(gh-pages): sitemap.xml 없음(404), robots.txt에 Sitemap 줄 없음, JSON-LD 없음, App Store 출시(1.0, 2026-10-16) 배지 없이 "출시 준비 중" 표기, 검색어를 담은 본문 없음.
- 웹 앱: 제목이 `passQL` 하나뿐, 설명에 SQLD·SQLP 없음, sitemap·canonical 없음.
- Google Search Console·네이버 서치어드바이저 등록 여부와 소유 확인 정보 없음.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-10-16: PR #507(gh-pages), PR #508(웹) 머지.
- 2026-10-17: 검색엔진 등록·소유확인·sitemap 제출 후속(PR #515).

## 근본 원인
원본에 적힌 것: 웹 앱은 JS가 실행되면 제목이 `passQL`로 덮여 검색엔진이 보는 최종 제목에서 검색어가 사라졌다(`src/lib/notificationPresentation.ts`).
