---
type: decision
id: DEC-0139
created: 2026-10-16
reviewed: null
topics: [store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0310-sqld-seo-intro-site-revamp]]", "[[ISS-0310-sqld-seo-intro-site-revamp-report]]"]
---

# DEC-0139: 소개 사이트(gh-pages)는 `_src/` 생성 스크립트로만 만들고 HTML을 손으로 고치지 않는다

## 문제 정의 (Context)
소개 사이트를 검색 노출용으로 개편하면서 `<head>`가 여러 페이지에 반복됐다 (GitHub #505).

## 결정 (Decision)
- gh-pages 페이지(첫 화면, `/sqld/`, `/sqlp/`, 404, sitemap, robots)는 `_src/` 스크립트(`build_site.py` 등)가 생성한다. 실행: `python3 -I _src/build_site.py`.
- 주소·시험 범위·FAQ 문구의 원본은 `site_content.py`.
- HTML을 손으로 고치면 다음 생성 때 덮어씌워지므로 `_src/`를 고친다. 처음에는 법적 페이지(terms, privacy, delete-account)만 손으로 관리했으나, 2026-10-17 GitHub #506 후속에서 `privacy.html`·`terms.html`도 `_src/site_legal.py`가 운영 API 본문으로 생성하게 됐다.

## 검토한 대안 (Alternatives)
논의 기록 없음. (원본 이유: `<head>`가 여러 페이지에 반복돼서 한 곳에서 만들게 했다.)

## 결과 (Consequences)
**긍정**
- 공통 head·JSON-LD를 한 곳에서 관리. 스크립트 분리 전후 결과물 md5 일치.
- Play 공개 시 `IS_PLAY_STORE_PUBLIC = True` 한 줄과 재생성으로 배지·JSON-LD 설치 주소가 함께 바뀐다.

**부정**
- 시험 범위 9개 주제는 운영 데이터를 손으로 옮긴 사본이라 운영 주제 추가 시 `SQLD_SUBJECTS`를 함께 고쳐야 한다.

## 영향 범위 (Scope)
gh-pages 브랜치 `_src/`, 생성되는 HTML·sitemap·robots.

## 출처 (References)
- GitHub #505 보고서 댓글 (2026-10-16), GitHub #506 후속 댓글 (2026-10-17)
- [[ISS-0310-sqld-seo-intro-site-revamp]]
