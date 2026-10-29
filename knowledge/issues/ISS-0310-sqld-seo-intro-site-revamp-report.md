---
type: completion-report
id: ISS-0310
created: 2026-10-16
topics: [store-release]
status: resolved
resolves: "[[ISS-0310-sqld-seo-intro-site-revamp]]"
related: ["[[DEC-0139-intro-site-generated-from-src]]", "[[DEC-0140-no-spa-prerender-web-app]]"]
source: "https://github.com/Twin-Fang/passQL/issues/505"
---

# ISS-0310 완료 리포트: 소개 사이트 생성 스크립트·SQLD/SQLP 안내 페이지·검색 노출 요소와 검색엔진 등록

GitHub #505 보고서 댓글 2건 기준 (2026-10-16, 2026-10-17).

## 해결 방법
- 소개 사이트(gh-pages): 생성 스크립트 `_src/`(`site_content.py`, `site_head.py`, `site_guides.py`, `build_site.py`) 추가, 실행 `python3 -I _src/build_site.py`. 첫 화면 제목 "passQL — SQLD 문제 풀이 앱 | SQLD·SQLP 대비, SQL 실행과 AI 해설", 안내 페이지 `/sqld/`·`/sqlp/`(SQLP는 다루는 범위만, 튜닝 과목·실기 미제공 명시). JSON-LD(MobileApplication, WebSite, FAQPage, BreadcrumbList), canonical, OG·Twitter, `apple-itunes-app`, sitemap.xml 6개 주소, 404 noindex.
- 웹: `client/index.html` 제목·설명·OG에 검색어, canonical, WebApplication JSON-LD, iOS 설치 배너. 탭 제목 `passQL · SQLD·SQLP 문제 풀이`. `public/sitemap.xml`, robots.txt Sitemap 줄, `siteUrls.test.ts`.
- 후속(PR #515): Google Search Console·네이버 서치어드바이저에 두 사이트 등록, 소유확인, sitemap 제출. 네이버는 경로 붙은 주소를 받지 않아 조직 루트 사이트로 등록.
- 운영 확인: 4개 주소 200, 새 제목·JSON-LD 반영.

## 근본 원인 (확정)
검색 노출 요소 부재와 JS 실행 후 제목 덮어쓰기(이슈 노트 참조).

## 재발 방지
- 소개 사이트 HTML은 손으로 고치지 않고 `_src/`를 고쳐 재생성한다(법적 페이지 예외는 이후 GitHub #506 후속에서 생성 방식으로 바뀜).
- 프로젝트 사이트의 robots.txt는 검색엔진이 읽지 않으므로 sitemap은 검색 콘솔에 직접 제출해야 한다.
- 시험 범위 9개 주제는 운영 데이터 사본이라 주제 추가 시 `site_content.py`의 `SQLD_SUBJECTS`도 고쳐야 한다.
- 소유확인 파일·메타 태그를 지우면 확인이 풀린다. 루트 레포 `twin-fang.github.io`는 다른 프로젝트와 공용이다.
- Play 공개 후 `site_content.py`의 `IS_PLAY_STORE_PUBLIC = True`로 바꾸고 재생성.

## 교훈
(원본에 없음, 볼트 정리) SPA는 런타임에 `document.title`을 덮는 코드가 있으면 정적 태그의 검색어가 사라진다 — 빌드 결과(`dist/index.html`)와 실행 후 제목을 함께 본다.
